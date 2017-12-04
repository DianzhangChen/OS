
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 24 0f 80 00 	movl   $0x800f24,(%esp)
  80004a:	e8 29 01 00 00       	call   800178 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 66 0b 00 00       	call   800bcd <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80006f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800072:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80007e:	c7 04 24 42 0f 80 00 	movl   $0x800f42,(%esp)
  800085:	e8 ee 00 00 00       	call   800178 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  80008a:	a1 04 20 80 00       	mov    0x802004,%eax
  80008f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800093:	c7 04 24 52 0f 80 00 	movl   $0x800f52,(%esp)
  80009a:	e8 d9 00 00 00       	call   800178 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009f:	85 f6                	test   %esi,%esi
  8000a1:	7e 07                	jle    8000aa <libmain+0x56>
		binaryname = argv[0];
  8000a3:	8b 03                	mov    (%ebx),%eax
  8000a5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ae:	89 34 24             	mov    %esi,(%esp)
  8000b1:	e8 7e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b6:	e8 09 00 00 00       	call   8000c4 <exit>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    
	...

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d1:	e8 93 0a 00 00       	call   800b69 <sys_env_destroy>
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 14             	sub    $0x14,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000eb:	40                   	inc    %eax
  8000ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f3:	75 19                	jne    80010e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000f5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fc:	00 
  8000fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800100:	89 04 24             	mov    %eax,(%esp)
  800103:	e8 00 0a 00 00       	call   800b08 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010e:	ff 43 04             	incl   0x4(%ebx)
}
  800111:	83 c4 14             	add    $0x14,%esp
  800114:	5b                   	pop    %ebx
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	8b 45 08             	mov    0x8(%ebp),%eax
  80013e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800142:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	c7 04 24 d8 00 80 00 	movl   $0x8000d8,(%esp)
  800153:	e8 8d 01 00 00       	call   8002e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800162:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800168:	89 04 24             	mov    %eax,(%esp)
  80016b:	e8 98 09 00 00       	call   800b08 <sys_cputs>

	return b.cnt;
}
  800170:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 87 ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  800190:	c9                   	leave  
  800191:	c3                   	ret    
	...

00800194 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 3c             	sub    $0x3c,%esp
  80019d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a0:	89 d7                	mov    %edx,%edi
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b1:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001bc:	72 0f                	jb     8001cd <printnum+0x39>
  8001be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c4:	76 07                	jbe    8001cd <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c6:	4b                   	dec    %ebx
  8001c7:	85 db                	test   %ebx,%ebx
  8001c9:	7f 4f                	jg     80021a <printnum+0x86>
  8001cb:	eb 5a                	jmp    800227 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001d1:	4b                   	dec    %ebx
  8001d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ec:	00 
  8001ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	e8 d5 0a 00 00       	call   800cd4 <__udivdi3>
  8001ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800203:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020e:	89 fa                	mov    %edi,%edx
  800210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800213:	e8 7c ff ff ff       	call   800194 <printnum>
  800218:	eb 0d                	jmp    800227 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021e:	89 34 24             	mov    %esi,(%esp)
  800221:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800224:	4b                   	dec    %ebx
  800225:	75 f3                	jne    80021a <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022f:	8b 45 10             	mov    0x10(%ebp),%eax
  800232:	89 44 24 08          	mov    %eax,0x8(%esp)
  800236:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023d:	00 
  80023e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024b:	e8 a4 0b 00 00       	call   800df4 <__umoddi3>
  800250:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800254:	0f be 80 6f 0f 80 00 	movsbl 0x800f6f(%eax),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800261:	83 c4 3c             	add    $0x3c,%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026c:	83 fa 01             	cmp    $0x1,%edx
  80026f:	7e 0e                	jle    80027f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 08             	lea    0x8(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	8b 52 04             	mov    0x4(%edx),%edx
  80027d:	eb 22                	jmp    8002a1 <getuint+0x38>
	else if (lflag)
  80027f:	85 d2                	test   %edx,%edx
  800281:	74 10                	je     800293 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 04             	lea    0x4(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
  800291:	eb 0e                	jmp    8002a1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800293:	8b 10                	mov    (%eax),%edx
  800295:	8d 4a 04             	lea    0x4(%edx),%ecx
  800298:	89 08                	mov    %ecx,(%eax)
  80029a:	8b 02                	mov    (%edx),%eax
  80029c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b1:	73 08                	jae    8002bb <sprintputch+0x18>
		*b->buf++ = ch;
  8002b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b6:	88 0a                	mov    %cl,(%edx)
  8002b8:	42                   	inc    %edx
  8002b9:	89 10                	mov    %edx,(%eax)
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	e8 02 00 00 00       	call   8002e5 <vprintfmt>
	va_end(ap);
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 4c             	sub    $0x4c,%esp
  8002ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f4:	eb 17                	jmp    80030d <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f6:	85 c0                	test   %eax,%eax
  8002f8:	0f 84 93 03 00 00    	je     800691 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	ff 55 08             	call   *0x8(%ebp)
  800308:	eb 03                	jmp    80030d <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030d:	0f b6 06             	movzbl (%esi),%eax
  800310:	46                   	inc    %esi
  800311:	83 f8 25             	cmp    $0x25,%eax
  800314:	75 e0                	jne    8002f6 <vprintfmt+0x11>
  800316:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80031a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800321:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800326:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	eb 26                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800337:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80033b:	eb 1d                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800340:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800344:	eb 14                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800349:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800350:	eb 08                	jmp    80035a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800352:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800355:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	0f b6 16             	movzbl (%esi),%edx
  80035d:	8d 46 01             	lea    0x1(%esi),%eax
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	8a 06                	mov    (%esi),%al
  800365:	83 e8 23             	sub    $0x23,%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 fd 02 00 00    	ja     80066d <vprintfmt+0x388>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 fc 0f 80 00 	jmp    *0x800ffc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037a:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  80037d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800381:	8d 50 d0             	lea    -0x30(%eax),%edx
  800384:	83 fa 09             	cmp    $0x9,%edx
  800387:	77 3f                	ja     8003c8 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038c:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80038d:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800390:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800394:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800397:	8d 50 d0             	lea    -0x30(%eax),%edx
  80039a:	83 fa 09             	cmp    $0x9,%edx
  80039d:	76 ed                	jbe    80038c <vprintfmt+0xa7>
  80039f:	eb 2a                	jmp    8003cb <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 50 04             	lea    0x4(%eax),%edx
  8003a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003aa:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003af:	eb 1a                	jmp    8003cb <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b5:	78 8f                	js     800346 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ba:	eb 9e                	jmp    80035a <vprintfmt+0x75>
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bf:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003c6:	eb 92                	jmp    80035a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cf:	79 89                	jns    80035a <vprintfmt+0x75>
  8003d1:	e9 7c ff ff ff       	jmp    800352 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003da:	e9 7b ff ff ff       	jmp    80035a <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 50 04             	lea    0x4(%eax),%edx
  8003e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 04 24             	mov    %eax,(%esp)
  8003f1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f7:	e9 11 ff ff ff       	jmp    80030d <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	79 02                	jns    80040d <vprintfmt+0x128>
  80040b:	f7 d8                	neg    %eax
  80040d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040f:	83 f8 06             	cmp    $0x6,%eax
  800412:	7f 0b                	jg     80041f <vprintfmt+0x13a>
  800414:	8b 04 85 54 11 80 00 	mov    0x801154(,%eax,4),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	75 23                	jne    800442 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80041f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800423:	c7 44 24 08 87 0f 80 	movl   $0x800f87,0x8(%esp)
  80042a:	00 
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	8b 55 08             	mov    0x8(%ebp),%edx
  800432:	89 14 24             	mov    %edx,(%esp)
  800435:	e8 83 fe ff ff       	call   8002bd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cb fe ff ff       	jmp    80030d <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800446:	c7 44 24 08 90 0f 80 	movl   $0x800f90,0x8(%esp)
  80044d:	00 
  80044e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800452:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800455:	89 0c 24             	mov    %ecx,(%esp)
  800458:	e8 60 fe ff ff       	call   8002bd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800460:	e9 a8 fe ff ff       	jmp    80030d <vprintfmt+0x28>
  800465:	89 f9                	mov    %edi,%ecx
  800467:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800478:	85 c0                	test   %eax,%eax
  80047a:	75 07                	jne    800483 <vprintfmt+0x19e>
				p = "(null)";
  80047c:	c7 45 d4 80 0f 80 00 	movl   $0x800f80,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800483:	85 f6                	test   %esi,%esi
  800485:	7e 3b                	jle    8004c2 <vprintfmt+0x1dd>
  800487:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048b:	74 35                	je     8004c2 <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800491:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 a4 02 00 00       	call   800740 <strnlen>
  80049c:	29 c6                	sub    %eax,%esi
  80049e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004a1:	85 f6                	test   %esi,%esi
  8004a3:	7e 1d                	jle    8004c2 <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004a5:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004a9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b3:	89 34 24             	mov    %esi,(%esp)
  8004b6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	4f                   	dec    %edi
  8004ba:	75 f3                	jne    8004af <vprintfmt+0x1ca>
  8004bc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004bf:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c5:	0f be 02             	movsbl (%edx),%eax
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	75 43                	jne    80050f <vprintfmt+0x22a>
  8004cc:	eb 33                	jmp    800501 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d2:	74 18                	je     8004ec <vprintfmt+0x207>
  8004d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004d7:	83 fa 5e             	cmp    $0x5e,%edx
  8004da:	76 10                	jbe    8004ec <vprintfmt+0x207>
					putch('?', putdat);
  8004dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e7:	ff 55 08             	call   *0x8(%ebp)
  8004ea:	eb 0a                	jmp    8004f6 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f9:	0f be 06             	movsbl (%esi),%eax
  8004fc:	46                   	inc    %esi
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	75 12                	jne    800513 <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800501:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800505:	7f 15                	jg     80051c <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 fe fd ff ff       	jmp    80030d <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800512:	46                   	inc    %esi
  800513:	85 ff                	test   %edi,%edi
  800515:	78 b7                	js     8004ce <vprintfmt+0x1e9>
  800517:	4f                   	dec    %edi
  800518:	79 b4                	jns    8004ce <vprintfmt+0x1e9>
  80051a:	eb e5                	jmp    800501 <vprintfmt+0x21c>
  80051c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80051f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800522:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800526:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80052d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052f:	4e                   	dec    %esi
  800530:	75 f0                	jne    800522 <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800535:	e9 d3 fd ff ff       	jmp    80030d <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053a:	83 f9 01             	cmp    $0x1,%ecx
  80053d:	7e 10                	jle    80054f <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 08             	lea    0x8(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
  80054a:	8b 78 04             	mov    0x4(%eax),%edi
  80054d:	eb 26                	jmp    800575 <vprintfmt+0x290>
	else if (lflag)
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	74 12                	je     800565 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 50 04             	lea    0x4(%eax),%edx
  800559:	89 55 14             	mov    %edx,0x14(%ebp)
  80055c:	8b 30                	mov    (%eax),%esi
  80055e:	89 f7                	mov    %esi,%edi
  800560:	c1 ff 1f             	sar    $0x1f,%edi
  800563:	eb 10                	jmp    800575 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 30                	mov    (%eax),%esi
  800570:	89 f7                	mov    %esi,%edi
  800572:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800575:	85 ff                	test   %edi,%edi
  800577:	78 0e                	js     800587 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800579:	89 f0                	mov    %esi,%eax
  80057b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057d:	be 0a 00 00 00       	mov    $0xa,%esi
  800582:	e9 a8 00 00 00       	jmp    80062f <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800587:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800592:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800595:	89 f0                	mov    %esi,%eax
  800597:	89 fa                	mov    %edi,%edx
  800599:	f7 d8                	neg    %eax
  80059b:	83 d2 00             	adc    $0x0,%edx
  80059e:	f7 da                	neg    %edx
			}
			base = 10;
  8005a0:	be 0a 00 00 00       	mov    $0xa,%esi
  8005a5:	e9 85 00 00 00       	jmp    80062f <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005aa:	89 ca                	mov    %ecx,%edx
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8005af:	e8 b5 fc ff ff       	call   800269 <getuint>
			base = 10;
  8005b4:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005b9:	eb 74                	jmp    80062f <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bf:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005d4:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005db:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005e2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005e8:	e9 20 fd ff ff       	jmp    80030d <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 50 04             	lea    0x4(%eax),%edx
  80060f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800612:	8b 00                	mov    (%eax),%eax
  800614:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800619:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80061e:	eb 0f                	jmp    80062f <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 3f fc ff ff       	call   800269 <getuint>
			base = 16;
  80062a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062f:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800633:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800637:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80063a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80063e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	89 54 24 04          	mov    %edx,0x4(%esp)
  800649:	89 da                	mov    %ebx,%edx
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	e8 41 fb ff ff       	call   800194 <printnum>
			break;
  800653:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800656:	e9 b2 fc ff ff       	jmp    80030d <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	89 14 24             	mov    %edx,(%esp)
  800662:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800668:	e9 a0 fc ff ff       	jmp    80030d <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800671:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067f:	0f 84 88 fc ff ff    	je     80030d <vprintfmt+0x28>
  800685:	4e                   	dec    %esi
  800686:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068a:	75 f9                	jne    800685 <vprintfmt+0x3a0>
  80068c:	e9 7c fc ff ff       	jmp    80030d <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  800691:	83 c4 4c             	add    $0x4c,%esp
  800694:	5b                   	pop    %ebx
  800695:	5e                   	pop    %esi
  800696:	5f                   	pop    %edi
  800697:	5d                   	pop    %ebp
  800698:	c3                   	ret    

00800699 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	83 ec 28             	sub    $0x28,%esp
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b6:	85 c0                	test   %eax,%eax
  8006b8:	74 30                	je     8006ea <vsnprintf+0x51>
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	7e 33                	jle    8006f1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	c7 04 24 a3 02 80 00 	movl   $0x8002a3,(%esp)
  8006da:	e8 06 fc ff ff       	call   8002e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e8:	eb 0c                	jmp    8006f6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ef:	eb 05                	jmp    8006f6 <vsnprintf+0x5d>
  8006f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800701:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800705:	8b 45 10             	mov    0x10(%ebp),%eax
  800708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	e8 7b ff ff ff       	call   800699 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	80 3a 00             	cmpb   $0x0,(%edx)
  800729:	74 0e                	je     800739 <strlen+0x19>
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800730:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800735:	75 f9                	jne    800730 <strlen+0x10>
  800737:	eb 05                	jmp    80073e <strlen+0x1e>
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074a:	85 c9                	test   %ecx,%ecx
  80074c:	74 1a                	je     800768 <strnlen+0x28>
  80074e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800751:	74 1c                	je     80076f <strnlen+0x2f>
  800753:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800758:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	39 ca                	cmp    %ecx,%edx
  80075c:	74 16                	je     800774 <strnlen+0x34>
  80075e:	42                   	inc    %edx
  80075f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800764:	75 f2                	jne    800758 <strnlen+0x18>
  800766:	eb 0c                	jmp    800774 <strnlen+0x34>
  800768:	b8 00 00 00 00       	mov    $0x0,%eax
  80076d:	eb 05                	jmp    800774 <strnlen+0x34>
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800789:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80078c:	42                   	inc    %edx
  80078d:	84 c9                	test   %cl,%cl
  80078f:	75 f5                	jne    800786 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	89 1c 24             	mov    %ebx,(%esp)
  8007a1:	e8 7a ff ff ff       	call   800720 <strlen>
	strcpy(dst + len, src);
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 c0 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b7:	89 d8                	mov    %ebx,%eax
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	5b                   	pop    %ebx
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	85 f6                	test   %esi,%esi
  8007cf:	74 15                	je     8007e6 <strncpy+0x27>
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007d6:	8a 1a                	mov    (%edx),%bl
  8007d8:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007db:	80 3a 01             	cmpb   $0x1,(%edx)
  8007de:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	41                   	inc    %ecx
  8007e2:	39 f1                	cmp    %esi,%ecx
  8007e4:	75 f0                	jne    8007d6 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	57                   	push   %edi
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f6:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f9:	85 f6                	test   %esi,%esi
  8007fb:	74 31                	je     80082e <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  8007fd:	83 fe 01             	cmp    $0x1,%esi
  800800:	74 21                	je     800823 <strlcpy+0x39>
  800802:	8a 0b                	mov    (%ebx),%cl
  800804:	84 c9                	test   %cl,%cl
  800806:	74 1f                	je     800827 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800808:	83 ee 02             	sub    $0x2,%esi
  80080b:	89 f8                	mov    %edi,%eax
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	88 08                	mov    %cl,(%eax)
  800814:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800815:	39 f2                	cmp    %esi,%edx
  800817:	74 10                	je     800829 <strlcpy+0x3f>
  800819:	42                   	inc    %edx
  80081a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80081d:	84 c9                	test   %cl,%cl
  80081f:	75 f1                	jne    800812 <strlcpy+0x28>
  800821:	eb 06                	jmp    800829 <strlcpy+0x3f>
  800823:	89 f8                	mov    %edi,%eax
  800825:	eb 02                	jmp    800829 <strlcpy+0x3f>
  800827:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
  80082c:	eb 02                	jmp    800830 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800830:	29 f8                	sub    %edi,%eax
}
  800832:	5b                   	pop    %ebx
  800833:	5e                   	pop    %esi
  800834:	5f                   	pop    %edi
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800840:	8a 01                	mov    (%ecx),%al
  800842:	84 c0                	test   %al,%al
  800844:	74 11                	je     800857 <strcmp+0x20>
  800846:	3a 02                	cmp    (%edx),%al
  800848:	75 0d                	jne    800857 <strcmp+0x20>
		p++, q++;
  80084a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084b:	8a 41 01             	mov    0x1(%ecx),%al
  80084e:	84 c0                	test   %al,%al
  800850:	74 05                	je     800857 <strcmp+0x20>
  800852:	41                   	inc    %ecx
  800853:	3a 02                	cmp    (%edx),%al
  800855:	74 f3                	je     80084a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 55 08             	mov    0x8(%ebp),%edx
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 1b                	je     80088d <strncmp+0x2c>
  800872:	8a 1a                	mov    (%edx),%bl
  800874:	84 db                	test   %bl,%bl
  800876:	74 24                	je     80089c <strncmp+0x3b>
  800878:	3a 19                	cmp    (%ecx),%bl
  80087a:	75 20                	jne    80089c <strncmp+0x3b>
  80087c:	48                   	dec    %eax
  80087d:	74 15                	je     800894 <strncmp+0x33>
		n--, p++, q++;
  80087f:	42                   	inc    %edx
  800880:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	8a 1a                	mov    (%edx),%bl
  800883:	84 db                	test   %bl,%bl
  800885:	74 15                	je     80089c <strncmp+0x3b>
  800887:	3a 19                	cmp    (%ecx),%bl
  800889:	74 f1                	je     80087c <strncmp+0x1b>
  80088b:	eb 0f                	jmp    80089c <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 05                	jmp    800899 <strncmp+0x38>
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800899:	5b                   	pop    %ebx
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089c:	0f b6 02             	movzbl (%edx),%eax
  80089f:	0f b6 11             	movzbl (%ecx),%edx
  8008a2:	29 d0                	sub    %edx,%eax
  8008a4:	eb f3                	jmp    800899 <strncmp+0x38>

008008a6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008af:	8a 10                	mov    (%eax),%dl
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	74 19                	je     8008ce <strchr+0x28>
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	75 07                	jne    8008c0 <strchr+0x1a>
  8008b9:	eb 18                	jmp    8008d3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bb:	40                   	inc    %eax
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 13                	je     8008d3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c0:	8a 50 01             	mov    0x1(%eax),%dl
  8008c3:	84 d2                	test   %dl,%dl
  8008c5:	75 f4                	jne    8008bb <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	eb 05                	jmp    8008d3 <strchr+0x2d>
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008de:	8a 10                	mov    (%eax),%dl
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	74 11                	je     8008f5 <strfind+0x20>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	75 06                	jne    8008ee <strfind+0x19>
  8008e8:	eb 0b                	jmp    8008f5 <strfind+0x20>
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 07                	je     8008f5 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	8a 10                	mov    (%eax),%dl
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f5                	jne    8008ea <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800906:	85 c9                	test   %ecx,%ecx
  800908:	74 30                	je     80093a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800910:	75 25                	jne    800937 <memset+0x40>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 20                	jne    800937 <memset+0x40>
		c &= 0xFF;
  800917:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091a:	89 d3                	mov    %edx,%ebx
  80091c:	c1 e3 08             	shl    $0x8,%ebx
  80091f:	89 d6                	mov    %edx,%esi
  800921:	c1 e6 18             	shl    $0x18,%esi
  800924:	89 d0                	mov    %edx,%eax
  800926:	c1 e0 10             	shl    $0x10,%eax
  800929:	09 f0                	or     %esi,%eax
  80092b:	09 d0                	or     %edx,%eax
  80092d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800932:	fc                   	cld    
  800933:	f3 ab                	rep stos %eax,%es:(%edi)
  800935:	eb 03                	jmp    80093a <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800937:	fc                   	cld    
  800938:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093a:	89 f8                	mov    %edi,%eax
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094f:	39 c6                	cmp    %eax,%esi
  800951:	73 34                	jae    800987 <memmove+0x46>
  800953:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800956:	39 d0                	cmp    %edx,%eax
  800958:	73 2d                	jae    800987 <memmove+0x46>
		s += n;
		d += n;
  80095a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095d:	f6 c2 03             	test   $0x3,%dl
  800960:	75 1b                	jne    80097d <memmove+0x3c>
  800962:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800968:	75 13                	jne    80097d <memmove+0x3c>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0e                	jne    80097d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096f:	83 ef 04             	sub    $0x4,%edi
  800972:	8d 72 fc             	lea    -0x4(%edx),%esi
  800975:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800978:	fd                   	std    
  800979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097b:	eb 07                	jmp    800984 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097d:	4f                   	dec    %edi
  80097e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800981:	fd                   	std    
  800982:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800984:	fc                   	cld    
  800985:	eb 20                	jmp    8009a7 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800987:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098d:	75 13                	jne    8009a2 <memmove+0x61>
  80098f:	a8 03                	test   $0x3,%al
  800991:	75 0f                	jne    8009a2 <memmove+0x61>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 0a                	jne    8009a2 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800998:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	fc                   	cld    
  80099e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a0:	eb 05                	jmp    8009a7 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 77 ff ff ff       	call   800941 <memmove>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	85 ff                	test   %edi,%edi
  8009dd:	74 31                	je     800a10 <memcmp+0x44>
		if (*s1 != *s2)
  8009df:	8a 03                	mov    (%ebx),%al
  8009e1:	8a 0e                	mov    (%esi),%cl
  8009e3:	38 c8                	cmp    %cl,%al
  8009e5:	74 18                	je     8009ff <memcmp+0x33>
  8009e7:	eb 0c                	jmp    8009f5 <memcmp+0x29>
  8009e9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009ed:	42                   	inc    %edx
  8009ee:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  8009f1:	38 c8                	cmp    %cl,%al
  8009f3:	74 10                	je     800a05 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  8009f5:	0f b6 c0             	movzbl %al,%eax
  8009f8:	0f b6 c9             	movzbl %cl,%ecx
  8009fb:	29 c8                	sub    %ecx,%eax
  8009fd:	eb 16                	jmp    800a15 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	4f                   	dec    %edi
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	39 fa                	cmp    %edi,%edx
  800a07:	75 e0                	jne    8009e9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0e:	eb 05                	jmp    800a15 <memcmp+0x49>
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5f                   	pop    %edi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 12                	jae    800a3b <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a2c:	38 08                	cmp    %cl,(%eax)
  800a2e:	75 06                	jne    800a36 <memfind+0x1c>
  800a30:	eb 09                	jmp    800a3b <memfind+0x21>
  800a32:	38 08                	cmp    %cl,(%eax)
  800a34:	74 05                	je     800a3b <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a36:	40                   	inc    %eax
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	75 f7                	jne    800a32 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
  800a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a49:	eb 01                	jmp    800a4c <strtol+0xf>
		s++;
  800a4b:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4c:	8a 02                	mov    (%edx),%al
  800a4e:	3c 20                	cmp    $0x20,%al
  800a50:	74 f9                	je     800a4b <strtol+0xe>
  800a52:	3c 09                	cmp    $0x9,%al
  800a54:	74 f5                	je     800a4b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a56:	3c 2b                	cmp    $0x2b,%al
  800a58:	75 08                	jne    800a62 <strtol+0x25>
		s++;
  800a5a:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a60:	eb 13                	jmp    800a75 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a62:	3c 2d                	cmp    $0x2d,%al
  800a64:	75 0a                	jne    800a70 <strtol+0x33>
		s++, neg = 1;
  800a66:	8d 52 01             	lea    0x1(%edx),%edx
  800a69:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6e:	eb 05                	jmp    800a75 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a75:	85 db                	test   %ebx,%ebx
  800a77:	74 05                	je     800a7e <strtol+0x41>
  800a79:	83 fb 10             	cmp    $0x10,%ebx
  800a7c:	75 28                	jne    800aa6 <strtol+0x69>
  800a7e:	8a 02                	mov    (%edx),%al
  800a80:	3c 30                	cmp    $0x30,%al
  800a82:	75 10                	jne    800a94 <strtol+0x57>
  800a84:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a88:	75 0a                	jne    800a94 <strtol+0x57>
		s += 2, base = 16;
  800a8a:	83 c2 02             	add    $0x2,%edx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb 12                	jmp    800aa6 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	75 0e                	jne    800aa6 <strtol+0x69>
  800a98:	3c 30                	cmp    $0x30,%al
  800a9a:	75 05                	jne    800aa1 <strtol+0x64>
		s++, base = 8;
  800a9c:	42                   	inc    %edx
  800a9d:	b3 08                	mov    $0x8,%bl
  800a9f:	eb 05                	jmp    800aa6 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aad:	8a 0a                	mov    (%edx),%cl
  800aaf:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab2:	80 fb 09             	cmp    $0x9,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x82>
			dig = *s - '0';
  800ab7:	0f be c9             	movsbl %cl,%ecx
  800aba:	83 e9 30             	sub    $0x30,%ecx
  800abd:	eb 1e                	jmp    800add <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800abf:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 08                	ja     800acf <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac7:	0f be c9             	movsbl %cl,%ecx
  800aca:	83 e9 57             	sub    $0x57,%ecx
  800acd:	eb 0e                	jmp    800add <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800acf:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad2:	80 fb 19             	cmp    $0x19,%bl
  800ad5:	77 12                	ja     800ae9 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ad7:	0f be c9             	movsbl %cl,%ecx
  800ada:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800add:	39 f1                	cmp    %esi,%ecx
  800adf:	7d 0c                	jge    800aed <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ae1:	42                   	inc    %edx
  800ae2:	0f af c6             	imul   %esi,%eax
  800ae5:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ae7:	eb c4                	jmp    800aad <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae9:	89 c1                	mov    %eax,%ecx
  800aeb:	eb 02                	jmp    800aef <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aed:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 05                	je     800afa <strtol+0xbd>
		*endptr = (char *) s;
  800af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af8:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800afa:	85 ff                	test   %edi,%edi
  800afc:	74 04                	je     800b02 <strtol+0xc5>
  800afe:	89 c8                	mov    %ecx,%eax
  800b00:	f7 d8                	neg    %eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
	...

00800b08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	51                   	push   %ecx
  800b1d:	52                   	push   %edx
  800b1e:	53                   	push   %ebx
  800b1f:	54                   	push   %esp
  800b20:	55                   	push   %ebp
  800b21:	56                   	push   %esi
  800b22:	57                   	push   %edi
  800b23:	8d 35 2d 0b 80 00    	lea    0x800b2d,%esi
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	0f 34                	sysenter 

00800b2d <after_sysenter_label16>:
  800b2d:	5f                   	pop    %edi
  800b2e:	5e                   	pop    %esi
  800b2f:	5d                   	pop    %ebp
  800b30:	5c                   	pop    %esp
  800b31:	5b                   	pop    %ebx
  800b32:	5a                   	pop    %edx
  800b33:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	89 d1                	mov    %edx,%ecx
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	89 d7                	mov    %edx,%edi
  800b4d:	51                   	push   %ecx
  800b4e:	52                   	push   %edx
  800b4f:	53                   	push   %ebx
  800b50:	54                   	push   %esp
  800b51:	55                   	push   %ebp
  800b52:	56                   	push   %esi
  800b53:	57                   	push   %edi
  800b54:	8d 35 5e 0b 80 00    	lea    0x800b5e,%esi
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	0f 34                	sysenter 

00800b5e <after_sysenter_label41>:
  800b5e:	5f                   	pop    %edi
  800b5f:	5e                   	pop    %esi
  800b60:	5d                   	pop    %ebp
  800b61:	5c                   	pop    %esp
  800b62:	5b                   	pop    %ebx
  800b63:	5a                   	pop    %edx
  800b64:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b76:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	89 cb                	mov    %ecx,%ebx
  800b80:	89 cf                	mov    %ecx,%edi
  800b82:	51                   	push   %ecx
  800b83:	52                   	push   %edx
  800b84:	53                   	push   %ebx
  800b85:	54                   	push   %esp
  800b86:	55                   	push   %ebp
  800b87:	56                   	push   %esi
  800b88:	57                   	push   %edi
  800b89:	8d 35 93 0b 80 00    	lea    0x800b93,%esi
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	0f 34                	sysenter 

00800b93 <after_sysenter_label68>:
  800b93:	5f                   	pop    %edi
  800b94:	5e                   	pop    %esi
  800b95:	5d                   	pop    %ebp
  800b96:	5c                   	pop    %esp
  800b97:	5b                   	pop    %ebx
  800b98:	5a                   	pop    %edx
  800b99:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 28                	jle    800bc6 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba9:	00 
  800baa:	c7 44 24 08 70 11 80 	movl   $0x801170,0x8(%esp)
  800bb1:	00 
  800bb2:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800bb9:	00 
  800bba:	c7 04 24 8d 11 80 00 	movl   $0x80118d,(%esp)
  800bc1:	e8 9e 00 00 00       	call   800c64 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc6:	83 c4 20             	add    $0x20,%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	51                   	push   %ecx
  800be3:	52                   	push   %edx
  800be4:	53                   	push   %ebx
  800be5:	54                   	push   %esp
  800be6:	55                   	push   %ebp
  800be7:	56                   	push   %esi
  800be8:	57                   	push   %edi
  800be9:	8d 35 f3 0b 80 00    	lea    0x800bf3,%esi
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	0f 34                	sysenter 

00800bf3 <after_sysenter_label107>:
  800bf3:	5f                   	pop    %edi
  800bf4:	5e                   	pop    %esi
  800bf5:	5d                   	pop    %ebp
  800bf6:	5c                   	pop    %esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5a                   	pop    %edx
  800bf9:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c08:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	89 df                	mov    %ebx,%edi
  800c15:	51                   	push   %ecx
  800c16:	52                   	push   %edx
  800c17:	53                   	push   %ebx
  800c18:	54                   	push   %esp
  800c19:	55                   	push   %ebp
  800c1a:	56                   	push   %esi
  800c1b:	57                   	push   %edi
  800c1c:	8d 35 26 0c 80 00    	lea    0x800c26,%esi
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	0f 34                	sysenter 

00800c26 <after_sysenter_label133>:
  800c26:	5f                   	pop    %edi
  800c27:	5e                   	pop    %esi
  800c28:	5d                   	pop    %ebp
  800c29:	5c                   	pop    %esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5a                   	pop    %edx
  800c2c:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	51                   	push   %ecx
  800c48:	52                   	push   %edx
  800c49:	53                   	push   %ebx
  800c4a:	54                   	push   %esp
  800c4b:	55                   	push   %ebp
  800c4c:	56                   	push   %esi
  800c4d:	57                   	push   %edi
  800c4e:	8d 35 58 0c 80 00    	lea    0x800c58,%esi
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	0f 34                	sysenter 

00800c58 <after_sysenter_label159>:
  800c58:	5f                   	pop    %edi
  800c59:	5e                   	pop    %esi
  800c5a:	5d                   	pop    %ebp
  800c5b:	5c                   	pop    %esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5a                   	pop    %edx
  800c5e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    
	...

00800c64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c6c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c6f:	a1 08 20 80 00       	mov    0x802008,%eax
  800c74:	85 c0                	test   %eax,%eax
  800c76:	74 10                	je     800c88 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7c:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  800c83:	e8 f0 f4 ff ff       	call   800178 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c88:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c8e:	e8 3a ff ff ff       	call   800bcd <sys_getenvid>
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c96:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ca1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca9:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  800cb0:	e8 c3 f4 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbc:	89 04 24             	mov    %eax,(%esp)
  800cbf:	e8 53 f4 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  800cc4:	c7 04 24 40 0f 80 00 	movl   $0x800f40,(%esp)
  800ccb:	e8 a8 f4 ff ff       	call   800178 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cd0:	cc                   	int3   
  800cd1:	eb fd                	jmp    800cd0 <_panic+0x6c>
	...

00800cd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cd4:	55                   	push   %ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	83 ec 10             	sub    $0x10,%esp
  800cda:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cde:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ce2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800cea:	89 cd                	mov    %ecx,%ebp
  800cec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	75 2c                	jne    800d20 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cf4:	39 f9                	cmp    %edi,%ecx
  800cf6:	77 68                	ja     800d60 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf8:	85 c9                	test   %ecx,%ecx
  800cfa:	75 0b                	jne    800d07 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800d01:	31 d2                	xor    %edx,%edx
  800d03:	f7 f1                	div    %ecx
  800d05:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d07:	31 d2                	xor    %edx,%edx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	f7 f1                	div    %ecx
  800d0d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0f:	89 f0                	mov    %esi,%eax
  800d11:	f7 f1                	div    %ecx
  800d13:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d15:	89 f0                	mov    %esi,%eax
  800d17:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d19:	83 c4 10             	add    $0x10,%esp
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d20:	39 f8                	cmp    %edi,%eax
  800d22:	77 2c                	ja     800d50 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d24:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d27:	83 f6 1f             	xor    $0x1f,%esi
  800d2a:	75 4c                	jne    800d78 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d2c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d2e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d33:	72 0a                	jb     800d3f <__udivdi3+0x6b>
  800d35:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d39:	0f 87 ad 00 00 00    	ja     800dec <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d3f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d44:	89 f0                	mov    %esi,%eax
  800d46:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d48:	83 c4 10             	add    $0x10,%esp
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    
  800d4f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d50:	31 ff                	xor    %edi,%edi
  800d52:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d60:	89 fa                	mov    %edi,%edx
  800d62:	89 f0                	mov    %esi,%eax
  800d64:	f7 f1                	div    %ecx
  800d66:	89 c6                	mov    %eax,%esi
  800d68:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d6a:	89 f0                	mov    %esi,%eax
  800d6c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d78:	89 f1                	mov    %esi,%ecx
  800d7a:	d3 e0                	shl    %cl,%eax
  800d7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d80:	b8 20 00 00 00       	mov    $0x20,%eax
  800d85:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d87:	89 ea                	mov    %ebp,%edx
  800d89:	88 c1                	mov    %al,%cl
  800d8b:	d3 ea                	shr    %cl,%edx
  800d8d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800d91:	09 ca                	or     %ecx,%edx
  800d93:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800d97:	89 f1                	mov    %esi,%ecx
  800d99:	d3 e5                	shl    %cl,%ebp
  800d9b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800d9f:	89 fd                	mov    %edi,%ebp
  800da1:	88 c1                	mov    %al,%cl
  800da3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800da5:	89 fa                	mov    %edi,%edx
  800da7:	89 f1                	mov    %esi,%ecx
  800da9:	d3 e2                	shl    %cl,%edx
  800dab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800daf:	88 c1                	mov    %al,%cl
  800db1:	d3 ef                	shr    %cl,%edi
  800db3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800db5:	89 f8                	mov    %edi,%eax
  800db7:	89 ea                	mov    %ebp,%edx
  800db9:	f7 74 24 08          	divl   0x8(%esp)
  800dbd:	89 d1                	mov    %edx,%ecx
  800dbf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800dc1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc5:	39 d1                	cmp    %edx,%ecx
  800dc7:	72 17                	jb     800de0 <__udivdi3+0x10c>
  800dc9:	74 09                	je     800dd4 <__udivdi3+0x100>
  800dcb:	89 fe                	mov    %edi,%esi
  800dcd:	31 ff                	xor    %edi,%edi
  800dcf:	e9 41 ff ff ff       	jmp    800d15 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dd4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dd8:	89 f1                	mov    %esi,%ecx
  800dda:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ddc:	39 c2                	cmp    %eax,%edx
  800dde:	73 eb                	jae    800dcb <__udivdi3+0xf7>
		{
		  q0--;
  800de0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de3:	31 ff                	xor    %edi,%edi
  800de5:	e9 2b ff ff ff       	jmp    800d15 <__udivdi3+0x41>
  800dea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dec:	31 f6                	xor    %esi,%esi
  800dee:	e9 22 ff ff ff       	jmp    800d15 <__udivdi3+0x41>
	...

00800df4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	83 ec 20             	sub    $0x20,%esp
  800dfa:	8b 44 24 30          	mov    0x30(%esp),%eax
  800dfe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e02:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e06:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e0a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e0e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e12:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e14:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e16:	85 ed                	test   %ebp,%ebp
  800e18:	75 16                	jne    800e30 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e1a:	39 f1                	cmp    %esi,%ecx
  800e1c:	0f 86 a6 00 00 00    	jbe    800ec8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e22:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e24:	89 d0                	mov    %edx,%eax
  800e26:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e28:	83 c4 20             	add    $0x20,%esp
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    
  800e2f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e30:	39 f5                	cmp    %esi,%ebp
  800e32:	0f 87 ac 00 00 00    	ja     800ee4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e38:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e3b:	83 f0 1f             	xor    $0x1f,%eax
  800e3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e42:	0f 84 a8 00 00 00    	je     800ef0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e48:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e4c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e4e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e53:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e57:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e5b:	89 f9                	mov    %edi,%ecx
  800e5d:	d3 e8                	shr    %cl,%eax
  800e5f:	09 e8                	or     %ebp,%eax
  800e61:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e65:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e69:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e6d:	d3 e0                	shl    %cl,%eax
  800e6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e73:	89 f2                	mov    %esi,%edx
  800e75:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e77:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e7b:	d3 e0                	shl    %cl,%eax
  800e7d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e81:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	d3 e8                	shr    %cl,%eax
  800e89:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e8b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e8d:	89 f2                	mov    %esi,%edx
  800e8f:	f7 74 24 18          	divl   0x18(%esp)
  800e93:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e95:	f7 64 24 0c          	mull   0xc(%esp)
  800e99:	89 c5                	mov    %eax,%ebp
  800e9b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e9d:	39 d6                	cmp    %edx,%esi
  800e9f:	72 67                	jb     800f08 <__umoddi3+0x114>
  800ea1:	74 75                	je     800f18 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ea3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ea7:	29 e8                	sub    %ebp,%eax
  800ea9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800eab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eaf:	d3 e8                	shr    %cl,%eax
  800eb1:	89 f2                	mov    %esi,%edx
  800eb3:	89 f9                	mov    %edi,%ecx
  800eb5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800eb7:	09 d0                	or     %edx,%eax
  800eb9:	89 f2                	mov    %esi,%edx
  800ebb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ebf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec1:	83 c4 20             	add    $0x20,%esp
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ec8:	85 c9                	test   %ecx,%ecx
  800eca:	75 0b                	jne    800ed7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ecc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed1:	31 d2                	xor    %edx,%edx
  800ed3:	f7 f1                	div    %ecx
  800ed5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ed7:	89 f0                	mov    %esi,%eax
  800ed9:	31 d2                	xor    %edx,%edx
  800edb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800edd:	89 f8                	mov    %edi,%eax
  800edf:	e9 3e ff ff ff       	jmp    800e22 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ee4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee6:	83 c4 20             	add    $0x20,%esp
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    
  800eed:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ef0:	39 f5                	cmp    %esi,%ebp
  800ef2:	72 04                	jb     800ef8 <__umoddi3+0x104>
  800ef4:	39 f9                	cmp    %edi,%ecx
  800ef6:	77 06                	ja     800efe <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef8:	89 f2                	mov    %esi,%edx
  800efa:	29 cf                	sub    %ecx,%edi
  800efc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800efe:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    
  800f07:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f08:	89 d1                	mov    %edx,%ecx
  800f0a:	89 c5                	mov    %eax,%ebp
  800f0c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f10:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f14:	eb 8d                	jmp    800ea3 <__umoddi3+0xaf>
  800f16:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f18:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f1c:	72 ea                	jb     800f08 <__umoddi3+0x114>
  800f1e:	89 f1                	mov    %esi,%ecx
  800f20:	eb 81                	jmp    800ea3 <__umoddi3+0xaf>
