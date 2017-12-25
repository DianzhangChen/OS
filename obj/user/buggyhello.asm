
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 b6 0a 00 00       	call   800b04 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 66 0b 00 00       	call   800bc9 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80006b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80006e:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80007a:	c7 04 24 20 0f 80 00 	movl   $0x800f20,(%esp)
  800081:	e8 ee 00 00 00       	call   800174 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  800086:	a1 04 20 80 00       	mov    0x802004,%eax
  80008b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008f:	c7 04 24 30 0f 80 00 	movl   $0x800f30,(%esp)
  800096:	e8 d9 00 00 00       	call   800174 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 f6                	test   %esi,%esi
  80009d:	7e 07                	jle    8000a6 <libmain+0x56>
		binaryname = argv[0];
  80009f:	8b 03                	mov    (%ebx),%eax
  8000a1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000aa:	89 34 24             	mov    %esi,(%esp)
  8000ad:	e8 82 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 09 00 00 00       	call   8000c0 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    
	...

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cd:	e8 93 0a 00 00       	call   800b65 <sys_env_destroy>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e7:	40                   	inc    %eax
  8000e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	75 19                	jne    80010a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000f1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f8:	00 
  8000f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fc:	89 04 24             	mov    %eax,(%esp)
  8000ff:	e8 00 0a 00 00       	call   800b04 <sys_cputs>
		b->idx = 0;
  800104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010a:	ff 43 04             	incl   0x4(%ebx)
}
  80010d:	83 c4 14             	add    $0x14,%esp
  800110:	5b                   	pop    %ebx
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800137:	8b 45 08             	mov    0x8(%ebp),%eax
  80013a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800144:	89 44 24 04          	mov    %eax,0x4(%esp)
  800148:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  80014f:	e8 8d 01 00 00       	call   8002e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800154:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 98 09 00 00       	call   800b04 <sys_cputs>

	return b.cnt;
}
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 87 ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b8:	72 0f                	jb     8001c9 <printnum+0x39>
  8001ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c0:	76 07                	jbe    8001c9 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c2:	4b                   	dec    %ebx
  8001c3:	85 db                	test   %ebx,%ebx
  8001c5:	7f 4f                	jg     800216 <printnum+0x86>
  8001c7:	eb 5a                	jmp    800223 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c9:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001cd:	4b                   	dec    %ebx
  8001ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001dd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e8:	00 
  8001e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	e8 d5 0a 00 00       	call   800cd0 <__udivdi3>
  8001fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020a:	89 fa                	mov    %edi,%edx
  80020c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020f:	e8 7c ff ff ff       	call   800190 <printnum>
  800214:	eb 0d                	jmp    800223 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800216:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021a:	89 34 24             	mov    %esi,(%esp)
  80021d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	4b                   	dec    %ebx
  800221:	75 f3                	jne    800216 <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800223:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800227:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022b:	8b 45 10             	mov    0x10(%ebp),%eax
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800239:	00 
  80023a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023d:	89 04 24             	mov    %eax,(%esp)
  800240:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	e8 a4 0b 00 00       	call   800df0 <__umoddi3>
  80024c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800250:	0f be 80 4d 0f 80 00 	movsbl 0x800f4d(%eax),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80025d:	83 c4 3c             	add    $0x3c,%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800268:	83 fa 01             	cmp    $0x1,%edx
  80026b:	7e 0e                	jle    80027b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 02                	mov    (%edx),%eax
  800276:	8b 52 04             	mov    0x4(%edx),%edx
  800279:	eb 22                	jmp    80029d <getuint+0x38>
	else if (lflag)
  80027b:	85 d2                	test   %edx,%edx
  80027d:	74 10                	je     80028f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 04             	lea    0x4(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	ba 00 00 00 00       	mov    $0x0,%edx
  80028d:	eb 0e                	jmp    80029d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ad:	73 08                	jae    8002b7 <sprintputch+0x18>
		*b->buf++ = ch;
  8002af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b2:	88 0a                	mov    %cl,(%edx)
  8002b4:	42                   	inc    %edx
  8002b5:	89 10                	mov    %edx,(%eax)
}
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	e8 02 00 00 00       	call   8002e1 <vprintfmt>
	va_end(ap);
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
  8002e7:	83 ec 4c             	sub    $0x4c,%esp
  8002ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f0:	eb 17                	jmp    800309 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f2:	85 c0                	test   %eax,%eax
  8002f4:	0f 84 93 03 00 00    	je     80068d <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	ff 55 08             	call   *0x8(%ebp)
  800304:	eb 03                	jmp    800309 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 06             	movzbl (%esi),%eax
  80030c:	46                   	inc    %esi
  80030d:	83 f8 25             	cmp    $0x25,%eax
  800310:	75 e0                	jne    8002f2 <vprintfmt+0x11>
  800312:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800316:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80031d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800322:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	eb 26                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800333:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800337:	eb 1d                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800340:	eb 14                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800345:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034c:	eb 08                	jmp    800356 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800351:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	0f b6 16             	movzbl (%esi),%edx
  800359:	8d 46 01             	lea    0x1(%esi),%eax
  80035c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035f:	8a 06                	mov    (%esi),%al
  800361:	83 e8 23             	sub    $0x23,%eax
  800364:	3c 55                	cmp    $0x55,%al
  800366:	0f 87 fd 02 00 00    	ja     800669 <vprintfmt+0x388>
  80036c:	0f b6 c0             	movzbl %al,%eax
  80036f:	ff 24 85 dc 0f 80 00 	jmp    *0x800fdc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  800379:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80037d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800380:	83 fa 09             	cmp    $0x9,%edx
  800383:	77 3f                	ja     8003c4 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800389:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80038c:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800390:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800393:	8d 50 d0             	lea    -0x30(%eax),%edx
  800396:	83 fa 09             	cmp    $0x9,%edx
  800399:	76 ed                	jbe    800388 <vprintfmt+0xa7>
  80039b:	eb 2a                	jmp    8003c7 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ab:	eb 1a                	jmp    8003c7 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b1:	78 8f                	js     800342 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b6:	eb 9e                	jmp    800356 <vprintfmt+0x75>
  8003b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003c2:	eb 92                	jmp    800356 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cb:	79 89                	jns    800356 <vprintfmt+0x75>
  8003cd:	e9 7c ff ff ff       	jmp    80034e <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d6:	e9 7b ff ff ff       	jmp    800356 <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 50 04             	lea    0x4(%eax),%edx
  8003e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f3:	e9 11 ff ff ff       	jmp    800309 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	79 02                	jns    800409 <vprintfmt+0x128>
  800407:	f7 d8                	neg    %eax
  800409:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 06             	cmp    $0x6,%eax
  80040e:	7f 0b                	jg     80041b <vprintfmt+0x13a>
  800410:	8b 04 85 34 11 80 00 	mov    0x801134(,%eax,4),%eax
  800417:	85 c0                	test   %eax,%eax
  800419:	75 23                	jne    80043e <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80041b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041f:	c7 44 24 08 65 0f 80 	movl   $0x800f65,0x8(%esp)
  800426:	00 
  800427:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042b:	8b 55 08             	mov    0x8(%ebp),%edx
  80042e:	89 14 24             	mov    %edx,(%esp)
  800431:	e8 83 fe ff ff       	call   8002b9 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800439:	e9 cb fe ff ff       	jmp    800309 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  80043e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800442:	c7 44 24 08 6e 0f 80 	movl   $0x800f6e,0x8(%esp)
  800449:	00 
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800451:	89 0c 24             	mov    %ecx,(%esp)
  800454:	e8 60 fe ff ff       	call   8002b9 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045c:	e9 a8 fe ff ff       	jmp    800309 <vprintfmt+0x28>
  800461:	89 f9                	mov    %edi,%ecx
  800463:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800474:	85 c0                	test   %eax,%eax
  800476:	75 07                	jne    80047f <vprintfmt+0x19e>
				p = "(null)";
  800478:	c7 45 d4 5e 0f 80 00 	movl   $0x800f5e,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80047f:	85 f6                	test   %esi,%esi
  800481:	7e 3b                	jle    8004be <vprintfmt+0x1dd>
  800483:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800487:	74 35                	je     8004be <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80048d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 a4 02 00 00       	call   80073c <strnlen>
  800498:	29 c6                	sub    %eax,%esi
  80049a:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  80049d:	85 f6                	test   %esi,%esi
  80049f:	7e 1d                	jle    8004be <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004a1:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004a5:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004af:	89 34 24             	mov    %esi,(%esp)
  8004b2:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	4f                   	dec    %edi
  8004b6:	75 f3                	jne    8004ab <vprintfmt+0x1ca>
  8004b8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004bb:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c1:	0f be 02             	movsbl (%edx),%eax
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 43                	jne    80050b <vprintfmt+0x22a>
  8004c8:	eb 33                	jmp    8004fd <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ce:	74 18                	je     8004e8 <vprintfmt+0x207>
  8004d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004d3:	83 fa 5e             	cmp    $0x5e,%edx
  8004d6:	76 10                	jbe    8004e8 <vprintfmt+0x207>
					putch('?', putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
  8004e6:	eb 0a                	jmp    8004f2 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f5:	0f be 06             	movsbl (%esi),%eax
  8004f8:	46                   	inc    %esi
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	75 12                	jne    80050f <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800501:	7f 15                	jg     800518 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800506:	e9 fe fd ff ff       	jmp    800309 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80050e:	46                   	inc    %esi
  80050f:	85 ff                	test   %edi,%edi
  800511:	78 b7                	js     8004ca <vprintfmt+0x1e9>
  800513:	4f                   	dec    %edi
  800514:	79 b4                	jns    8004ca <vprintfmt+0x1e9>
  800516:	eb e5                	jmp    8004fd <vprintfmt+0x21c>
  800518:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80051b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800522:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800529:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	4e                   	dec    %esi
  80052c:	75 f0                	jne    80051e <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800531:	e9 d3 fd ff ff       	jmp    800309 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800536:	83 f9 01             	cmp    $0x1,%ecx
  800539:	7e 10                	jle    80054b <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 08             	lea    0x8(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	8b 78 04             	mov    0x4(%eax),%edi
  800549:	eb 26                	jmp    800571 <vprintfmt+0x290>
	else if (lflag)
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	74 12                	je     800561 <vprintfmt+0x280>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 30                	mov    (%eax),%esi
  80055a:	89 f7                	mov    %esi,%edi
  80055c:	c1 ff 1f             	sar    $0x1f,%edi
  80055f:	eb 10                	jmp    800571 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 30                	mov    (%eax),%esi
  80056c:	89 f7                	mov    %esi,%edi
  80056e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800571:	85 ff                	test   %edi,%edi
  800573:	78 0e                	js     800583 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800575:	89 f0                	mov    %esi,%eax
  800577:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800579:	be 0a 00 00 00       	mov    $0xa,%esi
  80057e:	e9 a8 00 00 00       	jmp    80062b <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800583:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800587:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80058e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800591:	89 f0                	mov    %esi,%eax
  800593:	89 fa                	mov    %edi,%edx
  800595:	f7 d8                	neg    %eax
  800597:	83 d2 00             	adc    $0x0,%edx
  80059a:	f7 da                	neg    %edx
			}
			base = 10;
  80059c:	be 0a 00 00 00       	mov    $0xa,%esi
  8005a1:	e9 85 00 00 00       	jmp    80062b <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a6:	89 ca                	mov    %ecx,%edx
  8005a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ab:	e8 b5 fc ff ff       	call   800265 <getuint>
			base = 10;
  8005b0:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005b5:	eb 74                	jmp    80062b <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bb:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c9:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005d0:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005de:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005e4:	e9 20 fd ff ff       	jmp    800309 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ed:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800615:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80061a:	eb 0f                	jmp    80062b <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061c:	89 ca                	mov    %ecx,%edx
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 3f fc ff ff       	call   800265 <getuint>
			base = 16;
  800626:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062b:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80062f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800633:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800636:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80063a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	89 54 24 04          	mov    %edx,0x4(%esp)
  800645:	89 da                	mov    %ebx,%edx
  800647:	8b 45 08             	mov    0x8(%ebp),%eax
  80064a:	e8 41 fb ff ff       	call   800190 <printnum>
			break;
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800652:	e9 b2 fc ff ff       	jmp    800309 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800657:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065b:	89 14 24             	mov    %edx,(%esp)
  80065e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800664:	e9 a0 fc ff ff       	jmp    800309 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800669:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800674:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800677:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067b:	0f 84 88 fc ff ff    	je     800309 <vprintfmt+0x28>
  800681:	4e                   	dec    %esi
  800682:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800686:	75 f9                	jne    800681 <vprintfmt+0x3a0>
  800688:	e9 7c fc ff ff       	jmp    800309 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  80068d:	83 c4 4c             	add    $0x4c,%esp
  800690:	5b                   	pop    %ebx
  800691:	5e                   	pop    %esi
  800692:	5f                   	pop    %edi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 28             	sub    $0x28,%esp
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	74 30                	je     8006e6 <vsnprintf+0x51>
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	7e 33                	jle    8006ed <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cf:	c7 04 24 9f 02 80 00 	movl   $0x80029f,(%esp)
  8006d6:	e8 06 fc ff ff       	call   8002e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e4:	eb 0c                	jmp    8006f2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006eb:	eb 05                	jmp    8006f2 <vsnprintf+0x5d>
  8006ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800701:	8b 45 10             	mov    0x10(%ebp),%eax
  800704:	89 44 24 08          	mov    %eax,0x8(%esp)
  800708:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070f:	8b 45 08             	mov    0x8(%ebp),%eax
  800712:	89 04 24             	mov    %eax,(%esp)
  800715:	e8 7b ff ff ff       	call   800695 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3a 00             	cmpb   $0x0,(%edx)
  800725:	74 0e                	je     800735 <strlen+0x19>
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80072c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800731:	75 f9                	jne    80072c <strlen+0x10>
  800733:	eb 05                	jmp    80073a <strlen+0x1e>
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800746:	85 c9                	test   %ecx,%ecx
  800748:	74 1a                	je     800764 <strnlen+0x28>
  80074a:	80 3b 00             	cmpb   $0x0,(%ebx)
  80074d:	74 1c                	je     80076b <strnlen+0x2f>
  80074f:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800754:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	39 ca                	cmp    %ecx,%edx
  800758:	74 16                	je     800770 <strnlen+0x34>
  80075a:	42                   	inc    %edx
  80075b:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800760:	75 f2                	jne    800754 <strnlen+0x18>
  800762:	eb 0c                	jmp    800770 <strnlen+0x34>
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 05                	jmp    800770 <strnlen+0x34>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800770:	5b                   	pop    %ebx
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
  800782:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800785:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800788:	42                   	inc    %edx
  800789:	84 c9                	test   %cl,%cl
  80078b:	75 f5                	jne    800782 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80078d:	5b                   	pop    %ebx
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	89 1c 24             	mov    %ebx,(%esp)
  80079d:	e8 7a ff ff ff       	call   80071c <strlen>
	strcpy(dst + len, src);
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	89 04 24             	mov    %eax,(%esp)
  8007ae:	e8 c0 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	83 c4 08             	add    $0x8,%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	85 f6                	test   %esi,%esi
  8007cb:	74 15                	je     8007e2 <strncpy+0x27>
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007d2:	8a 1a                	mov    (%edx),%bl
  8007d4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d7:	80 3a 01             	cmpb   $0x1,(%edx)
  8007da:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	41                   	inc    %ecx
  8007de:	39 f1                	cmp    %esi,%ecx
  8007e0:	75 f0                	jne    8007d2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	57                   	push   %edi
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f2:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 f6                	test   %esi,%esi
  8007f7:	74 31                	je     80082a <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  8007f9:	83 fe 01             	cmp    $0x1,%esi
  8007fc:	74 21                	je     80081f <strlcpy+0x39>
  8007fe:	8a 0b                	mov    (%ebx),%cl
  800800:	84 c9                	test   %cl,%cl
  800802:	74 1f                	je     800823 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800804:	83 ee 02             	sub    $0x2,%esi
  800807:	89 f8                	mov    %edi,%eax
  800809:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080e:	88 08                	mov    %cl,(%eax)
  800810:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800811:	39 f2                	cmp    %esi,%edx
  800813:	74 10                	je     800825 <strlcpy+0x3f>
  800815:	42                   	inc    %edx
  800816:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800819:	84 c9                	test   %cl,%cl
  80081b:	75 f1                	jne    80080e <strlcpy+0x28>
  80081d:	eb 06                	jmp    800825 <strlcpy+0x3f>
  80081f:	89 f8                	mov    %edi,%eax
  800821:	eb 02                	jmp    800825 <strlcpy+0x3f>
  800823:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800825:	c6 00 00             	movb   $0x0,(%eax)
  800828:	eb 02                	jmp    80082c <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80082c:	29 f8                	sub    %edi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5f                   	pop    %edi
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083c:	8a 01                	mov    (%ecx),%al
  80083e:	84 c0                	test   %al,%al
  800840:	74 11                	je     800853 <strcmp+0x20>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	75 0d                	jne    800853 <strcmp+0x20>
		p++, q++;
  800846:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800847:	8a 41 01             	mov    0x1(%ecx),%al
  80084a:	84 c0                	test   %al,%al
  80084c:	74 05                	je     800853 <strcmp+0x20>
  80084e:	41                   	inc    %ecx
  80084f:	3a 02                	cmp    (%edx),%al
  800851:	74 f3                	je     800846 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 c0             	movzbl %al,%eax
  800856:	0f b6 12             	movzbl (%edx),%edx
  800859:	29 d0                	sub    %edx,%eax
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	8b 55 08             	mov    0x8(%ebp),%edx
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80086a:	85 c0                	test   %eax,%eax
  80086c:	74 1b                	je     800889 <strncmp+0x2c>
  80086e:	8a 1a                	mov    (%edx),%bl
  800870:	84 db                	test   %bl,%bl
  800872:	74 24                	je     800898 <strncmp+0x3b>
  800874:	3a 19                	cmp    (%ecx),%bl
  800876:	75 20                	jne    800898 <strncmp+0x3b>
  800878:	48                   	dec    %eax
  800879:	74 15                	je     800890 <strncmp+0x33>
		n--, p++, q++;
  80087b:	42                   	inc    %edx
  80087c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087d:	8a 1a                	mov    (%edx),%bl
  80087f:	84 db                	test   %bl,%bl
  800881:	74 15                	je     800898 <strncmp+0x3b>
  800883:	3a 19                	cmp    (%ecx),%bl
  800885:	74 f1                	je     800878 <strncmp+0x1b>
  800887:	eb 0f                	jmp    800898 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
  80088e:	eb 05                	jmp    800895 <strncmp+0x38>
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 02             	movzbl (%edx),%eax
  80089b:	0f b6 11             	movzbl (%ecx),%edx
  80089e:	29 d0                	sub    %edx,%eax
  8008a0:	eb f3                	jmp    800895 <strncmp+0x38>

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ab:	8a 10                	mov    (%eax),%dl
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	74 19                	je     8008ca <strchr+0x28>
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	75 07                	jne    8008bc <strchr+0x1a>
  8008b5:	eb 18                	jmp    8008cf <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b7:	40                   	inc    %eax
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 13                	je     8008cf <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	8a 50 01             	mov    0x1(%eax),%dl
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f4                	jne    8008b7 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 05                	jmp    8008cf <strchr+0x2d>
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008da:	8a 10                	mov    (%eax),%dl
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	74 11                	je     8008f1 <strfind+0x20>
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	75 06                	jne    8008ea <strfind+0x19>
  8008e4:	eb 0b                	jmp    8008f1 <strfind+0x20>
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 07                	je     8008f1 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ea:	40                   	inc    %eax
  8008eb:	8a 10                	mov    (%eax),%dl
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	75 f5                	jne    8008e6 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 30                	je     800936 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090c:	75 25                	jne    800933 <memset+0x40>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 20                	jne    800933 <memset+0x40>
		c &= 0xFF;
  800913:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800916:	89 d3                	mov    %edx,%ebx
  800918:	c1 e3 08             	shl    $0x8,%ebx
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	c1 e6 18             	shl    $0x18,%esi
  800920:	89 d0                	mov    %edx,%eax
  800922:	c1 e0 10             	shl    $0x10,%eax
  800925:	09 f0                	or     %esi,%eax
  800927:	09 d0                	or     %edx,%eax
  800929:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092b:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80092e:	fc                   	cld    
  80092f:	f3 ab                	rep stos %eax,%es:(%edi)
  800931:	eb 03                	jmp    800936 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 34                	jae    800983 <memmove+0x46>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2d                	jae    800983 <memmove+0x46>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	f6 c2 03             	test   $0x3,%dl
  80095c:	75 1b                	jne    800979 <memmove+0x3c>
  80095e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800964:	75 13                	jne    800979 <memmove+0x3c>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0e                	jne    800979 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096b:	83 ef 04             	sub    $0x4,%edi
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800971:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 07                	jmp    800980 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800979:	4f                   	dec    %edi
  80097a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80097d:	fd                   	std    
  80097e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800980:	fc                   	cld    
  800981:	eb 20                	jmp    8009a3 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800983:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800989:	75 13                	jne    80099e <memmove+0x61>
  80098b:	a8 03                	test   $0x3,%al
  80098d:	75 0f                	jne    80099e <memmove+0x61>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	75 0a                	jne    80099e <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800994:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800997:	89 c7                	mov    %eax,%edi
  800999:	fc                   	cld    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099c:	eb 05                	jmp    8009a3 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 77 ff ff ff       	call   80093d <memmove>
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	85 ff                	test   %edi,%edi
  8009d9:	74 31                	je     800a0c <memcmp+0x44>
		if (*s1 != *s2)
  8009db:	8a 03                	mov    (%ebx),%al
  8009dd:	8a 0e                	mov    (%esi),%cl
  8009df:	38 c8                	cmp    %cl,%al
  8009e1:	74 18                	je     8009fb <memcmp+0x33>
  8009e3:	eb 0c                	jmp    8009f1 <memcmp+0x29>
  8009e5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009e9:	42                   	inc    %edx
  8009ea:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  8009ed:	38 c8                	cmp    %cl,%al
  8009ef:	74 10                	je     800a01 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  8009f1:	0f b6 c0             	movzbl %al,%eax
  8009f4:	0f b6 c9             	movzbl %cl,%ecx
  8009f7:	29 c8                	sub    %ecx,%eax
  8009f9:	eb 16                	jmp    800a11 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fb:	4f                   	dec    %edi
  8009fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800a01:	39 fa                	cmp    %edi,%edx
  800a03:	75 e0                	jne    8009e5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	eb 05                	jmp    800a11 <memcmp+0x49>
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a1c:	89 c2                	mov    %eax,%edx
  800a1e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a21:	39 d0                	cmp    %edx,%eax
  800a23:	73 12                	jae    800a37 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a28:	38 08                	cmp    %cl,(%eax)
  800a2a:	75 06                	jne    800a32 <memfind+0x1c>
  800a2c:	eb 09                	jmp    800a37 <memfind+0x21>
  800a2e:	38 08                	cmp    %cl,(%eax)
  800a30:	74 05                	je     800a37 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	40                   	inc    %eax
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	75 f7                	jne    800a2e <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	eb 01                	jmp    800a48 <strtol+0xf>
		s++;
  800a47:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a48:	8a 02                	mov    (%edx),%al
  800a4a:	3c 20                	cmp    $0x20,%al
  800a4c:	74 f9                	je     800a47 <strtol+0xe>
  800a4e:	3c 09                	cmp    $0x9,%al
  800a50:	74 f5                	je     800a47 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a52:	3c 2b                	cmp    $0x2b,%al
  800a54:	75 08                	jne    800a5e <strtol+0x25>
		s++;
  800a56:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a57:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5c:	eb 13                	jmp    800a71 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5e:	3c 2d                	cmp    $0x2d,%al
  800a60:	75 0a                	jne    800a6c <strtol+0x33>
		s++, neg = 1;
  800a62:	8d 52 01             	lea    0x1(%edx),%edx
  800a65:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6a:	eb 05                	jmp    800a71 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	74 05                	je     800a7a <strtol+0x41>
  800a75:	83 fb 10             	cmp    $0x10,%ebx
  800a78:	75 28                	jne    800aa2 <strtol+0x69>
  800a7a:	8a 02                	mov    (%edx),%al
  800a7c:	3c 30                	cmp    $0x30,%al
  800a7e:	75 10                	jne    800a90 <strtol+0x57>
  800a80:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a84:	75 0a                	jne    800a90 <strtol+0x57>
		s += 2, base = 16;
  800a86:	83 c2 02             	add    $0x2,%edx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb 12                	jmp    800aa2 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	75 0e                	jne    800aa2 <strtol+0x69>
  800a94:	3c 30                	cmp    $0x30,%al
  800a96:	75 05                	jne    800a9d <strtol+0x64>
		s++, base = 8;
  800a98:	42                   	inc    %edx
  800a99:	b3 08                	mov    $0x8,%bl
  800a9b:	eb 05                	jmp    800aa2 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa9:	8a 0a                	mov    (%edx),%cl
  800aab:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aae:	80 fb 09             	cmp    $0x9,%bl
  800ab1:	77 08                	ja     800abb <strtol+0x82>
			dig = *s - '0';
  800ab3:	0f be c9             	movsbl %cl,%ecx
  800ab6:	83 e9 30             	sub    $0x30,%ecx
  800ab9:	eb 1e                	jmp    800ad9 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800abb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800abe:	80 fb 19             	cmp    $0x19,%bl
  800ac1:	77 08                	ja     800acb <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac3:	0f be c9             	movsbl %cl,%ecx
  800ac6:	83 e9 57             	sub    $0x57,%ecx
  800ac9:	eb 0e                	jmp    800ad9 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800acb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ace:	80 fb 19             	cmp    $0x19,%bl
  800ad1:	77 12                	ja     800ae5 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ad3:	0f be c9             	movsbl %cl,%ecx
  800ad6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad9:	39 f1                	cmp    %esi,%ecx
  800adb:	7d 0c                	jge    800ae9 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800add:	42                   	inc    %edx
  800ade:	0f af c6             	imul   %esi,%eax
  800ae1:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ae3:	eb c4                	jmp    800aa9 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae5:	89 c1                	mov    %eax,%ecx
  800ae7:	eb 02                	jmp    800aeb <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aeb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aef:	74 05                	je     800af6 <strtol+0xbd>
		*endptr = (char *) s;
  800af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af6:	85 ff                	test   %edi,%edi
  800af8:	74 04                	je     800afe <strtol+0xc5>
  800afa:	89 c8                	mov    %ecx,%eax
  800afc:	f7 d8                	neg    %eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    
	...

00800b04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	51                   	push   %ecx
  800b19:	52                   	push   %edx
  800b1a:	53                   	push   %ebx
  800b1b:	54                   	push   %esp
  800b1c:	55                   	push   %ebp
  800b1d:	56                   	push   %esi
  800b1e:	57                   	push   %edi
  800b1f:	8d 35 29 0b 80 00    	lea    0x800b29,%esi
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	0f 34                	sysenter 

00800b29 <after_sysenter_label16>:
  800b29:	5f                   	pop    %edi
  800b2a:	5e                   	pop    %esi
  800b2b:	5d                   	pop    %ebp
  800b2c:	5c                   	pop    %esp
  800b2d:	5b                   	pop    %ebx
  800b2e:	5a                   	pop    %edx
  800b2f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	89 d1                	mov    %edx,%ecx
  800b45:	89 d3                	mov    %edx,%ebx
  800b47:	89 d7                	mov    %edx,%edi
  800b49:	51                   	push   %ecx
  800b4a:	52                   	push   %edx
  800b4b:	53                   	push   %ebx
  800b4c:	54                   	push   %esp
  800b4d:	55                   	push   %ebp
  800b4e:	56                   	push   %esi
  800b4f:	57                   	push   %edi
  800b50:	8d 35 5a 0b 80 00    	lea    0x800b5a,%esi
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	0f 34                	sysenter 

00800b5a <after_sysenter_label41>:
  800b5a:	5f                   	pop    %edi
  800b5b:	5e                   	pop    %esi
  800b5c:	5d                   	pop    %ebp
  800b5d:	5c                   	pop    %esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5a                   	pop    %edx
  800b60:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b72:	b8 03 00 00 00       	mov    $0x3,%eax
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	89 cb                	mov    %ecx,%ebx
  800b7c:	89 cf                	mov    %ecx,%edi
  800b7e:	51                   	push   %ecx
  800b7f:	52                   	push   %edx
  800b80:	53                   	push   %ebx
  800b81:	54                   	push   %esp
  800b82:	55                   	push   %ebp
  800b83:	56                   	push   %esi
  800b84:	57                   	push   %edi
  800b85:	8d 35 8f 0b 80 00    	lea    0x800b8f,%esi
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	0f 34                	sysenter 

00800b8f <after_sysenter_label68>:
  800b8f:	5f                   	pop    %edi
  800b90:	5e                   	pop    %esi
  800b91:	5d                   	pop    %ebp
  800b92:	5c                   	pop    %esp
  800b93:	5b                   	pop    %ebx
  800b94:	5a                   	pop    %edx
  800b95:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 28                	jle    800bc2 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba5:	00 
  800ba6:	c7 44 24 08 50 11 80 	movl   $0x801150,0x8(%esp)
  800bad:	00 
  800bae:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800bb5:	00 
  800bb6:	c7 04 24 6d 11 80 00 	movl   $0x80116d,(%esp)
  800bbd:	e8 9e 00 00 00       	call   800c60 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc2:	83 c4 20             	add    $0x20,%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd8:	89 d1                	mov    %edx,%ecx
  800bda:	89 d3                	mov    %edx,%ebx
  800bdc:	89 d7                	mov    %edx,%edi
  800bde:	51                   	push   %ecx
  800bdf:	52                   	push   %edx
  800be0:	53                   	push   %ebx
  800be1:	54                   	push   %esp
  800be2:	55                   	push   %ebp
  800be3:	56                   	push   %esi
  800be4:	57                   	push   %edi
  800be5:	8d 35 ef 0b 80 00    	lea    0x800bef,%esi
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	0f 34                	sysenter 

00800bef <after_sysenter_label107>:
  800bef:	5f                   	pop    %edi
  800bf0:	5e                   	pop    %esi
  800bf1:	5d                   	pop    %ebp
  800bf2:	5c                   	pop    %esp
  800bf3:	5b                   	pop    %ebx
  800bf4:	5a                   	pop    %edx
  800bf5:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 df                	mov    %ebx,%edi
  800c11:	51                   	push   %ecx
  800c12:	52                   	push   %edx
  800c13:	53                   	push   %ebx
  800c14:	54                   	push   %esp
  800c15:	55                   	push   %ebp
  800c16:	56                   	push   %esi
  800c17:	57                   	push   %edi
  800c18:	8d 35 22 0c 80 00    	lea    0x800c22,%esi
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	0f 34                	sysenter 

00800c22 <after_sysenter_label133>:
  800c22:	5f                   	pop    %edi
  800c23:	5e                   	pop    %esi
  800c24:	5d                   	pop    %ebp
  800c25:	5c                   	pop    %esp
  800c26:	5b                   	pop    %ebx
  800c27:	5a                   	pop    %edx
  800c28:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c37:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 cb                	mov    %ecx,%ebx
  800c41:	89 cf                	mov    %ecx,%edi
  800c43:	51                   	push   %ecx
  800c44:	52                   	push   %edx
  800c45:	53                   	push   %ebx
  800c46:	54                   	push   %esp
  800c47:	55                   	push   %ebp
  800c48:	56                   	push   %esi
  800c49:	57                   	push   %edi
  800c4a:	8d 35 54 0c 80 00    	lea    0x800c54,%esi
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	0f 34                	sysenter 

00800c54 <after_sysenter_label159>:
  800c54:	5f                   	pop    %edi
  800c55:	5e                   	pop    %esi
  800c56:	5d                   	pop    %ebp
  800c57:	5c                   	pop    %esp
  800c58:	5b                   	pop    %ebx
  800c59:	5a                   	pop    %edx
  800c5a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
	...

00800c60 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c68:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c6b:	a1 08 20 80 00       	mov    0x802008,%eax
  800c70:	85 c0                	test   %eax,%eax
  800c72:	74 10                	je     800c84 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c78:	c7 04 24 7b 11 80 00 	movl   $0x80117b,(%esp)
  800c7f:	e8 f0 f4 ff ff       	call   800174 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c84:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c8a:	e8 3a ff ff ff       	call   800bc9 <sys_getenvid>
  800c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c92:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c9d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca5:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  800cac:	e8 c3 f4 ff ff       	call   800174 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb8:	89 04 24             	mov    %eax,(%esp)
  800cbb:	e8 53 f4 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  800cc0:	c7 04 24 2e 0f 80 00 	movl   $0x800f2e,(%esp)
  800cc7:	e8 a8 f4 ff ff       	call   800174 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ccc:	cc                   	int3   
  800ccd:	eb fd                	jmp    800ccc <_panic+0x6c>
	...

00800cd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	83 ec 10             	sub    $0x10,%esp
  800cd6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cda:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cde:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800ce6:	89 cd                	mov    %ecx,%ebp
  800ce8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	75 2c                	jne    800d1c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cf0:	39 f9                	cmp    %edi,%ecx
  800cf2:	77 68                	ja     800d5c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf4:	85 c9                	test   %ecx,%ecx
  800cf6:	75 0b                	jne    800d03 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cf8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfd:	31 d2                	xor    %edx,%edx
  800cff:	f7 f1                	div    %ecx
  800d01:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d03:	31 d2                	xor    %edx,%edx
  800d05:	89 f8                	mov    %edi,%eax
  800d07:	f7 f1                	div    %ecx
  800d09:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	f7 f1                	div    %ecx
  800d0f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d1c:	39 f8                	cmp    %edi,%eax
  800d1e:	77 2c                	ja     800d4c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d20:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d23:	83 f6 1f             	xor    $0x1f,%esi
  800d26:	75 4c                	jne    800d74 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d28:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d2a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d2f:	72 0a                	jb     800d3b <__udivdi3+0x6b>
  800d31:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d35:	0f 87 ad 00 00 00    	ja     800de8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d3b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d40:	89 f0                	mov    %esi,%eax
  800d42:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
  800d4b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d4c:	31 ff                	xor    %edi,%edi
  800d4e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d50:	89 f0                	mov    %esi,%eax
  800d52:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
  800d5b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d5c:	89 fa                	mov    %edi,%edx
  800d5e:	89 f0                	mov    %esi,%eax
  800d60:	f7 f1                	div    %ecx
  800d62:	89 c6                	mov    %eax,%esi
  800d64:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d66:	89 f0                	mov    %esi,%eax
  800d68:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    
  800d71:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d74:	89 f1                	mov    %esi,%ecx
  800d76:	d3 e0                	shl    %cl,%eax
  800d78:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d81:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d83:	89 ea                	mov    %ebp,%edx
  800d85:	88 c1                	mov    %al,%cl
  800d87:	d3 ea                	shr    %cl,%edx
  800d89:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800d8d:	09 ca                	or     %ecx,%edx
  800d8f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800d93:	89 f1                	mov    %esi,%ecx
  800d95:	d3 e5                	shl    %cl,%ebp
  800d97:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800d9b:	89 fd                	mov    %edi,%ebp
  800d9d:	88 c1                	mov    %al,%cl
  800d9f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800da1:	89 fa                	mov    %edi,%edx
  800da3:	89 f1                	mov    %esi,%ecx
  800da5:	d3 e2                	shl    %cl,%edx
  800da7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dab:	88 c1                	mov    %al,%cl
  800dad:	d3 ef                	shr    %cl,%edi
  800daf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800db1:	89 f8                	mov    %edi,%eax
  800db3:	89 ea                	mov    %ebp,%edx
  800db5:	f7 74 24 08          	divl   0x8(%esp)
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800dbd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc1:	39 d1                	cmp    %edx,%ecx
  800dc3:	72 17                	jb     800ddc <__udivdi3+0x10c>
  800dc5:	74 09                	je     800dd0 <__udivdi3+0x100>
  800dc7:	89 fe                	mov    %edi,%esi
  800dc9:	31 ff                	xor    %edi,%edi
  800dcb:	e9 41 ff ff ff       	jmp    800d11 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dd0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dd4:	89 f1                	mov    %esi,%ecx
  800dd6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd8:	39 c2                	cmp    %eax,%edx
  800dda:	73 eb                	jae    800dc7 <__udivdi3+0xf7>
		{
		  q0--;
  800ddc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ddf:	31 ff                	xor    %edi,%edi
  800de1:	e9 2b ff ff ff       	jmp    800d11 <__udivdi3+0x41>
  800de6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800de8:	31 f6                	xor    %esi,%esi
  800dea:	e9 22 ff ff ff       	jmp    800d11 <__udivdi3+0x41>
	...

00800df0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	83 ec 20             	sub    $0x20,%esp
  800df6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800dfa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dfe:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e02:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e06:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e0a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e0e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e10:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e12:	85 ed                	test   %ebp,%ebp
  800e14:	75 16                	jne    800e2c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e16:	39 f1                	cmp    %esi,%ecx
  800e18:	0f 86 a6 00 00 00    	jbe    800ec4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e1e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e20:	89 d0                	mov    %edx,%eax
  800e22:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e24:	83 c4 20             	add    $0x20,%esp
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    
  800e2b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e2c:	39 f5                	cmp    %esi,%ebp
  800e2e:	0f 87 ac 00 00 00    	ja     800ee0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e34:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e37:	83 f0 1f             	xor    $0x1f,%eax
  800e3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3e:	0f 84 a8 00 00 00    	je     800eec <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e44:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e48:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e4a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e4f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e53:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e57:	89 f9                	mov    %edi,%ecx
  800e59:	d3 e8                	shr    %cl,%eax
  800e5b:	09 e8                	or     %ebp,%eax
  800e5d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e65:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e69:	d3 e0                	shl    %cl,%eax
  800e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e6f:	89 f2                	mov    %esi,%edx
  800e71:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e73:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e77:	d3 e0                	shl    %cl,%eax
  800e79:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e7d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e81:	89 f9                	mov    %edi,%ecx
  800e83:	d3 e8                	shr    %cl,%eax
  800e85:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e87:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e89:	89 f2                	mov    %esi,%edx
  800e8b:	f7 74 24 18          	divl   0x18(%esp)
  800e8f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e91:	f7 64 24 0c          	mull   0xc(%esp)
  800e95:	89 c5                	mov    %eax,%ebp
  800e97:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e99:	39 d6                	cmp    %edx,%esi
  800e9b:	72 67                	jb     800f04 <__umoddi3+0x114>
  800e9d:	74 75                	je     800f14 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e9f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ea3:	29 e8                	sub    %ebp,%eax
  800ea5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ea7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	89 f9                	mov    %edi,%ecx
  800eb1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800eb3:	09 d0                	or     %edx,%eax
  800eb5:	89 f2                	mov    %esi,%edx
  800eb7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ebb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ebd:	83 c4 20             	add    $0x20,%esp
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ec4:	85 c9                	test   %ecx,%ecx
  800ec6:	75 0b                	jne    800ed3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	f7 f1                	div    %ecx
  800ed1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	31 d2                	xor    %edx,%edx
  800ed7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ed9:	89 f8                	mov    %edi,%eax
  800edb:	e9 3e ff ff ff       	jmp    800e1e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ee0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee2:	83 c4 20             	add    $0x20,%esp
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eec:	39 f5                	cmp    %esi,%ebp
  800eee:	72 04                	jb     800ef4 <__umoddi3+0x104>
  800ef0:	39 f9                	cmp    %edi,%ecx
  800ef2:	77 06                	ja     800efa <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef4:	89 f2                	mov    %esi,%edx
  800ef6:	29 cf                	sub    %ecx,%edi
  800ef8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800efa:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f04:	89 d1                	mov    %edx,%ecx
  800f06:	89 c5                	mov    %eax,%ebp
  800f08:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f0c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f10:	eb 8d                	jmp    800e9f <__umoddi3+0xaf>
  800f12:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f14:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f18:	72 ea                	jb     800f04 <__umoddi3+0x114>
  800f1a:	89 f1                	mov    %esi,%ecx
  800f1c:	eb 81                	jmp    800e9f <__umoddi3+0xaf>
