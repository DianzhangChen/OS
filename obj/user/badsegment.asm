
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 66 0b 00 00       	call   800bb9 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80005b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80005e:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800065:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80006a:	c7 04 24 10 0f 80 00 	movl   $0x800f10,(%esp)
  800071:	e8 ee 00 00 00       	call   800164 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  800076:	a1 04 20 80 00       	mov    0x802004,%eax
  80007b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007f:	c7 04 24 20 0f 80 00 	movl   $0x800f20,(%esp)
  800086:	e8 d9 00 00 00       	call   800164 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 f6                	test   %esi,%esi
  80008d:	7e 07                	jle    800096 <libmain+0x56>
		binaryname = argv[0];
  80008f:	8b 03                	mov    (%ebx),%eax
  800091:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800096:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009a:	89 34 24             	mov    %esi,(%esp)
  80009d:	e8 92 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a2:	e8 09 00 00 00       	call   8000b0 <exit>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 93 0a 00 00       	call   800b55 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	40                   	inc    %eax
  8000d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 19                	jne    8000fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e8:	00 
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	89 04 24             	mov    %eax,(%esp)
  8000ef:	e8 00 0a 00 00       	call   800af4 <sys_cputs>
		b->idx = 0;
  8000f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fa:	ff 43 04             	incl   0x4(%ebx)
}
  8000fd:	83 c4 14             	add    $0x14,%esp
  800100:	5b                   	pop    %ebx
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	8b 45 08             	mov    0x8(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  80013f:	e8 8d 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 98 09 00 00       	call   800af4 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	8b 45 08             	mov    0x8(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 87 ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a8:	72 0f                	jb     8001b9 <printnum+0x39>
  8001aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b0:	76 07                	jbe    8001b9 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b2:	4b                   	dec    %ebx
  8001b3:	85 db                	test   %ebx,%ebx
  8001b5:	7f 4f                	jg     800206 <printnum+0x86>
  8001b7:	eb 5a                	jmp    800213 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bd:	4b                   	dec    %ebx
  8001be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001cd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d8:	00 
  8001d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001dc:	89 04 24             	mov    %eax,(%esp)
  8001df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	e8 d5 0a 00 00       	call   800cc0 <__udivdi3>
  8001eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fa:	89 fa                	mov    %edi,%edx
  8001fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ff:	e8 7c ff ff ff       	call   800180 <printnum>
  800204:	eb 0d                	jmp    800213 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800206:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020a:	89 34 24             	mov    %esi,(%esp)
  80020d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800210:	4b                   	dec    %ebx
  800211:	75 f3                	jne    800206 <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800213:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800217:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021b:	8b 45 10             	mov    0x10(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800229:	00 
  80022a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022d:	89 04 24             	mov    %eax,(%esp)
  800230:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800233:	89 44 24 04          	mov    %eax,0x4(%esp)
  800237:	e8 a4 0b 00 00       	call   800de0 <__umoddi3>
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	0f be 80 3d 0f 80 00 	movsbl 0x800f3d(%eax),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024d:	83 c4 3c             	add    $0x3c,%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800258:	83 fa 01             	cmp    $0x1,%edx
  80025b:	7e 0e                	jle    80026b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 02                	mov    (%edx),%eax
  800266:	8b 52 04             	mov    0x4(%edx),%edx
  800269:	eb 22                	jmp    80028d <getuint+0x38>
	else if (lflag)
  80026b:	85 d2                	test   %edx,%edx
  80026d:	74 10                	je     80027f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	8d 4a 04             	lea    0x4(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 02                	mov    (%edx),%eax
  800278:	ba 00 00 00 00       	mov    $0x0,%edx
  80027d:	eb 0e                	jmp    80028d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 04             	lea    0x4(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800295:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	3b 50 04             	cmp    0x4(%eax),%edx
  80029d:	73 08                	jae    8002a7 <sprintputch+0x18>
		*b->buf++ = ch;
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	88 0a                	mov    %cl,(%edx)
  8002a4:	42                   	inc    %edx
  8002a5:	89 10                	mov    %edx,(%eax)
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 02 00 00 00       	call   8002d1 <vprintfmt>
	va_end(ap);
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 4c             	sub    $0x4c,%esp
  8002da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002dd:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e0:	eb 17                	jmp    8002f9 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	0f 84 93 03 00 00    	je     80067d <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	ff 55 08             	call   *0x8(%ebp)
  8002f4:	eb 03                	jmp    8002f9 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 06             	movzbl (%esi),%eax
  8002fc:	46                   	inc    %esi
  8002fd:	83 f8 25             	cmp    $0x25,%eax
  800300:	75 e0                	jne    8002e2 <vprintfmt+0x11>
  800302:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800306:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80030d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800312:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031e:	eb 26                	jmp    800346 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800327:	eb 1d                	jmp    800346 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800330:	eb 14                	jmp    800346 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800335:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033c:	eb 08                	jmp    800346 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800341:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	0f b6 16             	movzbl (%esi),%edx
  800349:	8d 46 01             	lea    0x1(%esi),%eax
  80034c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034f:	8a 06                	mov    (%esi),%al
  800351:	83 e8 23             	sub    $0x23,%eax
  800354:	3c 55                	cmp    $0x55,%al
  800356:	0f 87 fd 02 00 00    	ja     800659 <vprintfmt+0x388>
  80035c:	0f b6 c0             	movzbl %al,%eax
  80035f:	ff 24 85 cc 0f 80 00 	jmp    *0x800fcc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800366:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  800369:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80036d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800370:	83 fa 09             	cmp    $0x9,%edx
  800373:	77 3f                	ja     8003b4 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800378:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800379:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80037c:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800380:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800383:	8d 50 d0             	lea    -0x30(%eax),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	76 ed                	jbe    800378 <vprintfmt+0xa7>
  80038b:	eb 2a                	jmp    8003b7 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 50 04             	lea    0x4(%eax),%edx
  800393:	89 55 14             	mov    %edx,0x14(%ebp)
  800396:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039b:	eb 1a                	jmp    8003b7 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  80039d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a1:	78 8f                	js     800332 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a6:	eb 9e                	jmp    800346 <vprintfmt+0x75>
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ab:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003b2:	eb 92                	jmp    800346 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bb:	79 89                	jns    800346 <vprintfmt+0x75>
  8003bd:	e9 7c ff ff ff       	jmp    80033e <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c6:	e9 7b ff ff ff       	jmp    800346 <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 50 04             	lea    0x4(%eax),%edx
  8003d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e3:	e9 11 ff ff ff       	jmp    8002f9 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	79 02                	jns    8003f9 <vprintfmt+0x128>
  8003f7:	f7 d8                	neg    %eax
  8003f9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 06             	cmp    $0x6,%eax
  8003fe:	7f 0b                	jg     80040b <vprintfmt+0x13a>
  800400:	8b 04 85 24 11 80 00 	mov    0x801124(,%eax,4),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	75 23                	jne    80042e <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80040b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80040f:	c7 44 24 08 55 0f 80 	movl   $0x800f55,0x8(%esp)
  800416:	00 
  800417:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041b:	8b 55 08             	mov    0x8(%ebp),%edx
  80041e:	89 14 24             	mov    %edx,(%esp)
  800421:	e8 83 fe ff ff       	call   8002a9 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800429:	e9 cb fe ff ff       	jmp    8002f9 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 5e 0f 80 	movl   $0x800f5e,0x8(%esp)
  800439:	00 
  80043a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800441:	89 0c 24             	mov    %ecx,(%esp)
  800444:	e8 60 fe ff ff       	call   8002a9 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044c:	e9 a8 fe ff ff       	jmp    8002f9 <vprintfmt+0x28>
  800451:	89 f9                	mov    %edi,%ecx
  800453:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800464:	85 c0                	test   %eax,%eax
  800466:	75 07                	jne    80046f <vprintfmt+0x19e>
				p = "(null)";
  800468:	c7 45 d4 4e 0f 80 00 	movl   $0x800f4e,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80046f:	85 f6                	test   %esi,%esi
  800471:	7e 3b                	jle    8004ae <vprintfmt+0x1dd>
  800473:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800477:	74 35                	je     8004ae <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80047d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 a4 02 00 00       	call   80072c <strnlen>
  800488:	29 c6                	sub    %eax,%esi
  80048a:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  80048d:	85 f6                	test   %esi,%esi
  80048f:	7e 1d                	jle    8004ae <vprintfmt+0x1dd>
					putch(padc, putdat);
  800491:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800495:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049f:	89 34 24             	mov    %esi,(%esp)
  8004a2:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	4f                   	dec    %edi
  8004a6:	75 f3                	jne    80049b <vprintfmt+0x1ca>
  8004a8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004ab:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b1:	0f be 02             	movsbl (%edx),%eax
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	75 43                	jne    8004fb <vprintfmt+0x22a>
  8004b8:	eb 33                	jmp    8004ed <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004be:	74 18                	je     8004d8 <vprintfmt+0x207>
  8004c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c3:	83 fa 5e             	cmp    $0x5e,%edx
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x207>
					putch('?', putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	eb 0a                	jmp    8004e2 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e5:	0f be 06             	movsbl (%esi),%eax
  8004e8:	46                   	inc    %esi
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 12                	jne    8004ff <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f1:	7f 15                	jg     800508 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f6:	e9 fe fd ff ff       	jmp    8002f9 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004fe:	46                   	inc    %esi
  8004ff:	85 ff                	test   %edi,%edi
  800501:	78 b7                	js     8004ba <vprintfmt+0x1e9>
  800503:	4f                   	dec    %edi
  800504:	79 b4                	jns    8004ba <vprintfmt+0x1e9>
  800506:	eb e5                	jmp    8004ed <vprintfmt+0x21c>
  800508:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80050b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800512:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800519:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051b:	4e                   	dec    %esi
  80051c:	75 f0                	jne    80050e <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800521:	e9 d3 fd ff ff       	jmp    8002f9 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800526:	83 f9 01             	cmp    $0x1,%ecx
  800529:	7e 10                	jle    80053b <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 08             	lea    0x8(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	8b 78 04             	mov    0x4(%eax),%edi
  800539:	eb 26                	jmp    800561 <vprintfmt+0x290>
	else if (lflag)
  80053b:	85 c9                	test   %ecx,%ecx
  80053d:	74 12                	je     800551 <vprintfmt+0x280>
		return va_arg(*ap, long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
  80054a:	89 f7                	mov    %esi,%edi
  80054c:	c1 ff 1f             	sar    $0x1f,%edi
  80054f:	eb 10                	jmp    800561 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 30                	mov    (%eax),%esi
  80055c:	89 f7                	mov    %esi,%edi
  80055e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800561:	85 ff                	test   %edi,%edi
  800563:	78 0e                	js     800573 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800565:	89 f0                	mov    %esi,%eax
  800567:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800569:	be 0a 00 00 00       	mov    $0xa,%esi
  80056e:	e9 a8 00 00 00       	jmp    80061b <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800573:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800577:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800581:	89 f0                	mov    %esi,%eax
  800583:	89 fa                	mov    %edi,%edx
  800585:	f7 d8                	neg    %eax
  800587:	83 d2 00             	adc    $0x0,%edx
  80058a:	f7 da                	neg    %edx
			}
			base = 10;
  80058c:	be 0a 00 00 00       	mov    $0xa,%esi
  800591:	e9 85 00 00 00       	jmp    80061b <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800596:	89 ca                	mov    %ecx,%edx
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 b5 fc ff ff       	call   800255 <getuint>
			base = 10;
  8005a0:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005a5:	eb 74                	jmp    80061b <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b9:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c0:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ce:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d4:	e9 20 fd ff ff       	jmp    8002f9 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800605:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80060a:	eb 0f                	jmp    80061b <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060c:	89 ca                	mov    %ecx,%edx
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 3f fc ff ff       	call   800255 <getuint>
			base = 16;
  800616:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061b:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80061f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800623:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800626:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80062a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	89 54 24 04          	mov    %edx,0x4(%esp)
  800635:	89 da                	mov    %ebx,%edx
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	e8 41 fb ff ff       	call   800180 <printnum>
			break;
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800642:	e9 b2 fc ff ff       	jmp    8002f9 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064b:	89 14 24             	mov    %edx,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800654:	e9 a0 fc ff ff       	jmp    8002f9 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800659:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800664:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800667:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066b:	0f 84 88 fc ff ff    	je     8002f9 <vprintfmt+0x28>
  800671:	4e                   	dec    %esi
  800672:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800676:	75 f9                	jne    800671 <vprintfmt+0x3a0>
  800678:	e9 7c fc ff ff       	jmp    8002f9 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  80067d:	83 c4 4c             	add    $0x4c,%esp
  800680:	5b                   	pop    %ebx
  800681:	5e                   	pop    %esi
  800682:	5f                   	pop    %edi
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 28             	sub    $0x28,%esp
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800694:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800698:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	74 30                	je     8006d6 <vsnprintf+0x51>
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	7e 33                	jle    8006dd <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bf:	c7 04 24 8f 02 80 00 	movl   $0x80028f,(%esp)
  8006c6:	e8 06 fc ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d4:	eb 0c                	jmp    8006e2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006db:	eb 05                	jmp    8006e2 <vsnprintf+0x5d>
  8006dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	89 04 24             	mov    %eax,(%esp)
  800705:	e8 7b ff ff ff       	call   800685 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	80 3a 00             	cmpb   $0x0,(%edx)
  800715:	74 0e                	je     800725 <strlen+0x19>
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80071c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800721:	75 f9                	jne    80071c <strlen+0x10>
  800723:	eb 05                	jmp    80072a <strlen+0x1e>
  800725:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800736:	85 c9                	test   %ecx,%ecx
  800738:	74 1a                	je     800754 <strnlen+0x28>
  80073a:	80 3b 00             	cmpb   $0x0,(%ebx)
  80073d:	74 1c                	je     80075b <strnlen+0x2f>
  80073f:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800744:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800746:	39 ca                	cmp    %ecx,%edx
  800748:	74 16                	je     800760 <strnlen+0x34>
  80074a:	42                   	inc    %edx
  80074b:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800750:	75 f2                	jne    800744 <strnlen+0x18>
  800752:	eb 0c                	jmp    800760 <strnlen+0x34>
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	eb 05                	jmp    800760 <strnlen+0x34>
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800760:	5b                   	pop    %ebx
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800775:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800778:	42                   	inc    %edx
  800779:	84 c9                	test   %cl,%cl
  80077b:	75 f5                	jne    800772 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	89 1c 24             	mov    %ebx,(%esp)
  80078d:	e8 7a ff ff ff       	call   80070c <strlen>
	strcpy(dst + len, src);
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	01 d8                	add    %ebx,%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 c0 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	85 f6                	test   %esi,%esi
  8007bb:	74 15                	je     8007d2 <strncpy+0x27>
  8007bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c2:	8a 1a                	mov    (%edx),%bl
  8007c4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c7:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ca:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	41                   	inc    %ecx
  8007ce:	39 f1                	cmp    %esi,%ecx
  8007d0:	75 f0                	jne    8007c2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	57                   	push   %edi
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e2:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e5:	85 f6                	test   %esi,%esi
  8007e7:	74 31                	je     80081a <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  8007e9:	83 fe 01             	cmp    $0x1,%esi
  8007ec:	74 21                	je     80080f <strlcpy+0x39>
  8007ee:	8a 0b                	mov    (%ebx),%cl
  8007f0:	84 c9                	test   %cl,%cl
  8007f2:	74 1f                	je     800813 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007f4:	83 ee 02             	sub    $0x2,%esi
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	88 08                	mov    %cl,(%eax)
  800800:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800801:	39 f2                	cmp    %esi,%edx
  800803:	74 10                	je     800815 <strlcpy+0x3f>
  800805:	42                   	inc    %edx
  800806:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800809:	84 c9                	test   %cl,%cl
  80080b:	75 f1                	jne    8007fe <strlcpy+0x28>
  80080d:	eb 06                	jmp    800815 <strlcpy+0x3f>
  80080f:	89 f8                	mov    %edi,%eax
  800811:	eb 02                	jmp    800815 <strlcpy+0x3f>
  800813:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800815:	c6 00 00             	movb   $0x0,(%eax)
  800818:	eb 02                	jmp    80081c <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80081c:	29 f8                	sub    %edi,%eax
}
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5f                   	pop    %edi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082c:	8a 01                	mov    (%ecx),%al
  80082e:	84 c0                	test   %al,%al
  800830:	74 11                	je     800843 <strcmp+0x20>
  800832:	3a 02                	cmp    (%edx),%al
  800834:	75 0d                	jne    800843 <strcmp+0x20>
		p++, q++;
  800836:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800837:	8a 41 01             	mov    0x1(%ecx),%al
  80083a:	84 c0                	test   %al,%al
  80083c:	74 05                	je     800843 <strcmp+0x20>
  80083e:	41                   	inc    %ecx
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	74 f3                	je     800836 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 55 08             	mov    0x8(%ebp),%edx
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 1b                	je     800879 <strncmp+0x2c>
  80085e:	8a 1a                	mov    (%edx),%bl
  800860:	84 db                	test   %bl,%bl
  800862:	74 24                	je     800888 <strncmp+0x3b>
  800864:	3a 19                	cmp    (%ecx),%bl
  800866:	75 20                	jne    800888 <strncmp+0x3b>
  800868:	48                   	dec    %eax
  800869:	74 15                	je     800880 <strncmp+0x33>
		n--, p++, q++;
  80086b:	42                   	inc    %edx
  80086c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086d:	8a 1a                	mov    (%edx),%bl
  80086f:	84 db                	test   %bl,%bl
  800871:	74 15                	je     800888 <strncmp+0x3b>
  800873:	3a 19                	cmp    (%ecx),%bl
  800875:	74 f1                	je     800868 <strncmp+0x1b>
  800877:	eb 0f                	jmp    800888 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	eb 05                	jmp    800885 <strncmp+0x38>
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 02             	movzbl (%edx),%eax
  80088b:	0f b6 11             	movzbl (%ecx),%edx
  80088e:	29 d0                	sub    %edx,%eax
  800890:	eb f3                	jmp    800885 <strncmp+0x38>

00800892 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089b:	8a 10                	mov    (%eax),%dl
  80089d:	84 d2                	test   %dl,%dl
  80089f:	74 19                	je     8008ba <strchr+0x28>
		if (*s == c)
  8008a1:	38 ca                	cmp    %cl,%dl
  8008a3:	75 07                	jne    8008ac <strchr+0x1a>
  8008a5:	eb 18                	jmp    8008bf <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a7:	40                   	inc    %eax
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 13                	je     8008bf <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ac:	8a 50 01             	mov    0x1(%eax),%dl
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f4                	jne    8008a7 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	eb 05                	jmp    8008bf <strchr+0x2d>
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ca:	8a 10                	mov    (%eax),%dl
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	74 11                	je     8008e1 <strfind+0x20>
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	75 06                	jne    8008da <strfind+0x19>
  8008d4:	eb 0b                	jmp    8008e1 <strfind+0x20>
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 07                	je     8008e1 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008da:	40                   	inc    %eax
  8008db:	8a 10                	mov    (%eax),%dl
  8008dd:	84 d2                	test   %dl,%dl
  8008df:	75 f5                	jne    8008d6 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	57                   	push   %edi
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f2:	85 c9                	test   %ecx,%ecx
  8008f4:	74 30                	je     800926 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fc:	75 25                	jne    800923 <memset+0x40>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 20                	jne    800923 <memset+0x40>
		c &= 0xFF;
  800903:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800906:	89 d3                	mov    %edx,%ebx
  800908:	c1 e3 08             	shl    $0x8,%ebx
  80090b:	89 d6                	mov    %edx,%esi
  80090d:	c1 e6 18             	shl    $0x18,%esi
  800910:	89 d0                	mov    %edx,%eax
  800912:	c1 e0 10             	shl    $0x10,%eax
  800915:	09 f0                	or     %esi,%eax
  800917:	09 d0                	or     %edx,%eax
  800919:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091b:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091e:	fc                   	cld    
  80091f:	f3 ab                	rep stos %eax,%es:(%edi)
  800921:	eb 03                	jmp    800926 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800923:	fc                   	cld    
  800924:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800926:	89 f8                	mov    %edi,%eax
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 75 0c             	mov    0xc(%ebp),%esi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093b:	39 c6                	cmp    %eax,%esi
  80093d:	73 34                	jae    800973 <memmove+0x46>
  80093f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800942:	39 d0                	cmp    %edx,%eax
  800944:	73 2d                	jae    800973 <memmove+0x46>
		s += n;
		d += n;
  800946:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	f6 c2 03             	test   $0x3,%dl
  80094c:	75 1b                	jne    800969 <memmove+0x3c>
  80094e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800954:	75 13                	jne    800969 <memmove+0x3c>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0e                	jne    800969 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095b:	83 ef 04             	sub    $0x4,%edi
  80095e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800961:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800964:	fd                   	std    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb 07                	jmp    800970 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800969:	4f                   	dec    %edi
  80096a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096d:	fd                   	std    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800970:	fc                   	cld    
  800971:	eb 20                	jmp    800993 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800979:	75 13                	jne    80098e <memmove+0x61>
  80097b:	a8 03                	test   $0x3,%al
  80097d:	75 0f                	jne    80098e <memmove+0x61>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 0a                	jne    80098e <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800984:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098c:	eb 05                	jmp    800993 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098e:	89 c7                	mov    %eax,%edi
  800990:	fc                   	cld    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099d:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	89 04 24             	mov    %eax,(%esp)
  8009b1:	e8 77 ff ff ff       	call   80092d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	57                   	push   %edi
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c7:	85 ff                	test   %edi,%edi
  8009c9:	74 31                	je     8009fc <memcmp+0x44>
		if (*s1 != *s2)
  8009cb:	8a 03                	mov    (%ebx),%al
  8009cd:	8a 0e                	mov    (%esi),%cl
  8009cf:	38 c8                	cmp    %cl,%al
  8009d1:	74 18                	je     8009eb <memcmp+0x33>
  8009d3:	eb 0c                	jmp    8009e1 <memcmp+0x29>
  8009d5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009d9:	42                   	inc    %edx
  8009da:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  8009dd:	38 c8                	cmp    %cl,%al
  8009df:	74 10                	je     8009f1 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c0             	movzbl %al,%eax
  8009e4:	0f b6 c9             	movzbl %cl,%ecx
  8009e7:	29 c8                	sub    %ecx,%eax
  8009e9:	eb 16                	jmp    800a01 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009eb:	4f                   	dec    %edi
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	39 fa                	cmp    %edi,%edx
  8009f3:	75 e0                	jne    8009d5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	eb 05                	jmp    800a01 <memcmp+0x49>
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0c:	89 c2                	mov    %eax,%edx
  800a0e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a11:	39 d0                	cmp    %edx,%eax
  800a13:	73 12                	jae    800a27 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a15:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a18:	38 08                	cmp    %cl,(%eax)
  800a1a:	75 06                	jne    800a22 <memfind+0x1c>
  800a1c:	eb 09                	jmp    800a27 <memfind+0x21>
  800a1e:	38 08                	cmp    %cl,(%eax)
  800a20:	74 05                	je     800a27 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a22:	40                   	inc    %eax
  800a23:	39 d0                	cmp    %edx,%eax
  800a25:	75 f7                	jne    800a1e <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 01                	jmp    800a38 <strtol+0xf>
		s++;
  800a37:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a38:	8a 02                	mov    (%edx),%al
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f9                	je     800a37 <strtol+0xe>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f5                	je     800a37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	75 08                	jne    800a4e <strtol+0x25>
		s++;
  800a46:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4c:	eb 13                	jmp    800a61 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 0a                	jne    800a5c <strtol+0x33>
		s++, neg = 1;
  800a52:	8d 52 01             	lea    0x1(%edx),%edx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5a:	eb 05                	jmp    800a61 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	74 05                	je     800a6a <strtol+0x41>
  800a65:	83 fb 10             	cmp    $0x10,%ebx
  800a68:	75 28                	jne    800a92 <strtol+0x69>
  800a6a:	8a 02                	mov    (%edx),%al
  800a6c:	3c 30                	cmp    $0x30,%al
  800a6e:	75 10                	jne    800a80 <strtol+0x57>
  800a70:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a74:	75 0a                	jne    800a80 <strtol+0x57>
		s += 2, base = 16;
  800a76:	83 c2 02             	add    $0x2,%edx
  800a79:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7e:	eb 12                	jmp    800a92 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	75 0e                	jne    800a92 <strtol+0x69>
  800a84:	3c 30                	cmp    $0x30,%al
  800a86:	75 05                	jne    800a8d <strtol+0x64>
		s++, base = 8;
  800a88:	42                   	inc    %edx
  800a89:	b3 08                	mov    $0x8,%bl
  800a8b:	eb 05                	jmp    800a92 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a8d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a99:	8a 0a                	mov    (%edx),%cl
  800a9b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a9e:	80 fb 09             	cmp    $0x9,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x82>
			dig = *s - '0';
  800aa3:	0f be c9             	movsbl %cl,%ecx
  800aa6:	83 e9 30             	sub    $0x30,%ecx
  800aa9:	eb 1e                	jmp    800ac9 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0x92>
			dig = *s - 'a' + 10;
  800ab3:	0f be c9             	movsbl %cl,%ecx
  800ab6:	83 e9 57             	sub    $0x57,%ecx
  800ab9:	eb 0e                	jmp    800ac9 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800abb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800abe:	80 fb 19             	cmp    $0x19,%bl
  800ac1:	77 12                	ja     800ad5 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ac3:	0f be c9             	movsbl %cl,%ecx
  800ac6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac9:	39 f1                	cmp    %esi,%ecx
  800acb:	7d 0c                	jge    800ad9 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800acd:	42                   	inc    %edx
  800ace:	0f af c6             	imul   %esi,%eax
  800ad1:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ad3:	eb c4                	jmp    800a99 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad5:	89 c1                	mov    %eax,%ecx
  800ad7:	eb 02                	jmp    800adb <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800adb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adf:	74 05                	je     800ae6 <strtol+0xbd>
		*endptr = (char *) s;
  800ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae6:	85 ff                	test   %edi,%edi
  800ae8:	74 04                	je     800aee <strtol+0xc5>
  800aea:	89 c8                	mov    %ecx,%eax
  800aec:	f7 d8                	neg    %eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    
	...

00800af4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	51                   	push   %ecx
  800b09:	52                   	push   %edx
  800b0a:	53                   	push   %ebx
  800b0b:	54                   	push   %esp
  800b0c:	55                   	push   %ebp
  800b0d:	56                   	push   %esi
  800b0e:	57                   	push   %edi
  800b0f:	8d 35 19 0b 80 00    	lea    0x800b19,%esi
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	0f 34                	sysenter 

00800b19 <after_sysenter_label16>:
  800b19:	5f                   	pop    %edi
  800b1a:	5e                   	pop    %esi
  800b1b:	5d                   	pop    %ebp
  800b1c:	5c                   	pop    %esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5a                   	pop    %edx
  800b1f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	51                   	push   %ecx
  800b3a:	52                   	push   %edx
  800b3b:	53                   	push   %ebx
  800b3c:	54                   	push   %esp
  800b3d:	55                   	push   %ebp
  800b3e:	56                   	push   %esi
  800b3f:	57                   	push   %edi
  800b40:	8d 35 4a 0b 80 00    	lea    0x800b4a,%esi
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	0f 34                	sysenter 

00800b4a <after_sysenter_label41>:
  800b4a:	5f                   	pop    %edi
  800b4b:	5e                   	pop    %esi
  800b4c:	5d                   	pop    %ebp
  800b4d:	5c                   	pop    %esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5a                   	pop    %edx
  800b50:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	b8 03 00 00 00       	mov    $0x3,%eax
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	89 cb                	mov    %ecx,%ebx
  800b6c:	89 cf                	mov    %ecx,%edi
  800b6e:	51                   	push   %ecx
  800b6f:	52                   	push   %edx
  800b70:	53                   	push   %ebx
  800b71:	54                   	push   %esp
  800b72:	55                   	push   %ebp
  800b73:	56                   	push   %esi
  800b74:	57                   	push   %edi
  800b75:	8d 35 7f 0b 80 00    	lea    0x800b7f,%esi
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	0f 34                	sysenter 

00800b7f <after_sysenter_label68>:
  800b7f:	5f                   	pop    %edi
  800b80:	5e                   	pop    %esi
  800b81:	5d                   	pop    %ebp
  800b82:	5c                   	pop    %esp
  800b83:	5b                   	pop    %ebx
  800b84:	5a                   	pop    %edx
  800b85:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 28                	jle    800bb2 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b95:	00 
  800b96:	c7 44 24 08 40 11 80 	movl   $0x801140,0x8(%esp)
  800b9d:	00 
  800b9e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ba5:	00 
  800ba6:	c7 04 24 5d 11 80 00 	movl   $0x80115d,(%esp)
  800bad:	e8 9e 00 00 00       	call   800c50 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb2:	83 c4 20             	add    $0x20,%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	51                   	push   %ecx
  800bcf:	52                   	push   %edx
  800bd0:	53                   	push   %ebx
  800bd1:	54                   	push   %esp
  800bd2:	55                   	push   %ebp
  800bd3:	56                   	push   %esi
  800bd4:	57                   	push   %edi
  800bd5:	8d 35 df 0b 80 00    	lea    0x800bdf,%esi
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	0f 34                	sysenter 

00800bdf <after_sysenter_label107>:
  800bdf:	5f                   	pop    %edi
  800be0:	5e                   	pop    %esi
  800be1:	5d                   	pop    %ebp
  800be2:	5c                   	pop    %esp
  800be3:	5b                   	pop    %ebx
  800be4:	5a                   	pop    %edx
  800be5:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	89 df                	mov    %ebx,%edi
  800c01:	51                   	push   %ecx
  800c02:	52                   	push   %edx
  800c03:	53                   	push   %ebx
  800c04:	54                   	push   %esp
  800c05:	55                   	push   %ebp
  800c06:	56                   	push   %esi
  800c07:	57                   	push   %edi
  800c08:	8d 35 12 0c 80 00    	lea    0x800c12,%esi
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	0f 34                	sysenter 

00800c12 <after_sysenter_label133>:
  800c12:	5f                   	pop    %edi
  800c13:	5e                   	pop    %esi
  800c14:	5d                   	pop    %ebp
  800c15:	5c                   	pop    %esp
  800c16:	5b                   	pop    %ebx
  800c17:	5a                   	pop    %edx
  800c18:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c27:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	89 cb                	mov    %ecx,%ebx
  800c31:	89 cf                	mov    %ecx,%edi
  800c33:	51                   	push   %ecx
  800c34:	52                   	push   %edx
  800c35:	53                   	push   %ebx
  800c36:	54                   	push   %esp
  800c37:	55                   	push   %ebp
  800c38:	56                   	push   %esi
  800c39:	57                   	push   %edi
  800c3a:	8d 35 44 0c 80 00    	lea    0x800c44,%esi
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	0f 34                	sysenter 

00800c44 <after_sysenter_label159>:
  800c44:	5f                   	pop    %edi
  800c45:	5e                   	pop    %esi
  800c46:	5d                   	pop    %ebp
  800c47:	5c                   	pop    %esp
  800c48:	5b                   	pop    %ebx
  800c49:	5a                   	pop    %edx
  800c4a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    
	...

00800c50 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c58:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c5b:	a1 08 20 80 00       	mov    0x802008,%eax
  800c60:	85 c0                	test   %eax,%eax
  800c62:	74 10                	je     800c74 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c68:	c7 04 24 6b 11 80 00 	movl   $0x80116b,(%esp)
  800c6f:	e8 f0 f4 ff ff       	call   800164 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c74:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c7a:	e8 3a ff ff ff       	call   800bb9 <sys_getenvid>
  800c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c82:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c95:	c7 04 24 70 11 80 00 	movl   $0x801170,(%esp)
  800c9c:	e8 c3 f4 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ca1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca8:	89 04 24             	mov    %eax,(%esp)
  800cab:	e8 53 f4 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800cb0:	c7 04 24 1e 0f 80 00 	movl   $0x800f1e,(%esp)
  800cb7:	e8 a8 f4 ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cbc:	cc                   	int3   
  800cbd:	eb fd                	jmp    800cbc <_panic+0x6c>
	...

00800cc0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	83 ec 10             	sub    $0x10,%esp
  800cc6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cca:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cce:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800cd6:	89 cd                	mov    %ecx,%ebp
  800cd8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	75 2c                	jne    800d0c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ce0:	39 f9                	cmp    %edi,%ecx
  800ce2:	77 68                	ja     800d4c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce4:	85 c9                	test   %ecx,%ecx
  800ce6:	75 0b                	jne    800cf3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ced:	31 d2                	xor    %edx,%edx
  800cef:	f7 f1                	div    %ecx
  800cf1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf3:	31 d2                	xor    %edx,%edx
  800cf5:	89 f8                	mov    %edi,%eax
  800cf7:	f7 f1                	div    %ecx
  800cf9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	f7 f1                	div    %ecx
  800cff:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d05:	83 c4 10             	add    $0x10,%esp
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d0c:	39 f8                	cmp    %edi,%eax
  800d0e:	77 2c                	ja     800d3c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d10:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d13:	83 f6 1f             	xor    $0x1f,%esi
  800d16:	75 4c                	jne    800d64 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d18:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d1a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d1f:	72 0a                	jb     800d2b <__udivdi3+0x6b>
  800d21:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d25:	0f 87 ad 00 00 00    	ja     800dd8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d2b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d30:	89 f0                	mov    %esi,%eax
  800d32:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d3c:	31 ff                	xor    %edi,%edi
  800d3e:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d4c:	89 fa                	mov    %edi,%edx
  800d4e:	89 f0                	mov    %esi,%eax
  800d50:	f7 f1                	div    %ecx
  800d52:	89 c6                	mov    %eax,%esi
  800d54:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d56:	89 f0                	mov    %esi,%eax
  800d58:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    
  800d61:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d64:	89 f1                	mov    %esi,%ecx
  800d66:	d3 e0                	shl    %cl,%eax
  800d68:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d6c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d71:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d73:	89 ea                	mov    %ebp,%edx
  800d75:	88 c1                	mov    %al,%cl
  800d77:	d3 ea                	shr    %cl,%edx
  800d79:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800d7d:	09 ca                	or     %ecx,%edx
  800d7f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800d83:	89 f1                	mov    %esi,%ecx
  800d85:	d3 e5                	shl    %cl,%ebp
  800d87:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800d8b:	89 fd                	mov    %edi,%ebp
  800d8d:	88 c1                	mov    %al,%cl
  800d8f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800d91:	89 fa                	mov    %edi,%edx
  800d93:	89 f1                	mov    %esi,%ecx
  800d95:	d3 e2                	shl    %cl,%edx
  800d97:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d9b:	88 c1                	mov    %al,%cl
  800d9d:	d3 ef                	shr    %cl,%edi
  800d9f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da1:	89 f8                	mov    %edi,%eax
  800da3:	89 ea                	mov    %ebp,%edx
  800da5:	f7 74 24 08          	divl   0x8(%esp)
  800da9:	89 d1                	mov    %edx,%ecx
  800dab:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800dad:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db1:	39 d1                	cmp    %edx,%ecx
  800db3:	72 17                	jb     800dcc <__udivdi3+0x10c>
  800db5:	74 09                	je     800dc0 <__udivdi3+0x100>
  800db7:	89 fe                	mov    %edi,%esi
  800db9:	31 ff                	xor    %edi,%edi
  800dbb:	e9 41 ff ff ff       	jmp    800d01 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dc0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dc4:	89 f1                	mov    %esi,%ecx
  800dc6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc8:	39 c2                	cmp    %eax,%edx
  800dca:	73 eb                	jae    800db7 <__udivdi3+0xf7>
		{
		  q0--;
  800dcc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dcf:	31 ff                	xor    %edi,%edi
  800dd1:	e9 2b ff ff ff       	jmp    800d01 <__udivdi3+0x41>
  800dd6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd8:	31 f6                	xor    %esi,%esi
  800dda:	e9 22 ff ff ff       	jmp    800d01 <__udivdi3+0x41>
	...

00800de0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	83 ec 20             	sub    $0x20,%esp
  800de6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800dea:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dee:	89 44 24 14          	mov    %eax,0x14(%esp)
  800df2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800df6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800dfa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dfe:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e00:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e02:	85 ed                	test   %ebp,%ebp
  800e04:	75 16                	jne    800e1c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e06:	39 f1                	cmp    %esi,%ecx
  800e08:	0f 86 a6 00 00 00    	jbe    800eb4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e0e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e10:	89 d0                	mov    %edx,%eax
  800e12:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e14:	83 c4 20             	add    $0x20,%esp
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
  800e1b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e1c:	39 f5                	cmp    %esi,%ebp
  800e1e:	0f 87 ac 00 00 00    	ja     800ed0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e24:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e27:	83 f0 1f             	xor    $0x1f,%eax
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	0f 84 a8 00 00 00    	je     800edc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e34:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e38:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e3a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e3f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e43:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e47:	89 f9                	mov    %edi,%ecx
  800e49:	d3 e8                	shr    %cl,%eax
  800e4b:	09 e8                	or     %ebp,%eax
  800e4d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e55:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e59:	d3 e0                	shl    %cl,%eax
  800e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e5f:	89 f2                	mov    %esi,%edx
  800e61:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e63:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e67:	d3 e0                	shl    %cl,%eax
  800e69:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e6d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e8                	shr    %cl,%eax
  800e75:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e77:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e79:	89 f2                	mov    %esi,%edx
  800e7b:	f7 74 24 18          	divl   0x18(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e81:	f7 64 24 0c          	mull   0xc(%esp)
  800e85:	89 c5                	mov    %eax,%ebp
  800e87:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e89:	39 d6                	cmp    %edx,%esi
  800e8b:	72 67                	jb     800ef4 <__umoddi3+0x114>
  800e8d:	74 75                	je     800f04 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e8f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800e93:	29 e8                	sub    %ebp,%eax
  800e95:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e9b:	d3 e8                	shr    %cl,%eax
  800e9d:	89 f2                	mov    %esi,%edx
  800e9f:	89 f9                	mov    %edi,%ecx
  800ea1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ea3:	09 d0                	or     %edx,%eax
  800ea5:	89 f2                	mov    %esi,%edx
  800ea7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eab:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ead:	83 c4 20             	add    $0x20,%esp
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb4:	85 c9                	test   %ecx,%ecx
  800eb6:	75 0b                	jne    800ec3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	f7 f1                	div    %ecx
  800ec1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	31 d2                	xor    %edx,%edx
  800ec7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec9:	89 f8                	mov    %edi,%eax
  800ecb:	e9 3e ff ff ff       	jmp    800e0e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ed0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed2:	83 c4 20             	add    $0x20,%esp
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800edc:	39 f5                	cmp    %esi,%ebp
  800ede:	72 04                	jb     800ee4 <__umoddi3+0x104>
  800ee0:	39 f9                	cmp    %edi,%ecx
  800ee2:	77 06                	ja     800eea <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee4:	89 f2                	mov    %esi,%edx
  800ee6:	29 cf                	sub    %ecx,%edi
  800ee8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800eea:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eec:	83 c4 20             	add    $0x20,%esp
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
  800ef3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef4:	89 d1                	mov    %edx,%ecx
  800ef6:	89 c5                	mov    %eax,%ebp
  800ef8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800efc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f00:	eb 8d                	jmp    800e8f <__umoddi3+0xaf>
  800f02:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f04:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f08:	72 ea                	jb     800ef4 <__umoddi3+0x114>
  800f0a:	89 f1                	mov    %esi,%ecx
  800f0c:	eb 81                	jmp    800e8f <__umoddi3+0xaf>
