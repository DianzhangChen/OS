
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 73 00 00 00       	call   8000a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800043:	e8 39 0c 00 00       	call   800c81 <sys_sbrk>
  800048:	89 c3                	mov    %eax,%ebx
	end = sys_sbrk(ALLOCATE_SIZE);
  80004a:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  800051:	e8 2b 0c 00 00       	call   800c81 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800056:	29 d8                	sub    %ebx,%eax
  800058:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005d:	77 0c                	ja     80006b <umain+0x37>
		cprintf("sbrk not correctly implemented\n");
  80005f:	c7 04 24 74 0f 80 00 	movl   $0x800f74,(%esp)
  800066:	e8 5d 01 00 00       	call   8001c8 <cprintf>
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  80006b:	b9 00 00 00 00       	mov    $0x0,%ecx
		s[i] = 'A' + (i % 26);
  800070:	be 1a 00 00 00       	mov    $0x1a,%esi
  800075:	89 c8                	mov    %ecx,%eax
  800077:	99                   	cltd   
  800078:	f7 fe                	idiv   %esi
  80007a:	83 c2 41             	add    $0x41,%edx
  80007d:	88 14 19             	mov    %dl,(%ecx,%ebx,1)
	if (end - start < ALLOCATE_SIZE) {
		cprintf("sbrk not correctly implemented\n");
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  800080:	41                   	inc    %ecx
  800081:	83 f9 40             	cmp    $0x40,%ecx
  800084:	75 ef                	jne    800075 <umain+0x41>
		s[i] = 'A' + (i % 26);
	}
	s[STRING_SIZE] = '\0';
  800086:	c6 43 40 00          	movb   $0x0,0x40(%ebx)

	cprintf("SBRK_TEST(%s)\n", s);
  80008a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008e:	c7 04 24 94 0f 80 00 	movl   $0x800f94,(%esp)
  800095:	e8 2e 01 00 00       	call   8001c8 <cprintf>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    
  8000a1:	00 00                	add    %al,(%eax)
	...

008000a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	83 ec 10             	sub    $0x10,%esp
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000b2:	e8 66 0b 00 00       	call   800c1d <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8000bf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8000c2:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  8000c9:	a3 04 20 80 00       	mov    %eax,0x802004
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  8000ce:	c7 04 24 a3 0f 80 00 	movl   $0x800fa3,(%esp)
  8000d5:	e8 ee 00 00 00       	call   8001c8 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  8000da:	a1 04 20 80 00       	mov    0x802004,%eax
  8000df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e3:	c7 04 24 b3 0f 80 00 	movl   $0x800fb3,(%esp)
  8000ea:	e8 d9 00 00 00       	call   8001c8 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ef:	85 f6                	test   %esi,%esi
  8000f1:	7e 07                	jle    8000fa <libmain+0x56>
		binaryname = argv[0];
  8000f3:	8b 03                	mov    (%ebx),%eax
  8000f5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fe:	89 34 24             	mov    %esi,(%esp)
  800101:	e8 2e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800106:	e8 09 00 00 00       	call   800114 <exit>
}
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 93 0a 00 00       	call   800bb9 <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 14             	sub    $0x14,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013b:	40                   	inc    %eax
  80013c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800143:	75 19                	jne    80015e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800145:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014c:	00 
  80014d:	8d 43 08             	lea    0x8(%ebx),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 00 0a 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015e:	ff 43 04             	incl   0x4(%ebx)
}
  800161:	83 c4 14             	add    $0x14,%esp
  800164:	5b                   	pop    %ebx
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800177:	00 00 00 
	b.cnt = 0;
  80017a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 45 08             	mov    0x8(%ebp),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  8001a3:	e8 8d 01 00 00       	call   800335 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 98 09 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  8001c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 87 ff ff ff       	call   800167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    
	...

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 3c             	sub    $0x3c,%esp
  8001ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f0:	89 d7                	mov    %edx,%edi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800201:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800204:	b8 00 00 00 00       	mov    $0x0,%eax
  800209:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80020c:	72 0f                	jb     80021d <printnum+0x39>
  80020e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800211:	39 45 10             	cmp    %eax,0x10(%ebp)
  800214:	76 07                	jbe    80021d <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800216:	4b                   	dec    %ebx
  800217:	85 db                	test   %ebx,%ebx
  800219:	7f 4f                	jg     80026a <printnum+0x86>
  80021b:	eb 5a                	jmp    800277 <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021d:	89 74 24 10          	mov    %esi,0x10(%esp)
  800221:	4b                   	dec    %ebx
  800222:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800226:	8b 45 10             	mov    0x10(%ebp),%eax
  800229:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800231:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800235:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023c:	00 
  80023d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	e8 d5 0a 00 00       	call   800d24 <__udivdi3>
  80024f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800253:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025e:	89 fa                	mov    %edi,%edx
  800260:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800263:	e8 7c ff ff ff       	call   8001e4 <printnum>
  800268:	eb 0d                	jmp    800277 <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800274:	4b                   	dec    %ebx
  800275:	75 f3                	jne    80026a <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800277:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80027f:	8b 45 10             	mov    0x10(%ebp),%eax
  800282:	89 44 24 08          	mov    %eax,0x8(%esp)
  800286:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028d:	00 
  80028e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029b:	e8 a4 0b 00 00       	call   800e44 <__umoddi3>
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a4:	0f be 80 d0 0f 80 00 	movsbl 0x800fd0(%eax),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b1:	83 c4 3c             	add    $0x3c,%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bc:	83 fa 01             	cmp    $0x1,%edx
  8002bf:	7e 0e                	jle    8002cf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	8b 52 04             	mov    0x4(%edx),%edx
  8002cd:	eb 22                	jmp    8002f1 <getuint+0x38>
	else if (lflag)
  8002cf:	85 d2                	test   %edx,%edx
  8002d1:	74 10                	je     8002e3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e1:	eb 0e                	jmp    8002f1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800301:	73 08                	jae    80030b <sprintputch+0x18>
		*b->buf++ = ch;
  800303:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800306:	88 0a                	mov    %cl,(%edx)
  800308:	42                   	inc    %edx
  800309:	89 10                	mov    %edx,(%eax)
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800313:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800316:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031a:	8b 45 10             	mov    0x10(%ebp),%eax
  80031d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800321:	8b 45 0c             	mov    0xc(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	e8 02 00 00 00       	call   800335 <vprintfmt>
	va_end(ap);
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 4c             	sub    $0x4c,%esp
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 75 10             	mov    0x10(%ebp),%esi
  800344:	eb 17                	jmp    80035d <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 93 03 00 00    	je     8006e1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80034e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	ff 55 08             	call   *0x8(%ebp)
  800358:	eb 03                	jmp    80035d <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	0f b6 06             	movzbl (%esi),%eax
  800360:	46                   	inc    %esi
  800361:	83 f8 25             	cmp    $0x25,%eax
  800364:	75 e0                	jne    800346 <vprintfmt+0x11>
  800366:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80036a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800371:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800376:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800382:	eb 26                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80038b:	eb 1d                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800390:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800394:	eb 14                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800399:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a0:	eb 08                	jmp    8003aa <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	0f b6 16             	movzbl (%esi),%edx
  8003ad:	8d 46 01             	lea    0x1(%esi),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	8a 06                	mov    (%esi),%al
  8003b5:	83 e8 23             	sub    $0x23,%eax
  8003b8:	3c 55                	cmp    $0x55,%al
  8003ba:	0f 87 fd 02 00 00    	ja     8006bd <vprintfmt+0x388>
  8003c0:	0f b6 c0             	movzbl %al,%eax
  8003c3:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ca:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  8003cd:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d4:	83 fa 09             	cmp    $0x9,%edx
  8003d7:	77 3f                	ja     800418 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dc:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003dd:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003e0:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003e4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e7:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ea:	83 fa 09             	cmp    $0x9,%edx
  8003ed:	76 ed                	jbe    8003dc <vprintfmt+0xa7>
  8003ef:	eb 2a                	jmp    80041b <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ff:	eb 1a                	jmp    80041b <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  800401:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800405:	78 8f                	js     800396 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80040a:	eb 9e                	jmp    8003aa <vprintfmt+0x75>
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800416:	eb 92                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041f:	79 89                	jns    8003aa <vprintfmt+0x75>
  800421:	e9 7c ff ff ff       	jmp    8003a2 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800426:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042a:	e9 7b ff ff ff       	jmp    8003aa <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800447:	e9 11 ff ff ff       	jmp    80035d <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	8b 00                	mov    (%eax),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	79 02                	jns    80045d <vprintfmt+0x128>
  80045b:	f7 d8                	neg    %eax
  80045d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045f:	83 f8 06             	cmp    $0x6,%eax
  800462:	7f 0b                	jg     80046f <vprintfmt+0x13a>
  800464:	8b 04 85 b8 11 80 00 	mov    0x8011b8(,%eax,4),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 23                	jne    800492 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80046f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800473:	c7 44 24 08 e8 0f 80 	movl   $0x800fe8,0x8(%esp)
  80047a:	00 
  80047b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047f:	8b 55 08             	mov    0x8(%ebp),%edx
  800482:	89 14 24             	mov    %edx,(%esp)
  800485:	e8 83 fe ff ff       	call   80030d <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048d:	e9 cb fe ff ff       	jmp    80035d <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  800492:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800496:	c7 44 24 08 f1 0f 80 	movl   $0x800ff1,0x8(%esp)
  80049d:	00 
  80049e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a5:	89 0c 24             	mov    %ecx,(%esp)
  8004a8:	e8 60 fe ff ff       	call   80030d <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004b0:	e9 a8 fe ff ff       	jmp    80035d <vprintfmt+0x28>
  8004b5:	89 f9                	mov    %edi,%ecx
  8004b7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	75 07                	jne    8004d3 <vprintfmt+0x19e>
				p = "(null)";
  8004cc:	c7 45 d4 e1 0f 80 00 	movl   $0x800fe1,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8004d3:	85 f6                	test   %esi,%esi
  8004d5:	7e 3b                	jle    800512 <vprintfmt+0x1dd>
  8004d7:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004db:	74 35                	je     800512 <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 a4 02 00 00       	call   800790 <strnlen>
  8004ec:	29 c6                	sub    %eax,%esi
  8004ee:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8004f1:	85 f6                	test   %esi,%esi
  8004f3:	7e 1d                	jle    800512 <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004f5:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8004f9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	89 34 24             	mov    %esi,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	4f                   	dec    %edi
  80050a:	75 f3                	jne    8004ff <vprintfmt+0x1ca>
  80050c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80050f:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800515:	0f be 02             	movsbl (%edx),%eax
  800518:	85 c0                	test   %eax,%eax
  80051a:	75 43                	jne    80055f <vprintfmt+0x22a>
  80051c:	eb 33                	jmp    800551 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800522:	74 18                	je     80053c <vprintfmt+0x207>
  800524:	8d 50 e0             	lea    -0x20(%eax),%edx
  800527:	83 fa 5e             	cmp    $0x5e,%edx
  80052a:	76 10                	jbe    80053c <vprintfmt+0x207>
					putch('?', putdat);
  80052c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800530:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	eb 0a                	jmp    800546 <vprintfmt+0x211>
				else
					putch(ch, putdat);
  80053c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	ff 4d e4             	decl   -0x1c(%ebp)
  800549:	0f be 06             	movsbl (%esi),%eax
  80054c:	46                   	inc    %esi
  80054d:	85 c0                	test   %eax,%eax
  80054f:	75 12                	jne    800563 <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800551:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800555:	7f 15                	jg     80056c <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80055a:	e9 fe fd ff ff       	jmp    80035d <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800562:	46                   	inc    %esi
  800563:	85 ff                	test   %edi,%edi
  800565:	78 b7                	js     80051e <vprintfmt+0x1e9>
  800567:	4f                   	dec    %edi
  800568:	79 b4                	jns    80051e <vprintfmt+0x1e9>
  80056a:	eb e5                	jmp    800551 <vprintfmt+0x21c>
  80056c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80056f:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800572:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800576:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057f:	4e                   	dec    %esi
  800580:	75 f0                	jne    800572 <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800585:	e9 d3 fd ff ff       	jmp    80035d <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058a:	83 f9 01             	cmp    $0x1,%ecx
  80058d:	7e 10                	jle    80059f <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 08             	lea    0x8(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 30                	mov    (%eax),%esi
  80059a:	8b 78 04             	mov    0x4(%eax),%edi
  80059d:	eb 26                	jmp    8005c5 <vprintfmt+0x290>
	else if (lflag)
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	74 12                	je     8005b5 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 30                	mov    (%eax),%esi
  8005ae:	89 f7                	mov    %esi,%edi
  8005b0:	c1 ff 1f             	sar    $0x1f,%edi
  8005b3:	eb 10                	jmp    8005c5 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 30                	mov    (%eax),%esi
  8005c0:	89 f7                	mov    %esi,%edi
  8005c2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c5:	85 ff                	test   %edi,%edi
  8005c7:	78 0e                	js     8005d7 <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c9:	89 f0                	mov    %esi,%eax
  8005cb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005cd:	be 0a 00 00 00       	mov    $0xa,%esi
  8005d2:	e9 a8 00 00 00       	jmp    80067f <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005db:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005e2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e5:	89 f0                	mov    %esi,%eax
  8005e7:	89 fa                	mov    %edi,%edx
  8005e9:	f7 d8                	neg    %eax
  8005eb:	83 d2 00             	adc    $0x0,%edx
  8005ee:	f7 da                	neg    %edx
			}
			base = 10;
  8005f0:	be 0a 00 00 00       	mov    $0xa,%esi
  8005f5:	e9 85 00 00 00       	jmp    80067f <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fa:	89 ca                	mov    %ecx,%edx
  8005fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ff:	e8 b5 fc ff ff       	call   8002b9 <getuint>
			base = 10;
  800604:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800609:	eb 74                	jmp    80067f <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800619:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800624:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800627:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062b:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800632:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800638:	e9 20 fd ff ff       	jmp    80035d <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  80063d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800641:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800656:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800669:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80066e:	eb 0f                	jmp    80067f <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800670:	89 ca                	mov    %ecx,%edx
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 3f fc ff ff       	call   8002b9 <getuint>
			base = 16;
  80067a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  800683:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800687:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80068a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80068e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	89 54 24 04          	mov    %edx,0x4(%esp)
  800699:	89 da                	mov    %ebx,%edx
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	e8 41 fb ff ff       	call   8001e4 <printnum>
			break;
  8006a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a6:	e9 b2 fc ff ff       	jmp    80035d <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006af:	89 14 24             	mov    %edx,(%esp)
  8006b2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b8:	e9 a0 fc ff ff       	jmp    80035d <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006cf:	0f 84 88 fc ff ff    	je     80035d <vprintfmt+0x28>
  8006d5:	4e                   	dec    %esi
  8006d6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006da:	75 f9                	jne    8006d5 <vprintfmt+0x3a0>
  8006dc:	e9 7c fc ff ff       	jmp    80035d <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  8006e1:	83 c4 4c             	add    $0x4c,%esp
  8006e4:	5b                   	pop    %ebx
  8006e5:	5e                   	pop    %esi
  8006e6:	5f                   	pop    %edi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 28             	sub    $0x28,%esp
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800706:	85 c0                	test   %eax,%eax
  800708:	74 30                	je     80073a <vsnprintf+0x51>
  80070a:	85 d2                	test   %edx,%edx
  80070c:	7e 33                	jle    800741 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800715:	8b 45 10             	mov    0x10(%ebp),%eax
  800718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	c7 04 24 f3 02 80 00 	movl   $0x8002f3,(%esp)
  80072a:	e8 06 fc ff ff       	call   800335 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	eb 0c                	jmp    800746 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073f:	eb 05                	jmp    800746 <vsnprintf+0x5d>
  800741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800751:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800755:	8b 45 10             	mov    0x10(%ebp),%eax
  800758:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	89 04 24             	mov    %eax,(%esp)
  800769:	e8 7b ff ff ff       	call   8006e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3a 00             	cmpb   $0x0,(%edx)
  800779:	74 0e                	je     800789 <strlen+0x19>
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800780:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800781:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800785:	75 f9                	jne    800780 <strlen+0x10>
  800787:	eb 05                	jmp    80078e <strlen+0x1e>
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	74 1a                	je     8007b8 <strnlen+0x28>
  80079e:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007a1:	74 1c                	je     8007bf <strnlen+0x2f>
  8007a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 ca                	cmp    %ecx,%edx
  8007ac:	74 16                	je     8007c4 <strnlen+0x34>
  8007ae:	42                   	inc    %edx
  8007af:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007b4:	75 f2                	jne    8007a8 <strnlen+0x18>
  8007b6:	eb 0c                	jmp    8007c4 <strnlen+0x34>
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	eb 05                	jmp    8007c4 <strnlen+0x34>
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007dc:	42                   	inc    %edx
  8007dd:	84 c9                	test   %cl,%cl
  8007df:	75 f5                	jne    8007d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e1:	5b                   	pop    %ebx
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ee:	89 1c 24             	mov    %ebx,(%esp)
  8007f1:	e8 7a ff ff ff       	call   800770 <strlen>
	strcpy(dst + len, src);
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fd:	01 d8                	add    %ebx,%eax
  8007ff:	89 04 24             	mov    %eax,(%esp)
  800802:	e8 c0 ff ff ff       	call   8007c7 <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	85 f6                	test   %esi,%esi
  80081f:	74 15                	je     800836 <strncpy+0x27>
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800826:	8a 1a                	mov    (%edx),%bl
  800828:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082b:	80 3a 01             	cmpb   $0x1,(%edx)
  80082e:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	41                   	inc    %ecx
  800832:	39 f1                	cmp    %esi,%ecx
  800834:	75 f0                	jne    800826 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	57                   	push   %edi
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 7d 08             	mov    0x8(%ebp),%edi
  800843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800846:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800849:	85 f6                	test   %esi,%esi
  80084b:	74 31                	je     80087e <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  80084d:	83 fe 01             	cmp    $0x1,%esi
  800850:	74 21                	je     800873 <strlcpy+0x39>
  800852:	8a 0b                	mov    (%ebx),%cl
  800854:	84 c9                	test   %cl,%cl
  800856:	74 1f                	je     800877 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800858:	83 ee 02             	sub    $0x2,%esi
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800862:	88 08                	mov    %cl,(%eax)
  800864:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800865:	39 f2                	cmp    %esi,%edx
  800867:	74 10                	je     800879 <strlcpy+0x3f>
  800869:	42                   	inc    %edx
  80086a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80086d:	84 c9                	test   %cl,%cl
  80086f:	75 f1                	jne    800862 <strlcpy+0x28>
  800871:	eb 06                	jmp    800879 <strlcpy+0x3f>
  800873:	89 f8                	mov    %edi,%eax
  800875:	eb 02                	jmp    800879 <strlcpy+0x3f>
  800877:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
  80087c:	eb 02                	jmp    800880 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800880:	29 f8                	sub    %edi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800890:	8a 01                	mov    (%ecx),%al
  800892:	84 c0                	test   %al,%al
  800894:	74 11                	je     8008a7 <strcmp+0x20>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	75 0d                	jne    8008a7 <strcmp+0x20>
		p++, q++;
  80089a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089b:	8a 41 01             	mov    0x1(%ecx),%al
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 05                	je     8008a7 <strcmp+0x20>
  8008a2:	41                   	inc    %ecx
  8008a3:	3a 02                	cmp    (%edx),%al
  8008a5:	74 f3                	je     80089a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 c0             	movzbl %al,%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bb:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	74 1b                	je     8008dd <strncmp+0x2c>
  8008c2:	8a 1a                	mov    (%edx),%bl
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	74 24                	je     8008ec <strncmp+0x3b>
  8008c8:	3a 19                	cmp    (%ecx),%bl
  8008ca:	75 20                	jne    8008ec <strncmp+0x3b>
  8008cc:	48                   	dec    %eax
  8008cd:	74 15                	je     8008e4 <strncmp+0x33>
		n--, p++, q++;
  8008cf:	42                   	inc    %edx
  8008d0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	8a 1a                	mov    (%edx),%bl
  8008d3:	84 db                	test   %bl,%bl
  8008d5:	74 15                	je     8008ec <strncmp+0x3b>
  8008d7:	3a 19                	cmp    (%ecx),%bl
  8008d9:	74 f1                	je     8008cc <strncmp+0x1b>
  8008db:	eb 0f                	jmp    8008ec <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e2:	eb 05                	jmp    8008e9 <strncmp+0x38>
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ec:	0f b6 02             	movzbl (%edx),%eax
  8008ef:	0f b6 11             	movzbl (%ecx),%edx
  8008f2:	29 d0                	sub    %edx,%eax
  8008f4:	eb f3                	jmp    8008e9 <strncmp+0x38>

008008f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ff:	8a 10                	mov    (%eax),%dl
  800901:	84 d2                	test   %dl,%dl
  800903:	74 19                	je     80091e <strchr+0x28>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	75 07                	jne    800910 <strchr+0x1a>
  800909:	eb 18                	jmp    800923 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090b:	40                   	inc    %eax
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 13                	je     800923 <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800910:	8a 50 01             	mov    0x1(%eax),%dl
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f4                	jne    80090b <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
  80091c:	eb 05                	jmp    800923 <strchr+0x2d>
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092e:	8a 10                	mov    (%eax),%dl
  800930:	84 d2                	test   %dl,%dl
  800932:	74 11                	je     800945 <strfind+0x20>
		if (*s == c)
  800934:	38 ca                	cmp    %cl,%dl
  800936:	75 06                	jne    80093e <strfind+0x19>
  800938:	eb 0b                	jmp    800945 <strfind+0x20>
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 07                	je     800945 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093e:	40                   	inc    %eax
  80093f:	8a 10                	mov    (%eax),%dl
  800941:	84 d2                	test   %dl,%dl
  800943:	75 f5                	jne    80093a <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	8b 45 0c             	mov    0xc(%ebp),%eax
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800956:	85 c9                	test   %ecx,%ecx
  800958:	74 30                	je     80098a <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800960:	75 25                	jne    800987 <memset+0x40>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 20                	jne    800987 <memset+0x40>
		c &= 0xFF;
  800967:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096a:	89 d3                	mov    %edx,%ebx
  80096c:	c1 e3 08             	shl    $0x8,%ebx
  80096f:	89 d6                	mov    %edx,%esi
  800971:	c1 e6 18             	shl    $0x18,%esi
  800974:	89 d0                	mov    %edx,%eax
  800976:	c1 e0 10             	shl    $0x10,%eax
  800979:	09 f0                	or     %esi,%eax
  80097b:	09 d0                	or     %edx,%eax
  80097d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800982:	fc                   	cld    
  800983:	f3 ab                	rep stos %eax,%es:(%edi)
  800985:	eb 03                	jmp    80098a <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800987:	fc                   	cld    
  800988:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098a:	89 f8                	mov    %edi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099f:	39 c6                	cmp    %eax,%esi
  8009a1:	73 34                	jae    8009d7 <memmove+0x46>
  8009a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a6:	39 d0                	cmp    %edx,%eax
  8009a8:	73 2d                	jae    8009d7 <memmove+0x46>
		s += n;
		d += n;
  8009aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	75 1b                	jne    8009cd <memmove+0x3c>
  8009b2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b8:	75 13                	jne    8009cd <memmove+0x3c>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0e                	jne    8009cd <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009bf:	83 ef 04             	sub    $0x4,%edi
  8009c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 07                	jmp    8009d4 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cd:	4f                   	dec    %edi
  8009ce:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d1:	fd                   	std    
  8009d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d4:	fc                   	cld    
  8009d5:	eb 20                	jmp    8009f7 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009dd:	75 13                	jne    8009f2 <memmove+0x61>
  8009df:	a8 03                	test   $0x3,%al
  8009e1:	75 0f                	jne    8009f2 <memmove+0x61>
  8009e3:	f6 c1 03             	test   $0x3,%cl
  8009e6:	75 0a                	jne    8009f2 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f0:	eb 05                	jmp    8009f7 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f2:	89 c7                	mov    %eax,%edi
  8009f4:	fc                   	cld    
  8009f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a01:	8b 45 10             	mov    0x10(%ebp),%eax
  800a04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 77 ff ff ff       	call   800991 <memmove>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a28:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	85 ff                	test   %edi,%edi
  800a2d:	74 31                	je     800a60 <memcmp+0x44>
		if (*s1 != *s2)
  800a2f:	8a 03                	mov    (%ebx),%al
  800a31:	8a 0e                	mov    (%esi),%cl
  800a33:	38 c8                	cmp    %cl,%al
  800a35:	74 18                	je     800a4f <memcmp+0x33>
  800a37:	eb 0c                	jmp    800a45 <memcmp+0x29>
  800a39:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a3d:	42                   	inc    %edx
  800a3e:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  800a41:	38 c8                	cmp    %cl,%al
  800a43:	74 10                	je     800a55 <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  800a45:	0f b6 c0             	movzbl %al,%eax
  800a48:	0f b6 c9             	movzbl %cl,%ecx
  800a4b:	29 c8                	sub    %ecx,%eax
  800a4d:	eb 16                	jmp    800a65 <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4f:	4f                   	dec    %edi
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	39 fa                	cmp    %edi,%edx
  800a57:	75 e0                	jne    800a39 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5e:	eb 05                	jmp    800a65 <memcmp+0x49>
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a70:	89 c2                	mov    %eax,%edx
  800a72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	73 12                	jae    800a8b <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a79:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a7c:	38 08                	cmp    %cl,(%eax)
  800a7e:	75 06                	jne    800a86 <memfind+0x1c>
  800a80:	eb 09                	jmp    800a8b <memfind+0x21>
  800a82:	38 08                	cmp    %cl,(%eax)
  800a84:	74 05                	je     800a8b <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a86:	40                   	inc    %eax
  800a87:	39 d0                	cmp    %edx,%eax
  800a89:	75 f7                	jne    800a82 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a99:	eb 01                	jmp    800a9c <strtol+0xf>
		s++;
  800a9b:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9c:	8a 02                	mov    (%edx),%al
  800a9e:	3c 20                	cmp    $0x20,%al
  800aa0:	74 f9                	je     800a9b <strtol+0xe>
  800aa2:	3c 09                	cmp    $0x9,%al
  800aa4:	74 f5                	je     800a9b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa6:	3c 2b                	cmp    $0x2b,%al
  800aa8:	75 08                	jne    800ab2 <strtol+0x25>
		s++;
  800aaa:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aab:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab0:	eb 13                	jmp    800ac5 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab2:	3c 2d                	cmp    $0x2d,%al
  800ab4:	75 0a                	jne    800ac0 <strtol+0x33>
		s++, neg = 1;
  800ab6:	8d 52 01             	lea    0x1(%edx),%edx
  800ab9:	bf 01 00 00 00       	mov    $0x1,%edi
  800abe:	eb 05                	jmp    800ac5 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	74 05                	je     800ace <strtol+0x41>
  800ac9:	83 fb 10             	cmp    $0x10,%ebx
  800acc:	75 28                	jne    800af6 <strtol+0x69>
  800ace:	8a 02                	mov    (%edx),%al
  800ad0:	3c 30                	cmp    $0x30,%al
  800ad2:	75 10                	jne    800ae4 <strtol+0x57>
  800ad4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad8:	75 0a                	jne    800ae4 <strtol+0x57>
		s += 2, base = 16;
  800ada:	83 c2 02             	add    $0x2,%edx
  800add:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae2:	eb 12                	jmp    800af6 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	75 0e                	jne    800af6 <strtol+0x69>
  800ae8:	3c 30                	cmp    $0x30,%al
  800aea:	75 05                	jne    800af1 <strtol+0x64>
		s++, base = 8;
  800aec:	42                   	inc    %edx
  800aed:	b3 08                	mov    $0x8,%bl
  800aef:	eb 05                	jmp    800af6 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800af1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afd:	8a 0a                	mov    (%edx),%cl
  800aff:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b02:	80 fb 09             	cmp    $0x9,%bl
  800b05:	77 08                	ja     800b0f <strtol+0x82>
			dig = *s - '0';
  800b07:	0f be c9             	movsbl %cl,%ecx
  800b0a:	83 e9 30             	sub    $0x30,%ecx
  800b0d:	eb 1e                	jmp    800b2d <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b0f:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 08                	ja     800b1f <strtol+0x92>
			dig = *s - 'a' + 10;
  800b17:	0f be c9             	movsbl %cl,%ecx
  800b1a:	83 e9 57             	sub    $0x57,%ecx
  800b1d:	eb 0e                	jmp    800b2d <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b22:	80 fb 19             	cmp    $0x19,%bl
  800b25:	77 12                	ja     800b39 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b27:	0f be c9             	movsbl %cl,%ecx
  800b2a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2d:	39 f1                	cmp    %esi,%ecx
  800b2f:	7d 0c                	jge    800b3d <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b31:	42                   	inc    %edx
  800b32:	0f af c6             	imul   %esi,%eax
  800b35:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b37:	eb c4                	jmp    800afd <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	eb 02                	jmp    800b3f <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3d:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b43:	74 05                	je     800b4a <strtol+0xbd>
		*endptr = (char *) s;
  800b45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b48:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b4a:	85 ff                	test   %edi,%edi
  800b4c:	74 04                	je     800b52 <strtol+0xc5>
  800b4e:	89 c8                	mov    %ecx,%eax
  800b50:	f7 d8                	neg    %eax
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    
	...

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	89 c3                	mov    %eax,%ebx
  800b6a:	89 c7                	mov    %eax,%edi
  800b6c:	51                   	push   %ecx
  800b6d:	52                   	push   %edx
  800b6e:	53                   	push   %ebx
  800b6f:	54                   	push   %esp
  800b70:	55                   	push   %ebp
  800b71:	56                   	push   %esi
  800b72:	57                   	push   %edi
  800b73:	8d 35 7d 0b 80 00    	lea    0x800b7d,%esi
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	0f 34                	sysenter 

00800b7d <after_sysenter_label16>:
  800b7d:	5f                   	pop    %edi
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	5c                   	pop    %esp
  800b81:	5b                   	pop    %ebx
  800b82:	5a                   	pop    %edx
  800b83:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 01 00 00 00       	mov    $0x1,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	51                   	push   %ecx
  800b9e:	52                   	push   %edx
  800b9f:	53                   	push   %ebx
  800ba0:	54                   	push   %esp
  800ba1:	55                   	push   %ebp
  800ba2:	56                   	push   %esi
  800ba3:	57                   	push   %edi
  800ba4:	8d 35 ae 0b 80 00    	lea    0x800bae,%esi
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	0f 34                	sysenter 

00800bae <after_sysenter_label41>:
  800bae:	5f                   	pop    %edi
  800baf:	5e                   	pop    %esi
  800bb0:	5d                   	pop    %ebp
  800bb1:	5c                   	pop    %esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5a                   	pop    %edx
  800bb4:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 cb                	mov    %ecx,%ebx
  800bd0:	89 cf                	mov    %ecx,%edi
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

00800be3 <after_sysenter_label68>:
  800be3:	5f                   	pop    %edi
  800be4:	5e                   	pop    %esi
  800be5:	5d                   	pop    %ebp
  800be6:	5c                   	pop    %esp
  800be7:	5b                   	pop    %ebx
  800be8:	5a                   	pop    %edx
  800be9:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 28                	jle    800c16 <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf9:	00 
  800bfa:	c7 44 24 08 d4 11 80 	movl   $0x8011d4,0x8(%esp)
  800c01:	00 
  800c02:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800c09:	00 
  800c0a:	c7 04 24 f1 11 80 00 	movl   $0x8011f1,(%esp)
  800c11:	e8 9e 00 00 00       	call   800cb4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c16:	83 c4 20             	add    $0x20,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	51                   	push   %ecx
  800c33:	52                   	push   %edx
  800c34:	53                   	push   %ebx
  800c35:	54                   	push   %esp
  800c36:	55                   	push   %ebp
  800c37:	56                   	push   %esi
  800c38:	57                   	push   %edi
  800c39:	8d 35 43 0c 80 00    	lea    0x800c43,%esi
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	0f 34                	sysenter 

00800c43 <after_sysenter_label107>:
  800c43:	5f                   	pop    %edi
  800c44:	5e                   	pop    %esi
  800c45:	5d                   	pop    %ebp
  800c46:	5c                   	pop    %esp
  800c47:	5b                   	pop    %ebx
  800c48:	5a                   	pop    %edx
  800c49:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	51                   	push   %ecx
  800c66:	52                   	push   %edx
  800c67:	53                   	push   %ebx
  800c68:	54                   	push   %esp
  800c69:	55                   	push   %ebp
  800c6a:	56                   	push   %esi
  800c6b:	57                   	push   %edi
  800c6c:	8d 35 76 0c 80 00    	lea    0x800c76,%esi
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	0f 34                	sysenter 

00800c76 <after_sysenter_label133>:
  800c76:	5f                   	pop    %edi
  800c77:	5e                   	pop    %esi
  800c78:	5d                   	pop    %ebp
  800c79:	5c                   	pop    %esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5a                   	pop    %edx
  800c7c:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 cb                	mov    %ecx,%ebx
  800c95:	89 cf                	mov    %ecx,%edi
  800c97:	51                   	push   %ecx
  800c98:	52                   	push   %edx
  800c99:	53                   	push   %ebx
  800c9a:	54                   	push   %esp
  800c9b:	55                   	push   %ebp
  800c9c:	56                   	push   %esi
  800c9d:	57                   	push   %edi
  800c9e:	8d 35 a8 0c 80 00    	lea    0x800ca8,%esi
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	0f 34                	sysenter 

00800ca8 <after_sysenter_label159>:
  800ca8:	5f                   	pop    %edi
  800ca9:	5e                   	pop    %esi
  800caa:	5d                   	pop    %ebp
  800cab:	5c                   	pop    %esp
  800cac:	5b                   	pop    %ebx
  800cad:	5a                   	pop    %edx
  800cae:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
	...

00800cb4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800cbc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  800cbf:	a1 08 20 80 00       	mov    0x802008,%eax
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	74 10                	je     800cd8 <_panic+0x24>
		cprintf("%s: ", argv0);
  800cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccc:	c7 04 24 ff 11 80 00 	movl   $0x8011ff,(%esp)
  800cd3:	e8 f0 f4 ff ff       	call   8001c8 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cd8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800cde:	e8 3a ff ff ff       	call   800c1d <sys_getenvid>
  800ce3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce6:	89 54 24 10          	mov    %edx,0x10(%esp)
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cf1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf9:	c7 04 24 04 12 80 00 	movl   $0x801204,(%esp)
  800d00:	e8 c3 f4 ff ff       	call   8001c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d09:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0c:	89 04 24             	mov    %eax,(%esp)
  800d0f:	e8 53 f4 ff ff       	call   800167 <vcprintf>
	cprintf("\n");
  800d14:	c7 04 24 a1 0f 80 00 	movl   $0x800fa1,(%esp)
  800d1b:	e8 a8 f4 ff ff       	call   8001c8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d20:	cc                   	int3   
  800d21:	eb fd                	jmp    800d20 <_panic+0x6c>
	...

00800d24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d24:	55                   	push   %ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	83 ec 10             	sub    $0x10,%esp
  800d2a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d2e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d36:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d3a:	89 cd                	mov    %ecx,%ebp
  800d3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	75 2c                	jne    800d70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d44:	39 f9                	cmp    %edi,%ecx
  800d46:	77 68                	ja     800db0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d48:	85 c9                	test   %ecx,%ecx
  800d4a:	75 0b                	jne    800d57 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d51:	31 d2                	xor    %edx,%edx
  800d53:	f7 f1                	div    %ecx
  800d55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d57:	31 d2                	xor    %edx,%edx
  800d59:	89 f8                	mov    %edi,%eax
  800d5b:	f7 f1                	div    %ecx
  800d5d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d5f:	89 f0                	mov    %esi,%eax
  800d61:	f7 f1                	div    %ecx
  800d63:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d65:	89 f0                	mov    %esi,%eax
  800d67:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d70:	39 f8                	cmp    %edi,%eax
  800d72:	77 2c                	ja     800da0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d74:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800d77:	83 f6 1f             	xor    $0x1f,%esi
  800d7a:	75 4c                	jne    800dc8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d7c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d7e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d83:	72 0a                	jb     800d8f <__udivdi3+0x6b>
  800d85:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800d89:	0f 87 ad 00 00 00    	ja     800e3c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d8f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d94:	89 f0                	mov    %esi,%eax
  800d96:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    
  800d9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800da0:	31 ff                	xor    %edi,%edi
  800da2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da4:	89 f0                	mov    %esi,%eax
  800da6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    
  800daf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db0:	89 fa                	mov    %edi,%edx
  800db2:	89 f0                	mov    %esi,%eax
  800db4:	f7 f1                	div    %ecx
  800db6:	89 c6                	mov    %eax,%esi
  800db8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dba:	89 f0                	mov    %esi,%eax
  800dbc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dbe:	83 c4 10             	add    $0x10,%esp
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
  800dc5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dc8:	89 f1                	mov    %esi,%ecx
  800dca:	d3 e0                	shl    %cl,%eax
  800dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800dd0:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800dd7:	89 ea                	mov    %ebp,%edx
  800dd9:	88 c1                	mov    %al,%cl
  800ddb:	d3 ea                	shr    %cl,%edx
  800ddd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800de1:	09 ca                	or     %ecx,%edx
  800de3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800de7:	89 f1                	mov    %esi,%ecx
  800de9:	d3 e5                	shl    %cl,%ebp
  800deb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800def:	89 fd                	mov    %edi,%ebp
  800df1:	88 c1                	mov    %al,%cl
  800df3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800df5:	89 fa                	mov    %edi,%edx
  800df7:	89 f1                	mov    %esi,%ecx
  800df9:	d3 e2                	shl    %cl,%edx
  800dfb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dff:	88 c1                	mov    %al,%cl
  800e01:	d3 ef                	shr    %cl,%edi
  800e03:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e05:	89 f8                	mov    %edi,%eax
  800e07:	89 ea                	mov    %ebp,%edx
  800e09:	f7 74 24 08          	divl   0x8(%esp)
  800e0d:	89 d1                	mov    %edx,%ecx
  800e0f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e11:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e15:	39 d1                	cmp    %edx,%ecx
  800e17:	72 17                	jb     800e30 <__udivdi3+0x10c>
  800e19:	74 09                	je     800e24 <__udivdi3+0x100>
  800e1b:	89 fe                	mov    %edi,%esi
  800e1d:	31 ff                	xor    %edi,%edi
  800e1f:	e9 41 ff ff ff       	jmp    800d65 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e24:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e28:	89 f1                	mov    %esi,%ecx
  800e2a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e2c:	39 c2                	cmp    %eax,%edx
  800e2e:	73 eb                	jae    800e1b <__udivdi3+0xf7>
		{
		  q0--;
  800e30:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e33:	31 ff                	xor    %edi,%edi
  800e35:	e9 2b ff ff ff       	jmp    800d65 <__udivdi3+0x41>
  800e3a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e3c:	31 f6                	xor    %esi,%esi
  800e3e:	e9 22 ff ff ff       	jmp    800d65 <__udivdi3+0x41>
	...

00800e44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	83 ec 20             	sub    $0x20,%esp
  800e4a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e52:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e56:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e62:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e64:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e66:	85 ed                	test   %ebp,%ebp
  800e68:	75 16                	jne    800e80 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e6a:	39 f1                	cmp    %esi,%ecx
  800e6c:	0f 86 a6 00 00 00    	jbe    800f18 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e72:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e74:	89 d0                	mov    %edx,%eax
  800e76:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e78:	83 c4 20             	add    $0x20,%esp
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    
  800e7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e80:	39 f5                	cmp    %esi,%ebp
  800e82:	0f 87 ac 00 00 00    	ja     800f34 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e88:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800e8b:	83 f0 1f             	xor    $0x1f,%eax
  800e8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e92:	0f 84 a8 00 00 00    	je     800f40 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e98:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800e9c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e9e:	bf 20 00 00 00       	mov    $0x20,%edi
  800ea3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ea7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eab:	89 f9                	mov    %edi,%ecx
  800ead:	d3 e8                	shr    %cl,%eax
  800eaf:	09 e8                	or     %ebp,%eax
  800eb1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800eb5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eb9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ebd:	d3 e0                	shl    %cl,%eax
  800ebf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ec3:	89 f2                	mov    %esi,%edx
  800ec5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ec7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ecb:	d3 e0                	shl    %cl,%eax
  800ecd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ed1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 e8                	shr    %cl,%eax
  800ed9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800edb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800edd:	89 f2                	mov    %esi,%edx
  800edf:	f7 74 24 18          	divl   0x18(%esp)
  800ee3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ee5:	f7 64 24 0c          	mull   0xc(%esp)
  800ee9:	89 c5                	mov    %eax,%ebp
  800eeb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eed:	39 d6                	cmp    %edx,%esi
  800eef:	72 67                	jb     800f58 <__umoddi3+0x114>
  800ef1:	74 75                	je     800f68 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ef3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ef7:	29 e8                	sub    %ebp,%eax
  800ef9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800efb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eff:	d3 e8                	shr    %cl,%eax
  800f01:	89 f2                	mov    %esi,%edx
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f07:	09 d0                	or     %edx,%eax
  800f09:	89 f2                	mov    %esi,%edx
  800f0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f0f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f11:	83 c4 20             	add    $0x20,%esp
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f18:	85 c9                	test   %ecx,%ecx
  800f1a:	75 0b                	jne    800f27 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f21:	31 d2                	xor    %edx,%edx
  800f23:	f7 f1                	div    %ecx
  800f25:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f27:	89 f0                	mov    %esi,%eax
  800f29:	31 d2                	xor    %edx,%edx
  800f2b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f2d:	89 f8                	mov    %edi,%eax
  800f2f:	e9 3e ff ff ff       	jmp    800e72 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f34:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f36:	83 c4 20             	add    $0x20,%esp
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f40:	39 f5                	cmp    %esi,%ebp
  800f42:	72 04                	jb     800f48 <__umoddi3+0x104>
  800f44:	39 f9                	cmp    %edi,%ecx
  800f46:	77 06                	ja     800f4e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	29 cf                	sub    %ecx,%edi
  800f4c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f4e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f50:	83 c4 20             	add    $0x20,%esp
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    
  800f57:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f58:	89 d1                	mov    %edx,%ecx
  800f5a:	89 c5                	mov    %eax,%ebp
  800f5c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f60:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f64:	eb 8d                	jmp    800ef3 <__umoddi3+0xaf>
  800f66:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f68:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f6c:	72 ea                	jb     800f58 <__umoddi3+0x114>
  800f6e:	89 f1                	mov    %esi,%ecx
  800f70:	eb 81                	jmp    800ef3 <__umoddi3+0xaf>
