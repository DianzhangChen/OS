
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 10             	sub    $0x10,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80004a:	e8 66 0b 00 00       	call   800bb5 <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800057:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80005a:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800061:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  800066:	c7 04 24 0c 0f 80 00 	movl   $0x800f0c,(%esp)
  80006d:	e8 ee 00 00 00       	call   800160 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  800072:	a1 04 20 80 00       	mov    0x802004,%eax
  800077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007b:	c7 04 24 1c 0f 80 00 	movl   $0x800f1c,(%esp)
  800082:	e8 d9 00 00 00       	call   800160 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 f6                	test   %esi,%esi
  800089:	7e 07                	jle    800092 <libmain+0x56>
		binaryname = argv[0];
  80008b:	8b 03                	mov    (%ebx),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 96 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009e:	e8 09 00 00 00       	call   8000ac <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 93 0a 00 00       	call   800b51 <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 14             	sub    $0x14,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d3:	40                   	inc    %eax
  8000d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 19                	jne    8000f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e4:	00 
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	89 04 24             	mov    %eax,(%esp)
  8000eb:	e8 00 0a 00 00       	call   800af0 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f6:	ff 43 04             	incl   0x4(%ebx)
}
  8000f9:	83 c4 14             	add    $0x14,%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010f:	00 00 00 
	b.cnt = 0;
  800112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800123:	8b 45 08             	mov    0x8(%ebp),%eax
  800126:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	89 44 24 04          	mov    %eax,0x4(%esp)
  800134:	c7 04 24 c0 00 80 00 	movl   $0x8000c0,(%esp)
  80013b:	e8 8d 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800140:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 98 09 00 00       	call   800af0 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	89 04 24             	mov    %eax,(%esp)
  800173:	e8 87 ff ff ff       	call   8000ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800178:	c9                   	leave  
  800179:	c3                   	ret    
	...

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 3c             	sub    $0x3c,%esp
  800185:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800188:	89 d7                	mov    %edx,%edi
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800196:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800199:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019c:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a4:	72 0f                	jb     8001b5 <printnum+0x39>
  8001a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ac:	76 07                	jbe    8001b5 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ae:	4b                   	dec    %ebx
  8001af:	85 db                	test   %ebx,%ebx
  8001b1:	7f 4f                	jg     800202 <printnum+0x86>
  8001b3:	eb 5a                	jmp    80020f <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b5:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b9:	4b                   	dec    %ebx
  8001ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001be:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d4:	00 
  8001d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	e8 d5 0a 00 00       	call   800cbc <__udivdi3>
  8001e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f6:	89 fa                	mov    %edi,%edx
  8001f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fb:	e8 7c ff ff ff       	call   80017c <printnum>
  800200:	eb 0d                	jmp    80020f <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800202:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800206:	89 34 24             	mov    %esi,(%esp)
  800209:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020c:	4b                   	dec    %ebx
  80020d:	75 f3                	jne    800202 <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800213:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800217:	8b 45 10             	mov    0x10(%ebp),%eax
  80021a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800225:	00 
  800226:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	e8 a4 0b 00 00       	call   800ddc <__umoddi3>
  800238:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023c:	0f be 80 39 0f 80 00 	movsbl 0x800f39(%eax),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800249:	83 c4 3c             	add    $0x3c,%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5e                   	pop    %esi
  80024e:	5f                   	pop    %edi
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800254:	83 fa 01             	cmp    $0x1,%edx
  800257:	7e 0e                	jle    800267 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800259:	8b 10                	mov    (%eax),%edx
  80025b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 02                	mov    (%edx),%eax
  800262:	8b 52 04             	mov    0x4(%edx),%edx
  800265:	eb 22                	jmp    800289 <getuint+0x38>
	else if (lflag)
  800267:	85 d2                	test   %edx,%edx
  800269:	74 10                	je     80027b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	ba 00 00 00 00       	mov    $0x0,%edx
  800279:	eb 0e                	jmp    800289 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800280:	89 08                	mov    %ecx,(%eax)
  800282:	8b 02                	mov    (%edx),%eax
  800284:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800291:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 08                	jae    8002a3 <sprintputch+0x18>
		*b->buf++ = ch;
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 0a                	mov    %cl,(%edx)
  8002a0:	42                   	inc    %edx
  8002a1:	89 10                	mov    %edx,(%eax)
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	e8 02 00 00 00       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 4c             	sub    $0x4c,%esp
  8002d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002dc:	eb 17                	jmp    8002f5 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	0f 84 93 03 00 00    	je     800679 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	ff 55 08             	call   *0x8(%ebp)
  8002f0:	eb 03                	jmp    8002f5 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f5:	0f b6 06             	movzbl (%esi),%eax
  8002f8:	46                   	inc    %esi
  8002f9:	83 f8 25             	cmp    $0x25,%eax
  8002fc:	75 e0                	jne    8002de <vprintfmt+0x11>
  8002fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800302:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800309:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	eb 26                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800323:	eb 1d                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80032c:	eb 14                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800331:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800338:	eb 08                	jmp    800342 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	0f b6 16             	movzbl (%esi),%edx
  800345:	8d 46 01             	lea    0x1(%esi),%eax
  800348:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034b:	8a 06                	mov    (%esi),%al
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 fd 02 00 00    	ja     800655 <vprintfmt+0x388>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 c8 0f 80 00 	jmp    *0x800fc8(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  800365:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800369:	8d 50 d0             	lea    -0x30(%eax),%edx
  80036c:	83 fa 09             	cmp    $0x9,%edx
  80036f:	77 3f                	ja     8003b0 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800374:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800375:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800378:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80037c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80037f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800382:	83 fa 09             	cmp    $0x9,%edx
  800385:	76 ed                	jbe    800374 <vprintfmt+0xa7>
  800387:	eb 2a                	jmp    8003b3 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 50 04             	lea    0x4(%eax),%edx
  80038f:	89 55 14             	mov    %edx,0x14(%ebp)
  800392:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800397:	eb 1a                	jmp    8003b3 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  800399:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039d:	78 8f                	js     80032e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a2:	eb 9e                	jmp    800342 <vprintfmt+0x75>
  8003a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003ae:	eb 92                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b7:	79 89                	jns    800342 <vprintfmt+0x75>
  8003b9:	e9 7c ff ff ff       	jmp    80033a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003be:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c2:	e9 7b ff ff ff       	jmp    800342 <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8d 50 04             	lea    0x4(%eax),%edx
  8003cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	89 04 24             	mov    %eax,(%esp)
  8003d9:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003df:	e9 11 ff ff ff       	jmp    8002f5 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	79 02                	jns    8003f5 <vprintfmt+0x128>
  8003f3:	f7 d8                	neg    %eax
  8003f5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f7:	83 f8 06             	cmp    $0x6,%eax
  8003fa:	7f 0b                	jg     800407 <vprintfmt+0x13a>
  8003fc:	8b 04 85 20 11 80 00 	mov    0x801120(,%eax,4),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	75 23                	jne    80042a <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800407:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80040b:	c7 44 24 08 51 0f 80 	movl   $0x800f51,0x8(%esp)
  800412:	00 
  800413:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800417:	8b 55 08             	mov    0x8(%ebp),%edx
  80041a:	89 14 24             	mov    %edx,(%esp)
  80041d:	e8 83 fe ff ff       	call   8002a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800425:	e9 cb fe ff ff       	jmp    8002f5 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  80042a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042e:	c7 44 24 08 5a 0f 80 	movl   $0x800f5a,0x8(%esp)
  800435:	00 
  800436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043d:	89 0c 24             	mov    %ecx,(%esp)
  800440:	e8 60 fe ff ff       	call   8002a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800448:	e9 a8 fe ff ff       	jmp    8002f5 <vprintfmt+0x28>
  80044d:	89 f9                	mov    %edi,%ecx
  80044f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800460:	85 c0                	test   %eax,%eax
  800462:	75 07                	jne    80046b <vprintfmt+0x19e>
				p = "(null)";
  800464:	c7 45 d4 4a 0f 80 00 	movl   $0x800f4a,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80046b:	85 f6                	test   %esi,%esi
  80046d:	7e 3b                	jle    8004aa <vprintfmt+0x1dd>
  80046f:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800473:	74 35                	je     8004aa <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800479:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 a4 02 00 00       	call   800728 <strnlen>
  800484:	29 c6                	sub    %eax,%esi
  800486:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800489:	85 f6                	test   %esi,%esi
  80048b:	7e 1d                	jle    8004aa <vprintfmt+0x1dd>
					putch(padc, putdat);
  80048d:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800491:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800497:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049b:	89 34 24             	mov    %esi,(%esp)
  80049e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	4f                   	dec    %edi
  8004a2:	75 f3                	jne    800497 <vprintfmt+0x1ca>
  8004a4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004a7:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ad:	0f be 02             	movsbl (%edx),%eax
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	75 43                	jne    8004f7 <vprintfmt+0x22a>
  8004b4:	eb 33                	jmp    8004e9 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ba:	74 18                	je     8004d4 <vprintfmt+0x207>
  8004bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bf:	83 fa 5e             	cmp    $0x5e,%edx
  8004c2:	76 10                	jbe    8004d4 <vprintfmt+0x207>
					putch('?', putdat);
  8004c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	eb 0a                	jmp    8004de <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e1:	0f be 06             	movsbl (%esi),%eax
  8004e4:	46                   	inc    %esi
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 12                	jne    8004fb <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ed:	7f 15                	jg     800504 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f2:	e9 fe fd ff ff       	jmp    8002f5 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004fa:	46                   	inc    %esi
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	78 b7                	js     8004b6 <vprintfmt+0x1e9>
  8004ff:	4f                   	dec    %edi
  800500:	79 b4                	jns    8004b6 <vprintfmt+0x1e9>
  800502:	eb e5                	jmp    8004e9 <vprintfmt+0x21c>
  800504:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800507:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800515:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800517:	4e                   	dec    %esi
  800518:	75 f0                	jne    80050a <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051d:	e9 d3 fd ff ff       	jmp    8002f5 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800522:	83 f9 01             	cmp    $0x1,%ecx
  800525:	7e 10                	jle    800537 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 50 08             	lea    0x8(%eax),%edx
  80052d:	89 55 14             	mov    %edx,0x14(%ebp)
  800530:	8b 30                	mov    (%eax),%esi
  800532:	8b 78 04             	mov    0x4(%eax),%edi
  800535:	eb 26                	jmp    80055d <vprintfmt+0x290>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	74 12                	je     80054d <vprintfmt+0x280>
		return va_arg(*ap, long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	89 f7                	mov    %esi,%edi
  800548:	c1 ff 1f             	sar    $0x1f,%edi
  80054b:	eb 10                	jmp    80055d <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 30                	mov    (%eax),%esi
  800558:	89 f7                	mov    %esi,%edi
  80055a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055d:	85 ff                	test   %edi,%edi
  80055f:	78 0e                	js     80056f <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800561:	89 f0                	mov    %esi,%eax
  800563:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800565:	be 0a 00 00 00       	mov    $0xa,%esi
  80056a:	e9 a8 00 00 00       	jmp    800617 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80056f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800573:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057d:	89 f0                	mov    %esi,%eax
  80057f:	89 fa                	mov    %edi,%edx
  800581:	f7 d8                	neg    %eax
  800583:	83 d2 00             	adc    $0x0,%edx
  800586:	f7 da                	neg    %edx
			}
			base = 10;
  800588:	be 0a 00 00 00       	mov    $0xa,%esi
  80058d:	e9 85 00 00 00       	jmp    800617 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800592:	89 ca                	mov    %ecx,%edx
  800594:	8d 45 14             	lea    0x14(%ebp),%eax
  800597:	e8 b5 fc ff ff       	call   800251 <getuint>
			base = 10;
  80059c:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005a1:	eb 74                	jmp    800617 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ae:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005bc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ca:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d0:	e9 20 fd ff ff       	jmp    8002f5 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800601:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800606:	eb 0f                	jmp    800617 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800608:	89 ca                	mov    %ecx,%edx
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	e8 3f fc ff ff       	call   800251 <getuint>
			base = 16;
  800612:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800617:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80061b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80061f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800622:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800626:	89 74 24 08          	mov    %esi,0x8(%esp)
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800631:	89 da                	mov    %ebx,%edx
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	e8 41 fb ff ff       	call   80017c <printnum>
			break;
  80063b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80063e:	e9 b2 fc ff ff       	jmp    8002f5 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800647:	89 14 24             	mov    %edx,(%esp)
  80064a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800650:	e9 a0 fc ff ff       	jmp    8002f5 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800659:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800660:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800663:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800667:	0f 84 88 fc ff ff    	je     8002f5 <vprintfmt+0x28>
  80066d:	4e                   	dec    %esi
  80066e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800672:	75 f9                	jne    80066d <vprintfmt+0x3a0>
  800674:	e9 7c fc ff ff       	jmp    8002f5 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  800679:	83 c4 4c             	add    $0x4c,%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	83 ec 28             	sub    $0x28,%esp
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800690:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800694:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 30                	je     8006d2 <vsnprintf+0x51>
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	7e 33                	jle    8006d9 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bb:	c7 04 24 8b 02 80 00 	movl   $0x80028b,(%esp)
  8006c2:	e8 06 fc ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d0:	eb 0c                	jmp    8006de <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d7:	eb 05                	jmp    8006de <vsnprintf+0x5d>
  8006d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	89 04 24             	mov    %eax,(%esp)
  800701:	e8 7b ff ff ff       	call   800681 <vsnprintf>
	va_end(ap);

	return rc;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	80 3a 00             	cmpb   $0x0,(%edx)
  800711:	74 0e                	je     800721 <strlen+0x19>
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800718:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800719:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071d:	75 f9                	jne    800718 <strlen+0x10>
  80071f:	eb 05                	jmp    800726 <strlen+0x1e>
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80072f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800732:	85 c9                	test   %ecx,%ecx
  800734:	74 1a                	je     800750 <strnlen+0x28>
  800736:	80 3b 00             	cmpb   $0x0,(%ebx)
  800739:	74 1c                	je     800757 <strnlen+0x2f>
  80073b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800740:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800742:	39 ca                	cmp    %ecx,%edx
  800744:	74 16                	je     80075c <strnlen+0x34>
  800746:	42                   	inc    %edx
  800747:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80074c:	75 f2                	jne    800740 <strnlen+0x18>
  80074e:	eb 0c                	jmp    80075c <strnlen+0x34>
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	eb 05                	jmp    80075c <strnlen+0x34>
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80075c:	5b                   	pop    %ebx
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800769:	ba 00 00 00 00       	mov    $0x0,%edx
  80076e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800771:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800774:	42                   	inc    %edx
  800775:	84 c9                	test   %cl,%cl
  800777:	75 f5                	jne    80076e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800779:	5b                   	pop    %ebx
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800786:	89 1c 24             	mov    %ebx,(%esp)
  800789:	e8 7a ff ff ff       	call   800708 <strlen>
	strcpy(dst + len, src);
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	89 54 24 04          	mov    %edx,0x4(%esp)
  800795:	01 d8                	add    %ebx,%eax
  800797:	89 04 24             	mov    %eax,(%esp)
  80079a:	e8 c0 ff ff ff       	call   80075f <strcpy>
	return dst;
}
  80079f:	89 d8                	mov    %ebx,%eax
  8007a1:	83 c4 08             	add    $0x8,%esp
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b5:	85 f6                	test   %esi,%esi
  8007b7:	74 15                	je     8007ce <strncpy+0x27>
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007be:	8a 1a                	mov    (%edx),%bl
  8007c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	41                   	inc    %ecx
  8007ca:	39 f1                	cmp    %esi,%ecx
  8007cc:	75 f0                	jne    8007be <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	57                   	push   %edi
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007de:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e1:	85 f6                	test   %esi,%esi
  8007e3:	74 31                	je     800816 <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  8007e5:	83 fe 01             	cmp    $0x1,%esi
  8007e8:	74 21                	je     80080b <strlcpy+0x39>
  8007ea:	8a 0b                	mov    (%ebx),%cl
  8007ec:	84 c9                	test   %cl,%cl
  8007ee:	74 1f                	je     80080f <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007f0:	83 ee 02             	sub    $0x2,%esi
  8007f3:	89 f8                	mov    %edi,%eax
  8007f5:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fa:	88 08                	mov    %cl,(%eax)
  8007fc:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007fd:	39 f2                	cmp    %esi,%edx
  8007ff:	74 10                	je     800811 <strlcpy+0x3f>
  800801:	42                   	inc    %edx
  800802:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800805:	84 c9                	test   %cl,%cl
  800807:	75 f1                	jne    8007fa <strlcpy+0x28>
  800809:	eb 06                	jmp    800811 <strlcpy+0x3f>
  80080b:	89 f8                	mov    %edi,%eax
  80080d:	eb 02                	jmp    800811 <strlcpy+0x3f>
  80080f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800811:	c6 00 00             	movb   $0x0,(%eax)
  800814:	eb 02                	jmp    800818 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800818:	29 f8                	sub    %edi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	8a 01                	mov    (%ecx),%al
  80082a:	84 c0                	test   %al,%al
  80082c:	74 11                	je     80083f <strcmp+0x20>
  80082e:	3a 02                	cmp    (%edx),%al
  800830:	75 0d                	jne    80083f <strcmp+0x20>
		p++, q++;
  800832:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800833:	8a 41 01             	mov    0x1(%ecx),%al
  800836:	84 c0                	test   %al,%al
  800838:	74 05                	je     80083f <strcmp+0x20>
  80083a:	41                   	inc    %ecx
  80083b:	3a 02                	cmp    (%edx),%al
  80083d:	74 f3                	je     800832 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 c0             	movzbl %al,%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 55 08             	mov    0x8(%ebp),%edx
  800850:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800853:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800856:	85 c0                	test   %eax,%eax
  800858:	74 1b                	je     800875 <strncmp+0x2c>
  80085a:	8a 1a                	mov    (%edx),%bl
  80085c:	84 db                	test   %bl,%bl
  80085e:	74 24                	je     800884 <strncmp+0x3b>
  800860:	3a 19                	cmp    (%ecx),%bl
  800862:	75 20                	jne    800884 <strncmp+0x3b>
  800864:	48                   	dec    %eax
  800865:	74 15                	je     80087c <strncmp+0x33>
		n--, p++, q++;
  800867:	42                   	inc    %edx
  800868:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800869:	8a 1a                	mov    (%edx),%bl
  80086b:	84 db                	test   %bl,%bl
  80086d:	74 15                	je     800884 <strncmp+0x3b>
  80086f:	3a 19                	cmp    (%ecx),%bl
  800871:	74 f1                	je     800864 <strncmp+0x1b>
  800873:	eb 0f                	jmp    800884 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	eb 05                	jmp    800881 <strncmp+0x38>
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800881:	5b                   	pop    %ebx
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 02             	movzbl (%edx),%eax
  800887:	0f b6 11             	movzbl (%ecx),%edx
  80088a:	29 d0                	sub    %edx,%eax
  80088c:	eb f3                	jmp    800881 <strncmp+0x38>

0080088e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800897:	8a 10                	mov    (%eax),%dl
  800899:	84 d2                	test   %dl,%dl
  80089b:	74 19                	je     8008b6 <strchr+0x28>
		if (*s == c)
  80089d:	38 ca                	cmp    %cl,%dl
  80089f:	75 07                	jne    8008a8 <strchr+0x1a>
  8008a1:	eb 18                	jmp    8008bb <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a3:	40                   	inc    %eax
		if (*s == c)
  8008a4:	38 ca                	cmp    %cl,%dl
  8008a6:	74 13                	je     8008bb <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a8:	8a 50 01             	mov    0x1(%eax),%dl
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f4                	jne    8008a3 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	eb 05                	jmp    8008bb <strchr+0x2d>
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c6:	8a 10                	mov    (%eax),%dl
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	74 11                	je     8008dd <strfind+0x20>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	75 06                	jne    8008d6 <strfind+0x19>
  8008d0:	eb 0b                	jmp    8008dd <strfind+0x20>
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 07                	je     8008dd <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	40                   	inc    %eax
  8008d7:	8a 10                	mov    (%eax),%dl
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f5                	jne    8008d2 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 30                	je     800922 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f8:	75 25                	jne    80091f <memset+0x40>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 20                	jne    80091f <memset+0x40>
		c &= 0xFF;
  8008ff:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	89 d3                	mov    %edx,%ebx
  800904:	c1 e3 08             	shl    $0x8,%ebx
  800907:	89 d6                	mov    %edx,%esi
  800909:	c1 e6 18             	shl    $0x18,%esi
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	c1 e0 10             	shl    $0x10,%eax
  800911:	09 f0                	or     %esi,%eax
  800913:	09 d0                	or     %edx,%eax
  800915:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800917:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091a:	fc                   	cld    
  80091b:	f3 ab                	rep stos %eax,%es:(%edi)
  80091d:	eb 03                	jmp    800922 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 34                	jae    80096f <memmove+0x46>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	73 2d                	jae    80096f <memmove+0x46>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	f6 c2 03             	test   $0x3,%dl
  800948:	75 1b                	jne    800965 <memmove+0x3c>
  80094a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800950:	75 13                	jne    800965 <memmove+0x3c>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 0e                	jne    800965 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800957:	83 ef 04             	sub    $0x4,%edi
  80095a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800960:	fd                   	std    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 07                	jmp    80096c <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800965:	4f                   	dec    %edi
  800966:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800969:	fd                   	std    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096c:	fc                   	cld    
  80096d:	eb 20                	jmp    80098f <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800975:	75 13                	jne    80098a <memmove+0x61>
  800977:	a8 03                	test   $0x3,%al
  800979:	75 0f                	jne    80098a <memmove+0x61>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0a                	jne    80098a <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800980:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 05                	jmp    80098f <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800999:	8b 45 10             	mov    0x10(%ebp),%eax
  80099c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	e8 77 ff ff ff       	call   800929 <memmove>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	85 ff                	test   %edi,%edi
  8009c5:	74 31                	je     8009f8 <memcmp+0x44>
		if (*s1 != *s2)
  8009c7:	8a 03                	mov    (%ebx),%al
  8009c9:	8a 0e                	mov    (%esi),%cl
  8009cb:	38 c8                	cmp    %cl,%al
  8009cd:	74 18                	je     8009e7 <memcmp+0x33>
  8009cf:	eb 0c                	jmp    8009dd <memcmp+0x29>
  8009d1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009d5:	42                   	inc    %edx
  8009d6:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  8009d9:	38 c8                	cmp    %cl,%al
  8009db:	74 10                	je     8009ed <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  8009dd:	0f b6 c0             	movzbl %al,%eax
  8009e0:	0f b6 c9             	movzbl %cl,%ecx
  8009e3:	29 c8                	sub    %ecx,%eax
  8009e5:	eb 16                	jmp    8009fd <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e7:	4f                   	dec    %edi
  8009e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ed:	39 fa                	cmp    %edi,%edx
  8009ef:	75 e0                	jne    8009d1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 05                	jmp    8009fd <memcmp+0x49>
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	73 12                	jae    800a23 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a11:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a14:	38 08                	cmp    %cl,(%eax)
  800a16:	75 06                	jne    800a1e <memfind+0x1c>
  800a18:	eb 09                	jmp    800a23 <memfind+0x21>
  800a1a:	38 08                	cmp    %cl,(%eax)
  800a1c:	74 05                	je     800a23 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1e:	40                   	inc    %eax
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	75 f7                	jne    800a1a <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a31:	eb 01                	jmp    800a34 <strtol+0xf>
		s++;
  800a33:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	8a 02                	mov    (%edx),%al
  800a36:	3c 20                	cmp    $0x20,%al
  800a38:	74 f9                	je     800a33 <strtol+0xe>
  800a3a:	3c 09                	cmp    $0x9,%al
  800a3c:	74 f5                	je     800a33 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3e:	3c 2b                	cmp    $0x2b,%al
  800a40:	75 08                	jne    800a4a <strtol+0x25>
		s++;
  800a42:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	eb 13                	jmp    800a5d <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4a:	3c 2d                	cmp    $0x2d,%al
  800a4c:	75 0a                	jne    800a58 <strtol+0x33>
		s++, neg = 1;
  800a4e:	8d 52 01             	lea    0x1(%edx),%edx
  800a51:	bf 01 00 00 00       	mov    $0x1,%edi
  800a56:	eb 05                	jmp    800a5d <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a58:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	74 05                	je     800a66 <strtol+0x41>
  800a61:	83 fb 10             	cmp    $0x10,%ebx
  800a64:	75 28                	jne    800a8e <strtol+0x69>
  800a66:	8a 02                	mov    (%edx),%al
  800a68:	3c 30                	cmp    $0x30,%al
  800a6a:	75 10                	jne    800a7c <strtol+0x57>
  800a6c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a70:	75 0a                	jne    800a7c <strtol+0x57>
		s += 2, base = 16;
  800a72:	83 c2 02             	add    $0x2,%edx
  800a75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7a:	eb 12                	jmp    800a8e <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	75 0e                	jne    800a8e <strtol+0x69>
  800a80:	3c 30                	cmp    $0x30,%al
  800a82:	75 05                	jne    800a89 <strtol+0x64>
		s++, base = 8;
  800a84:	42                   	inc    %edx
  800a85:	b3 08                	mov    $0x8,%bl
  800a87:	eb 05                	jmp    800a8e <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a89:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	8a 0a                	mov    (%edx),%cl
  800a97:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a9a:	80 fb 09             	cmp    $0x9,%bl
  800a9d:	77 08                	ja     800aa7 <strtol+0x82>
			dig = *s - '0';
  800a9f:	0f be c9             	movsbl %cl,%ecx
  800aa2:	83 e9 30             	sub    $0x30,%ecx
  800aa5:	eb 1e                	jmp    800ac5 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aa7:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aaa:	80 fb 19             	cmp    $0x19,%bl
  800aad:	77 08                	ja     800ab7 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aaf:	0f be c9             	movsbl %cl,%ecx
  800ab2:	83 e9 57             	sub    $0x57,%ecx
  800ab5:	eb 0e                	jmp    800ac5 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ab7:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aba:	80 fb 19             	cmp    $0x19,%bl
  800abd:	77 12                	ja     800ad1 <strtol+0xac>
			dig = *s - 'A' + 10;
  800abf:	0f be c9             	movsbl %cl,%ecx
  800ac2:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac5:	39 f1                	cmp    %esi,%ecx
  800ac7:	7d 0c                	jge    800ad5 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ac9:	42                   	inc    %edx
  800aca:	0f af c6             	imul   %esi,%eax
  800acd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb c4                	jmp    800a95 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad1:	89 c1                	mov    %eax,%ecx
  800ad3:	eb 02                	jmp    800ad7 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adb:	74 05                	je     800ae2 <strtol+0xbd>
		*endptr = (char *) s;
  800add:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	74 04                	je     800aea <strtol+0xc5>
  800ae6:	89 c8                	mov    %ecx,%eax
  800ae8:	f7 d8                	neg    %eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    
	...

00800af0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	51                   	push   %ecx
  800b05:	52                   	push   %edx
  800b06:	53                   	push   %ebx
  800b07:	54                   	push   %esp
  800b08:	55                   	push   %ebp
  800b09:	56                   	push   %esi
  800b0a:	57                   	push   %edi
  800b0b:	8d 35 15 0b 80 00    	lea    0x800b15,%esi
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	0f 34                	sysenter 

00800b15 <after_sysenter_label16>:
  800b15:	5f                   	pop    %edi
  800b16:	5e                   	pop    %esi
  800b17:	5d                   	pop    %ebp
  800b18:	5c                   	pop    %esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5a                   	pop    %edx
  800b1b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	51                   	push   %ecx
  800b36:	52                   	push   %edx
  800b37:	53                   	push   %ebx
  800b38:	54                   	push   %esp
  800b39:	55                   	push   %ebp
  800b3a:	56                   	push   %esi
  800b3b:	57                   	push   %edi
  800b3c:	8d 35 46 0b 80 00    	lea    0x800b46,%esi
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	0f 34                	sysenter 

00800b46 <after_sysenter_label41>:
  800b46:	5f                   	pop    %edi
  800b47:	5e                   	pop    %esi
  800b48:	5d                   	pop    %ebp
  800b49:	5c                   	pop    %esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5a                   	pop    %edx
  800b4c:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	53                   	push   %ebx
  800b56:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	89 cb                	mov    %ecx,%ebx
  800b68:	89 cf                	mov    %ecx,%edi
  800b6a:	51                   	push   %ecx
  800b6b:	52                   	push   %edx
  800b6c:	53                   	push   %ebx
  800b6d:	54                   	push   %esp
  800b6e:	55                   	push   %ebp
  800b6f:	56                   	push   %esi
  800b70:	57                   	push   %edi
  800b71:	8d 35 7b 0b 80 00    	lea    0x800b7b,%esi
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	0f 34                	sysenter 

00800b7b <after_sysenter_label68>:
  800b7b:	5f                   	pop    %edi
  800b7c:	5e                   	pop    %esi
  800b7d:	5d                   	pop    %ebp
  800b7e:	5c                   	pop    %esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5a                   	pop    %edx
  800b81:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 28                	jle    800bae <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8a:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b91:	00 
  800b92:	c7 44 24 08 3c 11 80 	movl   $0x80113c,0x8(%esp)
  800b99:	00 
  800b9a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ba1:	00 
  800ba2:	c7 04 24 59 11 80 00 	movl   $0x801159,(%esp)
  800ba9:	e8 9e 00 00 00       	call   800c4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bae:	83 c4 20             	add    $0x20,%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	89 d3                	mov    %edx,%ebx
  800bc8:	89 d7                	mov    %edx,%edi
  800bca:	51                   	push   %ecx
  800bcb:	52                   	push   %edx
  800bcc:	53                   	push   %ebx
  800bcd:	54                   	push   %esp
  800bce:	55                   	push   %ebp
  800bcf:	56                   	push   %esi
  800bd0:	57                   	push   %edi
  800bd1:	8d 35 db 0b 80 00    	lea    0x800bdb,%esi
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	0f 34                	sysenter 

00800bdb <after_sysenter_label107>:
  800bdb:	5f                   	pop    %edi
  800bdc:	5e                   	pop    %esi
  800bdd:	5d                   	pop    %ebp
  800bde:	5c                   	pop    %esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5a                   	pop    %edx
  800be1:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be2:	5b                   	pop    %ebx
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	51                   	push   %ecx
  800bfe:	52                   	push   %edx
  800bff:	53                   	push   %ebx
  800c00:	54                   	push   %esp
  800c01:	55                   	push   %ebp
  800c02:	56                   	push   %esi
  800c03:	57                   	push   %edi
  800c04:	8d 35 0e 0c 80 00    	lea    0x800c0e,%esi
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	0f 34                	sysenter 

00800c0e <after_sysenter_label133>:
  800c0e:	5f                   	pop    %edi
  800c0f:	5e                   	pop    %esi
  800c10:	5d                   	pop    %ebp
  800c11:	5c                   	pop    %esp
  800c12:	5b                   	pop    %ebx
  800c13:	5a                   	pop    %edx
  800c14:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c23:	b8 05 00 00 00       	mov    $0x5,%eax
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	89 cb                	mov    %ecx,%ebx
  800c2d:	89 cf                	mov    %ecx,%edi
  800c2f:	51                   	push   %ecx
  800c30:	52                   	push   %edx
  800c31:	53                   	push   %ebx
  800c32:	54                   	push   %esp
  800c33:	55                   	push   %ebp
  800c34:	56                   	push   %esi
  800c35:	57                   	push   %edi
  800c36:	8d 35 40 0c 80 00    	lea    0x800c40,%esi
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	0f 34                	sysenter 

00800c40 <after_sysenter_label159>:
  800c40:	5f                   	pop    %edi
  800c41:	5e                   	pop    %esi
  800c42:	5d                   	pop    %ebp
  800c43:	5c                   	pop    %esp
  800c44:	5b                   	pop    %ebx
  800c45:	5a                   	pop    %edx
  800c46:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    
	...

00800c4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c54:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c57:	a1 08 20 80 00       	mov    0x802008,%eax
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	74 10                	je     800c70 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c64:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800c6b:	e8 f0 f4 ff ff       	call   800160 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c70:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c76:	e8 3a ff ff ff       	call   800bb5 <sys_getenvid>
  800c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c91:	c7 04 24 6c 11 80 00 	movl   $0x80116c,(%esp)
  800c98:	e8 c3 f4 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c9d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca4:	89 04 24             	mov    %eax,(%esp)
  800ca7:	e8 53 f4 ff ff       	call   8000ff <vcprintf>
	cprintf("\n");
  800cac:	c7 04 24 1a 0f 80 00 	movl   $0x800f1a,(%esp)
  800cb3:	e8 a8 f4 ff ff       	call   800160 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cb8:	cc                   	int3   
  800cb9:	eb fd                	jmp    800cb8 <_panic+0x6c>
	...

00800cbc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800cbc:	55                   	push   %ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	83 ec 10             	sub    $0x10,%esp
  800cc2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cc6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800cd2:	89 cd                	mov    %ecx,%ebp
  800cd4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	75 2c                	jne    800d08 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800cdc:	39 f9                	cmp    %edi,%ecx
  800cde:	77 68                	ja     800d48 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ce0:	85 c9                	test   %ecx,%ecx
  800ce2:	75 0b                	jne    800cef <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ce4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce9:	31 d2                	xor    %edx,%edx
  800ceb:	f7 f1                	div    %ecx
  800ced:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cef:	31 d2                	xor    %edx,%edx
  800cf1:	89 f8                	mov    %edi,%eax
  800cf3:	f7 f1                	div    %ecx
  800cf5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf7:	89 f0                	mov    %esi,%eax
  800cf9:	f7 f1                	div    %ecx
  800cfb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cfd:	89 f0                	mov    %esi,%eax
  800cff:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d08:	39 f8                	cmp    %edi,%eax
  800d0a:	77 2c                	ja     800d38 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d0c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d0f:	83 f6 1f             	xor    $0x1f,%esi
  800d12:	75 4c                	jne    800d60 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d14:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d16:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d1b:	72 0a                	jb     800d27 <__udivdi3+0x6b>
  800d1d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d21:	0f 87 ad 00 00 00    	ja     800dd4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d27:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d2c:	89 f0                	mov    %esi,%eax
  800d2e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    
  800d37:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d38:	31 ff                	xor    %edi,%edi
  800d3a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d3c:	89 f0                	mov    %esi,%eax
  800d3e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    
  800d47:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d48:	89 fa                	mov    %edi,%edx
  800d4a:	89 f0                	mov    %esi,%eax
  800d4c:	f7 f1                	div    %ecx
  800d4e:	89 c6                	mov    %eax,%esi
  800d50:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d60:	89 f1                	mov    %esi,%ecx
  800d62:	d3 e0                	shl    %cl,%eax
  800d64:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d68:	b8 20 00 00 00       	mov    $0x20,%eax
  800d6d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d6f:	89 ea                	mov    %ebp,%edx
  800d71:	88 c1                	mov    %al,%cl
  800d73:	d3 ea                	shr    %cl,%edx
  800d75:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800d79:	09 ca                	or     %ecx,%edx
  800d7b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800d7f:	89 f1                	mov    %esi,%ecx
  800d81:	d3 e5                	shl    %cl,%ebp
  800d83:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800d87:	89 fd                	mov    %edi,%ebp
  800d89:	88 c1                	mov    %al,%cl
  800d8b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800d8d:	89 fa                	mov    %edi,%edx
  800d8f:	89 f1                	mov    %esi,%ecx
  800d91:	d3 e2                	shl    %cl,%edx
  800d93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d97:	88 c1                	mov    %al,%cl
  800d99:	d3 ef                	shr    %cl,%edi
  800d9b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d9d:	89 f8                	mov    %edi,%eax
  800d9f:	89 ea                	mov    %ebp,%edx
  800da1:	f7 74 24 08          	divl   0x8(%esp)
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800da9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dad:	39 d1                	cmp    %edx,%ecx
  800daf:	72 17                	jb     800dc8 <__udivdi3+0x10c>
  800db1:	74 09                	je     800dbc <__udivdi3+0x100>
  800db3:	89 fe                	mov    %edi,%esi
  800db5:	31 ff                	xor    %edi,%edi
  800db7:	e9 41 ff ff ff       	jmp    800cfd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800dbc:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dc0:	89 f1                	mov    %esi,%ecx
  800dc2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc4:	39 c2                	cmp    %eax,%edx
  800dc6:	73 eb                	jae    800db3 <__udivdi3+0xf7>
		{
		  q0--;
  800dc8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dcb:	31 ff                	xor    %edi,%edi
  800dcd:	e9 2b ff ff ff       	jmp    800cfd <__udivdi3+0x41>
  800dd2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd4:	31 f6                	xor    %esi,%esi
  800dd6:	e9 22 ff ff ff       	jmp    800cfd <__udivdi3+0x41>
	...

00800ddc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ddc:	55                   	push   %ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	83 ec 20             	sub    $0x20,%esp
  800de2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800de6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dea:	89 44 24 14          	mov    %eax,0x14(%esp)
  800dee:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800df2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800df6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800dfa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800dfc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dfe:	85 ed                	test   %ebp,%ebp
  800e00:	75 16                	jne    800e18 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e02:	39 f1                	cmp    %esi,%ecx
  800e04:	0f 86 a6 00 00 00    	jbe    800eb0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e0a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e0c:	89 d0                	mov    %edx,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e10:	83 c4 20             	add    $0x20,%esp
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
  800e17:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e18:	39 f5                	cmp    %esi,%ebp
  800e1a:	0f 87 ac 00 00 00    	ja     800ecc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e20:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e23:	83 f0 1f             	xor    $0x1f,%eax
  800e26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2a:	0f 84 a8 00 00 00    	je     800ed8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e30:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e34:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e36:	bf 20 00 00 00       	mov    $0x20,%edi
  800e3b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e3f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e43:	89 f9                	mov    %edi,%ecx
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	09 e8                	or     %ebp,%eax
  800e49:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e4d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e51:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e55:	d3 e0                	shl    %cl,%eax
  800e57:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e63:	d3 e0                	shl    %cl,%eax
  800e65:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e69:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e6d:	89 f9                	mov    %edi,%ecx
  800e6f:	d3 e8                	shr    %cl,%eax
  800e71:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e73:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e75:	89 f2                	mov    %esi,%edx
  800e77:	f7 74 24 18          	divl   0x18(%esp)
  800e7b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e7d:	f7 64 24 0c          	mull   0xc(%esp)
  800e81:	89 c5                	mov    %eax,%ebp
  800e83:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e85:	39 d6                	cmp    %edx,%esi
  800e87:	72 67                	jb     800ef0 <__umoddi3+0x114>
  800e89:	74 75                	je     800f00 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e8b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800e8f:	29 e8                	sub    %ebp,%eax
  800e91:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e93:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e97:	d3 e8                	shr    %cl,%eax
  800e99:	89 f2                	mov    %esi,%edx
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e9f:	09 d0                	or     %edx,%eax
  800ea1:	89 f2                	mov    %esi,%edx
  800ea3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ea7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea9:	83 c4 20             	add    $0x20,%esp
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eb0:	85 c9                	test   %ecx,%ecx
  800eb2:	75 0b                	jne    800ebf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb9:	31 d2                	xor    %edx,%edx
  800ebb:	f7 f1                	div    %ecx
  800ebd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ebf:	89 f0                	mov    %esi,%eax
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec5:	89 f8                	mov    %edi,%eax
  800ec7:	e9 3e ff ff ff       	jmp    800e0a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ecc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ece:	83 c4 20             	add    $0x20,%esp
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed8:	39 f5                	cmp    %esi,%ebp
  800eda:	72 04                	jb     800ee0 <__umoddi3+0x104>
  800edc:	39 f9                	cmp    %edi,%ecx
  800ede:	77 06                	ja     800ee6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee0:	89 f2                	mov    %esi,%edx
  800ee2:	29 cf                	sub    %ecx,%edi
  800ee4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ee6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee8:	83 c4 20             	add    $0x20,%esp
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    
  800eef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef0:	89 d1                	mov    %edx,%ecx
  800ef2:	89 c5                	mov    %eax,%ebp
  800ef4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800ef8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800efc:	eb 8d                	jmp    800e8b <__umoddi3+0xaf>
  800efe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f00:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f04:	72 ea                	jb     800ef0 <__umoddi3+0x114>
  800f06:	89 f1                	mov    %esi,%ecx
  800f08:	eb 81                	jmp    800e8b <__umoddi3+0xaf>
