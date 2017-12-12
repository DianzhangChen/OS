
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 66 0b 00 00       	call   800bbd <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80005f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800062:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80006e:	c7 04 24 14 0f 80 00 	movl   $0x800f14,(%esp)
  800075:	e8 ee 00 00 00       	call   800168 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  80007a:	a1 04 20 80 00       	mov    0x802004,%eax
  80007f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800083:	c7 04 24 24 0f 80 00 	movl   $0x800f24,(%esp)
  80008a:	e8 d9 00 00 00       	call   800168 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 f6                	test   %esi,%esi
  800091:	7e 07                	jle    80009a <libmain+0x56>
		binaryname = argv[0];
  800093:	8b 03                	mov    (%ebx),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009e:	89 34 24             	mov    %esi,(%esp)
  8000a1:	e8 8e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 09 00 00 00       	call   8000b4 <exit>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 93 0a 00 00       	call   800b59 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 00 0a 00 00       	call   800af8 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	ff 43 04             	incl   0x4(%ebx)
}
  800101:	83 c4 14             	add    $0x14,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013c:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800143:	e8 8d 01 00 00       	call   8002d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800158:	89 04 24             	mov    %eax,(%esp)
  80015b:	e8 98 09 00 00       	call   800af8 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 87 ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001ac:	72 0f                	jb     8001bd <printnum+0x39>
  8001ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b4:	76 07                	jbe    8001bd <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b6:	4b                   	dec    %ebx
  8001b7:	85 db                	test   %ebx,%ebx
  8001b9:	7f 4f                	jg     80020a <printnum+0x86>
  8001bb:	eb 5a                	jmp    800217 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c1:	4b                   	dec    %ebx
  8001c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001dc:	00 
  8001dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	e8 d5 0a 00 00       	call   800cc4 <__udivdi3>
  8001ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fe:	89 fa                	mov    %edi,%edx
  800200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800203:	e8 7c ff ff ff       	call   800184 <printnum>
  800208:	eb 0d                	jmp    800217 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020e:	89 34 24             	mov    %esi,(%esp)
  800211:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800214:	4b                   	dec    %ebx
  800215:	75 f3                	jne    80020a <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800217:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021f:	8b 45 10             	mov    0x10(%ebp),%eax
  800222:	89 44 24 08          	mov    %eax,0x8(%esp)
  800226:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022d:	00 
  80022e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800231:	89 04 24             	mov    %eax,(%esp)
  800234:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023b:	e8 a4 0b 00 00       	call   800de4 <__umoddi3>
  800240:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800244:	0f be 80 41 0f 80 00 	movsbl 0x800f41(%eax),%eax
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800251:	83 c4 3c             	add    $0x3c,%esp
  800254:	5b                   	pop    %ebx
  800255:	5e                   	pop    %esi
  800256:	5f                   	pop    %edi
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025c:	83 fa 01             	cmp    $0x1,%edx
  80025f:	7e 0e                	jle    80026f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 08             	lea    0x8(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	8b 52 04             	mov    0x4(%edx),%edx
  80026d:	eb 22                	jmp    800291 <getuint+0x38>
	else if (lflag)
  80026f:	85 d2                	test   %edx,%edx
  800271:	74 10                	je     800283 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 04             	lea    0x4(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	ba 00 00 00 00       	mov    $0x0,%edx
  800281:	eb 0e                	jmp    800291 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 04             	lea    0x4(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800299:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a1:	73 08                	jae    8002ab <sprintputch+0x18>
		*b->buf++ = ch;
  8002a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a6:	88 0a                	mov    %cl,(%edx)
  8002a8:	42                   	inc    %edx
  8002a9:	89 10                	mov    %edx,(%eax)
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 02 00 00 00       	call   8002d5 <vprintfmt>
	va_end(ap);
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 4c             	sub    $0x4c,%esp
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e4:	eb 17                	jmp    8002fd <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	0f 84 93 03 00 00    	je     800681 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	ff 55 08             	call   *0x8(%ebp)
  8002f8:	eb 03                	jmp    8002fd <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	0f b6 06             	movzbl (%esi),%eax
  800300:	46                   	inc    %esi
  800301:	83 f8 25             	cmp    $0x25,%eax
  800304:	75 e0                	jne    8002e6 <vprintfmt+0x11>
  800306:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80030a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800311:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800316:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	eb 26                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800327:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80032b:	eb 1d                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800330:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800334:	eb 14                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800339:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800340:	eb 08                	jmp    80034a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800342:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800345:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	0f b6 16             	movzbl (%esi),%edx
  80034d:	8d 46 01             	lea    0x1(%esi),%eax
  800350:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800353:	8a 06                	mov    (%esi),%al
  800355:	83 e8 23             	sub    $0x23,%eax
  800358:	3c 55                	cmp    $0x55,%al
  80035a:	0f 87 fd 02 00 00    	ja     80065d <vprintfmt+0x388>
  800360:	0f b6 c0             	movzbl %al,%eax
  800363:	ff 24 85 d0 0f 80 00 	jmp    *0x800fd0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036a:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  80036d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800371:	8d 50 d0             	lea    -0x30(%eax),%edx
  800374:	83 fa 09             	cmp    $0x9,%edx
  800377:	77 3f                	ja     8003b8 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80037d:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800380:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800384:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800387:	8d 50 d0             	lea    -0x30(%eax),%edx
  80038a:	83 fa 09             	cmp    $0x9,%edx
  80038d:	76 ed                	jbe    80037c <vprintfmt+0xa7>
  80038f:	eb 2a                	jmp    8003bb <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 50 04             	lea    0x4(%eax),%edx
  800397:	89 55 14             	mov    %edx,0x14(%ebp)
  80039a:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039f:	eb 1a                	jmp    8003bb <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a5:	78 8f                	js     800336 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003aa:	eb 9e                	jmp    80034a <vprintfmt+0x75>
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003af:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003b6:	eb 92                	jmp    80034a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bf:	79 89                	jns    80034a <vprintfmt+0x75>
  8003c1:	e9 7c ff ff ff       	jmp    800342 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ca:	e9 7b ff ff ff       	jmp    80034a <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 50 04             	lea    0x4(%eax),%edx
  8003d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e7:	e9 11 ff ff ff       	jmp    8002fd <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	79 02                	jns    8003fd <vprintfmt+0x128>
  8003fb:	f7 d8                	neg    %eax
  8003fd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 06             	cmp    $0x6,%eax
  800402:	7f 0b                	jg     80040f <vprintfmt+0x13a>
  800404:	8b 04 85 28 11 80 00 	mov    0x801128(,%eax,4),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	75 23                	jne    800432 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80040f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800413:	c7 44 24 08 59 0f 80 	movl   $0x800f59,0x8(%esp)
  80041a:	00 
  80041b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041f:	8b 55 08             	mov    0x8(%ebp),%edx
  800422:	89 14 24             	mov    %edx,(%esp)
  800425:	e8 83 fe ff ff       	call   8002ad <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042d:	e9 cb fe ff ff       	jmp    8002fd <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	c7 44 24 08 62 0f 80 	movl   $0x800f62,0x8(%esp)
  80043d:	00 
  80043e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800442:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800445:	89 0c 24             	mov    %ecx,(%esp)
  800448:	e8 60 fe ff ff       	call   8002ad <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800450:	e9 a8 fe ff ff       	jmp    8002fd <vprintfmt+0x28>
  800455:	89 f9                	mov    %edi,%ecx
  800457:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 00                	mov    (%eax),%eax
  800465:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800468:	85 c0                	test   %eax,%eax
  80046a:	75 07                	jne    800473 <vprintfmt+0x19e>
				p = "(null)";
  80046c:	c7 45 d4 52 0f 80 00 	movl   $0x800f52,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800473:	85 f6                	test   %esi,%esi
  800475:	7e 3b                	jle    8004b2 <vprintfmt+0x1dd>
  800477:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80047b:	74 35                	je     8004b2 <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	e8 a4 02 00 00       	call   800730 <strnlen>
  80048c:	29 c6                	sub    %eax,%esi
  80048e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800491:	85 f6                	test   %esi,%esi
  800493:	7e 1d                	jle    8004b2 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800495:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800499:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	89 34 24             	mov    %esi,(%esp)
  8004a6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	4f                   	dec    %edi
  8004aa:	75 f3                	jne    80049f <vprintfmt+0x1ca>
  8004ac:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004af:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b5:	0f be 02             	movsbl (%edx),%eax
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	75 43                	jne    8004ff <vprintfmt+0x22a>
  8004bc:	eb 33                	jmp    8004f1 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c2:	74 18                	je     8004dc <vprintfmt+0x207>
  8004c4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ca:	76 10                	jbe    8004dc <vprintfmt+0x207>
					putch('?', putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	eb 0a                	jmp    8004e6 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e9:	0f be 06             	movsbl (%esi),%eax
  8004ec:	46                   	inc    %esi
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	75 12                	jne    800503 <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f5:	7f 15                	jg     80050c <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fa:	e9 fe fd ff ff       	jmp    8002fd <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800502:	46                   	inc    %esi
  800503:	85 ff                	test   %edi,%edi
  800505:	78 b7                	js     8004be <vprintfmt+0x1e9>
  800507:	4f                   	dec    %edi
  800508:	79 b4                	jns    8004be <vprintfmt+0x1e9>
  80050a:	eb e5                	jmp    8004f1 <vprintfmt+0x21c>
  80050c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80050f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800516:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80051d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051f:	4e                   	dec    %esi
  800520:	75 f0                	jne    800512 <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800525:	e9 d3 fd ff ff       	jmp    8002fd <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052a:	83 f9 01             	cmp    $0x1,%ecx
  80052d:	7e 10                	jle    80053f <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 08             	lea    0x8(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 30                	mov    (%eax),%esi
  80053a:	8b 78 04             	mov    0x4(%eax),%edi
  80053d:	eb 26                	jmp    800565 <vprintfmt+0x290>
	else if (lflag)
  80053f:	85 c9                	test   %ecx,%ecx
  800541:	74 12                	je     800555 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 30                	mov    (%eax),%esi
  80054e:	89 f7                	mov    %esi,%edi
  800550:	c1 ff 1f             	sar    $0x1f,%edi
  800553:	eb 10                	jmp    800565 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 30                	mov    (%eax),%esi
  800560:	89 f7                	mov    %esi,%edi
  800562:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800565:	85 ff                	test   %edi,%edi
  800567:	78 0e                	js     800577 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800569:	89 f0                	mov    %esi,%eax
  80056b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056d:	be 0a 00 00 00       	mov    $0xa,%esi
  800572:	e9 a8 00 00 00       	jmp    80061f <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800577:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800582:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800585:	89 f0                	mov    %esi,%eax
  800587:	89 fa                	mov    %edi,%edx
  800589:	f7 d8                	neg    %eax
  80058b:	83 d2 00             	adc    $0x0,%edx
  80058e:	f7 da                	neg    %edx
			}
			base = 10;
  800590:	be 0a 00 00 00       	mov    $0xa,%esi
  800595:	e9 85 00 00 00       	jmp    80061f <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059a:	89 ca                	mov    %ecx,%edx
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
  80059f:	e8 b5 fc ff ff       	call   800259 <getuint>
			base = 10;
  8005a4:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005a9:	eb 74                	jmp    80061f <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005af:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b6:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c4:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cb:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005d2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d8:	e9 20 fd ff ff       	jmp    8002fd <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800609:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80060e:	eb 0f                	jmp    80061f <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 3f fc ff ff       	call   800259 <getuint>
			base = 16;
  80061a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061f:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800623:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800627:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80062a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80062e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800632:	89 04 24             	mov    %eax,(%esp)
  800635:	89 54 24 04          	mov    %edx,0x4(%esp)
  800639:	89 da                	mov    %ebx,%edx
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	e8 41 fb ff ff       	call   800184 <printnum>
			break;
  800643:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800646:	e9 b2 fc ff ff       	jmp    8002fd <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	89 14 24             	mov    %edx,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800658:	e9 a0 fc ff ff       	jmp    8002fd <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800661:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066f:	0f 84 88 fc ff ff    	je     8002fd <vprintfmt+0x28>
  800675:	4e                   	dec    %esi
  800676:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067a:	75 f9                	jne    800675 <vprintfmt+0x3a0>
  80067c:	e9 7c fc ff ff       	jmp    8002fd <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  800681:	83 c4 4c             	add    $0x4c,%esp
  800684:	5b                   	pop    %ebx
  800685:	5e                   	pop    %esi
  800686:	5f                   	pop    %edi
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	83 ec 28             	sub    $0x28,%esp
  80068f:	8b 45 08             	mov    0x8(%ebp),%eax
  800692:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800695:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800698:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	74 30                	je     8006da <vsnprintf+0x51>
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	7e 33                	jle    8006e1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c3:	c7 04 24 93 02 80 00 	movl   $0x800293,(%esp)
  8006ca:	e8 06 fc ff ff       	call   8002d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d8:	eb 0c                	jmp    8006e6 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006df:	eb 05                	jmp    8006e6 <vsnprintf+0x5d>
  8006e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	89 04 24             	mov    %eax,(%esp)
  800709:	e8 7b ff ff ff       	call   800689 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	80 3a 00             	cmpb   $0x0,(%edx)
  800719:	74 0e                	je     800729 <strlen+0x19>
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800720:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800721:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800725:	75 f9                	jne    800720 <strlen+0x10>
  800727:	eb 05                	jmp    80072e <strlen+0x1e>
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073a:	85 c9                	test   %ecx,%ecx
  80073c:	74 1a                	je     800758 <strnlen+0x28>
  80073e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800741:	74 1c                	je     80075f <strnlen+0x2f>
  800743:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800748:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074a:	39 ca                	cmp    %ecx,%edx
  80074c:	74 16                	je     800764 <strnlen+0x34>
  80074e:	42                   	inc    %edx
  80074f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800754:	75 f2                	jne    800748 <strnlen+0x18>
  800756:	eb 0c                	jmp    800764 <strnlen+0x34>
  800758:	b8 00 00 00 00       	mov    $0x0,%eax
  80075d:	eb 05                	jmp    800764 <strnlen+0x34>
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800764:	5b                   	pop    %ebx
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800771:	ba 00 00 00 00       	mov    $0x0,%edx
  800776:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800779:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80077c:	42                   	inc    %edx
  80077d:	84 c9                	test   %cl,%cl
  80077f:	75 f5                	jne    800776 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800781:	5b                   	pop    %ebx
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078e:	89 1c 24             	mov    %ebx,(%esp)
  800791:	e8 7a ff ff ff       	call   800710 <strlen>
	strcpy(dst + len, src);
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079d:	01 d8                	add    %ebx,%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	e8 c0 ff ff ff       	call   800767 <strcpy>
	return dst;
}
  8007a7:	89 d8                	mov    %ebx,%eax
  8007a9:	83 c4 08             	add    $0x8,%esp
  8007ac:	5b                   	pop    %ebx
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bd:	85 f6                	test   %esi,%esi
  8007bf:	74 15                	je     8007d6 <strncpy+0x27>
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c6:	8a 1a                	mov    (%edx),%bl
  8007c8:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cb:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ce:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d1:	41                   	inc    %ecx
  8007d2:	39 f1                	cmp    %esi,%ecx
  8007d4:	75 f0                	jne    8007c6 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	57                   	push   %edi
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e6:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e9:	85 f6                	test   %esi,%esi
  8007eb:	74 31                	je     80081e <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  8007ed:	83 fe 01             	cmp    $0x1,%esi
  8007f0:	74 21                	je     800813 <strlcpy+0x39>
  8007f2:	8a 0b                	mov    (%ebx),%cl
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	74 1f                	je     800817 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007f8:	83 ee 02             	sub    $0x2,%esi
  8007fb:	89 f8                	mov    %edi,%eax
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	88 08                	mov    %cl,(%eax)
  800804:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800805:	39 f2                	cmp    %esi,%edx
  800807:	74 10                	je     800819 <strlcpy+0x3f>
  800809:	42                   	inc    %edx
  80080a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80080d:	84 c9                	test   %cl,%cl
  80080f:	75 f1                	jne    800802 <strlcpy+0x28>
  800811:	eb 06                	jmp    800819 <strlcpy+0x3f>
  800813:	89 f8                	mov    %edi,%eax
  800815:	eb 02                	jmp    800819 <strlcpy+0x3f>
  800817:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800819:	c6 00 00             	movb   $0x0,(%eax)
  80081c:	eb 02                	jmp    800820 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800820:	29 f8                	sub    %edi,%eax
}
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5f                   	pop    %edi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	8a 01                	mov    (%ecx),%al
  800832:	84 c0                	test   %al,%al
  800834:	74 11                	je     800847 <strcmp+0x20>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	75 0d                	jne    800847 <strcmp+0x20>
		p++, q++;
  80083a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083b:	8a 41 01             	mov    0x1(%ecx),%al
  80083e:	84 c0                	test   %al,%al
  800840:	74 05                	je     800847 <strcmp+0x20>
  800842:	41                   	inc    %ecx
  800843:	3a 02                	cmp    (%edx),%al
  800845:	74 f3                	je     80083a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800847:	0f b6 c0             	movzbl %al,%eax
  80084a:	0f b6 12             	movzbl (%edx),%edx
  80084d:	29 d0                	sub    %edx,%eax
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085b:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80085e:	85 c0                	test   %eax,%eax
  800860:	74 1b                	je     80087d <strncmp+0x2c>
  800862:	8a 1a                	mov    (%edx),%bl
  800864:	84 db                	test   %bl,%bl
  800866:	74 24                	je     80088c <strncmp+0x3b>
  800868:	3a 19                	cmp    (%ecx),%bl
  80086a:	75 20                	jne    80088c <strncmp+0x3b>
  80086c:	48                   	dec    %eax
  80086d:	74 15                	je     800884 <strncmp+0x33>
		n--, p++, q++;
  80086f:	42                   	inc    %edx
  800870:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800871:	8a 1a                	mov    (%edx),%bl
  800873:	84 db                	test   %bl,%bl
  800875:	74 15                	je     80088c <strncmp+0x3b>
  800877:	3a 19                	cmp    (%ecx),%bl
  800879:	74 f1                	je     80086c <strncmp+0x1b>
  80087b:	eb 0f                	jmp    80088c <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
  800882:	eb 05                	jmp    800889 <strncmp+0x38>
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800889:	5b                   	pop    %ebx
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 02             	movzbl (%edx),%eax
  80088f:	0f b6 11             	movzbl (%ecx),%edx
  800892:	29 d0                	sub    %edx,%eax
  800894:	eb f3                	jmp    800889 <strncmp+0x38>

00800896 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089f:	8a 10                	mov    (%eax),%dl
  8008a1:	84 d2                	test   %dl,%dl
  8008a3:	74 19                	je     8008be <strchr+0x28>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	75 07                	jne    8008b0 <strchr+0x1a>
  8008a9:	eb 18                	jmp    8008c3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ab:	40                   	inc    %eax
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 13                	je     8008c3 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	8a 50 01             	mov    0x1(%eax),%dl
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f4                	jne    8008ab <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	eb 05                	jmp    8008c3 <strchr+0x2d>
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	74 11                	je     8008e5 <strfind+0x20>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	75 06                	jne    8008de <strfind+0x19>
  8008d8:	eb 0b                	jmp    8008e5 <strfind+0x20>
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	74 07                	je     8008e5 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008de:	40                   	inc    %eax
  8008df:	8a 10                	mov    (%eax),%dl
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f5                	jne    8008da <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f6:	85 c9                	test   %ecx,%ecx
  8008f8:	74 30                	je     80092a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800900:	75 25                	jne    800927 <memset+0x40>
  800902:	f6 c1 03             	test   $0x3,%cl
  800905:	75 20                	jne    800927 <memset+0x40>
		c &= 0xFF;
  800907:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090a:	89 d3                	mov    %edx,%ebx
  80090c:	c1 e3 08             	shl    $0x8,%ebx
  80090f:	89 d6                	mov    %edx,%esi
  800911:	c1 e6 18             	shl    $0x18,%esi
  800914:	89 d0                	mov    %edx,%eax
  800916:	c1 e0 10             	shl    $0x10,%eax
  800919:	09 f0                	or     %esi,%eax
  80091b:	09 d0                	or     %edx,%eax
  80091d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800922:	fc                   	cld    
  800923:	f3 ab                	rep stos %eax,%es:(%edi)
  800925:	eb 03                	jmp    80092a <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	fc                   	cld    
  800928:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092a:	89 f8                	mov    %edi,%eax
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093f:	39 c6                	cmp    %eax,%esi
  800941:	73 34                	jae    800977 <memmove+0x46>
  800943:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800946:	39 d0                	cmp    %edx,%eax
  800948:	73 2d                	jae    800977 <memmove+0x46>
		s += n;
		d += n;
  80094a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	f6 c2 03             	test   $0x3,%dl
  800950:	75 1b                	jne    80096d <memmove+0x3c>
  800952:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800958:	75 13                	jne    80096d <memmove+0x3c>
  80095a:	f6 c1 03             	test   $0x3,%cl
  80095d:	75 0e                	jne    80096d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095f:	83 ef 04             	sub    $0x4,%edi
  800962:	8d 72 fc             	lea    -0x4(%edx),%esi
  800965:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800968:	fd                   	std    
  800969:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096b:	eb 07                	jmp    800974 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096d:	4f                   	dec    %edi
  80096e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800971:	fd                   	std    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800974:	fc                   	cld    
  800975:	eb 20                	jmp    800997 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097d:	75 13                	jne    800992 <memmove+0x61>
  80097f:	a8 03                	test   $0x3,%al
  800981:	75 0f                	jne    800992 <memmove+0x61>
  800983:	f6 c1 03             	test   $0x3,%cl
  800986:	75 0a                	jne    800992 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800988:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800990:	eb 05                	jmp    800997 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800992:	89 c7                	mov    %eax,%edi
  800994:	fc                   	cld    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	89 04 24             	mov    %eax,(%esp)
  8009b5:	e8 77 ff ff ff       	call   800931 <memmove>
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cb:	85 ff                	test   %edi,%edi
  8009cd:	74 31                	je     800a00 <memcmp+0x44>
		if (*s1 != *s2)
  8009cf:	8a 03                	mov    (%ebx),%al
  8009d1:	8a 0e                	mov    (%esi),%cl
  8009d3:	38 c8                	cmp    %cl,%al
  8009d5:	74 18                	je     8009ef <memcmp+0x33>
  8009d7:	eb 0c                	jmp    8009e5 <memcmp+0x29>
  8009d9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009dd:	42                   	inc    %edx
  8009de:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  8009e1:	38 c8                	cmp    %cl,%al
  8009e3:	74 10                	je     8009f5 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  8009e5:	0f b6 c0             	movzbl %al,%eax
  8009e8:	0f b6 c9             	movzbl %cl,%ecx
  8009eb:	29 c8                	sub    %ecx,%eax
  8009ed:	eb 16                	jmp    800a05 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	4f                   	dec    %edi
  8009f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f5:	39 fa                	cmp    %edi,%edx
  8009f7:	75 e0                	jne    8009d9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	eb 05                	jmp    800a05 <memcmp+0x49>
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a10:	89 c2                	mov    %eax,%edx
  800a12:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a15:	39 d0                	cmp    %edx,%eax
  800a17:	73 12                	jae    800a2b <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a19:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a1c:	38 08                	cmp    %cl,(%eax)
  800a1e:	75 06                	jne    800a26 <memfind+0x1c>
  800a20:	eb 09                	jmp    800a2b <memfind+0x21>
  800a22:	38 08                	cmp    %cl,(%eax)
  800a24:	74 05                	je     800a2b <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a26:	40                   	inc    %eax
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	75 f7                	jne    800a22 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
  800a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a39:	eb 01                	jmp    800a3c <strtol+0xf>
		s++;
  800a3b:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3c:	8a 02                	mov    (%edx),%al
  800a3e:	3c 20                	cmp    $0x20,%al
  800a40:	74 f9                	je     800a3b <strtol+0xe>
  800a42:	3c 09                	cmp    $0x9,%al
  800a44:	74 f5                	je     800a3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a46:	3c 2b                	cmp    $0x2b,%al
  800a48:	75 08                	jne    800a52 <strtol+0x25>
		s++;
  800a4a:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a50:	eb 13                	jmp    800a65 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a52:	3c 2d                	cmp    $0x2d,%al
  800a54:	75 0a                	jne    800a60 <strtol+0x33>
		s++, neg = 1;
  800a56:	8d 52 01             	lea    0x1(%edx),%edx
  800a59:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5e:	eb 05                	jmp    800a65 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a65:	85 db                	test   %ebx,%ebx
  800a67:	74 05                	je     800a6e <strtol+0x41>
  800a69:	83 fb 10             	cmp    $0x10,%ebx
  800a6c:	75 28                	jne    800a96 <strtol+0x69>
  800a6e:	8a 02                	mov    (%edx),%al
  800a70:	3c 30                	cmp    $0x30,%al
  800a72:	75 10                	jne    800a84 <strtol+0x57>
  800a74:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a78:	75 0a                	jne    800a84 <strtol+0x57>
		s += 2, base = 16;
  800a7a:	83 c2 02             	add    $0x2,%edx
  800a7d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a82:	eb 12                	jmp    800a96 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	75 0e                	jne    800a96 <strtol+0x69>
  800a88:	3c 30                	cmp    $0x30,%al
  800a8a:	75 05                	jne    800a91 <strtol+0x64>
		s++, base = 8;
  800a8c:	42                   	inc    %edx
  800a8d:	b3 08                	mov    $0x8,%bl
  800a8f:	eb 05                	jmp    800a96 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a91:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9d:	8a 0a                	mov    (%edx),%cl
  800a9f:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aa2:	80 fb 09             	cmp    $0x9,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x82>
			dig = *s - '0';
  800aa7:	0f be c9             	movsbl %cl,%ecx
  800aaa:	83 e9 30             	sub    $0x30,%ecx
  800aad:	eb 1e                	jmp    800acd <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x92>
			dig = *s - 'a' + 10;
  800ab7:	0f be c9             	movsbl %cl,%ecx
  800aba:	83 e9 57             	sub    $0x57,%ecx
  800abd:	eb 0e                	jmp    800acd <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 12                	ja     800ad9 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ac7:	0f be c9             	movsbl %cl,%ecx
  800aca:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800acd:	39 f1                	cmp    %esi,%ecx
  800acf:	7d 0c                	jge    800add <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ad1:	42                   	inc    %edx
  800ad2:	0f af c6             	imul   %esi,%eax
  800ad5:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ad7:	eb c4                	jmp    800a9d <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad9:	89 c1                	mov    %eax,%ecx
  800adb:	eb 02                	jmp    800adf <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800add:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 05                	je     800aea <strtol+0xbd>
		*endptr = (char *) s;
  800ae5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae8:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aea:	85 ff                	test   %edi,%edi
  800aec:	74 04                	je     800af2 <strtol+0xc5>
  800aee:	89 c8                	mov    %ecx,%eax
  800af0:	f7 d8                	neg    %eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    
	...

00800af8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	8b 55 08             	mov    0x8(%ebp),%edx
  800b08:	89 c3                	mov    %eax,%ebx
  800b0a:	89 c7                	mov    %eax,%edi
  800b0c:	51                   	push   %ecx
  800b0d:	52                   	push   %edx
  800b0e:	53                   	push   %ebx
  800b0f:	54                   	push   %esp
  800b10:	55                   	push   %ebp
  800b11:	56                   	push   %esi
  800b12:	57                   	push   %edi
  800b13:	8d 35 1d 0b 80 00    	lea    0x800b1d,%esi
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	0f 34                	sysenter 

00800b1d <after_sysenter_label16>:
  800b1d:	5f                   	pop    %edi
  800b1e:	5e                   	pop    %esi
  800b1f:	5d                   	pop    %ebp
  800b20:	5c                   	pop    %esp
  800b21:	5b                   	pop    %ebx
  800b22:	5a                   	pop    %edx
  800b23:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 01 00 00 00       	mov    $0x1,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	51                   	push   %ecx
  800b3e:	52                   	push   %edx
  800b3f:	53                   	push   %ebx
  800b40:	54                   	push   %esp
  800b41:	55                   	push   %ebp
  800b42:	56                   	push   %esi
  800b43:	57                   	push   %edi
  800b44:	8d 35 4e 0b 80 00    	lea    0x800b4e,%esi
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	0f 34                	sysenter 

00800b4e <after_sysenter_label41>:
  800b4e:	5f                   	pop    %edi
  800b4f:	5e                   	pop    %esi
  800b50:	5d                   	pop    %ebp
  800b51:	5c                   	pop    %esp
  800b52:	5b                   	pop    %ebx
  800b53:	5a                   	pop    %edx
  800b54:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	89 cb                	mov    %ecx,%ebx
  800b70:	89 cf                	mov    %ecx,%edi
  800b72:	51                   	push   %ecx
  800b73:	52                   	push   %edx
  800b74:	53                   	push   %ebx
  800b75:	54                   	push   %esp
  800b76:	55                   	push   %ebp
  800b77:	56                   	push   %esi
  800b78:	57                   	push   %edi
  800b79:	8d 35 83 0b 80 00    	lea    0x800b83,%esi
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	0f 34                	sysenter 

00800b83 <after_sysenter_label68>:
  800b83:	5f                   	pop    %edi
  800b84:	5e                   	pop    %esi
  800b85:	5d                   	pop    %ebp
  800b86:	5c                   	pop    %esp
  800b87:	5b                   	pop    %ebx
  800b88:	5a                   	pop    %edx
  800b89:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	7e 28                	jle    800bb6 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b92:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b99:	00 
  800b9a:	c7 44 24 08 44 11 80 	movl   $0x801144,0x8(%esp)
  800ba1:	00 
  800ba2:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ba9:	00 
  800baa:	c7 04 24 61 11 80 00 	movl   $0x801161,(%esp)
  800bb1:	e8 9e 00 00 00       	call   800c54 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb6:	83 c4 20             	add    $0x20,%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	51                   	push   %ecx
  800bd3:	52                   	push   %edx
  800bd4:	53                   	push   %ebx
  800bd5:	54                   	push   %esp
  800bd6:	55                   	push   %ebp
  800bd7:	56                   	push   %esi
  800bd8:	57                   	push   %edi
  800bd9:	8d 35 e3 0b 80 00    	lea    0x800be3,%esi
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	0f 34                	sysenter 

00800be3 <after_sysenter_label107>:
  800be3:	5f                   	pop    %edi
  800be4:	5e                   	pop    %esi
  800be5:	5d                   	pop    %ebp
  800be6:	5c                   	pop    %esp
  800be7:	5b                   	pop    %ebx
  800be8:	5a                   	pop    %edx
  800be9:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	51                   	push   %ecx
  800c06:	52                   	push   %edx
  800c07:	53                   	push   %ebx
  800c08:	54                   	push   %esp
  800c09:	55                   	push   %ebp
  800c0a:	56                   	push   %esi
  800c0b:	57                   	push   %edi
  800c0c:	8d 35 16 0c 80 00    	lea    0x800c16,%esi
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	0f 34                	sysenter 

00800c16 <after_sysenter_label133>:
  800c16:	5f                   	pop    %edi
  800c17:	5e                   	pop    %esi
  800c18:	5d                   	pop    %ebp
  800c19:	5c                   	pop    %esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5a                   	pop    %edx
  800c1c:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	51                   	push   %ecx
  800c38:	52                   	push   %edx
  800c39:	53                   	push   %ebx
  800c3a:	54                   	push   %esp
  800c3b:	55                   	push   %ebp
  800c3c:	56                   	push   %esi
  800c3d:	57                   	push   %edi
  800c3e:	8d 35 48 0c 80 00    	lea    0x800c48,%esi
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	0f 34                	sysenter 

00800c48 <after_sysenter_label159>:
  800c48:	5f                   	pop    %edi
  800c49:	5e                   	pop    %esi
  800c4a:	5d                   	pop    %ebp
  800c4b:	5c                   	pop    %esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5a                   	pop    %edx
  800c4e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    
	...

00800c54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c5c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c5f:	a1 08 20 80 00       	mov    0x802008,%eax
  800c64:	85 c0                	test   %eax,%eax
  800c66:	74 10                	je     800c78 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6c:	c7 04 24 6f 11 80 00 	movl   $0x80116f,(%esp)
  800c73:	e8 f0 f4 ff ff       	call   800168 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c78:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c7e:	e8 3a ff ff ff       	call   800bbd <sys_getenvid>
  800c83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c86:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c99:	c7 04 24 74 11 80 00 	movl   $0x801174,(%esp)
  800ca0:	e8 c3 f4 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ca5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cac:	89 04 24             	mov    %eax,(%esp)
  800caf:	e8 53 f4 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800cb4:	c7 04 24 22 0f 80 00 	movl   $0x800f22,(%esp)
  800cbb:	e8 a8 f4 ff ff       	call   800168 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cc0:	cc                   	int3   
  800cc1:	eb fd                	jmp    800cc0 <_panic+0x6c>
	...

00800cc4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cc4:	55                   	push   %ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	83 ec 10             	sub    $0x10,%esp
  800cca:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cce:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800cda:	89 cd                	mov    %ecx,%ebp
  800cdc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	75 2c                	jne    800d10 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ce4:	39 f9                	cmp    %edi,%ecx
  800ce6:	77 68                	ja     800d50 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce8:	85 c9                	test   %ecx,%ecx
  800cea:	75 0b                	jne    800cf7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800cec:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf1:	31 d2                	xor    %edx,%edx
  800cf3:	f7 f1                	div    %ecx
  800cf5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf7:	31 d2                	xor    %edx,%edx
  800cf9:	89 f8                	mov    %edi,%eax
  800cfb:	f7 f1                	div    %ecx
  800cfd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cff:	89 f0                	mov    %esi,%eax
  800d01:	f7 f1                	div    %ecx
  800d03:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d05:	89 f0                	mov    %esi,%eax
  800d07:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d10:	39 f8                	cmp    %edi,%eax
  800d12:	77 2c                	ja     800d40 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d14:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d17:	83 f6 1f             	xor    $0x1f,%esi
  800d1a:	75 4c                	jne    800d68 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d1c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d1e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d23:	72 0a                	jb     800d2f <__udivdi3+0x6b>
  800d25:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d29:	0f 87 ad 00 00 00    	ja     800ddc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d2f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d34:	89 f0                	mov    %esi,%eax
  800d36:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    
  800d3f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d40:	31 ff                	xor    %edi,%edi
  800d42:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d50:	89 fa                	mov    %edi,%edx
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	f7 f1                	div    %ecx
  800d56:	89 c6                	mov    %eax,%esi
  800d58:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d5a:	89 f0                	mov    %esi,%eax
  800d5c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d68:	89 f1                	mov    %esi,%ecx
  800d6a:	d3 e0                	shl    %cl,%eax
  800d6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d70:	b8 20 00 00 00       	mov    $0x20,%eax
  800d75:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d77:	89 ea                	mov    %ebp,%edx
  800d79:	88 c1                	mov    %al,%cl
  800d7b:	d3 ea                	shr    %cl,%edx
  800d7d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800d81:	09 ca                	or     %ecx,%edx
  800d83:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800d87:	89 f1                	mov    %esi,%ecx
  800d89:	d3 e5                	shl    %cl,%ebp
  800d8b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800d8f:	89 fd                	mov    %edi,%ebp
  800d91:	88 c1                	mov    %al,%cl
  800d93:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800d95:	89 fa                	mov    %edi,%edx
  800d97:	89 f1                	mov    %esi,%ecx
  800d99:	d3 e2                	shl    %cl,%edx
  800d9b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d9f:	88 c1                	mov    %al,%cl
  800da1:	d3 ef                	shr    %cl,%edi
  800da3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da5:	89 f8                	mov    %edi,%eax
  800da7:	89 ea                	mov    %ebp,%edx
  800da9:	f7 74 24 08          	divl   0x8(%esp)
  800dad:	89 d1                	mov    %edx,%ecx
  800daf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800db1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db5:	39 d1                	cmp    %edx,%ecx
  800db7:	72 17                	jb     800dd0 <__udivdi3+0x10c>
  800db9:	74 09                	je     800dc4 <__udivdi3+0x100>
  800dbb:	89 fe                	mov    %edi,%esi
  800dbd:	31 ff                	xor    %edi,%edi
  800dbf:	e9 41 ff ff ff       	jmp    800d05 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dc4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dc8:	89 f1                	mov    %esi,%ecx
  800dca:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dcc:	39 c2                	cmp    %eax,%edx
  800dce:	73 eb                	jae    800dbb <__udivdi3+0xf7>
		{
		  q0--;
  800dd0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dd3:	31 ff                	xor    %edi,%edi
  800dd5:	e9 2b ff ff ff       	jmp    800d05 <__udivdi3+0x41>
  800dda:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ddc:	31 f6                	xor    %esi,%esi
  800dde:	e9 22 ff ff ff       	jmp    800d05 <__udivdi3+0x41>
	...

00800de4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800de4:	55                   	push   %ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	83 ec 20             	sub    $0x20,%esp
  800dea:	8b 44 24 30          	mov    0x30(%esp),%eax
  800dee:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800df2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800df6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800dfa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800dfe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e02:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e04:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e06:	85 ed                	test   %ebp,%ebp
  800e08:	75 16                	jne    800e20 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e0a:	39 f1                	cmp    %esi,%ecx
  800e0c:	0f 86 a6 00 00 00    	jbe    800eb8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e12:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e14:	89 d0                	mov    %edx,%eax
  800e16:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e18:	83 c4 20             	add    $0x20,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e20:	39 f5                	cmp    %esi,%ebp
  800e22:	0f 87 ac 00 00 00    	ja     800ed4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e28:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e2b:	83 f0 1f             	xor    $0x1f,%eax
  800e2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e32:	0f 84 a8 00 00 00    	je     800ee0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e38:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e3c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e3e:	bf 20 00 00 00       	mov    $0x20,%edi
  800e43:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e47:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e4b:	89 f9                	mov    %edi,%ecx
  800e4d:	d3 e8                	shr    %cl,%eax
  800e4f:	09 e8                	or     %ebp,%eax
  800e51:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e55:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e59:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e5d:	d3 e0                	shl    %cl,%eax
  800e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e63:	89 f2                	mov    %esi,%edx
  800e65:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e67:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e6b:	d3 e0                	shl    %cl,%eax
  800e6d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e71:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e8                	shr    %cl,%eax
  800e79:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e7b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e7d:	89 f2                	mov    %esi,%edx
  800e7f:	f7 74 24 18          	divl   0x18(%esp)
  800e83:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e85:	f7 64 24 0c          	mull   0xc(%esp)
  800e89:	89 c5                	mov    %eax,%ebp
  800e8b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8d:	39 d6                	cmp    %edx,%esi
  800e8f:	72 67                	jb     800ef8 <__umoddi3+0x114>
  800e91:	74 75                	je     800f08 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e93:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800e97:	29 e8                	sub    %ebp,%eax
  800e99:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e9b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e9f:	d3 e8                	shr    %cl,%eax
  800ea1:	89 f2                	mov    %esi,%edx
  800ea3:	89 f9                	mov    %edi,%ecx
  800ea5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ea7:	09 d0                	or     %edx,%eax
  800ea9:	89 f2                	mov    %esi,%edx
  800eab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eaf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb1:	83 c4 20             	add    $0x20,%esp
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb8:	85 c9                	test   %ecx,%ecx
  800eba:	75 0b                	jne    800ec7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	f7 f1                	div    %ecx
  800ec5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec7:	89 f0                	mov    %esi,%eax
  800ec9:	31 d2                	xor    %edx,%edx
  800ecb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ecd:	89 f8                	mov    %edi,%eax
  800ecf:	e9 3e ff ff ff       	jmp    800e12 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ed4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed6:	83 c4 20             	add    $0x20,%esp
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    
  800edd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee0:	39 f5                	cmp    %esi,%ebp
  800ee2:	72 04                	jb     800ee8 <__umoddi3+0x104>
  800ee4:	39 f9                	cmp    %edi,%ecx
  800ee6:	77 06                	ja     800eee <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	29 cf                	sub    %ecx,%edi
  800eec:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800eee:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef0:	83 c4 20             	add    $0x20,%esp
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    
  800ef7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 c5                	mov    %eax,%ebp
  800efc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f00:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f04:	eb 8d                	jmp    800e93 <__umoddi3+0xaf>
  800f06:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f08:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f0c:	72 ea                	jb     800ef8 <__umoddi3+0x114>
  800f0e:	89 f1                	mov    %esi,%ecx
  800f10:	eb 81                	jmp    800e93 <__umoddi3+0xaf>
