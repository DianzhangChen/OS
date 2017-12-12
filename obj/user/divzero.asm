
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 34 0f 80 00 	movl   $0x800f34,(%esp)
  80005c:	e8 27 01 00 00       	call   800188 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 10             	sub    $0x10,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800072:	e8 66 0b 00 00       	call   800bdd <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80007f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800082:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800089:	a3 08 20 80 00       	mov    %eax,0x802008
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80008e:	c7 04 24 42 0f 80 00 	movl   $0x800f42,(%esp)
  800095:	e8 ee 00 00 00       	call   800188 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  80009a:	a1 08 20 80 00       	mov    0x802008,%eax
  80009f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a3:	c7 04 24 52 0f 80 00 	movl   $0x800f52,(%esp)
  8000aa:	e8 d9 00 00 00       	call   800188 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 07                	jle    8000ba <libmain+0x56>
		binaryname = argv[0];
  8000b3:	8b 03                	mov    (%ebx),%eax
  8000b5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000be:	89 34 24             	mov    %esi,(%esp)
  8000c1:	e8 6e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 09 00 00 00       	call   8000d4 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    
	...

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e1:	e8 93 0a 00 00       	call   800b79 <sys_env_destroy>
}
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 14             	sub    $0x14,%esp
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f2:	8b 03                	mov    (%ebx),%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000fb:	40                   	inc    %eax
  8000fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800103:	75 19                	jne    80011e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800105:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80010c:	00 
  80010d:	8d 43 08             	lea    0x8(%ebx),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 00 0a 00 00       	call   800b18 <sys_cputs>
		b->idx = 0;
  800118:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80011e:	ff 43 04             	incl   0x4(%ebx)
}
  800121:	83 c4 14             	add    $0x14,%esp
  800124:	5b                   	pop    %ebx
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800130:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800137:	00 00 00 
	b.cnt = 0;
  80013a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800141:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800144:	8b 45 0c             	mov    0xc(%ebp),%eax
  800147:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014b:	8b 45 08             	mov    0x8(%ebp),%eax
  80014e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800152:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	c7 04 24 e8 00 80 00 	movl   $0x8000e8,(%esp)
  800163:	e8 8d 01 00 00       	call   8002f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800172:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 98 09 00 00       	call   800b18 <sys_cputs>

	return b.cnt;
}
  800180:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 87 ff ff ff       	call   800127 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    
	...

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 3c             	sub    $0x3c,%esp
  8001ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b0:	89 d7                	mov    %edx,%edi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001cc:	72 0f                	jb     8001dd <printnum+0x39>
  8001ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d4:	76 07                	jbe    8001dd <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d6:	4b                   	dec    %ebx
  8001d7:	85 db                	test   %ebx,%ebx
  8001d9:	7f 4f                	jg     80022a <printnum+0x86>
  8001db:	eb 5a                	jmp    800237 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e1:	4b                   	dec    %ebx
  8001e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ed:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fc:	00 
  8001fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020a:	e8 d5 0a 00 00       	call   800ce4 <__udivdi3>
  80020f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800213:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021e:	89 fa                	mov    %edi,%edx
  800220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800223:	e8 7c ff ff ff       	call   8001a4 <printnum>
  800228:	eb 0d                	jmp    800237 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022e:	89 34 24             	mov    %esi,(%esp)
  800231:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	4b                   	dec    %ebx
  800235:	75 f3                	jne    80022a <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800237:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80023f:	8b 45 10             	mov    0x10(%ebp),%eax
  800242:	89 44 24 08          	mov    %eax,0x8(%esp)
  800246:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024d:	00 
  80024e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	e8 a4 0b 00 00       	call   800e04 <__umoddi3>
  800260:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800264:	0f be 80 6f 0f 80 00 	movsbl 0x800f6f(%eax),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800271:	83 c4 3c             	add    $0x3c,%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027c:	83 fa 01             	cmp    $0x1,%edx
  80027f:	7e 0e                	jle    80028f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 08             	lea    0x8(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	8b 52 04             	mov    0x4(%edx),%edx
  80028d:	eb 22                	jmp    8002b1 <getuint+0x38>
	else if (lflag)
  80028f:	85 d2                	test   %edx,%edx
  800291:	74 10                	je     8002a3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800293:	8b 10                	mov    (%eax),%edx
  800295:	8d 4a 04             	lea    0x4(%edx),%ecx
  800298:	89 08                	mov    %ecx,(%eax)
  80029a:	8b 02                	mov    (%edx),%eax
  80029c:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a1:	eb 0e                	jmp    8002b1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c1:	73 08                	jae    8002cb <sprintputch+0x18>
		*b->buf++ = ch;
  8002c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c6:	88 0a                	mov    %cl,(%edx)
  8002c8:	42                   	inc    %edx
  8002c9:	89 10                	mov    %edx,(%eax)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002da:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	e8 02 00 00 00       	call   8002f5 <vprintfmt>
	va_end(ap);
}
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 4c             	sub    $0x4c,%esp
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800301:	8b 75 10             	mov    0x10(%ebp),%esi
  800304:	eb 17                	jmp    80031d <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800306:	85 c0                	test   %eax,%eax
  800308:	0f 84 93 03 00 00    	je     8006a1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80030e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	ff 55 08             	call   *0x8(%ebp)
  800318:	eb 03                	jmp    80031d <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	0f b6 06             	movzbl (%esi),%eax
  800320:	46                   	inc    %esi
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	75 e0                	jne    800306 <vprintfmt+0x11>
  800326:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800336:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	eb 26                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034b:	eb 1d                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800350:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800354:	eb 14                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800359:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800360:	eb 08                	jmp    80036a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800362:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800365:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 16             	movzbl (%esi),%edx
  80036d:	8d 46 01             	lea    0x1(%esi),%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	8a 06                	mov    (%esi),%al
  800375:	83 e8 23             	sub    $0x23,%eax
  800378:	3c 55                	cmp    $0x55,%al
  80037a:	0f 87 fd 02 00 00    	ja     80067d <vprintfmt+0x388>
  800380:	0f b6 c0             	movzbl %al,%eax
  800383:	ff 24 85 fc 0f 80 00 	jmp    *0x800ffc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038a:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  80038d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800391:	8d 50 d0             	lea    -0x30(%eax),%edx
  800394:	83 fa 09             	cmp    $0x9,%edx
  800397:	77 3f                	ja     8003d8 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039c:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80039d:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003a0:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003a4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a7:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003aa:	83 fa 09             	cmp    $0x9,%edx
  8003ad:	76 ed                	jbe    80039c <vprintfmt+0xa7>
  8003af:	eb 2a                	jmp    8003db <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 50 04             	lea    0x4(%eax),%edx
  8003b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ba:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bf:	eb 1a                	jmp    8003db <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c5:	78 8f                	js     800356 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ca:	eb 9e                	jmp    80036a <vprintfmt+0x75>
  8003cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cf:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003d6:	eb 92                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003df:	79 89                	jns    80036a <vprintfmt+0x75>
  8003e1:	e9 7c ff ff ff       	jmp    800362 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ea:	e9 7b ff ff ff       	jmp    80036a <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	89 04 24             	mov    %eax,(%esp)
  800401:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800407:	e9 11 ff ff ff       	jmp    80031d <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	85 c0                	test   %eax,%eax
  800419:	79 02                	jns    80041d <vprintfmt+0x128>
  80041b:	f7 d8                	neg    %eax
  80041d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 06             	cmp    $0x6,%eax
  800422:	7f 0b                	jg     80042f <vprintfmt+0x13a>
  800424:	8b 04 85 54 11 80 00 	mov    0x801154(,%eax,4),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	75 23                	jne    800452 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80042f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800433:	c7 44 24 08 87 0f 80 	movl   $0x800f87,0x8(%esp)
  80043a:	00 
  80043b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043f:	8b 55 08             	mov    0x8(%ebp),%edx
  800442:	89 14 24             	mov    %edx,(%esp)
  800445:	e8 83 fe ff ff       	call   8002cd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044d:	e9 cb fe ff ff       	jmp    80031d <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	c7 44 24 08 90 0f 80 	movl   $0x800f90,0x8(%esp)
  80045d:	00 
  80045e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800462:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800465:	89 0c 24             	mov    %ecx,(%esp)
  800468:	e8 60 fe ff ff       	call   8002cd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800470:	e9 a8 fe ff ff       	jmp    80031d <vprintfmt+0x28>
  800475:	89 f9                	mov    %edi,%ecx
  800477:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 50 04             	lea    0x4(%eax),%edx
  800480:	89 55 14             	mov    %edx,0x14(%ebp)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800488:	85 c0                	test   %eax,%eax
  80048a:	75 07                	jne    800493 <vprintfmt+0x19e>
				p = "(null)";
  80048c:	c7 45 d4 80 0f 80 00 	movl   $0x800f80,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800493:	85 f6                	test   %esi,%esi
  800495:	7e 3b                	jle    8004d2 <vprintfmt+0x1dd>
  800497:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80049b:	74 35                	je     8004d2 <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 a4 02 00 00       	call   800750 <strnlen>
  8004ac:	29 c6                	sub    %eax,%esi
  8004ae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004b1:	85 f6                	test   %esi,%esi
  8004b3:	7e 1d                	jle    8004d2 <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004b5:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004b9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	89 34 24             	mov    %esi,(%esp)
  8004c6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	4f                   	dec    %edi
  8004ca:	75 f3                	jne    8004bf <vprintfmt+0x1ca>
  8004cc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004cf:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d5:	0f be 02             	movsbl (%edx),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	75 43                	jne    80051f <vprintfmt+0x22a>
  8004dc:	eb 33                	jmp    800511 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004de:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e2:	74 18                	je     8004fc <vprintfmt+0x207>
  8004e4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ea:	76 10                	jbe    8004fc <vprintfmt+0x207>
					putch('?', putdat);
  8004ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	eb 0a                	jmp    800506 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800506:	ff 4d e4             	decl   -0x1c(%ebp)
  800509:	0f be 06             	movsbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	85 c0                	test   %eax,%eax
  80050f:	75 12                	jne    800523 <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800511:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800515:	7f 15                	jg     80052c <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 fe fd ff ff       	jmp    80031d <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800522:	46                   	inc    %esi
  800523:	85 ff                	test   %edi,%edi
  800525:	78 b7                	js     8004de <vprintfmt+0x1e9>
  800527:	4f                   	dec    %edi
  800528:	79 b4                	jns    8004de <vprintfmt+0x1e9>
  80052a:	eb e5                	jmp    800511 <vprintfmt+0x21c>
  80052c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80052f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800532:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800536:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80053d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053f:	4e                   	dec    %esi
  800540:	75 f0                	jne    800532 <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800545:	e9 d3 fd ff ff       	jmp    80031d <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054a:	83 f9 01             	cmp    $0x1,%ecx
  80054d:	7e 10                	jle    80055f <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 08             	lea    0x8(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 30                	mov    (%eax),%esi
  80055a:	8b 78 04             	mov    0x4(%eax),%edi
  80055d:	eb 26                	jmp    800585 <vprintfmt+0x290>
	else if (lflag)
  80055f:	85 c9                	test   %ecx,%ecx
  800561:	74 12                	je     800575 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 30                	mov    (%eax),%esi
  80056e:	89 f7                	mov    %esi,%edi
  800570:	c1 ff 1f             	sar    $0x1f,%edi
  800573:	eb 10                	jmp    800585 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 30                	mov    (%eax),%esi
  800580:	89 f7                	mov    %esi,%edi
  800582:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800585:	85 ff                	test   %edi,%edi
  800587:	78 0e                	js     800597 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800589:	89 f0                	mov    %esi,%eax
  80058b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058d:	be 0a 00 00 00       	mov    $0xa,%esi
  800592:	e9 a8 00 00 00       	jmp    80063f <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800597:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a5:	89 f0                	mov    %esi,%eax
  8005a7:	89 fa                	mov    %edi,%edx
  8005a9:	f7 d8                	neg    %eax
  8005ab:	83 d2 00             	adc    $0x0,%edx
  8005ae:	f7 da                	neg    %edx
			}
			base = 10;
  8005b0:	be 0a 00 00 00       	mov    $0xa,%esi
  8005b5:	e9 85 00 00 00       	jmp    80063f <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ba:	89 ca                	mov    %ecx,%edx
  8005bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bf:	e8 b5 fc ff ff       	call   800279 <getuint>
			base = 10;
  8005c4:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005c9:	eb 74                	jmp    80063f <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cf:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005d6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005e4:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005f2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005f8:	e9 20 fd ff ff       	jmp    80031d <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800601:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800629:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80062e:	eb 0f                	jmp    80063f <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800630:	89 ca                	mov    %ecx,%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 3f fc ff ff       	call   800279 <getuint>
			base = 16;
  80063a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063f:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800643:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800647:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80064a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80064e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800652:	89 04 24             	mov    %eax,(%esp)
  800655:	89 54 24 04          	mov    %edx,0x4(%esp)
  800659:	89 da                	mov    %ebx,%edx
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	e8 41 fb ff ff       	call   8001a4 <printnum>
			break;
  800663:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800666:	e9 b2 fc ff ff       	jmp    80031d <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066f:	89 14 24             	mov    %edx,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800678:	e9 a0 fc ff ff       	jmp    80031d <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800681:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068f:	0f 84 88 fc ff ff    	je     80031d <vprintfmt+0x28>
  800695:	4e                   	dec    %esi
  800696:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069a:	75 f9                	jne    800695 <vprintfmt+0x3a0>
  80069c:	e9 7c fc ff ff       	jmp    80031d <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  8006a1:	83 c4 4c             	add    $0x4c,%esp
  8006a4:	5b                   	pop    %ebx
  8006a5:	5e                   	pop    %esi
  8006a6:	5f                   	pop    %edi
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 28             	sub    $0x28,%esp
  8006af:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	74 30                	je     8006fa <vsnprintf+0x51>
  8006ca:	85 d2                	test   %edx,%edx
  8006cc:	7e 33                	jle    800701 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e3:	c7 04 24 b3 02 80 00 	movl   $0x8002b3,(%esp)
  8006ea:	e8 06 fc ff ff       	call   8002f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	eb 0c                	jmp    800706 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ff:	eb 05                	jmp    800706 <vsnprintf+0x5d>
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800715:	8b 45 10             	mov    0x10(%ebp),%eax
  800718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	89 04 24             	mov    %eax,(%esp)
  800729:	e8 7b ff ff ff       	call   8006a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3a 00             	cmpb   $0x0,(%edx)
  800739:	74 0e                	je     800749 <strlen+0x19>
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800740:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800745:	75 f9                	jne    800740 <strlen+0x10>
  800747:	eb 05                	jmp    80074e <strlen+0x1e>
  800749:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	74 1a                	je     800778 <strnlen+0x28>
  80075e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800761:	74 1c                	je     80077f <strnlen+0x2f>
  800763:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800768:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	39 ca                	cmp    %ecx,%edx
  80076c:	74 16                	je     800784 <strnlen+0x34>
  80076e:	42                   	inc    %edx
  80076f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800774:	75 f2                	jne    800768 <strnlen+0x18>
  800776:	eb 0c                	jmp    800784 <strnlen+0x34>
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 05                	jmp    800784 <strnlen+0x34>
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
  800796:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800799:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80079c:	42                   	inc    %edx
  80079d:	84 c9                	test   %cl,%cl
  80079f:	75 f5                	jne    800796 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a1:	5b                   	pop    %ebx
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	89 1c 24             	mov    %ebx,(%esp)
  8007b1:	e8 7a ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bd:	01 d8                	add    %ebx,%eax
  8007bf:	89 04 24             	mov    %eax,(%esp)
  8007c2:	e8 c0 ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	83 c4 08             	add    $0x8,%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	85 f6                	test   %esi,%esi
  8007df:	74 15                	je     8007f6 <strncpy+0x27>
  8007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007e6:	8a 1a                	mov    (%edx),%bl
  8007e8:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007eb:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ee:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	41                   	inc    %ecx
  8007f2:	39 f1                	cmp    %esi,%ecx
  8007f4:	75 f0                	jne    8007e6 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	57                   	push   %edi
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 7d 08             	mov    0x8(%ebp),%edi
  800803:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800806:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800809:	85 f6                	test   %esi,%esi
  80080b:	74 31                	je     80083e <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  80080d:	83 fe 01             	cmp    $0x1,%esi
  800810:	74 21                	je     800833 <strlcpy+0x39>
  800812:	8a 0b                	mov    (%ebx),%cl
  800814:	84 c9                	test   %cl,%cl
  800816:	74 1f                	je     800837 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800818:	83 ee 02             	sub    $0x2,%esi
  80081b:	89 f8                	mov    %edi,%eax
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	88 08                	mov    %cl,(%eax)
  800824:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800825:	39 f2                	cmp    %esi,%edx
  800827:	74 10                	je     800839 <strlcpy+0x3f>
  800829:	42                   	inc    %edx
  80082a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 f1                	jne    800822 <strlcpy+0x28>
  800831:	eb 06                	jmp    800839 <strlcpy+0x3f>
  800833:	89 f8                	mov    %edi,%eax
  800835:	eb 02                	jmp    800839 <strlcpy+0x3f>
  800837:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 00 00             	movb   $0x0,(%eax)
  80083c:	eb 02                	jmp    800840 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800840:	29 f8                	sub    %edi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5f                   	pop    %edi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800850:	8a 01                	mov    (%ecx),%al
  800852:	84 c0                	test   %al,%al
  800854:	74 11                	je     800867 <strcmp+0x20>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	75 0d                	jne    800867 <strcmp+0x20>
		p++, q++;
  80085a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085b:	8a 41 01             	mov    0x1(%ecx),%al
  80085e:	84 c0                	test   %al,%al
  800860:	74 05                	je     800867 <strcmp+0x20>
  800862:	41                   	inc    %ecx
  800863:	3a 02                	cmp    (%edx),%al
  800865:	74 f3                	je     80085a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 c0             	movzbl %al,%eax
  80086a:	0f b6 12             	movzbl (%edx),%edx
  80086d:	29 d0                	sub    %edx,%eax
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 55 08             	mov    0x8(%ebp),%edx
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087b:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80087e:	85 c0                	test   %eax,%eax
  800880:	74 1b                	je     80089d <strncmp+0x2c>
  800882:	8a 1a                	mov    (%edx),%bl
  800884:	84 db                	test   %bl,%bl
  800886:	74 24                	je     8008ac <strncmp+0x3b>
  800888:	3a 19                	cmp    (%ecx),%bl
  80088a:	75 20                	jne    8008ac <strncmp+0x3b>
  80088c:	48                   	dec    %eax
  80088d:	74 15                	je     8008a4 <strncmp+0x33>
		n--, p++, q++;
  80088f:	42                   	inc    %edx
  800890:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800891:	8a 1a                	mov    (%edx),%bl
  800893:	84 db                	test   %bl,%bl
  800895:	74 15                	je     8008ac <strncmp+0x3b>
  800897:	3a 19                	cmp    (%ecx),%bl
  800899:	74 f1                	je     80088c <strncmp+0x1b>
  80089b:	eb 0f                	jmp    8008ac <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 05                	jmp    8008a9 <strncmp+0x38>
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 02             	movzbl (%edx),%eax
  8008af:	0f b6 11             	movzbl (%ecx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb f3                	jmp    8008a9 <strncmp+0x38>

008008b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bf:	8a 10                	mov    (%eax),%dl
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 19                	je     8008de <strchr+0x28>
		if (*s == c)
  8008c5:	38 ca                	cmp    %cl,%dl
  8008c7:	75 07                	jne    8008d0 <strchr+0x1a>
  8008c9:	eb 18                	jmp    8008e3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cb:	40                   	inc    %eax
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 13                	je     8008e3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	8a 50 01             	mov    0x1(%eax),%dl
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f4                	jne    8008cb <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	eb 05                	jmp    8008e3 <strchr+0x2d>
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ee:	8a 10                	mov    (%eax),%dl
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	74 11                	je     800905 <strfind+0x20>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	75 06                	jne    8008fe <strfind+0x19>
  8008f8:	eb 0b                	jmp    800905 <strfind+0x20>
  8008fa:	38 ca                	cmp    %cl,%dl
  8008fc:	74 07                	je     800905 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008fe:	40                   	inc    %eax
  8008ff:	8a 10                	mov    (%eax),%dl
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f5                	jne    8008fa <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	8b 45 0c             	mov    0xc(%ebp),%eax
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	74 30                	je     80094a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800920:	75 25                	jne    800947 <memset+0x40>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	75 20                	jne    800947 <memset+0x40>
		c &= 0xFF;
  800927:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092a:	89 d3                	mov    %edx,%ebx
  80092c:	c1 e3 08             	shl    $0x8,%ebx
  80092f:	89 d6                	mov    %edx,%esi
  800931:	c1 e6 18             	shl    $0x18,%esi
  800934:	89 d0                	mov    %edx,%eax
  800936:	c1 e0 10             	shl    $0x10,%eax
  800939:	09 f0                	or     %esi,%eax
  80093b:	09 d0                	or     %edx,%eax
  80093d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800942:	fc                   	cld    
  800943:	f3 ab                	rep stos %eax,%es:(%edi)
  800945:	eb 03                	jmp    80094a <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800947:	fc                   	cld    
  800948:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094a:	89 f8                	mov    %edi,%eax
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095f:	39 c6                	cmp    %eax,%esi
  800961:	73 34                	jae    800997 <memmove+0x46>
  800963:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800966:	39 d0                	cmp    %edx,%eax
  800968:	73 2d                	jae    800997 <memmove+0x46>
		s += n;
		d += n;
  80096a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	f6 c2 03             	test   $0x3,%dl
  800970:	75 1b                	jne    80098d <memmove+0x3c>
  800972:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800978:	75 13                	jne    80098d <memmove+0x3c>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0e                	jne    80098d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097f:	83 ef 04             	sub    $0x4,%edi
  800982:	8d 72 fc             	lea    -0x4(%edx),%esi
  800985:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800988:	fd                   	std    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 07                	jmp    800994 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098d:	4f                   	dec    %edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 20                	jmp    8009b7 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099d:	75 13                	jne    8009b2 <memmove+0x61>
  80099f:	a8 03                	test   $0x3,%al
  8009a1:	75 0f                	jne    8009b2 <memmove+0x61>
  8009a3:	f6 c1 03             	test   $0x3,%cl
  8009a6:	75 0a                	jne    8009b2 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 05                	jmp    8009b7 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 77 ff ff ff       	call   800951 <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009eb:	85 ff                	test   %edi,%edi
  8009ed:	74 31                	je     800a20 <memcmp+0x44>
		if (*s1 != *s2)
  8009ef:	8a 03                	mov    (%ebx),%al
  8009f1:	8a 0e                	mov    (%esi),%cl
  8009f3:	38 c8                	cmp    %cl,%al
  8009f5:	74 18                	je     800a0f <memcmp+0x33>
  8009f7:	eb 0c                	jmp    800a05 <memcmp+0x29>
  8009f9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009fd:	42                   	inc    %edx
  8009fe:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  800a01:	38 c8                	cmp    %cl,%al
  800a03:	74 10                	je     800a15 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 c9             	movzbl %cl,%ecx
  800a0b:	29 c8                	sub    %ecx,%eax
  800a0d:	eb 16                	jmp    800a25 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	4f                   	dec    %edi
  800a10:	ba 00 00 00 00       	mov    $0x0,%edx
  800a15:	39 fa                	cmp    %edi,%edx
  800a17:	75 e0                	jne    8009f9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1e:	eb 05                	jmp    800a25 <memcmp+0x49>
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a30:	89 c2                	mov    %eax,%edx
  800a32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a35:	39 d0                	cmp    %edx,%eax
  800a37:	73 12                	jae    800a4b <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a39:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a3c:	38 08                	cmp    %cl,(%eax)
  800a3e:	75 06                	jne    800a46 <memfind+0x1c>
  800a40:	eb 09                	jmp    800a4b <memfind+0x21>
  800a42:	38 08                	cmp    %cl,(%eax)
  800a44:	74 05                	je     800a4b <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a46:	40                   	inc    %eax
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	75 f7                	jne    800a42 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a59:	eb 01                	jmp    800a5c <strtol+0xf>
		s++;
  800a5b:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5c:	8a 02                	mov    (%edx),%al
  800a5e:	3c 20                	cmp    $0x20,%al
  800a60:	74 f9                	je     800a5b <strtol+0xe>
  800a62:	3c 09                	cmp    $0x9,%al
  800a64:	74 f5                	je     800a5b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a66:	3c 2b                	cmp    $0x2b,%al
  800a68:	75 08                	jne    800a72 <strtol+0x25>
		s++;
  800a6a:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a70:	eb 13                	jmp    800a85 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a72:	3c 2d                	cmp    $0x2d,%al
  800a74:	75 0a                	jne    800a80 <strtol+0x33>
		s++, neg = 1;
  800a76:	8d 52 01             	lea    0x1(%edx),%edx
  800a79:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7e:	eb 05                	jmp    800a85 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a85:	85 db                	test   %ebx,%ebx
  800a87:	74 05                	je     800a8e <strtol+0x41>
  800a89:	83 fb 10             	cmp    $0x10,%ebx
  800a8c:	75 28                	jne    800ab6 <strtol+0x69>
  800a8e:	8a 02                	mov    (%edx),%al
  800a90:	3c 30                	cmp    $0x30,%al
  800a92:	75 10                	jne    800aa4 <strtol+0x57>
  800a94:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a98:	75 0a                	jne    800aa4 <strtol+0x57>
		s += 2, base = 16;
  800a9a:	83 c2 02             	add    $0x2,%edx
  800a9d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa2:	eb 12                	jmp    800ab6 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	75 0e                	jne    800ab6 <strtol+0x69>
  800aa8:	3c 30                	cmp    $0x30,%al
  800aaa:	75 05                	jne    800ab1 <strtol+0x64>
		s++, base = 8;
  800aac:	42                   	inc    %edx
  800aad:	b3 08                	mov    $0x8,%bl
  800aaf:	eb 05                	jmp    800ab6 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abd:	8a 0a                	mov    (%edx),%cl
  800abf:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac2:	80 fb 09             	cmp    $0x9,%bl
  800ac5:	77 08                	ja     800acf <strtol+0x82>
			dig = *s - '0';
  800ac7:	0f be c9             	movsbl %cl,%ecx
  800aca:	83 e9 30             	sub    $0x30,%ecx
  800acd:	eb 1e                	jmp    800aed <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800acf:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad2:	80 fb 19             	cmp    $0x19,%bl
  800ad5:	77 08                	ja     800adf <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad7:	0f be c9             	movsbl %cl,%ecx
  800ada:	83 e9 57             	sub    $0x57,%ecx
  800add:	eb 0e                	jmp    800aed <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800adf:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 12                	ja     800af9 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae7:	0f be c9             	movsbl %cl,%ecx
  800aea:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aed:	39 f1                	cmp    %esi,%ecx
  800aef:	7d 0c                	jge    800afd <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af1:	42                   	inc    %edx
  800af2:	0f af c6             	imul   %esi,%eax
  800af5:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af7:	eb c4                	jmp    800abd <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af9:	89 c1                	mov    %eax,%ecx
  800afb:	eb 02                	jmp    800aff <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afd:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xbd>
		*endptr = (char *) s;
  800b05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b08:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b0a:	85 ff                	test   %edi,%edi
  800b0c:	74 04                	je     800b12 <strtol+0xc5>
  800b0e:	89 c8                	mov    %ecx,%eax
  800b10:	f7 d8                	neg    %eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    
	...

00800b18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	51                   	push   %ecx
  800b2d:	52                   	push   %edx
  800b2e:	53                   	push   %ebx
  800b2f:	54                   	push   %esp
  800b30:	55                   	push   %ebp
  800b31:	56                   	push   %esi
  800b32:	57                   	push   %edi
  800b33:	8d 35 3d 0b 80 00    	lea    0x800b3d,%esi
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	0f 34                	sysenter 

00800b3d <after_sysenter_label16>:
  800b3d:	5f                   	pop    %edi
  800b3e:	5e                   	pop    %esi
  800b3f:	5d                   	pop    %ebp
  800b40:	5c                   	pop    %esp
  800b41:	5b                   	pop    %ebx
  800b42:	5a                   	pop    %edx
  800b43:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	51                   	push   %ecx
  800b5e:	52                   	push   %edx
  800b5f:	53                   	push   %ebx
  800b60:	54                   	push   %esp
  800b61:	55                   	push   %ebp
  800b62:	56                   	push   %esi
  800b63:	57                   	push   %edi
  800b64:	8d 35 6e 0b 80 00    	lea    0x800b6e,%esi
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	0f 34                	sysenter 

00800b6e <after_sysenter_label41>:
  800b6e:	5f                   	pop    %edi
  800b6f:	5e                   	pop    %esi
  800b70:	5d                   	pop    %ebp
  800b71:	5c                   	pop    %esp
  800b72:	5b                   	pop    %ebx
  800b73:	5a                   	pop    %edx
  800b74:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b86:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 cb                	mov    %ecx,%ebx
  800b90:	89 cf                	mov    %ecx,%edi
  800b92:	51                   	push   %ecx
  800b93:	52                   	push   %edx
  800b94:	53                   	push   %ebx
  800b95:	54                   	push   %esp
  800b96:	55                   	push   %ebp
  800b97:	56                   	push   %esi
  800b98:	57                   	push   %edi
  800b99:	8d 35 a3 0b 80 00    	lea    0x800ba3,%esi
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	0f 34                	sysenter 

00800ba3 <after_sysenter_label68>:
  800ba3:	5f                   	pop    %edi
  800ba4:	5e                   	pop    %esi
  800ba5:	5d                   	pop    %ebp
  800ba6:	5c                   	pop    %esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5a                   	pop    %edx
  800ba9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 28                	jle    800bd6 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb9:	00 
  800bba:	c7 44 24 08 70 11 80 	movl   $0x801170,0x8(%esp)
  800bc1:	00 
  800bc2:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800bc9:	00 
  800bca:	c7 04 24 8d 11 80 00 	movl   $0x80118d,(%esp)
  800bd1:	e8 9e 00 00 00       	call   800c74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd6:	83 c4 20             	add    $0x20,%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bec:	89 d1                	mov    %edx,%ecx
  800bee:	89 d3                	mov    %edx,%ebx
  800bf0:	89 d7                	mov    %edx,%edi
  800bf2:	51                   	push   %ecx
  800bf3:	52                   	push   %edx
  800bf4:	53                   	push   %ebx
  800bf5:	54                   	push   %esp
  800bf6:	55                   	push   %ebp
  800bf7:	56                   	push   %esi
  800bf8:	57                   	push   %edi
  800bf9:	8d 35 03 0c 80 00    	lea    0x800c03,%esi
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	0f 34                	sysenter 

00800c03 <after_sysenter_label107>:
  800c03:	5f                   	pop    %edi
  800c04:	5e                   	pop    %esi
  800c05:	5d                   	pop    %ebp
  800c06:	5c                   	pop    %esp
  800c07:	5b                   	pop    %ebx
  800c08:	5a                   	pop    %edx
  800c09:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	51                   	push   %ecx
  800c26:	52                   	push   %edx
  800c27:	53                   	push   %ebx
  800c28:	54                   	push   %esp
  800c29:	55                   	push   %ebp
  800c2a:	56                   	push   %esi
  800c2b:	57                   	push   %edi
  800c2c:	8d 35 36 0c 80 00    	lea    0x800c36,%esi
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	0f 34                	sysenter 

00800c36 <after_sysenter_label133>:
  800c36:	5f                   	pop    %edi
  800c37:	5e                   	pop    %esi
  800c38:	5d                   	pop    %ebp
  800c39:	5c                   	pop    %esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5a                   	pop    %edx
  800c3c:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 cb                	mov    %ecx,%ebx
  800c55:	89 cf                	mov    %ecx,%edi
  800c57:	51                   	push   %ecx
  800c58:	52                   	push   %edx
  800c59:	53                   	push   %ebx
  800c5a:	54                   	push   %esp
  800c5b:	55                   	push   %ebp
  800c5c:	56                   	push   %esi
  800c5d:	57                   	push   %edi
  800c5e:	8d 35 68 0c 80 00    	lea    0x800c68,%esi
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	0f 34                	sysenter 

00800c68 <after_sysenter_label159>:
  800c68:	5f                   	pop    %edi
  800c69:	5e                   	pop    %esi
  800c6a:	5d                   	pop    %ebp
  800c6b:	5c                   	pop    %esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5a                   	pop    %edx
  800c6e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
	...

00800c74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c7c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c7f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800c84:	85 c0                	test   %eax,%eax
  800c86:	74 10                	je     800c98 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  800c93:	e8 f0 f4 ff ff       	call   800188 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c98:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c9e:	e8 3a ff ff ff       	call   800bdd <sys_getenvid>
  800ca3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca6:	89 54 24 10          	mov    %edx,0x10(%esp)
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cb1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb9:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  800cc0:	e8 c3 f4 ff ff       	call   800188 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccc:	89 04 24             	mov    %eax,(%esp)
  800ccf:	e8 53 f4 ff ff       	call   800127 <vcprintf>
	cprintf("\n");
  800cd4:	c7 04 24 40 0f 80 00 	movl   $0x800f40,(%esp)
  800cdb:	e8 a8 f4 ff ff       	call   800188 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ce0:	cc                   	int3   
  800ce1:	eb fd                	jmp    800ce0 <_panic+0x6c>
	...

00800ce4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ce4:	55                   	push   %ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	83 ec 10             	sub    $0x10,%esp
  800cea:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800cfa:	89 cd                	mov    %ecx,%ebp
  800cfc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	75 2c                	jne    800d30 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d04:	39 f9                	cmp    %edi,%ecx
  800d06:	77 68                	ja     800d70 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d08:	85 c9                	test   %ecx,%ecx
  800d0a:	75 0b                	jne    800d17 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d11:	31 d2                	xor    %edx,%edx
  800d13:	f7 f1                	div    %ecx
  800d15:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d17:	31 d2                	xor    %edx,%edx
  800d19:	89 f8                	mov    %edi,%eax
  800d1b:	f7 f1                	div    %ecx
  800d1d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d1f:	89 f0                	mov    %esi,%eax
  800d21:	f7 f1                	div    %ecx
  800d23:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d25:	89 f0                	mov    %esi,%eax
  800d27:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d30:	39 f8                	cmp    %edi,%eax
  800d32:	77 2c                	ja     800d60 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d34:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d37:	83 f6 1f             	xor    $0x1f,%esi
  800d3a:	75 4c                	jne    800d88 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d3c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d3e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d43:	72 0a                	jb     800d4f <__udivdi3+0x6b>
  800d45:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d49:	0f 87 ad 00 00 00    	ja     800dfc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d4f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d54:	89 f0                	mov    %esi,%eax
  800d56:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    
  800d5f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d60:	31 ff                	xor    %edi,%edi
  800d62:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d70:	89 fa                	mov    %edi,%edx
  800d72:	89 f0                	mov    %esi,%eax
  800d74:	f7 f1                	div    %ecx
  800d76:	89 c6                	mov    %eax,%esi
  800d78:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d7a:	89 f0                	mov    %esi,%eax
  800d7c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d88:	89 f1                	mov    %esi,%ecx
  800d8a:	d3 e0                	shl    %cl,%eax
  800d8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d90:	b8 20 00 00 00       	mov    $0x20,%eax
  800d95:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d97:	89 ea                	mov    %ebp,%edx
  800d99:	88 c1                	mov    %al,%cl
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800da1:	09 ca                	or     %ecx,%edx
  800da3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800da7:	89 f1                	mov    %esi,%ecx
  800da9:	d3 e5                	shl    %cl,%ebp
  800dab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800daf:	89 fd                	mov    %edi,%ebp
  800db1:	88 c1                	mov    %al,%cl
  800db3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800db5:	89 fa                	mov    %edi,%edx
  800db7:	89 f1                	mov    %esi,%ecx
  800db9:	d3 e2                	shl    %cl,%edx
  800dbb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dbf:	88 c1                	mov    %al,%cl
  800dc1:	d3 ef                	shr    %cl,%edi
  800dc3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dc5:	89 f8                	mov    %edi,%eax
  800dc7:	89 ea                	mov    %ebp,%edx
  800dc9:	f7 74 24 08          	divl   0x8(%esp)
  800dcd:	89 d1                	mov    %edx,%ecx
  800dcf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800dd1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd5:	39 d1                	cmp    %edx,%ecx
  800dd7:	72 17                	jb     800df0 <__udivdi3+0x10c>
  800dd9:	74 09                	je     800de4 <__udivdi3+0x100>
  800ddb:	89 fe                	mov    %edi,%esi
  800ddd:	31 ff                	xor    %edi,%edi
  800ddf:	e9 41 ff ff ff       	jmp    800d25 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800de4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800de8:	89 f1                	mov    %esi,%ecx
  800dea:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dec:	39 c2                	cmp    %eax,%edx
  800dee:	73 eb                	jae    800ddb <__udivdi3+0xf7>
		{
		  q0--;
  800df0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	e9 2b ff ff ff       	jmp    800d25 <__udivdi3+0x41>
  800dfa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dfc:	31 f6                	xor    %esi,%esi
  800dfe:	e9 22 ff ff ff       	jmp    800d25 <__udivdi3+0x41>
	...

00800e04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	83 ec 20             	sub    $0x20,%esp
  800e0a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e0e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e12:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e16:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e1a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e1e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e22:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e24:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e26:	85 ed                	test   %ebp,%ebp
  800e28:	75 16                	jne    800e40 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e2a:	39 f1                	cmp    %esi,%ecx
  800e2c:	0f 86 a6 00 00 00    	jbe    800ed8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e32:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e34:	89 d0                	mov    %edx,%eax
  800e36:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e38:	83 c4 20             	add    $0x20,%esp
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    
  800e3f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e40:	39 f5                	cmp    %esi,%ebp
  800e42:	0f 87 ac 00 00 00    	ja     800ef4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e48:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e4b:	83 f0 1f             	xor    $0x1f,%eax
  800e4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e52:	0f 84 a8 00 00 00    	je     800f00 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e58:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e5c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e5e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e63:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e67:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e6b:	89 f9                	mov    %edi,%ecx
  800e6d:	d3 e8                	shr    %cl,%eax
  800e6f:	09 e8                	or     %ebp,%eax
  800e71:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e75:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e79:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e7d:	d3 e0                	shl    %cl,%eax
  800e7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e83:	89 f2                	mov    %esi,%edx
  800e85:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e87:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e8b:	d3 e0                	shl    %cl,%eax
  800e8d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e91:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	d3 e8                	shr    %cl,%eax
  800e99:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e9b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e9d:	89 f2                	mov    %esi,%edx
  800e9f:	f7 74 24 18          	divl   0x18(%esp)
  800ea3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ea5:	f7 64 24 0c          	mull   0xc(%esp)
  800ea9:	89 c5                	mov    %eax,%ebp
  800eab:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ead:	39 d6                	cmp    %edx,%esi
  800eaf:	72 67                	jb     800f18 <__umoddi3+0x114>
  800eb1:	74 75                	je     800f28 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800eb3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800eb7:	29 e8                	sub    %ebp,%eax
  800eb9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ebb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ebf:	d3 e8                	shr    %cl,%eax
  800ec1:	89 f2                	mov    %esi,%edx
  800ec3:	89 f9                	mov    %edi,%ecx
  800ec5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ec7:	09 d0                	or     %edx,%eax
  800ec9:	89 f2                	mov    %esi,%edx
  800ecb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ecf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed1:	83 c4 20             	add    $0x20,%esp
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ed8:	85 c9                	test   %ecx,%ecx
  800eda:	75 0b                	jne    800ee7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800edc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee1:	31 d2                	xor    %edx,%edx
  800ee3:	f7 f1                	div    %ecx
  800ee5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ee7:	89 f0                	mov    %esi,%eax
  800ee9:	31 d2                	xor    %edx,%edx
  800eeb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eed:	89 f8                	mov    %edi,%eax
  800eef:	e9 3e ff ff ff       	jmp    800e32 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ef4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef6:	83 c4 20             	add    $0x20,%esp
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
  800efd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f00:	39 f5                	cmp    %esi,%ebp
  800f02:	72 04                	jb     800f08 <__umoddi3+0x104>
  800f04:	39 f9                	cmp    %edi,%ecx
  800f06:	77 06                	ja     800f0e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f08:	89 f2                	mov    %esi,%edx
  800f0a:	29 cf                	sub    %ecx,%edi
  800f0c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f0e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    
  800f17:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f18:	89 d1                	mov    %edx,%ecx
  800f1a:	89 c5                	mov    %eax,%ebp
  800f1c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f20:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f24:	eb 8d                	jmp    800eb3 <__umoddi3+0xaf>
  800f26:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f28:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f2c:	72 ea                	jb     800f18 <__umoddi3+0x114>
  800f2e:	89 f1                	mov    %esi,%ecx
  800f30:	eb 81                	jmp    800eb3 <__umoddi3+0xaf>
