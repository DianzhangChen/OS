
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 b0 f1 20 f0       	mov    $0xf020f1b0,%eax
f010004b:	2d b3 e2 20 f0       	sub    $0xf020e2b3,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 b3 e2 20 f0 	movl   $0xf020e2b3,(%esp)
f0100063:	e8 5f 4d 00 00       	call   f0104dc7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b1 04 00 00       	call   f010051e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 40 52 10 f0 	movl   $0xf0105240,(%esp)
f010007c:	e8 0f 37 00 00       	call   f0103790 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 87 12 00 00       	call   f010130d <mem_init>

	// Lab 3 user environment initialization functions
	cprintf("before env_init!\n");               ////////////////////////////////////////////////////////
f0100086:	c7 04 24 5b 52 10 f0 	movl   $0xf010525b,(%esp)
f010008d:	e8 fe 36 00 00       	call   f0103790 <cprintf>
	env_init();
f0100092:	e8 8c 2f 00 00       	call   f0103023 <env_init>
	cprintf("after env_init!\n");               ////////////////////////////////////////////////////////
f0100097:	c7 04 24 6d 52 10 f0 	movl   $0xf010526d,(%esp)
f010009e:	e8 ed 36 00 00       	call   f0103790 <cprintf>
	trap_init();
f01000a3:	e8 61 37 00 00       	call   f0103809 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000af:	00 
f01000b0:	c7 44 24 04 b7 f9 00 	movl   $0xf9b7,0x4(%esp)
f01000b7:	00 
f01000b8:	c7 04 24 89 29 16 f0 	movl   $0xf0162989,(%esp)
f01000bf:	e8 0d 32 00 00       	call   f01032d1 <env_create>
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	
	cprintf("before env_run!\n");               ////////////////////////////////////////////////////////
f01000c4:	c7 04 24 7e 52 10 f0 	movl   $0xf010527e,(%esp)
f01000cb:	e8 c0 36 00 00       	call   f0103790 <cprintf>
	env_run(&envs[0]);
f01000d0:	a1 0c e5 20 f0       	mov    0xf020e50c,%eax
f01000d5:	89 04 24             	mov    %eax,(%esp)
f01000d8:	e8 a4 35 00 00       	call   f0103681 <env_run>

f01000dd <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	56                   	push   %esi
f01000e1:	53                   	push   %ebx
f01000e2:	83 ec 10             	sub    $0x10,%esp
f01000e5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000e8:	83 3d a0 f1 20 f0 00 	cmpl   $0x0,0xf020f1a0
f01000ef:	75 3d                	jne    f010012e <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000f1:	89 35 a0 f1 20 f0    	mov    %esi,0xf020f1a0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000f7:	fa                   	cli    
f01000f8:	fc                   	cld    

	va_start(ap, fmt);
f01000f9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100103:	8b 45 08             	mov    0x8(%ebp),%eax
f0100106:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010a:	c7 04 24 8f 52 10 f0 	movl   $0xf010528f,(%esp)
f0100111:	e8 7a 36 00 00       	call   f0103790 <cprintf>
	vcprintf(fmt, ap);
f0100116:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011a:	89 34 24             	mov    %esi,(%esp)
f010011d:	e8 3b 36 00 00       	call   f010375d <vcprintf>
	cprintf("\n");
f0100122:	c7 04 24 29 62 10 f0 	movl   $0xf0106229,(%esp)
f0100129:	e8 62 36 00 00       	call   f0103790 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100135:	e8 f5 06 00 00       	call   f010082f <monitor>
f010013a:	eb f2                	jmp    f010012e <_panic+0x51>

f010013c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013c:	55                   	push   %ebp
f010013d:	89 e5                	mov    %esp,%ebp
f010013f:	53                   	push   %ebx
f0100140:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100143:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100146:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100149:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100150:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100154:	c7 04 24 a7 52 10 f0 	movl   $0xf01052a7,(%esp)
f010015b:	e8 30 36 00 00       	call   f0103790 <cprintf>
	vcprintf(fmt, ap);
f0100160:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100164:	8b 45 10             	mov    0x10(%ebp),%eax
f0100167:	89 04 24             	mov    %eax,(%esp)
f010016a:	e8 ee 35 00 00       	call   f010375d <vcprintf>
	cprintf("\n");
f010016f:	c7 04 24 29 62 10 f0 	movl   $0xf0106229,(%esp)
f0100176:	e8 15 36 00 00       	call   f0103790 <cprintf>
	va_end(ap);
}
f010017b:	83 c4 14             	add    $0x14,%esp
f010017e:	5b                   	pop    %ebx
f010017f:	5d                   	pop    %ebp
f0100180:	c3                   	ret    
f0100181:	00 00                	add    %al,(%eax)
	...

f0100184 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100184:	55                   	push   %ebp
f0100185:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100187:	ba 84 00 00 00       	mov    $0x84,%edx
f010018c:	ec                   	in     (%dx),%al
f010018d:	ec                   	in     (%dx),%al
f010018e:	ec                   	in     (%dx),%al
f010018f:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100190:	5d                   	pop    %ebp
f0100191:	c3                   	ret    

f0100192 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100192:	55                   	push   %ebp
f0100193:	89 e5                	mov    %esp,%ebp
f0100195:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010019a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010019b:	a8 01                	test   $0x1,%al
f010019d:	74 08                	je     f01001a7 <serial_proc_data+0x15>
f010019f:	b2 f8                	mov    $0xf8,%dl
f01001a1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001a2:	0f b6 c0             	movzbl %al,%eax
f01001a5:	eb 05                	jmp    f01001ac <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	53                   	push   %ebx
f01001b2:	83 ec 04             	sub    $0x4,%esp
f01001b5:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001b7:	eb 29                	jmp    f01001e2 <cons_intr+0x34>
		if (c == 0)
f01001b9:	85 c0                	test   %eax,%eax
f01001bb:	74 25                	je     f01001e2 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001bd:	8b 15 e4 e4 20 f0    	mov    0xf020e4e4,%edx
f01001c3:	88 82 e0 e2 20 f0    	mov    %al,-0xfdf1d20(%edx)
f01001c9:	8d 42 01             	lea    0x1(%edx),%eax
f01001cc:	a3 e4 e4 20 f0       	mov    %eax,0xf020e4e4
		if (cons.wpos == CONSBUFSIZE)
f01001d1:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001d6:	75 0a                	jne    f01001e2 <cons_intr+0x34>
			cons.wpos = 0;
f01001d8:	c7 05 e4 e4 20 f0 00 	movl   $0x0,0xf020e4e4
f01001df:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001e2:	ff d3                	call   *%ebx
f01001e4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e7:	75 d0                	jne    f01001b9 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001e9:	83 c4 04             	add    $0x4,%esp
f01001ec:	5b                   	pop    %ebx
f01001ed:	5d                   	pop    %ebp
f01001ee:	c3                   	ret    

f01001ef <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001ef:	55                   	push   %ebp
f01001f0:	89 e5                	mov    %esp,%ebp
f01001f2:	57                   	push   %edi
f01001f3:	56                   	push   %esi
f01001f4:	53                   	push   %ebx
f01001f5:	83 ec 1c             	sub    $0x1c,%esp
f01001f8:	89 c6                	mov    %eax,%esi
f01001fa:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001ff:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100200:	a8 20                	test   $0x20,%al
f0100202:	75 19                	jne    f010021d <cons_putc+0x2e>
f0100204:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100209:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010020e:	e8 71 ff ff ff       	call   f0100184 <delay>
f0100213:	89 fa                	mov    %edi,%edx
f0100215:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100216:	a8 20                	test   $0x20,%al
f0100218:	75 03                	jne    f010021d <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010021a:	4b                   	dec    %ebx
f010021b:	75 f1                	jne    f010020e <cons_putc+0x1f>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f010021d:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010021f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100224:	89 f0                	mov    %esi,%eax
f0100226:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100227:	b2 79                	mov    $0x79,%dl
f0100229:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010022a:	84 c0                	test   %al,%al
f010022c:	78 17                	js     f0100245 <cons_putc+0x56>
f010022e:	bb 00 32 00 00       	mov    $0x3200,%ebx
		delay();
f0100233:	e8 4c ff ff ff       	call   f0100184 <delay>
f0100238:	ba 79 03 00 00       	mov    $0x379,%edx
f010023d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010023e:	84 c0                	test   %al,%al
f0100240:	78 03                	js     f0100245 <cons_putc+0x56>
f0100242:	4b                   	dec    %ebx
f0100243:	75 ee                	jne    f0100233 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100245:	ba 78 03 00 00       	mov    $0x378,%edx
f010024a:	89 f8                	mov    %edi,%eax
f010024c:	ee                   	out    %al,(%dx)
f010024d:	b2 7a                	mov    $0x7a,%dl
f010024f:	b0 0d                	mov    $0xd,%al
f0100251:	ee                   	out    %al,(%dx)
f0100252:	b0 08                	mov    $0x8,%al
f0100254:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100255:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010025b:	75 06                	jne    f0100263 <cons_putc+0x74>
		c |= 0x0700;
f010025d:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100263:	89 f0                	mov    %esi,%eax
f0100265:	25 ff 00 00 00       	and    $0xff,%eax
f010026a:	83 f8 09             	cmp    $0x9,%eax
f010026d:	74 78                	je     f01002e7 <cons_putc+0xf8>
f010026f:	83 f8 09             	cmp    $0x9,%eax
f0100272:	7f 0b                	jg     f010027f <cons_putc+0x90>
f0100274:	83 f8 08             	cmp    $0x8,%eax
f0100277:	0f 85 9e 00 00 00    	jne    f010031b <cons_putc+0x12c>
f010027d:	eb 10                	jmp    f010028f <cons_putc+0xa0>
f010027f:	83 f8 0a             	cmp    $0xa,%eax
f0100282:	74 39                	je     f01002bd <cons_putc+0xce>
f0100284:	83 f8 0d             	cmp    $0xd,%eax
f0100287:	0f 85 8e 00 00 00    	jne    f010031b <cons_putc+0x12c>
f010028d:	eb 36                	jmp    f01002c5 <cons_putc+0xd6>
	case '\b':
		if (crt_pos > 0) {
f010028f:	66 a1 f4 e4 20 f0    	mov    0xf020e4f4,%ax
f0100295:	66 85 c0             	test   %ax,%ax
f0100298:	0f 84 e2 00 00 00    	je     f0100380 <cons_putc+0x191>
			crt_pos--;
f010029e:	48                   	dec    %eax
f010029f:	66 a3 f4 e4 20 f0    	mov    %ax,0xf020e4f4
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002a5:	0f b7 c0             	movzwl %ax,%eax
f01002a8:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002ae:	83 ce 20             	or     $0x20,%esi
f01002b1:	8b 15 f0 e4 20 f0    	mov    0xf020e4f0,%edx
f01002b7:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002bb:	eb 78                	jmp    f0100335 <cons_putc+0x146>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002bd:	66 83 05 f4 e4 20 f0 	addw   $0x50,0xf020e4f4
f01002c4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002c5:	66 8b 0d f4 e4 20 f0 	mov    0xf020e4f4,%cx
f01002cc:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002d1:	89 c8                	mov    %ecx,%eax
f01002d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01002d8:	66 f7 f3             	div    %bx
f01002db:	66 29 d1             	sub    %dx,%cx
f01002de:	66 89 0d f4 e4 20 f0 	mov    %cx,0xf020e4f4
f01002e5:	eb 4e                	jmp    f0100335 <cons_putc+0x146>
		break;
	case '\t':
		cons_putc(' ');
f01002e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ec:	e8 fe fe ff ff       	call   f01001ef <cons_putc>
		cons_putc(' ');
f01002f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f6:	e8 f4 fe ff ff       	call   f01001ef <cons_putc>
		cons_putc(' ');
f01002fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100300:	e8 ea fe ff ff       	call   f01001ef <cons_putc>
		cons_putc(' ');
f0100305:	b8 20 00 00 00       	mov    $0x20,%eax
f010030a:	e8 e0 fe ff ff       	call   f01001ef <cons_putc>
		cons_putc(' ');
f010030f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100314:	e8 d6 fe ff ff       	call   f01001ef <cons_putc>
f0100319:	eb 1a                	jmp    f0100335 <cons_putc+0x146>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010031b:	66 a1 f4 e4 20 f0    	mov    0xf020e4f4,%ax
f0100321:	0f b7 c8             	movzwl %ax,%ecx
f0100324:	8b 15 f0 e4 20 f0    	mov    0xf020e4f0,%edx
f010032a:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010032e:	40                   	inc    %eax
f010032f:	66 a3 f4 e4 20 f0    	mov    %ax,0xf020e4f4
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100335:	66 81 3d f4 e4 20 f0 	cmpw   $0x7cf,0xf020e4f4
f010033c:	cf 07 
f010033e:	76 40                	jbe    f0100380 <cons_putc+0x191>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100340:	a1 f0 e4 20 f0       	mov    0xf020e4f0,%eax
f0100345:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010034c:	00 
f010034d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100353:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100357:	89 04 24             	mov    %eax,(%esp)
f010035a:	e8 b2 4a 00 00       	call   f0104e11 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010035f:	8b 15 f0 e4 20 f0    	mov    0xf020e4f0,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100365:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010036a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100370:	40                   	inc    %eax
f0100371:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100376:	75 f2                	jne    f010036a <cons_putc+0x17b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100378:	66 83 2d f4 e4 20 f0 	subw   $0x50,0xf020e4f4
f010037f:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100380:	8b 0d ec e4 20 f0    	mov    0xf020e4ec,%ecx
f0100386:	b0 0e                	mov    $0xe,%al
f0100388:	89 ca                	mov    %ecx,%edx
f010038a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010038b:	66 8b 35 f4 e4 20 f0 	mov    0xf020e4f4,%si
f0100392:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100395:	89 f0                	mov    %esi,%eax
f0100397:	66 c1 e8 08          	shr    $0x8,%ax
f010039b:	89 da                	mov    %ebx,%edx
f010039d:	ee                   	out    %al,(%dx)
f010039e:	b0 0f                	mov    $0xf,%al
f01003a0:	89 ca                	mov    %ecx,%edx
f01003a2:	ee                   	out    %al,(%dx)
f01003a3:	89 f0                	mov    %esi,%eax
f01003a5:	89 da                	mov    %ebx,%edx
f01003a7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003a8:	83 c4 1c             	add    $0x1c,%esp
f01003ab:	5b                   	pop    %ebx
f01003ac:	5e                   	pop    %esi
f01003ad:	5f                   	pop    %edi
f01003ae:	5d                   	pop    %ebp
f01003af:	c3                   	ret    

f01003b0 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003b0:	55                   	push   %ebp
f01003b1:	89 e5                	mov    %esp,%ebp
f01003b3:	53                   	push   %ebx
f01003b4:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b7:	ba 64 00 00 00       	mov    $0x64,%edx
f01003bc:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003bd:	a8 01                	test   $0x1,%al
f01003bf:	0f 84 d8 00 00 00    	je     f010049d <kbd_proc_data+0xed>
f01003c5:	b2 60                	mov    $0x60,%dl
f01003c7:	ec                   	in     (%dx),%al
f01003c8:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003ca:	3c e0                	cmp    $0xe0,%al
f01003cc:	75 11                	jne    f01003df <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003ce:	83 0d e8 e4 20 f0 40 	orl    $0x40,0xf020e4e8
		return 0;
f01003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003da:	e9 c3 00 00 00       	jmp    f01004a2 <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f01003df:	84 c0                	test   %al,%al
f01003e1:	79 33                	jns    f0100416 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003e3:	8b 0d e8 e4 20 f0    	mov    0xf020e4e8,%ecx
f01003e9:	f6 c1 40             	test   $0x40,%cl
f01003ec:	75 05                	jne    f01003f3 <kbd_proc_data+0x43>
f01003ee:	88 c2                	mov    %al,%dl
f01003f0:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003f3:	0f b6 d2             	movzbl %dl,%edx
f01003f6:	8a 82 00 53 10 f0    	mov    -0xfefad00(%edx),%al
f01003fc:	83 c8 40             	or     $0x40,%eax
f01003ff:	0f b6 c0             	movzbl %al,%eax
f0100402:	f7 d0                	not    %eax
f0100404:	21 c1                	and    %eax,%ecx
f0100406:	89 0d e8 e4 20 f0    	mov    %ecx,0xf020e4e8
		return 0;
f010040c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100411:	e9 8c 00 00 00       	jmp    f01004a2 <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f0100416:	8b 0d e8 e4 20 f0    	mov    0xf020e4e8,%ecx
f010041c:	f6 c1 40             	test   $0x40,%cl
f010041f:	74 0e                	je     f010042f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100421:	88 c2                	mov    %al,%dl
f0100423:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100426:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100429:	89 0d e8 e4 20 f0    	mov    %ecx,0xf020e4e8
	}

	shift |= shiftcode[data];
f010042f:	0f b6 d2             	movzbl %dl,%edx
f0100432:	0f b6 82 00 53 10 f0 	movzbl -0xfefad00(%edx),%eax
f0100439:	0b 05 e8 e4 20 f0    	or     0xf020e4e8,%eax
	shift ^= togglecode[data];
f010043f:	0f b6 8a 00 54 10 f0 	movzbl -0xfefac00(%edx),%ecx
f0100446:	31 c8                	xor    %ecx,%eax
f0100448:	a3 e8 e4 20 f0       	mov    %eax,0xf020e4e8

	c = charcode[shift & (CTL | SHIFT)][data];
f010044d:	89 c1                	mov    %eax,%ecx
f010044f:	83 e1 03             	and    $0x3,%ecx
f0100452:	8b 0c 8d 00 55 10 f0 	mov    -0xfefab00(,%ecx,4),%ecx
f0100459:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010045d:	a8 08                	test   $0x8,%al
f010045f:	74 18                	je     f0100479 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100461:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100464:	83 fa 19             	cmp    $0x19,%edx
f0100467:	77 05                	ja     f010046e <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100469:	83 eb 20             	sub    $0x20,%ebx
f010046c:	eb 0b                	jmp    f0100479 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f010046e:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100471:	83 fa 19             	cmp    $0x19,%edx
f0100474:	77 03                	ja     f0100479 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100476:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100479:	f7 d0                	not    %eax
f010047b:	a8 06                	test   $0x6,%al
f010047d:	75 23                	jne    f01004a2 <kbd_proc_data+0xf2>
f010047f:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100485:	75 1b                	jne    f01004a2 <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f0100487:	c7 04 24 c1 52 10 f0 	movl   $0xf01052c1,(%esp)
f010048e:	e8 fd 32 00 00       	call   f0103790 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100493:	ba 92 00 00 00       	mov    $0x92,%edx
f0100498:	b0 03                	mov    $0x3,%al
f010049a:	ee                   	out    %al,(%dx)
f010049b:	eb 05                	jmp    f01004a2 <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010049d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004a2:	89 d8                	mov    %ebx,%eax
f01004a4:	83 c4 14             	add    $0x14,%esp
f01004a7:	5b                   	pop    %ebx
f01004a8:	5d                   	pop    %ebp
f01004a9:	c3                   	ret    

f01004aa <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004aa:	55                   	push   %ebp
f01004ab:	89 e5                	mov    %esp,%ebp
f01004ad:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004b0:	83 3d c0 e2 20 f0 00 	cmpl   $0x0,0xf020e2c0
f01004b7:	74 0a                	je     f01004c3 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004b9:	b8 92 01 10 f0       	mov    $0xf0100192,%eax
f01004be:	e8 eb fc ff ff       	call   f01001ae <cons_intr>
}
f01004c3:	c9                   	leave  
f01004c4:	c3                   	ret    

f01004c5 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c5:	55                   	push   %ebp
f01004c6:	89 e5                	mov    %esp,%ebp
f01004c8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004cb:	b8 b0 03 10 f0       	mov    $0xf01003b0,%eax
f01004d0:	e8 d9 fc ff ff       	call   f01001ae <cons_intr>
}
f01004d5:	c9                   	leave  
f01004d6:	c3                   	ret    

f01004d7 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d7:	55                   	push   %ebp
f01004d8:	89 e5                	mov    %esp,%ebp
f01004da:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004dd:	e8 c8 ff ff ff       	call   f01004aa <serial_intr>
	kbd_intr();
f01004e2:	e8 de ff ff ff       	call   f01004c5 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e7:	8b 15 e0 e4 20 f0    	mov    0xf020e4e0,%edx
f01004ed:	3b 15 e4 e4 20 f0    	cmp    0xf020e4e4,%edx
f01004f3:	74 22                	je     f0100517 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004f5:	0f b6 82 e0 e2 20 f0 	movzbl -0xfdf1d20(%edx),%eax
f01004fc:	42                   	inc    %edx
f01004fd:	89 15 e0 e4 20 f0    	mov    %edx,0xf020e4e0
		if (cons.rpos == CONSBUFSIZE)
f0100503:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100509:	75 11                	jne    f010051c <cons_getc+0x45>
			cons.rpos = 0;
f010050b:	c7 05 e0 e4 20 f0 00 	movl   $0x0,0xf020e4e0
f0100512:	00 00 00 
f0100515:	eb 05                	jmp    f010051c <cons_getc+0x45>
		return c;
	}
	return 0;
f0100517:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010051c:	c9                   	leave  
f010051d:	c3                   	ret    

f010051e <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010051e:	55                   	push   %ebp
f010051f:	89 e5                	mov    %esp,%ebp
f0100521:	57                   	push   %edi
f0100522:	56                   	push   %esi
f0100523:	53                   	push   %ebx
f0100524:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100527:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010052e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100535:	5a a5 
	if (*cp != 0xA55A) {
f0100537:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010053d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100541:	74 11                	je     f0100554 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100543:	c7 05 ec e4 20 f0 b4 	movl   $0x3b4,0xf020e4ec
f010054a:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100552:	eb 16                	jmp    f010056a <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100554:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010055b:	c7 05 ec e4 20 f0 d4 	movl   $0x3d4,0xf020e4ec
f0100562:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100565:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010056a:	8b 0d ec e4 20 f0    	mov    0xf020e4ec,%ecx
f0100570:	b0 0e                	mov    $0xe,%al
f0100572:	89 ca                	mov    %ecx,%edx
f0100574:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100575:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100578:	89 da                	mov    %ebx,%edx
f010057a:	ec                   	in     (%dx),%al
f010057b:	0f b6 f8             	movzbl %al,%edi
f010057e:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100581:	b0 0f                	mov    $0xf,%al
f0100583:	89 ca                	mov    %ecx,%edx
f0100585:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100586:	89 da                	mov    %ebx,%edx
f0100588:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100589:	89 35 f0 e4 20 f0    	mov    %esi,0xf020e4f0
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010058f:	0f b6 d8             	movzbl %al,%ebx
f0100592:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100594:	66 89 3d f4 e4 20 f0 	mov    %di,0xf020e4f4
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059b:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005a0:	b0 00                	mov    $0x0,%al
f01005a2:	89 da                	mov    %ebx,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 fb                	mov    $0xfb,%dl
f01005a7:	b0 80                	mov    $0x80,%al
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005af:	b0 0c                	mov    $0xc,%al
f01005b1:	89 ca                	mov    %ecx,%edx
f01005b3:	ee                   	out    %al,(%dx)
f01005b4:	b2 f9                	mov    $0xf9,%dl
f01005b6:	b0 00                	mov    $0x0,%al
f01005b8:	ee                   	out    %al,(%dx)
f01005b9:	b2 fb                	mov    $0xfb,%dl
f01005bb:	b0 03                	mov    $0x3,%al
f01005bd:	ee                   	out    %al,(%dx)
f01005be:	b2 fc                	mov    $0xfc,%dl
f01005c0:	b0 00                	mov    $0x0,%al
f01005c2:	ee                   	out    %al,(%dx)
f01005c3:	b2 f9                	mov    $0xf9,%dl
f01005c5:	b0 01                	mov    $0x1,%al
f01005c7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c8:	b2 fd                	mov    $0xfd,%dl
f01005ca:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005cb:	3c ff                	cmp    $0xff,%al
f01005cd:	0f 95 c0             	setne  %al
f01005d0:	0f b6 c0             	movzbl %al,%eax
f01005d3:	89 c6                	mov    %eax,%esi
f01005d5:	a3 c0 e2 20 f0       	mov    %eax,0xf020e2c0
f01005da:	89 da                	mov    %ebx,%edx
f01005dc:	ec                   	in     (%dx),%al
f01005dd:	89 ca                	mov    %ecx,%edx
f01005df:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e0:	85 f6                	test   %esi,%esi
f01005e2:	75 0c                	jne    f01005f0 <cons_init+0xd2>
		cprintf("Serial port does not exist!\n");
f01005e4:	c7 04 24 cd 52 10 f0 	movl   $0xf01052cd,(%esp)
f01005eb:	e8 a0 31 00 00       	call   f0103790 <cprintf>
}
f01005f0:	83 c4 1c             	add    $0x1c,%esp
f01005f3:	5b                   	pop    %ebx
f01005f4:	5e                   	pop    %esi
f01005f5:	5f                   	pop    %edi
f01005f6:	5d                   	pop    %ebp
f01005f7:	c3                   	ret    

f01005f8 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f8:	55                   	push   %ebp
f01005f9:	89 e5                	mov    %esp,%ebp
f01005fb:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0100601:	e8 e9 fb ff ff       	call   f01001ef <cons_putc>
}
f0100606:	c9                   	leave  
f0100607:	c3                   	ret    

f0100608 <getchar>:

int
getchar(void)
{
f0100608:	55                   	push   %ebp
f0100609:	89 e5                	mov    %esp,%ebp
f010060b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010060e:	e8 c4 fe ff ff       	call   f01004d7 <cons_getc>
f0100613:	85 c0                	test   %eax,%eax
f0100615:	74 f7                	je     f010060e <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100617:	c9                   	leave  
f0100618:	c3                   	ret    

f0100619 <iscons>:

int
iscons(int fdnum)
{
f0100619:	55                   	push   %ebp
f010061a:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010061c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100621:	5d                   	pop    %ebp
f0100622:	c3                   	ret    
	...

f0100624 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100624:	55                   	push   %ebp
f0100625:	89 e5                	mov    %esp,%ebp
f0100627:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010062a:	c7 04 24 10 55 10 f0 	movl   $0xf0105510,(%esp)
f0100631:	e8 5a 31 00 00       	call   f0103790 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100636:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010063d:	00 
f010063e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100645:	f0 
f0100646:	c7 04 24 0c 56 10 f0 	movl   $0xf010560c,(%esp)
f010064d:	e8 3e 31 00 00       	call   f0103790 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100652:	c7 44 24 08 26 52 10 	movl   $0x105226,0x8(%esp)
f0100659:	00 
f010065a:	c7 44 24 04 26 52 10 	movl   $0xf0105226,0x4(%esp)
f0100661:	f0 
f0100662:	c7 04 24 30 56 10 f0 	movl   $0xf0105630,(%esp)
f0100669:	e8 22 31 00 00       	call   f0103790 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010066e:	c7 44 24 08 b3 e2 20 	movl   $0x20e2b3,0x8(%esp)
f0100675:	00 
f0100676:	c7 44 24 04 b3 e2 20 	movl   $0xf020e2b3,0x4(%esp)
f010067d:	f0 
f010067e:	c7 04 24 54 56 10 f0 	movl   $0xf0105654,(%esp)
f0100685:	e8 06 31 00 00       	call   f0103790 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010068a:	c7 44 24 08 b0 f1 20 	movl   $0x20f1b0,0x8(%esp)
f0100691:	00 
f0100692:	c7 44 24 04 b0 f1 20 	movl   $0xf020f1b0,0x4(%esp)
f0100699:	f0 
f010069a:	c7 04 24 78 56 10 f0 	movl   $0xf0105678,(%esp)
f01006a1:	e8 ea 30 00 00       	call   f0103790 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
f01006a6:	b8 af f5 20 f0       	mov    $0xf020f5af,%eax
f01006ab:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b0:	89 c2                	mov    %eax,%edx
f01006b2:	85 c0                	test   %eax,%eax
f01006b4:	79 06                	jns    f01006bc <mon_kerninfo+0x98>
f01006b6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006bc:	c1 fa 0a             	sar    $0xa,%edx
f01006bf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006c3:	c7 04 24 9c 56 10 f0 	movl   $0xf010569c,(%esp)
f01006ca:	e8 c1 30 00 00       	call   f0103790 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01006cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d4:	c9                   	leave  
f01006d5:	c3                   	ret    

f01006d6 <mon_help>:
}


int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006d6:	55                   	push   %ebp
f01006d7:	89 e5                	mov    %esp,%ebp
f01006d9:	53                   	push   %ebx
f01006da:	83 ec 14             	sub    $0x14,%esp
f01006dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006e2:	8b 83 e4 57 10 f0    	mov    -0xfefa81c(%ebx),%eax
f01006e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006ec:	8b 83 e0 57 10 f0    	mov    -0xfefa820(%ebx),%eax
f01006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006f6:	c7 04 24 29 55 10 f0 	movl   $0xf0105529,(%esp)
f01006fd:	e8 8e 30 00 00       	call   f0103790 <cprintf>
f0100702:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100705:	83 fb 3c             	cmp    $0x3c,%ebx
f0100708:	75 d8                	jne    f01006e2 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010070a:	b8 00 00 00 00       	mov    $0x0,%eax
f010070f:	83 c4 14             	add    $0x14,%esp
f0100712:	5b                   	pop    %ebx
f0100713:	5d                   	pop    %ebp
f0100714:	c3                   	ret    

f0100715 <mon_c>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

//my lab3 code 
int mon_c(int argc, char **argv, struct Trapframe *tf){
f0100715:	55                   	push   %ebp
f0100716:	89 e5                	mov    %esp,%ebp
f0100718:	83 ec 18             	sub    $0x18,%esp
f010071b:	8b 45 10             	mov    0x10(%ebp),%eax
	if(tf){
f010071e:	85 c0                	test   %eax,%eax
f0100720:	74 0e                	je     f0100730 <mon_c+0x1b>
	  tf->tf_eflags &= ~FL_TF;
f0100722:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	  return -1;
f0100729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010072e:	eb 11                	jmp    f0100741 <mon_c+0x2c>
	}
	cprintf("not support continue in non-gdb mode\n");
f0100730:	c7 04 24 c8 56 10 f0 	movl   $0xf01056c8,(%esp)
f0100737:	e8 54 30 00 00       	call   f0103790 <cprintf>
	return 0;
f010073c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <mon_x>:
	}
	cprintf("not support stepi in non-gdb mode\n");
	return 0;
}

int mon_x(int argc, char **argv, struct Trapframe *tf){
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 18             	sub    $0x18,%esp
	if(tf){
f0100749:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010074d:	74 46                	je     f0100795 <mon_x+0x52>
		if(argc != 2){
f010074f:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100753:	74 0e                	je     f0100763 <mon_x+0x20>
			cprintf("Please enter the address");
f0100755:	c7 04 24 32 55 10 f0 	movl   $0xf0105532,(%esp)
f010075c:	e8 2f 30 00 00       	call   f0103790 <cprintf>
			return 0;
f0100761:	eb 3e                	jmp    f01007a1 <mon_x+0x5e>
		}
		uintptr_t examine_address = (uintptr_t)strtol(argv[1], NULL, 16);
f0100763:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010076a:	00 
f010076b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100772:	00 
f0100773:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100776:	8b 40 04             	mov    0x4(%eax),%eax
f0100779:	89 04 24             	mov    %eax,(%esp)
f010077c:	e8 8c 47 00 00       	call   f0104f0d <strtol>
		uint32_t examine_value;
		__asm __volatile("movl (%0), %0" : "=r" (examine_value) : "r" (examine_address));
f0100781:	8b 00                	mov    (%eax),%eax
		cprintf("%d\n", examine_value);
f0100783:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100787:	c7 04 24 f6 65 10 f0 	movl   $0xf01065f6,(%esp)
f010078e:	e8 fd 2f 00 00       	call   f0103790 <cprintf>
		return 0;
f0100793:	eb 0c                	jmp    f01007a1 <mon_x+0x5e>
	}
	cprintf("not support stepi in non_gdb mode\n");
f0100795:	c7 04 24 f0 56 10 f0 	movl   $0xf01056f0,(%esp)
f010079c:	e8 ef 2f 00 00       	call   f0103790 <cprintf>
	return 0;
}
f01007a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a6:	c9                   	leave  
f01007a7:	c3                   	ret    

f01007a8 <mon_si>:
	}
	cprintf("not support continue in non-gdb mode\n");
	return 0;
}

int mon_si(int argc, char **argv, struct Trapframe *tf){
f01007a8:	55                   	push   %ebp
f01007a9:	89 e5                	mov    %esp,%ebp
f01007ab:	53                   	push   %ebx
f01007ac:	83 ec 44             	sub    $0x44,%esp
f01007af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(tf){
f01007b2:	85 db                	test   %ebx,%ebx
f01007b4:	74 58                	je     f010080e <mon_si+0x66>
		tf->tf_eflags |= FL_TF;
f01007b6:	81 4b 38 00 01 00 00 	orl    $0x100,0x38(%ebx)
		struct Eipdebuginfo info;
		debuginfo_eip((uintptr_t)tf->tf_eip, &info);
f01007bd:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c4:	8b 43 30             	mov    0x30(%ebx),%eax
f01007c7:	89 04 24             	mov    %eax,(%esp)
f01007ca:	e8 3a 3b 00 00       	call   f0104309 <debuginfo_eip>
					tf->tf_eip,
					info.eip_file,
					info.eip_line,
					info.eip_fn_namelen,
					info.eip_fn_name,
					tf->tf_eip-(uint32_t)info.eip_fn_addr
f01007cf:	8b 43 30             	mov    0x30(%ebx),%eax
	if(tf){
		tf->tf_eflags |= FL_TF;
		struct Eipdebuginfo info;
		debuginfo_eip((uintptr_t)tf->tf_eip, &info);
		// cprintf("cdz: the eip_line= %d\n", info.eip_line);
		cprintf("tf_eip=%08x\n%s:%u %.*s+%u\n",
f01007d2:	89 c2                	mov    %eax,%edx
f01007d4:	2b 55 f0             	sub    -0x10(%ebp),%edx
f01007d7:	89 54 24 18          	mov    %edx,0x18(%esp)
f01007db:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01007de:	89 54 24 14          	mov    %edx,0x14(%esp)
f01007e2:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01007e5:	89 54 24 10          	mov    %edx,0x10(%esp)
f01007e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01007ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01007f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01007f3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007fb:	c7 04 24 4b 55 10 f0 	movl   $0xf010554b,(%esp)
f0100802:	e8 89 2f 00 00       	call   f0103790 <cprintf>
					info.eip_line,
					info.eip_fn_namelen,
					info.eip_fn_name,
					tf->tf_eip-(uint32_t)info.eip_fn_addr
					);
		return -1;
f0100807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010080c:	eb 11                	jmp    f010081f <mon_si+0x77>
	}
	cprintf("not support stepi in non-gdb mode\n");
f010080e:	c7 04 24 14 57 10 f0 	movl   $0xf0105714,(%esp)
f0100815:	e8 76 2f 00 00       	call   f0103790 <cprintf>
	return 0;
f010081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010081f:	83 c4 44             	add    $0x44,%esp
f0100822:	5b                   	pop    %ebx
f0100823:	5d                   	pop    %ebp
f0100824:	c3                   	ret    

f0100825 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100825:	55                   	push   %ebp
f0100826:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100828:	b8 00 00 00 00       	mov    $0x0,%eax
f010082d:	5d                   	pop    %ebp
f010082e:	c3                   	ret    

f010082f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010082f:	55                   	push   %ebp
f0100830:	89 e5                	mov    %esp,%ebp
f0100832:	57                   	push   %edi
f0100833:	56                   	push   %esi
f0100834:	53                   	push   %ebx
f0100835:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100838:	c7 04 24 38 57 10 f0 	movl   $0xf0105738,(%esp)
f010083f:	e8 4c 2f 00 00       	call   f0103790 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100844:	c7 04 24 5c 57 10 f0 	movl   $0xf010575c,(%esp)
f010084b:	e8 40 2f 00 00       	call   f0103790 <cprintf>

	if (tf != NULL)
f0100850:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100854:	74 0b                	je     f0100861 <monitor+0x32>
		print_trapframe(tf);
f0100856:	8b 45 08             	mov    0x8(%ebp),%eax
f0100859:	89 04 24             	mov    %eax,(%esp)
f010085c:	e8 bc 33 00 00       	call   f0103c1d <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100861:	c7 04 24 66 55 10 f0 	movl   $0xf0105566,(%esp)
f0100868:	e8 bb 42 00 00       	call   f0104b28 <readline>
f010086d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010086f:	85 c0                	test   %eax,%eax
f0100871:	74 ee                	je     f0100861 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100873:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010087a:	be 00 00 00 00       	mov    $0x0,%esi
f010087f:	eb 04                	jmp    f0100885 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100881:	c6 03 00             	movb   $0x0,(%ebx)
f0100884:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100885:	8a 03                	mov    (%ebx),%al
f0100887:	84 c0                	test   %al,%al
f0100889:	74 64                	je     f01008ef <monitor+0xc0>
f010088b:	0f be c0             	movsbl %al,%eax
f010088e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100892:	c7 04 24 6a 55 10 f0 	movl   $0xf010556a,(%esp)
f0100899:	e8 d8 44 00 00       	call   f0104d76 <strchr>
f010089e:	85 c0                	test   %eax,%eax
f01008a0:	75 df                	jne    f0100881 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01008a2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a5:	74 48                	je     f01008ef <monitor+0xc0>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008a7:	83 fe 0f             	cmp    $0xf,%esi
f01008aa:	75 16                	jne    f01008c2 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ac:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008b3:	00 
f01008b4:	c7 04 24 6f 55 10 f0 	movl   $0xf010556f,(%esp)
f01008bb:	e8 d0 2e 00 00       	call   f0103790 <cprintf>
f01008c0:	eb 9f                	jmp    f0100861 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01008c2:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008c6:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008c7:	8a 03                	mov    (%ebx),%al
f01008c9:	84 c0                	test   %al,%al
f01008cb:	75 09                	jne    f01008d6 <monitor+0xa7>
f01008cd:	eb b6                	jmp    f0100885 <monitor+0x56>
			buf++;
f01008cf:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008d0:	8a 03                	mov    (%ebx),%al
f01008d2:	84 c0                	test   %al,%al
f01008d4:	74 af                	je     f0100885 <monitor+0x56>
f01008d6:	0f be c0             	movsbl %al,%eax
f01008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008dd:	c7 04 24 6a 55 10 f0 	movl   $0xf010556a,(%esp)
f01008e4:	e8 8d 44 00 00       	call   f0104d76 <strchr>
f01008e9:	85 c0                	test   %eax,%eax
f01008eb:	74 e2                	je     f01008cf <monitor+0xa0>
f01008ed:	eb 96                	jmp    f0100885 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f01008ef:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008f6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008f7:	85 f6                	test   %esi,%esi
f01008f9:	0f 84 62 ff ff ff    	je     f0100861 <monitor+0x32>
f01008ff:	bb e0 57 10 f0       	mov    $0xf01057e0,%ebx
f0100904:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100909:	8b 03                	mov    (%ebx),%eax
f010090b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100912:	89 04 24             	mov    %eax,(%esp)
f0100915:	e8 ed 43 00 00       	call   f0104d07 <strcmp>
f010091a:	85 c0                	test   %eax,%eax
f010091c:	75 24                	jne    f0100942 <monitor+0x113>
			return commands[i].func(argc, argv, tf);
f010091e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100921:	8b 55 08             	mov    0x8(%ebp),%edx
f0100924:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100928:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010092b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010092f:	89 34 24             	mov    %esi,(%esp)
f0100932:	ff 14 85 e8 57 10 f0 	call   *-0xfefa818(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100939:	85 c0                	test   %eax,%eax
f010093b:	78 26                	js     f0100963 <monitor+0x134>
f010093d:	e9 1f ff ff ff       	jmp    f0100861 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100942:	47                   	inc    %edi
f0100943:	83 c3 0c             	add    $0xc,%ebx
f0100946:	83 ff 05             	cmp    $0x5,%edi
f0100949:	75 be                	jne    f0100909 <monitor+0xda>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010094b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010094e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100952:	c7 04 24 8c 55 10 f0 	movl   $0xf010558c,(%esp)
f0100959:	e8 32 2e 00 00       	call   f0103790 <cprintf>
f010095e:	e9 fe fe ff ff       	jmp    f0100861 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100963:	83 c4 5c             	add    $0x5c,%esp
f0100966:	5b                   	pop    %ebx
f0100967:	5e                   	pop    %esi
f0100968:	5f                   	pop    %edi
f0100969:	5d                   	pop    %ebp
f010096a:	c3                   	ret    

f010096b <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010096b:	55                   	push   %ebp
f010096c:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010096e:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100971:	5d                   	pop    %ebp
f0100972:	c3                   	ret    
	...

f0100974 <check_va2pa_large>:
	return PTE_ADDR(p[PTX(va)]);
}

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
f0100974:	55                   	push   %ebp
f0100975:	89 e5                	mov    %esp,%ebp
	pgdir = &pgdir[PDX(va)];
f0100977:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f010097a:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010097d:	89 c2                	mov    %eax,%edx
f010097f:	81 e2 81 00 00 00    	and    $0x81,%edx
f0100985:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f010098b:	75 07                	jne    f0100994 <check_va2pa_large+0x20>
		return ~0;
	return PTE_ADDR(*pgdir);
f010098d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100992:	eb 05                	jmp    f0100999 <check_va2pa_large+0x25>
static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
		return ~0;
f0100994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(*pgdir);
}
f0100999:	5d                   	pop    %ebp
f010099a:	c3                   	ret    

f010099b <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010099b:	55                   	push   %ebp
f010099c:	89 e5                	mov    %esp,%ebp
f010099e:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009a1:	89 d1                	mov    %edx,%ecx
f01009a3:	c1 e9 16             	shr    $0x16,%ecx

	// cprintf("pgdir=%x \n", pgdir);
	if (!(*pgdir & PTE_P))
f01009a6:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009a9:	a8 01                	test   $0x1,%al
f01009ab:	74 4d                	je     f01009fa <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009b2:	89 c1                	mov    %eax,%ecx
f01009b4:	c1 e9 0c             	shr    $0xc,%ecx
f01009b7:	3b 0d a4 f1 20 f0    	cmp    0xf020f1a4,%ecx
f01009bd:	72 20                	jb     f01009df <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009c3:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01009ca:	f0 
f01009cb:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f01009d2:	00 
f01009d3:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01009da:	e8 fe f6 ff ff       	call   f01000dd <_panic>
	if (!(p[PTX(va)] & PTE_P)){
f01009df:	c1 ea 0c             	shr    $0xc,%edx
f01009e2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009e8:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009ef:	a8 01                	test   $0x1,%al
f01009f1:	74 0e                	je     f0100a01 <check_va2pa+0x66>
		return ~0;
	}
	// cprintf("the addr: %x\n", PTE_ADDR(p[PTX(va)]));
	return PTE_ADDR(p[PTX(va)]);
f01009f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009f8:	eb 0c                	jmp    f0100a06 <check_va2pa+0x6b>

	pgdir = &pgdir[PDX(va)];

	// cprintf("pgdir=%x \n", pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f01009fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009ff:	eb 05                	jmp    f0100a06 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P)){
		return ~0;
f0100a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	}
	// cprintf("the addr: %x\n", PTE_ADDR(p[PTX(va)]));
	return PTE_ADDR(p[PTX(va)]);
}
f0100a06:	c9                   	leave  
f0100a07:	c3                   	ret    

f0100a08 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a08:	55                   	push   %ebp
f0100a09:	89 e5                	mov    %esp,%ebp
f0100a0b:	56                   	push   %esi
f0100a0c:	53                   	push   %ebx
f0100a0d:	83 ec 10             	sub    $0x10,%esp
f0100a10:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a12:	89 04 24             	mov    %eax,(%esp)
f0100a15:	e8 fe 2c 00 00       	call   f0103718 <mc146818_read>
f0100a1a:	89 c6                	mov    %eax,%esi
f0100a1c:	43                   	inc    %ebx
f0100a1d:	89 1c 24             	mov    %ebx,(%esp)
f0100a20:	e8 f3 2c 00 00       	call   f0103718 <mc146818_read>
f0100a25:	c1 e0 08             	shl    $0x8,%eax
f0100a28:	09 f0                	or     %esi,%eax
}
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	5b                   	pop    %ebx
f0100a2e:	5e                   	pop    %esi
f0100a2f:	5d                   	pop    %ebp
f0100a30:	c3                   	ret    

f0100a31 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a31:	55                   	push   %ebp
f0100a32:	89 e5                	mov    %esp,%ebp
f0100a34:	56                   	push   %esi
f0100a35:	53                   	push   %ebx
f0100a36:	83 ec 10             	sub    $0x10,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a39:	83 3d fc e4 20 f0 00 	cmpl   $0x0,0xf020e4fc
f0100a40:	75 11                	jne    f0100a53 <boot_alloc+0x22>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a42:	ba af 01 21 f0       	mov    $0xf02101af,%edx
f0100a47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a4d:	89 15 fc e4 20 f0    	mov    %edx,0xf020e4fc
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	result = KADDR(PADDR(nextfree));
f0100a53:	8b 15 fc e4 20 f0    	mov    0xf020e4fc,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100a59:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100a5f:	77 20                	ja     f0100a81 <boot_alloc+0x50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100a61:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100a65:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0100a6c:	f0 
f0100a6d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
f0100a74:	00 
f0100a75:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100a7c:	e8 5c f6 ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100a81:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a87:	8b 0d a4 f1 20 f0    	mov    0xf020f1a4,%ecx
f0100a8d:	89 de                	mov    %ebx,%esi
f0100a8f:	c1 ee 0c             	shr    $0xc,%esi
f0100a92:	39 ce                	cmp    %ecx,%esi
f0100a94:	72 20                	jb     f0100ab6 <boot_alloc+0x85>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a96:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a9a:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0100aa1:	f0 
f0100aa2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
f0100aa9:	00 
f0100aaa:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100ab1:	e8 27 f6 ff ff       	call   f01000dd <_panic>
	if(n>0){
f0100ab6:	85 c0                	test   %eax,%eax
f0100ab8:	74 6c                	je     f0100b26 <boot_alloc+0xf5>
		nextfree += n;
f0100aba:	01 d0                	add    %edx,%eax
f0100abc:	a3 fc e4 20 f0       	mov    %eax,0xf020e4fc
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ac1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ac6:	77 20                	ja     f0100ae8 <boot_alloc+0xb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ac8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100acc:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0100ad3:	f0 
f0100ad4:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100adb:	00 
f0100adc:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100ae3:	e8 f5 f5 ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ae8:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aee:	89 de                	mov    %ebx,%esi
f0100af0:	c1 ee 0c             	shr    $0xc,%esi
f0100af3:	39 f1                	cmp    %esi,%ecx
f0100af5:	77 20                	ja     f0100b17 <boot_alloc+0xe6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100af7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100afb:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0100b02:	f0 
f0100b03:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100b0a:	00 
f0100b0b:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100b12:	e8 c6 f5 ff ff       	call   f01000dd <_panic>

		// PADDR will check if VA >= KERNBASE
		// KADDR will check if PA < npages*PGSIZE
		KADDR(PADDR(nextfree));
		nextfree = ROUNDUP(nextfree, PGSIZE);
f0100b17:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b21:	a3 fc e4 20 f0       	mov    %eax,0xf020e4fc
	}

	return result;
}
f0100b26:	89 d0                	mov    %edx,%eax
f0100b28:	83 c4 10             	add    $0x10,%esp
f0100b2b:	5b                   	pop    %ebx
f0100b2c:	5e                   	pop    %esi
f0100b2d:	5d                   	pop    %ebp
f0100b2e:	c3                   	ret    

f0100b2f <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b2f:	55                   	push   %ebp
f0100b30:	89 e5                	mov    %esp,%ebp
f0100b32:	57                   	push   %edi
f0100b33:	56                   	push   %esi
f0100b34:	53                   	push   %ebx
f0100b35:	83 ec 3c             	sub    $0x3c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b38:	83 f8 01             	cmp    $0x1,%eax
f0100b3b:	19 f6                	sbb    %esi,%esi
f0100b3d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b43:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b44:	8b 1d 00 e5 20 f0    	mov    0xf020e500,%ebx
f0100b4a:	85 db                	test   %ebx,%ebx
f0100b4c:	75 1c                	jne    f0100b6a <check_page_free_list+0x3b>
		panic("'page_free_list' is a null pointer!");
f0100b4e:	c7 44 24 08 64 58 10 	movl   $0xf0105864,0x8(%esp)
f0100b55:	f0 
f0100b56:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0100b5d:	00 
f0100b5e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100b65:	e8 73 f5 ff ff       	call   f01000dd <_panic>

	if (only_low_memory) {
f0100b6a:	85 c0                	test   %eax,%eax
f0100b6c:	74 50                	je     f0100bbe <check_page_free_list+0x8f>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100b6e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100b71:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100b77:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b7a:	89 d8                	mov    %ebx,%eax
f0100b7c:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0100b82:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b85:	c1 e8 16             	shr    $0x16,%eax
f0100b88:	39 f0                	cmp    %esi,%eax
f0100b8a:	0f 93 c0             	setae  %al
f0100b8d:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100b90:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100b94:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100b96:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b9a:	8b 1b                	mov    (%ebx),%ebx
f0100b9c:	85 db                	test   %ebx,%ebx
f0100b9e:	75 da                	jne    f0100b7a <check_page_free_list+0x4b>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ba0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ba3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ba9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100baf:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bb1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100bb4:	89 1d 00 e5 20 f0    	mov    %ebx,0xf020e500
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100bba:	85 db                	test   %ebx,%ebx
f0100bbc:	74 67                	je     f0100c25 <check_page_free_list+0xf6>
f0100bbe:	89 d8                	mov    %ebx,%eax
f0100bc0:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0100bc6:	c1 f8 03             	sar    $0x3,%eax
f0100bc9:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bcc:	89 c2                	mov    %eax,%edx
f0100bce:	c1 ea 16             	shr    $0x16,%edx
f0100bd1:	39 f2                	cmp    %esi,%edx
f0100bd3:	73 4a                	jae    f0100c1f <check_page_free_list+0xf0>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bd5:	89 c2                	mov    %eax,%edx
f0100bd7:	c1 ea 0c             	shr    $0xc,%edx
f0100bda:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f0100be0:	72 20                	jb     f0100c02 <check_page_free_list+0xd3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100be6:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0100bed:	f0 
f0100bee:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100bf5:	00 
f0100bf6:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0100bfd:	e8 db f4 ff ff       	call   f01000dd <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c02:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c09:	00 
f0100c0a:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c11:	00 
	return (void *)(pa + KERNBASE);
f0100c12:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c17:	89 04 24             	mov    %eax,(%esp)
f0100c1a:	e8 a8 41 00 00       	call   f0104dc7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100c1f:	8b 1b                	mov    (%ebx),%ebx
f0100c21:	85 db                	test   %ebx,%ebx
f0100c23:	75 99                	jne    f0100bbe <check_page_free_list+0x8f>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100c25:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2a:	e8 02 fe ff ff       	call   f0100a31 <boot_alloc>
f0100c2f:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c32:	8b 15 00 e5 20 f0    	mov    0xf020e500,%edx
f0100c38:	85 d2                	test   %edx,%edx
f0100c3a:	0f 84 ee 01 00 00    	je     f0100e2e <check_page_free_list+0x2ff>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c40:	8b 1d ac f1 20 f0    	mov    0xf020f1ac,%ebx
f0100c46:	39 da                	cmp    %ebx,%edx
f0100c48:	72 4b                	jb     f0100c95 <check_page_free_list+0x166>
		assert(pp < pages + npages);
f0100c4a:	a1 a4 f1 20 f0       	mov    0xf020f1a4,%eax
f0100c4f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c52:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100c55:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100c58:	39 c2                	cmp    %eax,%edx
f0100c5a:	73 62                	jae    f0100cbe <check_page_free_list+0x18f>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c5c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100c5f:	89 d0                	mov    %edx,%eax
f0100c61:	29 d8                	sub    %ebx,%eax
f0100c63:	a8 07                	test   $0x7,%al
f0100c65:	0f 85 80 00 00 00    	jne    f0100ceb <check_page_free_list+0x1bc>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c6b:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c6e:	c1 e0 0c             	shl    $0xc,%eax
f0100c71:	0f 84 a0 00 00 00    	je     f0100d17 <check_page_free_list+0x1e8>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c77:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c7c:	0f 84 c0 00 00 00    	je     f0100d42 <check_page_free_list+0x213>
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c82:	be 00 00 00 00       	mov    $0x0,%esi
f0100c87:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c8c:	e9 d5 00 00 00       	jmp    f0100d66 <check_page_free_list+0x237>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c91:	39 da                	cmp    %ebx,%edx
f0100c93:	73 24                	jae    f0100cb9 <check_page_free_list+0x18a>
f0100c95:	c7 44 24 0c b3 5f 10 	movl   $0xf0105fb3,0xc(%esp)
f0100c9c:	f0 
f0100c9d:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100ca4:	f0 
f0100ca5:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0100cac:	00 
f0100cad:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100cb4:	e8 24 f4 ff ff       	call   f01000dd <_panic>
		assert(pp < pages + npages);
f0100cb9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cbc:	72 24                	jb     f0100ce2 <check_page_free_list+0x1b3>
f0100cbe:	c7 44 24 0c d4 5f 10 	movl   $0xf0105fd4,0xc(%esp)
f0100cc5:	f0 
f0100cc6:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100ccd:	f0 
f0100cce:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0100cd5:	00 
f0100cd6:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100cdd:	e8 fb f3 ff ff       	call   f01000dd <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce2:	89 d0                	mov    %edx,%eax
f0100ce4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ce7:	a8 07                	test   $0x7,%al
f0100ce9:	74 24                	je     f0100d0f <check_page_free_list+0x1e0>
f0100ceb:	c7 44 24 0c 88 58 10 	movl   $0xf0105888,0xc(%esp)
f0100cf2:	f0 
f0100cf3:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100cfa:	f0 
f0100cfb:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0100d02:	00 
f0100d03:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100d0a:	e8 ce f3 ff ff       	call   f01000dd <_panic>
f0100d0f:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d12:	c1 e0 0c             	shl    $0xc,%eax
f0100d15:	75 24                	jne    f0100d3b <check_page_free_list+0x20c>
f0100d17:	c7 44 24 0c e8 5f 10 	movl   $0xf0105fe8,0xc(%esp)
f0100d1e:	f0 
f0100d1f:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100d26:	f0 
f0100d27:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0100d2e:	00 
f0100d2f:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100d36:	e8 a2 f3 ff ff       	call   f01000dd <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d3b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d40:	75 24                	jne    f0100d66 <check_page_free_list+0x237>
f0100d42:	c7 44 24 0c f9 5f 10 	movl   $0xf0105ff9,0xc(%esp)
f0100d49:	f0 
f0100d4a:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100d51:	f0 
f0100d52:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0100d59:	00 
f0100d5a:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100d61:	e8 77 f3 ff ff       	call   f01000dd <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d66:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d6b:	75 24                	jne    f0100d91 <check_page_free_list+0x262>
f0100d6d:	c7 44 24 0c bc 58 10 	movl   $0xf01058bc,0xc(%esp)
f0100d74:	f0 
f0100d75:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100d7c:	f0 
f0100d7d:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0100d84:	00 
f0100d85:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100d8c:	e8 4c f3 ff ff       	call   f01000dd <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d91:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d96:	75 24                	jne    f0100dbc <check_page_free_list+0x28d>
f0100d98:	c7 44 24 0c 12 60 10 	movl   $0xf0106012,0xc(%esp)
f0100d9f:	f0 
f0100da0:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100da7:	f0 
f0100da8:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100daf:	00 
f0100db0:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100db7:	e8 21 f3 ff ff       	call   f01000dd <_panic>
f0100dbc:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dbe:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc3:	76 57                	jbe    f0100e1c <check_page_free_list+0x2ed>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc5:	c1 e8 0c             	shr    $0xc,%eax
f0100dc8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100dcb:	77 20                	ja     f0100ded <check_page_free_list+0x2be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dcd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100dd1:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0100dd8:	f0 
f0100dd9:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100de0:	00 
f0100de1:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0100de8:	e8 f0 f2 ff ff       	call   f01000dd <_panic>
	return (void *)(pa + KERNBASE);
f0100ded:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100df3:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100df6:	76 27                	jbe    f0100e1f <check_page_free_list+0x2f0>
f0100df8:	c7 44 24 0c e0 58 10 	movl   $0xf01058e0,0xc(%esp)
f0100dff:	f0 
f0100e00:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100e07:	f0 
f0100e08:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100e0f:	00 
f0100e10:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100e17:	e8 c1 f2 ff ff       	call   f01000dd <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e1c:	47                   	inc    %edi
f0100e1d:	eb 01                	jmp    f0100e20 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0100e1f:	46                   	inc    %esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e20:	8b 12                	mov    (%edx),%edx
f0100e22:	85 d2                	test   %edx,%edx
f0100e24:	0f 85 67 fe ff ff    	jne    f0100c91 <check_page_free_list+0x162>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e2a:	85 ff                	test   %edi,%edi
f0100e2c:	7f 24                	jg     f0100e52 <check_page_free_list+0x323>
f0100e2e:	c7 44 24 0c 2c 60 10 	movl   $0xf010602c,0xc(%esp)
f0100e35:	f0 
f0100e36:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100e3d:	f0 
f0100e3e:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100e45:	00 
f0100e46:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100e4d:	e8 8b f2 ff ff       	call   f01000dd <_panic>
	assert(nfree_extmem > 0);
f0100e52:	85 f6                	test   %esi,%esi
f0100e54:	7f 24                	jg     f0100e7a <check_page_free_list+0x34b>
f0100e56:	c7 44 24 0c 3e 60 10 	movl   $0xf010603e,0xc(%esp)
f0100e5d:	f0 
f0100e5e:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0100e65:	f0 
f0100e66:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0100e6d:	00 
f0100e6e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100e75:	e8 63 f2 ff ff       	call   f01000dd <_panic>
}
f0100e7a:	83 c4 3c             	add    $0x3c,%esp
f0100e7d:	5b                   	pop    %ebx
f0100e7e:	5e                   	pop    %esi
f0100e7f:	5f                   	pop    %edi
f0100e80:	5d                   	pop    %ebp
f0100e81:	c3                   	ret    

f0100e82 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e82:	55                   	push   %ebp
f0100e83:	89 e5                	mov    %esp,%ebp
f0100e85:	56                   	push   %esi
f0100e86:	53                   	push   %ebx
f0100e87:	83 ec 10             	sub    $0x10,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
	size_t i;
	for(i=1; i<npages_basemem; i++){
f0100e8a:	8b 35 f8 e4 20 f0    	mov    0xf020e4f8,%esi
f0100e90:	83 fe 01             	cmp    $0x1,%esi
f0100e93:	76 35                	jbe    f0100eca <page_init+0x48>
f0100e95:	8b 1d 00 e5 20 f0    	mov    0xf020e500,%ebx
f0100e9b:	b8 01 00 00 00       	mov    $0x1,%eax
		pages[i].pp_ref = 0;
f0100ea0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ea7:	89 d1                	mov    %edx,%ecx
f0100ea9:	03 0d ac f1 20 f0    	add    0xf020f1ac,%ecx
f0100eaf:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100eb5:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100eb7:	89 d3                	mov    %edx,%ebx
f0100eb9:	03 1d ac f1 20 f0    	add    0xf020f1ac,%ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
	size_t i;
	for(i=1; i<npages_basemem; i++){
f0100ebf:	40                   	inc    %eax
f0100ec0:	39 c6                	cmp    %eax,%esi
f0100ec2:	77 dc                	ja     f0100ea0 <page_init+0x1e>
f0100ec4:	89 1d 00 e5 20 f0    	mov    %ebx,0xf020e500
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	
	for(i=PGNUM(PADDR(boot_alloc(0))); i<npages; i++){
f0100eca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ecf:	e8 5d fb ff ff       	call   f0100a31 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ed4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ed9:	77 20                	ja     f0100efb <page_init+0x79>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100edf:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0100ee6:	f0 
f0100ee7:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f0100eee:	00 
f0100eef:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0100ef6:	e8 e2 f1 ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100efb:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f00:	c1 e8 0c             	shr    $0xc,%eax
f0100f03:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f0100f09:	73 37                	jae    f0100f42 <page_init+0xc0>
f0100f0b:	8b 1d 00 e5 20 f0    	mov    0xf020e500,%ebx
f0100f11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100f18:	89 d1                	mov    %edx,%ecx
f0100f1a:	03 0d ac f1 20 f0    	add    0xf020f1ac,%ecx
f0100f20:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f26:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f28:	89 d3                	mov    %edx,%ebx
f0100f2a:	03 1d ac f1 20 f0    	add    0xf020f1ac,%ebx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	
	for(i=PGNUM(PADDR(boot_alloc(0))); i<npages; i++){
f0100f30:	40                   	inc    %eax
f0100f31:	83 c2 08             	add    $0x8,%edx
f0100f34:	39 05 a4 f1 20 f0    	cmp    %eax,0xf020f1a4
f0100f3a:	77 dc                	ja     f0100f18 <page_init+0x96>
f0100f3c:	89 1d 00 e5 20 f0    	mov    %ebx,0xf020e500
	//for (i = 0; i < npages; i++) {
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	chunk_list = NULL;
f0100f42:	c7 05 04 e5 20 f0 00 	movl   $0x0,0xf020e504
f0100f49:	00 00 00 
}
f0100f4c:	83 c4 10             	add    $0x10,%esp
f0100f4f:	5b                   	pop    %ebx
f0100f50:	5e                   	pop    %esi
f0100f51:	5d                   	pop    %ebp
f0100f52:	c3                   	ret    

f0100f53 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0100f53:	55                   	push   %ebp
f0100f54:	89 e5                	mov    %esp,%ebp
f0100f56:	53                   	push   %ebx
f0100f57:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	
	struct Page * alloc_page = NULL;
	if(page_free_list){
f0100f5a:	8b 1d 00 e5 20 f0    	mov    0xf020e500,%ebx
f0100f60:	85 db                	test   %ebx,%ebx
f0100f62:	74 6b                	je     f0100fcf <page_alloc+0x7c>
		alloc_page = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100f64:	8b 03                	mov    (%ebx),%eax
f0100f66:	a3 00 e5 20 f0       	mov    %eax,0xf020e500
		//alloc_page.pp_ref = 0;
		alloc_page->pp_link = NULL;
f0100f6b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		if(alloc_flags &  ALLOC_ZERO){
f0100f71:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f75:	74 58                	je     f0100fcf <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f77:	89 d8                	mov    %ebx,%eax
f0100f79:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0100f7f:	c1 f8 03             	sar    $0x3,%eax
f0100f82:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f85:	89 c2                	mov    %eax,%edx
f0100f87:	c1 ea 0c             	shr    $0xc,%edx
f0100f8a:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f0100f90:	72 20                	jb     f0100fb2 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f96:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0100f9d:	f0 
f0100f9e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100fa5:	00 
f0100fa6:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0100fad:	e8 2b f1 ff ff       	call   f01000dd <_panic>
			memset(page2kva(alloc_page), 0, PGSIZE);
f0100fb2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fb9:	00 
f0100fba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fc1:	00 
	return (void *)(pa + KERNBASE);
f0100fc2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fc7:	89 04 24             	mov    %eax,(%esp)
f0100fca:	e8 f8 3d 00 00       	call   f0104dc7 <memset>
		}
	}
	return alloc_page;

}
f0100fcf:	89 d8                	mov    %ebx,%eax
f0100fd1:	83 c4 14             	add    $0x14,%esp
f0100fd4:	5b                   	pop    %ebx
f0100fd5:	5d                   	pop    %ebp
f0100fd6:	c3                   	ret    

f0100fd7 <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f0100fd7:	55                   	push   %ebp
f0100fd8:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return NULL;
}
f0100fda:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fdf:	5d                   	pop    %ebp
f0100fe0:	c3                   	ret    

f0100fe1 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0100fe1:	55                   	push   %ebp
f0100fe2:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return -1;
}
f0100fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fe9:	5d                   	pop    %ebp
f0100fea:	c3                   	ret    

f0100feb <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100feb:	55                   	push   %ebp
f0100fec:	89 e5                	mov    %esp,%ebp
f0100fee:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(pp->pp_ref==0){	
f0100ff1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ff6:	75 13                	jne    f010100b <page_free+0x20>
		pp->pp_ref = 0;
f0100ff8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pp->pp_link = page_free_list;
f0100ffe:	8b 15 00 e5 20 f0    	mov    0xf020e500,%edx
f0101004:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0101006:	a3 00 e5 20 f0       	mov    %eax,0xf020e500
	}
}
f010100b:	5d                   	pop    %ebp
f010100c:	c3                   	ret    

f010100d <page_realloc_npages>:
// You can man realloc for better understanding.
// (Try to reuse the allocated pages as many as possible.)
//
struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f010100d:	55                   	push   %ebp
f010100e:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return NULL;
}
f0101010:	b8 00 00 00 00       	mov    $0x0,%eax
f0101015:	5d                   	pop    %ebp
f0101016:	c3                   	ret    

f0101017 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101017:	55                   	push   %ebp
f0101018:	89 e5                	mov    %esp,%ebp
f010101a:	83 ec 04             	sub    $0x4,%esp
f010101d:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101020:	8b 50 04             	mov    0x4(%eax),%edx
f0101023:	4a                   	dec    %edx
f0101024:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101028:	66 85 d2             	test   %dx,%dx
f010102b:	75 08                	jne    f0101035 <page_decref+0x1e>
		page_free(pp);
f010102d:	89 04 24             	mov    %eax,(%esp)
f0101030:	e8 b6 ff ff ff       	call   f0100feb <page_free>
}
f0101035:	c9                   	leave  
f0101036:	c3                   	ret    

f0101037 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101037:	55                   	push   %ebp
f0101038:	89 e5                	mov    %esp,%ebp
f010103a:	57                   	push   %edi
f010103b:	56                   	push   %esi
f010103c:	53                   	push   %ebx
f010103d:	83 ec 1c             	sub    $0x1c,%esp
f0101040:	8b 75 0c             	mov    0xc(%ebp),%esi
	//my note:
	//pgdir is a *virtual addr*;
	//the return of pgdir_walk is a *virtual addr* pointer to the sceondery page table entry;
	pde_t * pde;
	pte_t * pt;
	pde = pgdir + PDX(va);
f0101043:	89 f3                	mov    %esi,%ebx
f0101045:	c1 eb 16             	shr    $0x16,%ebx
f0101048:	c1 e3 02             	shl    $0x2,%ebx
f010104b:	03 5d 08             	add    0x8(%ebp),%ebx
	// cprintf("the pgdir is: %x, and the *pgdir is :%x\n", pgdir, *pgdir);
	// cprintf("the pde is: %x, and the *pde is :%x\n", pde, *pde);

	if((*pde) & PTE_P){
f010104e:	8b 03                	mov    (%ebx),%eax
f0101050:	a8 01                	test   $0x1,%al
f0101052:	74 3d                	je     f0101091 <pgdir_walk+0x5a>
	  pt = KADDR(PTE_ADDR(*pde));
f0101054:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101059:	89 c2                	mov    %eax,%edx
f010105b:	c1 ea 0c             	shr    $0xc,%edx
f010105e:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f0101064:	72 20                	jb     f0101086 <pgdir_walk+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101066:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010106a:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0101071:	f0 
f0101072:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f0101079:	00 
f010107a:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101081:	e8 57 f0 ff ff       	call   f01000dd <_panic>
	return (void *)(pa + KERNBASE);
f0101086:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f010108c:	e9 92 00 00 00       	jmp    f0101123 <pgdir_walk+0xec>
	}

	else{
		if(create){
f0101091:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101095:	0f 84 96 00 00 00    	je     f0101131 <pgdir_walk+0xfa>
			struct Page *pp = page_alloc(ALLOC_ZERO);
f010109b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010a2:	e8 ac fe ff ff       	call   f0100f53 <page_alloc>
			if(pp==NULL) return NULL;
f01010a7:	85 c0                	test   %eax,%eax
f01010a9:	0f 84 89 00 00 00    	je     f0101138 <pgdir_walk+0x101>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01010af:	89 c2                	mov    %eax,%edx
f01010b1:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f01010b7:	c1 fa 03             	sar    $0x3,%edx
f01010ba:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010bd:	89 d1                	mov    %edx,%ecx
f01010bf:	c1 e9 0c             	shr    $0xc,%ecx
f01010c2:	3b 0d a4 f1 20 f0    	cmp    0xf020f1a4,%ecx
f01010c8:	72 20                	jb     f01010ea <pgdir_walk+0xb3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01010ce:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01010d5:	f0 
f01010d6:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01010dd:	00 
f01010de:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f01010e5:	e8 f3 ef ff ff       	call   f01000dd <_panic>
	return (void *)(pa + KERNBASE);
f01010ea:	8d ba 00 00 00 f0    	lea    -0x10000000(%edx),%edi
f01010f0:	89 f9                	mov    %edi,%ecx
			pt = page2kva(pp);
			pp->pp_ref++;
f01010f2:	66 ff 40 04          	incw   0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010f6:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01010fc:	77 20                	ja     f010111e <pgdir_walk+0xe7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010fe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101102:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0101109:	f0 
f010110a:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f0101111:	00 
f0101112:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101119:	e8 bf ef ff ff       	call   f01000dd <_panic>
			*pde = PADDR(pt) | PTE_P | PTE_W | PTE_U;
f010111e:	83 ca 07             	or     $0x7,%edx
f0101121:	89 13                	mov    %edx,(%ebx)
		}
		else return NULL;
	}
	// cprintf("the pt is : %x, and the *pt is %x\n", pt, *pt);
	return pt+PTX(va);
f0101123:	c1 ee 0a             	shr    $0xa,%esi
f0101126:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010112c:	8d 04 31             	lea    (%ecx,%esi,1),%eax
f010112f:	eb 0c                	jmp    f010113d <pgdir_walk+0x106>
			if(pp==NULL) return NULL;
			pt = page2kva(pp);
			pp->pp_ref++;
			*pde = PADDR(pt) | PTE_P | PTE_W | PTE_U;
		}
		else return NULL;
f0101131:	b8 00 00 00 00       	mov    $0x0,%eax
f0101136:	eb 05                	jmp    f010113d <pgdir_walk+0x106>
	}

	else{
		if(create){
			struct Page *pp = page_alloc(ALLOC_ZERO);
			if(pp==NULL) return NULL;
f0101138:	b8 00 00 00 00       	mov    $0x0,%eax
		}
		else return NULL;
	}
	// cprintf("the pt is : %x, and the *pt is %x\n", pt, *pt);
	return pt+PTX(va);
}
f010113d:	83 c4 1c             	add    $0x1c,%esp
f0101140:	5b                   	pop    %ebx
f0101141:	5e                   	pop    %esi
f0101142:	5f                   	pop    %edi
f0101143:	5d                   	pop    %ebp
f0101144:	c3                   	ret    

f0101145 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101145:	55                   	push   %ebp
f0101146:	89 e5                	mov    %esp,%ebp
f0101148:	57                   	push   %edi
f0101149:	56                   	push   %esi
f010114a:	53                   	push   %ebx
f010114b:	83 ec 2c             	sub    $0x2c,%esp
f010114e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101151:	89 d3                	mov    %edx,%ebx
f0101153:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function in
	uint32_t n = size/PGSIZE;
	uint32_t i;
	pte_t * pte;
	for(i=0; i<n; i++){
f0101156:	c1 e9 0c             	shr    $0xc,%ecx
f0101159:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010115c:	74 3e                	je     f010119c <boot_map_region+0x57>
f010115e:	be 00 00 00 00       	mov    $0x0,%esi
		pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
f0101163:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101166:	83 c8 01             	or     $0x1,%eax
f0101169:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	uint32_t n = size/PGSIZE;
	uint32_t i;
	pte_t * pte;
	for(i=0; i<n; i++){
		pte = pgdir_walk(pgdir, (void *)va, 1);
f010116c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101173:	00 
f0101174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101178:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010117b:	89 04 24             	mov    %eax,(%esp)
f010117e:	e8 b4 fe ff ff       	call   f0101037 <pgdir_walk>
		*pte = pa | perm | PTE_P;
f0101183:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101186:	09 fa                	or     %edi,%edx
f0101188:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
f010118a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		pa += PGSIZE;
f0101190:	81 c7 00 10 00 00    	add    $0x1000,%edi
{
	// Fill this function in
	uint32_t n = size/PGSIZE;
	uint32_t i;
	pte_t * pte;
	for(i=0; i<n; i++){
f0101196:	46                   	inc    %esi
f0101197:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010119a:	75 d0                	jne    f010116c <boot_map_region+0x27>
		pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f010119c:	83 c4 2c             	add    $0x2c,%esp
f010119f:	5b                   	pop    %ebx
f01011a0:	5e                   	pop    %esi
f01011a1:	5f                   	pop    %edi
f01011a2:	5d                   	pop    %ebp
f01011a3:	c3                   	ret    

f01011a4 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011a4:	55                   	push   %ebp
f01011a5:	89 e5                	mov    %esp,%ebp
f01011a7:	53                   	push   %ebx
f01011a8:	83 ec 14             	sub    $0x14,%esp
f01011ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, 1);
f01011ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011b5:	00 
f01011b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01011c0:	89 04 24             	mov    %eax,(%esp)
f01011c3:	e8 6f fe ff ff       	call   f0101037 <pgdir_walk>
	if(pte_store){
f01011c8:	85 db                	test   %ebx,%ebx
f01011ca:	74 02                	je     f01011ce <page_lookup+0x2a>
		*pte_store = pte;
f01011cc:	89 03                	mov    %eax,(%ebx)
	}
	if((pte != NULL)&&(*pte & PTE_P))
f01011ce:	85 c0                	test   %eax,%eax
f01011d0:	74 38                	je     f010120a <page_lookup+0x66>
f01011d2:	8b 00                	mov    (%eax),%eax
f01011d4:	a8 01                	test   $0x1,%al
f01011d6:	74 39                	je     f0101211 <page_lookup+0x6d>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011d8:	c1 e8 0c             	shr    $0xc,%eax
f01011db:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f01011e1:	72 1c                	jb     f01011ff <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01011e3:	c7 44 24 08 28 59 10 	movl   $0xf0105928,0x8(%esp)
f01011ea:	f0 
f01011eb:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01011f2:	00 
f01011f3:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f01011fa:	e8 de ee ff ff       	call   f01000dd <_panic>
	return &pages[PGNUM(pa)];
f01011ff:	c1 e0 03             	shl    $0x3,%eax
f0101202:	03 05 ac f1 20 f0    	add    0xf020f1ac,%eax
	  return pa2page(PTE_ADDR(*pte));
f0101208:	eb 0c                	jmp    f0101216 <page_lookup+0x72>
	return NULL;
f010120a:	b8 00 00 00 00       	mov    $0x0,%eax
f010120f:	eb 05                	jmp    f0101216 <page_lookup+0x72>
f0101211:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101216:	83 c4 14             	add    $0x14,%esp
f0101219:	5b                   	pop    %ebx
f010121a:	5d                   	pop    %ebp
f010121b:	c3                   	ret    

f010121c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010121f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101222:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101225:	5d                   	pop    %ebp
f0101226:	c3                   	ret    

f0101227 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101227:	55                   	push   %ebp
f0101228:	89 e5                	mov    %esp,%ebp
f010122a:	56                   	push   %esi
f010122b:	53                   	push   %ebx
f010122c:	83 ec 20             	sub    $0x20,%esp
f010122f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * pte; //= pgdir_walk(pgdir, va, 1);
	struct Page * pp = page_lookup(pgdir, va, &pte);
f0101235:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101238:	89 44 24 08          	mov    %eax,0x8(%esp)
f010123c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101240:	89 34 24             	mov    %esi,(%esp)
f0101243:	e8 5c ff ff ff       	call   f01011a4 <page_lookup>

	if(pp != NULL){
f0101248:	85 c0                	test   %eax,%eax
f010124a:	74 1d                	je     f0101269 <page_remove+0x42>
		*pte = 0;
f010124c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010124f:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(pp);
f0101255:	89 04 24             	mov    %eax,(%esp)
f0101258:	e8 ba fd ff ff       	call   f0101017 <page_decref>
		tlb_invalidate(pgdir, va);
f010125d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101261:	89 34 24             	mov    %esi,(%esp)
f0101264:	e8 b3 ff ff ff       	call   f010121c <tlb_invalidate>
//	if(pp->pp_ref<=0){
//		page_free(pp);
//		*pte = 0;
//		tlb_invalidate(pgdir, va);
//	}
}
f0101269:	83 c4 20             	add    $0x20,%esp
f010126c:	5b                   	pop    %ebx
f010126d:	5e                   	pop    %esi
f010126e:	5d                   	pop    %ebp
f010126f:	c3                   	ret    

f0101270 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101270:	55                   	push   %ebp
f0101271:	89 e5                	mov    %esp,%ebp
f0101273:	57                   	push   %edi
f0101274:	56                   	push   %esi
f0101275:	53                   	push   %ebx
f0101276:	83 ec 1c             	sub    $0x1c,%esp
f0101279:	8b 75 0c             	mov    0xc(%ebp),%esi
f010127c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f010127f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101286:	00 
f0101287:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010128b:	8b 45 08             	mov    0x8(%ebp),%eax
f010128e:	89 04 24             	mov    %eax,(%esp)
f0101291:	e8 a1 fd ff ff       	call   f0101037 <pgdir_walk>
f0101296:	89 c3                	mov    %eax,%ebx

	if(pte == NULL)
f0101298:	85 c0                	test   %eax,%eax
f010129a:	74 64                	je     f0101300 <page_insert+0x90>
	  return -E_NO_MEM;

	if(*pte & PTE_P){
f010129c:	8b 00                	mov    (%eax),%eax
f010129e:	a8 01                	test   $0x1,%al
f01012a0:	74 3b                	je     f01012dd <page_insert+0x6d>
		if(PTE_ADDR(*pte) == page2pa(pp)){
f01012a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01012a7:	89 f2                	mov    %esi,%edx
f01012a9:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f01012af:	c1 fa 03             	sar    $0x3,%edx
f01012b2:	c1 e2 0c             	shl    $0xc,%edx
f01012b5:	39 d0                	cmp    %edx,%eax
f01012b7:	75 15                	jne    f01012ce <page_insert+0x5e>
			tlb_invalidate(pgdir, va);
f01012b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c0:	89 04 24             	mov    %eax,(%esp)
f01012c3:	e8 54 ff ff ff       	call   f010121c <tlb_invalidate>
			pp->pp_ref--;
f01012c8:	66 ff 4e 04          	decw   0x4(%esi)
f01012cc:	eb 0f                	jmp    f01012dd <page_insert+0x6d>
		}
		else{
			page_remove(pgdir, va);
f01012ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01012d5:	89 04 24             	mov    %eax,(%esp)
f01012d8:	e8 4a ff ff ff       	call   f0101227 <page_remove>
		}
	}

	*pte = page2pa(pp) | perm | PTE_P;
f01012dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e0:	83 c8 01             	or     $0x1,%eax
f01012e3:	89 f2                	mov    %esi,%edx
f01012e5:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f01012eb:	c1 fa 03             	sar    $0x3,%edx
f01012ee:	c1 e2 0c             	shl    $0xc,%edx
f01012f1:	09 d0                	or     %edx,%eax
f01012f3:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref++;
f01012f5:	66 ff 46 04          	incw   0x4(%esi)
	return 0;
f01012f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01012fe:	eb 05                	jmp    f0101305 <page_insert+0x95>
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);

	if(pte == NULL)
	  return -E_NO_MEM;
f0101300:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}

	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f0101305:	83 c4 1c             	add    $0x1c,%esp
f0101308:	5b                   	pop    %ebx
f0101309:	5e                   	pop    %esi
f010130a:	5f                   	pop    %edi
f010130b:	5d                   	pop    %ebp
f010130c:	c3                   	ret    

f010130d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010130d:	55                   	push   %ebp
f010130e:	89 e5                	mov    %esp,%ebp
f0101310:	57                   	push   %edi
f0101311:	56                   	push   %esi
f0101312:	53                   	push   %ebx
f0101313:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101316:	b8 15 00 00 00       	mov    $0x15,%eax
f010131b:	e8 e8 f6 ff ff       	call   f0100a08 <nvram_read>
f0101320:	c1 e0 0a             	shl    $0xa,%eax
f0101323:	89 c2                	mov    %eax,%edx
f0101325:	85 c0                	test   %eax,%eax
f0101327:	79 06                	jns    f010132f <mem_init+0x22>
f0101329:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010132f:	c1 fa 0c             	sar    $0xc,%edx
f0101332:	89 15 f8 e4 20 f0    	mov    %edx,0xf020e4f8
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101338:	b8 17 00 00 00       	mov    $0x17,%eax
f010133d:	e8 c6 f6 ff ff       	call   f0100a08 <nvram_read>
f0101342:	89 c2                	mov    %eax,%edx
f0101344:	c1 e2 0a             	shl    $0xa,%edx
f0101347:	89 d0                	mov    %edx,%eax
f0101349:	85 d2                	test   %edx,%edx
f010134b:	79 06                	jns    f0101353 <mem_init+0x46>
f010134d:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101353:	c1 f8 0c             	sar    $0xc,%eax
f0101356:	74 0e                	je     f0101366 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101358:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010135e:	89 15 a4 f1 20 f0    	mov    %edx,0xf020f1a4
f0101364:	eb 0c                	jmp    f0101372 <mem_init+0x65>
	else
		npages = npages_basemem;
f0101366:	8b 15 f8 e4 20 f0    	mov    0xf020e4f8,%edx
f010136c:	89 15 a4 f1 20 f0    	mov    %edx,0xf020f1a4

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101372:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101375:	c1 e8 0a             	shr    $0xa,%eax
f0101378:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010137c:	a1 f8 e4 20 f0       	mov    0xf020e4f8,%eax
f0101381:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101384:	c1 e8 0a             	shr    $0xa,%eax
f0101387:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f010138b:	a1 a4 f1 20 f0       	mov    0xf020f1a4,%eax
f0101390:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101393:	c1 e8 0a             	shr    $0xa,%eax
f0101396:	89 44 24 04          	mov    %eax,0x4(%esp)
f010139a:	c7 04 24 48 59 10 f0 	movl   $0xf0105948,(%esp)
f01013a1:	e8 ea 23 00 00       	call   f0103790 <cprintf>

	// Remove this line when you're ready to test this function.

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013a6:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ab:	e8 81 f6 ff ff       	call   f0100a31 <boot_alloc>
f01013b0:	a3 a8 f1 20 f0       	mov    %eax,0xf020f1a8
	memset(kern_pgdir, 0, PGSIZE);
f01013b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013bc:	00 
f01013bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013c4:	00 
f01013c5:	89 04 24             	mov    %eax,(%esp)
f01013c8:	e8 fa 39 00 00       	call   f0104dc7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013cd:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013d7:	77 20                	ja     f01013f9 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013dd:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f01013e4:	f0 
f01013e5:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
f01013ec:	00 
f01013ed:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01013f4:	e8 e4 ec ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f01013f9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013ff:	83 ca 05             	or     $0x5,%edx
f0101402:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	size_t page_size = sizeof(struct Page);
	pages = boot_alloc(npages*page_size);
f0101408:	a1 a4 f1 20 f0       	mov    0xf020f1a4,%eax
f010140d:	c1 e0 03             	shl    $0x3,%eax
f0101410:	e8 1c f6 ff ff       	call   f0100a31 <boot_alloc>
f0101415:	a3 ac f1 20 f0       	mov    %eax,0xf020f1ac
	memset(pages, 0, npages*page_size);
f010141a:	8b 15 a4 f1 20 f0    	mov    0xf020f1a4,%edx
f0101420:	c1 e2 03             	shl    $0x3,%edx
f0101423:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101427:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010142e:	00 
f010142f:	89 04 24             	mov    %eax,(%esp)
f0101432:	e8 90 39 00 00       	call   f0104dc7 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	size_t env_size = sizeof(struct Env);
	envs = boot_alloc(NENV * env_size);
f0101437:	b8 00 90 01 00       	mov    $0x19000,%eax
f010143c:	e8 f0 f5 ff ff       	call   f0100a31 <boot_alloc>
f0101441:	a3 0c e5 20 f0       	mov    %eax,0xf020e50c
	memset(envs, 0, NENV * env_size);
f0101446:	c7 44 24 08 00 90 01 	movl   $0x19000,0x8(%esp)
f010144d:	00 
f010144e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101455:	00 
f0101456:	89 04 24             	mov    %eax,(%esp)
f0101459:	e8 69 39 00 00       	call   f0104dc7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010145e:	e8 1f fa ff ff       	call   f0100e82 <page_init>

	check_page_free_list(1);
f0101463:	b8 01 00 00 00       	mov    $0x1,%eax
f0101468:	e8 c2 f6 ff ff       	call   f0100b2f <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f010146d:	83 3d ac f1 20 f0 00 	cmpl   $0x0,0xf020f1ac
f0101474:	75 1c                	jne    f0101492 <mem_init+0x185>
		panic("'pages' is a null pointer!");
f0101476:	c7 44 24 08 4f 60 10 	movl   $0xf010604f,0x8(%esp)
f010147d:	f0 
f010147e:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101485:	00 
f0101486:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010148d:	e8 4b ec ff ff       	call   f01000dd <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101492:	a1 00 e5 20 f0       	mov    0xf020e500,%eax
f0101497:	85 c0                	test   %eax,%eax
f0101499:	74 0e                	je     f01014a9 <mem_init+0x19c>
f010149b:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01014a0:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014a1:	8b 00                	mov    (%eax),%eax
f01014a3:	85 c0                	test   %eax,%eax
f01014a5:	75 f9                	jne    f01014a0 <mem_init+0x193>
f01014a7:	eb 05                	jmp    f01014ae <mem_init+0x1a1>
f01014a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014b5:	e8 99 fa ff ff       	call   f0100f53 <page_alloc>
f01014ba:	89 c6                	mov    %eax,%esi
f01014bc:	85 c0                	test   %eax,%eax
f01014be:	75 24                	jne    f01014e4 <mem_init+0x1d7>
f01014c0:	c7 44 24 0c 6a 60 10 	movl   $0xf010606a,0xc(%esp)
f01014c7:	f0 
f01014c8:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01014cf:	f0 
f01014d0:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f01014d7:	00 
f01014d8:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01014df:	e8 f9 eb ff ff       	call   f01000dd <_panic>
	assert((pp1 = page_alloc(0)));
f01014e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014eb:	e8 63 fa ff ff       	call   f0100f53 <page_alloc>
f01014f0:	89 c7                	mov    %eax,%edi
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	75 24                	jne    f010151a <mem_init+0x20d>
f01014f6:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101505:	f0 
f0101506:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010150d:	00 
f010150e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101515:	e8 c3 eb ff ff       	call   f01000dd <_panic>
	assert((pp2 = page_alloc(0)));
f010151a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101521:	e8 2d fa ff ff       	call   f0100f53 <page_alloc>
f0101526:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101529:	85 c0                	test   %eax,%eax
f010152b:	75 24                	jne    f0101551 <mem_init+0x244>
f010152d:	c7 44 24 0c 96 60 10 	movl   $0xf0106096,0xc(%esp)
f0101534:	f0 
f0101535:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010153c:	f0 
f010153d:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101544:	00 
f0101545:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010154c:	e8 8c eb ff ff       	call   f01000dd <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101551:	39 fe                	cmp    %edi,%esi
f0101553:	75 24                	jne    f0101579 <mem_init+0x26c>
f0101555:	c7 44 24 0c ac 60 10 	movl   $0xf01060ac,0xc(%esp)
f010155c:	f0 
f010155d:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101564:	f0 
f0101565:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f010156c:	00 
f010156d:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101574:	e8 64 eb ff ff       	call   f01000dd <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101579:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010157c:	74 05                	je     f0101583 <mem_init+0x276>
f010157e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101581:	75 24                	jne    f01015a7 <mem_init+0x29a>
f0101583:	c7 44 24 0c 84 59 10 	movl   $0xf0105984,0xc(%esp)
f010158a:	f0 
f010158b:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101592:	f0 
f0101593:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f010159a:	00 
f010159b:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01015a2:	e8 36 eb ff ff       	call   f01000dd <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01015a7:	8b 15 ac f1 20 f0    	mov    0xf020f1ac,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015ad:	a1 a4 f1 20 f0       	mov    0xf020f1a4,%eax
f01015b2:	c1 e0 0c             	shl    $0xc,%eax
f01015b5:	89 f1                	mov    %esi,%ecx
f01015b7:	29 d1                	sub    %edx,%ecx
f01015b9:	c1 f9 03             	sar    $0x3,%ecx
f01015bc:	c1 e1 0c             	shl    $0xc,%ecx
f01015bf:	39 c1                	cmp    %eax,%ecx
f01015c1:	72 24                	jb     f01015e7 <mem_init+0x2da>
f01015c3:	c7 44 24 0c be 60 10 	movl   $0xf01060be,0xc(%esp)
f01015ca:	f0 
f01015cb:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01015d2:	f0 
f01015d3:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01015da:	00 
f01015db:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01015e2:	e8 f6 ea ff ff       	call   f01000dd <_panic>
f01015e7:	89 f9                	mov    %edi,%ecx
f01015e9:	29 d1                	sub    %edx,%ecx
f01015eb:	c1 f9 03             	sar    $0x3,%ecx
f01015ee:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01015f1:	39 c8                	cmp    %ecx,%eax
f01015f3:	77 24                	ja     f0101619 <mem_init+0x30c>
f01015f5:	c7 44 24 0c db 60 10 	movl   $0xf01060db,0xc(%esp)
f01015fc:	f0 
f01015fd:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101604:	f0 
f0101605:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f010160c:	00 
f010160d:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101614:	e8 c4 ea ff ff       	call   f01000dd <_panic>
f0101619:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010161c:	29 d1                	sub    %edx,%ecx
f010161e:	89 ca                	mov    %ecx,%edx
f0101620:	c1 fa 03             	sar    $0x3,%edx
f0101623:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101626:	39 d0                	cmp    %edx,%eax
f0101628:	77 24                	ja     f010164e <mem_init+0x341>
f010162a:	c7 44 24 0c f8 60 10 	movl   $0xf01060f8,0xc(%esp)
f0101631:	f0 
f0101632:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101639:	f0 
f010163a:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101641:	00 
f0101642:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101649:	e8 8f ea ff ff       	call   f01000dd <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010164e:	a1 00 e5 20 f0       	mov    0xf020e500,%eax
f0101653:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101656:	c7 05 00 e5 20 f0 00 	movl   $0x0,0xf020e500
f010165d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101660:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101667:	e8 e7 f8 ff ff       	call   f0100f53 <page_alloc>
f010166c:	85 c0                	test   %eax,%eax
f010166e:	74 24                	je     f0101694 <mem_init+0x387>
f0101670:	c7 44 24 0c 15 61 10 	movl   $0xf0106115,0xc(%esp)
f0101677:	f0 
f0101678:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010167f:	f0 
f0101680:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0101687:	00 
f0101688:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010168f:	e8 49 ea ff ff       	call   f01000dd <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101694:	89 34 24             	mov    %esi,(%esp)
f0101697:	e8 4f f9 ff ff       	call   f0100feb <page_free>
	page_free(pp1);
f010169c:	89 3c 24             	mov    %edi,(%esp)
f010169f:	e8 47 f9 ff ff       	call   f0100feb <page_free>
	page_free(pp2);
f01016a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a7:	89 04 24             	mov    %eax,(%esp)
f01016aa:	e8 3c f9 ff ff       	call   f0100feb <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016b6:	e8 98 f8 ff ff       	call   f0100f53 <page_alloc>
f01016bb:	89 c6                	mov    %eax,%esi
f01016bd:	85 c0                	test   %eax,%eax
f01016bf:	75 24                	jne    f01016e5 <mem_init+0x3d8>
f01016c1:	c7 44 24 0c 6a 60 10 	movl   $0xf010606a,0xc(%esp)
f01016c8:	f0 
f01016c9:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01016d0:	f0 
f01016d1:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01016d8:	00 
f01016d9:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01016e0:	e8 f8 e9 ff ff       	call   f01000dd <_panic>
	assert((pp1 = page_alloc(0)));
f01016e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016ec:	e8 62 f8 ff ff       	call   f0100f53 <page_alloc>
f01016f1:	89 c7                	mov    %eax,%edi
f01016f3:	85 c0                	test   %eax,%eax
f01016f5:	75 24                	jne    f010171b <mem_init+0x40e>
f01016f7:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f01016fe:	f0 
f01016ff:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101706:	f0 
f0101707:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f010170e:	00 
f010170f:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101716:	e8 c2 e9 ff ff       	call   f01000dd <_panic>
	assert((pp2 = page_alloc(0)));
f010171b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101722:	e8 2c f8 ff ff       	call   f0100f53 <page_alloc>
f0101727:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010172a:	85 c0                	test   %eax,%eax
f010172c:	75 24                	jne    f0101752 <mem_init+0x445>
f010172e:	c7 44 24 0c 96 60 10 	movl   $0xf0106096,0xc(%esp)
f0101735:	f0 
f0101736:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010173d:	f0 
f010173e:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101745:	00 
f0101746:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010174d:	e8 8b e9 ff ff       	call   f01000dd <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101752:	39 fe                	cmp    %edi,%esi
f0101754:	75 24                	jne    f010177a <mem_init+0x46d>
f0101756:	c7 44 24 0c ac 60 10 	movl   $0xf01060ac,0xc(%esp)
f010175d:	f0 
f010175e:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101765:	f0 
f0101766:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f010176d:	00 
f010176e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101775:	e8 63 e9 ff ff       	call   f01000dd <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177a:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010177d:	74 05                	je     f0101784 <mem_init+0x477>
f010177f:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101782:	75 24                	jne    f01017a8 <mem_init+0x49b>
f0101784:	c7 44 24 0c 84 59 10 	movl   $0xf0105984,0xc(%esp)
f010178b:	f0 
f010178c:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101793:	f0 
f0101794:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f010179b:	00 
f010179c:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01017a3:	e8 35 e9 ff ff       	call   f01000dd <_panic>
	assert(!page_alloc(0));
f01017a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017af:	e8 9f f7 ff ff       	call   f0100f53 <page_alloc>
f01017b4:	85 c0                	test   %eax,%eax
f01017b6:	74 24                	je     f01017dc <mem_init+0x4cf>
f01017b8:	c7 44 24 0c 15 61 10 	movl   $0xf0106115,0xc(%esp)
f01017bf:	f0 
f01017c0:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01017c7:	f0 
f01017c8:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01017cf:	00 
f01017d0:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01017d7:	e8 01 e9 ff ff       	call   f01000dd <_panic>
f01017dc:	89 f0                	mov    %esi,%eax
f01017de:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f01017e4:	c1 f8 03             	sar    $0x3,%eax
f01017e7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017ea:	89 c2                	mov    %eax,%edx
f01017ec:	c1 ea 0c             	shr    $0xc,%edx
f01017ef:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f01017f5:	72 20                	jb     f0101817 <mem_init+0x50a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017fb:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0101802:	f0 
f0101803:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010180a:	00 
f010180b:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0101812:	e8 c6 e8 ff ff       	call   f01000dd <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101817:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010181e:	00 
f010181f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101826:	00 
	return (void *)(pa + KERNBASE);
f0101827:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010182c:	89 04 24             	mov    %eax,(%esp)
f010182f:	e8 93 35 00 00       	call   f0104dc7 <memset>
	page_free(pp0);
f0101834:	89 34 24             	mov    %esi,(%esp)
f0101837:	e8 af f7 ff ff       	call   f0100feb <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010183c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101843:	e8 0b f7 ff ff       	call   f0100f53 <page_alloc>
f0101848:	85 c0                	test   %eax,%eax
f010184a:	75 24                	jne    f0101870 <mem_init+0x563>
f010184c:	c7 44 24 0c 24 61 10 	movl   $0xf0106124,0xc(%esp)
f0101853:	f0 
f0101854:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010185b:	f0 
f010185c:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101863:	00 
f0101864:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010186b:	e8 6d e8 ff ff       	call   f01000dd <_panic>
	assert(pp && pp0 == pp);
f0101870:	39 c6                	cmp    %eax,%esi
f0101872:	74 24                	je     f0101898 <mem_init+0x58b>
f0101874:	c7 44 24 0c 42 61 10 	movl   $0xf0106142,0xc(%esp)
f010187b:	f0 
f010187c:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101883:	f0 
f0101884:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f010188b:	00 
f010188c:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101893:	e8 45 e8 ff ff       	call   f01000dd <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101898:	89 f2                	mov    %esi,%edx
f010189a:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f01018a0:	c1 fa 03             	sar    $0x3,%edx
f01018a3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a6:	89 d0                	mov    %edx,%eax
f01018a8:	c1 e8 0c             	shr    $0xc,%eax
f01018ab:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f01018b1:	72 20                	jb     f01018d3 <mem_init+0x5c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018b7:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01018be:	f0 
f01018bf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01018c6:	00 
f01018c7:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f01018ce:	e8 0a e8 ff ff       	call   f01000dd <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018d3:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01018da:	75 11                	jne    f01018ed <mem_init+0x5e0>
f01018dc:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01018e2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018e8:	80 38 00             	cmpb   $0x0,(%eax)
f01018eb:	74 24                	je     f0101911 <mem_init+0x604>
f01018ed:	c7 44 24 0c 52 61 10 	movl   $0xf0106152,0xc(%esp)
f01018f4:	f0 
f01018f5:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01018fc:	f0 
f01018fd:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101904:	00 
f0101905:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010190c:	e8 cc e7 ff ff       	call   f01000dd <_panic>
f0101911:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101912:	39 d0                	cmp    %edx,%eax
f0101914:	75 d2                	jne    f01018e8 <mem_init+0x5db>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101916:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101919:	89 15 00 e5 20 f0    	mov    %edx,0xf020e500

	// free the pages we took
	page_free(pp0);
f010191f:	89 34 24             	mov    %esi,(%esp)
f0101922:	e8 c4 f6 ff ff       	call   f0100feb <page_free>
	page_free(pp1);
f0101927:	89 3c 24             	mov    %edi,(%esp)
f010192a:	e8 bc f6 ff ff       	call   f0100feb <page_free>
	page_free(pp2);
f010192f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101932:	89 04 24             	mov    %eax,(%esp)
f0101935:	e8 b1 f6 ff ff       	call   f0100feb <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010193a:	a1 00 e5 20 f0       	mov    0xf020e500,%eax
f010193f:	85 c0                	test   %eax,%eax
f0101941:	74 07                	je     f010194a <mem_init+0x63d>
		--nfree;
f0101943:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101944:	8b 00                	mov    (%eax),%eax
f0101946:	85 c0                	test   %eax,%eax
f0101948:	75 f9                	jne    f0101943 <mem_init+0x636>
		--nfree;
	assert(nfree == 0);
f010194a:	85 db                	test   %ebx,%ebx
f010194c:	74 24                	je     f0101972 <mem_init+0x665>
f010194e:	c7 44 24 0c 5c 61 10 	movl   $0xf010615c,0xc(%esp)
f0101955:	f0 
f0101956:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010195d:	f0 
f010195e:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101965:	00 
f0101966:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010196d:	e8 6b e7 ff ff       	call   f01000dd <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101972:	c7 04 24 a4 59 10 f0 	movl   $0xf01059a4,(%esp)
f0101979:	e8 12 1e 00 00       	call   f0103790 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010197e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101985:	e8 c9 f5 ff ff       	call   f0100f53 <page_alloc>
f010198a:	89 c3                	mov    %eax,%ebx
f010198c:	85 c0                	test   %eax,%eax
f010198e:	75 24                	jne    f01019b4 <mem_init+0x6a7>
f0101990:	c7 44 24 0c 6a 60 10 	movl   $0xf010606a,0xc(%esp)
f0101997:	f0 
f0101998:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010199f:	f0 
f01019a0:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f01019a7:	00 
f01019a8:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01019af:	e8 29 e7 ff ff       	call   f01000dd <_panic>
	assert((pp1 = page_alloc(0)));
f01019b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019bb:	e8 93 f5 ff ff       	call   f0100f53 <page_alloc>
f01019c0:	89 c7                	mov    %eax,%edi
f01019c2:	85 c0                	test   %eax,%eax
f01019c4:	75 24                	jne    f01019ea <mem_init+0x6dd>
f01019c6:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f01019cd:	f0 
f01019ce:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01019d5:	f0 
f01019d6:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f01019dd:	00 
f01019de:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01019e5:	e8 f3 e6 ff ff       	call   f01000dd <_panic>
	assert((pp2 = page_alloc(0)));
f01019ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019f1:	e8 5d f5 ff ff       	call   f0100f53 <page_alloc>
f01019f6:	89 c6                	mov    %eax,%esi
f01019f8:	85 c0                	test   %eax,%eax
f01019fa:	75 24                	jne    f0101a20 <mem_init+0x713>
f01019fc:	c7 44 24 0c 96 60 10 	movl   $0xf0106096,0xc(%esp)
f0101a03:	f0 
f0101a04:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101a0b:	f0 
f0101a0c:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101a13:	00 
f0101a14:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101a1b:	e8 bd e6 ff ff       	call   f01000dd <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a20:	39 fb                	cmp    %edi,%ebx
f0101a22:	75 24                	jne    f0101a48 <mem_init+0x73b>
f0101a24:	c7 44 24 0c ac 60 10 	movl   $0xf01060ac,0xc(%esp)
f0101a2b:	f0 
f0101a2c:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101a33:	f0 
f0101a34:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101a3b:	00 
f0101a3c:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101a43:	e8 95 e6 ff ff       	call   f01000dd <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a48:	39 c7                	cmp    %eax,%edi
f0101a4a:	74 04                	je     f0101a50 <mem_init+0x743>
f0101a4c:	39 c3                	cmp    %eax,%ebx
f0101a4e:	75 24                	jne    f0101a74 <mem_init+0x767>
f0101a50:	c7 44 24 0c 84 59 10 	movl   $0xf0105984,0xc(%esp)
f0101a57:	f0 
f0101a58:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101a5f:	f0 
f0101a60:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101a67:	00 
f0101a68:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101a6f:	e8 69 e6 ff ff       	call   f01000dd <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a74:	8b 15 00 e5 20 f0    	mov    0xf020e500,%edx
f0101a7a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101a7d:	c7 05 00 e5 20 f0 00 	movl   $0x0,0xf020e500
f0101a84:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a8e:	e8 c0 f4 ff ff       	call   f0100f53 <page_alloc>
f0101a93:	85 c0                	test   %eax,%eax
f0101a95:	74 24                	je     f0101abb <mem_init+0x7ae>
f0101a97:	c7 44 24 0c 15 61 10 	movl   $0xf0106115,0xc(%esp)
f0101a9e:	f0 
f0101a9f:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101aae:	00 
f0101aaf:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101ab6:	e8 22 e6 ff ff       	call   f01000dd <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101abb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101abe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ac2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ac9:	00 
f0101aca:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101acf:	89 04 24             	mov    %eax,(%esp)
f0101ad2:	e8 cd f6 ff ff       	call   f01011a4 <page_lookup>
f0101ad7:	85 c0                	test   %eax,%eax
f0101ad9:	74 24                	je     f0101aff <mem_init+0x7f2>
f0101adb:	c7 44 24 0c c4 59 10 	movl   $0xf01059c4,0xc(%esp)
f0101ae2:	f0 
f0101ae3:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101aea:	f0 
f0101aeb:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0101af2:	00 
f0101af3:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101afa:	e8 de e5 ff ff       	call   f01000dd <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aff:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b06:	00 
f0101b07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b0e:	00 
f0101b0f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b13:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101b18:	89 04 24             	mov    %eax,(%esp)
f0101b1b:	e8 50 f7 ff ff       	call   f0101270 <page_insert>
f0101b20:	85 c0                	test   %eax,%eax
f0101b22:	78 24                	js     f0101b48 <mem_init+0x83b>
f0101b24:	c7 44 24 0c fc 59 10 	movl   $0xf01059fc,0xc(%esp)
f0101b2b:	f0 
f0101b2c:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101b33:	f0 
f0101b34:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101b3b:	00 
f0101b3c:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101b43:	e8 95 e5 ff ff       	call   f01000dd <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b48:	89 1c 24             	mov    %ebx,(%esp)
f0101b4b:	e8 9b f4 ff ff       	call   f0100feb <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b50:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b57:	00 
f0101b58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b5f:	00 
f0101b60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b64:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101b69:	89 04 24             	mov    %eax,(%esp)
f0101b6c:	e8 ff f6 ff ff       	call   f0101270 <page_insert>
f0101b71:	85 c0                	test   %eax,%eax
f0101b73:	74 24                	je     f0101b99 <mem_init+0x88c>
f0101b75:	c7 44 24 0c 2c 5a 10 	movl   $0xf0105a2c,0xc(%esp)
f0101b7c:	f0 
f0101b7d:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101b84:	f0 
f0101b85:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101b8c:	00 
f0101b8d:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101b94:	e8 44 e5 ff ff       	call   f01000dd <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b99:	8b 0d a8 f1 20 f0    	mov    0xf020f1a8,%ecx
f0101b9f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ba2:	a1 ac f1 20 f0       	mov    0xf020f1ac,%eax
f0101ba7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101baa:	8b 11                	mov    (%ecx),%edx
f0101bac:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bb2:	89 d8                	mov    %ebx,%eax
f0101bb4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101bb7:	c1 f8 03             	sar    $0x3,%eax
f0101bba:	c1 e0 0c             	shl    $0xc,%eax
f0101bbd:	39 c2                	cmp    %eax,%edx
f0101bbf:	74 24                	je     f0101be5 <mem_init+0x8d8>
f0101bc1:	c7 44 24 0c 5c 5a 10 	movl   $0xf0105a5c,0xc(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101bd0:	f0 
f0101bd1:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101bd8:	00 
f0101bd9:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101be0:	e8 f8 e4 ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101be5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bed:	e8 a9 ed ff ff       	call   f010099b <check_va2pa>
f0101bf2:	89 fa                	mov    %edi,%edx
f0101bf4:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101bf7:	c1 fa 03             	sar    $0x3,%edx
f0101bfa:	c1 e2 0c             	shl    $0xc,%edx
f0101bfd:	39 d0                	cmp    %edx,%eax
f0101bff:	74 24                	je     f0101c25 <mem_init+0x918>
f0101c01:	c7 44 24 0c 84 5a 10 	movl   $0xf0105a84,0xc(%esp)
f0101c08:	f0 
f0101c09:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101c10:	f0 
f0101c11:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101c18:	00 
f0101c19:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101c20:	e8 b8 e4 ff ff       	call   f01000dd <_panic>
	assert(pp1->pp_ref == 1);
f0101c25:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c2a:	74 24                	je     f0101c50 <mem_init+0x943>
f0101c2c:	c7 44 24 0c 67 61 10 	movl   $0xf0106167,0xc(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101c43:	00 
f0101c44:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101c4b:	e8 8d e4 ff ff       	call   f01000dd <_panic>
	assert(pp0->pp_ref == 1);
f0101c50:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c55:	74 24                	je     f0101c7b <mem_init+0x96e>
f0101c57:	c7 44 24 0c 78 61 10 	movl   $0xf0106178,0xc(%esp)
f0101c5e:	f0 
f0101c5f:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101c66:	f0 
f0101c67:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101c6e:	00 
f0101c6f:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101c76:	e8 62 e4 ff ff       	call   f01000dd <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c7b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c82:	00 
f0101c83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c8a:	00 
f0101c8b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c8f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c92:	89 14 24             	mov    %edx,(%esp)
f0101c95:	e8 d6 f5 ff ff       	call   f0101270 <page_insert>
f0101c9a:	85 c0                	test   %eax,%eax
f0101c9c:	74 24                	je     f0101cc2 <mem_init+0x9b5>
f0101c9e:	c7 44 24 0c b4 5a 10 	movl   $0xf0105ab4,0xc(%esp)
f0101ca5:	f0 
f0101ca6:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101cad:	f0 
f0101cae:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101cb5:	00 
f0101cb6:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101cbd:	e8 1b e4 ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cc2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc7:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101ccc:	e8 ca ec ff ff       	call   f010099b <check_va2pa>
f0101cd1:	89 f2                	mov    %esi,%edx
f0101cd3:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f0101cd9:	c1 fa 03             	sar    $0x3,%edx
f0101cdc:	c1 e2 0c             	shl    $0xc,%edx
f0101cdf:	39 d0                	cmp    %edx,%eax
f0101ce1:	74 24                	je     f0101d07 <mem_init+0x9fa>
f0101ce3:	c7 44 24 0c f0 5a 10 	movl   $0xf0105af0,0xc(%esp)
f0101cea:	f0 
f0101ceb:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101cf2:	f0 
f0101cf3:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101cfa:	00 
f0101cfb:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101d02:	e8 d6 e3 ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 1);
f0101d07:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d0c:	74 24                	je     f0101d32 <mem_init+0xa25>
f0101d0e:	c7 44 24 0c 89 61 10 	movl   $0xf0106189,0xc(%esp)
f0101d15:	f0 
f0101d16:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101d1d:	f0 
f0101d1e:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101d25:	00 
f0101d26:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101d2d:	e8 ab e3 ff ff       	call   f01000dd <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d39:	e8 15 f2 ff ff       	call   f0100f53 <page_alloc>
f0101d3e:	85 c0                	test   %eax,%eax
f0101d40:	74 24                	je     f0101d66 <mem_init+0xa59>
f0101d42:	c7 44 24 0c 15 61 10 	movl   $0xf0106115,0xc(%esp)
f0101d49:	f0 
f0101d4a:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101d51:	f0 
f0101d52:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101d59:	00 
f0101d5a:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101d61:	e8 77 e3 ff ff       	call   f01000dd <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d66:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d6d:	00 
f0101d6e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d75:	00 
f0101d76:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d7a:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101d7f:	89 04 24             	mov    %eax,(%esp)
f0101d82:	e8 e9 f4 ff ff       	call   f0101270 <page_insert>
f0101d87:	85 c0                	test   %eax,%eax
f0101d89:	74 24                	je     f0101daf <mem_init+0xaa2>
f0101d8b:	c7 44 24 0c b4 5a 10 	movl   $0xf0105ab4,0xc(%esp)
f0101d92:	f0 
f0101d93:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101d9a:	f0 
f0101d9b:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101da2:	00 
f0101da3:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101daa:	e8 2e e3 ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101daf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db4:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101db9:	e8 dd eb ff ff       	call   f010099b <check_va2pa>
f0101dbe:	89 f2                	mov    %esi,%edx
f0101dc0:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f0101dc6:	c1 fa 03             	sar    $0x3,%edx
f0101dc9:	c1 e2 0c             	shl    $0xc,%edx
f0101dcc:	39 d0                	cmp    %edx,%eax
f0101dce:	74 24                	je     f0101df4 <mem_init+0xae7>
f0101dd0:	c7 44 24 0c f0 5a 10 	movl   $0xf0105af0,0xc(%esp)
f0101dd7:	f0 
f0101dd8:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101ddf:	f0 
f0101de0:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101de7:	00 
f0101de8:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101def:	e8 e9 e2 ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 1);
f0101df4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101df9:	74 24                	je     f0101e1f <mem_init+0xb12>
f0101dfb:	c7 44 24 0c 89 61 10 	movl   $0xf0106189,0xc(%esp)
f0101e02:	f0 
f0101e03:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101e0a:	f0 
f0101e0b:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101e12:	00 
f0101e13:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101e1a:	e8 be e2 ff ff       	call   f01000dd <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e26:	e8 28 f1 ff ff       	call   f0100f53 <page_alloc>
f0101e2b:	85 c0                	test   %eax,%eax
f0101e2d:	74 24                	je     f0101e53 <mem_init+0xb46>
f0101e2f:	c7 44 24 0c 15 61 10 	movl   $0xf0106115,0xc(%esp)
f0101e36:	f0 
f0101e37:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101e3e:	f0 
f0101e3f:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101e46:	00 
f0101e47:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101e4e:	e8 8a e2 ff ff       	call   f01000dd <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e53:	8b 15 a8 f1 20 f0    	mov    0xf020f1a8,%edx
f0101e59:	8b 02                	mov    (%edx),%eax
f0101e5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e60:	89 c1                	mov    %eax,%ecx
f0101e62:	c1 e9 0c             	shr    $0xc,%ecx
f0101e65:	3b 0d a4 f1 20 f0    	cmp    0xf020f1a4,%ecx
f0101e6b:	72 20                	jb     f0101e8d <mem_init+0xb80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e71:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0101e78:	f0 
f0101e79:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101e80:	00 
f0101e81:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101e88:	e8 50 e2 ff ff       	call   f01000dd <_panic>
	return (void *)(pa + KERNBASE);
f0101e8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e9c:	00 
f0101e9d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ea4:	00 
f0101ea5:	89 14 24             	mov    %edx,(%esp)
f0101ea8:	e8 8a f1 ff ff       	call   f0101037 <pgdir_walk>
f0101ead:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101eb0:	83 c2 04             	add    $0x4,%edx
f0101eb3:	39 d0                	cmp    %edx,%eax
f0101eb5:	74 24                	je     f0101edb <mem_init+0xbce>
f0101eb7:	c7 44 24 0c 20 5b 10 	movl   $0xf0105b20,0xc(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101ece:	00 
f0101ecf:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101ed6:	e8 02 e2 ff ff       	call   f01000dd <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101edb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ee2:	00 
f0101ee3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eea:	00 
f0101eeb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101eef:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101ef4:	89 04 24             	mov    %eax,(%esp)
f0101ef7:	e8 74 f3 ff ff       	call   f0101270 <page_insert>
f0101efc:	85 c0                	test   %eax,%eax
f0101efe:	74 24                	je     f0101f24 <mem_init+0xc17>
f0101f00:	c7 44 24 0c 60 5b 10 	movl   $0xf0105b60,0xc(%esp)
f0101f07:	f0 
f0101f08:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101f0f:	f0 
f0101f10:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101f17:	00 
f0101f18:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101f1f:	e8 b9 e1 ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f24:	8b 0d a8 f1 20 f0    	mov    0xf020f1a8,%ecx
f0101f2a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f2d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f32:	89 c8                	mov    %ecx,%eax
f0101f34:	e8 62 ea ff ff       	call   f010099b <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f39:	89 f2                	mov    %esi,%edx
f0101f3b:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f0101f41:	c1 fa 03             	sar    $0x3,%edx
f0101f44:	c1 e2 0c             	shl    $0xc,%edx
f0101f47:	39 d0                	cmp    %edx,%eax
f0101f49:	74 24                	je     f0101f6f <mem_init+0xc62>
f0101f4b:	c7 44 24 0c f0 5a 10 	movl   $0xf0105af0,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101f6a:	e8 6e e1 ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 1);
f0101f6f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f74:	74 24                	je     f0101f9a <mem_init+0xc8d>
f0101f76:	c7 44 24 0c 89 61 10 	movl   $0xf0106189,0xc(%esp)
f0101f7d:	f0 
f0101f7e:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101f85:	f0 
f0101f86:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101f8d:	00 
f0101f8e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101f95:	e8 43 e1 ff ff       	call   f01000dd <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fa1:	00 
f0101fa2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fa9:	00 
f0101faa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fad:	89 04 24             	mov    %eax,(%esp)
f0101fb0:	e8 82 f0 ff ff       	call   f0101037 <pgdir_walk>
f0101fb5:	f6 00 04             	testb  $0x4,(%eax)
f0101fb8:	75 24                	jne    f0101fde <mem_init+0xcd1>
f0101fba:	c7 44 24 0c a0 5b 10 	movl   $0xf0105ba0,0xc(%esp)
f0101fc1:	f0 
f0101fc2:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101fc9:	f0 
f0101fca:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101fd1:	00 
f0101fd2:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0101fd9:	e8 ff e0 ff ff       	call   f01000dd <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fde:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0101fe3:	f6 00 04             	testb  $0x4,(%eax)
f0101fe6:	75 24                	jne    f010200c <mem_init+0xcff>
f0101fe8:	c7 44 24 0c 9a 61 10 	movl   $0xf010619a,0xc(%esp)
f0101fef:	f0 
f0101ff0:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0101ff7:	f0 
f0101ff8:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101fff:	00 
f0102000:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102007:	e8 d1 e0 ff ff       	call   f01000dd <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010200c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102013:	00 
f0102014:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010201b:	00 
f010201c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102020:	89 04 24             	mov    %eax,(%esp)
f0102023:	e8 48 f2 ff ff       	call   f0101270 <page_insert>
f0102028:	85 c0                	test   %eax,%eax
f010202a:	78 24                	js     f0102050 <mem_init+0xd43>
f010202c:	c7 44 24 0c d4 5b 10 	movl   $0xf0105bd4,0xc(%esp)
f0102033:	f0 
f0102034:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010203b:	f0 
f010203c:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102043:	00 
f0102044:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010204b:	e8 8d e0 ff ff       	call   f01000dd <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102050:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102057:	00 
f0102058:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010205f:	00 
f0102060:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102064:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102069:	89 04 24             	mov    %eax,(%esp)
f010206c:	e8 ff f1 ff ff       	call   f0101270 <page_insert>
f0102071:	85 c0                	test   %eax,%eax
f0102073:	74 24                	je     f0102099 <mem_init+0xd8c>
f0102075:	c7 44 24 0c 0c 5c 10 	movl   $0xf0105c0c,0xc(%esp)
f010207c:	f0 
f010207d:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102084:	f0 
f0102085:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f010208c:	00 
f010208d:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102094:	e8 44 e0 ff ff       	call   f01000dd <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102099:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020a0:	00 
f01020a1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020a8:	00 
f01020a9:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01020ae:	89 04 24             	mov    %eax,(%esp)
f01020b1:	e8 81 ef ff ff       	call   f0101037 <pgdir_walk>
f01020b6:	f6 00 04             	testb  $0x4,(%eax)
f01020b9:	74 24                	je     f01020df <mem_init+0xdd2>
f01020bb:	c7 44 24 0c 48 5c 10 	movl   $0xf0105c48,0xc(%esp)
f01020c2:	f0 
f01020c3:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01020ca:	f0 
f01020cb:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01020d2:	00 
f01020d3:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01020da:	e8 fe df ff ff       	call   f01000dd <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01020df:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01020e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01020e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ec:	e8 aa e8 ff ff       	call   f010099b <check_va2pa>
f01020f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01020f4:	89 f8                	mov    %edi,%eax
f01020f6:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f01020fc:	c1 f8 03             	sar    $0x3,%eax
f01020ff:	c1 e0 0c             	shl    $0xc,%eax
f0102102:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102105:	74 24                	je     f010212b <mem_init+0xe1e>
f0102107:	c7 44 24 0c 80 5c 10 	movl   $0xf0105c80,0xc(%esp)
f010210e:	f0 
f010210f:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102116:	f0 
f0102117:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f010211e:	00 
f010211f:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102126:	e8 b2 df ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010212b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102130:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102133:	e8 63 e8 ff ff       	call   f010099b <check_va2pa>
f0102138:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010213b:	74 24                	je     f0102161 <mem_init+0xe54>
f010213d:	c7 44 24 0c ac 5c 10 	movl   $0xf0105cac,0xc(%esp)
f0102144:	f0 
f0102145:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010214c:	f0 
f010214d:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102154:	00 
f0102155:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010215c:	e8 7c df ff ff       	call   f01000dd <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102161:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102166:	74 24                	je     f010218c <mem_init+0xe7f>
f0102168:	c7 44 24 0c b0 61 10 	movl   $0xf01061b0,0xc(%esp)
f010216f:	f0 
f0102170:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102177:	f0 
f0102178:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f010217f:	00 
f0102180:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102187:	e8 51 df ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 0);
f010218c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102191:	74 24                	je     f01021b7 <mem_init+0xeaa>
f0102193:	c7 44 24 0c c1 61 10 	movl   $0xf01061c1,0xc(%esp)
f010219a:	f0 
f010219b:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01021a2:	f0 
f01021a3:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01021aa:	00 
f01021ab:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01021b2:	e8 26 df ff ff       	call   f01000dd <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021be:	e8 90 ed ff ff       	call   f0100f53 <page_alloc>
f01021c3:	85 c0                	test   %eax,%eax
f01021c5:	74 04                	je     f01021cb <mem_init+0xebe>
f01021c7:	39 c6                	cmp    %eax,%esi
f01021c9:	74 24                	je     f01021ef <mem_init+0xee2>
f01021cb:	c7 44 24 0c dc 5c 10 	movl   $0xf0105cdc,0xc(%esp)
f01021d2:	f0 
f01021d3:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01021da:	f0 
f01021db:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01021e2:	00 
f01021e3:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01021ea:	e8 ee de ff ff       	call   f01000dd <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01021f6:	00 
f01021f7:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01021fc:	89 04 24             	mov    %eax,(%esp)
f01021ff:	e8 23 f0 ff ff       	call   f0101227 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102204:	8b 15 a8 f1 20 f0    	mov    0xf020f1a8,%edx
f010220a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010220d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102212:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102215:	e8 81 e7 ff ff       	call   f010099b <check_va2pa>
f010221a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010221d:	74 24                	je     f0102243 <mem_init+0xf36>
f010221f:	c7 44 24 0c 00 5d 10 	movl   $0xf0105d00,0xc(%esp)
f0102226:	f0 
f0102227:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010222e:	f0 
f010222f:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102236:	00 
f0102237:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010223e:	e8 9a de ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102243:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010224b:	e8 4b e7 ff ff       	call   f010099b <check_va2pa>
f0102250:	89 fa                	mov    %edi,%edx
f0102252:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f0102258:	c1 fa 03             	sar    $0x3,%edx
f010225b:	c1 e2 0c             	shl    $0xc,%edx
f010225e:	39 d0                	cmp    %edx,%eax
f0102260:	74 24                	je     f0102286 <mem_init+0xf79>
f0102262:	c7 44 24 0c ac 5c 10 	movl   $0xf0105cac,0xc(%esp)
f0102269:	f0 
f010226a:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102271:	f0 
f0102272:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102279:	00 
f010227a:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102281:	e8 57 de ff ff       	call   f01000dd <_panic>
	assert(pp1->pp_ref == 1);
f0102286:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010228b:	74 24                	je     f01022b1 <mem_init+0xfa4>
f010228d:	c7 44 24 0c 67 61 10 	movl   $0xf0106167,0xc(%esp)
f0102294:	f0 
f0102295:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010229c:	f0 
f010229d:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01022a4:	00 
f01022a5:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01022ac:	e8 2c de ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 0);
f01022b1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022b6:	74 24                	je     f01022dc <mem_init+0xfcf>
f01022b8:	c7 44 24 0c c1 61 10 	movl   $0xf01061c1,0xc(%esp)
f01022bf:	f0 
f01022c0:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01022c7:	f0 
f01022c8:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01022cf:	00 
f01022d0:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01022d7:	e8 01 de ff ff       	call   f01000dd <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022dc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022e3:	00 
f01022e4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01022e7:	89 0c 24             	mov    %ecx,(%esp)
f01022ea:	e8 38 ef ff ff       	call   f0101227 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022ef:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01022f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01022fc:	e8 9a e6 ff ff       	call   f010099b <check_va2pa>
f0102301:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102304:	74 24                	je     f010232a <mem_init+0x101d>
f0102306:	c7 44 24 0c 00 5d 10 	movl   $0xf0105d00,0xc(%esp)
f010230d:	f0 
f010230e:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102315:	f0 
f0102316:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f010231d:	00 
f010231e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102325:	e8 b3 dd ff ff       	call   f01000dd <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010232a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010232f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102332:	e8 64 e6 ff ff       	call   f010099b <check_va2pa>
f0102337:	83 f8 ff             	cmp    $0xffffffff,%eax
f010233a:	74 24                	je     f0102360 <mem_init+0x1053>
f010233c:	c7 44 24 0c 24 5d 10 	movl   $0xf0105d24,0xc(%esp)
f0102343:	f0 
f0102344:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010234b:	f0 
f010234c:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102353:	00 
f0102354:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010235b:	e8 7d dd ff ff       	call   f01000dd <_panic>
	assert(pp1->pp_ref == 0);
f0102360:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102365:	74 24                	je     f010238b <mem_init+0x107e>
f0102367:	c7 44 24 0c d2 61 10 	movl   $0xf01061d2,0xc(%esp)
f010236e:	f0 
f010236f:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102376:	f0 
f0102377:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f010237e:	00 
f010237f:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102386:	e8 52 dd ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 0);
f010238b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102390:	74 24                	je     f01023b6 <mem_init+0x10a9>
f0102392:	c7 44 24 0c c1 61 10 	movl   $0xf01061c1,0xc(%esp)
f0102399:	f0 
f010239a:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01023a1:	f0 
f01023a2:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01023a9:	00 
f01023aa:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01023b1:	e8 27 dd ff ff       	call   f01000dd <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023bd:	e8 91 eb ff ff       	call   f0100f53 <page_alloc>
f01023c2:	85 c0                	test   %eax,%eax
f01023c4:	74 04                	je     f01023ca <mem_init+0x10bd>
f01023c6:	39 c7                	cmp    %eax,%edi
f01023c8:	74 24                	je     f01023ee <mem_init+0x10e1>
f01023ca:	c7 44 24 0c 4c 5d 10 	movl   $0xf0105d4c,0xc(%esp)
f01023d1:	f0 
f01023d2:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01023d9:	f0 
f01023da:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01023e1:	00 
f01023e2:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01023e9:	e8 ef dc ff ff       	call   f01000dd <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023f5:	e8 59 eb ff ff       	call   f0100f53 <page_alloc>
f01023fa:	85 c0                	test   %eax,%eax
f01023fc:	74 24                	je     f0102422 <mem_init+0x1115>
f01023fe:	c7 44 24 0c 15 61 10 	movl   $0xf0106115,0xc(%esp)
f0102405:	f0 
f0102406:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010240d:	f0 
f010240e:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0102415:	00 
f0102416:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010241d:	e8 bb dc ff ff       	call   f01000dd <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102422:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102427:	8b 08                	mov    (%eax),%ecx
f0102429:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010242f:	89 da                	mov    %ebx,%edx
f0102431:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f0102437:	c1 fa 03             	sar    $0x3,%edx
f010243a:	c1 e2 0c             	shl    $0xc,%edx
f010243d:	39 d1                	cmp    %edx,%ecx
f010243f:	74 24                	je     f0102465 <mem_init+0x1158>
f0102441:	c7 44 24 0c 5c 5a 10 	movl   $0xf0105a5c,0xc(%esp)
f0102448:	f0 
f0102449:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102450:	f0 
f0102451:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102458:	00 
f0102459:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102460:	e8 78 dc ff ff       	call   f01000dd <_panic>
	kern_pgdir[0] = 0;
f0102465:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010246b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102470:	74 24                	je     f0102496 <mem_init+0x1189>
f0102472:	c7 44 24 0c 78 61 10 	movl   $0xf0106178,0xc(%esp)
f0102479:	f0 
f010247a:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102481:	f0 
f0102482:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102489:	00 
f010248a:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102491:	e8 47 dc ff ff       	call   f01000dd <_panic>
	pp0->pp_ref = 0;
f0102496:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010249c:	89 1c 24             	mov    %ebx,(%esp)
f010249f:	e8 47 eb ff ff       	call   f0100feb <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01024a4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01024ab:	00 
f01024ac:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01024b3:	00 
f01024b4:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01024b9:	89 04 24             	mov    %eax,(%esp)
f01024bc:	e8 76 eb ff ff       	call   f0101037 <pgdir_walk>
f01024c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01024c4:	8b 0d a8 f1 20 f0    	mov    0xf020f1a8,%ecx
f01024ca:	8b 51 04             	mov    0x4(%ecx),%edx
f01024cd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024d3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024d6:	8b 15 a4 f1 20 f0    	mov    0xf020f1a4,%edx
f01024dc:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01024df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024e2:	c1 ea 0c             	shr    $0xc,%edx
f01024e5:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01024e8:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01024eb:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01024ee:	72 23                	jb     f0102513 <mem_init+0x1206>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024f3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01024f7:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01024fe:	f0 
f01024ff:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102506:	00 
f0102507:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010250e:	e8 ca db ff ff       	call   f01000dd <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102513:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102516:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010251c:	39 d0                	cmp    %edx,%eax
f010251e:	74 24                	je     f0102544 <mem_init+0x1237>
f0102520:	c7 44 24 0c e3 61 10 	movl   $0xf01061e3,0xc(%esp)
f0102527:	f0 
f0102528:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010252f:	f0 
f0102530:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102537:	00 
f0102538:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010253f:	e8 99 db ff ff       	call   f01000dd <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102544:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f010254b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102551:	89 d8                	mov    %ebx,%eax
f0102553:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0102559:	c1 f8 03             	sar    $0x3,%eax
f010255c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010255f:	89 c1                	mov    %eax,%ecx
f0102561:	c1 e9 0c             	shr    $0xc,%ecx
f0102564:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102567:	77 20                	ja     f0102589 <mem_init+0x127c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102569:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010256d:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0102574:	f0 
f0102575:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010257c:	00 
f010257d:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0102584:	e8 54 db ff ff       	call   f01000dd <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102589:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102590:	00 
f0102591:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102598:	00 
	return (void *)(pa + KERNBASE);
f0102599:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010259e:	89 04 24             	mov    %eax,(%esp)
f01025a1:	e8 21 28 00 00       	call   f0104dc7 <memset>
	page_free(pp0);
f01025a6:	89 1c 24             	mov    %ebx,(%esp)
f01025a9:	e8 3d ea ff ff       	call   f0100feb <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01025ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025b5:	00 
f01025b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01025bd:	00 
f01025be:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01025c3:	89 04 24             	mov    %eax,(%esp)
f01025c6:	e8 6c ea ff ff       	call   f0101037 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01025cb:	89 da                	mov    %ebx,%edx
f01025cd:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f01025d3:	c1 fa 03             	sar    $0x3,%edx
f01025d6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025d9:	89 d0                	mov    %edx,%eax
f01025db:	c1 e8 0c             	shr    $0xc,%eax
f01025de:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f01025e4:	72 20                	jb     f0102606 <mem_init+0x12f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01025ea:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01025f1:	f0 
f01025f2:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01025f9:	00 
f01025fa:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0102601:	e8 d7 da ff ff       	call   f01000dd <_panic>
	return (void *)(pa + KERNBASE);
f0102606:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010260c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010260f:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102616:	75 11                	jne    f0102629 <mem_init+0x131c>
f0102618:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010261e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102624:	f6 00 01             	testb  $0x1,(%eax)
f0102627:	74 24                	je     f010264d <mem_init+0x1340>
f0102629:	c7 44 24 0c fb 61 10 	movl   $0xf01061fb,0xc(%esp)
f0102630:	f0 
f0102631:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102638:	f0 
f0102639:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102640:	00 
f0102641:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102648:	e8 90 da ff ff       	call   f01000dd <_panic>
f010264d:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102650:	39 d0                	cmp    %edx,%eax
f0102652:	75 d0                	jne    f0102624 <mem_init+0x1317>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102654:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102659:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010265f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f0102665:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102668:	89 0d 00 e5 20 f0    	mov    %ecx,0xf020e500

	// free the pages we took
	page_free(pp0);
f010266e:	89 1c 24             	mov    %ebx,(%esp)
f0102671:	e8 75 e9 ff ff       	call   f0100feb <page_free>
	page_free(pp1);
f0102676:	89 3c 24             	mov    %edi,(%esp)
f0102679:	e8 6d e9 ff ff       	call   f0100feb <page_free>
	page_free(pp2);
f010267e:	89 34 24             	mov    %esi,(%esp)
f0102681:	e8 65 e9 ff ff       	call   f0100feb <page_free>

	cprintf("check_page() succeeded!\n");
f0102686:	c7 04 24 12 62 10 f0 	movl   $0xf0106212,(%esp)
f010268d:	e8 fe 10 00 00       	call   f0103790 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	//
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages *page_size, PGSIZE),
f0102692:	a1 ac f1 20 f0       	mov    0xf020f1ac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102697:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010269c:	77 20                	ja     f01026be <mem_init+0x13b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010269e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026a2:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f01026a9:	f0 
f01026aa:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f01026b1:	00 
f01026b2:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01026b9:	e8 1f da ff ff       	call   f01000dd <_panic>
f01026be:	8b 15 a4 f1 20 f0    	mov    0xf020f1a4,%edx
f01026c4:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01026cb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026d1:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01026d8:	00 
	return (physaddr_t)kva - KERNBASE;
f01026d9:	05 00 00 00 10       	add    $0x10000000,%eax
f01026de:	89 04 24             	mov    %eax,(%esp)
f01026e1:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026e6:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01026eb:	e8 55 ea ff ff       	call   f0101145 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV*env_size, PGSIZE),
f01026f0:	a1 0c e5 20 f0       	mov    0xf020e50c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026fa:	77 20                	ja     f010271c <mem_init+0x140f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102700:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0102707:	f0 
f0102708:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f010270f:	00 
f0102710:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102717:	e8 c1 d9 ff ff       	call   f01000dd <_panic>
f010271c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102723:	00 
	return (physaddr_t)kva - KERNBASE;
f0102724:	05 00 00 00 10       	add    $0x10000000,%eax
f0102729:	89 04 24             	mov    %eax,(%esp)
f010272c:	b9 00 90 01 00       	mov    $0x19000,%ecx
f0102731:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102736:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f010273b:	e8 05 ea ff ff       	call   f0101145 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102740:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f0102745:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010274a:	77 20                	ja     f010276c <mem_init+0x145f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010274c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102750:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0102757:	f0 
f0102758:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f010275f:	00 
f0102760:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102767:	e8 71 d9 ff ff       	call   f01000dd <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE,
f010276c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102773:	00 
f0102774:	c7 04 24 00 a0 11 00 	movl   $0x11a000,(%esp)
f010277b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102780:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102785:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f010278a:	e8 b6 e9 ff ff       	call   f0101145 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ~KERNBASE+1,
f010278f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102796:	00 
f0102797:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010279e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027a3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027a8:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f01027ad:	e8 93 e9 ff ff       	call   f0101145 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027b2:	8b 1d a8 f1 20 f0    	mov    0xf020f1a8,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f01027b8:	8b 15 a4 f1 20 f0    	mov    0xf020f1a4,%edx
f01027be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01027c1:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01027c8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01027ce:	0f 84 80 00 00 00    	je     f0102854 <mem_init+0x1547>
f01027d4:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027d9:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027df:	89 d8                	mov    %ebx,%eax
f01027e1:	e8 b5 e1 ff ff       	call   f010099b <check_va2pa>
f01027e6:	8b 15 ac f1 20 f0    	mov    0xf020f1ac,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027ec:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027f2:	77 20                	ja     f0102814 <mem_init+0x1507>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027f8:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f01027ff:	f0 
f0102800:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102807:	00 
f0102808:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010280f:	e8 c9 d8 ff ff       	call   f01000dd <_panic>
f0102814:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010281b:	39 d0                	cmp    %edx,%eax
f010281d:	74 24                	je     f0102843 <mem_init+0x1536>
f010281f:	c7 44 24 0c 70 5d 10 	movl   $0xf0105d70,0xc(%esp)
f0102826:	f0 
f0102827:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010282e:	f0 
f010282f:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102836:	00 
f0102837:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010283e:	e8 9a d8 ff ff       	call   f01000dd <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102843:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102849:	39 f7                	cmp    %esi,%edi
f010284b:	77 8c                	ja     f01027d9 <mem_init+0x14cc>
f010284d:	be 00 00 00 00       	mov    $0x0,%esi
f0102852:	eb 05                	jmp    f0102859 <mem_init+0x154c>
f0102854:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102859:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010285f:	89 d8                	mov    %ebx,%eax
f0102861:	e8 35 e1 ff ff       	call   f010099b <check_va2pa>
f0102866:	8b 15 0c e5 20 f0    	mov    0xf020e50c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010286c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102872:	77 20                	ja     f0102894 <mem_init+0x1587>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102874:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102878:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f010287f:	f0 
f0102880:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102887:	00 
f0102888:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010288f:	e8 49 d8 ff ff       	call   f01000dd <_panic>
f0102894:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010289b:	39 d0                	cmp    %edx,%eax
f010289d:	74 24                	je     f01028c3 <mem_init+0x15b6>
f010289f:	c7 44 24 0c a4 5d 10 	movl   $0xf0105da4,0xc(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01028b6:	00 
f01028b7:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01028be:	e8 1a d8 ff ff       	call   f01000dd <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028c3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028c9:	81 fe 00 90 01 00    	cmp    $0x19000,%esi
f01028cf:	75 88                	jne    f0102859 <mem_init+0x154c>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f01028d1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028d6:	89 d8                	mov    %ebx,%eax
f01028d8:	e8 97 e0 ff ff       	call   f0100974 <check_va2pa_large>
f01028dd:	85 c0                	test   %eax,%eax
f01028df:	74 0a                	je     f01028eb <mem_init+0x15de>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028e4:	c1 e7 0c             	shl    $0xc,%edi
f01028e7:	75 7e                	jne    f0102967 <mem_init+0x165a>
f01028e9:	eb 5e                	jmp    f0102949 <mem_init+0x163c>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f01028eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028ee:	c1 e7 0c             	shl    $0xc,%edi
f01028f1:	75 37                	jne    f010292a <mem_init+0x161d>
f01028f3:	eb 48                	jmp    f010293d <mem_init+0x1630>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028f5:	8d 90 00 00 40 f0    	lea    -0xfc00000(%eax),%edx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f01028fb:	89 f0                	mov    %esi,%eax
f01028fd:	e8 72 e0 ff ff       	call   f0100974 <check_va2pa_large>
f0102902:	39 d8                	cmp    %ebx,%eax
f0102904:	74 2b                	je     f0102931 <mem_init+0x1624>
f0102906:	c7 44 24 0c d8 5d 10 	movl   $0xf0105dd8,0xc(%esp)
f010290d:	f0 
f010290e:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102915:	f0 
f0102916:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f010291d:	00 
f010291e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102925:	e8 b3 d7 ff ff       	call   f01000dd <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f010292a:	b8 00 00 00 00       	mov    $0x0,%eax
f010292f:	89 de                	mov    %ebx,%esi
f0102931:	8d 98 00 00 40 00    	lea    0x400000(%eax),%ebx
f0102937:	39 fb                	cmp    %edi,%ebx
f0102939:	72 ba                	jb     f01028f5 <mem_init+0x15e8>
f010293b:	89 f3                	mov    %esi,%ebx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f010293d:	c7 04 24 2b 62 10 f0 	movl   $0xf010622b,(%esp)
f0102944:	e8 47 0e 00 00       	call   f0103790 <cprintf>
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102949:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010294e:	89 d8                	mov    %ebx,%eax
f0102950:	e8 46 e0 ff ff       	call   f010099b <check_va2pa>
f0102955:	be 00 90 bf ef       	mov    $0xefbf9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010295a:	bf 00 a0 11 f0       	mov    $0xf011a000,%edi
f010295f:	81 c7 00 70 40 20    	add    $0x20407000,%edi
f0102965:	eb 46                	jmp    f01029ad <mem_init+0x16a0>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102967:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010296c:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102972:	89 d8                	mov    %ebx,%eax
f0102974:	e8 22 e0 ff ff       	call   f010099b <check_va2pa>
f0102979:	39 c6                	cmp    %eax,%esi
f010297b:	74 24                	je     f01029a1 <mem_init+0x1694>
f010297d:	c7 44 24 0c 04 5e 10 	movl   $0xf0105e04,0xc(%esp)
f0102984:	f0 
f0102985:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f010298c:	f0 
f010298d:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102994:	00 
f0102995:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f010299c:	e8 3c d7 ff ff       	call   f01000dd <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029a1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01029a7:	39 fe                	cmp    %edi,%esi
f01029a9:	72 c1                	jb     f010296c <mem_init+0x165f>
f01029ab:	eb 9c                	jmp    f0102949 <mem_init+0x163c>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01029ad:	8d 14 37             	lea    (%edi,%esi,1),%edx
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029b0:	39 d0                	cmp    %edx,%eax
f01029b2:	74 24                	je     f01029d8 <mem_init+0x16cb>
f01029b4:	c7 44 24 0c 2c 5e 10 	movl   $0xf0105e2c,0xc(%esp)
f01029bb:	f0 
f01029bc:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f01029c3:	f0 
f01029c4:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f01029cb:	00 
f01029cc:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f01029d3:	e8 05 d7 ff ff       	call   f01000dd <_panic>
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029d8:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f01029de:	0f 85 25 05 00 00    	jne    f0102f09 <mem_init+0x1bfc>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029e4:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f01029e9:	89 d8                	mov    %ebx,%eax
f01029eb:	e8 ab df ff ff       	call   f010099b <check_va2pa>
f01029f0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029f3:	74 24                	je     f0102a19 <mem_init+0x170c>
f01029f5:	c7 44 24 0c 74 5e 10 	movl   $0xf0105e74,0xc(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102a0c:	00 
f0102a0d:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102a14:	e8 c4 d6 ff ff       	call   f01000dd <_panic>
f0102a19:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a1e:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a24:	83 fa 03             	cmp    $0x3,%edx
f0102a27:	77 2e                	ja     f0102a57 <mem_init+0x174a>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102a29:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102a2d:	0f 85 aa 00 00 00    	jne    f0102add <mem_init+0x17d0>
f0102a33:	c7 44 24 0c 42 62 10 	movl   $0xf0106242,0xc(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102a4a:	00 
f0102a4b:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102a52:	e8 86 d6 ff ff       	call   f01000dd <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a57:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a5c:	76 55                	jbe    f0102ab3 <mem_init+0x17a6>
				assert(pgdir[i] & PTE_P);
f0102a5e:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102a61:	f6 c2 01             	test   $0x1,%dl
f0102a64:	75 24                	jne    f0102a8a <mem_init+0x177d>
f0102a66:	c7 44 24 0c 42 62 10 	movl   $0xf0106242,0xc(%esp)
f0102a6d:	f0 
f0102a6e:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102a75:	f0 
f0102a76:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102a7d:	00 
f0102a7e:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102a85:	e8 53 d6 ff ff       	call   f01000dd <_panic>
				assert(pgdir[i] & PTE_W);
f0102a8a:	f6 c2 02             	test   $0x2,%dl
f0102a8d:	75 4e                	jne    f0102add <mem_init+0x17d0>
f0102a8f:	c7 44 24 0c 53 62 10 	movl   $0xf0106253,0xc(%esp)
f0102a96:	f0 
f0102a97:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102a9e:	f0 
f0102a9f:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0102aa6:	00 
f0102aa7:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102aae:	e8 2a d6 ff ff       	call   f01000dd <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ab3:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102ab7:	74 24                	je     f0102add <mem_init+0x17d0>
f0102ab9:	c7 44 24 0c 64 62 10 	movl   $0xf0106264,0xc(%esp)
f0102ac0:	f0 
f0102ac1:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102ac8:	f0 
f0102ac9:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0102ad0:	00 
f0102ad1:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102ad8:	e8 00 d6 ff ff       	call   f01000dd <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102add:	40                   	inc    %eax
f0102ade:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ae3:	0f 85 35 ff ff ff    	jne    f0102a1e <mem_init+0x1711>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102ae9:	c7 04 24 a4 5e 10 f0 	movl   $0xf0105ea4,(%esp)
f0102af0:	e8 9b 0c 00 00       	call   f0103790 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102af5:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102afa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102aff:	77 20                	ja     f0102b21 <mem_init+0x1814>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b01:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b05:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0102b0c:	f0 
f0102b0d:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
f0102b14:	00 
f0102b15:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102b1c:	e8 bc d5 ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b21:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b26:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b29:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b2e:	e8 fc df ff ff       	call   f0100b2f <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102b33:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102b36:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b3b:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b3e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b48:	e8 06 e4 ff ff       	call   f0100f53 <page_alloc>
f0102b4d:	89 c6                	mov    %eax,%esi
f0102b4f:	85 c0                	test   %eax,%eax
f0102b51:	75 24                	jne    f0102b77 <mem_init+0x186a>
f0102b53:	c7 44 24 0c 6a 60 10 	movl   $0xf010606a,0xc(%esp)
f0102b5a:	f0 
f0102b5b:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102b62:	f0 
f0102b63:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f0102b6a:	00 
f0102b6b:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102b72:	e8 66 d5 ff ff       	call   f01000dd <_panic>
	assert((pp1 = page_alloc(0)));
f0102b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b7e:	e8 d0 e3 ff ff       	call   f0100f53 <page_alloc>
f0102b83:	89 c7                	mov    %eax,%edi
f0102b85:	85 c0                	test   %eax,%eax
f0102b87:	75 24                	jne    f0102bad <mem_init+0x18a0>
f0102b89:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f0102b90:	f0 
f0102b91:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102b98:	f0 
f0102b99:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f0102ba0:	00 
f0102ba1:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102ba8:	e8 30 d5 ff ff       	call   f01000dd <_panic>
	assert((pp2 = page_alloc(0)));
f0102bad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bb4:	e8 9a e3 ff ff       	call   f0100f53 <page_alloc>
f0102bb9:	89 c3                	mov    %eax,%ebx
f0102bbb:	85 c0                	test   %eax,%eax
f0102bbd:	75 24                	jne    f0102be3 <mem_init+0x18d6>
f0102bbf:	c7 44 24 0c 96 60 10 	movl   $0xf0106096,0xc(%esp)
f0102bc6:	f0 
f0102bc7:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102bce:	f0 
f0102bcf:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0102bd6:	00 
f0102bd7:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102bde:	e8 fa d4 ff ff       	call   f01000dd <_panic>
	page_free(pp0);
f0102be3:	89 34 24             	mov    %esi,(%esp)
f0102be6:	e8 00 e4 ff ff       	call   f0100feb <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102beb:	89 f8                	mov    %edi,%eax
f0102bed:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0102bf3:	c1 f8 03             	sar    $0x3,%eax
f0102bf6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bf9:	89 c2                	mov    %eax,%edx
f0102bfb:	c1 ea 0c             	shr    $0xc,%edx
f0102bfe:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f0102c04:	72 20                	jb     f0102c26 <mem_init+0x1919>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c0a:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0102c11:	f0 
f0102c12:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c19:	00 
f0102c1a:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0102c21:	e8 b7 d4 ff ff       	call   f01000dd <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c26:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c2d:	00 
f0102c2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102c35:	00 
	return (void *)(pa + KERNBASE);
f0102c36:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c3b:	89 04 24             	mov    %eax,(%esp)
f0102c3e:	e8 84 21 00 00       	call   f0104dc7 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c43:	89 d8                	mov    %ebx,%eax
f0102c45:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0102c4b:	c1 f8 03             	sar    $0x3,%eax
f0102c4e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c51:	89 c2                	mov    %eax,%edx
f0102c53:	c1 ea 0c             	shr    $0xc,%edx
f0102c56:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f0102c5c:	72 20                	jb     f0102c7e <mem_init+0x1971>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c62:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0102c69:	f0 
f0102c6a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c71:	00 
f0102c72:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0102c79:	e8 5f d4 ff ff       	call   f01000dd <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c7e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c85:	00 
f0102c86:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c8d:	00 
	return (void *)(pa + KERNBASE);
f0102c8e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c93:	89 04 24             	mov    %eax,(%esp)
f0102c96:	e8 2c 21 00 00       	call   f0104dc7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c9b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102ca2:	00 
f0102ca3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102caa:	00 
f0102cab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102caf:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102cb4:	89 04 24             	mov    %eax,(%esp)
f0102cb7:	e8 b4 e5 ff ff       	call   f0101270 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cbc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cc1:	74 24                	je     f0102ce7 <mem_init+0x19da>
f0102cc3:	c7 44 24 0c 67 61 10 	movl   $0xf0106167,0xc(%esp)
f0102cca:	f0 
f0102ccb:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102cd2:	f0 
f0102cd3:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f0102cda:	00 
f0102cdb:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102ce2:	e8 f6 d3 ff ff       	call   f01000dd <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ce7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cee:	01 01 01 
f0102cf1:	74 24                	je     f0102d17 <mem_init+0x1a0a>
f0102cf3:	c7 44 24 0c c4 5e 10 	movl   $0xf0105ec4,0xc(%esp)
f0102cfa:	f0 
f0102cfb:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102d02:	f0 
f0102d03:	c7 44 24 04 a8 04 00 	movl   $0x4a8,0x4(%esp)
f0102d0a:	00 
f0102d0b:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102d12:	e8 c6 d3 ff ff       	call   f01000dd <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d17:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102d1e:	00 
f0102d1f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d26:	00 
f0102d27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d2b:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102d30:	89 04 24             	mov    %eax,(%esp)
f0102d33:	e8 38 e5 ff ff       	call   f0101270 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d38:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d3f:	02 02 02 
f0102d42:	74 24                	je     f0102d68 <mem_init+0x1a5b>
f0102d44:	c7 44 24 0c e8 5e 10 	movl   $0xf0105ee8,0xc(%esp)
f0102d4b:	f0 
f0102d4c:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102d53:	f0 
f0102d54:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f0102d5b:	00 
f0102d5c:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102d63:	e8 75 d3 ff ff       	call   f01000dd <_panic>
	assert(pp2->pp_ref == 1);
f0102d68:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d6d:	74 24                	je     f0102d93 <mem_init+0x1a86>
f0102d6f:	c7 44 24 0c 89 61 10 	movl   $0xf0106189,0xc(%esp)
f0102d76:	f0 
f0102d77:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102d7e:	f0 
f0102d7f:	c7 44 24 04 ab 04 00 	movl   $0x4ab,0x4(%esp)
f0102d86:	00 
f0102d87:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102d8e:	e8 4a d3 ff ff       	call   f01000dd <_panic>
	assert(pp1->pp_ref == 0);
f0102d93:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d98:	74 24                	je     f0102dbe <mem_init+0x1ab1>
f0102d9a:	c7 44 24 0c d2 61 10 	movl   $0xf01061d2,0xc(%esp)
f0102da1:	f0 
f0102da2:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102da9:	f0 
f0102daa:	c7 44 24 04 ac 04 00 	movl   $0x4ac,0x4(%esp)
f0102db1:	00 
f0102db2:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102db9:	e8 1f d3 ff ff       	call   f01000dd <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102dbe:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102dc5:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102dc8:	89 d8                	mov    %ebx,%eax
f0102dca:	2b 05 ac f1 20 f0    	sub    0xf020f1ac,%eax
f0102dd0:	c1 f8 03             	sar    $0x3,%eax
f0102dd3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dd6:	89 c2                	mov    %eax,%edx
f0102dd8:	c1 ea 0c             	shr    $0xc,%edx
f0102ddb:	3b 15 a4 f1 20 f0    	cmp    0xf020f1a4,%edx
f0102de1:	72 20                	jb     f0102e03 <mem_init+0x1af6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102de7:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f0102dee:	f0 
f0102def:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102df6:	00 
f0102df7:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0102dfe:	e8 da d2 ff ff       	call   f01000dd <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e03:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e0a:	03 03 03 
f0102e0d:	74 24                	je     f0102e33 <mem_init+0x1b26>
f0102e0f:	c7 44 24 0c 0c 5f 10 	movl   $0xf0105f0c,0xc(%esp)
f0102e16:	f0 
f0102e17:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102e1e:	f0 
f0102e1f:	c7 44 24 04 ae 04 00 	movl   $0x4ae,0x4(%esp)
f0102e26:	00 
f0102e27:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102e2e:	e8 aa d2 ff ff       	call   f01000dd <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e33:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102e3a:	00 
f0102e3b:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102e40:	89 04 24             	mov    %eax,(%esp)
f0102e43:	e8 df e3 ff ff       	call   f0101227 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e48:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e4d:	74 24                	je     f0102e73 <mem_init+0x1b66>
f0102e4f:	c7 44 24 0c c1 61 10 	movl   $0xf01061c1,0xc(%esp)
f0102e56:	f0 
f0102e57:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102e5e:	f0 
f0102e5f:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f0102e66:	00 
f0102e67:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102e6e:	e8 6a d2 ff ff       	call   f01000dd <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e73:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
f0102e78:	8b 08                	mov    (%eax),%ecx
f0102e7a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e80:	89 f2                	mov    %esi,%edx
f0102e82:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f0102e88:	c1 fa 03             	sar    $0x3,%edx
f0102e8b:	c1 e2 0c             	shl    $0xc,%edx
f0102e8e:	39 d1                	cmp    %edx,%ecx
f0102e90:	74 24                	je     f0102eb6 <mem_init+0x1ba9>
f0102e92:	c7 44 24 0c 5c 5a 10 	movl   $0xf0105a5c,0xc(%esp)
f0102e99:	f0 
f0102e9a:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102ea1:	f0 
f0102ea2:	c7 44 24 04 b3 04 00 	movl   $0x4b3,0x4(%esp)
f0102ea9:	00 
f0102eaa:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102eb1:	e8 27 d2 ff ff       	call   f01000dd <_panic>
	kern_pgdir[0] = 0;
f0102eb6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102ebc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ec1:	74 24                	je     f0102ee7 <mem_init+0x1bda>
f0102ec3:	c7 44 24 0c 78 61 10 	movl   $0xf0106178,0xc(%esp)
f0102eca:	f0 
f0102ecb:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0102ed2:	f0 
f0102ed3:	c7 44 24 04 b5 04 00 	movl   $0x4b5,0x4(%esp)
f0102eda:	00 
f0102edb:	c7 04 24 99 5f 10 f0 	movl   $0xf0105f99,(%esp)
f0102ee2:	e8 f6 d1 ff ff       	call   f01000dd <_panic>
	pp0->pp_ref = 0;
f0102ee7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102eed:	89 34 24             	mov    %esi,(%esp)
f0102ef0:	e8 f6 e0 ff ff       	call   f0100feb <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ef5:	c7 04 24 38 5f 10 f0 	movl   $0xf0105f38,(%esp)
f0102efc:	e8 8f 08 00 00       	call   f0103790 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f01:	83 c4 3c             	add    $0x3c,%esp
f0102f04:	5b                   	pop    %ebx
f0102f05:	5e                   	pop    %esi
f0102f06:	5f                   	pop    %edi
f0102f07:	5d                   	pop    %ebp
f0102f08:	c3                   	ret    
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102f09:	89 f2                	mov    %esi,%edx
f0102f0b:	89 d8                	mov    %ebx,%eax
f0102f0d:	e8 89 da ff ff       	call   f010099b <check_va2pa>
f0102f12:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f18:	e9 90 fa ff ff       	jmp    f01029ad <mem_init+0x16a0>

f0102f1d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f1d:	55                   	push   %ebp
f0102f1e:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102f20:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f25:	5d                   	pop    %ebp
f0102f26:	c3                   	ret    

f0102f27 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f27:	55                   	push   %ebp
f0102f28:	89 e5                	mov    %esp,%ebp
f0102f2a:	53                   	push   %ebx
f0102f2b:	83 ec 14             	sub    $0x14,%esp
f0102f2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f31:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f34:	83 c8 04             	or     $0x4,%eax
f0102f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f3b:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f3e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f49:	89 1c 24             	mov    %ebx,(%esp)
f0102f4c:	e8 cc ff ff ff       	call   f0102f1d <user_mem_check>
f0102f51:	85 c0                	test   %eax,%eax
f0102f53:	79 23                	jns    f0102f78 <user_mem_assert+0x51>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f5c:	00 
f0102f5d:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f64:	c7 04 24 64 5f 10 f0 	movl   $0xf0105f64,(%esp)
f0102f6b:	e8 20 08 00 00       	call   f0103790 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f70:	89 1c 24             	mov    %ebx,(%esp)
f0102f73:	e8 b2 06 00 00       	call   f010362a <env_destroy>
	}
}
f0102f78:	83 c4 14             	add    $0x14,%esp
f0102f7b:	5b                   	pop    %ebx
f0102f7c:	5d                   	pop    %ebp
f0102f7d:	c3                   	ret    
	...

f0102f80 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f80:	55                   	push   %ebp
f0102f81:	89 e5                	mov    %esp,%ebp
f0102f83:	53                   	push   %ebx
f0102f84:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f8a:	85 c0                	test   %eax,%eax
f0102f8c:	75 0e                	jne    f0102f9c <envid2env+0x1c>
		*env_store = curenv;
f0102f8e:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0102f93:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f95:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f9a:	eb 5a                	jmp    f0102ff6 <envid2env+0x76>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f9c:	89 c2                	mov    %eax,%edx
f0102f9e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102fa4:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0102fa7:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0102faa:	c1 e2 02             	shl    $0x2,%edx
f0102fad:	03 15 0c e5 20 f0    	add    0xf020e50c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fb3:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102fb7:	74 05                	je     f0102fbe <envid2env+0x3e>
f0102fb9:	39 42 48             	cmp    %eax,0x48(%edx)
f0102fbc:	74 0d                	je     f0102fcb <envid2env+0x4b>
		*env_store = 0;
f0102fbe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102fc4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fc9:	eb 2b                	jmp    f0102ff6 <envid2env+0x76>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fcb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102fcf:	74 1e                	je     f0102fef <envid2env+0x6f>
f0102fd1:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0102fd6:	39 c2                	cmp    %eax,%edx
f0102fd8:	74 15                	je     f0102fef <envid2env+0x6f>
f0102fda:	8b 58 48             	mov    0x48(%eax),%ebx
f0102fdd:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102fe0:	74 0d                	je     f0102fef <envid2env+0x6f>
		*env_store = 0;
f0102fe2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102fe8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fed:	eb 07                	jmp    f0102ff6 <envid2env+0x76>
	}

	*env_store = e;
f0102fef:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102ff1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ff6:	5b                   	pop    %ebx
f0102ff7:	5d                   	pop    %ebp
f0102ff8:	c3                   	ret    

f0102ff9 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ff9:	55                   	push   %ebp
f0102ffa:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ffc:	b8 00 43 12 f0       	mov    $0xf0124300,%eax
f0103001:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103004:	b8 23 00 00 00       	mov    $0x23,%eax
f0103009:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010300b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010300d:	b0 10                	mov    $0x10,%al
f010300f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103011:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103013:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103015:	ea 1c 30 10 f0 08 00 	ljmp   $0x8,$0xf010301c
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010301c:	b0 00                	mov    $0x0,%al
f010301e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103021:	5d                   	pop    %ebp
f0103022:	c3                   	ret    

f0103023 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103023:	55                   	push   %ebp
f0103024:	89 e5                	mov    %esp,%ebp
f0103026:	56                   	push   %esi
f0103027:	53                   	push   %ebx
f0103028:	83 ec 10             	sub    $0x10,%esp
	// Set up envs array
	// LAB 3: Your code here.
	int i=NENV-1;

	cprintf("before loop!!!!!!!!!!!!!!!!!!!!!!! %d\n", i);               ////////////////////////////////////////////////////////
f010302b:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0103032:	00 
f0103033:	c7 04 24 74 62 10 f0 	movl   $0xf0106274,(%esp)
f010303a:	e8 51 07 00 00       	call   f0103790 <cprintf>
	for(; i>=0; --i){

		// cprintf("inside env_init-------------%d\n", i);               ////////////////////////////////////////////////////////
		//cprintf("inside env_init loop!\n");               ////////////////////////////////////////////////////////
		// envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
f010303f:	8b 35 0c e5 20 f0    	mov    0xf020e50c,%esi
f0103045:	8b 0d 10 e5 20 f0    	mov    0xf020e510,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010304b:	8d 86 9c 8f 01 00    	lea    0x18f9c(%esi),%eax
f0103051:	ba 00 04 00 00       	mov    $0x400,%edx
f0103056:	eb 02                	jmp    f010305a <env_init+0x37>

		// cprintf("inside env_init-------------%d\n", i);               ////////////////////////////////////////////////////////
		//cprintf("inside env_init loop!\n");               ////////////////////////////////////////////////////////
		// envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103058:	89 d9                	mov    %ebx,%ecx
	for(; i>=0; --i){

		// cprintf("inside env_init-------------%d\n", i);               ////////////////////////////////////////////////////////
		//cprintf("inside env_init loop!\n");               ////////////////////////////////////////////////////////
		// envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
f010305a:	89 c3                	mov    %eax,%ebx
f010305c:	89 48 44             	mov    %ecx,0x44(%eax)
f010305f:	83 e8 64             	sub    $0x64,%eax
	// Set up envs array
	// LAB 3: Your code here.
	int i=NENV-1;

	cprintf("before loop!!!!!!!!!!!!!!!!!!!!!!! %d\n", i);               ////////////////////////////////////////////////////////
	for(; i>=0; --i){
f0103062:	4a                   	dec    %edx
f0103063:	75 f3                	jne    f0103058 <env_init+0x35>
f0103065:	89 35 10 e5 20 f0    	mov    %esi,0xf020e510
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	
	cprintf("before env_percpu................!\n");               ////////////////////////////////////////////////////////
f010306b:	c7 04 24 9c 62 10 f0 	movl   $0xf010629c,(%esp)
f0103072:	e8 19 07 00 00       	call   f0103790 <cprintf>
	env_init_percpu();
f0103077:	e8 7d ff ff ff       	call   f0102ff9 <env_init_percpu>
	
	cprintf("inside env_init!\n");               ////////////////////////////////////////////////////////
f010307c:	c7 04 24 45 63 10 f0 	movl   $0xf0106345,(%esp)
f0103083:	e8 08 07 00 00       	call   f0103790 <cprintf>

}
f0103088:	83 c4 10             	add    $0x10,%esp
f010308b:	5b                   	pop    %ebx
f010308c:	5e                   	pop    %esi
f010308d:	5d                   	pop    %ebp
f010308e:	c3                   	ret    

f010308f <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010308f:	55                   	push   %ebp
f0103090:	89 e5                	mov    %esp,%ebp
f0103092:	56                   	push   %esi
f0103093:	53                   	push   %ebx
f0103094:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103097:	8b 1d 10 e5 20 f0    	mov    0xf020e510,%ebx
f010309d:	85 db                	test   %ebx,%ebx
f010309f:	0f 84 94 01 00 00    	je     f0103239 <env_alloc+0x1aa>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01030ac:	e8 a2 de ff ff       	call   f0100f53 <page_alloc>
f01030b1:	85 c0                	test   %eax,%eax
f01030b3:	0f 84 87 01 00 00    	je     f0103240 <env_alloc+0x1b1>
f01030b9:	89 c2                	mov    %eax,%edx
f01030bb:	2b 15 ac f1 20 f0    	sub    0xf020f1ac,%edx
f01030c1:	c1 fa 03             	sar    $0x3,%edx
f01030c4:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030c7:	89 d1                	mov    %edx,%ecx
f01030c9:	c1 e9 0c             	shr    $0xc,%ecx
f01030cc:	3b 0d a4 f1 20 f0    	cmp    0xf020f1a4,%ecx
f01030d2:	72 20                	jb     f01030f4 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01030d8:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01030df:	f0 
f01030e0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01030e7:	00 
f01030e8:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f01030ef:	e8 e9 cf ff ff       	call   f01000dd <_panic>
	return (void *)(pa + KERNBASE);
f01030f4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01030fa:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
	p->pp_ref++;
f01030fd:	66 ff 40 04          	incw   0x4(%eax)
f0103101:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	for(i=PDX(UTOP); i<NPDENTRIES; i++){
		e->env_pgdir[i] = kern_pgdir[i];
f0103106:	8b 15 a8 f1 20 f0    	mov    0xf020f1a8,%edx
f010310c:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010310f:	8b 53 60             	mov    0x60(%ebx),%edx
f0103112:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103115:	83 c0 04             	add    $0x4,%eax
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
	p->pp_ref++;
	for(i=PDX(UTOP); i<NPDENTRIES; i++){
f0103118:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010311d:	75 e7                	jne    f0103106 <env_alloc+0x77>
	}


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010311f:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103122:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103127:	77 20                	ja     f0103149 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103129:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010312d:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0103134:	f0 
f0103135:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f010313c:	00 
f010313d:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f0103144:	e8 94 cf ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103149:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010314f:	83 ca 05             	or     $0x5,%edx
f0103152:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103158:	8b 43 48             	mov    0x48(%ebx),%eax
f010315b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103160:	89 c1                	mov    %eax,%ecx
f0103162:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103168:	7f 05                	jg     f010316f <env_alloc+0xe0>
		generation = 1 << ENVGENSHIFT;
f010316a:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010316f:	89 d8                	mov    %ebx,%eax
f0103171:	2b 05 0c e5 20 f0    	sub    0xf020e50c,%eax
f0103177:	c1 f8 02             	sar    $0x2,%eax
f010317a:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010317d:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0103180:	89 d6                	mov    %edx,%esi
f0103182:	c1 e6 0a             	shl    $0xa,%esi
f0103185:	29 d6                	sub    %edx,%esi
f0103187:	89 f2                	mov    %esi,%edx
f0103189:	c1 e2 05             	shl    $0x5,%edx
f010318c:	01 c2                	add    %eax,%edx
f010318e:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103191:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0103194:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
f010319b:	29 d6                	sub    %edx,%esi
f010319d:	89 f2                	mov    %esi,%edx
f010319f:	c1 e2 03             	shl    $0x3,%edx
f01031a2:	29 d0                	sub    %edx,%eax
f01031a4:	09 c1                	or     %eax,%ecx
f01031a6:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031ac:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031af:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031b6:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f01031bd:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031c4:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01031cb:	00 
f01031cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01031d3:	00 
f01031d4:	89 1c 24             	mov    %ebx,(%esp)
f01031d7:	e8 eb 1b 00 00       	call   f0104dc7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031dc:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031e2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031e8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031ee:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031f5:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01031fb:	8b 43 44             	mov    0x44(%ebx),%eax
f01031fe:	a3 10 e5 20 f0       	mov    %eax,0xf020e510
	*newenv_store = e;
f0103203:	8b 45 08             	mov    0x8(%ebp),%eax
f0103206:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103208:	8b 53 48             	mov    0x48(%ebx),%edx
f010320b:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103210:	85 c0                	test   %eax,%eax
f0103212:	74 05                	je     f0103219 <env_alloc+0x18a>
f0103214:	8b 40 48             	mov    0x48(%eax),%eax
f0103217:	eb 05                	jmp    f010321e <env_alloc+0x18f>
f0103219:	b8 00 00 00 00       	mov    $0x0,%eax
f010321e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103222:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103226:	c7 04 24 62 63 10 f0 	movl   $0xf0106362,(%esp)
f010322d:	e8 5e 05 00 00       	call   f0103790 <cprintf>
	return 0;
f0103232:	b8 00 00 00 00       	mov    $0x0,%eax
f0103237:	eb 0c                	jmp    f0103245 <env_alloc+0x1b6>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103239:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010323e:	eb 05                	jmp    f0103245 <env_alloc+0x1b6>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103240:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103245:	83 c4 10             	add    $0x10,%esp
f0103248:	5b                   	pop    %ebx
f0103249:	5e                   	pop    %esi
f010324a:	5d                   	pop    %ebp
f010324b:	c3                   	ret    

f010324c <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
void
region_alloc(struct Env *e, void *va, size_t len)
{
f010324c:	55                   	push   %ebp
f010324d:	89 e5                	mov    %esp,%ebp
f010324f:	57                   	push   %edi
f0103250:	56                   	push   %esi
f0103251:	53                   	push   %ebx
f0103252:	83 ec 1c             	sub    $0x1c,%esp
f0103255:	8b 75 08             	mov    0x8(%ebp),%esi
f0103258:	8b 45 0c             	mov    0xc(%ebp),%eax
//		// boot_map_region(e->env_pgdir, va, PGSIZE, page2pa(p), PTE_P|PTE_U|PTE_W);
//		page_insert(e->env_pgdir, p, va, PTE_W | PTE_U);
//		va += PGSIZE;
//	}
//	
	uintptr_t  va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f010325b:	89 c3                	mov    %eax,%ebx
f010325d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t  va_end = ROUNDUP((uintptr_t)(va)+len, PGSIZE);
f0103263:	89 c7                	mov    %eax,%edi
f0103265:	03 7d 10             	add    0x10(%ebp),%edi
f0103268:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f010326e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	uintptr_t i;
	for(i=va_start; i<va_end; i+=PGSIZE){
f0103274:	39 fb                	cmp    %edi,%ebx
f0103276:	73 51                	jae    f01032c9 <region_alloc+0x7d>
		struct Page* pg = page_alloc(0);
f0103278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010327f:	e8 cf dc ff ff       	call   f0100f53 <page_alloc>
		if(!pg)
f0103284:	85 c0                	test   %eax,%eax
f0103286:	75 1c                	jne    f01032a4 <region_alloc+0x58>
		  panic("region_alloc failed!\n");
f0103288:	c7 44 24 08 77 63 10 	movl   $0xf0106377,0x8(%esp)
f010328f:	f0 
f0103290:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f0103297:	00 
f0103298:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f010329f:	e8 39 ce ff ff       	call   f01000dd <_panic>
		page_insert(e->env_pgdir, pg, (void *)i, PTE_W | PTE_U | PTE_P);
f01032a4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01032ab:	00 
f01032ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01032b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032b4:	8b 46 60             	mov    0x60(%esi),%eax
f01032b7:	89 04 24             	mov    %eax,(%esp)
f01032ba:	e8 b1 df ff ff       	call   f0101270 <page_insert>
//	}
//	
	uintptr_t  va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t  va_end = ROUNDUP((uintptr_t)(va)+len, PGSIZE);
	uintptr_t i;
	for(i=va_start; i<va_end; i+=PGSIZE){
f01032bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032c5:	39 df                	cmp    %ebx,%edi
f01032c7:	77 af                	ja     f0103278 <region_alloc+0x2c>
//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f01032c9:	83 c4 1c             	add    $0x1c,%esp
f01032cc:	5b                   	pop    %ebx
f01032cd:	5e                   	pop    %esi
f01032ce:	5f                   	pop    %edi
f01032cf:	5d                   	pop    %ebp
f01032d0:	c3                   	ret    

f01032d1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f01032d1:	55                   	push   %ebp
f01032d2:	89 e5                	mov    %esp,%ebp
f01032d4:	57                   	push   %edi
f01032d5:	56                   	push   %esi
f01032d6:	53                   	push   %ebx
f01032d7:	83 ec 3c             	sub    $0x3c,%esp
f01032da:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int ret = env_alloc(&e, 0);
f01032dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01032e4:	00 
f01032e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032e8:	89 04 24             	mov    %eax,(%esp)
f01032eb:	e8 9f fd ff ff       	call   f010308f <env_alloc>
	if(ret<0)
f01032f0:	85 c0                	test   %eax,%eax
f01032f2:	79 20                	jns    f0103314 <env_create+0x43>
	  panic("env_create: %e", ret);
f01032f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032f8:	c7 44 24 08 8d 63 10 	movl   $0xf010638d,0x8(%esp)
f01032ff:	f0 
f0103300:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
f0103307:	00 
f0103308:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f010330f:	e8 c9 cd ff ff       	call   f01000dd <_panic>
	e->env_type =  type;
f0103314:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103317:	8b 45 10             	mov    0x10(%ebp),%eax
f010331a:	89 46 50             	mov    %eax,0x50(%esi)
	// LAB 3: Your code here.
	
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f010331d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103323:	74 1c                	je     f0103341 <env_create+0x70>
	  panic("load_icode failed! invalid ELF!\n");
f0103325:	c7 44 24 08 c0 62 10 	movl   $0xf01062c0,0x8(%esp)
f010332c:	f0 
f010332d:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f0103334:	00 
f0103335:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f010333c:	e8 9c cd ff ff       	call   f01000dd <_panic>

	ph = (struct Proghdr *)((uint8_t *)elf+elf->e_phoff);
f0103341:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0103344:	8b 57 2c             	mov    0x2c(%edi),%edx

	lcr3(PADDR(e->env_pgdir));
f0103347:	8b 46 60             	mov    0x60(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010334a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010334f:	77 20                	ja     f0103371 <env_create+0xa0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103351:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103355:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f010335c:	f0 
f010335d:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
f0103364:	00 
f0103365:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f010336c:	e8 6c cd ff ff       	call   f01000dd <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
	  panic("load_icode failed! invalid ELF!\n");

	ph = (struct Proghdr *)((uint8_t *)elf+elf->e_phoff);
f0103371:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f0103373:	0f b7 d2             	movzwl %dx,%edx
f0103376:	c1 e2 05             	shl    $0x5,%edx
f0103379:	01 da                	add    %ebx,%edx
f010337b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010337e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103383:	0f 22 d8             	mov    %eax,%cr3

	lcr3(PADDR(e->env_pgdir));
	for(; ph<eph; ph++){
f0103386:	39 d3                	cmp    %edx,%ebx
f0103388:	73 58                	jae    f01033e2 <env_create+0x111>
		if(ph->p_type==ELF_PROG_LOAD){
f010338a:	83 3b 01             	cmpl   $0x1,(%ebx)
f010338d:	75 4b                	jne    f01033da <env_create+0x109>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010338f:	8b 43 14             	mov    0x14(%ebx),%eax
f0103392:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103396:	8b 43 08             	mov    0x8(%ebx),%eax
f0103399:	89 44 24 04          	mov    %eax,0x4(%esp)
f010339d:	89 34 24             	mov    %esi,(%esp)
f01033a0:	e8 a7 fe ff ff       	call   f010324c <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f01033a5:	8b 43 14             	mov    0x14(%ebx),%eax
f01033a8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01033b3:	00 
f01033b4:	8b 43 08             	mov    0x8(%ebx),%eax
f01033b7:	89 04 24             	mov    %eax,(%esp)
f01033ba:	e8 08 1a 00 00       	call   f0104dc7 <memset>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01033bf:	8b 43 10             	mov    0x10(%ebx),%eax
f01033c2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033c6:	89 f8                	mov    %edi,%eax
f01033c8:	03 43 04             	add    0x4(%ebx),%eax
f01033cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033cf:	8b 43 08             	mov    0x8(%ebx),%eax
f01033d2:	89 04 24             	mov    %eax,(%esp)
f01033d5:	e8 37 1a 00 00       	call   f0104e11 <memmove>

	ph = (struct Proghdr *)((uint8_t *)elf+elf->e_phoff);
	eph = ph + elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for(; ph<eph; ph++){
f01033da:	83 c3 20             	add    $0x20,%ebx
f01033dd:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01033e0:	77 a8                	ja     f010338a <env_create+0xb9>
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
	}

	lcr3(PADDR(kern_pgdir));
f01033e2:	a1 a8 f1 20 f0       	mov    0xf020f1a8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033ec:	77 20                	ja     f010340e <env_create+0x13d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033f2:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f01033f9:	f0 
f01033fa:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0103401:	00 
f0103402:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f0103409:	e8 cf cc ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f010340e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103413:	0f 22 d8             	mov    %eax,%cr3

	// set entry
	e->env_tf.tf_eip = elf->e_entry;
f0103416:	8b 47 18             	mov    0x18(%edi),%eax
f0103419:	89 46 30             	mov    %eax,0x30(%esi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f010341c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103423:	00 
f0103424:	c7 44 24 04 00 d0 bf 	movl   $0xeebfd000,0x4(%esp)
f010342b:	ee 
f010342c:	89 34 24             	mov    %esi,(%esp)
f010342f:	e8 18 fe ff ff       	call   f010324c <region_alloc>
	e->env_heap_bottom = (uintptr_t)ROUNDDOWN(USTACKTOP-PGSIZE, PGSIZE);
f0103434:	c7 46 5c 00 d0 bf ee 	movl   $0xeebfd000,0x5c(%esi)
	int ret = env_alloc(&e, 0);
	if(ret<0)
	  panic("env_create: %e", ret);
	e->env_type =  type;
	load_icode(e, binary, size);
}
f010343b:	83 c4 3c             	add    $0x3c,%esp
f010343e:	5b                   	pop    %ebx
f010343f:	5e                   	pop    %esi
f0103440:	5f                   	pop    %edi
f0103441:	5d                   	pop    %ebp
f0103442:	c3                   	ret    

f0103443 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103443:	55                   	push   %ebp
f0103444:	89 e5                	mov    %esp,%ebp
f0103446:	57                   	push   %edi
f0103447:	56                   	push   %esi
f0103448:	53                   	push   %ebx
f0103449:	83 ec 2c             	sub    $0x2c,%esp
f010344c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010344f:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103454:	39 c7                	cmp    %eax,%edi
f0103456:	75 37                	jne    f010348f <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103458:	8b 15 a8 f1 20 f0    	mov    0xf020f1a8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010345e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103464:	77 20                	ja     f0103486 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103466:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010346a:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0103471:	f0 
f0103472:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
f0103479:	00 
f010347a:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f0103481:	e8 57 cc ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103486:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010348c:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010348f:	8b 57 48             	mov    0x48(%edi),%edx
f0103492:	85 c0                	test   %eax,%eax
f0103494:	74 05                	je     f010349b <env_free+0x58>
f0103496:	8b 40 48             	mov    0x48(%eax),%eax
f0103499:	eb 05                	jmp    f01034a0 <env_free+0x5d>
f010349b:	b8 00 00 00 00       	mov    $0x0,%eax
f01034a0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034a8:	c7 04 24 9c 63 10 f0 	movl   $0xf010639c,(%esp)
f01034af:	e8 dc 02 00 00       	call   f0103790 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034b4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034be:	c1 e0 02             	shl    $0x2,%eax
f01034c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01034c4:	8b 47 60             	mov    0x60(%edi),%eax
f01034c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034ca:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01034cd:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01034d3:	0f 84 b6 00 00 00    	je     f010358f <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034d9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034df:	89 f0                	mov    %esi,%eax
f01034e1:	c1 e8 0c             	shr    $0xc,%eax
f01034e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034e7:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f01034ed:	72 20                	jb     f010350f <env_free+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01034f3:	c7 44 24 08 1c 58 10 	movl   $0xf010581c,0x8(%esp)
f01034fa:	f0 
f01034fb:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f0103502:	00 
f0103503:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f010350a:	e8 ce cb ff ff       	call   f01000dd <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010350f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103512:	c1 e2 16             	shl    $0x16,%edx
f0103515:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103518:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010351d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103524:	01 
f0103525:	74 17                	je     f010353e <env_free+0xfb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103527:	89 d8                	mov    %ebx,%eax
f0103529:	c1 e0 0c             	shl    $0xc,%eax
f010352c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010352f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103533:	8b 47 60             	mov    0x60(%edi),%eax
f0103536:	89 04 24             	mov    %eax,(%esp)
f0103539:	e8 e9 dc ff ff       	call   f0101227 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010353e:	43                   	inc    %ebx
f010353f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103545:	75 d6                	jne    f010351d <env_free+0xda>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103547:	8b 47 60             	mov    0x60(%edi),%eax
f010354a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010354d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103554:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103557:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f010355d:	72 1c                	jb     f010357b <env_free+0x138>
		panic("pa2page called with invalid pa");
f010355f:	c7 44 24 08 28 59 10 	movl   $0xf0105928,0x8(%esp)
f0103566:	f0 
f0103567:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010356e:	00 
f010356f:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0103576:	e8 62 cb ff ff       	call   f01000dd <_panic>
	return &pages[PGNUM(pa)];
f010357b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010357e:	c1 e0 03             	shl    $0x3,%eax
f0103581:	03 05 ac f1 20 f0    	add    0xf020f1ac,%eax
		page_decref(pa2page(pa));
f0103587:	89 04 24             	mov    %eax,(%esp)
f010358a:	e8 88 da ff ff       	call   f0101017 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010358f:	ff 45 e0             	incl   -0x20(%ebp)
f0103592:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103599:	0f 85 1c ff ff ff    	jne    f01034bb <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010359f:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a7:	77 20                	ja     f01035c9 <env_free+0x186>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ad:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f01035b4:	f0 
f01035b5:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f01035bc:	00 
f01035bd:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f01035c4:	e8 14 cb ff ff       	call   f01000dd <_panic>
	e->env_pgdir = 0;
f01035c9:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01035d0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035d5:	c1 e8 0c             	shr    $0xc,%eax
f01035d8:	3b 05 a4 f1 20 f0    	cmp    0xf020f1a4,%eax
f01035de:	72 1c                	jb     f01035fc <env_free+0x1b9>
		panic("pa2page called with invalid pa");
f01035e0:	c7 44 24 08 28 59 10 	movl   $0xf0105928,0x8(%esp)
f01035e7:	f0 
f01035e8:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01035ef:	00 
f01035f0:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f01035f7:	e8 e1 ca ff ff       	call   f01000dd <_panic>
	return &pages[PGNUM(pa)];
f01035fc:	c1 e0 03             	shl    $0x3,%eax
f01035ff:	03 05 ac f1 20 f0    	add    0xf020f1ac,%eax
	page_decref(pa2page(pa));
f0103605:	89 04 24             	mov    %eax,(%esp)
f0103608:	e8 0a da ff ff       	call   f0101017 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010360d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103614:	a1 10 e5 20 f0       	mov    0xf020e510,%eax
f0103619:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010361c:	89 3d 10 e5 20 f0    	mov    %edi,0xf020e510
}
f0103622:	83 c4 2c             	add    $0x2c,%esp
f0103625:	5b                   	pop    %ebx
f0103626:	5e                   	pop    %esi
f0103627:	5f                   	pop    %edi
f0103628:	5d                   	pop    %ebp
f0103629:	c3                   	ret    

f010362a <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010362a:	55                   	push   %ebp
f010362b:	89 e5                	mov    %esp,%ebp
f010362d:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103630:	8b 45 08             	mov    0x8(%ebp),%eax
f0103633:	89 04 24             	mov    %eax,(%esp)
f0103636:	e8 08 fe ff ff       	call   f0103443 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010363b:	c7 04 24 e4 62 10 f0 	movl   $0xf01062e4,(%esp)
f0103642:	e8 49 01 00 00       	call   f0103790 <cprintf>
	while (1)
		monitor(NULL);
f0103647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010364e:	e8 dc d1 ff ff       	call   f010082f <monitor>
f0103653:	eb f2                	jmp    f0103647 <env_destroy+0x1d>

f0103655 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103655:	55                   	push   %ebp
f0103656:	89 e5                	mov    %esp,%ebp
f0103658:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f010365b:	8b 65 08             	mov    0x8(%ebp),%esp
f010365e:	61                   	popa   
f010365f:	07                   	pop    %es
f0103660:	1f                   	pop    %ds
f0103661:	83 c4 08             	add    $0x8,%esp
f0103664:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103665:	c7 44 24 08 b2 63 10 	movl   $0xf01063b2,0x8(%esp)
f010366c:	f0 
f010366d:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
f0103674:	00 
f0103675:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f010367c:	e8 5c ca ff ff       	call   f01000dd <_panic>

f0103681 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103681:	55                   	push   %ebp
f0103682:	89 e5                	mov    %esp,%ebp
f0103684:	83 ec 18             	sub    $0x18,%esp
f0103687:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.


	if(curenv != e){
f010368a:	8b 15 08 e5 20 f0    	mov    0xf020e508,%edx
f0103690:	39 c2                	cmp    %eax,%edx
f0103692:	74 6b                	je     f01036ff <env_run+0x7e>
		if(curenv && curenv->env_status == ENV_RUNNING)
f0103694:	85 d2                	test   %edx,%edx
f0103696:	74 0d                	je     f01036a5 <env_run+0x24>
f0103698:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f010369c:	75 07                	jne    f01036a5 <env_run+0x24>
		  curenv->env_status = ENV_RUNNABLE;
f010369e:	c7 42 54 01 00 00 00 	movl   $0x1,0x54(%edx)
		curenv = e;
f01036a5:	a3 08 e5 20 f0       	mov    %eax,0xf020e508
		curenv->env_status = ENV_RUNNING;
f01036aa:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv->env_runs++;
f01036b1:	ff 40 58             	incl   0x58(%eax)
		cprintf("curenv= %x, e= %x\n......................", curenv, e);		
f01036b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036bc:	c7 04 24 1c 63 10 f0 	movl   $0xf010631c,(%esp)
f01036c3:	e8 c8 00 00 00       	call   f0103790 <cprintf>
		lcr3(PADDR(curenv->env_pgdir));
f01036c8:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f01036cd:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036d5:	77 20                	ja     f01036f7 <env_run+0x76>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036db:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f01036e2:	f0 
f01036e3:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
f01036ea:	00 
f01036eb:	c7 04 24 57 63 10 f0 	movl   $0xf0106357,(%esp)
f01036f2:	e8 e6 c9 ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036f7:	05 00 00 00 10       	add    $0x10000000,%eax
f01036fc:	0f 22 d8             	mov    %eax,%cr3
	}
	cprintf("hello before context switch!\n");
f01036ff:	c7 04 24 be 63 10 f0 	movl   $0xf01063be,(%esp)
f0103706:	e8 85 00 00 00       	call   f0103790 <cprintf>
	env_pop_tf(&curenv->env_tf);
f010370b:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103710:	89 04 24             	mov    %eax,(%esp)
f0103713:	e8 3d ff ff ff       	call   f0103655 <env_pop_tf>

f0103718 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103718:	55                   	push   %ebp
f0103719:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010371b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103720:	8b 45 08             	mov    0x8(%ebp),%eax
f0103723:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103724:	b2 71                	mov    $0x71,%dl
f0103726:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103727:	0f b6 c0             	movzbl %al,%eax
}
f010372a:	5d                   	pop    %ebp
f010372b:	c3                   	ret    

f010372c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010372c:	55                   	push   %ebp
f010372d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010372f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103734:	8b 45 08             	mov    0x8(%ebp),%eax
f0103737:	ee                   	out    %al,(%dx)
f0103738:	b2 71                	mov    $0x71,%dl
f010373a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010373d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010373e:	5d                   	pop    %ebp
f010373f:	c3                   	ret    

f0103740 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103740:	55                   	push   %ebp
f0103741:	89 e5                	mov    %esp,%ebp
f0103743:	53                   	push   %ebx
f0103744:	83 ec 14             	sub    $0x14,%esp
f0103747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f010374a:	8b 45 08             	mov    0x8(%ebp),%eax
f010374d:	89 04 24             	mov    %eax,(%esp)
f0103750:	e8 a3 ce ff ff       	call   f01005f8 <cputchar>
    (*cnt)++;
f0103755:	ff 03                	incl   (%ebx)
}
f0103757:	83 c4 14             	add    $0x14,%esp
f010375a:	5b                   	pop    %ebx
f010375b:	5d                   	pop    %ebp
f010375c:	c3                   	ret    

f010375d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010375d:	55                   	push   %ebp
f010375e:	89 e5                	mov    %esp,%ebp
f0103760:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103763:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010376a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010376d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103771:	8b 45 08             	mov    0x8(%ebp),%eax
f0103774:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103778:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010377b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010377f:	c7 04 24 40 37 10 f0 	movl   $0xf0103740,(%esp)
f0103786:	e8 62 0f 00 00       	call   f01046ed <vprintfmt>
	return cnt;
}
f010378b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010378e:	c9                   	leave  
f010378f:	c3                   	ret    

f0103790 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103790:	55                   	push   %ebp
f0103791:	89 e5                	mov    %esp,%ebp
f0103793:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103796:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103799:	89 44 24 04          	mov    %eax,0x4(%esp)
f010379d:	8b 45 08             	mov    0x8(%ebp),%eax
f01037a0:	89 04 24             	mov    %eax,(%esp)
f01037a3:	e8 b5 ff ff ff       	call   f010375d <vcprintf>
	va_end(ap);

	return cnt;
}
f01037a8:	c9                   	leave  
f01037a9:	c3                   	ret    
	...

f01037ac <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01037ac:	55                   	push   %ebp
f01037ad:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01037af:	c7 05 24 ed 20 f0 00 	movl   $0xefc00000,0xf020ed24
f01037b6:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f01037b9:	66 c7 05 28 ed 20 f0 	movw   $0x10,0xf020ed28
f01037c0:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01037c2:	66 c7 05 48 43 12 f0 	movw   $0x68,0xf0124348
f01037c9:	68 00 
f01037cb:	b8 20 ed 20 f0       	mov    $0xf020ed20,%eax
f01037d0:	66 a3 4a 43 12 f0    	mov    %ax,0xf012434a
f01037d6:	89 c2                	mov    %eax,%edx
f01037d8:	c1 ea 10             	shr    $0x10,%edx
f01037db:	88 15 4c 43 12 f0    	mov    %dl,0xf012434c
f01037e1:	c6 05 4e 43 12 f0 40 	movb   $0x40,0xf012434e
f01037e8:	c1 e8 18             	shr    $0x18,%eax
f01037eb:	a2 4f 43 12 f0       	mov    %al,0xf012434f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01037f0:	c6 05 4d 43 12 f0 89 	movb   $0x89,0xf012434d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037f7:	b8 28 00 00 00       	mov    $0x28,%eax
f01037fc:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037ff:	b8 50 43 12 f0       	mov    $0xf0124350,%eax
f0103804:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103807:	5d                   	pop    %ebp
f0103808:	c3                   	ret    

f0103809 <trap_init>:
}


void
trap_init(void)
{
f0103809:	55                   	push   %ebp
f010380a:	89 e5                	mov    %esp,%ebp
f010380c:	83 ec 18             	sub    $0x18,%esp
	// SYSCALL
	extern void entry48();



	SETGATE(idt[T_DIVIDE], 0, GD_KT, entry0, 0);
f010380f:	b8 cc 3f 10 f0       	mov    $0xf0103fcc,%eax
f0103814:	66 a3 20 e5 20 f0    	mov    %ax,0xf020e520
f010381a:	66 c7 05 22 e5 20 f0 	movw   $0x8,0xf020e522
f0103821:	08 00 
f0103823:	c6 05 24 e5 20 f0 00 	movb   $0x0,0xf020e524
f010382a:	c6 05 25 e5 20 f0 8e 	movb   $0x8e,0xf020e525
f0103831:	c1 e8 10             	shr    $0x10,%eax
f0103834:	66 a3 26 e5 20 f0    	mov    %ax,0xf020e526
	SETGATE(idt[T_DEBUG], 0, GD_KT, entry1, 0);
f010383a:	b8 d2 3f 10 f0       	mov    $0xf0103fd2,%eax
f010383f:	66 a3 28 e5 20 f0    	mov    %ax,0xf020e528
f0103845:	66 c7 05 2a e5 20 f0 	movw   $0x8,0xf020e52a
f010384c:	08 00 
f010384e:	c6 05 2c e5 20 f0 00 	movb   $0x0,0xf020e52c
f0103855:	c6 05 2d e5 20 f0 8e 	movb   $0x8e,0xf020e52d
f010385c:	c1 e8 10             	shr    $0x10,%eax
f010385f:	66 a3 2e e5 20 f0    	mov    %ax,0xf020e52e
	SETGATE(idt[T_NMI], 0, GD_KT, entry2, 0);
f0103865:	b8 d8 3f 10 f0       	mov    $0xf0103fd8,%eax
f010386a:	66 a3 30 e5 20 f0    	mov    %ax,0xf020e530
f0103870:	66 c7 05 32 e5 20 f0 	movw   $0x8,0xf020e532
f0103877:	08 00 
f0103879:	c6 05 34 e5 20 f0 00 	movb   $0x0,0xf020e534
f0103880:	c6 05 35 e5 20 f0 8e 	movb   $0x8e,0xf020e535
f0103887:	c1 e8 10             	shr    $0x10,%eax
f010388a:	66 a3 36 e5 20 f0    	mov    %ax,0xf020e536
	SETGATE(idt[T_BRKPT], 0, GD_KT, entry3, 3);
f0103890:	b8 de 3f 10 f0       	mov    $0xf0103fde,%eax
f0103895:	66 a3 38 e5 20 f0    	mov    %ax,0xf020e538
f010389b:	66 c7 05 3a e5 20 f0 	movw   $0x8,0xf020e53a
f01038a2:	08 00 
f01038a4:	c6 05 3c e5 20 f0 00 	movb   $0x0,0xf020e53c
f01038ab:	c6 05 3d e5 20 f0 ee 	movb   $0xee,0xf020e53d
f01038b2:	c1 e8 10             	shr    $0x10,%eax
f01038b5:	66 a3 3e e5 20 f0    	mov    %ax,0xf020e53e
	SETGATE(idt[T_OFLOW], 0, GD_KT, entry4, 0);
f01038bb:	b8 e4 3f 10 f0       	mov    $0xf0103fe4,%eax
f01038c0:	66 a3 40 e5 20 f0    	mov    %ax,0xf020e540
f01038c6:	66 c7 05 42 e5 20 f0 	movw   $0x8,0xf020e542
f01038cd:	08 00 
f01038cf:	c6 05 44 e5 20 f0 00 	movb   $0x0,0xf020e544
f01038d6:	c6 05 45 e5 20 f0 8e 	movb   $0x8e,0xf020e545
f01038dd:	c1 e8 10             	shr    $0x10,%eax
f01038e0:	66 a3 46 e5 20 f0    	mov    %ax,0xf020e546
	SETGATE(idt[T_BOUND], 0, GD_KT, entry5, 0);
f01038e6:	b8 ea 3f 10 f0       	mov    $0xf0103fea,%eax
f01038eb:	66 a3 48 e5 20 f0    	mov    %ax,0xf020e548
f01038f1:	66 c7 05 4a e5 20 f0 	movw   $0x8,0xf020e54a
f01038f8:	08 00 
f01038fa:	c6 05 4c e5 20 f0 00 	movb   $0x0,0xf020e54c
f0103901:	c6 05 4d e5 20 f0 8e 	movb   $0x8e,0xf020e54d
f0103908:	c1 e8 10             	shr    $0x10,%eax
f010390b:	66 a3 4e e5 20 f0    	mov    %ax,0xf020e54e
	SETGATE(idt[T_ILLOP], 0, GD_KT, entry6, 0);
f0103911:	b8 f0 3f 10 f0       	mov    $0xf0103ff0,%eax
f0103916:	66 a3 50 e5 20 f0    	mov    %ax,0xf020e550
f010391c:	66 c7 05 52 e5 20 f0 	movw   $0x8,0xf020e552
f0103923:	08 00 
f0103925:	c6 05 54 e5 20 f0 00 	movb   $0x0,0xf020e554
f010392c:	c6 05 55 e5 20 f0 8e 	movb   $0x8e,0xf020e555
f0103933:	c1 e8 10             	shr    $0x10,%eax
f0103936:	66 a3 56 e5 20 f0    	mov    %ax,0xf020e556
	SETGATE(idt[T_DEVICE], 0, GD_KT, entry7, 0);
f010393c:	b8 f6 3f 10 f0       	mov    $0xf0103ff6,%eax
f0103941:	66 a3 58 e5 20 f0    	mov    %ax,0xf020e558
f0103947:	66 c7 05 5a e5 20 f0 	movw   $0x8,0xf020e55a
f010394e:	08 00 
f0103950:	c6 05 5c e5 20 f0 00 	movb   $0x0,0xf020e55c
f0103957:	c6 05 5d e5 20 f0 8e 	movb   $0x8e,0xf020e55d
f010395e:	c1 e8 10             	shr    $0x10,%eax
f0103961:	66 a3 5e e5 20 f0    	mov    %ax,0xf020e55e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, entry8, 0);
f0103967:	b8 fc 3f 10 f0       	mov    $0xf0103ffc,%eax
f010396c:	66 a3 60 e5 20 f0    	mov    %ax,0xf020e560
f0103972:	66 c7 05 62 e5 20 f0 	movw   $0x8,0xf020e562
f0103979:	08 00 
f010397b:	c6 05 64 e5 20 f0 00 	movb   $0x0,0xf020e564
f0103982:	c6 05 65 e5 20 f0 8e 	movb   $0x8e,0xf020e565
f0103989:	c1 e8 10             	shr    $0x10,%eax
f010398c:	66 a3 66 e5 20 f0    	mov    %ax,0xf020e566
	SETGATE(idt[T_TSS], 0, GD_KT, entry10, 0);
f0103992:	b8 00 40 10 f0       	mov    $0xf0104000,%eax
f0103997:	66 a3 70 e5 20 f0    	mov    %ax,0xf020e570
f010399d:	66 c7 05 72 e5 20 f0 	movw   $0x8,0xf020e572
f01039a4:	08 00 
f01039a6:	c6 05 74 e5 20 f0 00 	movb   $0x0,0xf020e574
f01039ad:	c6 05 75 e5 20 f0 8e 	movb   $0x8e,0xf020e575
f01039b4:	c1 e8 10             	shr    $0x10,%eax
f01039b7:	66 a3 76 e5 20 f0    	mov    %ax,0xf020e576
	SETGATE(idt[T_SEGNP], 0, GD_KT, entry11, 0);
f01039bd:	b8 04 40 10 f0       	mov    $0xf0104004,%eax
f01039c2:	66 a3 78 e5 20 f0    	mov    %ax,0xf020e578
f01039c8:	66 c7 05 7a e5 20 f0 	movw   $0x8,0xf020e57a
f01039cf:	08 00 
f01039d1:	c6 05 7c e5 20 f0 00 	movb   $0x0,0xf020e57c
f01039d8:	c6 05 7d e5 20 f0 8e 	movb   $0x8e,0xf020e57d
f01039df:	c1 e8 10             	shr    $0x10,%eax
f01039e2:	66 a3 7e e5 20 f0    	mov    %ax,0xf020e57e
	SETGATE(idt[T_STACK], 0, GD_KT, entry12, 0);
f01039e8:	b8 08 40 10 f0       	mov    $0xf0104008,%eax
f01039ed:	66 a3 80 e5 20 f0    	mov    %ax,0xf020e580
f01039f3:	66 c7 05 82 e5 20 f0 	movw   $0x8,0xf020e582
f01039fa:	08 00 
f01039fc:	c6 05 84 e5 20 f0 00 	movb   $0x0,0xf020e584
f0103a03:	c6 05 85 e5 20 f0 8e 	movb   $0x8e,0xf020e585
f0103a0a:	c1 e8 10             	shr    $0x10,%eax
f0103a0d:	66 a3 86 e5 20 f0    	mov    %ax,0xf020e586
	SETGATE(idt[T_GPFLT], 0, GD_KT, entry13, 0);
f0103a13:	b8 0c 40 10 f0       	mov    $0xf010400c,%eax
f0103a18:	66 a3 88 e5 20 f0    	mov    %ax,0xf020e588
f0103a1e:	66 c7 05 8a e5 20 f0 	movw   $0x8,0xf020e58a
f0103a25:	08 00 
f0103a27:	c6 05 8c e5 20 f0 00 	movb   $0x0,0xf020e58c
f0103a2e:	c6 05 8d e5 20 f0 8e 	movb   $0x8e,0xf020e58d
f0103a35:	c1 e8 10             	shr    $0x10,%eax
f0103a38:	66 a3 8e e5 20 f0    	mov    %ax,0xf020e58e
	SETGATE(idt[T_PGFLT], 0, GD_KT, entry14, 0);
f0103a3e:	b8 10 40 10 f0       	mov    $0xf0104010,%eax
f0103a43:	66 a3 90 e5 20 f0    	mov    %ax,0xf020e590
f0103a49:	66 c7 05 92 e5 20 f0 	movw   $0x8,0xf020e592
f0103a50:	08 00 
f0103a52:	c6 05 94 e5 20 f0 00 	movb   $0x0,0xf020e594
f0103a59:	c6 05 95 e5 20 f0 8e 	movb   $0x8e,0xf020e595
f0103a60:	c1 e8 10             	shr    $0x10,%eax
f0103a63:	66 a3 96 e5 20 f0    	mov    %ax,0xf020e596
	SETGATE(idt[T_FPERR], 0, GD_KT, entry16, 0);
f0103a69:	b8 14 40 10 f0       	mov    $0xf0104014,%eax
f0103a6e:	66 a3 a0 e5 20 f0    	mov    %ax,0xf020e5a0
f0103a74:	66 c7 05 a2 e5 20 f0 	movw   $0x8,0xf020e5a2
f0103a7b:	08 00 
f0103a7d:	c6 05 a4 e5 20 f0 00 	movb   $0x0,0xf020e5a4
f0103a84:	c6 05 a5 e5 20 f0 8e 	movb   $0x8e,0xf020e5a5
f0103a8b:	c1 e8 10             	shr    $0x10,%eax
f0103a8e:	66 a3 a6 e5 20 f0    	mov    %ax,0xf020e5a6
	SETGATE(idt[T_ALIGN], 0, GD_KT, entry17, 0);
f0103a94:	b8 1a 40 10 f0       	mov    $0xf010401a,%eax
f0103a99:	66 a3 a8 e5 20 f0    	mov    %ax,0xf020e5a8
f0103a9f:	66 c7 05 aa e5 20 f0 	movw   $0x8,0xf020e5aa
f0103aa6:	08 00 
f0103aa8:	c6 05 ac e5 20 f0 00 	movb   $0x0,0xf020e5ac
f0103aaf:	c6 05 ad e5 20 f0 8e 	movb   $0x8e,0xf020e5ad
f0103ab6:	c1 e8 10             	shr    $0x10,%eax
f0103ab9:	66 a3 ae e5 20 f0    	mov    %ax,0xf020e5ae
	SETGATE(idt[T_MCHK], 0, GD_KT, entry18, 0);
f0103abf:	b8 1e 40 10 f0       	mov    $0xf010401e,%eax
f0103ac4:	66 a3 b0 e5 20 f0    	mov    %ax,0xf020e5b0
f0103aca:	66 c7 05 b2 e5 20 f0 	movw   $0x8,0xf020e5b2
f0103ad1:	08 00 
f0103ad3:	c6 05 b4 e5 20 f0 00 	movb   $0x0,0xf020e5b4
f0103ada:	c6 05 b5 e5 20 f0 8e 	movb   $0x8e,0xf020e5b5
f0103ae1:	c1 e8 10             	shr    $0x10,%eax
f0103ae4:	66 a3 b6 e5 20 f0    	mov    %ax,0xf020e5b6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, entry19, 0);
f0103aea:	b8 24 40 10 f0       	mov    $0xf0104024,%eax
f0103aef:	66 a3 b8 e5 20 f0    	mov    %ax,0xf020e5b8
f0103af5:	66 c7 05 ba e5 20 f0 	movw   $0x8,0xf020e5ba
f0103afc:	08 00 
f0103afe:	c6 05 bc e5 20 f0 00 	movb   $0x0,0xf020e5bc
f0103b05:	c6 05 bd e5 20 f0 8e 	movb   $0x8e,0xf020e5bd
f0103b0c:	c1 e8 10             	shr    $0x10,%eax
f0103b0f:	66 a3 be e5 20 f0    	mov    %ax,0xf020e5be
	
	// SYSCALL
	SETGATE(idt[T_SYSCALL], 0, GD_KT, entry48, 3);
f0103b15:	b8 2a 40 10 f0       	mov    $0xf010402a,%eax
f0103b1a:	66 a3 a0 e6 20 f0    	mov    %ax,0xf020e6a0
f0103b20:	66 c7 05 a2 e6 20 f0 	movw   $0x8,0xf020e6a2
f0103b27:	08 00 
f0103b29:	c6 05 a4 e6 20 f0 00 	movb   $0x0,0xf020e6a4
f0103b30:	c6 05 a5 e6 20 f0 ee 	movb   $0xee,0xf020e6a5
f0103b37:	c1 e8 10             	shr    $0x10,%eax
f0103b3a:	66 a3 a6 e6 20 f0    	mov    %ax,0xf020e6a6
	
	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f0103b40:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b45:	b8 08 00 00 00       	mov    $0x8,%eax
f0103b4a:	b9 74 01 00 00       	mov    $0x174,%ecx
f0103b4f:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);
f0103b51:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0103b56:	b1 75                	mov    $0x75,%cl
f0103b58:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f0103b5a:	b8 30 40 10 f0       	mov    $0xf0104030,%eax
f0103b5f:	b1 76                	mov    $0x76,%cl
f0103b61:	0f 30                	wrmsr  

	// Per-CPU setup 
	trap_init_percpu();
f0103b63:	e8 44 fc ff ff       	call   f01037ac <trap_init_percpu>
	
	cprintf("afer trap_init!\n");               ////////////////////////////////////////////////////////
f0103b68:	c7 04 24 dc 63 10 f0 	movl   $0xf01063dc,(%esp)
f0103b6f:	e8 1c fc ff ff       	call   f0103790 <cprintf>
}
f0103b74:	c9                   	leave  
f0103b75:	c3                   	ret    

f0103b76 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103b76:	55                   	push   %ebp
f0103b77:	89 e5                	mov    %esp,%ebp
f0103b79:	53                   	push   %ebx
f0103b7a:	83 ec 14             	sub    $0x14,%esp
f0103b7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103b80:	8b 03                	mov    (%ebx),%eax
f0103b82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b86:	c7 04 24 ed 63 10 f0 	movl   $0xf01063ed,(%esp)
f0103b8d:	e8 fe fb ff ff       	call   f0103790 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103b92:	8b 43 04             	mov    0x4(%ebx),%eax
f0103b95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b99:	c7 04 24 fc 63 10 f0 	movl   $0xf01063fc,(%esp)
f0103ba0:	e8 eb fb ff ff       	call   f0103790 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ba5:	8b 43 08             	mov    0x8(%ebx),%eax
f0103ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bac:	c7 04 24 0b 64 10 f0 	movl   $0xf010640b,(%esp)
f0103bb3:	e8 d8 fb ff ff       	call   f0103790 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103bb8:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bbf:	c7 04 24 1a 64 10 f0 	movl   $0xf010641a,(%esp)
f0103bc6:	e8 c5 fb ff ff       	call   f0103790 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103bcb:	8b 43 10             	mov    0x10(%ebx),%eax
f0103bce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd2:	c7 04 24 29 64 10 f0 	movl   $0xf0106429,(%esp)
f0103bd9:	e8 b2 fb ff ff       	call   f0103790 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103bde:	8b 43 14             	mov    0x14(%ebx),%eax
f0103be1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be5:	c7 04 24 38 64 10 f0 	movl   $0xf0106438,(%esp)
f0103bec:	e8 9f fb ff ff       	call   f0103790 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103bf1:	8b 43 18             	mov    0x18(%ebx),%eax
f0103bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bf8:	c7 04 24 47 64 10 f0 	movl   $0xf0106447,(%esp)
f0103bff:	e8 8c fb ff ff       	call   f0103790 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c04:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103c07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c0b:	c7 04 24 56 64 10 f0 	movl   $0xf0106456,(%esp)
f0103c12:	e8 79 fb ff ff       	call   f0103790 <cprintf>
}
f0103c17:	83 c4 14             	add    $0x14,%esp
f0103c1a:	5b                   	pop    %ebx
f0103c1b:	5d                   	pop    %ebp
f0103c1c:	c3                   	ret    

f0103c1d <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103c1d:	55                   	push   %ebp
f0103c1e:	89 e5                	mov    %esp,%ebp
f0103c20:	53                   	push   %ebx
f0103c21:	83 ec 14             	sub    $0x14,%esp
f0103c24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103c27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c2b:	c7 04 24 8c 65 10 f0 	movl   $0xf010658c,(%esp)
f0103c32:	e8 59 fb ff ff       	call   f0103790 <cprintf>
	print_regs(&tf->tf_regs);
f0103c37:	89 1c 24             	mov    %ebx,(%esp)
f0103c3a:	e8 37 ff ff ff       	call   f0103b76 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103c3f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103c43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c47:	c7 04 24 a7 64 10 f0 	movl   $0xf01064a7,(%esp)
f0103c4e:	e8 3d fb ff ff       	call   f0103790 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103c53:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103c57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c5b:	c7 04 24 ba 64 10 f0 	movl   $0xf01064ba,(%esp)
f0103c62:	e8 29 fb ff ff       	call   f0103790 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c67:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103c6a:	83 f8 13             	cmp    $0x13,%eax
f0103c6d:	77 09                	ja     f0103c78 <print_trapframe+0x5b>
		return excnames[trapno];
f0103c6f:	8b 14 85 00 68 10 f0 	mov    -0xfef9800(,%eax,4),%edx
f0103c76:	eb 11                	jmp    f0103c89 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
f0103c78:	83 f8 30             	cmp    $0x30,%eax
f0103c7b:	75 07                	jne    f0103c84 <print_trapframe+0x67>
		return "System call";
f0103c7d:	ba 65 64 10 f0       	mov    $0xf0106465,%edx
f0103c82:	eb 05                	jmp    f0103c89 <print_trapframe+0x6c>
	return "(unknown trap)";
f0103c84:	ba 71 64 10 f0       	mov    $0xf0106471,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c89:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c91:	c7 04 24 cd 64 10 f0 	movl   $0xf01064cd,(%esp)
f0103c98:	e8 f3 fa ff ff       	call   f0103790 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103c9d:	3b 1d 88 ed 20 f0    	cmp    0xf020ed88,%ebx
f0103ca3:	75 19                	jne    f0103cbe <print_trapframe+0xa1>
f0103ca5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ca9:	75 13                	jne    f0103cbe <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103cab:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103cae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cb2:	c7 04 24 df 64 10 f0 	movl   $0xf01064df,(%esp)
f0103cb9:	e8 d2 fa ff ff       	call   f0103790 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103cbe:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc5:	c7 04 24 ee 64 10 f0 	movl   $0xf01064ee,(%esp)
f0103ccc:	e8 bf fa ff ff       	call   f0103790 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103cd1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103cd5:	75 4d                	jne    f0103d24 <print_trapframe+0x107>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103cd7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103cda:	a8 01                	test   $0x1,%al
f0103cdc:	74 07                	je     f0103ce5 <print_trapframe+0xc8>
f0103cde:	b9 80 64 10 f0       	mov    $0xf0106480,%ecx
f0103ce3:	eb 05                	jmp    f0103cea <print_trapframe+0xcd>
f0103ce5:	b9 8b 64 10 f0       	mov    $0xf010648b,%ecx
f0103cea:	a8 02                	test   $0x2,%al
f0103cec:	74 07                	je     f0103cf5 <print_trapframe+0xd8>
f0103cee:	ba 97 64 10 f0       	mov    $0xf0106497,%edx
f0103cf3:	eb 05                	jmp    f0103cfa <print_trapframe+0xdd>
f0103cf5:	ba 9d 64 10 f0       	mov    $0xf010649d,%edx
f0103cfa:	a8 04                	test   $0x4,%al
f0103cfc:	74 07                	je     f0103d05 <print_trapframe+0xe8>
f0103cfe:	b8 a2 64 10 f0       	mov    $0xf01064a2,%eax
f0103d03:	eb 05                	jmp    f0103d0a <print_trapframe+0xed>
f0103d05:	b8 0c 66 10 f0       	mov    $0xf010660c,%eax
f0103d0a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103d0e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d16:	c7 04 24 fc 64 10 f0 	movl   $0xf01064fc,(%esp)
f0103d1d:	e8 6e fa ff ff       	call   f0103790 <cprintf>
f0103d22:	eb 0c                	jmp    f0103d30 <print_trapframe+0x113>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103d24:	c7 04 24 29 62 10 f0 	movl   $0xf0106229,(%esp)
f0103d2b:	e8 60 fa ff ff       	call   f0103790 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103d30:	8b 43 30             	mov    0x30(%ebx),%eax
f0103d33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d37:	c7 04 24 0b 65 10 f0 	movl   $0xf010650b,(%esp)
f0103d3e:	e8 4d fa ff ff       	call   f0103790 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103d43:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d4b:	c7 04 24 1a 65 10 f0 	movl   $0xf010651a,(%esp)
f0103d52:	e8 39 fa ff ff       	call   f0103790 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d57:	8b 43 38             	mov    0x38(%ebx),%eax
f0103d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d5e:	c7 04 24 2d 65 10 f0 	movl   $0xf010652d,(%esp)
f0103d65:	e8 26 fa ff ff       	call   f0103790 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103d6a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103d6e:	74 27                	je     f0103d97 <print_trapframe+0x17a>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d70:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d77:	c7 04 24 3c 65 10 f0 	movl   $0xf010653c,(%esp)
f0103d7e:	e8 0d fa ff ff       	call   f0103790 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d83:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d8b:	c7 04 24 4b 65 10 f0 	movl   $0xf010654b,(%esp)
f0103d92:	e8 f9 f9 ff ff       	call   f0103790 <cprintf>
	}
}
f0103d97:	83 c4 14             	add    $0x14,%esp
f0103d9a:	5b                   	pop    %ebx
f0103d9b:	5d                   	pop    %ebp
f0103d9c:	c3                   	ret    

f0103d9d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d9d:	55                   	push   %ebp
f0103d9e:	89 e5                	mov    %esp,%ebp
f0103da0:	53                   	push   %ebx
f0103da1:	83 ec 14             	sub    $0x14,%esp
f0103da4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103da7:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103daa:	8b 53 30             	mov    0x30(%ebx),%edx
f0103dad:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103db1:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103db5:	a1 08 e5 20 f0       	mov    0xf020e508,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103dba:	8b 40 48             	mov    0x48(%eax),%eax
f0103dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dc1:	c7 04 24 58 67 10 f0 	movl   $0xf0106758,(%esp)
f0103dc8:	e8 c3 f9 ff ff       	call   f0103790 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103dcd:	89 1c 24             	mov    %ebx,(%esp)
f0103dd0:	e8 48 fe ff ff       	call   f0103c1d <print_trapframe>
	env_destroy(curenv);
f0103dd5:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103dda:	89 04 24             	mov    %eax,(%esp)
f0103ddd:	e8 48 f8 ff ff       	call   f010362a <env_destroy>
}
f0103de2:	83 c4 14             	add    $0x14,%esp
f0103de5:	5b                   	pop    %ebx
f0103de6:	5d                   	pop    %ebp
f0103de7:	c3                   	ret    

f0103de8 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103de8:	55                   	push   %ebp
f0103de9:	89 e5                	mov    %esp,%ebp
f0103deb:	57                   	push   %edi
f0103dec:	56                   	push   %esi
f0103ded:	83 ec 20             	sub    $0x20,%esp
f0103df0:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103df3:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103df4:	9c                   	pushf  
f0103df5:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103df6:	f6 c4 02             	test   $0x2,%ah
f0103df9:	74 24                	je     f0103e1f <trap+0x37>
f0103dfb:	c7 44 24 0c 5e 65 10 	movl   $0xf010655e,0xc(%esp)
f0103e02:	f0 
f0103e03:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0103e0a:	f0 
f0103e0b:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
f0103e12:	00 
f0103e13:	c7 04 24 77 65 10 f0 	movl   $0xf0106577,(%esp)
f0103e1a:	e8 be c2 ff ff       	call   f01000dd <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103e1f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103e23:	c7 04 24 83 65 10 f0 	movl   $0xf0106583,(%esp)
f0103e2a:	e8 61 f9 ff ff       	call   f0103790 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103e2f:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103e33:	83 e0 03             	and    $0x3,%eax
f0103e36:	83 f8 03             	cmp    $0x3,%eax
f0103e39:	75 3c                	jne    f0103e77 <trap+0x8f>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103e3b:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103e40:	85 c0                	test   %eax,%eax
f0103e42:	75 24                	jne    f0103e68 <trap+0x80>
f0103e44:	c7 44 24 0c 9e 65 10 	movl   $0xf010659e,0xc(%esp)
f0103e4b:	f0 
f0103e4c:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0103e53:	f0 
f0103e54:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
f0103e5b:	00 
f0103e5c:	c7 04 24 77 65 10 f0 	movl   $0xf0106577,(%esp)
f0103e63:	e8 75 c2 ff ff       	call   f01000dd <_panic>
		curenv->env_tf = *tf;
f0103e68:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103e6d:	89 c7                	mov    %eax,%edi
f0103e6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103e71:	8b 35 08 e5 20 f0    	mov    0xf020e508,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103e77:	89 35 88 ed 20 f0    	mov    %esi,0xf020ed88
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno){
f0103e7d:	8b 46 28             	mov    0x28(%esi),%eax
f0103e80:	83 f8 03             	cmp    $0x3,%eax
f0103e83:	74 3a                	je     f0103ebf <trap+0xd7>
f0103e85:	83 f8 03             	cmp    $0x3,%eax
f0103e88:	77 0f                	ja     f0103e99 <trap+0xb1>
f0103e8a:	85 c0                	test   %eax,%eax
f0103e8c:	74 20                	je     f0103eae <trap+0xc6>
f0103e8e:	83 f8 01             	cmp    $0x1,%eax
f0103e91:	0f 85 b0 00 00 00    	jne    f0103f47 <trap+0x15f>
f0103e97:	eb 3f                	jmp    f0103ed8 <trap+0xf0>
f0103e99:	83 f8 0e             	cmp    $0xe,%eax
f0103e9c:	74 61                	je     f0103eff <trap+0x117>
f0103e9e:	83 f8 30             	cmp    $0x30,%eax
f0103ea1:	74 72                	je     f0103f15 <trap+0x12d>
f0103ea3:	83 f8 0d             	cmp    $0xd,%eax
f0103ea6:	0f 85 9b 00 00 00    	jne    f0103f47 <trap+0x15f>
f0103eac:	eb 43                	jmp    f0103ef1 <trap+0x109>
		case T_DIVIDE:
			cprintf("trap T_DIVIDE: divide error\n");
f0103eae:	c7 04 24 a5 65 10 f0 	movl   $0xf01065a5,(%esp)
f0103eb5:	e8 d6 f8 ff ff       	call   f0103790 <cprintf>
f0103eba:	e9 98 00 00 00       	jmp    f0103f57 <trap+0x16f>
			break;
		case T_BRKPT:
			cprintf("trap T_BRKPT: breakpoint\n");
f0103ebf:	c7 04 24 c2 65 10 f0 	movl   $0xf01065c2,(%esp)
f0103ec6:	e8 c5 f8 ff ff       	call   f0103790 <cprintf>
			monitor(tf);
f0103ecb:	89 34 24             	mov    %esi,(%esp)
f0103ece:	e8 5c c9 ff ff       	call   f010082f <monitor>
f0103ed3:	e9 b7 00 00 00       	jmp    f0103f8f <trap+0x1a7>
			return;
		case T_DEBUG:
			cprintf("trap T_DEBUG: debug exception\n");
f0103ed8:	c7 04 24 7c 67 10 f0 	movl   $0xf010677c,(%esp)
f0103edf:	e8 ac f8 ff ff       	call   f0103790 <cprintf>
			monitor(tf);
f0103ee4:	89 34 24             	mov    %esi,(%esp)
f0103ee7:	e8 43 c9 ff ff       	call   f010082f <monitor>
f0103eec:	e9 9e 00 00 00       	jmp    f0103f8f <trap+0x1a7>
			return;
		case T_GPFLT:
			cprintf("trap T_GPFLT: general protection fault\n");
f0103ef1:	c7 04 24 9c 67 10 f0 	movl   $0xf010679c,(%esp)
f0103ef8:	e8 93 f8 ff ff       	call   f0103790 <cprintf>
f0103efd:	eb 58                	jmp    f0103f57 <trap+0x16f>
			break;
		case T_PGFLT:
			page_fault_handler(tf);
f0103eff:	89 34 24             	mov    %esi,(%esp)
f0103f02:	e8 96 fe ff ff       	call   f0103d9d <page_fault_handler>
			cprintf("cdz in pagefault\n");
f0103f07:	c7 04 24 dc 65 10 f0 	movl   $0xf01065dc,(%esp)
f0103f0e:	e8 7d f8 ff ff       	call   f0103790 <cprintf>
f0103f13:	eb 42                	jmp    f0103f57 <trap+0x16f>
			break;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(
f0103f15:	8b 46 04             	mov    0x4(%esi),%eax
f0103f18:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103f1c:	8b 06                	mov    (%esi),%eax
f0103f1e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103f22:	8b 46 10             	mov    0x10(%esi),%eax
f0103f25:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f29:	8b 46 18             	mov    0x18(%esi),%eax
f0103f2c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f30:	8b 46 14             	mov    0x14(%esi),%eax
f0103f33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f37:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103f3a:	89 04 24             	mov    %eax,(%esp)
f0103f3d:	e8 1a 01 00 00       	call   f010405c <syscall>
f0103f42:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103f45:	eb 48                	jmp    f0103f8f <trap+0x1a7>
						tf->tf_regs.reg_edi,
						tf->tf_regs.reg_esi
						);
			return;
		default:
			cprintf("trap no=%d\n", tf->tf_trapno);
f0103f47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f4b:	c7 04 24 ee 65 10 f0 	movl   $0xf01065ee,(%esp)
f0103f52:	e8 39 f8 ff ff       	call   f0103790 <cprintf>
			break;
	}


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103f57:	89 34 24             	mov    %esi,(%esp)
f0103f5a:	e8 be fc ff ff       	call   f0103c1d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103f5f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103f64:	75 1c                	jne    f0103f82 <trap+0x19a>
		panic("unhandled trap in kernel");
f0103f66:	c7 44 24 08 fa 65 10 	movl   $0xf01065fa,0x8(%esp)
f0103f6d:	f0 
f0103f6e:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
f0103f75:	00 
f0103f76:	c7 04 24 77 65 10 f0 	movl   $0xf0106577,(%esp)
f0103f7d:	e8 5b c1 ff ff       	call   f01000dd <_panic>
	else {
		env_destroy(curenv);
f0103f82:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103f87:	89 04 24             	mov    %eax,(%esp)
f0103f8a:	e8 9b f6 ff ff       	call   f010362a <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103f8f:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0103f94:	85 c0                	test   %eax,%eax
f0103f96:	74 06                	je     f0103f9e <trap+0x1b6>
f0103f98:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103f9c:	74 24                	je     f0103fc2 <trap+0x1da>
f0103f9e:	c7 44 24 0c c4 67 10 	movl   $0xf01067c4,0xc(%esp)
f0103fa5:	f0 
f0103fa6:	c7 44 24 08 bf 5f 10 	movl   $0xf0105fbf,0x8(%esp)
f0103fad:	f0 
f0103fae:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
f0103fb5:	00 
f0103fb6:	c7 04 24 77 65 10 f0 	movl   $0xf0106577,(%esp)
f0103fbd:	e8 1b c1 ff ff       	call   f01000dd <_panic>
	env_run(curenv);
f0103fc2:	89 04 24             	mov    %eax,(%esp)
f0103fc5:	e8 b7 f6 ff ff       	call   f0103681 <env_run>
	...

f0103fcc <entry0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(entry0, T_DIVIDE);
f0103fcc:	6a 00                	push   $0x0
f0103fce:	6a 00                	push   $0x0
f0103fd0:	eb 6e                	jmp    f0104040 <_alltraps>

f0103fd2 <entry1>:

TRAPHANDLER_NOEC(entry1, T_DEBUG);
f0103fd2:	6a 00                	push   $0x0
f0103fd4:	6a 01                	push   $0x1
f0103fd6:	eb 68                	jmp    f0104040 <_alltraps>

f0103fd8 <entry2>:
TRAPHANDLER_NOEC(entry2, T_NMI);
f0103fd8:	6a 00                	push   $0x0
f0103fda:	6a 02                	push   $0x2
f0103fdc:	eb 62                	jmp    f0104040 <_alltraps>

f0103fde <entry3>:
TRAPHANDLER_NOEC(entry3, T_BRKPT);
f0103fde:	6a 00                	push   $0x0
f0103fe0:	6a 03                	push   $0x3
f0103fe2:	eb 5c                	jmp    f0104040 <_alltraps>

f0103fe4 <entry4>:
TRAPHANDLER_NOEC(entry4, T_OFLOW);
f0103fe4:	6a 00                	push   $0x0
f0103fe6:	6a 04                	push   $0x4
f0103fe8:	eb 56                	jmp    f0104040 <_alltraps>

f0103fea <entry5>:
TRAPHANDLER_NOEC(entry5, T_BOUND);
f0103fea:	6a 00                	push   $0x0
f0103fec:	6a 05                	push   $0x5
f0103fee:	eb 50                	jmp    f0104040 <_alltraps>

f0103ff0 <entry6>:
TRAPHANDLER_NOEC(entry6, T_ILLOP);
f0103ff0:	6a 00                	push   $0x0
f0103ff2:	6a 06                	push   $0x6
f0103ff4:	eb 4a                	jmp    f0104040 <_alltraps>

f0103ff6 <entry7>:
TRAPHANDLER_NOEC(entry7, T_DEVICE);
f0103ff6:	6a 00                	push   $0x0
f0103ff8:	6a 07                	push   $0x7
f0103ffa:	eb 44                	jmp    f0104040 <_alltraps>

f0103ffc <entry8>:

TRAPHANDLER(entry8, T_DBLFLT);
f0103ffc:	6a 08                	push   $0x8
f0103ffe:	eb 40                	jmp    f0104040 <_alltraps>

f0104000 <entry10>:
TRAPHANDLER(entry10, T_TSS);
f0104000:	6a 0a                	push   $0xa
f0104002:	eb 3c                	jmp    f0104040 <_alltraps>

f0104004 <entry11>:
TRAPHANDLER(entry11, T_SEGNP);
f0104004:	6a 0b                	push   $0xb
f0104006:	eb 38                	jmp    f0104040 <_alltraps>

f0104008 <entry12>:
TRAPHANDLER(entry12, T_STACK);
f0104008:	6a 0c                	push   $0xc
f010400a:	eb 34                	jmp    f0104040 <_alltraps>

f010400c <entry13>:
TRAPHANDLER(entry13, T_GPFLT);
f010400c:	6a 0d                	push   $0xd
f010400e:	eb 30                	jmp    f0104040 <_alltraps>

f0104010 <entry14>:
TRAPHANDLER(entry14, T_PGFLT);
f0104010:	6a 0e                	push   $0xe
f0104012:	eb 2c                	jmp    f0104040 <_alltraps>

f0104014 <entry16>:
TRAPHANDLER_NOEC(entry16, T_FPERR);
f0104014:	6a 00                	push   $0x0
f0104016:	6a 10                	push   $0x10
f0104018:	eb 26                	jmp    f0104040 <_alltraps>

f010401a <entry17>:
TRAPHANDLER(entry17, T_ALIGN);
f010401a:	6a 11                	push   $0x11
f010401c:	eb 22                	jmp    f0104040 <_alltraps>

f010401e <entry18>:
TRAPHANDLER_NOEC(entry18, T_MCHK);
f010401e:	6a 00                	push   $0x0
f0104020:	6a 12                	push   $0x12
f0104022:	eb 1c                	jmp    f0104040 <_alltraps>

f0104024 <entry19>:
TRAPHANDLER_NOEC(entry19, T_SIMDERR);
f0104024:	6a 00                	push   $0x0
f0104026:	6a 13                	push   $0x13
f0104028:	eb 16                	jmp    f0104040 <_alltraps>

f010402a <entry48>:

TRAPHANDLER_NOEC(entry48, T_SYSCALL);
f010402a:	6a 00                	push   $0x0
f010402c:	6a 30                	push   $0x30
f010402e:	eb 10                	jmp    f0104040 <_alltraps>

f0104030 <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
	pushl %edi
f0104030:	57                   	push   %edi
	pushl %ebx
f0104031:	53                   	push   %ebx
	pushl %ecx
f0104032:	51                   	push   %ecx
	pushl %edx
f0104033:	52                   	push   %edx
	pushl %eax
f0104034:	50                   	push   %eax
	call syscall
f0104035:	e8 22 00 00 00       	call   f010405c <syscall>
	movl %ebp, %ecx
f010403a:	89 e9                	mov    %ebp,%ecx
	movl %esi, %edx
f010403c:	89 f2                	mov    %esi,%edx
	sysexit
f010403e:	0f 35                	sysexit 

f0104040 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushw $0
f0104040:	66 6a 00             	pushw  $0x0
	pushw %ds
f0104043:	66 1e                	pushw  %ds
	pushw $0
f0104045:	66 6a 00             	pushw  $0x0
	pushw %es
f0104048:	66 06                	pushw  %es
	pushal
f010404a:	60                   	pusha  
	movl $GD_KD, %eax
f010404b:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104050:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104052:	8e c0                	mov    %eax,%es

	pushl %esp
f0104054:	54                   	push   %esp

	call trap
f0104055:	e8 8e fd ff ff       	call   f0103de8 <trap>
	...

f010405c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010405c:	55                   	push   %ebp
f010405d:	89 e5                	mov    %esp,%ebp
f010405f:	53                   	push   %ebx
f0104060:	83 ec 24             	sub    $0x24,%esp
f0104063:	8b 45 08             	mov    0x8(%ebp),%eax
f0104066:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104069:	8b 55 10             	mov    0x10(%ebp),%edx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f010406c:	83 f8 05             	cmp    $0x5,%eax
f010406f:	0f 87 64 01 00 00    	ja     f01041d9 <syscall+0x17d>
f0104075:	ff 24 85 98 68 10 f0 	jmp    *-0xfef9768(,%eax,4)
	// Destroy the environment if not.

	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010407c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104080:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104084:	c7 04 24 50 68 10 f0 	movl   $0xf0106850,(%esp)
f010408b:	e8 00 f7 ff ff       	call   f0103790 <cprintf>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
		case SYS_cputs:
			sys_cputs((char *)a1, (size_t)a2);
			return 0;
f0104090:	b8 00 00 00 00       	mov    $0x0,%eax
f0104095:	e9 44 01 00 00       	jmp    f01041de <syscall+0x182>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010409a:	e8 38 c4 ff ff       	call   f01004d7 <cons_getc>
	switch(syscallno){
		case SYS_cputs:
			sys_cputs((char *)a1, (size_t)a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f010409f:	e9 3a 01 00 00       	jmp    f01041de <syscall+0x182>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01040a4:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f01040a9:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char *)a1, (size_t)a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01040ac:	e9 2d 01 00 00       	jmp    f01041de <syscall+0x182>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01040b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01040b8:	00 
f01040b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01040bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040c0:	89 1c 24             	mov    %ebx,(%esp)
f01040c3:	e8 b8 ee ff ff       	call   f0102f80 <envid2env>
f01040c8:	85 c0                	test   %eax,%eax
f01040ca:	0f 88 0e 01 00 00    	js     f01041de <syscall+0x182>
		return r;
	if (e == curenv)
f01040d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040d3:	8b 15 08 e5 20 f0    	mov    0xf020e508,%edx
f01040d9:	39 d0                	cmp    %edx,%eax
f01040db:	75 15                	jne    f01040f2 <syscall+0x96>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01040dd:	8b 40 48             	mov    0x48(%eax),%eax
f01040e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e4:	c7 04 24 55 68 10 f0 	movl   $0xf0106855,(%esp)
f01040eb:	e8 a0 f6 ff ff       	call   f0103790 <cprintf>
f01040f0:	eb 1a                	jmp    f010410c <syscall+0xb0>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01040f2:	8b 40 48             	mov    0x48(%eax),%eax
f01040f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040f9:	8b 42 48             	mov    0x48(%edx),%eax
f01040fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104100:	c7 04 24 70 68 10 f0 	movl   $0xf0106870,(%esp)
f0104107:	e8 84 f6 ff ff       	call   f0103790 <cprintf>
	env_destroy(e);
f010410c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010410f:	89 04 24             	mov    %eax,(%esp)
f0104112:	e8 13 f5 ff ff       	call   f010362a <env_destroy>
	return 0;
f0104117:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f010411c:	e9 bd 00 00 00       	jmp    f01041de <syscall+0x182>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104121:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0104127:	77 20                	ja     f0104149 <syscall+0xed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104129:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010412d:	c7 44 24 08 40 58 10 	movl   $0xf0105840,0x8(%esp)
f0104134:	f0 
f0104135:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
f010413c:	00 
f010413d:	c7 04 24 88 68 10 f0 	movl   $0xf0106888,(%esp)
f0104144:	e8 94 bf ff ff       	call   f01000dd <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104149:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010414f:	c1 eb 0c             	shr    $0xc,%ebx
f0104152:	3b 1d a4 f1 20 f0    	cmp    0xf020f1a4,%ebx
f0104158:	72 1c                	jb     f0104176 <syscall+0x11a>
		panic("pa2page called with invalid pa");
f010415a:	c7 44 24 08 28 59 10 	movl   $0xf0105928,0x8(%esp)
f0104161:	f0 
f0104162:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0104169:	00 
f010416a:	c7 04 24 a5 5f 10 f0 	movl   $0xf0105fa5,(%esp)
f0104171:	e8 67 bf ff ff       	call   f01000dd <_panic>
	return &pages[PGNUM(pa)];
f0104176:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0104179:	03 1d ac f1 20 f0    	add    0xf020f1ac,%ebx
f010417f:	74 22                	je     f01041a3 <syscall+0x147>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0104181:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104188:	00 
f0104189:	89 54 24 08          	mov    %edx,0x8(%esp)
f010418d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104191:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f0104196:	8b 40 60             	mov    0x60(%eax),%eax
f0104199:	89 04 24             	mov    %eax,(%esp)
f010419c:	e8 cf d0 ff ff       	call   f0101270 <page_insert>
f01041a1:	eb 3b                	jmp    f01041de <syscall+0x182>
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
		return E_INVAL;
f01041a3:	b8 03 00 00 00       	mov    $0x3,%eax
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_map_kernel_page:
			return sys_map_kernel_page((void *)a1, (void *)a2);
f01041a8:	eb 34                	jmp    f01041de <syscall+0x182>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_heap_bottom-inc), inc);
f01041aa:	a1 08 e5 20 f0       	mov    0xf020e508,%eax
f01041af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01041b3:	8b 50 5c             	mov    0x5c(%eax),%edx
f01041b6:	29 da                	sub    %ebx,%edx
f01041b8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01041bc:	89 04 24             	mov    %eax,(%esp)
f01041bf:	e8 88 f0 ff ff       	call   f010324c <region_alloc>
	return curenv->env_heap_bottom = (uintptr_t)ROUNDDOWN(curenv->env_heap_bottom-inc, PGSIZE);
f01041c4:	8b 15 08 e5 20 f0    	mov    0xf020e508,%edx
f01041ca:	8b 42 5c             	mov    0x5c(%edx),%eax
f01041cd:	29 d8                	sub    %ebx,%eax
f01041cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01041d4:	89 42 5c             	mov    %eax,0x5c(%edx)
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_map_kernel_page:
			return sys_map_kernel_page((void *)a1, (void *)a2);
		case SYS_sbrk:
			return sys_sbrk(a1);
f01041d7:	eb 05                	jmp    f01041de <syscall+0x182>
		case NSYSCALLS:
		default:
			return -E_INVAL;
f01041d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	// panic("syscall not implemented");
}
f01041de:	83 c4 24             	add    $0x24,%esp
f01041e1:	5b                   	pop    %ebx
f01041e2:	5d                   	pop    %ebp
f01041e3:	c3                   	ret    

f01041e4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01041e4:	55                   	push   %ebp
f01041e5:	89 e5                	mov    %esp,%ebp
f01041e7:	57                   	push   %edi
f01041e8:	56                   	push   %esi
f01041e9:	53                   	push   %ebx
f01041ea:	83 ec 14             	sub    $0x14,%esp
f01041ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01041f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01041f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01041f6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01041f9:	8b 1a                	mov    (%edx),%ebx
f01041fb:	8b 01                	mov    (%ecx),%eax
f01041fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0104200:	39 c3                	cmp    %eax,%ebx
f0104202:	0f 8f 97 00 00 00    	jg     f010429f <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0104208:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010420f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104212:	01 d8                	add    %ebx,%eax
f0104214:	89 c7                	mov    %eax,%edi
f0104216:	c1 ef 1f             	shr    $0x1f,%edi
f0104219:	01 c7                	add    %eax,%edi
f010421b:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010421d:	39 df                	cmp    %ebx,%edi
f010421f:	7c 31                	jl     f0104252 <stab_binsearch+0x6e>
f0104221:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104224:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104227:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f010422c:	39 f0                	cmp    %esi,%eax
f010422e:	0f 84 b3 00 00 00    	je     f01042e7 <stab_binsearch+0x103>
f0104234:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104238:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010423c:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010423e:	48                   	dec    %eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010423f:	39 d8                	cmp    %ebx,%eax
f0104241:	7c 0f                	jl     f0104252 <stab_binsearch+0x6e>
f0104243:	0f b6 0a             	movzbl (%edx),%ecx
f0104246:	83 ea 0c             	sub    $0xc,%edx
f0104249:	39 f1                	cmp    %esi,%ecx
f010424b:	75 f1                	jne    f010423e <stab_binsearch+0x5a>
f010424d:	e9 97 00 00 00       	jmp    f01042e9 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104252:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104255:	eb 39                	jmp    f0104290 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104257:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010425a:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010425c:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010425f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104266:	eb 28                	jmp    f0104290 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104268:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010426b:	76 12                	jbe    f010427f <stab_binsearch+0x9b>
			*region_right = m - 1;
f010426d:	48                   	dec    %eax
f010426e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104271:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104274:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104276:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010427d:	eb 11                	jmp    f0104290 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010427f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104282:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0104284:	ff 45 0c             	incl   0xc(%ebp)
f0104287:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104289:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0104290:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104293:	0f 8d 76 ff ff ff    	jge    f010420f <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104299:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010429d:	75 0d                	jne    f01042ac <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f010429f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01042a2:	8b 02                	mov    (%edx),%eax
f01042a4:	48                   	dec    %eax
f01042a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01042a8:	89 01                	mov    %eax,(%ecx)
f01042aa:	eb 55                	jmp    f0104301 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01042ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01042af:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01042b1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01042b4:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01042b6:	39 c1                	cmp    %eax,%ecx
f01042b8:	7d 26                	jge    f01042e0 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01042ba:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01042bd:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01042c0:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01042c5:	39 f2                	cmp    %esi,%edx
f01042c7:	74 17                	je     f01042e0 <stab_binsearch+0xfc>
f01042c9:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01042cd:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01042d1:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01042d2:	39 c1                	cmp    %eax,%ecx
f01042d4:	7d 0a                	jge    f01042e0 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01042d6:	0f b6 1a             	movzbl (%edx),%ebx
f01042d9:	83 ea 0c             	sub    $0xc,%edx
f01042dc:	39 f3                	cmp    %esi,%ebx
f01042de:	75 f1                	jne    f01042d1 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01042e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01042e3:	89 02                	mov    %eax,(%edx)
f01042e5:	eb 1a                	jmp    f0104301 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01042e7:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01042e9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01042ec:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01042ef:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01042f3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01042f6:	0f 82 5b ff ff ff    	jb     f0104257 <stab_binsearch+0x73>
f01042fc:	e9 67 ff ff ff       	jmp    f0104268 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104301:	83 c4 14             	add    $0x14,%esp
f0104304:	5b                   	pop    %ebx
f0104305:	5e                   	pop    %esi
f0104306:	5f                   	pop    %edi
f0104307:	5d                   	pop    %ebp
f0104308:	c3                   	ret    

f0104309 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104309:	55                   	push   %ebp
f010430a:	89 e5                	mov    %esp,%ebp
f010430c:	57                   	push   %edi
f010430d:	56                   	push   %esi
f010430e:	53                   	push   %ebx
f010430f:	83 ec 5c             	sub    $0x5c,%esp
f0104312:	8b 75 08             	mov    0x8(%ebp),%esi
f0104315:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104318:	c7 03 b0 68 10 f0    	movl   $0xf01068b0,(%ebx)
	info->eip_line = 0;
f010431e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104325:	c7 43 08 b0 68 10 f0 	movl   $0xf01068b0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010432c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104333:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104336:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010433d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104343:	77 22                	ja     f0104367 <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104345:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f010434b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010434e:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104353:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104359:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010435c:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104362:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0104365:	eb 1a                	jmp    f0104381 <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104367:	c7 45 c0 1f 9a 11 f0 	movl   $0xf0119a1f,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010436e:	c7 45 bc 41 fb 10 f0 	movl   $0xf010fb41,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104375:	b8 40 fb 10 f0       	mov    $0xf010fb40,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010437a:	c7 45 c4 c8 6a 10 f0 	movl   $0xf0106ac8,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104381:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104384:	39 7d bc             	cmp    %edi,-0x44(%ebp)
f0104387:	0f 83 cf 01 00 00    	jae    f010455c <debuginfo_eip+0x253>
f010438d:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104391:	0f 85 cc 01 00 00    	jne    f0104563 <debuginfo_eip+0x25a>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104397:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010439e:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f01043a1:	c1 f8 02             	sar    $0x2,%eax
f01043a4:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01043a7:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01043aa:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01043ad:	89 d1                	mov    %edx,%ecx
f01043af:	c1 e1 08             	shl    $0x8,%ecx
f01043b2:	01 ca                	add    %ecx,%edx
f01043b4:	89 d1                	mov    %edx,%ecx
f01043b6:	c1 e1 10             	shl    $0x10,%ecx
f01043b9:	01 ca                	add    %ecx,%edx
f01043bb:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f01043bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01043c2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01043c6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01043cd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01043d0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01043d3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01043d6:	e8 09 fe ff ff       	call   f01041e4 <stab_binsearch>
	if (lfile == 0)
f01043db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043de:	85 c0                	test   %eax,%eax
f01043e0:	0f 84 84 01 00 00    	je     f010456a <debuginfo_eip+0x261>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01043e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01043e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01043ef:	89 74 24 04          	mov    %esi,0x4(%esp)
f01043f3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01043fa:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01043fd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104400:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104403:	e8 dc fd ff ff       	call   f01041e4 <stab_binsearch>

	if (lfun <= rfun) {
f0104408:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010440b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010440e:	39 d0                	cmp    %edx,%eax
f0104410:	7f 32                	jg     f0104444 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104412:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104415:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104418:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010441b:	8b 39                	mov    (%ecx),%edi
f010441d:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0104420:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104423:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0104426:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104429:	73 09                	jae    f0104434 <debuginfo_eip+0x12b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010442b:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010442e:	03 7d bc             	add    -0x44(%ebp),%edi
f0104431:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104434:	8b 49 08             	mov    0x8(%ecx),%ecx
f0104437:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010443a:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010443c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010443f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104442:	eb 0f                	jmp    f0104453 <debuginfo_eip+0x14a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104444:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010444a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010444d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104450:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104453:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010445a:	00 
f010445b:	8b 43 08             	mov    0x8(%ebx),%eax
f010445e:	89 04 24             	mov    %eax,(%esp)
f0104461:	e8 3f 09 00 00       	call   f0104da5 <strfind>
f0104466:	2b 43 08             	sub    0x8(%ebx),%eax
f0104469:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010446c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104470:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0104477:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010447a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010447d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104480:	e8 5f fd ff ff       	call   f01041e4 <stab_binsearch>
	if(lline <= rline)
f0104485:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104488:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010448b:	0f 8f e0 00 00 00    	jg     f0104571 <debuginfo_eip+0x268>
	  info->eip_line = stabs[lline].n_desc;
f0104491:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104494:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104497:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f010449c:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010449f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01044a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01044a5:	89 7d b8             	mov    %edi,-0x48(%ebp)
f01044a8:	39 f8                	cmp    %edi,%eax
f01044aa:	7c 70                	jl     f010451c <debuginfo_eip+0x213>
	       && stabs[lline].n_type != N_SOL
f01044ac:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01044af:	89 f7                	mov    %esi,%edi
f01044b1:	8d 34 96             	lea    (%esi,%edx,4),%esi
f01044b4:	8a 4e 04             	mov    0x4(%esi),%cl
f01044b7:	80 f9 84             	cmp    $0x84,%cl
f01044ba:	74 43                	je     f01044ff <debuginfo_eip+0x1f6>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01044bc:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01044c0:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01044c3:	89 c7                	mov    %eax,%edi
f01044c5:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01044c8:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01044cb:	eb 1c                	jmp    f01044e9 <debuginfo_eip+0x1e0>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01044cd:	48                   	dec    %eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01044ce:	39 c3                	cmp    %eax,%ebx
f01044d0:	7f 47                	jg     f0104519 <debuginfo_eip+0x210>
	       && stabs[lline].n_type != N_SOL
f01044d2:	89 d6                	mov    %edx,%esi
f01044d4:	83 ea 0c             	sub    $0xc,%edx
f01044d7:	8a 4a 10             	mov    0x10(%edx),%cl
f01044da:	80 f9 84             	cmp    $0x84,%cl
f01044dd:	75 08                	jne    f01044e7 <debuginfo_eip+0x1de>
f01044df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01044e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01044e5:	eb 18                	jmp    f01044ff <debuginfo_eip+0x1f6>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01044e7:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01044e9:	80 f9 64             	cmp    $0x64,%cl
f01044ec:	75 df                	jne    f01044cd <debuginfo_eip+0x1c4>
f01044ee:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f01044f2:	74 d9                	je     f01044cd <debuginfo_eip+0x1c4>
f01044f4:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01044f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01044fa:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01044fd:	7f 1d                	jg     f010451c <debuginfo_eip+0x213>
f01044ff:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104502:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104505:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0104508:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010450b:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010450e:	39 d0                	cmp    %edx,%eax
f0104510:	73 0a                	jae    f010451c <debuginfo_eip+0x213>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104512:	03 45 bc             	add    -0x44(%ebp),%eax
f0104515:	89 03                	mov    %eax,(%ebx)
f0104517:	eb 03                	jmp    f010451c <debuginfo_eip+0x213>
f0104519:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010451c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010451f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104522:	39 ca                	cmp    %ecx,%edx
f0104524:	7d 52                	jge    f0104578 <debuginfo_eip+0x26f>
		for (lline = lfun + 1;
f0104526:	8d 42 01             	lea    0x1(%edx),%eax
f0104529:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010452c:	39 c1                	cmp    %eax,%ecx
f010452e:	7e 4f                	jle    f010457f <debuginfo_eip+0x276>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104530:	8d 34 40             	lea    (%eax,%eax,2),%esi
f0104533:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104536:	80 7c b7 04 a0       	cmpb   $0xa0,0x4(%edi,%esi,4)
f010453b:	75 49                	jne    f0104586 <debuginfo_eip+0x27d>
f010453d:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104540:	8d 54 97 1c          	lea    0x1c(%edi,%edx,4),%edx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104544:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104547:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104548:	39 c1                	cmp    %eax,%ecx
f010454a:	7e 41                	jle    f010458d <debuginfo_eip+0x284>
f010454c:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010454f:	80 7a f4 a0          	cmpb   $0xa0,-0xc(%edx)
f0104553:	74 ef                	je     f0104544 <debuginfo_eip+0x23b>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0104555:	b8 00 00 00 00       	mov    $0x0,%eax
f010455a:	eb 36                	jmp    f0104592 <debuginfo_eip+0x289>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010455c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104561:	eb 2f                	jmp    f0104592 <debuginfo_eip+0x289>
f0104563:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104568:	eb 28                	jmp    f0104592 <debuginfo_eip+0x289>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010456a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010456f:	eb 21                	jmp    f0104592 <debuginfo_eip+0x289>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline)
	  info->eip_line = stabs[lline].n_desc;
	else
	  return -1;
f0104571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104576:	eb 1a                	jmp    f0104592 <debuginfo_eip+0x289>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0104578:	b8 00 00 00 00       	mov    $0x0,%eax
f010457d:	eb 13                	jmp    f0104592 <debuginfo_eip+0x289>
f010457f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104584:	eb 0c                	jmp    f0104592 <debuginfo_eip+0x289>
f0104586:	b8 00 00 00 00       	mov    $0x0,%eax
f010458b:	eb 05                	jmp    f0104592 <debuginfo_eip+0x289>
f010458d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104592:	83 c4 5c             	add    $0x5c,%esp
f0104595:	5b                   	pop    %ebx
f0104596:	5e                   	pop    %esi
f0104597:	5f                   	pop    %edi
f0104598:	5d                   	pop    %ebp
f0104599:	c3                   	ret    
	...

f010459c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010459c:	55                   	push   %ebp
f010459d:	89 e5                	mov    %esp,%ebp
f010459f:	57                   	push   %edi
f01045a0:	56                   	push   %esi
f01045a1:	53                   	push   %ebx
f01045a2:	83 ec 3c             	sub    $0x3c,%esp
f01045a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01045a8:	89 d7                	mov    %edx,%edi
f01045aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01045b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01045b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01045b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01045bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01045c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01045c4:	72 0f                	jb     f01045d5 <printnum+0x39>
f01045c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01045c9:	39 45 10             	cmp    %eax,0x10(%ebp)
f01045cc:	76 07                	jbe    f01045d5 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01045ce:	4b                   	dec    %ebx
f01045cf:	85 db                	test   %ebx,%ebx
f01045d1:	7f 4f                	jg     f0104622 <printnum+0x86>
f01045d3:	eb 5a                	jmp    f010462f <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01045d5:	89 74 24 10          	mov    %esi,0x10(%esp)
f01045d9:	4b                   	dec    %ebx
f01045da:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01045de:	8b 45 10             	mov    0x10(%ebp),%eax
f01045e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045e5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01045e9:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01045ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01045f4:	00 
f01045f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01045f8:	89 04 24             	mov    %eax,(%esp)
f01045fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104602:	e8 d1 09 00 00       	call   f0104fd8 <__udivdi3>
f0104607:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010460b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010460f:	89 04 24             	mov    %eax,(%esp)
f0104612:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104616:	89 fa                	mov    %edi,%edx
f0104618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010461b:	e8 7c ff ff ff       	call   f010459c <printnum>
f0104620:	eb 0d                	jmp    f010462f <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104622:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104626:	89 34 24             	mov    %esi,(%esp)
f0104629:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010462c:	4b                   	dec    %ebx
f010462d:	75 f3                	jne    f0104622 <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010462f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104633:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104637:	8b 45 10             	mov    0x10(%ebp),%eax
f010463a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010463e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104645:	00 
f0104646:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104649:	89 04 24             	mov    %eax,(%esp)
f010464c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010464f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104653:	e8 a0 0a 00 00       	call   f01050f8 <__umoddi3>
f0104658:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010465c:	0f be 80 ba 68 10 f0 	movsbl -0xfef9746(%eax),%eax
f0104663:	89 04 24             	mov    %eax,(%esp)
f0104666:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104669:	83 c4 3c             	add    $0x3c,%esp
f010466c:	5b                   	pop    %ebx
f010466d:	5e                   	pop    %esi
f010466e:	5f                   	pop    %edi
f010466f:	5d                   	pop    %ebp
f0104670:	c3                   	ret    

f0104671 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104671:	55                   	push   %ebp
f0104672:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104674:	83 fa 01             	cmp    $0x1,%edx
f0104677:	7e 0e                	jle    f0104687 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104679:	8b 10                	mov    (%eax),%edx
f010467b:	8d 4a 08             	lea    0x8(%edx),%ecx
f010467e:	89 08                	mov    %ecx,(%eax)
f0104680:	8b 02                	mov    (%edx),%eax
f0104682:	8b 52 04             	mov    0x4(%edx),%edx
f0104685:	eb 22                	jmp    f01046a9 <getuint+0x38>
	else if (lflag)
f0104687:	85 d2                	test   %edx,%edx
f0104689:	74 10                	je     f010469b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010468b:	8b 10                	mov    (%eax),%edx
f010468d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104690:	89 08                	mov    %ecx,(%eax)
f0104692:	8b 02                	mov    (%edx),%eax
f0104694:	ba 00 00 00 00       	mov    $0x0,%edx
f0104699:	eb 0e                	jmp    f01046a9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010469b:	8b 10                	mov    (%eax),%edx
f010469d:	8d 4a 04             	lea    0x4(%edx),%ecx
f01046a0:	89 08                	mov    %ecx,(%eax)
f01046a2:	8b 02                	mov    (%edx),%eax
f01046a4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01046a9:	5d                   	pop    %ebp
f01046aa:	c3                   	ret    

f01046ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01046ab:	55                   	push   %ebp
f01046ac:	89 e5                	mov    %esp,%ebp
f01046ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01046b1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01046b4:	8b 10                	mov    (%eax),%edx
f01046b6:	3b 50 04             	cmp    0x4(%eax),%edx
f01046b9:	73 08                	jae    f01046c3 <sprintputch+0x18>
		*b->buf++ = ch;
f01046bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046be:	88 0a                	mov    %cl,(%edx)
f01046c0:	42                   	inc    %edx
f01046c1:	89 10                	mov    %edx,(%eax)
}
f01046c3:	5d                   	pop    %ebp
f01046c4:	c3                   	ret    

f01046c5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01046c5:	55                   	push   %ebp
f01046c6:	89 e5                	mov    %esp,%ebp
f01046c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01046cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01046ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01046d2:	8b 45 10             	mov    0x10(%ebp),%eax
f01046d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01046e3:	89 04 24             	mov    %eax,(%esp)
f01046e6:	e8 02 00 00 00       	call   f01046ed <vprintfmt>
	va_end(ap);
}
f01046eb:	c9                   	leave  
f01046ec:	c3                   	ret    

f01046ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01046ed:	55                   	push   %ebp
f01046ee:	89 e5                	mov    %esp,%ebp
f01046f0:	57                   	push   %edi
f01046f1:	56                   	push   %esi
f01046f2:	53                   	push   %ebx
f01046f3:	83 ec 4c             	sub    $0x4c,%esp
f01046f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046f9:	8b 75 10             	mov    0x10(%ebp),%esi
f01046fc:	eb 17                	jmp    f0104715 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01046fe:	85 c0                	test   %eax,%eax
f0104700:	0f 84 93 03 00 00    	je     f0104a99 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0104706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010470a:	89 04 24             	mov    %eax,(%esp)
f010470d:	ff 55 08             	call   *0x8(%ebp)
f0104710:	eb 03                	jmp    f0104715 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104712:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104715:	0f b6 06             	movzbl (%esi),%eax
f0104718:	46                   	inc    %esi
f0104719:	83 f8 25             	cmp    $0x25,%eax
f010471c:	75 e0                	jne    f01046fe <vprintfmt+0x11>
f010471e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0104722:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0104729:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010472e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104735:	b9 00 00 00 00       	mov    $0x0,%ecx
f010473a:	eb 26                	jmp    f0104762 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010473c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010473f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0104743:	eb 1d                	jmp    f0104762 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104745:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104748:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010474c:	eb 14                	jmp    f0104762 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010474e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104751:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104758:	eb 08                	jmp    f0104762 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010475a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010475d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104762:	0f b6 16             	movzbl (%esi),%edx
f0104765:	8d 46 01             	lea    0x1(%esi),%eax
f0104768:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010476b:	8a 06                	mov    (%esi),%al
f010476d:	83 e8 23             	sub    $0x23,%eax
f0104770:	3c 55                	cmp    $0x55,%al
f0104772:	0f 87 fd 02 00 00    	ja     f0104a75 <vprintfmt+0x388>
f0104778:	0f b6 c0             	movzbl %al,%eax
f010477b:	ff 24 85 44 69 10 f0 	jmp    *-0xfef96bc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104782:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
f0104785:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0104789:	8d 50 d0             	lea    -0x30(%eax),%edx
f010478c:	83 fa 09             	cmp    $0x9,%edx
f010478f:	77 3f                	ja     f01047d0 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104791:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104794:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0104795:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0104798:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010479c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010479f:	8d 50 d0             	lea    -0x30(%eax),%edx
f01047a2:	83 fa 09             	cmp    $0x9,%edx
f01047a5:	76 ed                	jbe    f0104794 <vprintfmt+0xa7>
f01047a7:	eb 2a                	jmp    f01047d3 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01047a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01047ac:	8d 50 04             	lea    0x4(%eax),%edx
f01047af:	89 55 14             	mov    %edx,0x14(%ebp)
f01047b2:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01047b7:	eb 1a                	jmp    f01047d3 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f01047b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01047bd:	78 8f                	js     f010474e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01047c2:	eb 9e                	jmp    f0104762 <vprintfmt+0x75>
f01047c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01047c7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01047ce:	eb 92                	jmp    f0104762 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01047d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01047d7:	79 89                	jns    f0104762 <vprintfmt+0x75>
f01047d9:	e9 7c ff ff ff       	jmp    f010475a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01047de:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01047e2:	e9 7b ff ff ff       	jmp    f0104762 <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01047e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01047ea:	8d 50 04             	lea    0x4(%eax),%edx
f01047ed:	89 55 14             	mov    %edx,0x14(%ebp)
f01047f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047f4:	8b 00                	mov    (%eax),%eax
f01047f6:	89 04 24             	mov    %eax,(%esp)
f01047f9:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01047ff:	e9 11 ff ff ff       	jmp    f0104715 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104804:	8b 45 14             	mov    0x14(%ebp),%eax
f0104807:	8d 50 04             	lea    0x4(%eax),%edx
f010480a:	89 55 14             	mov    %edx,0x14(%ebp)
f010480d:	8b 00                	mov    (%eax),%eax
f010480f:	85 c0                	test   %eax,%eax
f0104811:	79 02                	jns    f0104815 <vprintfmt+0x128>
f0104813:	f7 d8                	neg    %eax
f0104815:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104817:	83 f8 06             	cmp    $0x6,%eax
f010481a:	7f 0b                	jg     f0104827 <vprintfmt+0x13a>
f010481c:	8b 04 85 9c 6a 10 f0 	mov    -0xfef9564(,%eax,4),%eax
f0104823:	85 c0                	test   %eax,%eax
f0104825:	75 23                	jne    f010484a <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
f0104827:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010482b:	c7 44 24 08 d2 68 10 	movl   $0xf01068d2,0x8(%esp)
f0104832:	f0 
f0104833:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104837:	8b 55 08             	mov    0x8(%ebp),%edx
f010483a:	89 14 24             	mov    %edx,(%esp)
f010483d:	e8 83 fe ff ff       	call   f01046c5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104842:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104845:	e9 cb fe ff ff       	jmp    f0104715 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
f010484a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010484e:	c7 44 24 08 d1 5f 10 	movl   $0xf0105fd1,0x8(%esp)
f0104855:	f0 
f0104856:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010485a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010485d:	89 0c 24             	mov    %ecx,(%esp)
f0104860:	e8 60 fe ff ff       	call   f01046c5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104865:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104868:	e9 a8 fe ff ff       	jmp    f0104715 <vprintfmt+0x28>
f010486d:	89 f9                	mov    %edi,%ecx
f010486f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104872:	8b 45 14             	mov    0x14(%ebp),%eax
f0104875:	8d 50 04             	lea    0x4(%eax),%edx
f0104878:	89 55 14             	mov    %edx,0x14(%ebp)
f010487b:	8b 00                	mov    (%eax),%eax
f010487d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104880:	85 c0                	test   %eax,%eax
f0104882:	75 07                	jne    f010488b <vprintfmt+0x19e>
				p = "(null)";
f0104884:	c7 45 d4 cb 68 10 f0 	movl   $0xf01068cb,-0x2c(%ebp)
			if (width > 0 && padc != '-')
f010488b:	85 f6                	test   %esi,%esi
f010488d:	7e 3b                	jle    f01048ca <vprintfmt+0x1dd>
f010488f:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0104893:	74 35                	je     f01048ca <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104895:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104899:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010489c:	89 04 24             	mov    %eax,(%esp)
f010489f:	e8 6c 03 00 00       	call   f0104c10 <strnlen>
f01048a4:	29 c6                	sub    %eax,%esi
f01048a6:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01048a9:	85 f6                	test   %esi,%esi
f01048ab:	7e 1d                	jle    f01048ca <vprintfmt+0x1dd>
					putch(padc, putdat);
f01048ad:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01048b1:	89 7d d8             	mov    %edi,-0x28(%ebp)
f01048b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01048b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048bb:	89 34 24             	mov    %esi,(%esp)
f01048be:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01048c1:	4f                   	dec    %edi
f01048c2:	75 f3                	jne    f01048b7 <vprintfmt+0x1ca>
f01048c4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01048c7:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01048ca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01048cd:	0f be 02             	movsbl (%edx),%eax
f01048d0:	85 c0                	test   %eax,%eax
f01048d2:	75 43                	jne    f0104917 <vprintfmt+0x22a>
f01048d4:	eb 33                	jmp    f0104909 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
f01048d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01048da:	74 18                	je     f01048f4 <vprintfmt+0x207>
f01048dc:	8d 50 e0             	lea    -0x20(%eax),%edx
f01048df:	83 fa 5e             	cmp    $0x5e,%edx
f01048e2:	76 10                	jbe    f01048f4 <vprintfmt+0x207>
					putch('?', putdat);
f01048e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048e8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01048ef:	ff 55 08             	call   *0x8(%ebp)
f01048f2:	eb 0a                	jmp    f01048fe <vprintfmt+0x211>
				else
					putch(ch, putdat);
f01048f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048f8:	89 04 24             	mov    %eax,(%esp)
f01048fb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01048fe:	ff 4d e4             	decl   -0x1c(%ebp)
f0104901:	0f be 06             	movsbl (%esi),%eax
f0104904:	46                   	inc    %esi
f0104905:	85 c0                	test   %eax,%eax
f0104907:	75 12                	jne    f010491b <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104909:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010490d:	7f 15                	jg     f0104924 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010490f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104912:	e9 fe fd ff ff       	jmp    f0104715 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104917:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010491a:	46                   	inc    %esi
f010491b:	85 ff                	test   %edi,%edi
f010491d:	78 b7                	js     f01048d6 <vprintfmt+0x1e9>
f010491f:	4f                   	dec    %edi
f0104920:	79 b4                	jns    f01048d6 <vprintfmt+0x1e9>
f0104922:	eb e5                	jmp    f0104909 <vprintfmt+0x21c>
f0104924:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104927:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010492a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010492e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104935:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104937:	4e                   	dec    %esi
f0104938:	75 f0                	jne    f010492a <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010493a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010493d:	e9 d3 fd ff ff       	jmp    f0104715 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104942:	83 f9 01             	cmp    $0x1,%ecx
f0104945:	7e 10                	jle    f0104957 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0104947:	8b 45 14             	mov    0x14(%ebp),%eax
f010494a:	8d 50 08             	lea    0x8(%eax),%edx
f010494d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104950:	8b 30                	mov    (%eax),%esi
f0104952:	8b 78 04             	mov    0x4(%eax),%edi
f0104955:	eb 26                	jmp    f010497d <vprintfmt+0x290>
	else if (lflag)
f0104957:	85 c9                	test   %ecx,%ecx
f0104959:	74 12                	je     f010496d <vprintfmt+0x280>
		return va_arg(*ap, long);
f010495b:	8b 45 14             	mov    0x14(%ebp),%eax
f010495e:	8d 50 04             	lea    0x4(%eax),%edx
f0104961:	89 55 14             	mov    %edx,0x14(%ebp)
f0104964:	8b 30                	mov    (%eax),%esi
f0104966:	89 f7                	mov    %esi,%edi
f0104968:	c1 ff 1f             	sar    $0x1f,%edi
f010496b:	eb 10                	jmp    f010497d <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010496d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104970:	8d 50 04             	lea    0x4(%eax),%edx
f0104973:	89 55 14             	mov    %edx,0x14(%ebp)
f0104976:	8b 30                	mov    (%eax),%esi
f0104978:	89 f7                	mov    %esi,%edi
f010497a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010497d:	85 ff                	test   %edi,%edi
f010497f:	78 0e                	js     f010498f <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104981:	89 f0                	mov    %esi,%eax
f0104983:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104985:	be 0a 00 00 00       	mov    $0xa,%esi
f010498a:	e9 a8 00 00 00       	jmp    f0104a37 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010498f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104993:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010499a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010499d:	89 f0                	mov    %esi,%eax
f010499f:	89 fa                	mov    %edi,%edx
f01049a1:	f7 d8                	neg    %eax
f01049a3:	83 d2 00             	adc    $0x0,%edx
f01049a6:	f7 da                	neg    %edx
			}
			base = 10;
f01049a8:	be 0a 00 00 00       	mov    $0xa,%esi
f01049ad:	e9 85 00 00 00       	jmp    f0104a37 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01049b2:	89 ca                	mov    %ecx,%edx
f01049b4:	8d 45 14             	lea    0x14(%ebp),%eax
f01049b7:	e8 b5 fc ff ff       	call   f0104671 <getuint>
			base = 10;
f01049bc:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f01049c1:	eb 74                	jmp    f0104a37 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
f01049c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049c7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01049ce:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01049d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049d5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01049dc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01049df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01049ea:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01049ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01049f0:	e9 20 fd ff ff       	jmp    f0104715 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
f01049f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049f9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104a00:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104a03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a07:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104a0e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104a11:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a14:	8d 50 04             	lea    0x4(%eax),%edx
f0104a17:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104a1a:	8b 00                	mov    (%eax),%eax
f0104a1c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104a21:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0104a26:	eb 0f                	jmp    f0104a37 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104a28:	89 ca                	mov    %ecx,%edx
f0104a2a:	8d 45 14             	lea    0x14(%ebp),%eax
f0104a2d:	e8 3f fc ff ff       	call   f0104671 <getuint>
			base = 16;
f0104a32:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104a37:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0104a3b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104a3f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104a42:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104a46:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104a4a:	89 04 24             	mov    %eax,(%esp)
f0104a4d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a51:	89 da                	mov    %ebx,%edx
f0104a53:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a56:	e8 41 fb ff ff       	call   f010459c <printnum>
			break;
f0104a5b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a5e:	e9 b2 fc ff ff       	jmp    f0104715 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104a63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a67:	89 14 24             	mov    %edx,(%esp)
f0104a6a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a6d:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104a70:	e9 a0 fc ff ff       	jmp    f0104715 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104a75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a79:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104a80:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104a83:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104a87:	0f 84 88 fc ff ff    	je     f0104715 <vprintfmt+0x28>
f0104a8d:	4e                   	dec    %esi
f0104a8e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104a92:	75 f9                	jne    f0104a8d <vprintfmt+0x3a0>
f0104a94:	e9 7c fc ff ff       	jmp    f0104715 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
f0104a99:	83 c4 4c             	add    $0x4c,%esp
f0104a9c:	5b                   	pop    %ebx
f0104a9d:	5e                   	pop    %esi
f0104a9e:	5f                   	pop    %edi
f0104a9f:	5d                   	pop    %ebp
f0104aa0:	c3                   	ret    

f0104aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104aa1:	55                   	push   %ebp
f0104aa2:	89 e5                	mov    %esp,%ebp
f0104aa4:	83 ec 28             	sub    $0x28,%esp
f0104aa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104abe:	85 c0                	test   %eax,%eax
f0104ac0:	74 30                	je     f0104af2 <vsnprintf+0x51>
f0104ac2:	85 d2                	test   %edx,%edx
f0104ac4:	7e 33                	jle    f0104af9 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104ac6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104acd:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ad0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ad4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104adb:	c7 04 24 ab 46 10 f0 	movl   $0xf01046ab,(%esp)
f0104ae2:	e8 06 fc ff ff       	call   f01046ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104aea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104af0:	eb 0c                	jmp    f0104afe <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104af2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104af7:	eb 05                	jmp    f0104afe <vsnprintf+0x5d>
f0104af9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104afe:	c9                   	leave  
f0104aff:	c3                   	ret    

f0104b00 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104b00:	55                   	push   %ebp
f0104b01:	89 e5                	mov    %esp,%ebp
f0104b03:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104b06:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104b09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b0d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b10:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b1e:	89 04 24             	mov    %eax,(%esp)
f0104b21:	e8 7b ff ff ff       	call   f0104aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104b26:	c9                   	leave  
f0104b27:	c3                   	ret    

f0104b28 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104b28:	55                   	push   %ebp
f0104b29:	89 e5                	mov    %esp,%ebp
f0104b2b:	57                   	push   %edi
f0104b2c:	56                   	push   %esi
f0104b2d:	53                   	push   %ebx
f0104b2e:	83 ec 1c             	sub    $0x1c,%esp
f0104b31:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104b34:	85 c0                	test   %eax,%eax
f0104b36:	74 10                	je     f0104b48 <readline+0x20>
		cprintf("%s", prompt);
f0104b38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b3c:	c7 04 24 d1 5f 10 f0 	movl   $0xf0105fd1,(%esp)
f0104b43:	e8 48 ec ff ff       	call   f0103790 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104b48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104b4f:	e8 c5 ba ff ff       	call   f0100619 <iscons>
f0104b54:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104b56:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104b5b:	e8 a8 ba ff ff       	call   f0100608 <getchar>
f0104b60:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104b62:	85 c0                	test   %eax,%eax
f0104b64:	79 17                	jns    f0104b7d <readline+0x55>
			cprintf("read error: %e\n", c);
f0104b66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b6a:	c7 04 24 b8 6a 10 f0 	movl   $0xf0106ab8,(%esp)
f0104b71:	e8 1a ec ff ff       	call   f0103790 <cprintf>
			return NULL;
f0104b76:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b7b:	eb 69                	jmp    f0104be6 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104b7d:	83 f8 08             	cmp    $0x8,%eax
f0104b80:	74 05                	je     f0104b87 <readline+0x5f>
f0104b82:	83 f8 7f             	cmp    $0x7f,%eax
f0104b85:	75 17                	jne    f0104b9e <readline+0x76>
f0104b87:	85 f6                	test   %esi,%esi
f0104b89:	7e 13                	jle    f0104b9e <readline+0x76>
			if (echoing)
f0104b8b:	85 ff                	test   %edi,%edi
f0104b8d:	74 0c                	je     f0104b9b <readline+0x73>
				cputchar('\b');
f0104b8f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104b96:	e8 5d ba ff ff       	call   f01005f8 <cputchar>
			i--;
f0104b9b:	4e                   	dec    %esi
f0104b9c:	eb bd                	jmp    f0104b5b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104b9e:	83 fb 1f             	cmp    $0x1f,%ebx
f0104ba1:	7e 1d                	jle    f0104bc0 <readline+0x98>
f0104ba3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104ba9:	7f 15                	jg     f0104bc0 <readline+0x98>
			if (echoing)
f0104bab:	85 ff                	test   %edi,%edi
f0104bad:	74 08                	je     f0104bb7 <readline+0x8f>
				cputchar(c);
f0104baf:	89 1c 24             	mov    %ebx,(%esp)
f0104bb2:	e8 41 ba ff ff       	call   f01005f8 <cputchar>
			buf[i++] = c;
f0104bb7:	88 9e a0 ed 20 f0    	mov    %bl,-0xfdf1260(%esi)
f0104bbd:	46                   	inc    %esi
f0104bbe:	eb 9b                	jmp    f0104b5b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104bc0:	83 fb 0a             	cmp    $0xa,%ebx
f0104bc3:	74 05                	je     f0104bca <readline+0xa2>
f0104bc5:	83 fb 0d             	cmp    $0xd,%ebx
f0104bc8:	75 91                	jne    f0104b5b <readline+0x33>
			if (echoing)
f0104bca:	85 ff                	test   %edi,%edi
f0104bcc:	74 0c                	je     f0104bda <readline+0xb2>
				cputchar('\n');
f0104bce:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104bd5:	e8 1e ba ff ff       	call   f01005f8 <cputchar>
			buf[i] = 0;
f0104bda:	c6 86 a0 ed 20 f0 00 	movb   $0x0,-0xfdf1260(%esi)
			return buf;
f0104be1:	b8 a0 ed 20 f0       	mov    $0xf020eda0,%eax
		}
	}
}
f0104be6:	83 c4 1c             	add    $0x1c,%esp
f0104be9:	5b                   	pop    %ebx
f0104bea:	5e                   	pop    %esi
f0104beb:	5f                   	pop    %edi
f0104bec:	5d                   	pop    %ebp
f0104bed:	c3                   	ret    
	...

f0104bf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104bf0:	55                   	push   %ebp
f0104bf1:	89 e5                	mov    %esp,%ebp
f0104bf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104bf6:	80 3a 00             	cmpb   $0x0,(%edx)
f0104bf9:	74 0e                	je     f0104c09 <strlen+0x19>
f0104bfb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104c00:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104c01:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104c05:	75 f9                	jne    f0104c00 <strlen+0x10>
f0104c07:	eb 05                	jmp    f0104c0e <strlen+0x1e>
f0104c09:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104c0e:	5d                   	pop    %ebp
f0104c0f:	c3                   	ret    

f0104c10 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104c10:	55                   	push   %ebp
f0104c11:	89 e5                	mov    %esp,%ebp
f0104c13:	53                   	push   %ebx
f0104c14:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104c1a:	85 c9                	test   %ecx,%ecx
f0104c1c:	74 1a                	je     f0104c38 <strnlen+0x28>
f0104c1e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104c21:	74 1c                	je     f0104c3f <strnlen+0x2f>
f0104c23:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0104c28:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104c2a:	39 ca                	cmp    %ecx,%edx
f0104c2c:	74 16                	je     f0104c44 <strnlen+0x34>
f0104c2e:	42                   	inc    %edx
f0104c2f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104c34:	75 f2                	jne    f0104c28 <strnlen+0x18>
f0104c36:	eb 0c                	jmp    f0104c44 <strnlen+0x34>
f0104c38:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c3d:	eb 05                	jmp    f0104c44 <strnlen+0x34>
f0104c3f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104c44:	5b                   	pop    %ebx
f0104c45:	5d                   	pop    %ebp
f0104c46:	c3                   	ret    

f0104c47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104c47:	55                   	push   %ebp
f0104c48:	89 e5                	mov    %esp,%ebp
f0104c4a:	53                   	push   %ebx
f0104c4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104c51:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c56:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0104c59:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104c5c:	42                   	inc    %edx
f0104c5d:	84 c9                	test   %cl,%cl
f0104c5f:	75 f5                	jne    f0104c56 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104c61:	5b                   	pop    %ebx
f0104c62:	5d                   	pop    %ebp
f0104c63:	c3                   	ret    

f0104c64 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104c64:	55                   	push   %ebp
f0104c65:	89 e5                	mov    %esp,%ebp
f0104c67:	53                   	push   %ebx
f0104c68:	83 ec 08             	sub    $0x8,%esp
f0104c6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104c6e:	89 1c 24             	mov    %ebx,(%esp)
f0104c71:	e8 7a ff ff ff       	call   f0104bf0 <strlen>
	strcpy(dst + len, src);
f0104c76:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c79:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104c7d:	01 d8                	add    %ebx,%eax
f0104c7f:	89 04 24             	mov    %eax,(%esp)
f0104c82:	e8 c0 ff ff ff       	call   f0104c47 <strcpy>
	return dst;
}
f0104c87:	89 d8                	mov    %ebx,%eax
f0104c89:	83 c4 08             	add    $0x8,%esp
f0104c8c:	5b                   	pop    %ebx
f0104c8d:	5d                   	pop    %ebp
f0104c8e:	c3                   	ret    

f0104c8f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104c8f:	55                   	push   %ebp
f0104c90:	89 e5                	mov    %esp,%ebp
f0104c92:	56                   	push   %esi
f0104c93:	53                   	push   %ebx
f0104c94:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c97:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c9a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104c9d:	85 f6                	test   %esi,%esi
f0104c9f:	74 15                	je     f0104cb6 <strncpy+0x27>
f0104ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104ca6:	8a 1a                	mov    (%edx),%bl
f0104ca8:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104cab:	80 3a 01             	cmpb   $0x1,(%edx)
f0104cae:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104cb1:	41                   	inc    %ecx
f0104cb2:	39 f1                	cmp    %esi,%ecx
f0104cb4:	75 f0                	jne    f0104ca6 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104cb6:	5b                   	pop    %ebx
f0104cb7:	5e                   	pop    %esi
f0104cb8:	5d                   	pop    %ebp
f0104cb9:	c3                   	ret    

f0104cba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104cba:	55                   	push   %ebp
f0104cbb:	89 e5                	mov    %esp,%ebp
f0104cbd:	57                   	push   %edi
f0104cbe:	56                   	push   %esi
f0104cbf:	53                   	push   %ebx
f0104cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104cc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cc6:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104cc9:	85 f6                	test   %esi,%esi
f0104ccb:	74 31                	je     f0104cfe <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
f0104ccd:	83 fe 01             	cmp    $0x1,%esi
f0104cd0:	74 21                	je     f0104cf3 <strlcpy+0x39>
f0104cd2:	8a 0b                	mov    (%ebx),%cl
f0104cd4:	84 c9                	test   %cl,%cl
f0104cd6:	74 1f                	je     f0104cf7 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0104cd8:	83 ee 02             	sub    $0x2,%esi
f0104cdb:	89 f8                	mov    %edi,%eax
f0104cdd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104ce2:	88 08                	mov    %cl,(%eax)
f0104ce4:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104ce5:	39 f2                	cmp    %esi,%edx
f0104ce7:	74 10                	je     f0104cf9 <strlcpy+0x3f>
f0104ce9:	42                   	inc    %edx
f0104cea:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0104ced:	84 c9                	test   %cl,%cl
f0104cef:	75 f1                	jne    f0104ce2 <strlcpy+0x28>
f0104cf1:	eb 06                	jmp    f0104cf9 <strlcpy+0x3f>
f0104cf3:	89 f8                	mov    %edi,%eax
f0104cf5:	eb 02                	jmp    f0104cf9 <strlcpy+0x3f>
f0104cf7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104cf9:	c6 00 00             	movb   $0x0,(%eax)
f0104cfc:	eb 02                	jmp    f0104d00 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104cfe:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0104d00:	29 f8                	sub    %edi,%eax
}
f0104d02:	5b                   	pop    %ebx
f0104d03:	5e                   	pop    %esi
f0104d04:	5f                   	pop    %edi
f0104d05:	5d                   	pop    %ebp
f0104d06:	c3                   	ret    

f0104d07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104d07:	55                   	push   %ebp
f0104d08:	89 e5                	mov    %esp,%ebp
f0104d0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104d10:	8a 01                	mov    (%ecx),%al
f0104d12:	84 c0                	test   %al,%al
f0104d14:	74 11                	je     f0104d27 <strcmp+0x20>
f0104d16:	3a 02                	cmp    (%edx),%al
f0104d18:	75 0d                	jne    f0104d27 <strcmp+0x20>
		p++, q++;
f0104d1a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104d1b:	8a 41 01             	mov    0x1(%ecx),%al
f0104d1e:	84 c0                	test   %al,%al
f0104d20:	74 05                	je     f0104d27 <strcmp+0x20>
f0104d22:	41                   	inc    %ecx
f0104d23:	3a 02                	cmp    (%edx),%al
f0104d25:	74 f3                	je     f0104d1a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104d27:	0f b6 c0             	movzbl %al,%eax
f0104d2a:	0f b6 12             	movzbl (%edx),%edx
f0104d2d:	29 d0                	sub    %edx,%eax
}
f0104d2f:	5d                   	pop    %ebp
f0104d30:	c3                   	ret    

f0104d31 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104d31:	55                   	push   %ebp
f0104d32:	89 e5                	mov    %esp,%ebp
f0104d34:	53                   	push   %ebx
f0104d35:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d3b:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0104d3e:	85 c0                	test   %eax,%eax
f0104d40:	74 1b                	je     f0104d5d <strncmp+0x2c>
f0104d42:	8a 1a                	mov    (%edx),%bl
f0104d44:	84 db                	test   %bl,%bl
f0104d46:	74 24                	je     f0104d6c <strncmp+0x3b>
f0104d48:	3a 19                	cmp    (%ecx),%bl
f0104d4a:	75 20                	jne    f0104d6c <strncmp+0x3b>
f0104d4c:	48                   	dec    %eax
f0104d4d:	74 15                	je     f0104d64 <strncmp+0x33>
		n--, p++, q++;
f0104d4f:	42                   	inc    %edx
f0104d50:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104d51:	8a 1a                	mov    (%edx),%bl
f0104d53:	84 db                	test   %bl,%bl
f0104d55:	74 15                	je     f0104d6c <strncmp+0x3b>
f0104d57:	3a 19                	cmp    (%ecx),%bl
f0104d59:	74 f1                	je     f0104d4c <strncmp+0x1b>
f0104d5b:	eb 0f                	jmp    f0104d6c <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104d5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d62:	eb 05                	jmp    f0104d69 <strncmp+0x38>
f0104d64:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104d69:	5b                   	pop    %ebx
f0104d6a:	5d                   	pop    %ebp
f0104d6b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104d6c:	0f b6 02             	movzbl (%edx),%eax
f0104d6f:	0f b6 11             	movzbl (%ecx),%edx
f0104d72:	29 d0                	sub    %edx,%eax
f0104d74:	eb f3                	jmp    f0104d69 <strncmp+0x38>

f0104d76 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104d76:	55                   	push   %ebp
f0104d77:	89 e5                	mov    %esp,%ebp
f0104d79:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d7c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104d7f:	8a 10                	mov    (%eax),%dl
f0104d81:	84 d2                	test   %dl,%dl
f0104d83:	74 19                	je     f0104d9e <strchr+0x28>
		if (*s == c)
f0104d85:	38 ca                	cmp    %cl,%dl
f0104d87:	75 07                	jne    f0104d90 <strchr+0x1a>
f0104d89:	eb 18                	jmp    f0104da3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104d8b:	40                   	inc    %eax
		if (*s == c)
f0104d8c:	38 ca                	cmp    %cl,%dl
f0104d8e:	74 13                	je     f0104da3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104d90:	8a 50 01             	mov    0x1(%eax),%dl
f0104d93:	84 d2                	test   %dl,%dl
f0104d95:	75 f4                	jne    f0104d8b <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0104d97:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d9c:	eb 05                	jmp    f0104da3 <strchr+0x2d>
f0104d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104da3:	5d                   	pop    %ebp
f0104da4:	c3                   	ret    

f0104da5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104da5:	55                   	push   %ebp
f0104da6:	89 e5                	mov    %esp,%ebp
f0104da8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104dae:	8a 10                	mov    (%eax),%dl
f0104db0:	84 d2                	test   %dl,%dl
f0104db2:	74 11                	je     f0104dc5 <strfind+0x20>
		if (*s == c)
f0104db4:	38 ca                	cmp    %cl,%dl
f0104db6:	75 06                	jne    f0104dbe <strfind+0x19>
f0104db8:	eb 0b                	jmp    f0104dc5 <strfind+0x20>
f0104dba:	38 ca                	cmp    %cl,%dl
f0104dbc:	74 07                	je     f0104dc5 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104dbe:	40                   	inc    %eax
f0104dbf:	8a 10                	mov    (%eax),%dl
f0104dc1:	84 d2                	test   %dl,%dl
f0104dc3:	75 f5                	jne    f0104dba <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0104dc5:	5d                   	pop    %ebp
f0104dc6:	c3                   	ret    

f0104dc7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104dc7:	55                   	push   %ebp
f0104dc8:	89 e5                	mov    %esp,%ebp
f0104dca:	57                   	push   %edi
f0104dcb:	56                   	push   %esi
f0104dcc:	53                   	push   %ebx
f0104dcd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104dd6:	85 c9                	test   %ecx,%ecx
f0104dd8:	74 30                	je     f0104e0a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104dda:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104de0:	75 25                	jne    f0104e07 <memset+0x40>
f0104de2:	f6 c1 03             	test   $0x3,%cl
f0104de5:	75 20                	jne    f0104e07 <memset+0x40>
		c &= 0xFF;
f0104de7:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104dea:	89 d3                	mov    %edx,%ebx
f0104dec:	c1 e3 08             	shl    $0x8,%ebx
f0104def:	89 d6                	mov    %edx,%esi
f0104df1:	c1 e6 18             	shl    $0x18,%esi
f0104df4:	89 d0                	mov    %edx,%eax
f0104df6:	c1 e0 10             	shl    $0x10,%eax
f0104df9:	09 f0                	or     %esi,%eax
f0104dfb:	09 d0                	or     %edx,%eax
f0104dfd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104dff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104e02:	fc                   	cld    
f0104e03:	f3 ab                	rep stos %eax,%es:(%edi)
f0104e05:	eb 03                	jmp    f0104e0a <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104e07:	fc                   	cld    
f0104e08:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104e0a:	89 f8                	mov    %edi,%eax
f0104e0c:	5b                   	pop    %ebx
f0104e0d:	5e                   	pop    %esi
f0104e0e:	5f                   	pop    %edi
f0104e0f:	5d                   	pop    %ebp
f0104e10:	c3                   	ret    

f0104e11 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104e11:	55                   	push   %ebp
f0104e12:	89 e5                	mov    %esp,%ebp
f0104e14:	57                   	push   %edi
f0104e15:	56                   	push   %esi
f0104e16:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e19:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104e1f:	39 c6                	cmp    %eax,%esi
f0104e21:	73 34                	jae    f0104e57 <memmove+0x46>
f0104e23:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104e26:	39 d0                	cmp    %edx,%eax
f0104e28:	73 2d                	jae    f0104e57 <memmove+0x46>
		s += n;
		d += n;
f0104e2a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104e2d:	f6 c2 03             	test   $0x3,%dl
f0104e30:	75 1b                	jne    f0104e4d <memmove+0x3c>
f0104e32:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104e38:	75 13                	jne    f0104e4d <memmove+0x3c>
f0104e3a:	f6 c1 03             	test   $0x3,%cl
f0104e3d:	75 0e                	jne    f0104e4d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104e3f:	83 ef 04             	sub    $0x4,%edi
f0104e42:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104e45:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104e48:	fd                   	std    
f0104e49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104e4b:	eb 07                	jmp    f0104e54 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104e4d:	4f                   	dec    %edi
f0104e4e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104e51:	fd                   	std    
f0104e52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104e54:	fc                   	cld    
f0104e55:	eb 20                	jmp    f0104e77 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104e57:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104e5d:	75 13                	jne    f0104e72 <memmove+0x61>
f0104e5f:	a8 03                	test   $0x3,%al
f0104e61:	75 0f                	jne    f0104e72 <memmove+0x61>
f0104e63:	f6 c1 03             	test   $0x3,%cl
f0104e66:	75 0a                	jne    f0104e72 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104e68:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104e6b:	89 c7                	mov    %eax,%edi
f0104e6d:	fc                   	cld    
f0104e6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104e70:	eb 05                	jmp    f0104e77 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104e72:	89 c7                	mov    %eax,%edi
f0104e74:	fc                   	cld    
f0104e75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104e77:	5e                   	pop    %esi
f0104e78:	5f                   	pop    %edi
f0104e79:	5d                   	pop    %ebp
f0104e7a:	c3                   	ret    

f0104e7b <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104e7b:	55                   	push   %ebp
f0104e7c:	89 e5                	mov    %esp,%ebp
f0104e7e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104e81:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e92:	89 04 24             	mov    %eax,(%esp)
f0104e95:	e8 77 ff ff ff       	call   f0104e11 <memmove>
}
f0104e9a:	c9                   	leave  
f0104e9b:	c3                   	ret    

f0104e9c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104e9c:	55                   	push   %ebp
f0104e9d:	89 e5                	mov    %esp,%ebp
f0104e9f:	57                   	push   %edi
f0104ea0:	56                   	push   %esi
f0104ea1:	53                   	push   %ebx
f0104ea2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104ea5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ea8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104eab:	85 ff                	test   %edi,%edi
f0104ead:	74 31                	je     f0104ee0 <memcmp+0x44>
		if (*s1 != *s2)
f0104eaf:	8a 03                	mov    (%ebx),%al
f0104eb1:	8a 0e                	mov    (%esi),%cl
f0104eb3:	38 c8                	cmp    %cl,%al
f0104eb5:	74 18                	je     f0104ecf <memcmp+0x33>
f0104eb7:	eb 0c                	jmp    f0104ec5 <memcmp+0x29>
f0104eb9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0104ebd:	42                   	inc    %edx
f0104ebe:	8a 0c 16             	mov    (%esi,%edx,1),%cl
f0104ec1:	38 c8                	cmp    %cl,%al
f0104ec3:	74 10                	je     f0104ed5 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
f0104ec5:	0f b6 c0             	movzbl %al,%eax
f0104ec8:	0f b6 c9             	movzbl %cl,%ecx
f0104ecb:	29 c8                	sub    %ecx,%eax
f0104ecd:	eb 16                	jmp    f0104ee5 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104ecf:	4f                   	dec    %edi
f0104ed0:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ed5:	39 fa                	cmp    %edi,%edx
f0104ed7:	75 e0                	jne    f0104eb9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104ed9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ede:	eb 05                	jmp    f0104ee5 <memcmp+0x49>
f0104ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ee5:	5b                   	pop    %ebx
f0104ee6:	5e                   	pop    %esi
f0104ee7:	5f                   	pop    %edi
f0104ee8:	5d                   	pop    %ebp
f0104ee9:	c3                   	ret    

f0104eea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104eea:	55                   	push   %ebp
f0104eeb:	89 e5                	mov    %esp,%ebp
f0104eed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104ef0:	89 c2                	mov    %eax,%edx
f0104ef2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104ef5:	39 d0                	cmp    %edx,%eax
f0104ef7:	73 12                	jae    f0104f0b <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104ef9:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0104efc:	38 08                	cmp    %cl,(%eax)
f0104efe:	75 06                	jne    f0104f06 <memfind+0x1c>
f0104f00:	eb 09                	jmp    f0104f0b <memfind+0x21>
f0104f02:	38 08                	cmp    %cl,(%eax)
f0104f04:	74 05                	je     f0104f0b <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104f06:	40                   	inc    %eax
f0104f07:	39 d0                	cmp    %edx,%eax
f0104f09:	75 f7                	jne    f0104f02 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104f0b:	5d                   	pop    %ebp
f0104f0c:	c3                   	ret    

f0104f0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104f0d:	55                   	push   %ebp
f0104f0e:	89 e5                	mov    %esp,%ebp
f0104f10:	57                   	push   %edi
f0104f11:	56                   	push   %esi
f0104f12:	53                   	push   %ebx
f0104f13:	8b 55 08             	mov    0x8(%ebp),%edx
f0104f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104f19:	eb 01                	jmp    f0104f1c <strtol+0xf>
		s++;
f0104f1b:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104f1c:	8a 02                	mov    (%edx),%al
f0104f1e:	3c 20                	cmp    $0x20,%al
f0104f20:	74 f9                	je     f0104f1b <strtol+0xe>
f0104f22:	3c 09                	cmp    $0x9,%al
f0104f24:	74 f5                	je     f0104f1b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104f26:	3c 2b                	cmp    $0x2b,%al
f0104f28:	75 08                	jne    f0104f32 <strtol+0x25>
		s++;
f0104f2a:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104f2b:	bf 00 00 00 00       	mov    $0x0,%edi
f0104f30:	eb 13                	jmp    f0104f45 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104f32:	3c 2d                	cmp    $0x2d,%al
f0104f34:	75 0a                	jne    f0104f40 <strtol+0x33>
		s++, neg = 1;
f0104f36:	8d 52 01             	lea    0x1(%edx),%edx
f0104f39:	bf 01 00 00 00       	mov    $0x1,%edi
f0104f3e:	eb 05                	jmp    f0104f45 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104f40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104f45:	85 db                	test   %ebx,%ebx
f0104f47:	74 05                	je     f0104f4e <strtol+0x41>
f0104f49:	83 fb 10             	cmp    $0x10,%ebx
f0104f4c:	75 28                	jne    f0104f76 <strtol+0x69>
f0104f4e:	8a 02                	mov    (%edx),%al
f0104f50:	3c 30                	cmp    $0x30,%al
f0104f52:	75 10                	jne    f0104f64 <strtol+0x57>
f0104f54:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104f58:	75 0a                	jne    f0104f64 <strtol+0x57>
		s += 2, base = 16;
f0104f5a:	83 c2 02             	add    $0x2,%edx
f0104f5d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104f62:	eb 12                	jmp    f0104f76 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104f64:	85 db                	test   %ebx,%ebx
f0104f66:	75 0e                	jne    f0104f76 <strtol+0x69>
f0104f68:	3c 30                	cmp    $0x30,%al
f0104f6a:	75 05                	jne    f0104f71 <strtol+0x64>
		s++, base = 8;
f0104f6c:	42                   	inc    %edx
f0104f6d:	b3 08                	mov    $0x8,%bl
f0104f6f:	eb 05                	jmp    f0104f76 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104f71:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104f76:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f7b:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104f7d:	8a 0a                	mov    (%edx),%cl
f0104f7f:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104f82:	80 fb 09             	cmp    $0x9,%bl
f0104f85:	77 08                	ja     f0104f8f <strtol+0x82>
			dig = *s - '0';
f0104f87:	0f be c9             	movsbl %cl,%ecx
f0104f8a:	83 e9 30             	sub    $0x30,%ecx
f0104f8d:	eb 1e                	jmp    f0104fad <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104f8f:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104f92:	80 fb 19             	cmp    $0x19,%bl
f0104f95:	77 08                	ja     f0104f9f <strtol+0x92>
			dig = *s - 'a' + 10;
f0104f97:	0f be c9             	movsbl %cl,%ecx
f0104f9a:	83 e9 57             	sub    $0x57,%ecx
f0104f9d:	eb 0e                	jmp    f0104fad <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0104f9f:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104fa2:	80 fb 19             	cmp    $0x19,%bl
f0104fa5:	77 12                	ja     f0104fb9 <strtol+0xac>
			dig = *s - 'A' + 10;
f0104fa7:	0f be c9             	movsbl %cl,%ecx
f0104faa:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104fad:	39 f1                	cmp    %esi,%ecx
f0104faf:	7d 0c                	jge    f0104fbd <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0104fb1:	42                   	inc    %edx
f0104fb2:	0f af c6             	imul   %esi,%eax
f0104fb5:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104fb7:	eb c4                	jmp    f0104f7d <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104fb9:	89 c1                	mov    %eax,%ecx
f0104fbb:	eb 02                	jmp    f0104fbf <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104fbd:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104fbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104fc3:	74 05                	je     f0104fca <strtol+0xbd>
		*endptr = (char *) s;
f0104fc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104fc8:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104fca:	85 ff                	test   %edi,%edi
f0104fcc:	74 04                	je     f0104fd2 <strtol+0xc5>
f0104fce:	89 c8                	mov    %ecx,%eax
f0104fd0:	f7 d8                	neg    %eax
}
f0104fd2:	5b                   	pop    %ebx
f0104fd3:	5e                   	pop    %esi
f0104fd4:	5f                   	pop    %edi
f0104fd5:	5d                   	pop    %ebp
f0104fd6:	c3                   	ret    
	...

f0104fd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0104fd8:	55                   	push   %ebp
f0104fd9:	57                   	push   %edi
f0104fda:	56                   	push   %esi
f0104fdb:	83 ec 10             	sub    $0x10,%esp
f0104fde:	8b 74 24 20          	mov    0x20(%esp),%esi
f0104fe2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0104fee:	89 cd                	mov    %ecx,%ebp
f0104ff0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104ff4:	85 c0                	test   %eax,%eax
f0104ff6:	75 2c                	jne    f0105024 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104ff8:	39 f9                	cmp    %edi,%ecx
f0104ffa:	77 68                	ja     f0105064 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104ffc:	85 c9                	test   %ecx,%ecx
f0104ffe:	75 0b                	jne    f010500b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0105000:	b8 01 00 00 00       	mov    $0x1,%eax
f0105005:	31 d2                	xor    %edx,%edx
f0105007:	f7 f1                	div    %ecx
f0105009:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010500b:	31 d2                	xor    %edx,%edx
f010500d:	89 f8                	mov    %edi,%eax
f010500f:	f7 f1                	div    %ecx
f0105011:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105013:	89 f0                	mov    %esi,%eax
f0105015:	f7 f1                	div    %ecx
f0105017:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105019:	89 f0                	mov    %esi,%eax
f010501b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010501d:	83 c4 10             	add    $0x10,%esp
f0105020:	5e                   	pop    %esi
f0105021:	5f                   	pop    %edi
f0105022:	5d                   	pop    %ebp
f0105023:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105024:	39 f8                	cmp    %edi,%eax
f0105026:	77 2c                	ja     f0105054 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0105028:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f010502b:	83 f6 1f             	xor    $0x1f,%esi
f010502e:	75 4c                	jne    f010507c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0105030:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0105032:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0105037:	72 0a                	jb     f0105043 <__udivdi3+0x6b>
f0105039:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f010503d:	0f 87 ad 00 00 00    	ja     f01050f0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0105043:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105048:	89 f0                	mov    %esi,%eax
f010504a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010504c:	83 c4 10             	add    $0x10,%esp
f010504f:	5e                   	pop    %esi
f0105050:	5f                   	pop    %edi
f0105051:	5d                   	pop    %ebp
f0105052:	c3                   	ret    
f0105053:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105054:	31 ff                	xor    %edi,%edi
f0105056:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105058:	89 f0                	mov    %esi,%eax
f010505a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010505c:	83 c4 10             	add    $0x10,%esp
f010505f:	5e                   	pop    %esi
f0105060:	5f                   	pop    %edi
f0105061:	5d                   	pop    %ebp
f0105062:	c3                   	ret    
f0105063:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105064:	89 fa                	mov    %edi,%edx
f0105066:	89 f0                	mov    %esi,%eax
f0105068:	f7 f1                	div    %ecx
f010506a:	89 c6                	mov    %eax,%esi
f010506c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010506e:	89 f0                	mov    %esi,%eax
f0105070:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0105072:	83 c4 10             	add    $0x10,%esp
f0105075:	5e                   	pop    %esi
f0105076:	5f                   	pop    %edi
f0105077:	5d                   	pop    %ebp
f0105078:	c3                   	ret    
f0105079:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010507c:	89 f1                	mov    %esi,%ecx
f010507e:	d3 e0                	shl    %cl,%eax
f0105080:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0105084:	b8 20 00 00 00       	mov    $0x20,%eax
f0105089:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f010508b:	89 ea                	mov    %ebp,%edx
f010508d:	88 c1                	mov    %al,%cl
f010508f:	d3 ea                	shr    %cl,%edx
f0105091:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0105095:	09 ca                	or     %ecx,%edx
f0105097:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f010509b:	89 f1                	mov    %esi,%ecx
f010509d:	d3 e5                	shl    %cl,%ebp
f010509f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f01050a3:	89 fd                	mov    %edi,%ebp
f01050a5:	88 c1                	mov    %al,%cl
f01050a7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f01050a9:	89 fa                	mov    %edi,%edx
f01050ab:	89 f1                	mov    %esi,%ecx
f01050ad:	d3 e2                	shl    %cl,%edx
f01050af:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01050b3:	88 c1                	mov    %al,%cl
f01050b5:	d3 ef                	shr    %cl,%edi
f01050b7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01050b9:	89 f8                	mov    %edi,%eax
f01050bb:	89 ea                	mov    %ebp,%edx
f01050bd:	f7 74 24 08          	divl   0x8(%esp)
f01050c1:	89 d1                	mov    %edx,%ecx
f01050c3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01050c5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01050c9:	39 d1                	cmp    %edx,%ecx
f01050cb:	72 17                	jb     f01050e4 <__udivdi3+0x10c>
f01050cd:	74 09                	je     f01050d8 <__udivdi3+0x100>
f01050cf:	89 fe                	mov    %edi,%esi
f01050d1:	31 ff                	xor    %edi,%edi
f01050d3:	e9 41 ff ff ff       	jmp    f0105019 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01050d8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01050dc:	89 f1                	mov    %esi,%ecx
f01050de:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01050e0:	39 c2                	cmp    %eax,%edx
f01050e2:	73 eb                	jae    f01050cf <__udivdi3+0xf7>
		{
		  q0--;
f01050e4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01050e7:	31 ff                	xor    %edi,%edi
f01050e9:	e9 2b ff ff ff       	jmp    f0105019 <__udivdi3+0x41>
f01050ee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01050f0:	31 f6                	xor    %esi,%esi
f01050f2:	e9 22 ff ff ff       	jmp    f0105019 <__udivdi3+0x41>
	...

f01050f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01050f8:	55                   	push   %ebp
f01050f9:	57                   	push   %edi
f01050fa:	56                   	push   %esi
f01050fb:	83 ec 20             	sub    $0x20,%esp
f01050fe:	8b 44 24 30          	mov    0x30(%esp),%eax
f0105102:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0105106:	89 44 24 14          	mov    %eax,0x14(%esp)
f010510a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f010510e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105112:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0105116:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0105118:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010511a:	85 ed                	test   %ebp,%ebp
f010511c:	75 16                	jne    f0105134 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f010511e:	39 f1                	cmp    %esi,%ecx
f0105120:	0f 86 a6 00 00 00    	jbe    f01051cc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105126:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0105128:	89 d0                	mov    %edx,%eax
f010512a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010512c:	83 c4 20             	add    $0x20,%esp
f010512f:	5e                   	pop    %esi
f0105130:	5f                   	pop    %edi
f0105131:	5d                   	pop    %ebp
f0105132:	c3                   	ret    
f0105133:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105134:	39 f5                	cmp    %esi,%ebp
f0105136:	0f 87 ac 00 00 00    	ja     f01051e8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010513c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f010513f:	83 f0 1f             	xor    $0x1f,%eax
f0105142:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105146:	0f 84 a8 00 00 00    	je     f01051f4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010514c:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0105150:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0105152:	bf 20 00 00 00       	mov    $0x20,%edi
f0105157:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f010515b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010515f:	89 f9                	mov    %edi,%ecx
f0105161:	d3 e8                	shr    %cl,%eax
f0105163:	09 e8                	or     %ebp,%eax
f0105165:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0105169:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010516d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0105171:	d3 e0                	shl    %cl,%eax
f0105173:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0105177:	89 f2                	mov    %esi,%edx
f0105179:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f010517b:	8b 44 24 14          	mov    0x14(%esp),%eax
f010517f:	d3 e0                	shl    %cl,%eax
f0105181:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0105185:	8b 44 24 14          	mov    0x14(%esp),%eax
f0105189:	89 f9                	mov    %edi,%ecx
f010518b:	d3 e8                	shr    %cl,%eax
f010518d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010518f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0105191:	89 f2                	mov    %esi,%edx
f0105193:	f7 74 24 18          	divl   0x18(%esp)
f0105197:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0105199:	f7 64 24 0c          	mull   0xc(%esp)
f010519d:	89 c5                	mov    %eax,%ebp
f010519f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01051a1:	39 d6                	cmp    %edx,%esi
f01051a3:	72 67                	jb     f010520c <__umoddi3+0x114>
f01051a5:	74 75                	je     f010521c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01051a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01051ab:	29 e8                	sub    %ebp,%eax
f01051ad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01051af:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01051b3:	d3 e8                	shr    %cl,%eax
f01051b5:	89 f2                	mov    %esi,%edx
f01051b7:	89 f9                	mov    %edi,%ecx
f01051b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01051bb:	09 d0                	or     %edx,%eax
f01051bd:	89 f2                	mov    %esi,%edx
f01051bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01051c3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01051c5:	83 c4 20             	add    $0x20,%esp
f01051c8:	5e                   	pop    %esi
f01051c9:	5f                   	pop    %edi
f01051ca:	5d                   	pop    %ebp
f01051cb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01051cc:	85 c9                	test   %ecx,%ecx
f01051ce:	75 0b                	jne    f01051db <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01051d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01051d5:	31 d2                	xor    %edx,%edx
f01051d7:	f7 f1                	div    %ecx
f01051d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01051db:	89 f0                	mov    %esi,%eax
f01051dd:	31 d2                	xor    %edx,%edx
f01051df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01051e1:	89 f8                	mov    %edi,%eax
f01051e3:	e9 3e ff ff ff       	jmp    f0105126 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01051e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01051ea:	83 c4 20             	add    $0x20,%esp
f01051ed:	5e                   	pop    %esi
f01051ee:	5f                   	pop    %edi
f01051ef:	5d                   	pop    %ebp
f01051f0:	c3                   	ret    
f01051f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01051f4:	39 f5                	cmp    %esi,%ebp
f01051f6:	72 04                	jb     f01051fc <__umoddi3+0x104>
f01051f8:	39 f9                	cmp    %edi,%ecx
f01051fa:	77 06                	ja     f0105202 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01051fc:	89 f2                	mov    %esi,%edx
f01051fe:	29 cf                	sub    %ecx,%edi
f0105200:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0105202:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0105204:	83 c4 20             	add    $0x20,%esp
f0105207:	5e                   	pop    %esi
f0105208:	5f                   	pop    %edi
f0105209:	5d                   	pop    %ebp
f010520a:	c3                   	ret    
f010520b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010520c:	89 d1                	mov    %edx,%ecx
f010520e:	89 c5                	mov    %eax,%ebp
f0105210:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0105214:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0105218:	eb 8d                	jmp    f01051a7 <__umoddi3+0xaf>
f010521a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010521c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0105220:	72 ea                	jb     f010520c <__umoddi3+0x114>
f0105222:	89 f1                	mov    %esi,%ecx
f0105224:	eb 81                	jmp    f01051a7 <__umoddi3+0xaf>
