
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 28             	sub    $0x28,%esp
	int a;
	a=10;
  80003a:	c7 45 f4 0a 00 00 00 	movl   $0xa,-0xc(%ebp)
	cprintf("At first , a equals %d\n",a);
  800041:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800048:	00 
  800049:	c7 04 24 58 0f 80 00 	movl   $0x800f58,(%esp)
  800050:	e8 57 01 00 00       	call   8001ac <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  800055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 70 0f 80 00 	movl   $0x800f70,(%esp)
  800063:	e8 44 01 00 00       	call   8001ac <cprintf>
	asm volatile("int $3");
  800068:	cc                   	int3   
	// Try single-step here
	a=20;
  800069:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800070:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 80 0f 80 00 	movl   $0x800f80,(%esp)
  80007f:	e8 28 01 00 00       	call   8001ac <cprintf>
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800096:	e8 66 0b 00 00       	call   800c01 <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8000a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8000a6:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  8000ad:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  8000b2:	c7 04 24 97 0f 80 00 	movl   $0x800f97,(%esp)
  8000b9:	e8 ee 00 00 00       	call   8001ac <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  8000be:	a1 04 20 80 00       	mov    0x802004,%eax
  8000c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c7:	c7 04 24 a7 0f 80 00 	movl   $0x800fa7,(%esp)
  8000ce:	e8 d9 00 00 00       	call   8001ac <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d3:	85 f6                	test   %esi,%esi
  8000d5:	7e 07                	jle    8000de <libmain+0x56>
		binaryname = argv[0];
  8000d7:	8b 03                	mov    (%ebx),%eax
  8000d9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e2:	89 34 24             	mov    %esi,(%esp)
  8000e5:	e8 4a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ea:	e8 09 00 00 00       	call   8000f8 <exit>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800105:	e8 93 0a 00 00       	call   800b9d <sys_env_destroy>
}
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 14             	sub    $0x14,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011f:	40                   	inc    %eax
  800120:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800122:	3d ff 00 00 00       	cmp    $0xff,%eax
  800127:	75 19                	jne    800142 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800129:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800130:	00 
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	89 04 24             	mov    %eax,(%esp)
  800137:	e8 00 0a 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  80013c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800142:	ff 43 04             	incl   0x4(%ebx)
}
  800145:	83 c4 14             	add    $0x14,%esp
  800148:	5b                   	pop    %ebx
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800154:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015b:	00 00 00 
	b.cnt = 0;
  80015e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800165:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800168:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	89 44 24 08          	mov    %eax,0x8(%esp)
  800176:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 0c 01 80 00 	movl   $0x80010c,(%esp)
  800187:	e8 8d 01 00 00       	call   800319 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800192:	89 44 24 04          	mov    %eax,0x4(%esp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 98 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 87 ff ff ff       	call   80014b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
	...

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 3c             	sub    $0x3c,%esp
  8001d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d4:	89 d7                	mov    %edx,%edi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e5:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f0:	72 0f                	jb     800201 <printnum+0x39>
  8001f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f8:	76 07                	jbe    800201 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fa:	4b                   	dec    %ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	7f 4f                	jg     80024e <printnum+0x86>
  8001ff:	eb 5a                	jmp    80025b <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800201:	89 74 24 10          	mov    %esi,0x10(%esp)
  800205:	4b                   	dec    %ebx
  800206:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800211:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800215:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800219:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800220:	00 
  800221:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	e8 d5 0a 00 00       	call   800d08 <__udivdi3>
  800233:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800237:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800242:	89 fa                	mov    %edi,%edx
  800244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800247:	e8 7c ff ff ff       	call   8001c8 <printnum>
  80024c:	eb 0d                	jmp    80025b <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800252:	89 34 24             	mov    %esi,(%esp)
  800255:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	4b                   	dec    %ebx
  800259:	75 f3                	jne    80024e <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800271:	00 
  800272:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 a4 0b 00 00       	call   800e28 <__umoddi3>
  800284:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800288:	0f be 80 c4 0f 80 00 	movsbl 0x800fc4(%eax),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800295:	83 c4 3c             	add    $0x3c,%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a0:	83 fa 01             	cmp    $0x1,%edx
  8002a3:	7e 0e                	jle    8002b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	8b 52 04             	mov    0x4(%edx),%edx
  8002b1:	eb 22                	jmp    8002d5 <getuint+0x38>
	else if (lflag)
  8002b3:	85 d2                	test   %edx,%edx
  8002b5:	74 10                	je     8002c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	eb 0e                	jmp    8002d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e5:	73 08                	jae    8002ef <sprintputch+0x18>
		*b->buf++ = ch;
  8002e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ea:	88 0a                	mov    %cl,(%edx)
  8002ec:	42                   	inc    %edx
  8002ed:	89 10                	mov    %edx,(%eax)
}
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800301:	89 44 24 08          	mov    %eax,0x8(%esp)
  800305:	8b 45 0c             	mov    0xc(%ebp),%eax
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	e8 02 00 00 00       	call   800319 <vprintfmt>
	va_end(ap);
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 4c             	sub    $0x4c,%esp
  800322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800325:	8b 75 10             	mov    0x10(%ebp),%esi
  800328:	eb 17                	jmp    800341 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032a:	85 c0                	test   %eax,%eax
  80032c:	0f 84 93 03 00 00    	je     8006c5 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800332:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800336:	89 04 24             	mov    %eax,(%esp)
  800339:	ff 55 08             	call   *0x8(%ebp)
  80033c:	eb 03                	jmp    800341 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	0f b6 06             	movzbl (%esi),%eax
  800344:	46                   	inc    %esi
  800345:	83 f8 25             	cmp    $0x25,%eax
  800348:	75 e0                	jne    80032a <vprintfmt+0x11>
  80034a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80034e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800355:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800361:	b9 00 00 00 00       	mov    $0x0,%ecx
  800366:	eb 26                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80036f:	eb 1d                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800374:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800378:	eb 14                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80037d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800384:	eb 08                	jmp    80038e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800386:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800389:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	0f b6 16             	movzbl (%esi),%edx
  800391:	8d 46 01             	lea    0x1(%esi),%eax
  800394:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800397:	8a 06                	mov    (%esi),%al
  800399:	83 e8 23             	sub    $0x23,%eax
  80039c:	3c 55                	cmp    $0x55,%al
  80039e:	0f 87 fd 02 00 00    	ja     8006a1 <vprintfmt+0x388>
  8003a4:	0f b6 c0             	movzbl %al,%eax
  8003a7:	ff 24 85 54 10 80 00 	jmp    *0x801054(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  8003b1:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b8:	83 fa 09             	cmp    $0x9,%edx
  8003bb:	77 3f                	ja     8003fc <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003c1:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003c4:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003cb:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ce:	83 fa 09             	cmp    $0x9,%edx
  8003d1:	76 ed                	jbe    8003c0 <vprintfmt+0xa7>
  8003d3:	eb 2a                	jmp    8003ff <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 50 04             	lea    0x4(%eax),%edx
  8003db:	89 55 14             	mov    %edx,0x14(%ebp)
  8003de:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e3:	eb 1a                	jmp    8003ff <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8003e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e9:	78 8f                	js     80037a <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ee:	eb 9e                	jmp    80038e <vprintfmt+0x75>
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f3:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003fa:	eb 92                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800403:	79 89                	jns    80038e <vprintfmt+0x75>
  800405:	e9 7c ff ff ff       	jmp    800386 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040a:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040e:	e9 7b ff ff ff       	jmp    80038e <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 50 04             	lea    0x4(%eax),%edx
  800419:	89 55 14             	mov    %edx,0x14(%ebp)
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 11 ff ff ff       	jmp    800341 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	85 c0                	test   %eax,%eax
  80043d:	79 02                	jns    800441 <vprintfmt+0x128>
  80043f:	f7 d8                	neg    %eax
  800441:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 06             	cmp    $0x6,%eax
  800446:	7f 0b                	jg     800453 <vprintfmt+0x13a>
  800448:	8b 04 85 ac 11 80 00 	mov    0x8011ac(,%eax,4),%eax
  80044f:	85 c0                	test   %eax,%eax
  800451:	75 23                	jne    800476 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800453:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800457:	c7 44 24 08 dc 0f 80 	movl   $0x800fdc,0x8(%esp)
  80045e:	00 
  80045f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800463:	8b 55 08             	mov    0x8(%ebp),%edx
  800466:	89 14 24             	mov    %edx,(%esp)
  800469:	e8 83 fe ff ff       	call   8002f1 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800471:	e9 cb fe ff ff       	jmp    800341 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  800476:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047a:	c7 44 24 08 e5 0f 80 	movl   $0x800fe5,0x8(%esp)
  800481:	00 
  800482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800486:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800489:	89 0c 24             	mov    %ecx,(%esp)
  80048c:	e8 60 fe ff ff       	call   8002f1 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800494:	e9 a8 fe ff ff       	jmp    800341 <vprintfmt+0x28>
  800499:	89 f9                	mov    %edi,%ecx
  80049b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	75 07                	jne    8004b7 <vprintfmt+0x19e>
				p = "(null)";
  8004b0:	c7 45 d4 d5 0f 80 00 	movl   $0x800fd5,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	7e 3b                	jle    8004f6 <vprintfmt+0x1dd>
  8004bb:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004bf:	74 35                	je     8004f6 <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 a4 02 00 00       	call   800774 <strnlen>
  8004d0:	29 c6                	sub    %eax,%esi
  8004d2:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	7e 1d                	jle    8004f6 <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004d9:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004dd:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e7:	89 34 24             	mov    %esi,(%esp)
  8004ea:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	4f                   	dec    %edi
  8004ee:	75 f3                	jne    8004e3 <vprintfmt+0x1ca>
  8004f0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f3:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004f9:	0f be 02             	movsbl (%edx),%eax
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	75 43                	jne    800543 <vprintfmt+0x22a>
  800500:	eb 33                	jmp    800535 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800506:	74 18                	je     800520 <vprintfmt+0x207>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 10                	jbe    800520 <vprintfmt+0x207>
					putch('?', putdat);
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
  80051e:	eb 0a                	jmp    80052a <vprintfmt+0x211>
				else
					putch(ch, putdat);
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	ff 4d e4             	decl   -0x1c(%ebp)
  80052d:	0f be 06             	movsbl (%esi),%eax
  800530:	46                   	inc    %esi
  800531:	85 c0                	test   %eax,%eax
  800533:	75 12                	jne    800547 <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800535:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800539:	7f 15                	jg     800550 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053e:	e9 fe fd ff ff       	jmp    800341 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800543:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800546:	46                   	inc    %esi
  800547:	85 ff                	test   %edi,%edi
  800549:	78 b7                	js     800502 <vprintfmt+0x1e9>
  80054b:	4f                   	dec    %edi
  80054c:	79 b4                	jns    800502 <vprintfmt+0x1e9>
  80054e:	eb e5                	jmp    800535 <vprintfmt+0x21c>
  800550:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800553:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800556:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800561:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800563:	4e                   	dec    %esi
  800564:	75 f0                	jne    800556 <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800569:	e9 d3 fd ff ff       	jmp    800341 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056e:	83 f9 01             	cmp    $0x1,%ecx
  800571:	7e 10                	jle    800583 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 08             	lea    0x8(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 30                	mov    (%eax),%esi
  80057e:	8b 78 04             	mov    0x4(%eax),%edi
  800581:	eb 26                	jmp    8005a9 <vprintfmt+0x290>
	else if (lflag)
  800583:	85 c9                	test   %ecx,%ecx
  800585:	74 12                	je     800599 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 50 04             	lea    0x4(%eax),%edx
  80058d:	89 55 14             	mov    %edx,0x14(%ebp)
  800590:	8b 30                	mov    (%eax),%esi
  800592:	89 f7                	mov    %esi,%edi
  800594:	c1 ff 1f             	sar    $0x1f,%edi
  800597:	eb 10                	jmp    8005a9 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 30                	mov    (%eax),%esi
  8005a4:	89 f7                	mov    %esi,%edi
  8005a6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a9:	85 ff                	test   %edi,%edi
  8005ab:	78 0e                	js     8005bb <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ad:	89 f0                	mov    %esi,%eax
  8005af:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b1:	be 0a 00 00 00       	mov    $0xa,%esi
  8005b6:	e9 a8 00 00 00       	jmp    800663 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005c6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c9:	89 f0                	mov    %esi,%eax
  8005cb:	89 fa                	mov    %edi,%edx
  8005cd:	f7 d8                	neg    %eax
  8005cf:	83 d2 00             	adc    $0x0,%edx
  8005d2:	f7 da                	neg    %edx
			}
			base = 10;
  8005d4:	be 0a 00 00 00       	mov    $0xa,%esi
  8005d9:	e9 85 00 00 00       	jmp    800663 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005de:	89 ca                	mov    %ecx,%edx
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 b5 fc ff ff       	call   80029d <getuint>
			base = 10;
  8005e8:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8005ed:	eb 74                	jmp    800663 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005fa:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800601:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80061c:	e9 20 fd ff ff       	jmp    800341 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  800621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800625:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80062c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800633:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80063a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800652:	eb 0f                	jmp    800663 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800654:	89 ca                	mov    %ecx,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 3f fc ff ff       	call   80029d <getuint>
			base = 16;
  80065e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800663:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800667:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80066b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80066e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800672:	89 74 24 08          	mov    %esi,0x8(%esp)
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067d:	89 da                	mov    %ebx,%edx
  80067f:	8b 45 08             	mov    0x8(%ebp),%eax
  800682:	e8 41 fb ff ff       	call   8001c8 <printnum>
			break;
  800687:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068a:	e9 b2 fc ff ff       	jmp    800341 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800693:	89 14 24             	mov    %edx,(%esp)
  800696:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069c:	e9 a0 fc ff ff       	jmp    800341 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ac:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006af:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b3:	0f 84 88 fc ff ff    	je     800341 <vprintfmt+0x28>
  8006b9:	4e                   	dec    %esi
  8006ba:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006be:	75 f9                	jne    8006b9 <vprintfmt+0x3a0>
  8006c0:	e9 7c fc ff ff       	jmp    800341 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  8006c5:	83 c4 4c             	add    $0x4c,%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5e                   	pop    %esi
  8006ca:	5f                   	pop    %edi
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 28             	sub    $0x28,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 30                	je     80071e <vsnprintf+0x51>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 33                	jle    800725 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	89 44 24 04          	mov    %eax,0x4(%esp)
  800707:	c7 04 24 d7 02 80 00 	movl   $0x8002d7,(%esp)
  80070e:	e8 06 fc ff ff       	call   800319 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800713:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800716:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071c:	eb 0c                	jmp    80072a <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800723:	eb 05                	jmp    80072a <vsnprintf+0x5d>
  800725:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800735:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800739:	8b 45 10             	mov    0x10(%ebp),%eax
  80073c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	89 04 24             	mov    %eax,(%esp)
  80074d:	e8 7b ff ff ff       	call   8006cd <vsnprintf>
	va_end(ap);

	return rc;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	80 3a 00             	cmpb   $0x0,(%edx)
  80075d:	74 0e                	je     80076d <strlen+0x19>
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800764:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800765:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800769:	75 f9                	jne    800764 <strlen+0x10>
  80076b:	eb 05                	jmp    800772 <strlen+0x1e>
  80076d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80077b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	85 c9                	test   %ecx,%ecx
  800780:	74 1a                	je     80079c <strnlen+0x28>
  800782:	80 3b 00             	cmpb   $0x0,(%ebx)
  800785:	74 1c                	je     8007a3 <strnlen+0x2f>
  800787:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80078c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	39 ca                	cmp    %ecx,%edx
  800790:	74 16                	je     8007a8 <strnlen+0x34>
  800792:	42                   	inc    %edx
  800793:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800798:	75 f2                	jne    80078c <strnlen+0x18>
  80079a:	eb 0c                	jmp    8007a8 <strnlen+0x34>
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 05                	jmp    8007a8 <strnlen+0x34>
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ba:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007bd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c0:	42                   	inc    %edx
  8007c1:	84 c9                	test   %cl,%cl
  8007c3:	75 f5                	jne    8007ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	89 1c 24             	mov    %ebx,(%esp)
  8007d5:	e8 7a ff ff ff       	call   800754 <strlen>
	strcpy(dst + len, src);
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	e8 c0 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	85 f6                	test   %esi,%esi
  800803:	74 15                	je     80081a <strncpy+0x27>
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80080a:	8a 1a                	mov    (%edx),%bl
  80080c:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080f:	80 3a 01             	cmpb   $0x1,(%edx)
  800812:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800815:	41                   	inc    %ecx
  800816:	39 f1                	cmp    %esi,%ecx
  800818:	75 f0                	jne    80080a <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	57                   	push   %edi
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 7d 08             	mov    0x8(%ebp),%edi
  800827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80082a:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082d:	85 f6                	test   %esi,%esi
  80082f:	74 31                	je     800862 <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  800831:	83 fe 01             	cmp    $0x1,%esi
  800834:	74 21                	je     800857 <strlcpy+0x39>
  800836:	8a 0b                	mov    (%ebx),%cl
  800838:	84 c9                	test   %cl,%cl
  80083a:	74 1f                	je     80085b <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80083c:	83 ee 02             	sub    $0x2,%esi
  80083f:	89 f8                	mov    %edi,%eax
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800846:	88 08                	mov    %cl,(%eax)
  800848:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800849:	39 f2                	cmp    %esi,%edx
  80084b:	74 10                	je     80085d <strlcpy+0x3f>
  80084d:	42                   	inc    %edx
  80084e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800851:	84 c9                	test   %cl,%cl
  800853:	75 f1                	jne    800846 <strlcpy+0x28>
  800855:	eb 06                	jmp    80085d <strlcpy+0x3f>
  800857:	89 f8                	mov    %edi,%eax
  800859:	eb 02                	jmp    80085d <strlcpy+0x3f>
  80085b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085d:	c6 00 00             	movb   $0x0,(%eax)
  800860:	eb 02                	jmp    800864 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800864:	29 f8                	sub    %edi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5f                   	pop    %edi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	8a 01                	mov    (%ecx),%al
  800876:	84 c0                	test   %al,%al
  800878:	74 11                	je     80088b <strcmp+0x20>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	75 0d                	jne    80088b <strcmp+0x20>
		p++, q++;
  80087e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087f:	8a 41 01             	mov    0x1(%ecx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 05                	je     80088b <strcmp+0x20>
  800886:	41                   	inc    %ecx
  800887:	3a 02                	cmp    (%edx),%al
  800889:	74 f3                	je     80087e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 c0             	movzbl %al,%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 55 08             	mov    0x8(%ebp),%edx
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	74 1b                	je     8008c1 <strncmp+0x2c>
  8008a6:	8a 1a                	mov    (%edx),%bl
  8008a8:	84 db                	test   %bl,%bl
  8008aa:	74 24                	je     8008d0 <strncmp+0x3b>
  8008ac:	3a 19                	cmp    (%ecx),%bl
  8008ae:	75 20                	jne    8008d0 <strncmp+0x3b>
  8008b0:	48                   	dec    %eax
  8008b1:	74 15                	je     8008c8 <strncmp+0x33>
		n--, p++, q++;
  8008b3:	42                   	inc    %edx
  8008b4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b5:	8a 1a                	mov    (%edx),%bl
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	74 15                	je     8008d0 <strncmp+0x3b>
  8008bb:	3a 19                	cmp    (%ecx),%bl
  8008bd:	74 f1                	je     8008b0 <strncmp+0x1b>
  8008bf:	eb 0f                	jmp    8008d0 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c6:	eb 05                	jmp    8008cd <strncmp+0x38>
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cd:	5b                   	pop    %ebx
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d0:	0f b6 02             	movzbl (%edx),%eax
  8008d3:	0f b6 11             	movzbl (%ecx),%edx
  8008d6:	29 d0                	sub    %edx,%eax
  8008d8:	eb f3                	jmp    8008cd <strncmp+0x38>

008008da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e3:	8a 10                	mov    (%eax),%dl
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	74 19                	je     800902 <strchr+0x28>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	75 07                	jne    8008f4 <strchr+0x1a>
  8008ed:	eb 18                	jmp    800907 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ef:	40                   	inc    %eax
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 13                	je     800907 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	8a 50 01             	mov    0x1(%eax),%dl
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f4                	jne    8008ef <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800900:	eb 05                	jmp    800907 <strchr+0x2d>
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	8a 10                	mov    (%eax),%dl
  800914:	84 d2                	test   %dl,%dl
  800916:	74 11                	je     800929 <strfind+0x20>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	75 06                	jne    800922 <strfind+0x19>
  80091c:	eb 0b                	jmp    800929 <strfind+0x20>
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	74 07                	je     800929 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800922:	40                   	inc    %eax
  800923:	8a 10                	mov    (%eax),%dl
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f5                	jne    80091e <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 7d 08             	mov    0x8(%ebp),%edi
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 30                	je     80096e <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800944:	75 25                	jne    80096b <memset+0x40>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 20                	jne    80096b <memset+0x40>
		c &= 0xFF;
  80094b:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094e:	89 d3                	mov    %edx,%ebx
  800950:	c1 e3 08             	shl    $0x8,%ebx
  800953:	89 d6                	mov    %edx,%esi
  800955:	c1 e6 18             	shl    $0x18,%esi
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 10             	shl    $0x10,%eax
  80095d:	09 f0                	or     %esi,%eax
  80095f:	09 d0                	or     %edx,%eax
  800961:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800963:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800966:	fc                   	cld    
  800967:	f3 ab                	rep stos %eax,%es:(%edi)
  800969:	eb 03                	jmp    80096e <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096b:	fc                   	cld    
  80096c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096e:	89 f8                	mov    %edi,%eax
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800983:	39 c6                	cmp    %eax,%esi
  800985:	73 34                	jae    8009bb <memmove+0x46>
  800987:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098a:	39 d0                	cmp    %edx,%eax
  80098c:	73 2d                	jae    8009bb <memmove+0x46>
		s += n;
		d += n;
  80098e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	f6 c2 03             	test   $0x3,%dl
  800994:	75 1b                	jne    8009b1 <memmove+0x3c>
  800996:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099c:	75 13                	jne    8009b1 <memmove+0x3c>
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 0e                	jne    8009b1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a3:	83 ef 04             	sub    $0x4,%edi
  8009a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 07                	jmp    8009b8 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b1:	4f                   	dec    %edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 20                	jmp    8009db <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c1:	75 13                	jne    8009d6 <memmove+0x61>
  8009c3:	a8 03                	test   $0x3,%al
  8009c5:	75 0f                	jne    8009d6 <memmove+0x61>
  8009c7:	f6 c1 03             	test   $0x3,%cl
  8009ca:	75 0a                	jne    8009d6 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009cf:	89 c7                	mov    %eax,%edi
  8009d1:	fc                   	cld    
  8009d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d4:	eb 05                	jmp    8009db <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 77 ff ff ff       	call   800975 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	85 ff                	test   %edi,%edi
  800a11:	74 31                	je     800a44 <memcmp+0x44>
		if (*s1 != *s2)
  800a13:	8a 03                	mov    (%ebx),%al
  800a15:	8a 0e                	mov    (%esi),%cl
  800a17:	38 c8                	cmp    %cl,%al
  800a19:	74 18                	je     800a33 <memcmp+0x33>
  800a1b:	eb 0c                	jmp    800a29 <memcmp+0x29>
  800a1d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a21:	42                   	inc    %edx
  800a22:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  800a25:	38 c8                	cmp    %cl,%al
  800a27:	74 10                	je     800a39 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 c9             	movzbl %cl,%ecx
  800a2f:	29 c8                	sub    %ecx,%eax
  800a31:	eb 16                	jmp    800a49 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	4f                   	dec    %edi
  800a34:	ba 00 00 00 00       	mov    $0x0,%edx
  800a39:	39 fa                	cmp    %edi,%edx
  800a3b:	75 e0                	jne    800a1d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	eb 05                	jmp    800a49 <memcmp+0x49>
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 12                	jae    800a6f <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a60:	38 08                	cmp    %cl,(%eax)
  800a62:	75 06                	jne    800a6a <memfind+0x1c>
  800a64:	eb 09                	jmp    800a6f <memfind+0x21>
  800a66:	38 08                	cmp    %cl,(%eax)
  800a68:	74 05                	je     800a6f <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6a:	40                   	inc    %eax
  800a6b:	39 d0                	cmp    %edx,%eax
  800a6d:	75 f7                	jne    800a66 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7d:	eb 01                	jmp    800a80 <strtol+0xf>
		s++;
  800a7f:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a80:	8a 02                	mov    (%edx),%al
  800a82:	3c 20                	cmp    $0x20,%al
  800a84:	74 f9                	je     800a7f <strtol+0xe>
  800a86:	3c 09                	cmp    $0x9,%al
  800a88:	74 f5                	je     800a7f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8a:	3c 2b                	cmp    $0x2b,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x25>
		s++;
  800a8e:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a94:	eb 13                	jmp    800aa9 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a96:	3c 2d                	cmp    $0x2d,%al
  800a98:	75 0a                	jne    800aa4 <strtol+0x33>
		s++, neg = 1;
  800a9a:	8d 52 01             	lea    0x1(%edx),%edx
  800a9d:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa2:	eb 05                	jmp    800aa9 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	74 05                	je     800ab2 <strtol+0x41>
  800aad:	83 fb 10             	cmp    $0x10,%ebx
  800ab0:	75 28                	jne    800ada <strtol+0x69>
  800ab2:	8a 02                	mov    (%edx),%al
  800ab4:	3c 30                	cmp    $0x30,%al
  800ab6:	75 10                	jne    800ac8 <strtol+0x57>
  800ab8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abc:	75 0a                	jne    800ac8 <strtol+0x57>
		s += 2, base = 16;
  800abe:	83 c2 02             	add    $0x2,%edx
  800ac1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac6:	eb 12                	jmp    800ada <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	75 0e                	jne    800ada <strtol+0x69>
  800acc:	3c 30                	cmp    $0x30,%al
  800ace:	75 05                	jne    800ad5 <strtol+0x64>
		s++, base = 8;
  800ad0:	42                   	inc    %edx
  800ad1:	b3 08                	mov    $0x8,%bl
  800ad3:	eb 05                	jmp    800ada <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad5:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae1:	8a 0a                	mov    (%edx),%cl
  800ae3:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae6:	80 fb 09             	cmp    $0x9,%bl
  800ae9:	77 08                	ja     800af3 <strtol+0x82>
			dig = *s - '0';
  800aeb:	0f be c9             	movsbl %cl,%ecx
  800aee:	83 e9 30             	sub    $0x30,%ecx
  800af1:	eb 1e                	jmp    800b11 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af3:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af6:	80 fb 19             	cmp    $0x19,%bl
  800af9:	77 08                	ja     800b03 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afb:	0f be c9             	movsbl %cl,%ecx
  800afe:	83 e9 57             	sub    $0x57,%ecx
  800b01:	eb 0e                	jmp    800b11 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b03:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 12                	ja     800b1d <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0b:	0f be c9             	movsbl %cl,%ecx
  800b0e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b11:	39 f1                	cmp    %esi,%ecx
  800b13:	7d 0c                	jge    800b21 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b15:	42                   	inc    %edx
  800b16:	0f af c6             	imul   %esi,%eax
  800b19:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1b:	eb c4                	jmp    800ae1 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1d:	89 c1                	mov    %eax,%ecx
  800b1f:	eb 02                	jmp    800b23 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b21:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b27:	74 05                	je     800b2e <strtol+0xbd>
		*endptr = (char *) s;
  800b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2c:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2e:	85 ff                	test   %edi,%edi
  800b30:	74 04                	je     800b36 <strtol+0xc5>
  800b32:	89 c8                	mov    %ecx,%eax
  800b34:	f7 d8                	neg    %eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    
	...

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	51                   	push   %ecx
  800b51:	52                   	push   %edx
  800b52:	53                   	push   %ebx
  800b53:	54                   	push   %esp
  800b54:	55                   	push   %ebp
  800b55:	56                   	push   %esi
  800b56:	57                   	push   %edi
  800b57:	8d 35 61 0b 80 00    	lea    0x800b61,%esi
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	0f 34                	sysenter 

00800b61 <after_sysenter_label16>:
  800b61:	5f                   	pop    %edi
  800b62:	5e                   	pop    %esi
  800b63:	5d                   	pop    %ebp
  800b64:	5c                   	pop    %esp
  800b65:	5b                   	pop    %ebx
  800b66:	5a                   	pop    %edx
  800b67:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7b:	89 d1                	mov    %edx,%ecx
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	89 d7                	mov    %edx,%edi
  800b81:	51                   	push   %ecx
  800b82:	52                   	push   %edx
  800b83:	53                   	push   %ebx
  800b84:	54                   	push   %esp
  800b85:	55                   	push   %ebp
  800b86:	56                   	push   %esi
  800b87:	57                   	push   %edi
  800b88:	8d 35 92 0b 80 00    	lea    0x800b92,%esi
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	0f 34                	sysenter 

00800b92 <after_sysenter_label41>:
  800b92:	5f                   	pop    %edi
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	5c                   	pop    %esp
  800b96:	5b                   	pop    %ebx
  800b97:	5a                   	pop    %edx
  800b98:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ba5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baa:	b8 03 00 00 00       	mov    $0x3,%eax
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	89 cb                	mov    %ecx,%ebx
  800bb4:	89 cf                	mov    %ecx,%edi
  800bb6:	51                   	push   %ecx
  800bb7:	52                   	push   %edx
  800bb8:	53                   	push   %ebx
  800bb9:	54                   	push   %esp
  800bba:	55                   	push   %ebp
  800bbb:	56                   	push   %esi
  800bbc:	57                   	push   %edi
  800bbd:	8d 35 c7 0b 80 00    	lea    0x800bc7,%esi
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	0f 34                	sysenter 

00800bc7 <after_sysenter_label68>:
  800bc7:	5f                   	pop    %edi
  800bc8:	5e                   	pop    %esi
  800bc9:	5d                   	pop    %ebp
  800bca:	5c                   	pop    %esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5a                   	pop    %edx
  800bcd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 28                	jle    800bfa <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bdd:	00 
  800bde:	c7 44 24 08 c8 11 80 	movl   $0x8011c8,0x8(%esp)
  800be5:	00 
  800be6:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800bed:	00 
  800bee:	c7 04 24 e5 11 80 00 	movl   $0x8011e5,(%esp)
  800bf5:	e8 9e 00 00 00       	call   800c98 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfa:	83 c4 20             	add    $0x20,%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c10:	89 d1                	mov    %edx,%ecx
  800c12:	89 d3                	mov    %edx,%ebx
  800c14:	89 d7                	mov    %edx,%edi
  800c16:	51                   	push   %ecx
  800c17:	52                   	push   %edx
  800c18:	53                   	push   %ebx
  800c19:	54                   	push   %esp
  800c1a:	55                   	push   %ebp
  800c1b:	56                   	push   %esi
  800c1c:	57                   	push   %edi
  800c1d:	8d 35 27 0c 80 00    	lea    0x800c27,%esi
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	0f 34                	sysenter 

00800c27 <after_sysenter_label107>:
  800c27:	5f                   	pop    %edi
  800c28:	5e                   	pop    %esi
  800c29:	5d                   	pop    %ebp
  800c2a:	5c                   	pop    %esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5a                   	pop    %edx
  800c2d:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	51                   	push   %ecx
  800c4a:	52                   	push   %edx
  800c4b:	53                   	push   %ebx
  800c4c:	54                   	push   %esp
  800c4d:	55                   	push   %ebp
  800c4e:	56                   	push   %esi
  800c4f:	57                   	push   %edi
  800c50:	8d 35 5a 0c 80 00    	lea    0x800c5a,%esi
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	0f 34                	sysenter 

00800c5a <after_sysenter_label133>:
  800c5a:	5f                   	pop    %edi
  800c5b:	5e                   	pop    %esi
  800c5c:	5d                   	pop    %ebp
  800c5d:	5c                   	pop    %esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5a                   	pop    %edx
  800c60:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c61:	5b                   	pop    %ebx
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 cb                	mov    %ecx,%ebx
  800c79:	89 cf                	mov    %ecx,%edi
  800c7b:	51                   	push   %ecx
  800c7c:	52                   	push   %edx
  800c7d:	53                   	push   %ebx
  800c7e:	54                   	push   %esp
  800c7f:	55                   	push   %ebp
  800c80:	56                   	push   %esi
  800c81:	57                   	push   %edi
  800c82:	8d 35 8c 0c 80 00    	lea    0x800c8c,%esi
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	0f 34                	sysenter 

00800c8c <after_sysenter_label159>:
  800c8c:	5f                   	pop    %edi
  800c8d:	5e                   	pop    %esi
  800c8e:	5d                   	pop    %ebp
  800c8f:	5c                   	pop    %esp
  800c90:	5b                   	pop    %ebx
  800c91:	5a                   	pop    %edx
  800c92:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800c93:	5b                   	pop    %ebx
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    
	...

00800c98 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ca0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800ca3:	a1 08 20 80 00       	mov    0x802008,%eax
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	74 10                	je     800cbc <_panic+0x24>
		cprintf("%s: ", argv0);
  800cac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb0:	c7 04 24 f3 11 80 00 	movl   $0x8011f3,(%esp)
  800cb7:	e8 f0 f4 ff ff       	call   8001ac <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cbc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800cc2:	e8 3a ff ff ff       	call   800c01 <sys_getenvid>
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cca:	89 54 24 10          	mov    %edx,0x10(%esp)
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cdd:	c7 04 24 f8 11 80 00 	movl   $0x8011f8,(%esp)
  800ce4:	e8 c3 f4 ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ce9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ced:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf0:	89 04 24             	mov    %eax,(%esp)
  800cf3:	e8 53 f4 ff ff       	call   80014b <vcprintf>
	cprintf("\n");
  800cf8:	c7 04 24 6e 0f 80 00 	movl   $0x800f6e,(%esp)
  800cff:	e8 a8 f4 ff ff       	call   8001ac <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d04:	cc                   	int3   
  800d05:	eb fd                	jmp    800d04 <_panic+0x6c>
	...

00800d08 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d08:	55                   	push   %ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	83 ec 10             	sub    $0x10,%esp
  800d0e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d1a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d1e:	89 cd                	mov    %ecx,%ebp
  800d20:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	75 2c                	jne    800d54 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d28:	39 f9                	cmp    %edi,%ecx
  800d2a:	77 68                	ja     800d94 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d2c:	85 c9                	test   %ecx,%ecx
  800d2e:	75 0b                	jne    800d3b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d30:	b8 01 00 00 00       	mov    $0x1,%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f1                	div    %ecx
  800d39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	89 f8                	mov    %edi,%eax
  800d3f:	f7 f1                	div    %ecx
  800d41:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d43:	89 f0                	mov    %esi,%eax
  800d45:	f7 f1                	div    %ecx
  800d47:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d54:	39 f8                	cmp    %edi,%eax
  800d56:	77 2c                	ja     800d84 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d58:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d5b:	83 f6 1f             	xor    $0x1f,%esi
  800d5e:	75 4c                	jne    800dac <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d60:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d62:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d67:	72 0a                	jb     800d73 <__udivdi3+0x6b>
  800d69:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d6d:	0f 87 ad 00 00 00    	ja     800e20 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d73:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d78:	89 f0                	mov    %esi,%eax
  800d7a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    
  800d83:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d84:	31 ff                	xor    %edi,%edi
  800d86:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d88:	89 f0                	mov    %esi,%eax
  800d8a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    
  800d93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d94:	89 fa                	mov    %edi,%edx
  800d96:	89 f0                	mov    %esi,%eax
  800d98:	f7 f1                	div    %ecx
  800d9a:	89 c6                	mov    %eax,%esi
  800d9c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d9e:	89 f0                	mov    %esi,%eax
  800da0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
  800da9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dac:	89 f1                	mov    %esi,%ecx
  800dae:	d3 e0                	shl    %cl,%eax
  800db0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800db4:	b8 20 00 00 00       	mov    $0x20,%eax
  800db9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800dbb:	89 ea                	mov    %ebp,%edx
  800dbd:	88 c1                	mov    %al,%cl
  800dbf:	d3 ea                	shr    %cl,%edx
  800dc1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800dc5:	09 ca                	or     %ecx,%edx
  800dc7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800dcb:	89 f1                	mov    %esi,%ecx
  800dcd:	d3 e5                	shl    %cl,%ebp
  800dcf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800dd3:	89 fd                	mov    %edi,%ebp
  800dd5:	88 c1                	mov    %al,%cl
  800dd7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800dd9:	89 fa                	mov    %edi,%edx
  800ddb:	89 f1                	mov    %esi,%ecx
  800ddd:	d3 e2                	shl    %cl,%edx
  800ddf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800de3:	88 c1                	mov    %al,%cl
  800de5:	d3 ef                	shr    %cl,%edi
  800de7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800de9:	89 f8                	mov    %edi,%eax
  800deb:	89 ea                	mov    %ebp,%edx
  800ded:	f7 74 24 08          	divl   0x8(%esp)
  800df1:	89 d1                	mov    %edx,%ecx
  800df3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800df5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800df9:	39 d1                	cmp    %edx,%ecx
  800dfb:	72 17                	jb     800e14 <__udivdi3+0x10c>
  800dfd:	74 09                	je     800e08 <__udivdi3+0x100>
  800dff:	89 fe                	mov    %edi,%esi
  800e01:	31 ff                	xor    %edi,%edi
  800e03:	e9 41 ff ff ff       	jmp    800d49 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e08:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e0c:	89 f1                	mov    %esi,%ecx
  800e0e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e10:	39 c2                	cmp    %eax,%edx
  800e12:	73 eb                	jae    800dff <__udivdi3+0xf7>
		{
		  q0--;
  800e14:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e17:	31 ff                	xor    %edi,%edi
  800e19:	e9 2b ff ff ff       	jmp    800d49 <__udivdi3+0x41>
  800e1e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e20:	31 f6                	xor    %esi,%esi
  800e22:	e9 22 ff ff ff       	jmp    800d49 <__udivdi3+0x41>
	...

00800e28 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e28:	55                   	push   %ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	83 ec 20             	sub    $0x20,%esp
  800e2e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e32:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e36:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e3a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e42:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e46:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e48:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e4a:	85 ed                	test   %ebp,%ebp
  800e4c:	75 16                	jne    800e64 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e4e:	39 f1                	cmp    %esi,%ecx
  800e50:	0f 86 a6 00 00 00    	jbe    800efc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e56:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e58:	89 d0                	mov    %edx,%eax
  800e5a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e64:	39 f5                	cmp    %esi,%ebp
  800e66:	0f 87 ac 00 00 00    	ja     800f18 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e6c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e6f:	83 f0 1f             	xor    $0x1f,%eax
  800e72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e76:	0f 84 a8 00 00 00    	je     800f24 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e7c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e80:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e82:	bf 20 00 00 00       	mov    $0x20,%edi
  800e87:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800e8b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e8f:	89 f9                	mov    %edi,%ecx
  800e91:	d3 e8                	shr    %cl,%eax
  800e93:	09 e8                	or     %ebp,%eax
  800e95:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800e99:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e9d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ea1:	d3 e0                	shl    %cl,%eax
  800ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ea7:	89 f2                	mov    %esi,%edx
  800ea9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800eab:	8b 44 24 14          	mov    0x14(%esp),%eax
  800eaf:	d3 e0                	shl    %cl,%eax
  800eb1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800eb5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800eb9:	89 f9                	mov    %edi,%ecx
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ebf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ec1:	89 f2                	mov    %esi,%edx
  800ec3:	f7 74 24 18          	divl   0x18(%esp)
  800ec7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ec9:	f7 64 24 0c          	mull   0xc(%esp)
  800ecd:	89 c5                	mov    %eax,%ebp
  800ecf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ed1:	39 d6                	cmp    %edx,%esi
  800ed3:	72 67                	jb     800f3c <__umoddi3+0x114>
  800ed5:	74 75                	je     800f4c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ed7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800edb:	29 e8                	sub    %ebp,%eax
  800edd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800edf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ee3:	d3 e8                	shr    %cl,%eax
  800ee5:	89 f2                	mov    %esi,%edx
  800ee7:	89 f9                	mov    %edi,%ecx
  800ee9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800eeb:	09 d0                	or     %edx,%eax
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef5:	83 c4 20             	add    $0x20,%esp
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800efc:	85 c9                	test   %ecx,%ecx
  800efe:	75 0b                	jne    800f0b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f00:	b8 01 00 00 00       	mov    $0x1,%eax
  800f05:	31 d2                	xor    %edx,%edx
  800f07:	f7 f1                	div    %ecx
  800f09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	31 d2                	xor    %edx,%edx
  800f0f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f11:	89 f8                	mov    %edi,%eax
  800f13:	e9 3e ff ff ff       	jmp    800e56 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f18:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
  800f21:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f24:	39 f5                	cmp    %esi,%ebp
  800f26:	72 04                	jb     800f2c <__umoddi3+0x104>
  800f28:	39 f9                	cmp    %edi,%ecx
  800f2a:	77 06                	ja     800f32 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f2c:	89 f2                	mov    %esi,%edx
  800f2e:	29 cf                	sub    %ecx,%edi
  800f30:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f32:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    
  800f3b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f3c:	89 d1                	mov    %edx,%ecx
  800f3e:	89 c5                	mov    %eax,%ebp
  800f40:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f44:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f48:	eb 8d                	jmp    800ed7 <__umoddi3+0xaf>
  800f4a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f4c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f50:	72 ea                	jb     800f3c <__umoddi3+0x114>
  800f52:	89 f1                	mov    %esi,%ecx
  800f54:	eb 81                	jmp    800ed7 <__umoddi3+0xaf>
