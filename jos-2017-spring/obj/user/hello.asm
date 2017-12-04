
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 30 0f 80 00 	movl   $0x800f30,(%esp)
  800041:	e8 3e 01 00 00       	call   800184 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 3e 0f 80 00 	movl   $0x800f3e,(%esp)
  800059:	e8 26 01 00 00       	call   800184 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80006e:	e8 66 0b 00 00       	call   800bd9 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80007b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80007e:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  80008a:	c7 04 24 55 0f 80 00 	movl   $0x800f55,(%esp)
  800091:	e8 ee 00 00 00       	call   800184 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  800096:	a1 04 20 80 00       	mov    0x802004,%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 65 0f 80 00 	movl   $0x800f65,(%esp)
  8000a6:	e8 d9 00 00 00       	call   800184 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ab:	85 f6                	test   %esi,%esi
  8000ad:	7e 07                	jle    8000b6 <libmain+0x56>
		binaryname = argv[0];
  8000af:	8b 03                	mov    (%ebx),%eax
  8000b1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ba:	89 34 24             	mov    %esi,(%esp)
  8000bd:	e8 72 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c2:	e8 09 00 00 00       	call   8000d0 <exit>
}
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    
	...

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000dd:	e8 93 0a 00 00       	call   800b75 <sys_env_destroy>
}
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 14             	sub    $0x14,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 03                	mov    (%ebx),%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000f7:	40                   	inc    %eax
  8000f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	75 19                	jne    80011a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800101:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800108:	00 
  800109:	8d 43 08             	lea    0x8(%ebx),%eax
  80010c:	89 04 24             	mov    %eax,(%esp)
  80010f:	e8 00 0a 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  800114:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80011a:	ff 43 04             	incl   0x4(%ebx)
}
  80011d:	83 c4 14             	add    $0x14,%esp
  800120:	5b                   	pop    %ebx
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800133:	00 00 00 
	b.cnt = 0;
  800136:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800140:	8b 45 0c             	mov    0xc(%ebp),%eax
  800143:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800147:	8b 45 08             	mov    0x8(%ebp),%eax
  80014a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800154:	89 44 24 04          	mov    %eax,0x4(%esp)
  800158:	c7 04 24 e4 00 80 00 	movl   $0x8000e4,(%esp)
  80015f:	e8 8d 01 00 00       	call   8002f1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800164:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 98 09 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  80017c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 87 ff ff ff       	call   800123 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001c8:	72 0f                	jb     8001d9 <printnum+0x39>
  8001ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d0:	76 07                	jbe    8001d9 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d2:	4b                   	dec    %ebx
  8001d3:	85 db                	test   %ebx,%ebx
  8001d5:	7f 4f                	jg     800226 <printnum+0x86>
  8001d7:	eb 5a                	jmp    800233 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d9:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001dd:	4b                   	dec    %ebx
  8001de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001ed:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f8:	00 
  8001f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800202:	89 44 24 04          	mov    %eax,0x4(%esp)
  800206:	e8 d5 0a 00 00       	call   800ce0 <__udivdi3>
  80020b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021a:	89 fa                	mov    %edi,%edx
  80021c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021f:	e8 7c ff ff ff       	call   8001a0 <printnum>
  800224:	eb 0d                	jmp    800233 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800226:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022a:	89 34 24             	mov    %esi,(%esp)
  80022d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800230:	4b                   	dec    %ebx
  800231:	75 f3                	jne    800226 <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800237:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80023b:	8b 45 10             	mov    0x10(%ebp),%eax
  80023e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800242:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800249:	00 
  80024a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	e8 a4 0b 00 00       	call   800e00 <__umoddi3>
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	0f be 80 82 0f 80 00 	movsbl 0x800f82(%eax),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026d:	83 c4 3c             	add    $0x3c,%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800278:	83 fa 01             	cmp    $0x1,%edx
  80027b:	7e 0e                	jle    80028b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	8b 52 04             	mov    0x4(%edx),%edx
  800289:	eb 22                	jmp    8002ad <getuint+0x38>
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 10                	je     80029f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
  80029d:	eb 0e                	jmp    8002ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 08                	jae    8002c7 <sprintputch+0x18>
		*b->buf++ = ch;
  8002bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c2:	88 0a                	mov    %cl,(%edx)
  8002c4:	42                   	inc    %edx
  8002c5:	89 10                	mov    %edx,(%eax)
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	e8 02 00 00 00       	call   8002f1 <vprintfmt>
	va_end(ap);
}
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 4c             	sub    $0x4c,%esp
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 75 10             	mov    0x10(%ebp),%esi
  800300:	eb 17                	jmp    800319 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800302:	85 c0                	test   %eax,%eax
  800304:	0f 84 93 03 00 00    	je     80069d <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80030a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	ff 55 08             	call   *0x8(%ebp)
  800314:	eb 03                	jmp    800319 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800319:	0f b6 06             	movzbl (%esi),%eax
  80031c:	46                   	inc    %esi
  80031d:	83 f8 25             	cmp    $0x25,%eax
  800320:	75 e0                	jne    800302 <vprintfmt+0x11>
  800322:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800326:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80032d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800332:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	eb 26                	jmp    800366 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800347:	eb 1d                	jmp    800366 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800350:	eb 14                	jmp    800366 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800355:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035c:	eb 08                	jmp    800366 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800361:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	0f b6 16             	movzbl (%esi),%edx
  800369:	8d 46 01             	lea    0x1(%esi),%eax
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	8a 06                	mov    (%esi),%al
  800371:	83 e8 23             	sub    $0x23,%eax
  800374:	3c 55                	cmp    $0x55,%al
  800376:	0f 87 fd 02 00 00    	ja     800679 <vprintfmt+0x388>
  80037c:	0f b6 c0             	movzbl %al,%eax
  80037f:	ff 24 85 10 10 80 00 	jmp    *0x801010(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800386:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  800389:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80038d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800390:	83 fa 09             	cmp    $0x9,%edx
  800393:	77 3f                	ja     8003d4 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800398:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800399:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80039c:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003a0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a3:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a6:	83 fa 09             	cmp    $0x9,%edx
  8003a9:	76 ed                	jbe    800398 <vprintfmt+0xa7>
  8003ab:	eb 2a                	jmp    8003d7 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bb:	eb 1a                	jmp    8003d7 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c1:	78 8f                	js     800352 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c6:	eb 9e                	jmp    800366 <vprintfmt+0x75>
  8003c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cb:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003d2:	eb 92                	jmp    800366 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003db:	79 89                	jns    800366 <vprintfmt+0x75>
  8003dd:	e9 7c ff ff ff       	jmp    80035e <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e6:	e9 7b ff ff ff       	jmp    800366 <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800403:	e9 11 ff ff ff       	jmp    800319 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	8b 00                	mov    (%eax),%eax
  800413:	85 c0                	test   %eax,%eax
  800415:	79 02                	jns    800419 <vprintfmt+0x128>
  800417:	f7 d8                	neg    %eax
  800419:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 06             	cmp    $0x6,%eax
  80041e:	7f 0b                	jg     80042b <vprintfmt+0x13a>
  800420:	8b 04 85 68 11 80 00 	mov    0x801168(,%eax,4),%eax
  800427:	85 c0                	test   %eax,%eax
  800429:	75 23                	jne    80044e <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80042b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042f:	c7 44 24 08 9a 0f 80 	movl   $0x800f9a,0x8(%esp)
  800436:	00 
  800437:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043b:	8b 55 08             	mov    0x8(%ebp),%edx
  80043e:	89 14 24             	mov    %edx,(%esp)
  800441:	e8 83 fe ff ff       	call   8002c9 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800449:	e9 cb fe ff ff       	jmp    800319 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  80044e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800452:	c7 44 24 08 a3 0f 80 	movl   $0x800fa3,0x8(%esp)
  800459:	00 
  80045a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800461:	89 0c 24             	mov    %ecx,(%esp)
  800464:	e8 60 fe ff ff       	call   8002c9 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046c:	e9 a8 fe ff ff       	jmp    800319 <vprintfmt+0x28>
  800471:	89 f9                	mov    %edi,%ecx
  800473:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800484:	85 c0                	test   %eax,%eax
  800486:	75 07                	jne    80048f <vprintfmt+0x19e>
				p = "(null)";
  800488:	c7 45 d4 93 0f 80 00 	movl   $0x800f93,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80048f:	85 f6                	test   %esi,%esi
  800491:	7e 3b                	jle    8004ce <vprintfmt+0x1dd>
  800493:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800497:	74 35                	je     8004ce <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 a4 02 00 00       	call   80074c <strnlen>
  8004a8:	29 c6                	sub    %eax,%esi
  8004aa:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004ad:	85 f6                	test   %esi,%esi
  8004af:	7e 1d                	jle    8004ce <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004b1:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004b5:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bf:	89 34 24             	mov    %esi,(%esp)
  8004c2:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	4f                   	dec    %edi
  8004c6:	75 f3                	jne    8004bb <vprintfmt+0x1ca>
  8004c8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004cb:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d1:	0f be 02             	movsbl (%edx),%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	75 43                	jne    80051b <vprintfmt+0x22a>
  8004d8:	eb 33                	jmp    80050d <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004de:	74 18                	je     8004f8 <vprintfmt+0x207>
  8004e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e3:	83 fa 5e             	cmp    $0x5e,%edx
  8004e6:	76 10                	jbe    8004f8 <vprintfmt+0x207>
					putch('?', putdat);
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	eb 0a                	jmp    800502 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	ff 4d e4             	decl   -0x1c(%ebp)
  800505:	0f be 06             	movsbl (%esi),%eax
  800508:	46                   	inc    %esi
  800509:	85 c0                	test   %eax,%eax
  80050b:	75 12                	jne    80051f <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800511:	7f 15                	jg     800528 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 fe fd ff ff       	jmp    800319 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80051e:	46                   	inc    %esi
  80051f:	85 ff                	test   %edi,%edi
  800521:	78 b7                	js     8004da <vprintfmt+0x1e9>
  800523:	4f                   	dec    %edi
  800524:	79 b4                	jns    8004da <vprintfmt+0x1e9>
  800526:	eb e5                	jmp    80050d <vprintfmt+0x21c>
  800528:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80052b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800532:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800539:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053b:	4e                   	dec    %esi
  80053c:	75 f0                	jne    80052e <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800541:	e9 d3 fd ff ff       	jmp    800319 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800546:	83 f9 01             	cmp    $0x1,%ecx
  800549:	7e 10                	jle    80055b <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 50 08             	lea    0x8(%eax),%edx
  800551:	89 55 14             	mov    %edx,0x14(%ebp)
  800554:	8b 30                	mov    (%eax),%esi
  800556:	8b 78 04             	mov    0x4(%eax),%edi
  800559:	eb 26                	jmp    800581 <vprintfmt+0x290>
	else if (lflag)
  80055b:	85 c9                	test   %ecx,%ecx
  80055d:	74 12                	je     800571 <vprintfmt+0x280>
		return va_arg(*ap, long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 30                	mov    (%eax),%esi
  80056a:	89 f7                	mov    %esi,%edi
  80056c:	c1 ff 1f             	sar    $0x1f,%edi
  80056f:	eb 10                	jmp    800581 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 30                	mov    (%eax),%esi
  80057c:	89 f7                	mov    %esi,%edi
  80057e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800581:	85 ff                	test   %edi,%edi
  800583:	78 0e                	js     800593 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800585:	89 f0                	mov    %esi,%eax
  800587:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800589:	be 0a 00 00 00       	mov    $0xa,%esi
  80058e:	e9 a8 00 00 00       	jmp    80063b <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800593:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800597:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a1:	89 f0                	mov    %esi,%eax
  8005a3:	89 fa                	mov    %edi,%edx
  8005a5:	f7 d8                	neg    %eax
  8005a7:	83 d2 00             	adc    $0x0,%edx
  8005aa:	f7 da                	neg    %edx
			}
			base = 10;
  8005ac:	be 0a 00 00 00       	mov    $0xa,%esi
  8005b1:	e9 85 00 00 00       	jmp    80063b <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b6:	89 ca                	mov    %ecx,%edx
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	e8 b5 fc ff ff       	call   800275 <getuint>
			base = 10;
  8005c0:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005c5:	eb 74                	jmp    80063b <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cb:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005d2:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d9:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005e0:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005f4:	e9 20 fd ff ff       	jmp    800319 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800604:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800607:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800612:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800625:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80062a:	eb 0f                	jmp    80063b <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 3f fc ff ff       	call   800275 <getuint>
			base = 16;
  800636:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063b:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80063f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800643:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800646:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80064a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	89 54 24 04          	mov    %edx,0x4(%esp)
  800655:	89 da                	mov    %ebx,%edx
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	e8 41 fb ff ff       	call   8001a0 <printnum>
			break;
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	e9 b2 fc ff ff       	jmp    800319 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	89 14 24             	mov    %edx,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800674:	e9 a0 fc ff ff       	jmp    800319 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800679:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800684:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800687:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068b:	0f 84 88 fc ff ff    	je     800319 <vprintfmt+0x28>
  800691:	4e                   	dec    %esi
  800692:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800696:	75 f9                	jne    800691 <vprintfmt+0x3a0>
  800698:	e9 7c fc ff ff       	jmp    800319 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  80069d:	83 c4 4c             	add    $0x4c,%esp
  8006a0:	5b                   	pop    %ebx
  8006a1:	5e                   	pop    %esi
  8006a2:	5f                   	pop    %edi
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 28             	sub    $0x28,%esp
  8006ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	74 30                	je     8006f6 <vsnprintf+0x51>
  8006c6:	85 d2                	test   %edx,%edx
  8006c8:	7e 33                	jle    8006fd <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	c7 04 24 af 02 80 00 	movl   $0x8002af,(%esp)
  8006e6:	e8 06 fc ff ff       	call   8002f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	eb 0c                	jmp    800702 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fb:	eb 05                	jmp    800702 <vsnprintf+0x5d>
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800711:	8b 45 10             	mov    0x10(%ebp),%eax
  800714:	89 44 24 08          	mov    %eax,0x8(%esp)
  800718:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	89 04 24             	mov    %eax,(%esp)
  800725:	e8 7b ff ff ff       	call   8006a5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	80 3a 00             	cmpb   $0x0,(%edx)
  800735:	74 0e                	je     800745 <strlen+0x19>
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80073c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800741:	75 f9                	jne    80073c <strlen+0x10>
  800743:	eb 05                	jmp    80074a <strlen+0x1e>
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	85 c9                	test   %ecx,%ecx
  800758:	74 1a                	je     800774 <strnlen+0x28>
  80075a:	80 3b 00             	cmpb   $0x0,(%ebx)
  80075d:	74 1c                	je     80077b <strnlen+0x2f>
  80075f:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800764:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	39 ca                	cmp    %ecx,%edx
  800768:	74 16                	je     800780 <strnlen+0x34>
  80076a:	42                   	inc    %edx
  80076b:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800770:	75 f2                	jne    800764 <strnlen+0x18>
  800772:	eb 0c                	jmp    800780 <strnlen+0x34>
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	eb 05                	jmp    800780 <strnlen+0x34>
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
  800792:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800795:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800798:	42                   	inc    %edx
  800799:	84 c9                	test   %cl,%cl
  80079b:	75 f5                	jne    800792 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	89 1c 24             	mov    %ebx,(%esp)
  8007ad:	e8 7a ff ff ff       	call   80072c <strlen>
	strcpy(dst + len, src);
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b9:	01 d8                	add    %ebx,%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 c0 ff ff ff       	call   800783 <strcpy>
	return dst;
}
  8007c3:	89 d8                	mov    %ebx,%eax
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	85 f6                	test   %esi,%esi
  8007db:	74 15                	je     8007f2 <strncpy+0x27>
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007e2:	8a 1a                	mov    (%edx),%bl
  8007e4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e7:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ea:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	41                   	inc    %ecx
  8007ee:	39 f1                	cmp    %esi,%ecx
  8007f0:	75 f0                	jne    8007e2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	57                   	push   %edi
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800802:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800805:	85 f6                	test   %esi,%esi
  800807:	74 31                	je     80083a <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  800809:	83 fe 01             	cmp    $0x1,%esi
  80080c:	74 21                	je     80082f <strlcpy+0x39>
  80080e:	8a 0b                	mov    (%ebx),%cl
  800810:	84 c9                	test   %cl,%cl
  800812:	74 1f                	je     800833 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800814:	83 ee 02             	sub    $0x2,%esi
  800817:	89 f8                	mov    %edi,%eax
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081e:	88 08                	mov    %cl,(%eax)
  800820:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800821:	39 f2                	cmp    %esi,%edx
  800823:	74 10                	je     800835 <strlcpy+0x3f>
  800825:	42                   	inc    %edx
  800826:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 f1                	jne    80081e <strlcpy+0x28>
  80082d:	eb 06                	jmp    800835 <strlcpy+0x3f>
  80082f:	89 f8                	mov    %edi,%eax
  800831:	eb 02                	jmp    800835 <strlcpy+0x3f>
  800833:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800835:	c6 00 00             	movb   $0x0,(%eax)
  800838:	eb 02                	jmp    80083c <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80083c:	29 f8                	sub    %edi,%eax
}
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5f                   	pop    %edi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084c:	8a 01                	mov    (%ecx),%al
  80084e:	84 c0                	test   %al,%al
  800850:	74 11                	je     800863 <strcmp+0x20>
  800852:	3a 02                	cmp    (%edx),%al
  800854:	75 0d                	jne    800863 <strcmp+0x20>
		p++, q++;
  800856:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800857:	8a 41 01             	mov    0x1(%ecx),%al
  80085a:	84 c0                	test   %al,%al
  80085c:	74 05                	je     800863 <strcmp+0x20>
  80085e:	41                   	inc    %ecx
  80085f:	3a 02                	cmp    (%edx),%al
  800861:	74 f3                	je     800856 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 c0             	movzbl %al,%eax
  800866:	0f b6 12             	movzbl (%edx),%edx
  800869:	29 d0                	sub    %edx,%eax
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	8b 55 08             	mov    0x8(%ebp),%edx
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80087a:	85 c0                	test   %eax,%eax
  80087c:	74 1b                	je     800899 <strncmp+0x2c>
  80087e:	8a 1a                	mov    (%edx),%bl
  800880:	84 db                	test   %bl,%bl
  800882:	74 24                	je     8008a8 <strncmp+0x3b>
  800884:	3a 19                	cmp    (%ecx),%bl
  800886:	75 20                	jne    8008a8 <strncmp+0x3b>
  800888:	48                   	dec    %eax
  800889:	74 15                	je     8008a0 <strncmp+0x33>
		n--, p++, q++;
  80088b:	42                   	inc    %edx
  80088c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	8a 1a                	mov    (%edx),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	74 15                	je     8008a8 <strncmp+0x3b>
  800893:	3a 19                	cmp    (%ecx),%bl
  800895:	74 f1                	je     800888 <strncmp+0x1b>
  800897:	eb 0f                	jmp    8008a8 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	eb 05                	jmp    8008a5 <strncmp+0x38>
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 02             	movzbl (%edx),%eax
  8008ab:	0f b6 11             	movzbl (%ecx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
  8008b0:	eb f3                	jmp    8008a5 <strncmp+0x38>

008008b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bb:	8a 10                	mov    (%eax),%dl
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	74 19                	je     8008da <strchr+0x28>
		if (*s == c)
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	75 07                	jne    8008cc <strchr+0x1a>
  8008c5:	eb 18                	jmp    8008df <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c7:	40                   	inc    %eax
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	74 13                	je     8008df <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cc:	8a 50 01             	mov    0x1(%eax),%dl
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f4                	jne    8008c7 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb 05                	jmp    8008df <strchr+0x2d>
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ea:	8a 10                	mov    (%eax),%dl
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 11                	je     800901 <strfind+0x20>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	75 06                	jne    8008fa <strfind+0x19>
  8008f4:	eb 0b                	jmp    800901 <strfind+0x20>
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 07                	je     800901 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008fa:	40                   	inc    %eax
  8008fb:	8a 10                	mov    (%eax),%dl
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f5                	jne    8008f6 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800912:	85 c9                	test   %ecx,%ecx
  800914:	74 30                	je     800946 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800916:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091c:	75 25                	jne    800943 <memset+0x40>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 20                	jne    800943 <memset+0x40>
		c &= 0xFF;
  800923:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800926:	89 d3                	mov    %edx,%ebx
  800928:	c1 e3 08             	shl    $0x8,%ebx
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	c1 e6 18             	shl    $0x18,%esi
  800930:	89 d0                	mov    %edx,%eax
  800932:	c1 e0 10             	shl    $0x10,%eax
  800935:	09 f0                	or     %esi,%eax
  800937:	09 d0                	or     %edx,%eax
  800939:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093b:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb 03                	jmp    800946 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800943:	fc                   	cld    
  800944:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800946:	89 f8                	mov    %edi,%eax
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 75 0c             	mov    0xc(%ebp),%esi
  800958:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095b:	39 c6                	cmp    %eax,%esi
  80095d:	73 34                	jae    800993 <memmove+0x46>
  80095f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800962:	39 d0                	cmp    %edx,%eax
  800964:	73 2d                	jae    800993 <memmove+0x46>
		s += n;
		d += n;
  800966:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	f6 c2 03             	test   $0x3,%dl
  80096c:	75 1b                	jne    800989 <memmove+0x3c>
  80096e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800974:	75 13                	jne    800989 <memmove+0x3c>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0e                	jne    800989 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097b:	83 ef 04             	sub    $0x4,%edi
  80097e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800981:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800984:	fd                   	std    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 07                	jmp    800990 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800989:	4f                   	dec    %edi
  80098a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098d:	fd                   	std    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800990:	fc                   	cld    
  800991:	eb 20                	jmp    8009b3 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800999:	75 13                	jne    8009ae <memmove+0x61>
  80099b:	a8 03                	test   $0x3,%al
  80099d:	75 0f                	jne    8009ae <memmove+0x61>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 0a                	jne    8009ae <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ac:	eb 05                	jmp    8009b3 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ae:	89 c7                	mov    %eax,%edi
  8009b0:	fc                   	cld    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 77 ff ff ff       	call   80094d <memmove>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e7:	85 ff                	test   %edi,%edi
  8009e9:	74 31                	je     800a1c <memcmp+0x44>
		if (*s1 != *s2)
  8009eb:	8a 03                	mov    (%ebx),%al
  8009ed:	8a 0e                	mov    (%esi),%cl
  8009ef:	38 c8                	cmp    %cl,%al
  8009f1:	74 18                	je     800a0b <memcmp+0x33>
  8009f3:	eb 0c                	jmp    800a01 <memcmp+0x29>
  8009f5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009f9:	42                   	inc    %edx
  8009fa:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  8009fd:	38 c8                	cmp    %cl,%al
  8009ff:	74 10                	je     800a11 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 c9             	movzbl %cl,%ecx
  800a07:	29 c8                	sub    %ecx,%eax
  800a09:	eb 16                	jmp    800a21 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	4f                   	dec    %edi
  800a0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a11:	39 fa                	cmp    %edi,%edx
  800a13:	75 e0                	jne    8009f5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	eb 05                	jmp    800a21 <memcmp+0x49>
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2c:	89 c2                	mov    %eax,%edx
  800a2e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a31:	39 d0                	cmp    %edx,%eax
  800a33:	73 12                	jae    800a47 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a35:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a38:	38 08                	cmp    %cl,(%eax)
  800a3a:	75 06                	jne    800a42 <memfind+0x1c>
  800a3c:	eb 09                	jmp    800a47 <memfind+0x21>
  800a3e:	38 08                	cmp    %cl,(%eax)
  800a40:	74 05                	je     800a47 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a42:	40                   	inc    %eax
  800a43:	39 d0                	cmp    %edx,%eax
  800a45:	75 f7                	jne    800a3e <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	eb 01                	jmp    800a58 <strtol+0xf>
		s++;
  800a57:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a58:	8a 02                	mov    (%edx),%al
  800a5a:	3c 20                	cmp    $0x20,%al
  800a5c:	74 f9                	je     800a57 <strtol+0xe>
  800a5e:	3c 09                	cmp    $0x9,%al
  800a60:	74 f5                	je     800a57 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a62:	3c 2b                	cmp    $0x2b,%al
  800a64:	75 08                	jne    800a6e <strtol+0x25>
		s++;
  800a66:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6c:	eb 13                	jmp    800a81 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6e:	3c 2d                	cmp    $0x2d,%al
  800a70:	75 0a                	jne    800a7c <strtol+0x33>
		s++, neg = 1;
  800a72:	8d 52 01             	lea    0x1(%edx),%edx
  800a75:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7a:	eb 05                	jmp    800a81 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	74 05                	je     800a8a <strtol+0x41>
  800a85:	83 fb 10             	cmp    $0x10,%ebx
  800a88:	75 28                	jne    800ab2 <strtol+0x69>
  800a8a:	8a 02                	mov    (%edx),%al
  800a8c:	3c 30                	cmp    $0x30,%al
  800a8e:	75 10                	jne    800aa0 <strtol+0x57>
  800a90:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a94:	75 0a                	jne    800aa0 <strtol+0x57>
		s += 2, base = 16;
  800a96:	83 c2 02             	add    $0x2,%edx
  800a99:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9e:	eb 12                	jmp    800ab2 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	75 0e                	jne    800ab2 <strtol+0x69>
  800aa4:	3c 30                	cmp    $0x30,%al
  800aa6:	75 05                	jne    800aad <strtol+0x64>
		s++, base = 8;
  800aa8:	42                   	inc    %edx
  800aa9:	b3 08                	mov    $0x8,%bl
  800aab:	eb 05                	jmp    800ab2 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aad:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab9:	8a 0a                	mov    (%edx),%cl
  800abb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	77 08                	ja     800acb <strtol+0x82>
			dig = *s - '0';
  800ac3:	0f be c9             	movsbl %cl,%ecx
  800ac6:	83 e9 30             	sub    $0x30,%ecx
  800ac9:	eb 1e                	jmp    800ae9 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ace:	80 fb 19             	cmp    $0x19,%bl
  800ad1:	77 08                	ja     800adb <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad3:	0f be c9             	movsbl %cl,%ecx
  800ad6:	83 e9 57             	sub    $0x57,%ecx
  800ad9:	eb 0e                	jmp    800ae9 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800adb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 12                	ja     800af5 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae3:	0f be c9             	movsbl %cl,%ecx
  800ae6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae9:	39 f1                	cmp    %esi,%ecx
  800aeb:	7d 0c                	jge    800af9 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aed:	42                   	inc    %edx
  800aee:	0f af c6             	imul   %esi,%eax
  800af1:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af3:	eb c4                	jmp    800ab9 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af5:	89 c1                	mov    %eax,%ecx
  800af7:	eb 02                	jmp    800afb <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aff:	74 05                	je     800b06 <strtol+0xbd>
		*endptr = (char *) s;
  800b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b04:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b06:	85 ff                	test   %edi,%edi
  800b08:	74 04                	je     800b0e <strtol+0xc5>
  800b0a:	89 c8                	mov    %ecx,%eax
  800b0c:	f7 d8                	neg    %eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    
	...

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b21:	8b 55 08             	mov    0x8(%ebp),%edx
  800b24:	89 c3                	mov    %eax,%ebx
  800b26:	89 c7                	mov    %eax,%edi
  800b28:	51                   	push   %ecx
  800b29:	52                   	push   %edx
  800b2a:	53                   	push   %ebx
  800b2b:	54                   	push   %esp
  800b2c:	55                   	push   %ebp
  800b2d:	56                   	push   %esi
  800b2e:	57                   	push   %edi
  800b2f:	8d 35 39 0b 80 00    	lea    0x800b39,%esi
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	0f 34                	sysenter 

00800b39 <after_sysenter_label16>:
  800b39:	5f                   	pop    %edi
  800b3a:	5e                   	pop    %esi
  800b3b:	5d                   	pop    %ebp
  800b3c:	5c                   	pop    %esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5a                   	pop    %edx
  800b3f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	51                   	push   %ecx
  800b5a:	52                   	push   %edx
  800b5b:	53                   	push   %ebx
  800b5c:	54                   	push   %esp
  800b5d:	55                   	push   %ebp
  800b5e:	56                   	push   %esi
  800b5f:	57                   	push   %edi
  800b60:	8d 35 6a 0b 80 00    	lea    0x800b6a,%esi
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	0f 34                	sysenter 

00800b6a <after_sysenter_label41>:
  800b6a:	5f                   	pop    %edi
  800b6b:	5e                   	pop    %esi
  800b6c:	5d                   	pop    %ebp
  800b6d:	5c                   	pop    %esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5a                   	pop    %edx
  800b70:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	53                   	push   %ebx
  800b7a:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	89 cb                	mov    %ecx,%ebx
  800b8c:	89 cf                	mov    %ecx,%edi
  800b8e:	51                   	push   %ecx
  800b8f:	52                   	push   %edx
  800b90:	53                   	push   %ebx
  800b91:	54                   	push   %esp
  800b92:	55                   	push   %ebp
  800b93:	56                   	push   %esi
  800b94:	57                   	push   %edi
  800b95:	8d 35 9f 0b 80 00    	lea    0x800b9f,%esi
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	0f 34                	sysenter 

00800b9f <after_sysenter_label68>:
  800b9f:	5f                   	pop    %edi
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	5c                   	pop    %esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5a                   	pop    %edx
  800ba5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ba6:	85 c0                	test   %eax,%eax
  800ba8:	7e 28                	jle    800bd2 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bae:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb5:	00 
  800bb6:	c7 44 24 08 84 11 80 	movl   $0x801184,0x8(%esp)
  800bbd:	00 
  800bbe:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800bc5:	00 
  800bc6:	c7 04 24 a1 11 80 00 	movl   $0x8011a1,(%esp)
  800bcd:	e8 9e 00 00 00       	call   800c70 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	83 c4 20             	add    $0x20,%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	b8 02 00 00 00       	mov    $0x2,%eax
  800be8:	89 d1                	mov    %edx,%ecx
  800bea:	89 d3                	mov    %edx,%ebx
  800bec:	89 d7                	mov    %edx,%edi
  800bee:	51                   	push   %ecx
  800bef:	52                   	push   %edx
  800bf0:	53                   	push   %ebx
  800bf1:	54                   	push   %esp
  800bf2:	55                   	push   %ebp
  800bf3:	56                   	push   %esi
  800bf4:	57                   	push   %edi
  800bf5:	8d 35 ff 0b 80 00    	lea    0x800bff,%esi
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	0f 34                	sysenter 

00800bff <after_sysenter_label107>:
  800bff:	5f                   	pop    %edi
  800c00:	5e                   	pop    %esi
  800c01:	5d                   	pop    %ebp
  800c02:	5c                   	pop    %esp
  800c03:	5b                   	pop    %ebx
  800c04:	5a                   	pop    %edx
  800c05:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c06:	5b                   	pop    %ebx
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 04 00 00 00       	mov    $0x4,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	51                   	push   %ecx
  800c22:	52                   	push   %edx
  800c23:	53                   	push   %ebx
  800c24:	54                   	push   %esp
  800c25:	55                   	push   %ebp
  800c26:	56                   	push   %esi
  800c27:	57                   	push   %edi
  800c28:	8d 35 32 0c 80 00    	lea    0x800c32,%esi
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	0f 34                	sysenter 

00800c32 <after_sysenter_label133>:
  800c32:	5f                   	pop    %edi
  800c33:	5e                   	pop    %esi
  800c34:	5d                   	pop    %ebp
  800c35:	5c                   	pop    %esp
  800c36:	5b                   	pop    %ebx
  800c37:	5a                   	pop    %edx
  800c38:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	51                   	push   %ecx
  800c54:	52                   	push   %edx
  800c55:	53                   	push   %ebx
  800c56:	54                   	push   %esp
  800c57:	55                   	push   %ebp
  800c58:	56                   	push   %esi
  800c59:	57                   	push   %edi
  800c5a:	8d 35 64 0c 80 00    	lea    0x800c64,%esi
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	0f 34                	sysenter 

00800c64 <after_sysenter_label159>:
  800c64:	5f                   	pop    %edi
  800c65:	5e                   	pop    %esi
  800c66:	5d                   	pop    %ebp
  800c67:	5c                   	pop    %esp
  800c68:	5b                   	pop    %ebx
  800c69:	5a                   	pop    %edx
  800c6a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    
	...

00800c70 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c78:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800c7b:	a1 08 20 80 00       	mov    0x802008,%eax
  800c80:	85 c0                	test   %eax,%eax
  800c82:	74 10                	je     800c94 <_panic+0x24>
		cprintf("%s: ", argv0);
  800c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c88:	c7 04 24 af 11 80 00 	movl   $0x8011af,(%esp)
  800c8f:	e8 f0 f4 ff ff       	call   800184 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c94:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c9a:	e8 3a ff ff ff       	call   800bd9 <sys_getenvid>
  800c9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca2:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb5:	c7 04 24 b4 11 80 00 	movl   $0x8011b4,(%esp)
  800cbc:	e8 c3 f4 ff ff       	call   800184 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc8:	89 04 24             	mov    %eax,(%esp)
  800ccb:	e8 53 f4 ff ff       	call   800123 <vcprintf>
	cprintf("\n");
  800cd0:	c7 04 24 3c 0f 80 00 	movl   $0x800f3c,(%esp)
  800cd7:	e8 a8 f4 ff ff       	call   800184 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cdc:	cc                   	int3   
  800cdd:	eb fd                	jmp    800cdc <_panic+0x6c>
	...

00800ce0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	83 ec 10             	sub    $0x10,%esp
  800ce6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800cea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800cf6:	89 cd                	mov    %ecx,%ebp
  800cf8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	75 2c                	jne    800d2c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d00:	39 f9                	cmp    %edi,%ecx
  800d02:	77 68                	ja     800d6c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d04:	85 c9                	test   %ecx,%ecx
  800d06:	75 0b                	jne    800d13 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d08:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0d:	31 d2                	xor    %edx,%edx
  800d0f:	f7 f1                	div    %ecx
  800d11:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d13:	31 d2                	xor    %edx,%edx
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	f7 f1                	div    %ecx
  800d19:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d1b:	89 f0                	mov    %esi,%eax
  800d1d:	f7 f1                	div    %ecx
  800d1f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d2c:	39 f8                	cmp    %edi,%eax
  800d2e:	77 2c                	ja     800d5c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d30:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d33:	83 f6 1f             	xor    $0x1f,%esi
  800d36:	75 4c                	jne    800d84 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d38:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d3a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d3f:	72 0a                	jb     800d4b <__udivdi3+0x6b>
  800d41:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d45:	0f 87 ad 00 00 00    	ja     800df8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d4b:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d5c:	31 ff                	xor    %edi,%edi
  800d5e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d60:	89 f0                	mov    %esi,%eax
  800d62:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    
  800d6b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d6c:	89 fa                	mov    %edi,%edx
  800d6e:	89 f0                	mov    %esi,%eax
  800d70:	f7 f1                	div    %ecx
  800d72:	89 c6                	mov    %eax,%esi
  800d74:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d76:	89 f0                	mov    %esi,%eax
  800d78:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    
  800d81:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d84:	89 f1                	mov    %esi,%ecx
  800d86:	d3 e0                	shl    %cl,%eax
  800d88:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d93:	89 ea                	mov    %ebp,%edx
  800d95:	88 c1                	mov    %al,%cl
  800d97:	d3 ea                	shr    %cl,%edx
  800d99:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800d9d:	09 ca                	or     %ecx,%edx
  800d9f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800da3:	89 f1                	mov    %esi,%ecx
  800da5:	d3 e5                	shl    %cl,%ebp
  800da7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800dab:	89 fd                	mov    %edi,%ebp
  800dad:	88 c1                	mov    %al,%cl
  800daf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800db1:	89 fa                	mov    %edi,%edx
  800db3:	89 f1                	mov    %esi,%ecx
  800db5:	d3 e2                	shl    %cl,%edx
  800db7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dbb:	88 c1                	mov    %al,%cl
  800dbd:	d3 ef                	shr    %cl,%edi
  800dbf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dc1:	89 f8                	mov    %edi,%eax
  800dc3:	89 ea                	mov    %ebp,%edx
  800dc5:	f7 74 24 08          	divl   0x8(%esp)
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800dcd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd1:	39 d1                	cmp    %edx,%ecx
  800dd3:	72 17                	jb     800dec <__udivdi3+0x10c>
  800dd5:	74 09                	je     800de0 <__udivdi3+0x100>
  800dd7:	89 fe                	mov    %edi,%esi
  800dd9:	31 ff                	xor    %edi,%edi
  800ddb:	e9 41 ff ff ff       	jmp    800d21 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800de0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800de4:	89 f1                	mov    %esi,%ecx
  800de6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800de8:	39 c2                	cmp    %eax,%edx
  800dea:	73 eb                	jae    800dd7 <__udivdi3+0xf7>
		{
		  q0--;
  800dec:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800def:	31 ff                	xor    %edi,%edi
  800df1:	e9 2b ff ff ff       	jmp    800d21 <__udivdi3+0x41>
  800df6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800df8:	31 f6                	xor    %esi,%esi
  800dfa:	e9 22 ff ff ff       	jmp    800d21 <__udivdi3+0x41>
	...

00800e00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	83 ec 20             	sub    $0x20,%esp
  800e06:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e0a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e0e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e12:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e16:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e1a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e1e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e20:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e22:	85 ed                	test   %ebp,%ebp
  800e24:	75 16                	jne    800e3c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e26:	39 f1                	cmp    %esi,%ecx
  800e28:	0f 86 a6 00 00 00    	jbe    800ed4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e2e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e30:	89 d0                	mov    %edx,%eax
  800e32:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e34:	83 c4 20             	add    $0x20,%esp
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    
  800e3b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e3c:	39 f5                	cmp    %esi,%ebp
  800e3e:	0f 87 ac 00 00 00    	ja     800ef0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e44:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e47:	83 f0 1f             	xor    $0x1f,%eax
  800e4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4e:	0f 84 a8 00 00 00    	je     800efc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e54:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e58:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e5a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e5f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e63:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e67:	89 f9                	mov    %edi,%ecx
  800e69:	d3 e8                	shr    %cl,%eax
  800e6b:	09 e8                	or     %ebp,%eax
  800e6d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e71:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e75:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e79:	d3 e0                	shl    %cl,%eax
  800e7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e7f:	89 f2                	mov    %esi,%edx
  800e81:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e83:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e87:	d3 e0                	shl    %cl,%eax
  800e89:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e8d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e8                	shr    %cl,%eax
  800e95:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e97:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e99:	89 f2                	mov    %esi,%edx
  800e9b:	f7 74 24 18          	divl   0x18(%esp)
  800e9f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ea1:	f7 64 24 0c          	mull   0xc(%esp)
  800ea5:	89 c5                	mov    %eax,%ebp
  800ea7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea9:	39 d6                	cmp    %edx,%esi
  800eab:	72 67                	jb     800f14 <__umoddi3+0x114>
  800ead:	74 75                	je     800f24 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800eaf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800eb3:	29 e8                	sub    %ebp,%eax
  800eb5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800eb7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	89 f2                	mov    %esi,%edx
  800ebf:	89 f9                	mov    %edi,%ecx
  800ec1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ec3:	09 d0                	or     %edx,%eax
  800ec5:	89 f2                	mov    %esi,%edx
  800ec7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ecb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ecd:	83 c4 20             	add    $0x20,%esp
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ed4:	85 c9                	test   %ecx,%ecx
  800ed6:	75 0b                	jne    800ee3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ed8:	b8 01 00 00 00       	mov    $0x1,%eax
  800edd:	31 d2                	xor    %edx,%edx
  800edf:	f7 f1                	div    %ecx
  800ee1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	31 d2                	xor    %edx,%edx
  800ee7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee9:	89 f8                	mov    %edi,%eax
  800eeb:	e9 3e ff ff ff       	jmp    800e2e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800ef0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef2:	83 c4 20             	add    $0x20,%esp
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800efc:	39 f5                	cmp    %esi,%ebp
  800efe:	72 04                	jb     800f04 <__umoddi3+0x104>
  800f00:	39 f9                	cmp    %edi,%ecx
  800f02:	77 06                	ja     800f0a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f04:	89 f2                	mov    %esi,%edx
  800f06:	29 cf                	sub    %ecx,%edi
  800f08:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f0a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f0c:	83 c4 20             	add    $0x20,%esp
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    
  800f13:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f14:	89 d1                	mov    %edx,%ecx
  800f16:	89 c5                	mov    %eax,%ebp
  800f18:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f1c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f20:	eb 8d                	jmp    800eaf <__umoddi3+0xaf>
  800f22:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f24:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f28:	72 ea                	jb     800f14 <__umoddi3+0x114>
  800f2a:	89 f1                	mov    %esi,%ecx
  800f2c:	eb 81                	jmp    800eaf <__umoddi3+0xaf>
