
obj/user/evilhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 43 00 00 00       	call   800074 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <evil>:
#include <inc/x86.h>


// Call this function with ring0 privilege
void evil()
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800043:	b0 49                	mov    $0x49,%al
  800045:	ee                   	out    %al,(%dx)
  800046:	b0 4e                	mov    $0x4e,%al
  800048:	ee                   	out    %al,(%dx)
  800049:	b0 20                	mov    $0x20,%al
  80004b:	ee                   	out    %al,(%dx)
  80004c:	b0 52                	mov    $0x52,%al
  80004e:	ee                   	out    %al,(%dx)
  80004f:	b0 49                	mov    $0x49,%al
  800051:	ee                   	out    %al,(%dx)
  800052:	b0 4e                	mov    $0x4e,%al
  800054:	ee                   	out    %al,(%dx)
  800055:	b0 47                	mov    $0x47,%al
  800057:	ee                   	out    %al,(%dx)
  800058:	b0 30                	mov    $0x30,%al
  80005a:	ee                   	out    %al,(%dx)
  80005b:	b0 21                	mov    $0x21,%al
  80005d:	ee                   	out    %al,(%dx)
  80005e:	ee                   	out    %al,(%dx)
  80005f:	ee                   	out    %al,(%dx)
  800060:	b0 0a                	mov    $0xa,%al
  800062:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800063:	5d                   	pop    %ebp
  800064:	c3                   	ret    

00800065 <ring0_call>:
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
    // Hint : use a wrapper function to call fun_ptr. Feel free
    //        to add any functions or global variables in this 
    //        file if necessary.

    // Lab3 : Your Code Here
}
  800068:	5d                   	pop    %ebp
  800069:	c3                   	ret    

0080006a <umain>:

void
umain(int argc, char **argv)
{
  80006a:	55                   	push   %ebp
  80006b:	89 e5                	mov    %esp,%ebp
        // call the evil function in ring0
	ring0_call(&evil);

	// call the evil function in ring3
	evil();
  80006d:	e8 c2 ff ff ff       	call   800034 <evil>
}
  800072:	5d                   	pop    %ebp
  800073:	c3                   	ret    

00800074 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	83 ec 10             	sub    $0x10,%esp
  80007c:	8b 75 08             	mov    0x8(%ebp),%esi
  80007f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800082:	e8 66 0b 00 00       	call   800bed <sys_getenvid>
  800087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80008f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800092:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800099:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80009e:	c7 04 24 44 0f 80 00 	movl   $0x800f44,(%esp)
  8000a5:	e8 ee 00 00 00       	call   800198 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  8000aa:	a1 04 20 80 00       	mov    0x802004,%eax
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	c7 04 24 54 0f 80 00 	movl   $0x800f54,(%esp)
  8000ba:	e8 d9 00 00 00       	call   800198 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bf:	85 f6                	test   %esi,%esi
  8000c1:	7e 07                	jle    8000ca <libmain+0x56>
		binaryname = argv[0];
  8000c3:	8b 03                	mov    (%ebx),%eax
  8000c5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	89 34 24             	mov    %esi,(%esp)
  8000d1:	e8 94 ff ff ff       	call   80006a <umain>

	// exit gracefully
	exit();
  8000d6:	e8 09 00 00 00       	call   8000e4 <exit>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 93 0a 00 00       	call   800b89 <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	40                   	inc    %eax
  80010c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	75 19                	jne    80012e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800115:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011c:	00 
  80011d:	8d 43 08             	lea    0x8(%ebx),%eax
  800120:	89 04 24             	mov    %eax,(%esp)
  800123:	e8 00 0a 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  800128:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012e:	ff 43 04             	incl   0x4(%ebx)
}
  800131:	83 c4 14             	add    $0x14,%esp
  800134:	5b                   	pop    %ebx
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800140:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800147:	00 00 00 
	b.cnt = 0;
  80014a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800151:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
  800157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015b:	8b 45 08             	mov    0x8(%ebp),%eax
  80015e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800173:	e8 8d 01 00 00       	call   800305 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 98 09 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 87 ff ff ff       	call   800137 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    
	...

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 3c             	sub    $0x3c,%esp
  8001bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c0:	89 d7                	mov    %edx,%edi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001dc:	72 0f                	jb     8001ed <printnum+0x39>
  8001de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e4:	76 07                	jbe    8001ed <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e6:	4b                   	dec    %ebx
  8001e7:	85 db                	test   %ebx,%ebx
  8001e9:	7f 4f                	jg     80023a <printnum+0x86>
  8001eb:	eb 5a                	jmp    800247 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ed:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f1:	4b                   	dec    %ebx
  8001f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800201:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800205:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020c:	00 
  80020d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	e8 d5 0a 00 00       	call   800cf4 <__udivdi3>
  80021f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800223:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800227:	89 04 24             	mov    %eax,(%esp)
  80022a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022e:	89 fa                	mov    %edi,%edx
  800230:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800233:	e8 7c ff ff ff       	call   8001b4 <printnum>
  800238:	eb 0d                	jmp    800247 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023e:	89 34 24             	mov    %esi,(%esp)
  800241:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800244:	4b                   	dec    %ebx
  800245:	75 f3                	jne    80023a <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80024f:	8b 45 10             	mov    0x10(%ebp),%eax
  800252:	89 44 24 08          	mov    %eax,0x8(%esp)
  800256:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025d:	00 
  80025e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	e8 a4 0b 00 00       	call   800e14 <__umoddi3>
  800270:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800274:	0f be 80 71 0f 80 00 	movsbl 0x800f71(%eax),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800281:	83 c4 3c             	add    $0x3c,%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028c:	83 fa 01             	cmp    $0x1,%edx
  80028f:	7e 0e                	jle    80029f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 08             	lea    0x8(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	8b 52 04             	mov    0x4(%edx),%edx
  80029d:	eb 22                	jmp    8002c1 <getuint+0x38>
	else if (lflag)
  80029f:	85 d2                	test   %edx,%edx
  8002a1:	74 10                	je     8002b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	eb 0e                	jmp    8002c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d1:	73 08                	jae    8002db <sprintputch+0x18>
		*b->buf++ = ch;
  8002d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d6:	88 0a                	mov    %cl,(%edx)
  8002d8:	42                   	inc    %edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	e8 02 00 00 00       	call   800305 <vprintfmt>
	va_end(ap);
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 4c             	sub    $0x4c,%esp
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 75 10             	mov    0x10(%ebp),%esi
  800314:	eb 17                	jmp    80032d <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800316:	85 c0                	test   %eax,%eax
  800318:	0f 84 93 03 00 00    	je     8006b1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80031e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff 55 08             	call   *0x8(%ebp)
  800328:	eb 03                	jmp    80032d <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032d:	0f b6 06             	movzbl (%esi),%eax
  800330:	46                   	inc    %esi
  800331:	83 f8 25             	cmp    $0x25,%eax
  800334:	75 e0                	jne    800316 <vprintfmt+0x11>
  800336:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80033a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800341:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800346:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	eb 26                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800357:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80035b:	eb 1d                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800364:	eb 14                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800369:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800370:	eb 08                	jmp    80037a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800372:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800375:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	0f b6 16             	movzbl (%esi),%edx
  80037d:	8d 46 01             	lea    0x1(%esi),%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	8a 06                	mov    (%esi),%al
  800385:	83 e8 23             	sub    $0x23,%eax
  800388:	3c 55                	cmp    $0x55,%al
  80038a:	0f 87 fd 02 00 00    	ja     80068d <vprintfmt+0x388>
  800390:	0f b6 c0             	movzbl %al,%eax
  800393:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039a:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  80039d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a4:	83 fa 09             	cmp    $0x9,%edx
  8003a7:	77 3f                	ja     8003e8 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ad:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003b0:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003b4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b7:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ba:	83 fa 09             	cmp    $0x9,%edx
  8003bd:	76 ed                	jbe    8003ac <vprintfmt+0xa7>
  8003bf:	eb 2a                	jmp    8003eb <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cf:	eb 1a                	jmp    8003eb <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d5:	78 8f                	js     800366 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003da:	eb 9e                	jmp    80037a <vprintfmt+0x75>
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003df:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003e6:	eb 92                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ef:	79 89                	jns    80037a <vprintfmt+0x75>
  8003f1:	e9 7c ff ff ff       	jmp    800372 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fa:	e9 7b ff ff ff       	jmp    80037a <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040c:	8b 00                	mov    (%eax),%eax
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800417:	e9 11 ff ff ff       	jmp    80032d <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 00                	mov    (%eax),%eax
  800427:	85 c0                	test   %eax,%eax
  800429:	79 02                	jns    80042d <vprintfmt+0x128>
  80042b:	f7 d8                	neg    %eax
  80042d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042f:	83 f8 06             	cmp    $0x6,%eax
  800432:	7f 0b                	jg     80043f <vprintfmt+0x13a>
  800434:	8b 04 85 58 11 80 00 	mov    0x801158(,%eax,4),%eax
  80043b:	85 c0                	test   %eax,%eax
  80043d:	75 23                	jne    800462 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80043f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800443:	c7 44 24 08 89 0f 80 	movl   $0x800f89,0x8(%esp)
  80044a:	00 
  80044b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044f:	8b 55 08             	mov    0x8(%ebp),%edx
  800452:	89 14 24             	mov    %edx,(%esp)
  800455:	e8 83 fe ff ff       	call   8002dd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045d:	e9 cb fe ff ff       	jmp    80032d <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 92 0f 80 	movl   $0x800f92,0x8(%esp)
  80046d:	00 
  80046e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800472:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800475:	89 0c 24             	mov    %ecx,(%esp)
  800478:	e8 60 fe ff ff       	call   8002dd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800480:	e9 a8 fe ff ff       	jmp    80032d <vprintfmt+0x28>
  800485:	89 f9                	mov    %edi,%ecx
  800487:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800498:	85 c0                	test   %eax,%eax
  80049a:	75 07                	jne    8004a3 <vprintfmt+0x19e>
				p = "(null)";
  80049c:	c7 45 d4 82 0f 80 00 	movl   $0x800f82,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004a3:	85 f6                	test   %esi,%esi
  8004a5:	7e 3b                	jle    8004e2 <vprintfmt+0x1dd>
  8004a7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004ab:	74 35                	je     8004e2 <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	e8 a4 02 00 00       	call   800760 <strnlen>
  8004bc:	29 c6                	sub    %eax,%esi
  8004be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004c1:	85 f6                	test   %esi,%esi
  8004c3:	7e 1d                	jle    8004e2 <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004c5:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004c9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d3:	89 34 24             	mov    %esi,(%esp)
  8004d6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	4f                   	dec    %edi
  8004da:	75 f3                	jne    8004cf <vprintfmt+0x1ca>
  8004dc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004df:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004e5:	0f be 02             	movsbl (%edx),%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 43                	jne    80052f <vprintfmt+0x22a>
  8004ec:	eb 33                	jmp    800521 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f2:	74 18                	je     80050c <vprintfmt+0x207>
  8004f4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f7:	83 fa 5e             	cmp    $0x5e,%edx
  8004fa:	76 10                	jbe    80050c <vprintfmt+0x207>
					putch('?', putdat);
  8004fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800500:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
  80050a:	eb 0a                	jmp    800516 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800516:	ff 4d e4             	decl   -0x1c(%ebp)
  800519:	0f be 06             	movsbl (%esi),%eax
  80051c:	46                   	inc    %esi
  80051d:	85 c0                	test   %eax,%eax
  80051f:	75 12                	jne    800533 <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800521:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800525:	7f 15                	jg     80053c <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 fe fd ff ff       	jmp    80032d <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800532:	46                   	inc    %esi
  800533:	85 ff                	test   %edi,%edi
  800535:	78 b7                	js     8004ee <vprintfmt+0x1e9>
  800537:	4f                   	dec    %edi
  800538:	79 b4                	jns    8004ee <vprintfmt+0x1e9>
  80053a:	eb e5                	jmp    800521 <vprintfmt+0x21c>
  80053c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80053f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800542:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800546:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80054d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054f:	4e                   	dec    %esi
  800550:	75 f0                	jne    800542 <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800555:	e9 d3 fd ff ff       	jmp    80032d <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055a:	83 f9 01             	cmp    $0x1,%ecx
  80055d:	7e 10                	jle    80056f <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 08             	lea    0x8(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 30                	mov    (%eax),%esi
  80056a:	8b 78 04             	mov    0x4(%eax),%edi
  80056d:	eb 26                	jmp    800595 <vprintfmt+0x290>
	else if (lflag)
  80056f:	85 c9                	test   %ecx,%ecx
  800571:	74 12                	je     800585 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 04             	lea    0x4(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 30                	mov    (%eax),%esi
  80057e:	89 f7                	mov    %esi,%edi
  800580:	c1 ff 1f             	sar    $0x1f,%edi
  800583:	eb 10                	jmp    800595 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 30                	mov    (%eax),%esi
  800590:	89 f7                	mov    %esi,%edi
  800592:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800595:	85 ff                	test   %edi,%edi
  800597:	78 0e                	js     8005a7 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800599:	89 f0                	mov    %esi,%eax
  80059b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059d:	be 0a 00 00 00       	mov    $0xa,%esi
  8005a2:	e9 a8 00 00 00       	jmp    80064f <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b5:	89 f0                	mov    %esi,%eax
  8005b7:	89 fa                	mov    %edi,%edx
  8005b9:	f7 d8                	neg    %eax
  8005bb:	83 d2 00             	adc    $0x0,%edx
  8005be:	f7 da                	neg    %edx
			}
			base = 10;
  8005c0:	be 0a 00 00 00       	mov    $0xa,%esi
  8005c5:	e9 85 00 00 00       	jmp    80064f <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ca:	89 ca                	mov    %ecx,%edx
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 b5 fc ff ff       	call   800289 <getuint>
			base = 10;
  8005d4:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005d9:	eb 74                	jmp    80064f <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005df:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005e6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ed:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fb:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800608:	e9 20 fd ff ff       	jmp    80032d <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  80060d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800611:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800618:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800626:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800632:	8b 00                	mov    (%eax),%eax
  800634:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800639:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80063e:	eb 0f                	jmp    80064f <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800640:	89 ca                	mov    %ecx,%edx
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 3f fc ff ff       	call   800289 <getuint>
			base = 16;
  80064a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064f:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800653:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800657:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80065a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80065e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800662:	89 04 24             	mov    %eax,(%esp)
  800665:	89 54 24 04          	mov    %edx,0x4(%esp)
  800669:	89 da                	mov    %ebx,%edx
  80066b:	8b 45 08             	mov    0x8(%ebp),%eax
  80066e:	e8 41 fb ff ff       	call   8001b4 <printnum>
			break;
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 b2 fc ff ff       	jmp    80032d <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067f:	89 14 24             	mov    %edx,(%esp)
  800682:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800688:	e9 a0 fc ff ff       	jmp    80032d <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069f:	0f 84 88 fc ff ff    	je     80032d <vprintfmt+0x28>
  8006a5:	4e                   	dec    %esi
  8006a6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006aa:	75 f9                	jne    8006a5 <vprintfmt+0x3a0>
  8006ac:	e9 7c fc ff ff       	jmp    80032d <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  8006b1:	83 c4 4c             	add    $0x4c,%esp
  8006b4:	5b                   	pop    %ebx
  8006b5:	5e                   	pop    %esi
  8006b6:	5f                   	pop    %edi
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    

008006b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 28             	sub    $0x28,%esp
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 30                	je     80070a <vsnprintf+0x51>
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	7e 33                	jle    800711 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f3:	c7 04 24 c3 02 80 00 	movl   $0x8002c3,(%esp)
  8006fa:	e8 06 fc ff ff       	call   800305 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800702:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800708:	eb 0c                	jmp    800716 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070f:	eb 05                	jmp    800716 <vsnprintf+0x5d>
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800721:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800725:	8b 45 10             	mov    0x10(%ebp),%eax
  800728:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	89 04 24             	mov    %eax,(%esp)
  800739:	e8 7b ff ff ff       	call   8006b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3a 00             	cmpb   $0x0,(%edx)
  800749:	74 0e                	je     800759 <strlen+0x19>
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800750:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f9                	jne    800750 <strlen+0x10>
  800757:	eb 05                	jmp    80075e <strlen+0x1e>
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	85 c9                	test   %ecx,%ecx
  80076c:	74 1a                	je     800788 <strnlen+0x28>
  80076e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800771:	74 1c                	je     80078f <strnlen+0x2f>
  800773:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800778:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	39 ca                	cmp    %ecx,%edx
  80077c:	74 16                	je     800794 <strnlen+0x34>
  80077e:	42                   	inc    %edx
  80077f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800784:	75 f2                	jne    800778 <strnlen+0x18>
  800786:	eb 0c                	jmp    800794 <strnlen+0x34>
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	eb 05                	jmp    800794 <strnlen+0x34>
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007a9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ac:	42                   	inc    %edx
  8007ad:	84 c9                	test   %cl,%cl
  8007af:	75 f5                	jne    8007a6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	89 1c 24             	mov    %ebx,(%esp)
  8007c1:	e8 7a ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 c0 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	85 f6                	test   %esi,%esi
  8007ef:	74 15                	je     800806 <strncpy+0x27>
  8007f1:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007f6:	8a 1a                	mov    (%edx),%bl
  8007f8:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fb:	80 3a 01             	cmpb   $0x1,(%edx)
  8007fe:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	41                   	inc    %ecx
  800802:	39 f1                	cmp    %esi,%ecx
  800804:	75 f0                	jne    8007f6 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	57                   	push   %edi
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 7d 08             	mov    0x8(%ebp),%edi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	85 f6                	test   %esi,%esi
  80081b:	74 31                	je     80084e <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  80081d:	83 fe 01             	cmp    $0x1,%esi
  800820:	74 21                	je     800843 <strlcpy+0x39>
  800822:	8a 0b                	mov    (%ebx),%cl
  800824:	84 c9                	test   %cl,%cl
  800826:	74 1f                	je     800847 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800828:	83 ee 02             	sub    $0x2,%esi
  80082b:	89 f8                	mov    %edi,%eax
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800832:	88 08                	mov    %cl,(%eax)
  800834:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800835:	39 f2                	cmp    %esi,%edx
  800837:	74 10                	je     800849 <strlcpy+0x3f>
  800839:	42                   	inc    %edx
  80083a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80083d:	84 c9                	test   %cl,%cl
  80083f:	75 f1                	jne    800832 <strlcpy+0x28>
  800841:	eb 06                	jmp    800849 <strlcpy+0x3f>
  800843:	89 f8                	mov    %edi,%eax
  800845:	eb 02                	jmp    800849 <strlcpy+0x3f>
  800847:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800849:	c6 00 00             	movb   $0x0,(%eax)
  80084c:	eb 02                	jmp    800850 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800850:	29 f8                	sub    %edi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5f                   	pop    %edi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800860:	8a 01                	mov    (%ecx),%al
  800862:	84 c0                	test   %al,%al
  800864:	74 11                	je     800877 <strcmp+0x20>
  800866:	3a 02                	cmp    (%edx),%al
  800868:	75 0d                	jne    800877 <strcmp+0x20>
		p++, q++;
  80086a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086b:	8a 41 01             	mov    0x1(%ecx),%al
  80086e:	84 c0                	test   %al,%al
  800870:	74 05                	je     800877 <strcmp+0x20>
  800872:	41                   	inc    %ecx
  800873:	3a 02                	cmp    (%edx),%al
  800875:	74 f3                	je     80086a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 55 08             	mov    0x8(%ebp),%edx
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80088e:	85 c0                	test   %eax,%eax
  800890:	74 1b                	je     8008ad <strncmp+0x2c>
  800892:	8a 1a                	mov    (%edx),%bl
  800894:	84 db                	test   %bl,%bl
  800896:	74 24                	je     8008bc <strncmp+0x3b>
  800898:	3a 19                	cmp    (%ecx),%bl
  80089a:	75 20                	jne    8008bc <strncmp+0x3b>
  80089c:	48                   	dec    %eax
  80089d:	74 15                	je     8008b4 <strncmp+0x33>
		n--, p++, q++;
  80089f:	42                   	inc    %edx
  8008a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a1:	8a 1a                	mov    (%edx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	74 15                	je     8008bc <strncmp+0x3b>
  8008a7:	3a 19                	cmp    (%ecx),%bl
  8008a9:	74 f1                	je     80089c <strncmp+0x1b>
  8008ab:	eb 0f                	jmp    8008bc <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	eb 05                	jmp    8008b9 <strncmp+0x38>
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bc:	0f b6 02             	movzbl (%edx),%eax
  8008bf:	0f b6 11             	movzbl (%ecx),%edx
  8008c2:	29 d0                	sub    %edx,%eax
  8008c4:	eb f3                	jmp    8008b9 <strncmp+0x38>

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cf:	8a 10                	mov    (%eax),%dl
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	74 19                	je     8008ee <strchr+0x28>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	75 07                	jne    8008e0 <strchr+0x1a>
  8008d9:	eb 18                	jmp    8008f3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008db:	40                   	inc    %eax
		if (*s == c)
  8008dc:	38 ca                	cmp    %cl,%dl
  8008de:	74 13                	je     8008f3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e0:	8a 50 01             	mov    0x1(%eax),%dl
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	75 f4                	jne    8008db <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb 05                	jmp    8008f3 <strchr+0x2d>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	8a 10                	mov    (%eax),%dl
  800900:	84 d2                	test   %dl,%dl
  800902:	74 11                	je     800915 <strfind+0x20>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	75 06                	jne    80090e <strfind+0x19>
  800908:	eb 0b                	jmp    800915 <strfind+0x20>
  80090a:	38 ca                	cmp    %cl,%dl
  80090c:	74 07                	je     800915 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090e:	40                   	inc    %eax
  80090f:	8a 10                	mov    (%eax),%dl
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f5                	jne    80090a <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 45 0c             	mov    0xc(%ebp),%eax
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800926:	85 c9                	test   %ecx,%ecx
  800928:	74 30                	je     80095a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800930:	75 25                	jne    800957 <memset+0x40>
  800932:	f6 c1 03             	test   $0x3,%cl
  800935:	75 20                	jne    800957 <memset+0x40>
		c &= 0xFF;
  800937:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093a:	89 d3                	mov    %edx,%ebx
  80093c:	c1 e3 08             	shl    $0x8,%ebx
  80093f:	89 d6                	mov    %edx,%esi
  800941:	c1 e6 18             	shl    $0x18,%esi
  800944:	89 d0                	mov    %edx,%eax
  800946:	c1 e0 10             	shl    $0x10,%eax
  800949:	09 f0                	or     %esi,%eax
  80094b:	09 d0                	or     %edx,%eax
  80094d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb 03                	jmp    80095a <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800957:	fc                   	cld    
  800958:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095a:	89 f8                	mov    %edi,%eax
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096f:	39 c6                	cmp    %eax,%esi
  800971:	73 34                	jae    8009a7 <memmove+0x46>
  800973:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800976:	39 d0                	cmp    %edx,%eax
  800978:	73 2d                	jae    8009a7 <memmove+0x46>
		s += n;
		d += n;
  80097a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097d:	f6 c2 03             	test   $0x3,%dl
  800980:	75 1b                	jne    80099d <memmove+0x3c>
  800982:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800988:	75 13                	jne    80099d <memmove+0x3c>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0e                	jne    80099d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098f:	83 ef 04             	sub    $0x4,%edi
  800992:	8d 72 fc             	lea    -0x4(%edx),%esi
  800995:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800998:	fd                   	std    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 07                	jmp    8009a4 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099d:	4f                   	dec    %edi
  80099e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a1:	fd                   	std    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a4:	fc                   	cld    
  8009a5:	eb 20                	jmp    8009c7 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ad:	75 13                	jne    8009c2 <memmove+0x61>
  8009af:	a8 03                	test   $0x3,%al
  8009b1:	75 0f                	jne    8009c2 <memmove+0x61>
  8009b3:	f6 c1 03             	test   $0x3,%cl
  8009b6:	75 0a                	jne    8009c2 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009bb:	89 c7                	mov    %eax,%edi
  8009bd:	fc                   	cld    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 05                	jmp    8009c7 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 77 ff ff ff       	call   800961 <memmove>
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fb:	85 ff                	test   %edi,%edi
  8009fd:	74 31                	je     800a30 <memcmp+0x44>
		if (*s1 != *s2)
  8009ff:	8a 03                	mov    (%ebx),%al
  800a01:	8a 0e                	mov    (%esi),%cl
  800a03:	38 c8                	cmp    %cl,%al
  800a05:	74 18                	je     800a1f <memcmp+0x33>
  800a07:	eb 0c                	jmp    800a15 <memcmp+0x29>
  800a09:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a0d:	42                   	inc    %edx
  800a0e:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  800a11:	38 c8                	cmp    %cl,%al
  800a13:	74 10                	je     800a25 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c0             	movzbl %al,%eax
  800a18:	0f b6 c9             	movzbl %cl,%ecx
  800a1b:	29 c8                	sub    %ecx,%eax
  800a1d:	eb 16                	jmp    800a35 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	4f                   	dec    %edi
  800a20:	ba 00 00 00 00       	mov    $0x0,%edx
  800a25:	39 fa                	cmp    %edi,%edx
  800a27:	75 e0                	jne    800a09 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	eb 05                	jmp    800a35 <memcmp+0x49>
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a45:	39 d0                	cmp    %edx,%eax
  800a47:	73 12                	jae    800a5b <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a4c:	38 08                	cmp    %cl,(%eax)
  800a4e:	75 06                	jne    800a56 <memfind+0x1c>
  800a50:	eb 09                	jmp    800a5b <memfind+0x21>
  800a52:	38 08                	cmp    %cl,(%eax)
  800a54:	74 05                	je     800a5b <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a56:	40                   	inc    %eax
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	75 f7                	jne    800a52 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
  800a66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a69:	eb 01                	jmp    800a6c <strtol+0xf>
		s++;
  800a6b:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	8a 02                	mov    (%edx),%al
  800a6e:	3c 20                	cmp    $0x20,%al
  800a70:	74 f9                	je     800a6b <strtol+0xe>
  800a72:	3c 09                	cmp    $0x9,%al
  800a74:	74 f5                	je     800a6b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a76:	3c 2b                	cmp    $0x2b,%al
  800a78:	75 08                	jne    800a82 <strtol+0x25>
		s++;
  800a7a:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a80:	eb 13                	jmp    800a95 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a82:	3c 2d                	cmp    $0x2d,%al
  800a84:	75 0a                	jne    800a90 <strtol+0x33>
		s++, neg = 1;
  800a86:	8d 52 01             	lea    0x1(%edx),%edx
  800a89:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8e:	eb 05                	jmp    800a95 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	74 05                	je     800a9e <strtol+0x41>
  800a99:	83 fb 10             	cmp    $0x10,%ebx
  800a9c:	75 28                	jne    800ac6 <strtol+0x69>
  800a9e:	8a 02                	mov    (%edx),%al
  800aa0:	3c 30                	cmp    $0x30,%al
  800aa2:	75 10                	jne    800ab4 <strtol+0x57>
  800aa4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa8:	75 0a                	jne    800ab4 <strtol+0x57>
		s += 2, base = 16;
  800aaa:	83 c2 02             	add    $0x2,%edx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb 12                	jmp    800ac6 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab4:	85 db                	test   %ebx,%ebx
  800ab6:	75 0e                	jne    800ac6 <strtol+0x69>
  800ab8:	3c 30                	cmp    $0x30,%al
  800aba:	75 05                	jne    800ac1 <strtol+0x64>
		s++, base = 8;
  800abc:	42                   	inc    %edx
  800abd:	b3 08                	mov    $0x8,%bl
  800abf:	eb 05                	jmp    800ac6 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acd:	8a 0a                	mov    (%edx),%cl
  800acf:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad2:	80 fb 09             	cmp    $0x9,%bl
  800ad5:	77 08                	ja     800adf <strtol+0x82>
			dig = *s - '0';
  800ad7:	0f be c9             	movsbl %cl,%ecx
  800ada:	83 e9 30             	sub    $0x30,%ecx
  800add:	eb 1e                	jmp    800afd <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800adf:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae7:	0f be c9             	movsbl %cl,%ecx
  800aea:	83 e9 57             	sub    $0x57,%ecx
  800aed:	eb 0e                	jmp    800afd <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aef:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af2:	80 fb 19             	cmp    $0x19,%bl
  800af5:	77 12                	ja     800b09 <strtol+0xac>
			dig = *s - 'A' + 10;
  800af7:	0f be c9             	movsbl %cl,%ecx
  800afa:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afd:	39 f1                	cmp    %esi,%ecx
  800aff:	7d 0c                	jge    800b0d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b01:	42                   	inc    %edx
  800b02:	0f af c6             	imul   %esi,%eax
  800b05:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b07:	eb c4                	jmp    800acd <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b09:	89 c1                	mov    %eax,%ecx
  800b0b:	eb 02                	jmp    800b0f <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0d:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b13:	74 05                	je     800b1a <strtol+0xbd>
		*endptr = (char *) s;
  800b15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b18:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	74 04                	je     800b22 <strtol+0xc5>
  800b1e:	89 c8                	mov    %ecx,%eax
  800b20:	f7 d8                	neg    %eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    
	...

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	89 c3                	mov    %eax,%ebx
  800b3a:	89 c7                	mov    %eax,%edi
  800b3c:	51                   	push   %ecx
  800b3d:	52                   	push   %edx
  800b3e:	53                   	push   %ebx
  800b3f:	54                   	push   %esp
  800b40:	55                   	push   %ebp
  800b41:	56                   	push   %esi
  800b42:	57                   	push   %edi
  800b43:	8d 35 4d 0b 80 00    	lea    0x800b4d,%esi
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	0f 34                	sysenter 

00800b4d <after_sysenter_label16>:
  800b4d:	5f                   	pop    %edi
  800b4e:	5e                   	pop    %esi
  800b4f:	5d                   	pop    %ebp
  800b50:	5c                   	pop    %esp
  800b51:	5b                   	pop    %ebx
  800b52:	5a                   	pop    %edx
  800b53:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	51                   	push   %ecx
  800b6e:	52                   	push   %edx
  800b6f:	53                   	push   %ebx
  800b70:	54                   	push   %esp
  800b71:	55                   	push   %ebp
  800b72:	56                   	push   %esi
  800b73:	57                   	push   %edi
  800b74:	8d 35 7e 0b 80 00    	lea    0x800b7e,%esi
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	0f 34                	sysenter 

00800b7e <after_sysenter_label41>:
  800b7e:	5f                   	pop    %edi
  800b7f:	5e                   	pop    %esi
  800b80:	5d                   	pop    %ebp
  800b81:	5c                   	pop    %esp
  800b82:	5b                   	pop    %ebx
  800b83:	5a                   	pop    %edx
  800b84:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b85:	5b                   	pop    %ebx
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b96:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	89 cb                	mov    %ecx,%ebx
  800ba0:	89 cf                	mov    %ecx,%edi
  800ba2:	51                   	push   %ecx
  800ba3:	52                   	push   %edx
  800ba4:	53                   	push   %ebx
  800ba5:	54                   	push   %esp
  800ba6:	55                   	push   %ebp
  800ba7:	56                   	push   %esi
  800ba8:	57                   	push   %edi
  800ba9:	8d 35 b3 0b 80 00    	lea    0x800bb3,%esi
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	0f 34                	sysenter 

00800bb3 <after_sysenter_label68>:
  800bb3:	5f                   	pop    %edi
  800bb4:	5e                   	pop    %esi
  800bb5:	5d                   	pop    %ebp
  800bb6:	5c                   	pop    %esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5a                   	pop    %edx
  800bb9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 28                	jle    800be6 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bc9:	00 
  800bca:	c7 44 24 08 74 11 80 	movl   $0x801174,0x8(%esp)
  800bd1:	00 
  800bd2:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800bd9:	00 
  800bda:	c7 04 24 91 11 80 00 	movl   $0x801191,(%esp)
  800be1:	e8 9e 00 00 00       	call   800c84 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be6:	83 c4 20             	add    $0x20,%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfc:	89 d1                	mov    %edx,%ecx
  800bfe:	89 d3                	mov    %edx,%ebx
  800c00:	89 d7                	mov    %edx,%edi
  800c02:	51                   	push   %ecx
  800c03:	52                   	push   %edx
  800c04:	53                   	push   %ebx
  800c05:	54                   	push   %esp
  800c06:	55                   	push   %ebp
  800c07:	56                   	push   %esi
  800c08:	57                   	push   %edi
  800c09:	8d 35 13 0c 80 00    	lea    0x800c13,%esi
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	0f 34                	sysenter 

00800c13 <after_sysenter_label107>:
  800c13:	5f                   	pop    %edi
  800c14:	5e                   	pop    %esi
  800c15:	5d                   	pop    %ebp
  800c16:	5c                   	pop    %esp
  800c17:	5b                   	pop    %ebx
  800c18:	5a                   	pop    %edx
  800c19:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	51                   	push   %ecx
  800c36:	52                   	push   %edx
  800c37:	53                   	push   %ebx
  800c38:	54                   	push   %esp
  800c39:	55                   	push   %ebp
  800c3a:	56                   	push   %esi
  800c3b:	57                   	push   %edi
  800c3c:	8d 35 46 0c 80 00    	lea    0x800c46,%esi
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	0f 34                	sysenter 

00800c46 <after_sysenter_label133>:
  800c46:	5f                   	pop    %edi
  800c47:	5e                   	pop    %esi
  800c48:	5d                   	pop    %ebp
  800c49:	5c                   	pop    %esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5a                   	pop    %edx
  800c4c:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 cb                	mov    %ecx,%ebx
  800c65:	89 cf                	mov    %ecx,%edi
  800c67:	51                   	push   %ecx
  800c68:	52                   	push   %edx
  800c69:	53                   	push   %ebx
  800c6a:	54                   	push   %esp
  800c6b:	55                   	push   %ebp
  800c6c:	56                   	push   %esi
  800c6d:	57                   	push   %edi
  800c6e:	8d 35 78 0c 80 00    	lea    0x800c78,%esi
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	0f 34                	sysenter 

00800c78 <after_sysenter_label159>:
  800c78:	5f                   	pop    %edi
  800c79:	5e                   	pop    %esi
  800c7a:	5d                   	pop    %ebp
  800c7b:	5c                   	pop    %esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5a                   	pop    %edx
  800c7e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
	...

00800c84 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c8c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c8f:	a1 08 20 80 00       	mov    0x802008,%eax
  800c94:	85 c0                	test   %eax,%eax
  800c96:	74 10                	je     800ca8 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9c:	c7 04 24 9f 11 80 00 	movl   $0x80119f,(%esp)
  800ca3:	e8 f0 f4 ff ff       	call   800198 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ca8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800cae:	e8 3a ff ff ff       	call   800bed <sys_getenvid>
  800cb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb6:	89 54 24 10          	mov    %edx,0x10(%esp)
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cc1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc9:	c7 04 24 a4 11 80 00 	movl   $0x8011a4,(%esp)
  800cd0:	e8 c3 f4 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdc:	89 04 24             	mov    %eax,(%esp)
  800cdf:	e8 53 f4 ff ff       	call   800137 <vcprintf>
	cprintf("\n");
  800ce4:	c7 04 24 52 0f 80 00 	movl   $0x800f52,(%esp)
  800ceb:	e8 a8 f4 ff ff       	call   800198 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cf0:	cc                   	int3   
  800cf1:	eb fd                	jmp    800cf0 <_panic+0x6c>
	...

00800cf4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	83 ec 10             	sub    $0x10,%esp
  800cfa:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cfe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d02:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d06:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d0a:	89 cd                	mov    %ecx,%ebp
  800d0c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	75 2c                	jne    800d40 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d14:	39 f9                	cmp    %edi,%ecx
  800d16:	77 68                	ja     800d80 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d18:	85 c9                	test   %ecx,%ecx
  800d1a:	75 0b                	jne    800d27 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	f7 f1                	div    %ecx
  800d25:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d27:	31 d2                	xor    %edx,%edx
  800d29:	89 f8                	mov    %edi,%eax
  800d2b:	f7 f1                	div    %ecx
  800d2d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	f7 f1                	div    %ecx
  800d33:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d35:	89 f0                	mov    %esi,%eax
  800d37:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d40:	39 f8                	cmp    %edi,%eax
  800d42:	77 2c                	ja     800d70 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d44:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d47:	83 f6 1f             	xor    $0x1f,%esi
  800d4a:	75 4c                	jne    800d98 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d4c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d4e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d53:	72 0a                	jb     800d5f <__udivdi3+0x6b>
  800d55:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d59:	0f 87 ad 00 00 00    	ja     800e0c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d5f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d64:	89 f0                	mov    %esi,%eax
  800d66:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d70:	31 ff                	xor    %edi,%edi
  800d72:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d74:	89 f0                	mov    %esi,%eax
  800d76:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
  800d7f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d80:	89 fa                	mov    %edi,%edx
  800d82:	89 f0                	mov    %esi,%eax
  800d84:	f7 f1                	div    %ecx
  800d86:	89 c6                	mov    %eax,%esi
  800d88:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d8a:	89 f0                	mov    %esi,%eax
  800d8c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d98:	89 f1                	mov    %esi,%ecx
  800d9a:	d3 e0                	shl    %cl,%eax
  800d9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800da0:	b8 20 00 00 00       	mov    $0x20,%eax
  800da5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800da7:	89 ea                	mov    %ebp,%edx
  800da9:	88 c1                	mov    %al,%cl
  800dab:	d3 ea                	shr    %cl,%edx
  800dad:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800db1:	09 ca                	or     %ecx,%edx
  800db3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800db7:	89 f1                	mov    %esi,%ecx
  800db9:	d3 e5                	shl    %cl,%ebp
  800dbb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800dbf:	89 fd                	mov    %edi,%ebp
  800dc1:	88 c1                	mov    %al,%cl
  800dc3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800dc5:	89 fa                	mov    %edi,%edx
  800dc7:	89 f1                	mov    %esi,%ecx
  800dc9:	d3 e2                	shl    %cl,%edx
  800dcb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dcf:	88 c1                	mov    %al,%cl
  800dd1:	d3 ef                	shr    %cl,%edi
  800dd3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dd5:	89 f8                	mov    %edi,%eax
  800dd7:	89 ea                	mov    %ebp,%edx
  800dd9:	f7 74 24 08          	divl   0x8(%esp)
  800ddd:	89 d1                	mov    %edx,%ecx
  800ddf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800de1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de5:	39 d1                	cmp    %edx,%ecx
  800de7:	72 17                	jb     800e00 <__udivdi3+0x10c>
  800de9:	74 09                	je     800df4 <__udivdi3+0x100>
  800deb:	89 fe                	mov    %edi,%esi
  800ded:	31 ff                	xor    %edi,%edi
  800def:	e9 41 ff ff ff       	jmp    800d35 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800df4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800df8:	89 f1                	mov    %esi,%ecx
  800dfa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dfc:	39 c2                	cmp    %eax,%edx
  800dfe:	73 eb                	jae    800deb <__udivdi3+0xf7>
		{
		  q0--;
  800e00:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e03:	31 ff                	xor    %edi,%edi
  800e05:	e9 2b ff ff ff       	jmp    800d35 <__udivdi3+0x41>
  800e0a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e0c:	31 f6                	xor    %esi,%esi
  800e0e:	e9 22 ff ff ff       	jmp    800d35 <__udivdi3+0x41>
	...

00800e14 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	83 ec 20             	sub    $0x20,%esp
  800e1a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e1e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e22:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e26:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e2a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e2e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e32:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e34:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e36:	85 ed                	test   %ebp,%ebp
  800e38:	75 16                	jne    800e50 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e3a:	39 f1                	cmp    %esi,%ecx
  800e3c:	0f 86 a6 00 00 00    	jbe    800ee8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e42:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e44:	89 d0                	mov    %edx,%eax
  800e46:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e48:	83 c4 20             	add    $0x20,%esp
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    
  800e4f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e50:	39 f5                	cmp    %esi,%ebp
  800e52:	0f 87 ac 00 00 00    	ja     800f04 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e58:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e5b:	83 f0 1f             	xor    $0x1f,%eax
  800e5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e62:	0f 84 a8 00 00 00    	je     800f10 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e68:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e6c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e6e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e73:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e77:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e7b:	89 f9                	mov    %edi,%ecx
  800e7d:	d3 e8                	shr    %cl,%eax
  800e7f:	09 e8                	or     %ebp,%eax
  800e81:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e85:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e89:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e8d:	d3 e0                	shl    %cl,%eax
  800e8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e93:	89 f2                	mov    %esi,%edx
  800e95:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e97:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e9b:	d3 e0                	shl    %cl,%eax
  800e9d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ea1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 e8                	shr    %cl,%eax
  800ea9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800eab:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	f7 74 24 18          	divl   0x18(%esp)
  800eb3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800eb5:	f7 64 24 0c          	mull   0xc(%esp)
  800eb9:	89 c5                	mov    %eax,%ebp
  800ebb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ebd:	39 d6                	cmp    %edx,%esi
  800ebf:	72 67                	jb     800f28 <__umoddi3+0x114>
  800ec1:	74 75                	je     800f38 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ec3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ec7:	29 e8                	sub    %ebp,%eax
  800ec9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ecb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ecf:	d3 e8                	shr    %cl,%eax
  800ed1:	89 f2                	mov    %esi,%edx
  800ed3:	89 f9                	mov    %edi,%ecx
  800ed5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ed7:	09 d0                	or     %edx,%eax
  800ed9:	89 f2                	mov    %esi,%edx
  800edb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800edf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee1:	83 c4 20             	add    $0x20,%esp
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ee8:	85 c9                	test   %ecx,%ecx
  800eea:	75 0b                	jne    800ef7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef1:	31 d2                	xor    %edx,%edx
  800ef3:	f7 f1                	div    %ecx
  800ef5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ef7:	89 f0                	mov    %esi,%eax
  800ef9:	31 d2                	xor    %edx,%edx
  800efb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	e9 3e ff ff ff       	jmp    800e42 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f04:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f06:	83 c4 20             	add    $0x20,%esp
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f10:	39 f5                	cmp    %esi,%ebp
  800f12:	72 04                	jb     800f18 <__umoddi3+0x104>
  800f14:	39 f9                	cmp    %edi,%ecx
  800f16:	77 06                	ja     800f1e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	29 cf                	sub    %ecx,%edi
  800f1c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f1e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f20:	83 c4 20             	add    $0x20,%esp
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    
  800f27:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 c5                	mov    %eax,%ebp
  800f2c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f30:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f34:	eb 8d                	jmp    800ec3 <__umoddi3+0xaf>
  800f36:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f38:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f3c:	72 ea                	jb     800f28 <__umoddi3+0x114>
  800f3e:	89 f1                	mov    %esi,%ecx
  800f40:	eb 81                	jmp    800ec3 <__umoddi3+0xaf>
