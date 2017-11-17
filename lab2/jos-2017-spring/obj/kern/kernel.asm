
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
	# until we set up our real page table in i386_vm_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 a0 1b 10 f0 	movl   $0xf0101ba0,(%esp)
f0100055:	e8 4e 0a 00 00       	call   f0100aa8 <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 c7 08 00 00       	call   f010094e <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 bc 1b 10 f0 	movl   $0xf0101bbc,(%esp)
f0100092:	e8 11 0a 00 00       	call   f0100aa8 <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	57                   	push   %edi
f01000a1:	53                   	push   %ebx
f01000a2:	81 ec 20 01 00 00    	sub    $0x120,%esp
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000a8:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
f01000ac:	c6 45 f6 00          	movb   $0x0,-0xa(%ebp)
f01000b0:	8d bd f6 fe ff ff    	lea    -0x10a(%ebp),%edi
f01000b6:	b9 00 01 00 00       	mov    $0x100,%ecx
f01000bb:	b0 00                	mov    $0x0,%al
f01000bd:	f3 aa                	rep stos %al,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000bf:	b8 80 a9 11 f0       	mov    $0xf011a980,%eax
f01000c4:	2d 04 a3 11 f0       	sub    $0xf011a304,%eax
f01000c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000d4:	00 
f01000d5:	c7 04 24 04 a3 11 f0 	movl   $0xf011a304,(%esp)
f01000dc:	e8 5b 16 00 00       	call   f010173c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000e1:	e8 20 05 00 00       	call   f0100606 <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01000e6:	8d 45 f6             	lea    -0xa(%ebp),%eax
f01000e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000ed:	8d 7d f7             	lea    -0x9(%ebp),%edi
f01000f0:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01000f4:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000fb:	00 
f01000fc:	c7 04 24 50 1c 10 f0 	movl   $0xf0101c50,(%esp)
f0100103:	e8 a0 09 00 00       	call   f0100aa8 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f0100108:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
f010010f:	00 
f0100110:	c7 04 24 70 1c 10 f0 	movl   $0xf0101c70,(%esp)
f0100117:	e8 8c 09 00 00       	call   f0100aa8 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010011c:	0f be 45 f6          	movsbl -0xa(%ebp),%eax
f0100120:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100124:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100128:	89 44 24 04          	mov    %eax,0x4(%esp)
f010012c:	c7 04 24 d7 1b 10 f0 	movl   $0xf0101bd7,(%esp)
f0100133:	e8 70 09 00 00       	call   f0100aa8 <cprintf>
	cprintf("%n", NULL);
f0100138:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010013f:	00 
f0100140:	c7 04 24 f0 1b 10 f0 	movl   $0xf0101bf0,(%esp)
f0100147:	e8 5c 09 00 00       	call   f0100aa8 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f010014c:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f0100153:	00 
f0100154:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f010015b:	00 
f010015c:	8d 9d f6 fe ff ff    	lea    -0x10a(%ebp),%ebx
f0100162:	89 1c 24             	mov    %ebx,(%esp)
f0100165:	e8 d2 15 00 00       	call   f010173c <memset>
	cprintf("%s%n", ntest, &chnum1); 
f010016a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010016e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100172:	c7 04 24 ee 1b 10 f0 	movl   $0xf0101bee,(%esp)
f0100179:	e8 2a 09 00 00       	call   f0100aa8 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010017e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100186:	c7 04 24 f3 1b 10 f0 	movl   $0xf0101bf3,(%esp)
f010018d:	e8 16 09 00 00       	call   f0100aa8 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f0100192:	c7 44 24 08 00 fc ff 	movl   $0xfffffc00,0x8(%esp)
f0100199:	ff 
f010019a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01001a1:	00 
f01001a2:	c7 04 24 ff 1b 10 f0 	movl   $0xf0101bff,(%esp)
f01001a9:	e8 fa 08 00 00       	call   f0100aa8 <cprintf>


	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01001ae:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01001b5:	e8 86 fe ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01001ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001c1:	e8 55 06 00 00       	call   f010081b <monitor>
f01001c6:	eb f2                	jmp    f01001ba <i386_init+0x11d>

f01001c8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01001c8:	55                   	push   %ebp
f01001c9:	89 e5                	mov    %esp,%ebp
f01001cb:	56                   	push   %esi
f01001cc:	53                   	push   %ebx
f01001cd:	83 ec 10             	sub    $0x10,%esp
f01001d0:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01001d3:	83 3d 20 a3 11 f0 00 	cmpl   $0x0,0xf011a320
f01001da:	75 3d                	jne    f0100219 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01001dc:	89 35 20 a3 11 f0    	mov    %esi,0xf011a320

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01001e2:	fa                   	cli    
f01001e3:	fc                   	cld    

	va_start(ap, fmt);
f01001e4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01001e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01001ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001f5:	c7 04 24 1b 1c 10 f0 	movl   $0xf0101c1b,(%esp)
f01001fc:	e8 a7 08 00 00       	call   f0100aa8 <cprintf>
	vcprintf(fmt, ap);
f0100201:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100205:	89 34 24             	mov    %esi,(%esp)
f0100208:	e8 68 08 00 00       	call   f0100a75 <vcprintf>
	cprintf("\n");
f010020d:	c7 04 24 a9 1c 10 f0 	movl   $0xf0101ca9,(%esp)
f0100214:	e8 8f 08 00 00       	call   f0100aa8 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100219:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100220:	e8 f6 05 00 00       	call   f010081b <monitor>
f0100225:	eb f2                	jmp    f0100219 <_panic+0x51>

f0100227 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100227:	55                   	push   %ebp
f0100228:	89 e5                	mov    %esp,%ebp
f010022a:	53                   	push   %ebx
f010022b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010022e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100231:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100234:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100238:	8b 45 08             	mov    0x8(%ebp),%eax
f010023b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010023f:	c7 04 24 33 1c 10 f0 	movl   $0xf0101c33,(%esp)
f0100246:	e8 5d 08 00 00       	call   f0100aa8 <cprintf>
	vcprintf(fmt, ap);
f010024b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010024f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100252:	89 04 24             	mov    %eax,(%esp)
f0100255:	e8 1b 08 00 00       	call   f0100a75 <vcprintf>
	cprintf("\n");
f010025a:	c7 04 24 a9 1c 10 f0 	movl   $0xf0101ca9,(%esp)
f0100261:	e8 42 08 00 00       	call   f0100aa8 <cprintf>
	va_end(ap);
}
f0100266:	83 c4 14             	add    $0x14,%esp
f0100269:	5b                   	pop    %ebx
f010026a:	5d                   	pop    %ebp
f010026b:	c3                   	ret    

f010026c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010026c:	55                   	push   %ebp
f010026d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010026f:	ba 84 00 00 00       	mov    $0x84,%edx
f0100274:	ec                   	in     (%dx),%al
f0100275:	ec                   	in     (%dx),%al
f0100276:	ec                   	in     (%dx),%al
f0100277:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100278:	5d                   	pop    %ebp
f0100279:	c3                   	ret    

f010027a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010027a:	55                   	push   %ebp
f010027b:	89 e5                	mov    %esp,%ebp
f010027d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100282:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100283:	a8 01                	test   $0x1,%al
f0100285:	74 08                	je     f010028f <serial_proc_data+0x15>
f0100287:	b2 f8                	mov    $0xf8,%dl
f0100289:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028a:	0f b6 c0             	movzbl %al,%eax
f010028d:	eb 05                	jmp    f0100294 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100294:	5d                   	pop    %ebp
f0100295:	c3                   	ret    

f0100296 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100296:	55                   	push   %ebp
f0100297:	89 e5                	mov    %esp,%ebp
f0100299:	53                   	push   %ebx
f010029a:	83 ec 04             	sub    $0x4,%esp
f010029d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029f:	eb 29                	jmp    f01002ca <cons_intr+0x34>
		if (c == 0)
f01002a1:	85 c0                	test   %eax,%eax
f01002a3:	74 25                	je     f01002ca <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a5:	8b 15 64 a5 11 f0    	mov    0xf011a564,%edx
f01002ab:	88 82 60 a3 11 f0    	mov    %al,-0xfee5ca0(%edx)
f01002b1:	8d 42 01             	lea    0x1(%edx),%eax
f01002b4:	a3 64 a5 11 f0       	mov    %eax,0xf011a564
		if (cons.wpos == CONSBUFSIZE)
f01002b9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01002be:	75 0a                	jne    f01002ca <cons_intr+0x34>
			cons.wpos = 0;
f01002c0:	c7 05 64 a5 11 f0 00 	movl   $0x0,0xf011a564
f01002c7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002ca:	ff d3                	call   *%ebx
f01002cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002cf:	75 d0                	jne    f01002a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d1:	83 c4 04             	add    $0x4,%esp
f01002d4:	5b                   	pop    %ebx
f01002d5:	5d                   	pop    %ebp
f01002d6:	c3                   	ret    

f01002d7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002d7:	55                   	push   %ebp
f01002d8:	89 e5                	mov    %esp,%ebp
f01002da:	57                   	push   %edi
f01002db:	56                   	push   %esi
f01002dc:	53                   	push   %ebx
f01002dd:	83 ec 1c             	sub    $0x1c,%esp
f01002e0:	89 c6                	mov    %eax,%esi
f01002e2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e7:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002e8:	a8 20                	test   $0x20,%al
f01002ea:	75 19                	jne    f0100305 <cons_putc+0x2e>
f01002ec:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01002f1:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01002f6:	e8 71 ff ff ff       	call   f010026c <delay>
f01002fb:	89 fa                	mov    %edi,%edx
f01002fd:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002fe:	a8 20                	test   $0x20,%al
f0100300:	75 03                	jne    f0100305 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100302:	4b                   	dec    %ebx
f0100303:	75 f1                	jne    f01002f6 <cons_putc+0x1f>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100305:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100307:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010030c:	89 f0                	mov    %esi,%eax
f010030e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030f:	b2 79                	mov    $0x79,%dl
f0100311:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100312:	84 c0                	test   %al,%al
f0100314:	78 17                	js     f010032d <cons_putc+0x56>
f0100316:	bb 00 32 00 00       	mov    $0x3200,%ebx
		delay();
f010031b:	e8 4c ff ff ff       	call   f010026c <delay>
f0100320:	ba 79 03 00 00       	mov    $0x379,%edx
f0100325:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100326:	84 c0                	test   %al,%al
f0100328:	78 03                	js     f010032d <cons_putc+0x56>
f010032a:	4b                   	dec    %ebx
f010032b:	75 ee                	jne    f010031b <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	ee                   	out    %al,(%dx)
f0100335:	b2 7a                	mov    $0x7a,%dl
f0100337:	b0 0d                	mov    $0xd,%al
f0100339:	ee                   	out    %al,(%dx)
f010033a:	b0 08                	mov    $0x8,%al
f010033c:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010033d:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100343:	75 06                	jne    f010034b <cons_putc+0x74>
		c |= 0x0700;
f0100345:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010034b:	89 f0                	mov    %esi,%eax
f010034d:	25 ff 00 00 00       	and    $0xff,%eax
f0100352:	83 f8 09             	cmp    $0x9,%eax
f0100355:	74 78                	je     f01003cf <cons_putc+0xf8>
f0100357:	83 f8 09             	cmp    $0x9,%eax
f010035a:	7f 0b                	jg     f0100367 <cons_putc+0x90>
f010035c:	83 f8 08             	cmp    $0x8,%eax
f010035f:	0f 85 9e 00 00 00    	jne    f0100403 <cons_putc+0x12c>
f0100365:	eb 10                	jmp    f0100377 <cons_putc+0xa0>
f0100367:	83 f8 0a             	cmp    $0xa,%eax
f010036a:	74 39                	je     f01003a5 <cons_putc+0xce>
f010036c:	83 f8 0d             	cmp    $0xd,%eax
f010036f:	0f 85 8e 00 00 00    	jne    f0100403 <cons_putc+0x12c>
f0100375:	eb 36                	jmp    f01003ad <cons_putc+0xd6>
	case '\b':
		if (crt_pos > 0) {
f0100377:	66 a1 74 a5 11 f0    	mov    0xf011a574,%ax
f010037d:	66 85 c0             	test   %ax,%ax
f0100380:	0f 84 e2 00 00 00    	je     f0100468 <cons_putc+0x191>
			crt_pos--;
f0100386:	48                   	dec    %eax
f0100387:	66 a3 74 a5 11 f0    	mov    %ax,0xf011a574
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010038d:	0f b7 c0             	movzwl %ax,%eax
f0100390:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100396:	83 ce 20             	or     $0x20,%esi
f0100399:	8b 15 70 a5 11 f0    	mov    0xf011a570,%edx
f010039f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01003a3:	eb 78                	jmp    f010041d <cons_putc+0x146>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003a5:	66 83 05 74 a5 11 f0 	addw   $0x50,0xf011a574
f01003ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003ad:	66 8b 0d 74 a5 11 f0 	mov    0xf011a574,%cx
f01003b4:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003b9:	89 c8                	mov    %ecx,%eax
f01003bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01003c0:	66 f7 f3             	div    %bx
f01003c3:	66 29 d1             	sub    %dx,%cx
f01003c6:	66 89 0d 74 a5 11 f0 	mov    %cx,0xf011a574
f01003cd:	eb 4e                	jmp    f010041d <cons_putc+0x146>
		break;
	case '\t':
		cons_putc(' ');
f01003cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d4:	e8 fe fe ff ff       	call   f01002d7 <cons_putc>
		cons_putc(' ');
f01003d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003de:	e8 f4 fe ff ff       	call   f01002d7 <cons_putc>
		cons_putc(' ');
f01003e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e8:	e8 ea fe ff ff       	call   f01002d7 <cons_putc>
		cons_putc(' ');
f01003ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f2:	e8 e0 fe ff ff       	call   f01002d7 <cons_putc>
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 d6 fe ff ff       	call   f01002d7 <cons_putc>
f0100401:	eb 1a                	jmp    f010041d <cons_putc+0x146>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100403:	66 a1 74 a5 11 f0    	mov    0xf011a574,%ax
f0100409:	0f b7 c8             	movzwl %ax,%ecx
f010040c:	8b 15 70 a5 11 f0    	mov    0xf011a570,%edx
f0100412:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100416:	40                   	inc    %eax
f0100417:	66 a3 74 a5 11 f0    	mov    %ax,0xf011a574
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010041d:	66 81 3d 74 a5 11 f0 	cmpw   $0x7cf,0xf011a574
f0100424:	cf 07 
f0100426:	76 40                	jbe    f0100468 <cons_putc+0x191>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100428:	a1 70 a5 11 f0       	mov    0xf011a570,%eax
f010042d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100434:	00 
f0100435:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010043b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010043f:	89 04 24             	mov    %eax,(%esp)
f0100442:	e8 3f 13 00 00       	call   f0101786 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100447:	8b 15 70 a5 11 f0    	mov    0xf011a570,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010044d:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100452:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100458:	40                   	inc    %eax
f0100459:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010045e:	75 f2                	jne    f0100452 <cons_putc+0x17b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100460:	66 83 2d 74 a5 11 f0 	subw   $0x50,0xf011a574
f0100467:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100468:	8b 0d 6c a5 11 f0    	mov    0xf011a56c,%ecx
f010046e:	b0 0e                	mov    $0xe,%al
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100473:	66 8b 35 74 a5 11 f0 	mov    0xf011a574,%si
f010047a:	8d 59 01             	lea    0x1(%ecx),%ebx
f010047d:	89 f0                	mov    %esi,%eax
f010047f:	66 c1 e8 08          	shr    $0x8,%ax
f0100483:	89 da                	mov    %ebx,%edx
f0100485:	ee                   	out    %al,(%dx)
f0100486:	b0 0f                	mov    $0xf,%al
f0100488:	89 ca                	mov    %ecx,%edx
f010048a:	ee                   	out    %al,(%dx)
f010048b:	89 f0                	mov    %esi,%eax
f010048d:	89 da                	mov    %ebx,%edx
f010048f:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100490:	83 c4 1c             	add    $0x1c,%esp
f0100493:	5b                   	pop    %ebx
f0100494:	5e                   	pop    %esi
f0100495:	5f                   	pop    %edi
f0100496:	5d                   	pop    %ebp
f0100497:	c3                   	ret    

f0100498 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100498:	55                   	push   %ebp
f0100499:	89 e5                	mov    %esp,%ebp
f010049b:	53                   	push   %ebx
f010049c:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010049f:	ba 64 00 00 00       	mov    $0x64,%edx
f01004a4:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01004a5:	a8 01                	test   $0x1,%al
f01004a7:	0f 84 d8 00 00 00    	je     f0100585 <kbd_proc_data+0xed>
f01004ad:	b2 60                	mov    $0x60,%dl
f01004af:	ec                   	in     (%dx),%al
f01004b0:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01004b2:	3c e0                	cmp    $0xe0,%al
f01004b4:	75 11                	jne    f01004c7 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01004b6:	83 0d 68 a5 11 f0 40 	orl    $0x40,0xf011a568
		return 0;
f01004bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004c2:	e9 c3 00 00 00       	jmp    f010058a <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f01004c7:	84 c0                	test   %al,%al
f01004c9:	79 33                	jns    f01004fe <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01004cb:	8b 0d 68 a5 11 f0    	mov    0xf011a568,%ecx
f01004d1:	f6 c1 40             	test   $0x40,%cl
f01004d4:	75 05                	jne    f01004db <kbd_proc_data+0x43>
f01004d6:	88 c2                	mov    %al,%dl
f01004d8:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01004db:	0f b6 d2             	movzbl %dl,%edx
f01004de:	8a 82 e0 1c 10 f0    	mov    -0xfefe320(%edx),%al
f01004e4:	83 c8 40             	or     $0x40,%eax
f01004e7:	0f b6 c0             	movzbl %al,%eax
f01004ea:	f7 d0                	not    %eax
f01004ec:	21 c1                	and    %eax,%ecx
f01004ee:	89 0d 68 a5 11 f0    	mov    %ecx,0xf011a568
		return 0;
f01004f4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004f9:	e9 8c 00 00 00       	jmp    f010058a <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f01004fe:	8b 0d 68 a5 11 f0    	mov    0xf011a568,%ecx
f0100504:	f6 c1 40             	test   $0x40,%cl
f0100507:	74 0e                	je     f0100517 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100509:	88 c2                	mov    %al,%dl
f010050b:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010050e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100511:	89 0d 68 a5 11 f0    	mov    %ecx,0xf011a568
	}

	shift |= shiftcode[data];
f0100517:	0f b6 d2             	movzbl %dl,%edx
f010051a:	0f b6 82 e0 1c 10 f0 	movzbl -0xfefe320(%edx),%eax
f0100521:	0b 05 68 a5 11 f0    	or     0xf011a568,%eax
	shift ^= togglecode[data];
f0100527:	0f b6 8a e0 1d 10 f0 	movzbl -0xfefe220(%edx),%ecx
f010052e:	31 c8                	xor    %ecx,%eax
f0100530:	a3 68 a5 11 f0       	mov    %eax,0xf011a568

	c = charcode[shift & (CTL | SHIFT)][data];
f0100535:	89 c1                	mov    %eax,%ecx
f0100537:	83 e1 03             	and    $0x3,%ecx
f010053a:	8b 0c 8d e0 1e 10 f0 	mov    -0xfefe120(,%ecx,4),%ecx
f0100541:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100545:	a8 08                	test   $0x8,%al
f0100547:	74 18                	je     f0100561 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100549:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010054c:	83 fa 19             	cmp    $0x19,%edx
f010054f:	77 05                	ja     f0100556 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100551:	83 eb 20             	sub    $0x20,%ebx
f0100554:	eb 0b                	jmp    f0100561 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100556:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100559:	83 fa 19             	cmp    $0x19,%edx
f010055c:	77 03                	ja     f0100561 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010055e:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100561:	f7 d0                	not    %eax
f0100563:	a8 06                	test   $0x6,%al
f0100565:	75 23                	jne    f010058a <kbd_proc_data+0xf2>
f0100567:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010056d:	75 1b                	jne    f010058a <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f010056f:	c7 04 24 9f 1c 10 f0 	movl   $0xf0101c9f,(%esp)
f0100576:	e8 2d 05 00 00       	call   f0100aa8 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100580:	b0 03                	mov    $0x3,%al
f0100582:	ee                   	out    %al,(%dx)
f0100583:	eb 05                	jmp    f010058a <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100585:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010058a:	89 d8                	mov    %ebx,%eax
f010058c:	83 c4 14             	add    $0x14,%esp
f010058f:	5b                   	pop    %ebx
f0100590:	5d                   	pop    %ebp
f0100591:	c3                   	ret    

f0100592 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100592:	55                   	push   %ebp
f0100593:	89 e5                	mov    %esp,%ebp
f0100595:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100598:	83 3d 40 a3 11 f0 00 	cmpl   $0x0,0xf011a340
f010059f:	74 0a                	je     f01005ab <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01005a1:	b8 7a 02 10 f0       	mov    $0xf010027a,%eax
f01005a6:	e8 eb fc ff ff       	call   f0100296 <cons_intr>
}
f01005ab:	c9                   	leave  
f01005ac:	c3                   	ret    

f01005ad <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005ad:	55                   	push   %ebp
f01005ae:	89 e5                	mov    %esp,%ebp
f01005b0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005b3:	b8 98 04 10 f0       	mov    $0xf0100498,%eax
f01005b8:	e8 d9 fc ff ff       	call   f0100296 <cons_intr>
}
f01005bd:	c9                   	leave  
f01005be:	c3                   	ret    

f01005bf <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005bf:	55                   	push   %ebp
f01005c0:	89 e5                	mov    %esp,%ebp
f01005c2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005c5:	e8 c8 ff ff ff       	call   f0100592 <serial_intr>
	kbd_intr();
f01005ca:	e8 de ff ff ff       	call   f01005ad <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005cf:	8b 15 60 a5 11 f0    	mov    0xf011a560,%edx
f01005d5:	3b 15 64 a5 11 f0    	cmp    0xf011a564,%edx
f01005db:	74 22                	je     f01005ff <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01005dd:	0f b6 82 60 a3 11 f0 	movzbl -0xfee5ca0(%edx),%eax
f01005e4:	42                   	inc    %edx
f01005e5:	89 15 60 a5 11 f0    	mov    %edx,0xf011a560
		if (cons.rpos == CONSBUFSIZE)
f01005eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01005f1:	75 11                	jne    f0100604 <cons_getc+0x45>
			cons.rpos = 0;
f01005f3:	c7 05 60 a5 11 f0 00 	movl   $0x0,0xf011a560
f01005fa:	00 00 00 
f01005fd:	eb 05                	jmp    f0100604 <cons_getc+0x45>
		return c;
	}
	return 0;
f01005ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100604:	c9                   	leave  
f0100605:	c3                   	ret    

f0100606 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100606:	55                   	push   %ebp
f0100607:	89 e5                	mov    %esp,%ebp
f0100609:	57                   	push   %edi
f010060a:	56                   	push   %esi
f010060b:	53                   	push   %ebx
f010060c:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010060f:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100616:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010061d:	5a a5 
	if (*cp != 0xA55A) {
f010061f:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100625:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100629:	74 11                	je     f010063c <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010062b:	c7 05 6c a5 11 f0 b4 	movl   $0x3b4,0xf011a56c
f0100632:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100635:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010063a:	eb 16                	jmp    f0100652 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010063c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100643:	c7 05 6c a5 11 f0 d4 	movl   $0x3d4,0xf011a56c
f010064a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010064d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100652:	8b 0d 6c a5 11 f0    	mov    0xf011a56c,%ecx
f0100658:	b0 0e                	mov    $0xe,%al
f010065a:	89 ca                	mov    %ecx,%edx
f010065c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065d:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100660:	89 da                	mov    %ebx,%edx
f0100662:	ec                   	in     (%dx),%al
f0100663:	0f b6 f8             	movzbl %al,%edi
f0100666:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100669:	b0 0f                	mov    $0xf,%al
f010066b:	89 ca                	mov    %ecx,%edx
f010066d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066e:	89 da                	mov    %ebx,%edx
f0100670:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100671:	89 35 70 a5 11 f0    	mov    %esi,0xf011a570
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100677:	0f b6 d8             	movzbl %al,%ebx
f010067a:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010067c:	66 89 3d 74 a5 11 f0 	mov    %di,0xf011a574
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100683:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100688:	b0 00                	mov    $0x0,%al
f010068a:	89 da                	mov    %ebx,%edx
f010068c:	ee                   	out    %al,(%dx)
f010068d:	b2 fb                	mov    $0xfb,%dl
f010068f:	b0 80                	mov    $0x80,%al
f0100691:	ee                   	out    %al,(%dx)
f0100692:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100697:	b0 0c                	mov    $0xc,%al
f0100699:	89 ca                	mov    %ecx,%edx
f010069b:	ee                   	out    %al,(%dx)
f010069c:	b2 f9                	mov    $0xf9,%dl
f010069e:	b0 00                	mov    $0x0,%al
f01006a0:	ee                   	out    %al,(%dx)
f01006a1:	b2 fb                	mov    $0xfb,%dl
f01006a3:	b0 03                	mov    $0x3,%al
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	b2 fc                	mov    $0xfc,%dl
f01006a8:	b0 00                	mov    $0x0,%al
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b2 f9                	mov    $0xf9,%dl
f01006ad:	b0 01                	mov    $0x1,%al
f01006af:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b0:	b2 fd                	mov    $0xfd,%dl
f01006b2:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006b3:	3c ff                	cmp    $0xff,%al
f01006b5:	0f 95 c0             	setne  %al
f01006b8:	0f b6 c0             	movzbl %al,%eax
f01006bb:	89 c6                	mov    %eax,%esi
f01006bd:	a3 40 a3 11 f0       	mov    %eax,0xf011a340
f01006c2:	89 da                	mov    %ebx,%edx
f01006c4:	ec                   	in     (%dx),%al
f01006c5:	89 ca                	mov    %ecx,%edx
f01006c7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006c8:	85 f6                	test   %esi,%esi
f01006ca:	75 0c                	jne    f01006d8 <cons_init+0xd2>
		cprintf("Serial port does not exist!\n");
f01006cc:	c7 04 24 ab 1c 10 f0 	movl   $0xf0101cab,(%esp)
f01006d3:	e8 d0 03 00 00       	call   f0100aa8 <cprintf>
}
f01006d8:	83 c4 1c             	add    $0x1c,%esp
f01006db:	5b                   	pop    %ebx
f01006dc:	5e                   	pop    %esi
f01006dd:	5f                   	pop    %edi
f01006de:	5d                   	pop    %ebp
f01006df:	c3                   	ret    

f01006e0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006e0:	55                   	push   %ebp
f01006e1:	89 e5                	mov    %esp,%ebp
f01006e3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e9:	e8 e9 fb ff ff       	call   f01002d7 <cons_putc>
}
f01006ee:	c9                   	leave  
f01006ef:	c3                   	ret    

f01006f0 <getchar>:

int
getchar(void)
{
f01006f0:	55                   	push   %ebp
f01006f1:	89 e5                	mov    %esp,%ebp
f01006f3:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f6:	e8 c4 fe ff ff       	call   f01005bf <cons_getc>
f01006fb:	85 c0                	test   %eax,%eax
f01006fd:	74 f7                	je     f01006f6 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006ff:	c9                   	leave  
f0100700:	c3                   	ret    

f0100701 <iscons>:

int
iscons(int fdnum)
{
f0100701:	55                   	push   %ebp
f0100702:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100704:	b8 01 00 00 00       	mov    $0x1,%eax
f0100709:	5d                   	pop    %ebp
f010070a:	c3                   	ret    
	...

f010070c <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010070c:	55                   	push   %ebp
f010070d:	89 e5                	mov    %esp,%ebp
f010070f:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100712:	c7 04 24 f0 1e 10 f0 	movl   $0xf0101ef0,(%esp)
f0100719:	e8 8a 03 00 00       	call   f0100aa8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010071e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100725:	00 
f0100726:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010072d:	f0 
f010072e:	c7 04 24 d4 1f 10 f0 	movl   $0xf0101fd4,(%esp)
f0100735:	e8 6e 03 00 00       	call   f0100aa8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010073a:	c7 44 24 08 9a 1b 10 	movl   $0x101b9a,0x8(%esp)
f0100741:	00 
f0100742:	c7 44 24 04 9a 1b 10 	movl   $0xf0101b9a,0x4(%esp)
f0100749:	f0 
f010074a:	c7 04 24 f8 1f 10 f0 	movl   $0xf0101ff8,(%esp)
f0100751:	e8 52 03 00 00       	call   f0100aa8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100756:	c7 44 24 08 04 a3 11 	movl   $0x11a304,0x8(%esp)
f010075d:	00 
f010075e:	c7 44 24 04 04 a3 11 	movl   $0xf011a304,0x4(%esp)
f0100765:	f0 
f0100766:	c7 04 24 1c 20 10 f0 	movl   $0xf010201c,(%esp)
f010076d:	e8 36 03 00 00       	call   f0100aa8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100772:	c7 44 24 08 80 a9 11 	movl   $0x11a980,0x8(%esp)
f0100779:	00 
f010077a:	c7 44 24 04 80 a9 11 	movl   $0xf011a980,0x4(%esp)
f0100781:	f0 
f0100782:	c7 04 24 40 20 10 f0 	movl   $0xf0102040,(%esp)
f0100789:	e8 1a 03 00 00       	call   f0100aa8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
f010078e:	b8 7f ad 11 f0       	mov    $0xf011ad7f,%eax
f0100793:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100798:	89 c2                	mov    %eax,%edx
f010079a:	85 c0                	test   %eax,%eax
f010079c:	79 06                	jns    f01007a4 <mon_kerninfo+0x98>
f010079e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007a4:	c1 fa 0a             	sar    $0xa,%edx
f01007a7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01007ab:	c7 04 24 64 20 10 f0 	movl   $0xf0102064,(%esp)
f01007b2:	e8 f1 02 00 00       	call   f0100aa8 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01007b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bc:	c9                   	leave  
f01007bd:	c3                   	ret    

f01007be <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
f01007c1:	53                   	push   %ebx
f01007c2:	83 ec 14             	sub    $0x14,%esp
f01007c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ca:	8b 83 84 21 10 f0    	mov    -0xfefde7c(%ebx),%eax
f01007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d4:	8b 83 80 21 10 f0    	mov    -0xfefde80(%ebx),%eax
f01007da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007de:	c7 04 24 09 1f 10 f0 	movl   $0xf0101f09,(%esp)
f01007e5:	e8 be 02 00 00       	call   f0100aa8 <cprintf>
f01007ea:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01007ed:	83 fb 24             	cmp    $0x24,%ebx
f01007f0:	75 d8                	jne    f01007ca <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f7:	83 c4 14             	add    $0x14,%esp
f01007fa:	5b                   	pop    %ebx
f01007fb:	5d                   	pop    %ebp
f01007fc:	c3                   	ret    

f01007fd <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f01007fd:	55                   	push   %ebp
f01007fe:	89 e5                	mov    %esp,%ebp
f0100800:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100803:	c7 04 24 12 1f 10 f0 	movl   $0xf0101f12,(%esp)
f010080a:	e8 99 02 00 00       	call   f0100aa8 <cprintf>
}
f010080f:	c9                   	leave  
f0100810:	c3                   	ret    

f0100811 <start_overflow>:

void
start_overflow(void)
{
f0100811:	55                   	push   %ebp
f0100812:	89 e5                	mov    %esp,%ebp

	// Your code here.
    


}
f0100814:	5d                   	pop    %ebp
f0100815:	c3                   	ret    

f0100816 <overflow_me>:

void
overflow_me(void)
{
f0100816:	55                   	push   %ebp
f0100817:	89 e5                	mov    %esp,%ebp
        start_overflow();
}
f0100819:	5d                   	pop    %ebp
f010081a:	c3                   	ret    

f010081b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010081b:	55                   	push   %ebp
f010081c:	89 e5                	mov    %esp,%ebp
f010081e:	57                   	push   %edi
f010081f:	56                   	push   %esi
f0100820:	53                   	push   %ebx
f0100821:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100824:	c7 04 24 90 20 10 f0 	movl   $0xf0102090,(%esp)
f010082b:	e8 78 02 00 00       	call   f0100aa8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100830:	c7 04 24 b4 20 10 f0 	movl   $0xf01020b4,(%esp)
f0100837:	e8 6c 02 00 00       	call   f0100aa8 <cprintf>


	while (1) {
		buf = readline("K> ");
f010083c:	c7 04 24 24 1f 10 f0 	movl   $0xf0101f24,(%esp)
f0100843:	e8 80 0c 00 00       	call   f01014c8 <readline>
f0100848:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010084a:	85 c0                	test   %eax,%eax
f010084c:	74 ee                	je     f010083c <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010084e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100855:	be 00 00 00 00       	mov    $0x0,%esi
f010085a:	eb 04                	jmp    f0100860 <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010085c:	c6 03 00             	movb   $0x0,(%ebx)
f010085f:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100860:	8a 03                	mov    (%ebx),%al
f0100862:	84 c0                	test   %al,%al
f0100864:	74 64                	je     f01008ca <monitor+0xaf>
f0100866:	0f be c0             	movsbl %al,%eax
f0100869:	89 44 24 04          	mov    %eax,0x4(%esp)
f010086d:	c7 04 24 28 1f 10 f0 	movl   $0xf0101f28,(%esp)
f0100874:	e8 72 0e 00 00       	call   f01016eb <strchr>
f0100879:	85 c0                	test   %eax,%eax
f010087b:	75 df                	jne    f010085c <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f010087d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100880:	74 48                	je     f01008ca <monitor+0xaf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100882:	83 fe 0f             	cmp    $0xf,%esi
f0100885:	75 16                	jne    f010089d <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100887:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010088e:	00 
f010088f:	c7 04 24 2d 1f 10 f0 	movl   $0xf0101f2d,(%esp)
f0100896:	e8 0d 02 00 00       	call   f0100aa8 <cprintf>
f010089b:	eb 9f                	jmp    f010083c <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f010089d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008a1:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a2:	8a 03                	mov    (%ebx),%al
f01008a4:	84 c0                	test   %al,%al
f01008a6:	75 09                	jne    f01008b1 <monitor+0x96>
f01008a8:	eb b6                	jmp    f0100860 <monitor+0x45>
			buf++;
f01008aa:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ab:	8a 03                	mov    (%ebx),%al
f01008ad:	84 c0                	test   %al,%al
f01008af:	74 af                	je     f0100860 <monitor+0x45>
f01008b1:	0f be c0             	movsbl %al,%eax
f01008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b8:	c7 04 24 28 1f 10 f0 	movl   $0xf0101f28,(%esp)
f01008bf:	e8 27 0e 00 00       	call   f01016eb <strchr>
f01008c4:	85 c0                	test   %eax,%eax
f01008c6:	74 e2                	je     f01008aa <monitor+0x8f>
f01008c8:	eb 96                	jmp    f0100860 <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f01008ca:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008d1:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008d2:	85 f6                	test   %esi,%esi
f01008d4:	0f 84 62 ff ff ff    	je     f010083c <monitor+0x21>
f01008da:	bb 80 21 10 f0       	mov    $0xf0102180,%ebx
f01008df:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e4:	8b 03                	mov    (%ebx),%eax
f01008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ea:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ed:	89 04 24             	mov    %eax,(%esp)
f01008f0:	e8 87 0d 00 00       	call   f010167c <strcmp>
f01008f5:	85 c0                	test   %eax,%eax
f01008f7:	75 24                	jne    f010091d <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f01008f9:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01008ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100903:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100906:	89 54 24 04          	mov    %edx,0x4(%esp)
f010090a:	89 34 24             	mov    %esi,(%esp)
f010090d:	ff 14 85 88 21 10 f0 	call   *-0xfefde78(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100914:	85 c0                	test   %eax,%eax
f0100916:	78 26                	js     f010093e <monitor+0x123>
f0100918:	e9 1f ff ff ff       	jmp    f010083c <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010091d:	47                   	inc    %edi
f010091e:	83 c3 0c             	add    $0xc,%ebx
f0100921:	83 ff 03             	cmp    $0x3,%edi
f0100924:	75 be                	jne    f01008e4 <monitor+0xc9>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100926:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100929:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092d:	c7 04 24 4a 1f 10 f0 	movl   $0xf0101f4a,(%esp)
f0100934:	e8 6f 01 00 00       	call   f0100aa8 <cprintf>
f0100939:	e9 fe fe ff ff       	jmp    f010083c <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010093e:	83 c4 5c             	add    $0x5c,%esp
f0100941:	5b                   	pop    %ebx
f0100942:	5e                   	pop    %esi
f0100943:	5f                   	pop    %edi
f0100944:	5d                   	pop    %ebp
f0100945:	c3                   	ret    

f0100946 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100946:	55                   	push   %ebp
f0100947:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100949:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010094c:	5d                   	pop    %ebp
f010094d:	c3                   	ret    

f010094e <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010094e:	55                   	push   %ebp
f010094f:	89 e5                	mov    %esp,%ebp
f0100951:	57                   	push   %edi
f0100952:	56                   	push   %esi
f0100953:	53                   	push   %ebx
f0100954:	83 ec 5c             	sub    $0x5c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100957:	89 eb                	mov    %ebp,%ebx
f0100959:	89 de                	mov    %ebx,%esi
	// Your code here.
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
f010095b:	e8 e6 ff ff ff       	call   f0100946 <read_eip>
	cprintf("Stack backtrace:\n");
f0100960:	c7 04 24 60 1f 10 f0 	movl   $0xf0101f60,(%esp)
f0100967:	e8 3c 01 00 00       	call   f0100aa8 <cprintf>
	while(ebp != 0x0){
f010096c:	85 db                	test   %ebx,%ebx
f010096e:	0f 84 cb 00 00 00    	je     f0100a3f <mon_backtrace+0xf1>
		eip =*((uint32_t *)ebp+1);
f0100974:	8b 5e 04             	mov    0x4(%esi),%ebx
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n", eip, ebp, *((uint32_t *)ebp+2), *((uint32_t *)ebp+3), *((uint32_t *)ebp+4),*((uint32_t *)ebp+5),*((uint32_t *)ebp+6));
f0100977:	8b 46 18             	mov    0x18(%esi),%eax
f010097a:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010097e:	8b 46 14             	mov    0x14(%esi),%eax
f0100981:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100985:	8b 46 10             	mov    0x10(%esi),%eax
f0100988:	89 44 24 14          	mov    %eax,0x14(%esp)
f010098c:	8b 46 0c             	mov    0xc(%esi),%eax
f010098f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100993:	8b 46 08             	mov    0x8(%esi),%eax
f0100996:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010099a:	89 74 24 08          	mov    %esi,0x8(%esp)
f010099e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009a2:	c7 04 24 dc 20 10 f0 	movl   $0xf01020dc,(%esp)
f01009a9:	e8 fa 00 00 00       	call   f0100aa8 <cprintf>
		
		struct Eipdebuginfo info;
		if(debuginfo_eip(eip, &info)==0){
f01009ae:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b5:	89 1c 24             	mov    %ebx,(%esp)
f01009b8:	e8 e7 01 00 00       	call   f0100ba4 <debuginfo_eip>
f01009bd:	85 c0                	test   %eax,%eax
f01009bf:	75 74                	jne    f0100a35 <mon_backtrace+0xe7>
f01009c1:	89 65 c0             	mov    %esp,-0x40(%ebp)
			char temp[info.eip_fn_namelen+1];
f01009c4:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01009c7:	8d 47 1f             	lea    0x1f(%edi),%eax
f01009ca:	b9 10 00 00 00       	mov    $0x10,%ecx
f01009cf:	ba 00 00 00 00       	mov    $0x0,%edx
f01009d4:	f7 f1                	div    %ecx
f01009d6:	c1 e0 04             	shl    $0x4,%eax
f01009d9:	29 c4                	sub    %eax,%esp
f01009db:	8d 44 24 2f          	lea    0x2f(%esp),%eax
f01009df:	83 e0 f0             	and    $0xfffffff0,%eax
f01009e2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01009e5:	89 c2                	mov    %eax,%edx
			temp[info.eip_fn_namelen]='\0';
f01009e7:	89 f9                	mov    %edi,%ecx
f01009e9:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
			int i = 0;
			for(i=0; i<info.eip_fn_namelen; i++){
f01009ed:	85 ff                	test   %edi,%edi
f01009ef:	7e 19                	jle    f0100a0a <mon_backtrace+0xbc>
				temp[i] = info.eip_fn_name[i];
f01009f1:	8b 7d d8             	mov    -0x28(%ebp),%edi
		struct Eipdebuginfo info;
		if(debuginfo_eip(eip, &info)==0){
			char temp[info.eip_fn_namelen+1];
			temp[info.eip_fn_namelen]='\0';
			int i = 0;
			for(i=0; i<info.eip_fn_namelen; i++){
f01009f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009f9:	89 5d bc             	mov    %ebx,-0x44(%ebp)
				temp[i] = info.eip_fn_name[i];
f01009fc:	8a 1c 07             	mov    (%edi,%eax,1),%bl
f01009ff:	88 1c 02             	mov    %bl,(%edx,%eax,1)
		struct Eipdebuginfo info;
		if(debuginfo_eip(eip, &info)==0){
			char temp[info.eip_fn_namelen+1];
			temp[info.eip_fn_namelen]='\0';
			int i = 0;
			for(i=0; i<info.eip_fn_namelen; i++){
f0100a02:	40                   	inc    %eax
f0100a03:	39 c8                	cmp    %ecx,%eax
f0100a05:	75 f5                	jne    f01009fc <mon_backtrace+0xae>
f0100a07:	8b 5d bc             	mov    -0x44(%ebp),%ebx
				temp[i] = info.eip_fn_name[i];
			}
			cprintf("         %s:%d: %s+%x\n", info.eip_file, info.eip_line, temp, eip-(uint32_t)info.eip_fn_addr);
f0100a0a:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100a0d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0100a11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100a14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100a1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100a22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a26:	c7 04 24 72 1f 10 f0 	movl   $0xf0101f72,(%esp)
f0100a2d:	e8 76 00 00 00       	call   f0100aa8 <cprintf>
f0100a32:	8b 65 c0             	mov    -0x40(%ebp),%esp
		}
		ebp = *((uint32_t *)ebp);
f0100a35:	8b 36                	mov    (%esi),%esi
{
	// Your code here.
	uint32_t ebp = read_ebp();
	uint32_t eip = read_eip();
	cprintf("Stack backtrace:\n");
	while(ebp != 0x0){
f0100a37:	85 f6                	test   %esi,%esi
f0100a39:	0f 85 35 ff ff ff    	jne    f0100974 <mon_backtrace+0x26>
		}
		ebp = *((uint32_t *)ebp);
	}

	overflow_me();
    cprintf("Backtrace success\n");
f0100a3f:	c7 04 24 89 1f 10 f0 	movl   $0xf0101f89,(%esp)
f0100a46:	e8 5d 00 00 00       	call   f0100aa8 <cprintf>
	return 0;
}
f0100a4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a53:	5b                   	pop    %ebx
f0100a54:	5e                   	pop    %esi
f0100a55:	5f                   	pop    %edi
f0100a56:	5d                   	pop    %ebp
f0100a57:	c3                   	ret    

f0100a58 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a58:	55                   	push   %ebp
f0100a59:	89 e5                	mov    %esp,%ebp
f0100a5b:	53                   	push   %ebx
f0100a5c:	83 ec 14             	sub    $0x14,%esp
f0100a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100a62:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a65:	89 04 24             	mov    %eax,(%esp)
f0100a68:	e8 73 fc ff ff       	call   f01006e0 <cputchar>
    (*cnt)++;
f0100a6d:	ff 03                	incl   (%ebx)
}
f0100a6f:	83 c4 14             	add    $0x14,%esp
f0100a72:	5b                   	pop    %ebx
f0100a73:	5d                   	pop    %ebp
f0100a74:	c3                   	ret    

f0100a75 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a75:	55                   	push   %ebp
f0100a76:	89 e5                	mov    %esp,%ebp
f0100a78:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100a7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a82:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a89:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a8c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a97:	c7 04 24 58 0a 10 f0 	movl   $0xf0100a58,(%esp)
f0100a9e:	e8 11 05 00 00       	call   f0100fb4 <vprintfmt>
	return cnt;
}
f0100aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100aa6:	c9                   	leave  
f0100aa7:	c3                   	ret    

f0100aa8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
f0100aab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100aae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ab5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ab8:	89 04 24             	mov    %eax,(%esp)
f0100abb:	e8 b5 ff ff ff       	call   f0100a75 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100ac0:	c9                   	leave  
f0100ac1:	c3                   	ret    
	...

f0100ac4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100ac4:	55                   	push   %ebp
f0100ac5:	89 e5                	mov    %esp,%ebp
f0100ac7:	57                   	push   %edi
f0100ac8:	56                   	push   %esi
f0100ac9:	53                   	push   %ebx
f0100aca:	83 ec 10             	sub    $0x10,%esp
f0100acd:	89 c3                	mov    %eax,%ebx
f0100acf:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100ad2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ad5:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100ad8:	8b 0a                	mov    (%edx),%ecx
f0100ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100add:	8b 00                	mov    (%eax),%eax
f0100adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ae2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	while (l <= r) {
f0100ae9:	eb 77                	jmp    f0100b62 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100aee:	01 c8                	add    %ecx,%eax
f0100af0:	bf 02 00 00 00       	mov    $0x2,%edi
f0100af5:	99                   	cltd   
f0100af6:	f7 ff                	idiv   %edi
f0100af8:	89 c2                	mov    %eax,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100afa:	eb 01                	jmp    f0100afd <stab_binsearch+0x39>
			m--;
f0100afc:	4a                   	dec    %edx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100afd:	39 ca                	cmp    %ecx,%edx
f0100aff:	7c 1d                	jl     f0100b1e <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100b01:	6b fa 0c             	imul   $0xc,%edx,%edi
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b04:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100b09:	39 f7                	cmp    %esi,%edi
f0100b0b:	75 ef                	jne    f0100afc <stab_binsearch+0x38>
f0100b0d:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b10:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100b13:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100b17:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100b1a:	73 18                	jae    f0100b34 <stab_binsearch+0x70>
f0100b1c:	eb 05                	jmp    f0100b23 <stab_binsearch+0x5f>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100b1e:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100b21:	eb 3f                	jmp    f0100b62 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100b23:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100b26:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100b28:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b2b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100b32:	eb 2e                	jmp    f0100b62 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100b34:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100b37:	76 15                	jbe    f0100b4e <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100b39:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100b3c:	4f                   	dec    %edi
f0100b3d:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100b40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b43:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b45:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100b4c:	eb 14                	jmp    f0100b62 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b4e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100b51:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100b54:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100b56:	ff 45 0c             	incl   0xc(%ebp)
f0100b59:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b5b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100b62:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100b65:	7e 84                	jle    f0100aeb <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100b6b:	75 0d                	jne    f0100b7a <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0100b6d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b70:	8b 02                	mov    (%edx),%eax
f0100b72:	48                   	dec    %eax
f0100b73:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100b76:	89 01                	mov    %eax,(%ecx)
f0100b78:	eb 22                	jmp    f0100b9c <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b7a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100b7d:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b7f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b82:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b84:	eb 01                	jmp    f0100b87 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b86:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b87:	39 c1                	cmp    %eax,%ecx
f0100b89:	7d 0c                	jge    f0100b97 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100b8b:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100b8e:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100b93:	39 f2                	cmp    %esi,%edx
f0100b95:	75 ef                	jne    f0100b86 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b97:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b9a:	89 02                	mov    %eax,(%edx)
	}
}
f0100b9c:	83 c4 10             	add    $0x10,%esp
f0100b9f:	5b                   	pop    %ebx
f0100ba0:	5e                   	pop    %esi
f0100ba1:	5f                   	pop    %edi
f0100ba2:	5d                   	pop    %ebp
f0100ba3:	c3                   	ret    

f0100ba4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ba4:	55                   	push   %ebp
f0100ba5:	89 e5                	mov    %esp,%ebp
f0100ba7:	57                   	push   %edi
f0100ba8:	56                   	push   %esi
f0100ba9:	53                   	push   %ebx
f0100baa:	83 ec 4c             	sub    $0x4c,%esp
f0100bad:	8b 75 08             	mov    0x8(%ebp),%esi
f0100bb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100bb3:	c7 03 a4 21 10 f0    	movl   $0xf01021a4,(%ebx)
	info->eip_line = 0;
f0100bb9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100bc0:	c7 43 08 a4 21 10 f0 	movl   $0xf01021a4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100bc7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100bce:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100bd1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100bd8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100bde:	76 12                	jbe    f0100bf2 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100be0:	b8 18 fb 10 f0       	mov    $0xf010fb18,%eax
f0100be5:	3d b5 6d 10 f0       	cmp    $0xf0106db5,%eax
f0100bea:	0f 86 e9 01 00 00    	jbe    f0100dd9 <debuginfo_eip+0x235>
f0100bf0:	eb 1c                	jmp    f0100c0e <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100bf2:	c7 44 24 08 ae 21 10 	movl   $0xf01021ae,0x8(%esp)
f0100bf9:	f0 
f0100bfa:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100c01:	00 
f0100c02:	c7 04 24 bb 21 10 f0 	movl   $0xf01021bb,(%esp)
f0100c09:	e8 ba f5 ff ff       	call   f01001c8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c13:	80 3d 17 fb 10 f0 00 	cmpb   $0x0,0xf010fb17
f0100c1a:	0f 85 c5 01 00 00    	jne    f0100de5 <debuginfo_eip+0x241>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c27:	b8 b4 6d 10 f0       	mov    $0xf0106db4,%eax
f0100c2c:	2d 58 24 10 f0       	sub    $0xf0102458,%eax
f0100c31:	c1 f8 02             	sar    $0x2,%eax
f0100c34:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100c3a:	48                   	dec    %eax
f0100c3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c3e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c42:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100c49:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c4c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c4f:	b8 58 24 10 f0       	mov    $0xf0102458,%eax
f0100c54:	e8 6b fe ff ff       	call   f0100ac4 <stab_binsearch>
	if (lfile == 0)
f0100c59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100c5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100c61:	85 d2                	test   %edx,%edx
f0100c63:	0f 84 7c 01 00 00    	je     f0100de5 <debuginfo_eip+0x241>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c69:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100c6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c72:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c76:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100c7d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c80:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c83:	b8 58 24 10 f0       	mov    $0xf0102458,%eax
f0100c88:	e8 37 fe ff ff       	call   f0100ac4 <stab_binsearch>

	if (lfun <= rfun) {
f0100c8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c90:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c93:	39 d0                	cmp    %edx,%eax
f0100c95:	7f 3e                	jg     f0100cd5 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c97:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100c9a:	8d b9 58 24 10 f0    	lea    -0xfefdba8(%ecx),%edi
f0100ca0:	8b 89 58 24 10 f0    	mov    -0xfefdba8(%ecx),%ecx
f0100ca6:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100ca9:	b9 18 fb 10 f0       	mov    $0xf010fb18,%ecx
f0100cae:	81 e9 b5 6d 10 f0    	sub    $0xf0106db5,%ecx
f0100cb4:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0100cb7:	73 0c                	jae    f0100cc5 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cb9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0100cbc:	81 c1 b5 6d 10 f0    	add    $0xf0106db5,%ecx
f0100cc2:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100cc5:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100cc8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100ccb:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100ccd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100cd0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100cd3:	eb 0f                	jmp    f0100ce4 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100cd5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100cde:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ce4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100ceb:	00 
f0100cec:	8b 43 08             	mov    0x8(%ebx),%eax
f0100cef:	89 04 24             	mov    %eax,(%esp)
f0100cf2:	e8 23 0a 00 00       	call   f010171a <strfind>
f0100cf7:	2b 43 08             	sub    0x8(%ebx),%eax
f0100cfa:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100cfd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d01:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100d08:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d0b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d0e:	b8 58 24 10 f0       	mov    $0xf0102458,%eax
f0100d13:	e8 ac fd ff ff       	call   f0100ac4 <stab_binsearch>
	if(lline <= rline)
f0100d18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
	  return -1;
f0100d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline)
f0100d20:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d23:	0f 8f bc 00 00 00    	jg     f0100de5 <debuginfo_eip+0x241>
		info->eip_line = stabs[lline].n_desc;
f0100d29:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100d2c:	0f b7 82 5e 24 10 f0 	movzwl -0xfefdba2(%edx),%eax
f0100d33:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d39:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d3c:	39 c8                	cmp    %ecx,%eax
f0100d3e:	7c 5d                	jl     f0100d9d <debuginfo_eip+0x1f9>
	       && stabs[lline].n_type != N_SOL
f0100d40:	89 c2                	mov    %eax,%edx
f0100d42:	6b f0 0c             	imul   $0xc,%eax,%esi
f0100d45:	80 be 5c 24 10 f0 84 	cmpb   $0x84,-0xfefdba4(%esi)
f0100d4c:	75 16                	jne    f0100d64 <debuginfo_eip+0x1c0>
f0100d4e:	eb 2e                	jmp    f0100d7e <debuginfo_eip+0x1da>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100d50:	48                   	dec    %eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d51:	39 c1                	cmp    %eax,%ecx
f0100d53:	7f 48                	jg     f0100d9d <debuginfo_eip+0x1f9>
	       && stabs[lline].n_type != N_SOL
f0100d55:	89 c2                	mov    %eax,%edx
f0100d57:	8d 34 40             	lea    (%eax,%eax,2),%esi
f0100d5a:	80 3c b5 5c 24 10 f0 	cmpb   $0x84,-0xfefdba4(,%esi,4)
f0100d61:	84 
f0100d62:	74 1a                	je     f0100d7e <debuginfo_eip+0x1da>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d64:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d67:	8d 14 95 58 24 10 f0 	lea    -0xfefdba8(,%edx,4),%edx
f0100d6e:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f0100d72:	75 dc                	jne    f0100d50 <debuginfo_eip+0x1ac>
f0100d74:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100d78:	74 d6                	je     f0100d50 <debuginfo_eip+0x1ac>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d7a:	39 c1                	cmp    %eax,%ecx
f0100d7c:	7f 1f                	jg     f0100d9d <debuginfo_eip+0x1f9>
f0100d7e:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d81:	8b 80 58 24 10 f0    	mov    -0xfefdba8(%eax),%eax
f0100d87:	ba 18 fb 10 f0       	mov    $0xf010fb18,%edx
f0100d8c:	81 ea b5 6d 10 f0    	sub    $0xf0106db5,%edx
f0100d92:	39 d0                	cmp    %edx,%eax
f0100d94:	73 07                	jae    f0100d9d <debuginfo_eip+0x1f9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d96:	05 b5 6d 10 f0       	add    $0xf0106db5,%eax
f0100d9b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d9d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100da0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100da3:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100da8:	39 ca                	cmp    %ecx,%edx
f0100daa:	7d 39                	jge    f0100de5 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
f0100dac:	42                   	inc    %edx
f0100dad:	39 d1                	cmp    %edx,%ecx
f0100daf:	7e 34                	jle    f0100de5 <debuginfo_eip+0x241>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100db1:	6b f2 0c             	imul   $0xc,%edx,%esi
f0100db4:	80 be 5c 24 10 f0 a0 	cmpb   $0xa0,-0xfefdba4(%esi)
f0100dbb:	75 28                	jne    f0100de5 <debuginfo_eip+0x241>
		     lline++)
			info->eip_fn_narg++;
f0100dbd:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100dc0:	42                   	inc    %edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100dc1:	39 d1                	cmp    %edx,%ecx
f0100dc3:	7e 1b                	jle    f0100de0 <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100dc5:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100dc8:	80 3c 85 5c 24 10 f0 	cmpb   $0xa0,-0xfefdba4(,%eax,4)
f0100dcf:	a0 
f0100dd0:	74 eb                	je     f0100dbd <debuginfo_eip+0x219>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd7:	eb 0c                	jmp    f0100de5 <debuginfo_eip+0x241>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100dde:	eb 05                	jmp    f0100de5 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100de0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100de5:	83 c4 4c             	add    $0x4c,%esp
f0100de8:	5b                   	pop    %ebx
f0100de9:	5e                   	pop    %esi
f0100dea:	5f                   	pop    %edi
f0100deb:	5d                   	pop    %ebp
f0100dec:	c3                   	ret    
f0100ded:	00 00                	add    %al,(%eax)
	...

f0100df0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100df0:	55                   	push   %ebp
f0100df1:	89 e5                	mov    %esp,%ebp
f0100df3:	57                   	push   %edi
f0100df4:	56                   	push   %esi
f0100df5:	53                   	push   %ebx
f0100df6:	83 ec 4c             	sub    $0x4c,%esp
f0100df9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100dfc:	89 d3                	mov    %edx,%ebx
f0100dfe:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e01:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0100e04:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e07:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0100e0a:	8b 45 14             	mov    0x14(%ebp),%eax
	// your code here:
	//int first=1;
	int mypadc=padc;
	static int flag = 1; 
	
	if(padc=='-'){
f0100e0d:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0100e11:	75 11                	jne    f0100e24 <printnum+0x34>
		padc = ' ';
		flag = 0;
f0100e13:	c7 05 00 a3 11 f0 00 	movl   $0x0,0xf011a300
f0100e1a:	00 00 00 
	//int first=1;
	int mypadc=padc;
	static int flag = 1; 
	
	if(padc=='-'){
		padc = ' ';
f0100e1d:	be 20 00 00 00       	mov    $0x20,%esi
f0100e22:	eb 03                	jmp    f0100e27 <printnum+0x37>
	// your code here:
	//int first=1;
	int mypadc=padc;
	static int flag = 1; 
	
	if(padc=='-'){
f0100e24:	8b 75 18             	mov    0x18(%ebp),%esi
//		first = 0;
//		static int flag = 0; 
		static int len = 0;
//	}
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e27:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100e2b:	75 08                	jne    f0100e35 <printnum+0x45>
f0100e2d:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100e30:	39 7d 10             	cmp    %edi,0x10(%ebp)
f0100e33:	77 59                	ja     f0100e8e <printnum+0x9e>
		//len++;
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e35:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100e39:	48                   	dec    %eax
f0100e3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e3e:	8b 75 10             	mov    0x10(%ebp),%esi
f0100e41:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100e45:	8b 74 24 08          	mov    0x8(%esp),%esi
f0100e49:	8b 7c 24 0c          	mov    0xc(%esp),%edi
f0100e4d:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0100e50:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100e53:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100e5a:	00 
f0100e5b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100e5e:	89 34 24             	mov    %esi,(%esp)
f0100e61:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100e64:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e68:	e8 df 0a 00 00       	call   f010194c <__udivdi3>
f0100e6d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e73:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100e77:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100e7b:	89 04 24             	mov    %eax,(%esp)
f0100e7e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e82:	89 da                	mov    %ebx,%edx
f0100e84:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e87:	e8 64 ff ff ff       	call   f0100df0 <printnum>
f0100e8c:	eb 2a                	jmp    f0100eb8 <printnum+0xc8>
		//flag = len;
		// print any needed pad characters before first digit
//		while (--width > 0)
//			putch(padc, putdat);
		    //--width;
		len = width;
f0100e8e:	a3 78 a5 11 f0       	mov    %eax,0xf011a578
		if(flag==1){
f0100e93:	83 3d 00 a3 11 f0 01 	cmpl   $0x1,0xf011a300
f0100e9a:	75 1c                	jne    f0100eb8 <printnum+0xc8>
			while(--width>0)
f0100e9c:	48                   	dec    %eax
f0100e9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ea0:	85 c0                	test   %eax,%eax
f0100ea2:	7e 14                	jle    f0100eb8 <printnum+0xc8>
f0100ea4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
				putch(padc, putdat);
f0100ea7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100eab:	89 34 24             	mov    %esi,(%esp)
f0100eae:	ff d7                	call   *%edi
//		while (--width > 0)
//			putch(padc, putdat);
		    //--width;
		len = width;
		if(flag==1){
			while(--width>0)
f0100eb0:	ff 4d e0             	decl   -0x20(%ebp)
f0100eb3:	75 f2                	jne    f0100ea7 <printnum+0xb7>
f0100eb5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
//			putch(padc, putdat);
//			flag++;
//		}
//	}

	putch("0123456789abcdef"[num % base], putdat);
f0100eb8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ebc:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100ec0:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ec3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ec7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100ece:	00 
f0100ecf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ed2:	89 14 24             	mov    %edx,(%esp)
f0100ed5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100ed8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100edc:	e8 8b 0b 00 00       	call   f0101a6c <__umoddi3>
f0100ee1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ee5:	0f be 80 c9 21 10 f0 	movsbl -0xfefde37(%eax),%eax
f0100eec:	89 04 24             	mov    %eax,(%esp)
f0100eef:	ff 55 d4             	call   *-0x2c(%ebp)
	if(mypadc=='-'){
f0100ef2:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0100ef6:	75 38                	jne    f0100f30 <printnum+0x140>
		while(--len>0){
f0100ef8:	a1 78 a5 11 f0       	mov    0xf011a578,%eax
f0100efd:	48                   	dec    %eax
f0100efe:	a3 78 a5 11 f0       	mov    %eax,0xf011a578
f0100f03:	85 c0                	test   %eax,%eax
f0100f05:	7e 1f                	jle    f0100f26 <printnum+0x136>
f0100f07:	8b 7d d4             	mov    -0x2c(%ebp),%edi
			putch(' ', putdat);
f0100f0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f0e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100f15:	ff d7                	call   *%edi
//		}
//	}

	putch("0123456789abcdef"[num % base], putdat);
	if(mypadc=='-'){
		while(--len>0){
f0100f17:	a1 78 a5 11 f0       	mov    0xf011a578,%eax
f0100f1c:	48                   	dec    %eax
f0100f1d:	a3 78 a5 11 f0       	mov    %eax,0xf011a578
f0100f22:	85 c0                	test   %eax,%eax
f0100f24:	7f e4                	jg     f0100f0a <printnum+0x11a>
			putch(' ', putdat);
		}
		flag = 1;
f0100f26:	c7 05 00 a3 11 f0 01 	movl   $0x1,0xf011a300
f0100f2d:	00 00 00 
	}
	//len--;
	//--width;
	//len--;
}
f0100f30:	83 c4 4c             	add    $0x4c,%esp
f0100f33:	5b                   	pop    %ebx
f0100f34:	5e                   	pop    %esi
f0100f35:	5f                   	pop    %edi
f0100f36:	5d                   	pop    %ebp
f0100f37:	c3                   	ret    

f0100f38 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100f38:	55                   	push   %ebp
f0100f39:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100f3b:	83 fa 01             	cmp    $0x1,%edx
f0100f3e:	7e 0e                	jle    f0100f4e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100f40:	8b 10                	mov    (%eax),%edx
f0100f42:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100f45:	89 08                	mov    %ecx,(%eax)
f0100f47:	8b 02                	mov    (%edx),%eax
f0100f49:	8b 52 04             	mov    0x4(%edx),%edx
f0100f4c:	eb 22                	jmp    f0100f70 <getuint+0x38>
	else if (lflag)
f0100f4e:	85 d2                	test   %edx,%edx
f0100f50:	74 10                	je     f0100f62 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100f52:	8b 10                	mov    (%eax),%edx
f0100f54:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f57:	89 08                	mov    %ecx,(%eax)
f0100f59:	8b 02                	mov    (%edx),%eax
f0100f5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f60:	eb 0e                	jmp    f0100f70 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100f62:	8b 10                	mov    (%eax),%edx
f0100f64:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f67:	89 08                	mov    %ecx,(%eax)
f0100f69:	8b 02                	mov    (%edx),%eax
f0100f6b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f70:	5d                   	pop    %ebp
f0100f71:	c3                   	ret    

f0100f72 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f72:	55                   	push   %ebp
f0100f73:	89 e5                	mov    %esp,%ebp
f0100f75:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f78:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100f7b:	8b 10                	mov    (%eax),%edx
f0100f7d:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f80:	73 08                	jae    f0100f8a <sprintputch+0x18>
		*b->buf++ = ch;
f0100f82:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100f85:	88 0a                	mov    %cl,(%edx)
f0100f87:	42                   	inc    %edx
f0100f88:	89 10                	mov    %edx,(%eax)
}
f0100f8a:	5d                   	pop    %ebp
f0100f8b:	c3                   	ret    

f0100f8c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f8c:	55                   	push   %ebp
f0100f8d:	89 e5                	mov    %esp,%ebp
f0100f8f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100f92:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f99:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100faa:	89 04 24             	mov    %eax,(%esp)
f0100fad:	e8 02 00 00 00       	call   f0100fb4 <vprintfmt>
	va_end(ap);
}
f0100fb2:	c9                   	leave  
f0100fb3:	c3                   	ret    

f0100fb4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100fb4:	55                   	push   %ebp
f0100fb5:	89 e5                	mov    %esp,%ebp
f0100fb7:	57                   	push   %edi
f0100fb8:	56                   	push   %esi
f0100fb9:	53                   	push   %ebx
f0100fba:	83 ec 4c             	sub    $0x4c,%esp
f0100fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fc0:	8b 75 10             	mov    0x10(%ebp),%esi
f0100fc3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100fc6:	eb 15                	jmp    f0100fdd <vprintfmt+0x29>
	char padc;
	int base, lflag, width, precision, altflag, signflag;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100fc8:	85 c0                	test   %eax,%eax
f0100fca:	0f 84 69 04 00 00    	je     f0101439 <vprintfmt+0x485>
				return;
			putch(ch, putdat);
f0100fd0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fd7:	89 04 24             	mov    %eax,(%esp)
f0100fda:	ff 55 08             	call   *0x8(%ebp)
	//int base, lflag, width, precision, altflag;
	char padc;
	int base, lflag, width, precision, altflag, signflag;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fdd:	0f b6 06             	movzbl (%esi),%eax
f0100fe0:	46                   	inc    %esi
f0100fe1:	83 f8 25             	cmp    $0x25,%eax
f0100fe4:	75 e2                	jne    f0100fc8 <vprintfmt+0x14>
f0100fe6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0100fed:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ff2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100ff7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100ffe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0101005:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101009:	eb 23                	jmp    f010102e <vprintfmt+0x7a>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010100b:	89 ce                	mov    %ecx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010100d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0101011:	eb 1b                	jmp    f010102e <vprintfmt+0x7a>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101013:	89 ce                	mov    %ecx,%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101015:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101019:	eb 13                	jmp    f010102e <vprintfmt+0x7a>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010101b:	89 ce                	mov    %ecx,%esi
			signflag = 1;
			goto reswitch;

		case '.':
			if (width < 0)
				width = 0;
f010101d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101024:	eb 08                	jmp    f010102e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101026:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0101029:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010102e:	8a 06                	mov    (%esi),%al
f0101030:	0f b6 d0             	movzbl %al,%edx
f0101033:	8d 4e 01             	lea    0x1(%esi),%ecx
f0101036:	83 e8 23             	sub    $0x23,%eax
f0101039:	3c 55                	cmp    $0x55,%al
f010103b:	0f 87 d1 03 00 00    	ja     f0101412 <vprintfmt+0x45e>
f0101041:	0f b6 c0             	movzbl %al,%eax
f0101044:	ff 24 85 d4 22 10 f0 	jmp    *-0xfefdd2c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010104b:	8d 5a d0             	lea    -0x30(%edx),%ebx
				ch = *fmt;
f010104e:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0101052:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101055:	83 fa 09             	cmp    $0x9,%edx
f0101058:	77 44                	ja     f010109e <vprintfmt+0xea>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010105a:	89 ce                	mov    %ecx,%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010105c:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f010105d:	8d 14 9b             	lea    (%ebx,%ebx,4),%edx
f0101060:	8d 5c 50 d0          	lea    -0x30(%eax,%edx,2),%ebx
				ch = *fmt;
f0101064:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101067:	8d 50 d0             	lea    -0x30(%eax),%edx
f010106a:	83 fa 09             	cmp    $0x9,%edx
f010106d:	76 ed                	jbe    f010105c <vprintfmt+0xa8>
f010106f:	eb 2f                	jmp    f01010a0 <vprintfmt+0xec>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101071:	8b 45 14             	mov    0x14(%ebp),%eax
f0101074:	8d 50 04             	lea    0x4(%eax),%edx
f0101077:	89 55 14             	mov    %edx,0x14(%ebp)
f010107a:	8b 18                	mov    (%eax),%ebx
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010107c:	89 ce                	mov    %ecx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010107e:	eb 20                	jmp    f01010a0 <vprintfmt+0xec>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101080:	89 ce                	mov    %ecx,%esi
			precision = va_arg(ap, int);
			goto process_precision;
		
		// my code to support "+" flag
		case '+':
			signflag = 1;
f0101082:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101089:	eb a3                	jmp    f010102e <vprintfmt+0x7a>

		case '.':
			if (width < 0)
f010108b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010108f:	78 8a                	js     f010101b <vprintfmt+0x67>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101091:	89 ce                	mov    %ecx,%esi
f0101093:	eb 99                	jmp    f010102e <vprintfmt+0x7a>
f0101095:	89 ce                	mov    %ecx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101097:	bf 01 00 00 00       	mov    $0x1,%edi
			goto reswitch;
f010109c:	eb 90                	jmp    f010102e <vprintfmt+0x7a>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010109e:	89 ce                	mov    %ecx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01010a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01010a4:	79 88                	jns    f010102e <vprintfmt+0x7a>
f01010a6:	e9 7b ff ff ff       	jmp    f0101026 <vprintfmt+0x72>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01010ab:	ff 45 dc             	incl   -0x24(%ebp)
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010ae:	89 ce                	mov    %ecx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01010b0:	e9 79 ff ff ff       	jmp    f010102e <vprintfmt+0x7a>
f01010b5:	89 4d d8             	mov    %ecx,-0x28(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01010b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010bb:	8d 50 04             	lea    0x4(%eax),%edx
f01010be:	89 55 14             	mov    %edx,0x14(%ebp)
f01010c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010c4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010c8:	8b 00                	mov    (%eax),%eax
f01010ca:	89 04 24             	mov    %eax,(%esp)
f01010cd:	ff 55 08             	call   *0x8(%ebp)
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010d0:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01010d3:	e9 05 ff ff ff       	jmp    f0100fdd <vprintfmt+0x29>
f01010d8:	89 4d d8             	mov    %ecx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01010db:	8b 45 14             	mov    0x14(%ebp),%eax
f01010de:	8d 50 04             	lea    0x4(%eax),%edx
f01010e1:	89 55 14             	mov    %edx,0x14(%ebp)
f01010e4:	8b 00                	mov    (%eax),%eax
f01010e6:	85 c0                	test   %eax,%eax
f01010e8:	79 02                	jns    f01010ec <vprintfmt+0x138>
f01010ea:	f7 d8                	neg    %eax
f01010ec:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010ee:	83 f8 06             	cmp    $0x6,%eax
f01010f1:	7f 0b                	jg     f01010fe <vprintfmt+0x14a>
f01010f3:	8b 04 85 2c 24 10 f0 	mov    -0xfefdbd4(,%eax,4),%eax
f01010fa:	85 c0                	test   %eax,%eax
f01010fc:	75 26                	jne    f0101124 <vprintfmt+0x170>
				printfmt(putch, putdat, "error %d", err);
f01010fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101102:	c7 44 24 08 e1 21 10 	movl   $0xf01021e1,0x8(%esp)
f0101109:	f0 
f010110a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010110d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101111:	8b 55 08             	mov    0x8(%ebp),%edx
f0101114:	89 14 24             	mov    %edx,(%esp)
f0101117:	e8 70 fe ff ff       	call   f0100f8c <printfmt>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010111c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010111f:	e9 b9 fe ff ff       	jmp    f0100fdd <vprintfmt+0x29>
			else
				printfmt(putch, putdat, "%s", p);
f0101124:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101128:	c7 44 24 08 ea 21 10 	movl   $0xf01021ea,0x8(%esp)
f010112f:	f0 
f0101130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101133:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101137:	8b 55 08             	mov    0x8(%ebp),%edx
f010113a:	89 14 24             	mov    %edx,(%esp)
f010113d:	e8 4a fe ff ff       	call   f0100f8c <printfmt>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101142:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101145:	e9 93 fe ff ff       	jmp    f0100fdd <vprintfmt+0x29>
f010114a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f010114d:	89 d9                	mov    %ebx,%ecx
f010114f:	8b 75 e0             	mov    -0x20(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101152:	8b 45 14             	mov    0x14(%ebp),%eax
f0101155:	8d 50 04             	lea    0x4(%eax),%edx
f0101158:	89 55 14             	mov    %edx,0x14(%ebp)
f010115b:	8b 00                	mov    (%eax),%eax
f010115d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101160:	85 c0                	test   %eax,%eax
f0101162:	75 07                	jne    f010116b <vprintfmt+0x1b7>
				p = "(null)";
f0101164:	c7 45 dc da 21 10 f0 	movl   $0xf01021da,-0x24(%ebp)
			if (width > 0 && padc != '-')
f010116b:	85 f6                	test   %esi,%esi
f010116d:	7e 44                	jle    f01011b3 <vprintfmt+0x1ff>
f010116f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101173:	74 3e                	je     f01011b3 <vprintfmt+0x1ff>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101175:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101179:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010117c:	89 04 24             	mov    %eax,(%esp)
f010117f:	e8 2c 04 00 00       	call   f01015b0 <strnlen>
f0101184:	29 c6                	sub    %eax,%esi
f0101186:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101189:	85 f6                	test   %esi,%esi
f010118b:	7e 26                	jle    f01011b3 <vprintfmt+0x1ff>
					putch(padc, putdat);
f010118d:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f0101191:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101194:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101197:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010119a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010119d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011a1:	89 34 24             	mov    %esi,(%esp)
f01011a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01011a7:	4f                   	dec    %edi
f01011a8:	75 f3                	jne    f010119d <vprintfmt+0x1e9>
f01011aa:	89 7d e0             	mov    %edi,-0x20(%ebp)
f01011ad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01011b0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011b6:	0f be 02             	movsbl (%edx),%eax
f01011b9:	85 c0                	test   %eax,%eax
f01011bb:	75 47                	jne    f0101204 <vprintfmt+0x250>
f01011bd:	eb 37                	jmp    f01011f6 <vprintfmt+0x242>
				if (altflag && (ch < ' ' || ch > '~'))
f01011bf:	85 ff                	test   %edi,%edi
f01011c1:	74 1b                	je     f01011de <vprintfmt+0x22a>
f01011c3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01011c6:	83 fa 5e             	cmp    $0x5e,%edx
f01011c9:	76 13                	jbe    f01011de <vprintfmt+0x22a>
					putch('?', putdat);
f01011cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01011d9:	ff 55 08             	call   *0x8(%ebp)
f01011dc:	eb 0d                	jmp    f01011eb <vprintfmt+0x237>
				else
					putch(ch, putdat);
f01011de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01011e1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01011e5:	89 04 24             	mov    %eax,(%esp)
f01011e8:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011eb:	ff 4d e0             	decl   -0x20(%ebp)
f01011ee:	0f be 06             	movsbl (%esi),%eax
f01011f1:	46                   	inc    %esi
f01011f2:	85 c0                	test   %eax,%eax
f01011f4:	75 12                	jne    f0101208 <vprintfmt+0x254>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01011f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01011fa:	7f 15                	jg     f0101211 <vprintfmt+0x25d>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011fc:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01011ff:	e9 d9 fd ff ff       	jmp    f0100fdd <vprintfmt+0x29>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101204:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101207:	46                   	inc    %esi
f0101208:	85 db                	test   %ebx,%ebx
f010120a:	78 b3                	js     f01011bf <vprintfmt+0x20b>
f010120c:	4b                   	dec    %ebx
f010120d:	79 b0                	jns    f01011bf <vprintfmt+0x20b>
f010120f:	eb e5                	jmp    f01011f6 <vprintfmt+0x242>
f0101211:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101214:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101217:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010121a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010121e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101225:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101227:	4b                   	dec    %ebx
f0101228:	75 f0                	jne    f010121a <vprintfmt+0x266>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010122a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010122d:	e9 ab fd ff ff       	jmp    f0100fdd <vprintfmt+0x29>
f0101232:	89 4d d8             	mov    %ecx,-0x28(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101235:	83 7d dc 01          	cmpl   $0x1,-0x24(%ebp)
f0101239:	7e 10                	jle    f010124b <vprintfmt+0x297>
		return va_arg(*ap, long long);
f010123b:	8b 45 14             	mov    0x14(%ebp),%eax
f010123e:	8d 50 08             	lea    0x8(%eax),%edx
f0101241:	89 55 14             	mov    %edx,0x14(%ebp)
f0101244:	8b 30                	mov    (%eax),%esi
f0101246:	8b 78 04             	mov    0x4(%eax),%edi
f0101249:	eb 28                	jmp    f0101273 <vprintfmt+0x2bf>
	else if (lflag)
f010124b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010124f:	74 12                	je     f0101263 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0101251:	8b 45 14             	mov    0x14(%ebp),%eax
f0101254:	8d 50 04             	lea    0x4(%eax),%edx
f0101257:	89 55 14             	mov    %edx,0x14(%ebp)
f010125a:	8b 30                	mov    (%eax),%esi
f010125c:	89 f7                	mov    %esi,%edi
f010125e:	c1 ff 1f             	sar    $0x1f,%edi
f0101261:	eb 10                	jmp    f0101273 <vprintfmt+0x2bf>
	else
		return va_arg(*ap, int);
f0101263:	8b 45 14             	mov    0x14(%ebp),%eax
f0101266:	8d 50 04             	lea    0x4(%eax),%edx
f0101269:	89 55 14             	mov    %edx,0x14(%ebp)
f010126c:	8b 30                	mov    (%eax),%esi
f010126e:	89 f7                	mov    %esi,%edi
f0101270:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101273:	85 ff                	test   %edi,%edi
f0101275:	78 0a                	js     f0101281 <vprintfmt+0x2cd>

				//my code to support signflag;
				signflag = 0;
				
			}
			base = 10;
f0101277:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010127c:	e9 b8 00 00 00       	jmp    f0101339 <vprintfmt+0x385>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0101281:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101284:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101288:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010128f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101292:	f7 de                	neg    %esi
f0101294:	83 d7 00             	adc    $0x0,%edi
f0101297:	f7 df                	neg    %edi

				//my code to support signflag;
				signflag = 0;
				
			}
			base = 10;
f0101299:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010129e:	e9 ad 00 00 00       	jmp    f0101350 <vprintfmt+0x39c>
f01012a3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01012a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012a9:	8d 45 14             	lea    0x14(%ebp),%eax
f01012ac:	e8 87 fc ff ff       	call   f0100f38 <getuint>
f01012b1:	89 c6                	mov    %eax,%esi
f01012b3:	89 d7                	mov    %edx,%edi
			base = 10;
f01012b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
			goto number;
f01012ba:	eb 7d                	jmp    f0101339 <vprintfmt+0x385>
f01012bc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			putch('0', putdat);
f01012bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01012c2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01012cd:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap, lflag);
f01012d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012d3:	8d 45 14             	lea    0x14(%ebp),%eax
f01012d6:	e8 5d fc ff ff       	call   f0100f38 <getuint>
f01012db:	89 c6                	mov    %eax,%esi
f01012dd:	89 d7                	mov    %edx,%edi
			base = 8;
f01012df:	bb 08 00 00 00       	mov    $0x8,%ebx
			goto number;
f01012e4:	eb 53                	jmp    f0101339 <vprintfmt+0x385>
f01012e6:	89 4d d8             	mov    %ecx,-0x28(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01012e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01012f7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01012fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01012fd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101301:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101308:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010130b:	8b 45 14             	mov    0x14(%ebp),%eax
f010130e:	8d 50 04             	lea    0x4(%eax),%edx
f0101311:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101314:	8b 30                	mov    (%eax),%esi
f0101316:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010131b:	bb 10 00 00 00       	mov    $0x10,%ebx
			goto number;
f0101320:	eb 17                	jmp    f0101339 <vprintfmt+0x385>
f0101322:	89 4d d8             	mov    %ecx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101325:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101328:	8d 45 14             	lea    0x14(%ebp),%eax
f010132b:	e8 08 fc ff ff       	call   f0100f38 <getuint>
f0101330:	89 c6                	mov    %eax,%esi
f0101332:	89 d7                	mov    %edx,%edi
			base = 16;
f0101334:	bb 10 00 00 00       	mov    $0x10,%ebx
		number:
			
			// my code to support signflag;
			if(signflag==1){
f0101339:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
f010133d:	75 11                	jne    f0101350 <vprintfmt+0x39c>
				if(num>=0)
				  putch('+', putdat);
f010133f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101342:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101346:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f010134d:	ff 55 08             	call   *0x8(%ebp)
			//	else
			//	  putch('-', putdat);
			}
			signflag = 0;

			printnum(putch, putdat, num, base, width, padc);
f0101350:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101354:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101358:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010135b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010135f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101363:	89 34 24             	mov    %esi,(%esp)
f0101366:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010136a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010136d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101370:	e8 7b fa ff ff       	call   f0100df0 <printnum>
			break;
f0101375:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101378:	e9 60 fc ff ff       	jmp    f0100fdd <vprintfmt+0x29>
f010137d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char * posp; // position pointer
			if((posp=va_arg(ap, char *))==NULL){
f0101380:	8b 45 14             	mov    0x14(%ebp),%eax
f0101383:	8d 50 04             	lea    0x4(%eax),%edx
f0101386:	89 55 14             	mov    %edx,0x14(%ebp)
f0101389:	8b 18                	mov    (%eax),%ebx
f010138b:	85 db                	test   %ebx,%ebx
f010138d:	75 2a                	jne    f01013b9 <vprintfmt+0x405>
				printfmt(putch, putdat, "%s", null_error);
f010138f:	c7 44 24 0c 58 22 10 	movl   $0xf0102258,0xc(%esp)
f0101396:	f0 
f0101397:	c7 44 24 08 ea 21 10 	movl   $0xf01021ea,0x8(%esp)
f010139e:	f0 
f010139f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013a6:	8b 55 08             	mov    0x8(%ebp),%edx
f01013a9:	89 14 24             	mov    %edx,(%esp)
f01013ac:	e8 db fb ff ff       	call   f0100f8c <printfmt>
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01013b4:	e9 24 fc ff ff       	jmp    f0100fdd <vprintfmt+0x29>

            // Your code here
			char * posp; // position pointer
			if((posp=va_arg(ap, char *))==NULL){
				printfmt(putch, putdat, "%s", null_error);
			}else if(*((unsigned int *)putdat)>127){
f01013b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013bc:	83 38 7f             	cmpl   $0x7f,(%eax)
f01013bf:	76 2a                	jbe    f01013eb <vprintfmt+0x437>
				printfmt(putch, putdat, "%s", overflow_error);
f01013c1:	c7 44 24 0c 90 22 10 	movl   $0xf0102290,0xc(%esp)
f01013c8:	f0 
f01013c9:	c7 44 24 08 ea 21 10 	movl   $0xf01021ea,0x8(%esp)
f01013d0:	f0 
f01013d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013d5:	8b 55 08             	mov    0x8(%ebp),%edx
f01013d8:	89 14 24             	mov    %edx,(%esp)
f01013db:	e8 ac fb ff ff       	call   f0100f8c <printfmt>
				*posp = -1;
f01013e0:	c6 03 ff             	movb   $0xff,(%ebx)
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01013e6:	e9 f2 fb ff ff       	jmp    f0100fdd <vprintfmt+0x29>
			}else if(*((unsigned int *)putdat)>127){
				printfmt(putch, putdat, "%s", overflow_error);
				*posp = -1;
			}
			else{
				*posp = *(char *)putdat;
f01013eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01013ee:	8a 02                	mov    (%edx),%al
f01013f0:	88 03                	mov    %al,(%ebx)
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013f2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01013f5:	e9 e3 fb ff ff       	jmp    f0100fdd <vprintfmt+0x29>
f01013fa:	89 4d d8             	mov    %ecx,-0x28(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01013fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101400:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101404:	89 14 24             	mov    %edx,(%esp)
f0101407:	ff 55 08             	call   *0x8(%ebp)
		precision = -1;
		lflag = 0;
		altflag = 0;
		signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010140a:	8b 75 d8             	mov    -0x28(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010140d:	e9 cb fb ff ff       	jmp    f0100fdd <vprintfmt+0x29>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101412:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101415:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101419:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101420:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101423:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101427:	0f 84 b0 fb ff ff    	je     f0100fdd <vprintfmt+0x29>
f010142d:	4e                   	dec    %esi
f010142e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101432:	75 f9                	jne    f010142d <vprintfmt+0x479>
f0101434:	e9 a4 fb ff ff       	jmp    f0100fdd <vprintfmt+0x29>
				/* do nothing */;
			break;
		}
	}
}
f0101439:	83 c4 4c             	add    $0x4c,%esp
f010143c:	5b                   	pop    %ebx
f010143d:	5e                   	pop    %esi
f010143e:	5f                   	pop    %edi
f010143f:	5d                   	pop    %ebp
f0101440:	c3                   	ret    

f0101441 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101441:	55                   	push   %ebp
f0101442:	89 e5                	mov    %esp,%ebp
f0101444:	83 ec 28             	sub    $0x28,%esp
f0101447:	8b 45 08             	mov    0x8(%ebp),%eax
f010144a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010144d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101450:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101454:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101457:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010145e:	85 c0                	test   %eax,%eax
f0101460:	74 30                	je     f0101492 <vsnprintf+0x51>
f0101462:	85 d2                	test   %edx,%edx
f0101464:	7e 33                	jle    f0101499 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101466:	8b 45 14             	mov    0x14(%ebp),%eax
f0101469:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010146d:	8b 45 10             	mov    0x10(%ebp),%eax
f0101470:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101474:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101477:	89 44 24 04          	mov    %eax,0x4(%esp)
f010147b:	c7 04 24 72 0f 10 f0 	movl   $0xf0100f72,(%esp)
f0101482:	e8 2d fb ff ff       	call   f0100fb4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101487:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010148a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101490:	eb 0c                	jmp    f010149e <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101497:	eb 05                	jmp    f010149e <vsnprintf+0x5d>
f0101499:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010149e:	c9                   	leave  
f010149f:	c3                   	ret    

f01014a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
f01014a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014ad:	8b 45 10             	mov    0x10(%ebp),%eax
f01014b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01014be:	89 04 24             	mov    %eax,(%esp)
f01014c1:	e8 7b ff ff ff       	call   f0101441 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014c6:	c9                   	leave  
f01014c7:	c3                   	ret    

f01014c8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014c8:	55                   	push   %ebp
f01014c9:	89 e5                	mov    %esp,%ebp
f01014cb:	57                   	push   %edi
f01014cc:	56                   	push   %esi
f01014cd:	53                   	push   %ebx
f01014ce:	83 ec 1c             	sub    $0x1c,%esp
f01014d1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014d4:	85 c0                	test   %eax,%eax
f01014d6:	74 10                	je     f01014e8 <readline+0x20>
		cprintf("%s", prompt);
f01014d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014dc:	c7 04 24 ea 21 10 f0 	movl   $0xf01021ea,(%esp)
f01014e3:	e8 c0 f5 ff ff       	call   f0100aa8 <cprintf>

	i = 0;
	echoing = iscons(0);
f01014e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014ef:	e8 0d f2 ff ff       	call   f0100701 <iscons>
f01014f4:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01014f6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01014fb:	e8 f0 f1 ff ff       	call   f01006f0 <getchar>
f0101500:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101502:	85 c0                	test   %eax,%eax
f0101504:	79 17                	jns    f010151d <readline+0x55>
			cprintf("read error: %e\n", c);
f0101506:	89 44 24 04          	mov    %eax,0x4(%esp)
f010150a:	c7 04 24 48 24 10 f0 	movl   $0xf0102448,(%esp)
f0101511:	e8 92 f5 ff ff       	call   f0100aa8 <cprintf>
			return NULL;
f0101516:	b8 00 00 00 00       	mov    $0x0,%eax
f010151b:	eb 69                	jmp    f0101586 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010151d:	83 f8 08             	cmp    $0x8,%eax
f0101520:	74 05                	je     f0101527 <readline+0x5f>
f0101522:	83 f8 7f             	cmp    $0x7f,%eax
f0101525:	75 17                	jne    f010153e <readline+0x76>
f0101527:	85 f6                	test   %esi,%esi
f0101529:	7e 13                	jle    f010153e <readline+0x76>
			if (echoing)
f010152b:	85 ff                	test   %edi,%edi
f010152d:	74 0c                	je     f010153b <readline+0x73>
				cputchar('\b');
f010152f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101536:	e8 a5 f1 ff ff       	call   f01006e0 <cputchar>
			i--;
f010153b:	4e                   	dec    %esi
f010153c:	eb bd                	jmp    f01014fb <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010153e:	83 fb 1f             	cmp    $0x1f,%ebx
f0101541:	7e 1d                	jle    f0101560 <readline+0x98>
f0101543:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101549:	7f 15                	jg     f0101560 <readline+0x98>
			if (echoing)
f010154b:	85 ff                	test   %edi,%edi
f010154d:	74 08                	je     f0101557 <readline+0x8f>
				cputchar(c);
f010154f:	89 1c 24             	mov    %ebx,(%esp)
f0101552:	e8 89 f1 ff ff       	call   f01006e0 <cputchar>
			buf[i++] = c;
f0101557:	88 9e 80 a5 11 f0    	mov    %bl,-0xfee5a80(%esi)
f010155d:	46                   	inc    %esi
f010155e:	eb 9b                	jmp    f01014fb <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101560:	83 fb 0a             	cmp    $0xa,%ebx
f0101563:	74 05                	je     f010156a <readline+0xa2>
f0101565:	83 fb 0d             	cmp    $0xd,%ebx
f0101568:	75 91                	jne    f01014fb <readline+0x33>
			if (echoing)
f010156a:	85 ff                	test   %edi,%edi
f010156c:	74 0c                	je     f010157a <readline+0xb2>
				cputchar('\n');
f010156e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101575:	e8 66 f1 ff ff       	call   f01006e0 <cputchar>
			buf[i] = 0;
f010157a:	c6 86 80 a5 11 f0 00 	movb   $0x0,-0xfee5a80(%esi)
			return buf;
f0101581:	b8 80 a5 11 f0       	mov    $0xf011a580,%eax
		}
	}
}
f0101586:	83 c4 1c             	add    $0x1c,%esp
f0101589:	5b                   	pop    %ebx
f010158a:	5e                   	pop    %esi
f010158b:	5f                   	pop    %edi
f010158c:	5d                   	pop    %ebp
f010158d:	c3                   	ret    
	...

f0101590 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101590:	55                   	push   %ebp
f0101591:	89 e5                	mov    %esp,%ebp
f0101593:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101596:	80 3a 00             	cmpb   $0x0,(%edx)
f0101599:	74 0e                	je     f01015a9 <strlen+0x19>
f010159b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01015a0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01015a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015a5:	75 f9                	jne    f01015a0 <strlen+0x10>
f01015a7:	eb 05                	jmp    f01015ae <strlen+0x1e>
f01015a9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01015ae:	5d                   	pop    %ebp
f01015af:	c3                   	ret    

f01015b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015b0:	55                   	push   %ebp
f01015b1:	89 e5                	mov    %esp,%ebp
f01015b3:	53                   	push   %ebx
f01015b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01015b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015ba:	85 c9                	test   %ecx,%ecx
f01015bc:	74 1a                	je     f01015d8 <strnlen+0x28>
f01015be:	80 3b 00             	cmpb   $0x0,(%ebx)
f01015c1:	74 1c                	je     f01015df <strnlen+0x2f>
f01015c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01015c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015ca:	39 ca                	cmp    %ecx,%edx
f01015cc:	74 16                	je     f01015e4 <strnlen+0x34>
f01015ce:	42                   	inc    %edx
f01015cf:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01015d4:	75 f2                	jne    f01015c8 <strnlen+0x18>
f01015d6:	eb 0c                	jmp    f01015e4 <strnlen+0x34>
f01015d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01015dd:	eb 05                	jmp    f01015e4 <strnlen+0x34>
f01015df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01015e4:	5b                   	pop    %ebx
f01015e5:	5d                   	pop    %ebp
f01015e6:	c3                   	ret    

f01015e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015e7:	55                   	push   %ebp
f01015e8:	89 e5                	mov    %esp,%ebp
f01015ea:	53                   	push   %ebx
f01015eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01015f6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01015f9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01015fc:	42                   	inc    %edx
f01015fd:	84 c9                	test   %cl,%cl
f01015ff:	75 f5                	jne    f01015f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101601:	5b                   	pop    %ebx
f0101602:	5d                   	pop    %ebp
f0101603:	c3                   	ret    

f0101604 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101604:	55                   	push   %ebp
f0101605:	89 e5                	mov    %esp,%ebp
f0101607:	56                   	push   %esi
f0101608:	53                   	push   %ebx
f0101609:	8b 45 08             	mov    0x8(%ebp),%eax
f010160c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010160f:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101612:	85 f6                	test   %esi,%esi
f0101614:	74 15                	je     f010162b <strncpy+0x27>
f0101616:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010161b:	8a 1a                	mov    (%edx),%bl
f010161d:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101620:	80 3a 01             	cmpb   $0x1,(%edx)
f0101623:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101626:	41                   	inc    %ecx
f0101627:	39 f1                	cmp    %esi,%ecx
f0101629:	75 f0                	jne    f010161b <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010162b:	5b                   	pop    %ebx
f010162c:	5e                   	pop    %esi
f010162d:	5d                   	pop    %ebp
f010162e:	c3                   	ret    

f010162f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010162f:	55                   	push   %ebp
f0101630:	89 e5                	mov    %esp,%ebp
f0101632:	57                   	push   %edi
f0101633:	56                   	push   %esi
f0101634:	53                   	push   %ebx
f0101635:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010163b:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010163e:	85 f6                	test   %esi,%esi
f0101640:	74 31                	je     f0101673 <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
f0101642:	83 fe 01             	cmp    $0x1,%esi
f0101645:	74 21                	je     f0101668 <strlcpy+0x39>
f0101647:	8a 0b                	mov    (%ebx),%cl
f0101649:	84 c9                	test   %cl,%cl
f010164b:	74 1f                	je     f010166c <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010164d:	83 ee 02             	sub    $0x2,%esi
f0101650:	89 f8                	mov    %edi,%eax
f0101652:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101657:	88 08                	mov    %cl,(%eax)
f0101659:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010165a:	39 f2                	cmp    %esi,%edx
f010165c:	74 10                	je     f010166e <strlcpy+0x3f>
f010165e:	42                   	inc    %edx
f010165f:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101662:	84 c9                	test   %cl,%cl
f0101664:	75 f1                	jne    f0101657 <strlcpy+0x28>
f0101666:	eb 06                	jmp    f010166e <strlcpy+0x3f>
f0101668:	89 f8                	mov    %edi,%eax
f010166a:	eb 02                	jmp    f010166e <strlcpy+0x3f>
f010166c:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010166e:	c6 00 00             	movb   $0x0,(%eax)
f0101671:	eb 02                	jmp    f0101675 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101673:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0101675:	29 f8                	sub    %edi,%eax
}
f0101677:	5b                   	pop    %ebx
f0101678:	5e                   	pop    %esi
f0101679:	5f                   	pop    %edi
f010167a:	5d                   	pop    %ebp
f010167b:	c3                   	ret    

f010167c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010167c:	55                   	push   %ebp
f010167d:	89 e5                	mov    %esp,%ebp
f010167f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101682:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101685:	8a 01                	mov    (%ecx),%al
f0101687:	84 c0                	test   %al,%al
f0101689:	74 11                	je     f010169c <strcmp+0x20>
f010168b:	3a 02                	cmp    (%edx),%al
f010168d:	75 0d                	jne    f010169c <strcmp+0x20>
		p++, q++;
f010168f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101690:	8a 41 01             	mov    0x1(%ecx),%al
f0101693:	84 c0                	test   %al,%al
f0101695:	74 05                	je     f010169c <strcmp+0x20>
f0101697:	41                   	inc    %ecx
f0101698:	3a 02                	cmp    (%edx),%al
f010169a:	74 f3                	je     f010168f <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010169c:	0f b6 c0             	movzbl %al,%eax
f010169f:	0f b6 12             	movzbl (%edx),%edx
f01016a2:	29 d0                	sub    %edx,%eax
}
f01016a4:	5d                   	pop    %ebp
f01016a5:	c3                   	ret    

f01016a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016a6:	55                   	push   %ebp
f01016a7:	89 e5                	mov    %esp,%ebp
f01016a9:	53                   	push   %ebx
f01016aa:	8b 55 08             	mov    0x8(%ebp),%edx
f01016ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016b0:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01016b3:	85 c0                	test   %eax,%eax
f01016b5:	74 1b                	je     f01016d2 <strncmp+0x2c>
f01016b7:	8a 1a                	mov    (%edx),%bl
f01016b9:	84 db                	test   %bl,%bl
f01016bb:	74 24                	je     f01016e1 <strncmp+0x3b>
f01016bd:	3a 19                	cmp    (%ecx),%bl
f01016bf:	75 20                	jne    f01016e1 <strncmp+0x3b>
f01016c1:	48                   	dec    %eax
f01016c2:	74 15                	je     f01016d9 <strncmp+0x33>
		n--, p++, q++;
f01016c4:	42                   	inc    %edx
f01016c5:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01016c6:	8a 1a                	mov    (%edx),%bl
f01016c8:	84 db                	test   %bl,%bl
f01016ca:	74 15                	je     f01016e1 <strncmp+0x3b>
f01016cc:	3a 19                	cmp    (%ecx),%bl
f01016ce:	74 f1                	je     f01016c1 <strncmp+0x1b>
f01016d0:	eb 0f                	jmp    f01016e1 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01016d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d7:	eb 05                	jmp    f01016de <strncmp+0x38>
f01016d9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01016de:	5b                   	pop    %ebx
f01016df:	5d                   	pop    %ebp
f01016e0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016e1:	0f b6 02             	movzbl (%edx),%eax
f01016e4:	0f b6 11             	movzbl (%ecx),%edx
f01016e7:	29 d0                	sub    %edx,%eax
f01016e9:	eb f3                	jmp    f01016de <strncmp+0x38>

f01016eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016eb:	55                   	push   %ebp
f01016ec:	89 e5                	mov    %esp,%ebp
f01016ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01016f4:	8a 10                	mov    (%eax),%dl
f01016f6:	84 d2                	test   %dl,%dl
f01016f8:	74 19                	je     f0101713 <strchr+0x28>
		if (*s == c)
f01016fa:	38 ca                	cmp    %cl,%dl
f01016fc:	75 07                	jne    f0101705 <strchr+0x1a>
f01016fe:	eb 18                	jmp    f0101718 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101700:	40                   	inc    %eax
		if (*s == c)
f0101701:	38 ca                	cmp    %cl,%dl
f0101703:	74 13                	je     f0101718 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101705:	8a 50 01             	mov    0x1(%eax),%dl
f0101708:	84 d2                	test   %dl,%dl
f010170a:	75 f4                	jne    f0101700 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f010170c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101711:	eb 05                	jmp    f0101718 <strchr+0x2d>
f0101713:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101718:	5d                   	pop    %ebp
f0101719:	c3                   	ret    

f010171a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010171a:	55                   	push   %ebp
f010171b:	89 e5                	mov    %esp,%ebp
f010171d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101720:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101723:	8a 10                	mov    (%eax),%dl
f0101725:	84 d2                	test   %dl,%dl
f0101727:	74 11                	je     f010173a <strfind+0x20>
		if (*s == c)
f0101729:	38 ca                	cmp    %cl,%dl
f010172b:	75 06                	jne    f0101733 <strfind+0x19>
f010172d:	eb 0b                	jmp    f010173a <strfind+0x20>
f010172f:	38 ca                	cmp    %cl,%dl
f0101731:	74 07                	je     f010173a <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101733:	40                   	inc    %eax
f0101734:	8a 10                	mov    (%eax),%dl
f0101736:	84 d2                	test   %dl,%dl
f0101738:	75 f5                	jne    f010172f <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010173a:	5d                   	pop    %ebp
f010173b:	c3                   	ret    

f010173c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010173c:	55                   	push   %ebp
f010173d:	89 e5                	mov    %esp,%ebp
f010173f:	57                   	push   %edi
f0101740:	56                   	push   %esi
f0101741:	53                   	push   %ebx
f0101742:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101745:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101748:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010174b:	85 c9                	test   %ecx,%ecx
f010174d:	74 30                	je     f010177f <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010174f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101755:	75 25                	jne    f010177c <memset+0x40>
f0101757:	f6 c1 03             	test   $0x3,%cl
f010175a:	75 20                	jne    f010177c <memset+0x40>
		c &= 0xFF;
f010175c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010175f:	89 d3                	mov    %edx,%ebx
f0101761:	c1 e3 08             	shl    $0x8,%ebx
f0101764:	89 d6                	mov    %edx,%esi
f0101766:	c1 e6 18             	shl    $0x18,%esi
f0101769:	89 d0                	mov    %edx,%eax
f010176b:	c1 e0 10             	shl    $0x10,%eax
f010176e:	09 f0                	or     %esi,%eax
f0101770:	09 d0                	or     %edx,%eax
f0101772:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101774:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101777:	fc                   	cld    
f0101778:	f3 ab                	rep stos %eax,%es:(%edi)
f010177a:	eb 03                	jmp    f010177f <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010177c:	fc                   	cld    
f010177d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010177f:	89 f8                	mov    %edi,%eax
f0101781:	5b                   	pop    %ebx
f0101782:	5e                   	pop    %esi
f0101783:	5f                   	pop    %edi
f0101784:	5d                   	pop    %ebp
f0101785:	c3                   	ret    

f0101786 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101786:	55                   	push   %ebp
f0101787:	89 e5                	mov    %esp,%ebp
f0101789:	57                   	push   %edi
f010178a:	56                   	push   %esi
f010178b:	8b 45 08             	mov    0x8(%ebp),%eax
f010178e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101791:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101794:	39 c6                	cmp    %eax,%esi
f0101796:	73 34                	jae    f01017cc <memmove+0x46>
f0101798:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010179b:	39 d0                	cmp    %edx,%eax
f010179d:	73 2d                	jae    f01017cc <memmove+0x46>
		s += n;
		d += n;
f010179f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017a2:	f6 c2 03             	test   $0x3,%dl
f01017a5:	75 1b                	jne    f01017c2 <memmove+0x3c>
f01017a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01017ad:	75 13                	jne    f01017c2 <memmove+0x3c>
f01017af:	f6 c1 03             	test   $0x3,%cl
f01017b2:	75 0e                	jne    f01017c2 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017b4:	83 ef 04             	sub    $0x4,%edi
f01017b7:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017ba:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01017bd:	fd                   	std    
f01017be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017c0:	eb 07                	jmp    f01017c9 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017c2:	4f                   	dec    %edi
f01017c3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01017c6:	fd                   	std    
f01017c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017c9:	fc                   	cld    
f01017ca:	eb 20                	jmp    f01017ec <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017cc:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017d2:	75 13                	jne    f01017e7 <memmove+0x61>
f01017d4:	a8 03                	test   $0x3,%al
f01017d6:	75 0f                	jne    f01017e7 <memmove+0x61>
f01017d8:	f6 c1 03             	test   $0x3,%cl
f01017db:	75 0a                	jne    f01017e7 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017dd:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01017e0:	89 c7                	mov    %eax,%edi
f01017e2:	fc                   	cld    
f01017e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017e5:	eb 05                	jmp    f01017ec <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017e7:	89 c7                	mov    %eax,%edi
f01017e9:	fc                   	cld    
f01017ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017ec:	5e                   	pop    %esi
f01017ed:	5f                   	pop    %edi
f01017ee:	5d                   	pop    %ebp
f01017ef:	c3                   	ret    

f01017f0 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01017f0:	55                   	push   %ebp
f01017f1:	89 e5                	mov    %esp,%ebp
f01017f3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01017f6:	8b 45 10             	mov    0x10(%ebp),%eax
f01017f9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101800:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101804:	8b 45 08             	mov    0x8(%ebp),%eax
f0101807:	89 04 24             	mov    %eax,(%esp)
f010180a:	e8 77 ff ff ff       	call   f0101786 <memmove>
}
f010180f:	c9                   	leave  
f0101810:	c3                   	ret    

f0101811 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101811:	55                   	push   %ebp
f0101812:	89 e5                	mov    %esp,%ebp
f0101814:	57                   	push   %edi
f0101815:	56                   	push   %esi
f0101816:	53                   	push   %ebx
f0101817:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010181a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010181d:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101820:	85 ff                	test   %edi,%edi
f0101822:	74 31                	je     f0101855 <memcmp+0x44>
		if (*s1 != *s2)
f0101824:	8a 03                	mov    (%ebx),%al
f0101826:	8a 0e                	mov    (%esi),%cl
f0101828:	38 c8                	cmp    %cl,%al
f010182a:	74 18                	je     f0101844 <memcmp+0x33>
f010182c:	eb 0c                	jmp    f010183a <memcmp+0x29>
f010182e:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0101832:	42                   	inc    %edx
f0101833:	8a 0c 16             	mov    (%esi,%edx,1),%cl
f0101836:	38 c8                	cmp    %cl,%al
f0101838:	74 10                	je     f010184a <memcmp+0x39>
			return (int) *s1 - (int) *s2;
f010183a:	0f b6 c0             	movzbl %al,%eax
f010183d:	0f b6 c9             	movzbl %cl,%ecx
f0101840:	29 c8                	sub    %ecx,%eax
f0101842:	eb 16                	jmp    f010185a <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101844:	4f                   	dec    %edi
f0101845:	ba 00 00 00 00       	mov    $0x0,%edx
f010184a:	39 fa                	cmp    %edi,%edx
f010184c:	75 e0                	jne    f010182e <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010184e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101853:	eb 05                	jmp    f010185a <memcmp+0x49>
f0101855:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010185a:	5b                   	pop    %ebx
f010185b:	5e                   	pop    %esi
f010185c:	5f                   	pop    %edi
f010185d:	5d                   	pop    %ebp
f010185e:	c3                   	ret    

f010185f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010185f:	55                   	push   %ebp
f0101860:	89 e5                	mov    %esp,%ebp
f0101862:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101865:	89 c2                	mov    %eax,%edx
f0101867:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010186a:	39 d0                	cmp    %edx,%eax
f010186c:	73 12                	jae    f0101880 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010186e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0101871:	38 08                	cmp    %cl,(%eax)
f0101873:	75 06                	jne    f010187b <memfind+0x1c>
f0101875:	eb 09                	jmp    f0101880 <memfind+0x21>
f0101877:	38 08                	cmp    %cl,(%eax)
f0101879:	74 05                	je     f0101880 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010187b:	40                   	inc    %eax
f010187c:	39 d0                	cmp    %edx,%eax
f010187e:	75 f7                	jne    f0101877 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101880:	5d                   	pop    %ebp
f0101881:	c3                   	ret    

f0101882 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101882:	55                   	push   %ebp
f0101883:	89 e5                	mov    %esp,%ebp
f0101885:	57                   	push   %edi
f0101886:	56                   	push   %esi
f0101887:	53                   	push   %ebx
f0101888:	8b 55 08             	mov    0x8(%ebp),%edx
f010188b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010188e:	eb 01                	jmp    f0101891 <strtol+0xf>
		s++;
f0101890:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101891:	8a 02                	mov    (%edx),%al
f0101893:	3c 20                	cmp    $0x20,%al
f0101895:	74 f9                	je     f0101890 <strtol+0xe>
f0101897:	3c 09                	cmp    $0x9,%al
f0101899:	74 f5                	je     f0101890 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010189b:	3c 2b                	cmp    $0x2b,%al
f010189d:	75 08                	jne    f01018a7 <strtol+0x25>
		s++;
f010189f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01018a0:	bf 00 00 00 00       	mov    $0x0,%edi
f01018a5:	eb 13                	jmp    f01018ba <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01018a7:	3c 2d                	cmp    $0x2d,%al
f01018a9:	75 0a                	jne    f01018b5 <strtol+0x33>
		s++, neg = 1;
f01018ab:	8d 52 01             	lea    0x1(%edx),%edx
f01018ae:	bf 01 00 00 00       	mov    $0x1,%edi
f01018b3:	eb 05                	jmp    f01018ba <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01018b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018ba:	85 db                	test   %ebx,%ebx
f01018bc:	74 05                	je     f01018c3 <strtol+0x41>
f01018be:	83 fb 10             	cmp    $0x10,%ebx
f01018c1:	75 28                	jne    f01018eb <strtol+0x69>
f01018c3:	8a 02                	mov    (%edx),%al
f01018c5:	3c 30                	cmp    $0x30,%al
f01018c7:	75 10                	jne    f01018d9 <strtol+0x57>
f01018c9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01018cd:	75 0a                	jne    f01018d9 <strtol+0x57>
		s += 2, base = 16;
f01018cf:	83 c2 02             	add    $0x2,%edx
f01018d2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018d7:	eb 12                	jmp    f01018eb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01018d9:	85 db                	test   %ebx,%ebx
f01018db:	75 0e                	jne    f01018eb <strtol+0x69>
f01018dd:	3c 30                	cmp    $0x30,%al
f01018df:	75 05                	jne    f01018e6 <strtol+0x64>
		s++, base = 8;
f01018e1:	42                   	inc    %edx
f01018e2:	b3 08                	mov    $0x8,%bl
f01018e4:	eb 05                	jmp    f01018eb <strtol+0x69>
	else if (base == 0)
		base = 10;
f01018e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01018eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01018f0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01018f2:	8a 0a                	mov    (%edx),%cl
f01018f4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01018f7:	80 fb 09             	cmp    $0x9,%bl
f01018fa:	77 08                	ja     f0101904 <strtol+0x82>
			dig = *s - '0';
f01018fc:	0f be c9             	movsbl %cl,%ecx
f01018ff:	83 e9 30             	sub    $0x30,%ecx
f0101902:	eb 1e                	jmp    f0101922 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0101904:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101907:	80 fb 19             	cmp    $0x19,%bl
f010190a:	77 08                	ja     f0101914 <strtol+0x92>
			dig = *s - 'a' + 10;
f010190c:	0f be c9             	movsbl %cl,%ecx
f010190f:	83 e9 57             	sub    $0x57,%ecx
f0101912:	eb 0e                	jmp    f0101922 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0101914:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0101917:	80 fb 19             	cmp    $0x19,%bl
f010191a:	77 12                	ja     f010192e <strtol+0xac>
			dig = *s - 'A' + 10;
f010191c:	0f be c9             	movsbl %cl,%ecx
f010191f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101922:	39 f1                	cmp    %esi,%ecx
f0101924:	7d 0c                	jge    f0101932 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0101926:	42                   	inc    %edx
f0101927:	0f af c6             	imul   %esi,%eax
f010192a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010192c:	eb c4                	jmp    f01018f2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010192e:	89 c1                	mov    %eax,%ecx
f0101930:	eb 02                	jmp    f0101934 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101932:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101934:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101938:	74 05                	je     f010193f <strtol+0xbd>
		*endptr = (char *) s;
f010193a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010193d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010193f:	85 ff                	test   %edi,%edi
f0101941:	74 04                	je     f0101947 <strtol+0xc5>
f0101943:	89 c8                	mov    %ecx,%eax
f0101945:	f7 d8                	neg    %eax
}
f0101947:	5b                   	pop    %ebx
f0101948:	5e                   	pop    %esi
f0101949:	5f                   	pop    %edi
f010194a:	5d                   	pop    %ebp
f010194b:	c3                   	ret    

f010194c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f010194c:	55                   	push   %ebp
f010194d:	57                   	push   %edi
f010194e:	56                   	push   %esi
f010194f:	83 ec 10             	sub    $0x10,%esp
f0101952:	8b 74 24 20          	mov    0x20(%esp),%esi
f0101956:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010195a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010195e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0101962:	89 cd                	mov    %ecx,%ebp
f0101964:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101968:	85 c0                	test   %eax,%eax
f010196a:	75 2c                	jne    f0101998 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010196c:	39 f9                	cmp    %edi,%ecx
f010196e:	77 68                	ja     f01019d8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101970:	85 c9                	test   %ecx,%ecx
f0101972:	75 0b                	jne    f010197f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101974:	b8 01 00 00 00       	mov    $0x1,%eax
f0101979:	31 d2                	xor    %edx,%edx
f010197b:	f7 f1                	div    %ecx
f010197d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010197f:	31 d2                	xor    %edx,%edx
f0101981:	89 f8                	mov    %edi,%eax
f0101983:	f7 f1                	div    %ecx
f0101985:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101987:	89 f0                	mov    %esi,%eax
f0101989:	f7 f1                	div    %ecx
f010198b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010198d:	89 f0                	mov    %esi,%eax
f010198f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101991:	83 c4 10             	add    $0x10,%esp
f0101994:	5e                   	pop    %esi
f0101995:	5f                   	pop    %edi
f0101996:	5d                   	pop    %ebp
f0101997:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101998:	39 f8                	cmp    %edi,%eax
f010199a:	77 2c                	ja     f01019c8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010199c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f010199f:	83 f6 1f             	xor    $0x1f,%esi
f01019a2:	75 4c                	jne    f01019f0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01019a4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01019a6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01019ab:	72 0a                	jb     f01019b7 <__udivdi3+0x6b>
f01019ad:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01019b1:	0f 87 ad 00 00 00    	ja     f0101a64 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01019b7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01019bc:	89 f0                	mov    %esi,%eax
f01019be:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01019c0:	83 c4 10             	add    $0x10,%esp
f01019c3:	5e                   	pop    %esi
f01019c4:	5f                   	pop    %edi
f01019c5:	5d                   	pop    %ebp
f01019c6:	c3                   	ret    
f01019c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01019c8:	31 ff                	xor    %edi,%edi
f01019ca:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01019cc:	89 f0                	mov    %esi,%eax
f01019ce:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01019d0:	83 c4 10             	add    $0x10,%esp
f01019d3:	5e                   	pop    %esi
f01019d4:	5f                   	pop    %edi
f01019d5:	5d                   	pop    %ebp
f01019d6:	c3                   	ret    
f01019d7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01019d8:	89 fa                	mov    %edi,%edx
f01019da:	89 f0                	mov    %esi,%eax
f01019dc:	f7 f1                	div    %ecx
f01019de:	89 c6                	mov    %eax,%esi
f01019e0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01019e2:	89 f0                	mov    %esi,%eax
f01019e4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01019e6:	83 c4 10             	add    $0x10,%esp
f01019e9:	5e                   	pop    %esi
f01019ea:	5f                   	pop    %edi
f01019eb:	5d                   	pop    %ebp
f01019ec:	c3                   	ret    
f01019ed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01019f0:	89 f1                	mov    %esi,%ecx
f01019f2:	d3 e0                	shl    %cl,%eax
f01019f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01019f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01019fd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01019ff:	89 ea                	mov    %ebp,%edx
f0101a01:	88 c1                	mov    %al,%cl
f0101a03:	d3 ea                	shr    %cl,%edx
f0101a05:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0101a09:	09 ca                	or     %ecx,%edx
f0101a0b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0101a0f:	89 f1                	mov    %esi,%ecx
f0101a11:	d3 e5                	shl    %cl,%ebp
f0101a13:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0101a17:	89 fd                	mov    %edi,%ebp
f0101a19:	88 c1                	mov    %al,%cl
f0101a1b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0101a1d:	89 fa                	mov    %edi,%edx
f0101a1f:	89 f1                	mov    %esi,%ecx
f0101a21:	d3 e2                	shl    %cl,%edx
f0101a23:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101a27:	88 c1                	mov    %al,%cl
f0101a29:	d3 ef                	shr    %cl,%edi
f0101a2b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101a2d:	89 f8                	mov    %edi,%eax
f0101a2f:	89 ea                	mov    %ebp,%edx
f0101a31:	f7 74 24 08          	divl   0x8(%esp)
f0101a35:	89 d1                	mov    %edx,%ecx
f0101a37:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f0101a39:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101a3d:	39 d1                	cmp    %edx,%ecx
f0101a3f:	72 17                	jb     f0101a58 <__udivdi3+0x10c>
f0101a41:	74 09                	je     f0101a4c <__udivdi3+0x100>
f0101a43:	89 fe                	mov    %edi,%esi
f0101a45:	31 ff                	xor    %edi,%edi
f0101a47:	e9 41 ff ff ff       	jmp    f010198d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0101a4c:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101a50:	89 f1                	mov    %esi,%ecx
f0101a52:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101a54:	39 c2                	cmp    %eax,%edx
f0101a56:	73 eb                	jae    f0101a43 <__udivdi3+0xf7>
		{
		  q0--;
f0101a58:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101a5b:	31 ff                	xor    %edi,%edi
f0101a5d:	e9 2b ff ff ff       	jmp    f010198d <__udivdi3+0x41>
f0101a62:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101a64:	31 f6                	xor    %esi,%esi
f0101a66:	e9 22 ff ff ff       	jmp    f010198d <__udivdi3+0x41>
	...

f0101a6c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0101a6c:	55                   	push   %ebp
f0101a6d:	57                   	push   %edi
f0101a6e:	56                   	push   %esi
f0101a6f:	83 ec 20             	sub    $0x20,%esp
f0101a72:	8b 44 24 30          	mov    0x30(%esp),%eax
f0101a76:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0101a7a:	89 44 24 14          	mov    %eax,0x14(%esp)
f0101a7e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0101a82:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101a86:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0101a8a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0101a8c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101a8e:	85 ed                	test   %ebp,%ebp
f0101a90:	75 16                	jne    f0101aa8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0101a92:	39 f1                	cmp    %esi,%ecx
f0101a94:	0f 86 a6 00 00 00    	jbe    f0101b40 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101a9a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0101a9c:	89 d0                	mov    %edx,%eax
f0101a9e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101aa0:	83 c4 20             	add    $0x20,%esp
f0101aa3:	5e                   	pop    %esi
f0101aa4:	5f                   	pop    %edi
f0101aa5:	5d                   	pop    %ebp
f0101aa6:	c3                   	ret    
f0101aa7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101aa8:	39 f5                	cmp    %esi,%ebp
f0101aaa:	0f 87 ac 00 00 00    	ja     f0101b5c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0101ab0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0101ab3:	83 f0 1f             	xor    $0x1f,%eax
f0101ab6:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101aba:	0f 84 a8 00 00 00    	je     f0101b68 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101ac0:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101ac4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0101ac6:	bf 20 00 00 00       	mov    $0x20,%edi
f0101acb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0101acf:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101ad3:	89 f9                	mov    %edi,%ecx
f0101ad5:	d3 e8                	shr    %cl,%eax
f0101ad7:	09 e8                	or     %ebp,%eax
f0101ad9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0101add:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101ae1:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101ae5:	d3 e0                	shl    %cl,%eax
f0101ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101aeb:	89 f2                	mov    %esi,%edx
f0101aed:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0101aef:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101af3:	d3 e0                	shl    %cl,%eax
f0101af5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101af9:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101afd:	89 f9                	mov    %edi,%ecx
f0101aff:	d3 e8                	shr    %cl,%eax
f0101b01:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101b03:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101b05:	89 f2                	mov    %esi,%edx
f0101b07:	f7 74 24 18          	divl   0x18(%esp)
f0101b0b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0101b0d:	f7 64 24 0c          	mull   0xc(%esp)
f0101b11:	89 c5                	mov    %eax,%ebp
f0101b13:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101b15:	39 d6                	cmp    %edx,%esi
f0101b17:	72 67                	jb     f0101b80 <__umoddi3+0x114>
f0101b19:	74 75                	je     f0101b90 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0101b1b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0101b1f:	29 e8                	sub    %ebp,%eax
f0101b21:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0101b23:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101b27:	d3 e8                	shr    %cl,%eax
f0101b29:	89 f2                	mov    %esi,%edx
f0101b2b:	89 f9                	mov    %edi,%ecx
f0101b2d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0101b2f:	09 d0                	or     %edx,%eax
f0101b31:	89 f2                	mov    %esi,%edx
f0101b33:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101b37:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101b39:	83 c4 20             	add    $0x20,%esp
f0101b3c:	5e                   	pop    %esi
f0101b3d:	5f                   	pop    %edi
f0101b3e:	5d                   	pop    %ebp
f0101b3f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101b40:	85 c9                	test   %ecx,%ecx
f0101b42:	75 0b                	jne    f0101b4f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101b44:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b49:	31 d2                	xor    %edx,%edx
f0101b4b:	f7 f1                	div    %ecx
f0101b4d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101b4f:	89 f0                	mov    %esi,%eax
f0101b51:	31 d2                	xor    %edx,%edx
f0101b53:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101b55:	89 f8                	mov    %edi,%eax
f0101b57:	e9 3e ff ff ff       	jmp    f0101a9a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0101b5c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101b5e:	83 c4 20             	add    $0x20,%esp
f0101b61:	5e                   	pop    %esi
f0101b62:	5f                   	pop    %edi
f0101b63:	5d                   	pop    %ebp
f0101b64:	c3                   	ret    
f0101b65:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101b68:	39 f5                	cmp    %esi,%ebp
f0101b6a:	72 04                	jb     f0101b70 <__umoddi3+0x104>
f0101b6c:	39 f9                	cmp    %edi,%ecx
f0101b6e:	77 06                	ja     f0101b76 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101b70:	89 f2                	mov    %esi,%edx
f0101b72:	29 cf                	sub    %ecx,%edi
f0101b74:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0101b76:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101b78:	83 c4 20             	add    $0x20,%esp
f0101b7b:	5e                   	pop    %esi
f0101b7c:	5f                   	pop    %edi
f0101b7d:	5d                   	pop    %ebp
f0101b7e:	c3                   	ret    
f0101b7f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101b80:	89 d1                	mov    %edx,%ecx
f0101b82:	89 c5                	mov    %eax,%ebp
f0101b84:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0101b88:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0101b8c:	eb 8d                	jmp    f0101b1b <__umoddi3+0xaf>
f0101b8e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101b90:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0101b94:	72 ea                	jb     f0101b80 <__umoddi3+0x114>
f0101b96:	89 f1                	mov    %esi,%ecx
f0101b98:	eb 81                	jmp    f0101b1b <__umoddi3+0xaf>
