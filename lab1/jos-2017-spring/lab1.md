[TOC]


问题：
1. qemu到底是啥？与虚拟机什么关系？
2. 什么是boot address 什么是 load address
3. 传参数为什么可以有省略号


# （一）Part 1: PC Bootstrap
## （a）32位系统内存结构The PC's Physical Address Space
```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  <- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  <- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000
```
在以上区域中，最重要的是Basic Input/Output System (`BIOS`)，其地址为`0x000F0000 -> 0x000FFFFF`的64K大小的区域。
当开机之后系统执行的`第一条指令`是：
```
[f000:fff0] 0xffff0: ljmp $0xf000,$0xe05b
```
我们知道该条指令在BIOS的最上面16byte的位置（`0xffff0` is 16 bytes before the end of the BIOS (0x100000)），是一条跳转指令，该跳转指令跳到BIOS的较低的位置。
由于*CS = 0xf000*和 *IP = 0xe05b*, 我们知道跳到位置为：*0xfe05b*的位置，那么到了该位置做了些什么事情呢？
1. 设置中断向量表
2. 初始化各种设备

当完成初始化所有BIOS能够检测到的设备之后，**BIOS搜索能够启动的设备(如软盘、硬盘、CD-ROM等)，对该设备的第一个扇区进行读取，最后将控制权转移给扇区中存放的bootloader**

 注意点：
（1）在上述启动的过程中，CPU是运行在实模式下；
（2）对于硬盘来说，最基本存储单元是扇区(sector)，每个扇区容量为512个字节。
（3）对于一个可启动的硬盘，其第一个扇区必须是bootloader，故bootloader不能占据过大的空间

# （二）Part 2: The Boot Loader
Boot Loader主要完成的功能：
（1）实模式转变为保护模式
（2）加载内核文件

## (a) 实模式转变为保护模式
该代码在`boot/boot.S`中：
该代码是在系统启动盘的第一个扇区，BIOS把这段代码读入到内存为：`0x7c00`的位置。那么该段代码主要完成哪些功能呢？
1. 关闭中断，设置串处理从低地址向高地址处理。
2. 相关寄存器清零，堆栈寄存器设置为0x7c00开始
3. A20地址线：打开A20 Gate使得可以访问的内存则是连续的且能访问1M以上的内存。
4. 装载全局描述符，并设置cr0（PE位设置为1）进入使系统进入保护模式
5.  接下来系统进入32位的保护模式，进行了一个关键跳转
6. 下面是一些寄存器的初始化，并跳入c代码（`boot/main.c`的bootmain: 主要是加载内核文件）运行。

以上步骤具体对应的代码见：[bootLoader代码分析](http://m.blog.chinaunix.net/uid-24585655-id-2125526.html);接下来主要介绍实模式到保护模式的变换。

### 开启保护模式
开启保护模式涉及到了cr0寄存器下的PE位(即第0位)，当PE置1后，CPU将开启保护模式，此时保护模式下的分段保护机制将会被一同开启(分页机制没有开启)，故在开启保护模式前，需要设置好全局描述符表。
JOS中对于保护模式的开启有以下代码：
```
  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.

  lgdt    gdtdesc                    # 加载全局描述符表
  movl    %cr0, %eax                      
  orl     $CR0_PE_ON, %eax          #  cr0寄存器下的PE位(即第0位)置1
  movl    %eax, %cr0                      
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg

```
注意该关键的跳转：
```
.set PROT_MODE_CSEG, 0x8         # kernel code segment selector
.set PROT_MODE_DSEG, 0x10        # kernel data segment selector
ljmp    $PROT_MODE_CSEG, $protcseg
```
`PROT_MODE_CSEG`为段选择子，对于PROT_MODE_CSEG定义为0x8而言，就是选择第一个代码段，也即是当前执行的代码段，同样$protcseg也即是当前代码里面的$protcset处，程序也就跳入了32位的保护模式进行运行。


### 全局描述符

需要了解可以看一下：
[GDTR和GDT介绍](https://en.wikibooks.org/wiki/X86_Assembly/Global_Descriptor_Table)
[GDT数据结构](http://wiki.osdev.org/Global_Descriptor_Table)
[全局描述符的载入](http://m.blog.chinaunix.net/uid-24585655-id-2125527.html)


GDT(Global Descriptor Table)是内存中的一个表，用于定义进程的内存分段情况。GDT设置一些段寄存器，从而使得能够平稳转换为保护模式。
GDT由一个特殊的寄存器GDTR(GDT Register)指向。该GDTR总共48位，低16位描述GDT的大小，高32位描述GDT在内存中的地址；以下是GDTR的格式：
```
|LIMIT|----BASE----|
```
* LIMIT: 表示GDT的大小，比实际的小1，如果LIMIT为15那么说明大小为16.
BASE: 表示GDT在内存中的大小。

如何加载GDTR呢：
```
lgdt [gdtr]   // 加载GDTR
```
其中*gdtr*是一个指向6字节大小内存的指针。为了加载新的GDT, 段寄存器需要重新加载，其中*CS* 段寄存器需要使用far jump来加载：
``` 
flush_gdt:
    lgdt [gdtr]
    jmp 0x08:complete_flush
 
complete_flush:
    mov 0x10, ax
    mov ax, ds
    mov ax, es
    mov ax, fs
    mov ax, gs
    mov ax, ss
    ret
```

接下来看一下bootloader中相关的代码：
``` nasm
.set PROT_MODE_CSEG, 0x8         # kernel code segment selector
.set PROT_MODE_DSEG, 0x10       # kernel data segment selector

lgdt    gdtdesc           # 加载GDTR, 位置在符号gdtdesc表示的地方。

# Jump to next instruction, but in 32-bit code segment.
# Switches processor into 32-bit mode.
ljmp    $PROT_MODE_CSEG, $protcseg             # 加载CS段寄存器

.code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
  movw    %ax, %ss                # -> SS: Stack Segment
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
  call bootmain
# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:                                      # 表示gdt的内容，对于全局描述符表的介绍将会在下一篇文章中涉及，在这里需要知道的是，全局描述符表的第0项存储的内容必须为空(即为0)

  SEG_NULL                                # 空项
  SEG(STA_X|STA_R, 0x0, 0xffffffff)       # 代码项
  SEG(STA_W, 0x0, 0xffffffff)             # 数据项

gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1 ：23表示gdt的大小为24byte；此处表示在全局描述符表中共设置了三项，每项8字节。
  .long   gdt                             # address gdt  ：表示gdt的内存位置在gdt符号处
```

gdt为预先设定好的全局描述符表。对于全局描述符表的介绍将会在下一篇文章中涉及，在这里需要知道的是，全局描述符表的第0项存储的内容必须为空(即为0)
可以看出，在gdt中，将代码段和数据段全部映射到了4GB内存空间中，这对于启动过程来说，是完全够用的。


在*boot/boot.S*最后是一个跳转指令，该指令使程序跳到`boot/main.c`中执行。
```
  call bootmain
```


## (b) 加载内核文件
该代码在`boot/main.c`中：
这一部分中，主要完成的工作就是将内核文件加载到内存中(/boot/main.c)，并将控制权限交给内核。在更进一步的介绍之前，首先阐述ELF文件格式。对于ELF文件格式的定义在<inc/elf.h>中。我们无需深入的了解ELF文件格式(如希望深入了解的话，在MIT6.828的指定文献中列出了ELF文件的详细格式内容)，实际上来说，ELF类似于一个超大的“结构体”，每一个部分都存放了一定的内容，而对于该内容的描述在“头部”中存放。这里给出了JOS下<inc/elf.h>中的定义以及解释。
```
struct Elf {
    uint32_t e_magic;    // must equal ELF_MAGIC
    uint8_t e_elf[12];
    uint16_t e_type;     // 表示该文件类型
    uint16_t e_machine;  // 运行该程序需要的体系结构
    uint32_t e_version;  // 文件版本
    uint32_t e_entry;    // 程序入口地址
    uint32_t e_phoff;    // Program header table在文件中的偏移量(以字节计数)
    uint32_t e_shoff;    // Section header table在文件中的偏移量
    uint32_t e_flags;    // 对于IA32来说，计为0
    uint16_t e_ehsize;   // 表示ELF header大小
    uint16_t e_phentsize; // Program header table中每一项目的大小
    uint16_t e_phnum;     // Program header table有多少个项目
    uint16_t e_shentsize; // Section header table中每一项目的大小
    uint16_t e_shnum;     // Section header table有多少个项目
    uint16_t e_shstrndx;  // 包含节名称的字符串是第几个节(0开始计数)
};

struct Proghdr {
    uint32_t p_type;     // 当前Program header所描述的段的类型
    uint32_t p_offset;   // 段的第一个字节在文件中的偏移
    uint32_t p_va;       // 段的一个字节在内存中的虚拟地址
    uint32_t p_pa;       // 在物理内存定位的相关系统中，此项是为物理地址保留的
    uint32_t p_filesz;   // 段在文件中的长度
    uint32_t p_memsz;    // 段在内存中的长度
    uint32_t p_flags;    // 与段相关的标志
    uint32_t p_align;    // 根据此值来确定段在文件以及内存中如何对齐
};

```
下述代码主要是将内核读取到磁盘中，并最后将控制权移交给内核。

```
#define SECTSIZE    512
#define ELFHDR      ((struct Elf *) 0x10000) // scratch space

void readsect(void*, uint32_t);
// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    struct Proghdr *ph, *eph;
    // read 1st page off disk
    // 可以看出，内核加载于0x10000处之上，一共加载了512字节 * 8 = 4K，即分页模式下一个完整的页的大小
    readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    // is this a valid ELF? JOS中要求ELF文件的第一项必须为ELF_MAGIC
    if (ELFHDR->e_magic != ELF_MAGIC)
        goto bad;
    // load each program segment (ignores ph flags) 
    // 加载代码段， 可以看出每个代码段都规定了加载的位置以及大小
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph++)
        // p_pa is the load address of this segment (as well
        // as the physical address)
        readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    // call the entry point from the ELF header
    // note: does not return!
    // 移交控制权，e_entry即为入口函数， 此函数不会返回，如果返回则意味着执行出现了某种问题，此后系统进入死循环，需要手动重启
    ((void (*)(void)) (ELFHDR->e_entry))();
bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);
    while (1)
        /* do nothing */;
}

```
### 问题答案：

下面回答一下文中提出的四个问题： 
1. 在什么时候处理器开始运行于32bit模式？到底是什么把CPU从16位切换为32位工作模式？ 
　答：在boot.S文件中，计算机首先工作于实模式，此时是16bit工作模式。当运行完 `ljmp $PROT_MODE_CSEG, $protcseg` 语句后，正式进入32位工作模式。根本原因是此时CPU工作在保护模式下。

2. boot loader中执行的最后一条语句是什么？内核被加载到内存后执行的第一条语句又是什么？ 
　答：boot loader执行的最后一条语句是bootmain子程序中的最后一条语句 `((void (*)(void)) (ELFHDR->e_entry))(); `，即跳转到操作系统内核程序的起始指令处。 
　　 这个第一条指令位于`/kern/entry.S`文件中，第一句 movw $0x1234, 0x472 
　 
3. 内核的第一条指令在哪里？ 
　答：第一条指令位于/kern/entry.S文件中。

4. boot loader是如何知道它要读取多少个扇区才能把整个内核都送入内存的呢？在哪里找到这些信息？ 
　答：首先关于操作系统一共有多少个段，每个段又有多少个扇区的信息位于操作系统文件中的Program Header Table中。这个表中的每个表项分别对应操作系统的一个段。并且每个表项的内容包括这个段的大小，段起始地址偏移等等信息。所以如果我们能够找到这个表，那么就能够通过表项所提供的信息来确定内核占用多少个扇区。

boot loader通过`ELFHDR->e_phnum`得知Program header table有多少个项目,然后每个Program header table中的`p_memsz`得知每个项目的大小。从而可以得到总共的大小。


### 链接地址 vs 载入地址



# （三）Part 3: The Kernel

## 3.1 使用分段操作位置相关

根据提示，用gdb执行到kern的第一步指令地址为 *0x10000c(load address)* , 而 */obj/kern/kernal.asm(link address)* 对应的指令地址为 *0xf010000c*; 根据指导，*0xf010000c* 为虚拟地址，对应的物理地址为 *0x0010000c* ;此时并没有切换到虚拟地址。
进入kern后继续单步调试，可以发现在 *0x0010002d* 执行之后新的虚拟物理地址起效了，下一个指令的地址在 *0xf010002f* 。
```c
(gdb) si                                                              
0x10000c:      movw  $0x1234,0x472                                  
0x0010000c in ?? ()                                                  
(gdb) si                                                              
0x100015:      mov    $0x118000,%eax                                
0x00100015 in ?? ()                                                  
(gdb) si                                                              
0x10001a:      mov    %eax,%cr3                                      
0x0010001a in ?? ()                                                  
(gdb) si                                                              
0x10001d:      mov    %cr0,%eax                                      
0x0010001d in ?? ()                                                  
(gdb) si                                                              
0x100020:      or    $0x80010001,%eax                              
0x00100020 in ?? ()                                                  
(gdb) si                                                              
0x100025:      mov    %eax,%cr0                                      
0x00100025 in ?? ()                                                  
(gdb) si                                                              
0x100028:      mov    $0xf010002f,%eax                              
0x00100028 in ?? ()                                                  
(gdb) si                                                              
0x10002d:      jmp    *%eax                                          
0x0010002d in ?? ()                                                  
(gdb) si                                                              
0xf010002f:    mov    $0x0,%ebp                                      
73              movl    $0x0,%ebp                      # nuke frame pointer                                                                
```
其对应的代码*/kern/entry.S*为：
```c
.globl entry
entry:
movw	$0x1234,0x472	# warm boot

# We haven't set up virtual memory yet, so we're running from
# the physical address the boot loader loaded the kernel at: 1MB
# (plus a few bytes).  However, the C code is linked to run at
# KERNBASE+1MB.  Hence, we set up a trivial page directory that
# translates virtual addresses [KERNBASE, KERNBASE+4MB) to
# physical addresses [0, 4MB).  This 4MB region will be suffice
# until we set up our real page table in i386_vm_init in lab 2.

# Load the physical address of entry_pgdir into cr3.  entry_pgdir
# is defined in entrypgdir.c.
movl	$(RELOC(entry_pgdir)), %eax
movl	%eax, %cr3                            # 把entry_pgdir的物理地址存放到cr3
# Turn on paging.
movl	%cr0, %eax
orl	$(CR0_PE|CR0_PG|CR0_WP), %eax  
movl	%eax, %cr0

# Now paging is enabled, but we're still running at a low EIP
# (why is this okay?).  Jump up above KERNBASE before entering
# C code.
mov	$relocated, %eax
jmp	*%eax
relocated:                        
```

以上代码我们发现*cr3*寄存器存放的是*entry_pgdir*的地址。我们指导*cr3*都是存储页表的基址的；我们去*entrypgdir.c*文件看一下*entry_pgdir*存放的是啥：
```
pde_t entry_pgdir[NPDENTRIES] = {
    // Map VA's [0, 4MB) to PA's [0, 4MB)
    [0]
        = ((uintptr_t)entry_pgtable - KERNBASE) + PTE_P,
    // Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
    [KERNBASE>>PDXSHIFT]
        = ((uintptr_t)entry_pgtable - KERNBASE) + PTE_P + PTE_W
};
```
### 3.1.1 页表相关：
在32位系统中，当页的大小为4k时，是用二级页表的。
**page页**是一段连续的地址，其大小可以为：4M, 2M, 4KB，其中4KB是使用最多的，目前主流操作系统使用的都是4KB.
**page table 页表** 是一个大小为1024的数组，每一项为32-bit. (因此页表的大小符合 1024x32 为4KB)。页表中的每一项指向一个物理页的地址。由于一个页表是不足以涵盖所有的地址空间的（因为页表中每一项都指向一个页，一个页的大小为4KB, 一个页表共1024项，1024 entries x 4KB = only 22-bits of address space ）。所以需要使用二级页表基址。
**page directory ** 和页表一样也是一个1024大小的数组，每一项为32-bit。 但是每一项指向一个页表的基址。所以此时可以表达的范围为：1024x1024x4KB 也就是4GB。 

当给定一个虚拟地址时，会先使用高10位（31:22）来索引 page directory（其中page directory 的基址存放在 **cr3** 寄存器中。）,得到页表的基址后，使用次高10位（21:12）来索引页表，从而得到页的基址。最后通过低12位（11:0）得到具体地址。

由于**页表项**都是指向一个页的基址，而页都是4KB对齐的，所以页表项的低12位肯定是0，所以可以在页表项的低12位存储别的控制信息：
```
// Page table/directory entry flags.
#define PTE_P        0x001    // Present
#define PTE_W        0x002    // Writeable
#define PTE_U        0x004    // User
#define PTE_PWT        0x008    // Write-Through
#define PTE_PCD        0x010    // Cache-Disable
#define PTE_A        0x020    // Accessed
#define PTE_D        0x040    // Dirty
#define PTE_PS        0x080    // Page Size
#define PTE_G        0x100    // Global
```

## 3.2 格式化打印到控制台

首先跟踪打印: 
### 3.2.1 i386_init
当进入kernel后的第一段代码（ *entry.S* ）负责开启页式内存管理，由汇编代码完成，此后kernel就运行在虚拟地址空间的高256M的地址空间，其余代码均由c语言编写。
在 *entry.S* 文件中完成开启页式管理等任务后，跳转到第一个c语言程序：*i386_init* . 该函数在文件 */kern/init.c* 中。
在函数 *i386_init* 首先把 *BSS* 中的内容清零(*memset(...)*) ，然后初始化控制台（ *const_init()* 为了输入输出）。 
之后调用 
``` c
// /kern/init.c 文件的 i386_init 函数
cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2); 
``` 

### 3.2.2 cprintf

``` c
int cprintf(const char *fmt, ...)  return cnt;
|| 调用
int vcprintf(const char *fmt, va_list ap) return cnt;
|| 调用
void vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...);
|| 调用
void printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...);     // 格式化输出的主要函数。，其中putdat参数用于更新cnt用于说明已经输出了多少字符。
|| 调用
static void putch(int ch, int *cnt); // 通过调用console的cputchar() 函数来输出单个字符。
```

### 3.2.2 vprintfmt

**vprintfmt**主要用于遍历输出字符串；它从头开始遍历**fmt**字符串，逐个输出字符，当遇到**%**时，就判断后面跟的字符(比如：d、l、c、s等等)来判断此处的占位符是啥，然后做出相应的操作。
比如，当**%**后面跟的**d**时说明是一个十进制的数字，所以会去读取一个数（*getint()*）；然后设置数的base为10（ *base=10;* ）,然后调用**printnum()**来输出该数字。
```c
// /lib/printfmt.c中的vprintfmt函数
// 格式化输出％d的情况。
        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 10;
            goto number;
        number:
            printnum(putch, putdat, num, base, width, padc);
            break;

```

### 3.2.3 输出八进制数字
类似上一小节的输出10进制数字，我们修改/lib/printfmt.c中的vprintfmt函数中关于输出八进制的输出；它原先的输出为：


```c
// cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2); 
// 输出：6828 decimal is XXX octal!
// /lib/printfmt.c中的vprintfmt函数
// 修改之前的八进制输出
        // (unsigned) octal
        case 'o':
            // Replace this with your code.
            // display a number in octal form and the form should begin with '0'
            putch('X', putdat);
            putch('X', putdat);
            putch('X', putdat);
            break;
```

修改之后为：
```c
// cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2); 
// 输出：6828 decimal is 015254 octal!
// /lib/printfmt.c中的vprintfmt函数
// 修改之后的八进制输出
        // (unsigned) octal
        case 'o':
            // Replace this with your code.
            // display a number in octal form and the form should begin with '0'
            //putch('X', putdat);
            //putch('X', putdat);
            //putch('X', putdat);
            putch('0', putdat);
            num = getuint(&ap, lflag);
            base = 8;
            goto number;
```

## 3.3 Stack

首先看一下当test_backtrace调用test_backtrace的栈的结构：

|栈|寄存器|函数|
|---|---|---|
|`test_backtrace` 接受到本层参数1 | <- old esp|caller|
|return addr(old eip+4 因为call会放置 call下一条指令的address) ||caller|
|old ebp |<- ebp|`callee`|
|old ebx||`callee`|
|函数内临时数据/下一层调用第5个参数||`callee`|
|函数内临时数据/下一层调用第4个参数||`callee`|
|函数内临时数据/下一层调用第3个参数||`callee`|
|函数内临时数据/下一层调用第2个参数||`callee`|
|函数内临时数据/下一层调用第1个参数|<- esp|`callee`|
|可能的未来的会放置的eip+4|||



