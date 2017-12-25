
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800041:	e8 6a 02 00 00       	call   8002b0 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800054:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  80005b:	00 
  80005c:	74 27                	je     800085 <umain+0x51>
  80005e:	eb 05                	jmp    800065 <umain+0x31>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 67 10 80 	movl   $0x801067,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  800080:	e8 1b 01 00 00       	call   8001a0 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	40                   	inc    %eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 c7                	jne    800054 <umain+0x20>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800099:	40                   	inc    %eax
  80009a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009f:	75 f1                	jne    800092 <umain+0x5e>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a1:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000a8:	75 10                	jne    8000ba <umain+0x86>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000aa:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000af:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000b6:	74 27                	je     8000df <umain+0xab>
  8000b8:	eb 05                	jmp    8000bf <umain+0x8b>
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c3:	c7 44 24 08 0c 10 80 	movl   $0x80100c,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  8000da:	e8 c1 00 00 00       	call   8001a0 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000df:	40                   	inc    %eax
  8000e0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e5:	75 c8                	jne    8000af <umain+0x7b>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000e7:	c7 04 24 34 10 80 00 	movl   $0x801034,(%esp)
  8000ee:	e8 bd 01 00 00       	call   8002b0 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000fa:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000fd:	c7 44 24 08 93 10 80 	movl   $0x801093,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  800114:	e8 87 00 00 00       	call   8001a0 <_panic>
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 10             	sub    $0x10,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80012a:	e8 d6 0b 00 00       	call   800d05 <sys_getenvid>
  80012f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800134:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800137:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80013a:	8d 04 85 00 00 c0 ee 	lea    -0x11400000(,%eax,4),%eax
  800141:	a3 20 20 c0 00       	mov    %eax,0xc02020
	//thisenv = envs + ENVX(sys_getenvid());

	cprintf("the thisenv is\n");
  800146:	c7 04 24 aa 10 80 00 	movl   $0x8010aa,(%esp)
  80014d:	e8 5e 01 00 00       	call   8002b0 <cprintf>
	cprintf("the thisenv is %x\n", thisenv);
  800152:	a1 20 20 c0 00       	mov    0xc02020,%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  800162:	e8 49 01 00 00       	call   8002b0 <cprintf>
	//cprintf("the thisenv is\n");

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800167:	85 f6                	test   %esi,%esi
  800169:	7e 07                	jle    800172 <libmain+0x56>
		binaryname = argv[0];
  80016b:	8b 03                	mov    (%ebx),%eax
  80016d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800176:	89 34 24             	mov    %esi,(%esp)
  800179:	e8 b6 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80017e:	e8 09 00 00 00       	call   80018c <exit>
}
  800183:	83 c4 10             	add    $0x10,%esp
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    
	...

0080018c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800192:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800199:	e8 03 0b 00 00       	call   800ca1 <sys_env_destroy>
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	if (argv0)
  8001ab:	a1 24 20 c0 00       	mov    0xc02024,%eax
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	74 10                	je     8001c4 <_panic+0x24>
		cprintf("%s: ", argv0);
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	c7 04 24 d7 10 80 00 	movl   $0x8010d7,(%esp)
  8001bf:	e8 ec 00 00 00       	call   8002b0 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001ca:	e8 36 0b 00 00       	call   800d05 <sys_getenvid>
  8001cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 dc 10 80 00 	movl   $0x8010dc,(%esp)
  8001ec:	e8 bf 00 00 00       	call   8002b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 4f 00 00 00       	call   80024f <vcprintf>
	cprintf("\n");
  800200:	c7 04 24 82 10 80 00 	movl   $0x801082,(%esp)
  800207:	e8 a4 00 00 00       	call   8002b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020c:	cc                   	int3   
  80020d:	eb fd                	jmp    80020c <_panic+0x6c>
	...

00800210 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	53                   	push   %ebx
  800214:	83 ec 14             	sub    $0x14,%esp
  800217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021a:	8b 03                	mov    (%ebx),%eax
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800223:	40                   	inc    %eax
  800224:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800226:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022b:	75 19                	jne    800246 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80022d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800234:	00 
  800235:	8d 43 08             	lea    0x8(%ebx),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 00 0a 00 00       	call   800c40 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800246:	ff 43 04             	incl   0x4(%ebx)
}
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800258:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025f:	00 00 00 
	b.cnt = 0;
  800262:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800269:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 10 02 80 00 	movl   $0x800210,(%esp)
  80028b:	e8 8d 01 00 00       	call   80041d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800290:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 98 09 00 00       	call   800c40 <sys_cputs>

	return b.cnt;
}
  8002a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 87 ff ff ff       	call   80024f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    
	...

008002cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 3c             	sub    $0x3c,%esp
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	72 0f                	jb     800305 <printnum+0x39>
  8002f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002fc:	76 07                	jbe    800305 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fe:	4b                   	dec    %ebx
  8002ff:	85 db                	test   %ebx,%ebx
  800301:	7f 4f                	jg     800352 <printnum+0x86>
  800303:	eb 5a                	jmp    80035f <printnum+0x93>
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800305:	89 74 24 10          	mov    %esi,0x10(%esp)
  800309:	4b                   	dec    %ebx
  80030a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80030e:	8b 45 10             	mov    0x10(%ebp),%eax
  800311:	89 44 24 08          	mov    %eax,0x8(%esp)
  800315:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800319:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80031d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800324:	00 
  800325:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800332:	e8 65 0a 00 00       	call   800d9c <__udivdi3>
  800337:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	89 54 24 04          	mov    %edx,0x4(%esp)
  800346:	89 fa                	mov    %edi,%edx
  800348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034b:	e8 7c ff ff ff       	call   8002cc <printnum>
  800350:	eb 0d                	jmp    80035f <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800356:	89 34 24             	mov    %esi,(%esp)
  800359:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035c:	4b                   	dec    %ebx
  80035d:	75 f3                	jne    800352 <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800363:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800367:	8b 45 10             	mov    0x10(%ebp),%eax
  80036a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800375:	00 
  800376:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800383:	e8 34 0b 00 00       	call   800ebc <__umoddi3>
  800388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038c:	0f be 80 00 11 80 00 	movsbl 0x801100(%eax),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800399:	83 c4 3c             	add    $0x3c,%esp
  80039c:	5b                   	pop    %ebx
  80039d:	5e                   	pop    %esi
  80039e:	5f                   	pop    %edi
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a4:	83 fa 01             	cmp    $0x1,%edx
  8003a7:	7e 0e                	jle    8003b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	8b 52 04             	mov    0x4(%edx),%edx
  8003b5:	eb 22                	jmp    8003d9 <getuint+0x38>
	else if (lflag)
  8003b7:	85 d2                	test   %edx,%edx
  8003b9:	74 10                	je     8003cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c0:	89 08                	mov    %ecx,(%eax)
  8003c2:	8b 02                	mov    (%edx),%eax
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c9:	eb 0e                	jmp    8003d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cb:	8b 10                	mov    (%eax),%edx
  8003cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d0:	89 08                	mov    %ecx,(%eax)
  8003d2:	8b 02                	mov    (%edx),%eax
  8003d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e9:	73 08                	jae    8003f3 <sprintputch+0x18>
		*b->buf++ = ch;
  8003eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ee:	88 0a                	mov    %cl,(%edx)
  8003f0:	42                   	inc    %edx
  8003f1:	89 10                	mov    %edx,(%eax)
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800402:	8b 45 10             	mov    0x10(%ebp),%eax
  800405:	89 44 24 08          	mov    %eax,0x8(%esp)
  800409:	8b 45 0c             	mov    0xc(%ebp),%eax
  80040c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
  800413:	89 04 24             	mov    %eax,(%esp)
  800416:	e8 02 00 00 00       	call   80041d <vprintfmt>
	va_end(ap);
}
  80041b:	c9                   	leave  
  80041c:	c3                   	ret    

0080041d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	83 ec 4c             	sub    $0x4c,%esp
  800426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800429:	8b 75 10             	mov    0x10(%ebp),%esi
  80042c:	eb 17                	jmp    800445 <vprintfmt+0x28>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042e:	85 c0                	test   %eax,%eax
  800430:	0f 84 93 03 00 00    	je     8007c9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	ff 55 08             	call   *0x8(%ebp)
  800440:	eb 03                	jmp    800445 <vprintfmt+0x28>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 75 e0             	mov    -0x20(%ebp),%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800445:	0f b6 06             	movzbl (%esi),%eax
  800448:	46                   	inc    %esi
  800449:	83 f8 25             	cmp    $0x25,%eax
  80044c:	75 e0                	jne    80042e <vprintfmt+0x11>
  80044e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800452:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800459:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80045e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	eb 26                	jmp    800492 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800473:	eb 1d                	jmp    800492 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800478:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80047c:	eb 14                	jmp    800492 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800481:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800488:	eb 08                	jmp    800492 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80048d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	0f b6 16             	movzbl (%esi),%edx
  800495:	8d 46 01             	lea    0x1(%esi),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	8a 06                	mov    (%esi),%al
  80049d:	83 e8 23             	sub    $0x23,%eax
  8004a0:	3c 55                	cmp    $0x55,%al
  8004a2:	0f 87 fd 02 00 00    	ja     8007a5 <vprintfmt+0x388>
  8004a8:	0f b6 c0             	movzbl %al,%eax
  8004ab:	ff 24 85 90 11 80 00 	jmp    *0x801190(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b2:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
  8004b5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004b9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004bc:	83 fa 09             	cmp    $0x9,%edx
  8004bf:	77 3f                	ja     800500 <vprintfmt+0xe3>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c4:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004c5:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c8:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004cc:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004cf:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d2:	83 fa 09             	cmp    $0x9,%edx
  8004d5:	76 ed                	jbe    8004c4 <vprintfmt+0xa7>
  8004d7:	eb 2a                	jmp    800503 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
  8004e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ed:	78 8f                	js     80047e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f2:	eb 9e                	jmp    800492 <vprintfmt+0x75>
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004fe:	eb 92                	jmp    800492 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800503:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800507:	79 89                	jns    800492 <vprintfmt+0x75>
  800509:	e9 7c ff ff ff       	jmp    80048a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050e:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800512:	e9 7b ff ff ff       	jmp    800492 <vprintfmt+0x75>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052f:	e9 11 ff ff ff       	jmp    800445 <vprintfmt+0x28>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	79 02                	jns    800545 <vprintfmt+0x128>
  800543:	f7 d8                	neg    %eax
  800545:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800547:	83 f8 06             	cmp    $0x6,%eax
  80054a:	7f 0b                	jg     800557 <vprintfmt+0x13a>
  80054c:	8b 04 85 e8 12 80 00 	mov    0x8012e8(,%eax,4),%eax
  800553:	85 c0                	test   %eax,%eax
  800555:	75 23                	jne    80057a <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800557:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055b:	c7 44 24 08 18 11 80 	movl   $0x801118,0x8(%esp)
  800562:	00 
  800563:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800567:	8b 55 08             	mov    0x8(%ebp),%edx
  80056a:	89 14 24             	mov    %edx,(%esp)
  80056d:	e8 83 fe ff ff       	call   8003f5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800575:	e9 cb fe ff ff       	jmp    800445 <vprintfmt+0x28>
			else
				printfmt(putch, putdat, "%s", p);
  80057a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057e:	c7 44 24 08 21 11 80 	movl   $0x801121,0x8(%esp)
  800585:	00 
  800586:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80058d:	89 0c 24             	mov    %ecx,(%esp)
  800590:	e8 60 fe ff ff       	call   8003f5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800598:	e9 a8 fe ff ff       	jmp    800445 <vprintfmt+0x28>
  80059d:	89 f9                	mov    %edi,%ecx
  80059f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	75 07                	jne    8005bb <vprintfmt+0x19e>
				p = "(null)";
  8005b4:	c7 45 d4 11 11 80 00 	movl   $0x801111,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8005bb:	85 f6                	test   %esi,%esi
  8005bd:	7e 3b                	jle    8005fa <vprintfmt+0x1dd>
  8005bf:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c3:	74 35                	je     8005fa <vprintfmt+0x1dd>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	e8 a4 02 00 00       	call   800878 <strnlen>
  8005d4:	29 c6                	sub    %eax,%esi
  8005d6:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005d9:	85 f6                	test   %esi,%esi
  8005db:	7e 1d                	jle    8005fa <vprintfmt+0x1dd>
					putch(padc, putdat);
  8005dd:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8005e1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	4f                   	dec    %edi
  8005f2:	75 f3                	jne    8005e7 <vprintfmt+0x1ca>
  8005f4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f7:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005fd:	0f be 02             	movsbl (%edx),%eax
  800600:	85 c0                	test   %eax,%eax
  800602:	75 43                	jne    800647 <vprintfmt+0x22a>
  800604:	eb 33                	jmp    800639 <vprintfmt+0x21c>
				if (altflag && (ch < ' ' || ch > '~'))
  800606:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060a:	74 18                	je     800624 <vprintfmt+0x207>
  80060c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060f:	83 fa 5e             	cmp    $0x5e,%edx
  800612:	76 10                	jbe    800624 <vprintfmt+0x207>
					putch('?', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
  800622:	eb 0a                	jmp    80062e <vprintfmt+0x211>
				else
					putch(ch, putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062e:	ff 4d e4             	decl   -0x1c(%ebp)
  800631:	0f be 06             	movsbl (%esi),%eax
  800634:	46                   	inc    %esi
  800635:	85 c0                	test   %eax,%eax
  800637:	75 12                	jne    80064b <vprintfmt+0x22e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800639:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063d:	7f 15                	jg     800654 <vprintfmt+0x237>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800642:	e9 fe fd ff ff       	jmp    800445 <vprintfmt+0x28>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800647:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80064a:	46                   	inc    %esi
  80064b:	85 ff                	test   %edi,%edi
  80064d:	78 b7                	js     800606 <vprintfmt+0x1e9>
  80064f:	4f                   	dec    %edi
  800650:	79 b4                	jns    800606 <vprintfmt+0x1e9>
  800652:	eb e5                	jmp    800639 <vprintfmt+0x21c>
  800654:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800657:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800665:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	4e                   	dec    %esi
  800668:	75 f0                	jne    80065a <vprintfmt+0x23d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066d:	e9 d3 fd ff ff       	jmp    800445 <vprintfmt+0x28>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800672:	83 f9 01             	cmp    $0x1,%ecx
  800675:	7e 10                	jle    800687 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 08             	lea    0x8(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)
  800680:	8b 30                	mov    (%eax),%esi
  800682:	8b 78 04             	mov    0x4(%eax),%edi
  800685:	eb 26                	jmp    8006ad <vprintfmt+0x290>
	else if (lflag)
  800687:	85 c9                	test   %ecx,%ecx
  800689:	74 12                	je     80069d <vprintfmt+0x280>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 30                	mov    (%eax),%esi
  800696:	89 f7                	mov    %esi,%edi
  800698:	c1 ff 1f             	sar    $0x1f,%edi
  80069b:	eb 10                	jmp    8006ad <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	8b 30                	mov    (%eax),%esi
  8006a8:	89 f7                	mov    %esi,%edi
  8006aa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ad:	85 ff                	test   %edi,%edi
  8006af:	78 0e                	js     8006bf <vprintfmt+0x2a2>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b5:	be 0a 00 00 00       	mov    $0xa,%esi
  8006ba:	e9 a8 00 00 00       	jmp    800767 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	89 fa                	mov    %edi,%edx
  8006d1:	f7 d8                	neg    %eax
  8006d3:	83 d2 00             	adc    $0x0,%edx
  8006d6:	f7 da                	neg    %edx
			}
			base = 10;
  8006d8:	be 0a 00 00 00       	mov    $0xa,%esi
  8006dd:	e9 85 00 00 00       	jmp    800767 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e2:	89 ca                	mov    %ecx,%edx
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	e8 b5 fc ff ff       	call   8003a1 <getuint>
			base = 10;
  8006ec:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8006f1:	eb 74                	jmp    800767 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006fe:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800701:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800705:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80070c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80070f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800713:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80071a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800720:	e9 20 fd ff ff       	jmp    800445 <vprintfmt+0x28>

		// pointer
		case 'p':
			putch('0', putdat);
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 04             	lea    0x4(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800751:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800756:	eb 0f                	jmp    800767 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800758:	89 ca                	mov    %ecx,%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 3f fc ff ff       	call   8003a1 <getuint>
			base = 16;
  800762:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800767:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
  80076b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80076f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800772:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800776:	89 74 24 08          	mov    %esi,0x8(%esp)
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800781:	89 da                	mov    %ebx,%edx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	e8 41 fb ff ff       	call   8002cc <printnum>
			break;
  80078b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078e:	e9 b2 fc ff ff       	jmp    800445 <vprintfmt+0x28>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	89 14 24             	mov    %edx,(%esp)
  80079a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 75 e0             	mov    -0x20(%ebp),%esi
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a0:	e9 a0 fc ff ff       	jmp    800445 <vprintfmt+0x28>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007b7:	0f 84 88 fc ff ff    	je     800445 <vprintfmt+0x28>
  8007bd:	4e                   	dec    %esi
  8007be:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c2:	75 f9                	jne    8007bd <vprintfmt+0x3a0>
  8007c4:	e9 7c fc ff ff       	jmp    800445 <vprintfmt+0x28>
				/* do nothing */;
			break;
		}
	}
}
  8007c9:	83 c4 4c             	add    $0x4c,%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5f                   	pop    %edi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 28             	sub    $0x28,%esp
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	74 30                	je     800822 <vsnprintf+0x51>
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	7e 33                	jle    800829 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 44 24 08          	mov    %eax,0x8(%esp)
  800804:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	c7 04 24 db 03 80 00 	movl   $0x8003db,(%esp)
  800812:	e8 06 fc ff ff       	call   80041d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800820:	eb 0c                	jmp    80082e <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800827:	eb 05                	jmp    80082e <vsnprintf+0x5d>
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083d:	8b 45 10             	mov    0x10(%ebp),%eax
  800840:	89 44 24 08          	mov    %eax,0x8(%esp)
  800844:	8b 45 0c             	mov    0xc(%ebp),%eax
  800847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 7b ff ff ff       	call   8007d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085e:	80 3a 00             	cmpb   $0x0,(%edx)
  800861:	74 0e                	je     800871 <strlen+0x19>
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800868:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800869:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086d:	75 f9                	jne    800868 <strlen+0x10>
  80086f:	eb 05                	jmp    800876 <strlen+0x1e>
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	85 c9                	test   %ecx,%ecx
  800884:	74 1a                	je     8008a0 <strnlen+0x28>
  800886:	80 3b 00             	cmpb   $0x0,(%ebx)
  800889:	74 1c                	je     8008a7 <strnlen+0x2f>
  80088b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800890:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	39 ca                	cmp    %ecx,%edx
  800894:	74 16                	je     8008ac <strnlen+0x34>
  800896:	42                   	inc    %edx
  800897:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80089c:	75 f2                	jne    800890 <strnlen+0x18>
  80089e:	eb 0c                	jmp    8008ac <strnlen+0x34>
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	eb 05                	jmp    8008ac <strnlen+0x34>
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	53                   	push   %ebx
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008be:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c4:	42                   	inc    %edx
  8008c5:	84 c9                	test   %cl,%cl
  8008c7:	75 f5                	jne    8008be <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d6:	89 1c 24             	mov    %ebx,(%esp)
  8008d9:	e8 7a ff ff ff       	call   800858 <strlen>
	strcpy(dst + len, src);
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e5:	01 d8                	add    %ebx,%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	e8 c0 ff ff ff       	call   8008af <strcpy>
	return dst;
}
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	83 c4 08             	add    $0x8,%esp
  8008f4:	5b                   	pop    %ebx
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800902:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	85 f6                	test   %esi,%esi
  800907:	74 15                	je     80091e <strncpy+0x27>
  800909:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80090e:	8a 1a                	mov    (%edx),%bl
  800910:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800913:	80 3a 01             	cmpb   $0x1,(%edx)
  800916:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	41                   	inc    %ecx
  80091a:	39 f1                	cmp    %esi,%ecx
  80091c:	75 f0                	jne    80090e <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80092e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800931:	85 f6                	test   %esi,%esi
  800933:	74 31                	je     800966 <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
  800935:	83 fe 01             	cmp    $0x1,%esi
  800938:	74 21                	je     80095b <strlcpy+0x39>
  80093a:	8a 0b                	mov    (%ebx),%cl
  80093c:	84 c9                	test   %cl,%cl
  80093e:	74 1f                	je     80095f <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800940:	83 ee 02             	sub    $0x2,%esi
  800943:	89 f8                	mov    %edi,%eax
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094a:	88 08                	mov    %cl,(%eax)
  80094c:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094d:	39 f2                	cmp    %esi,%edx
  80094f:	74 10                	je     800961 <strlcpy+0x3f>
  800951:	42                   	inc    %edx
  800952:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800955:	84 c9                	test   %cl,%cl
  800957:	75 f1                	jne    80094a <strlcpy+0x28>
  800959:	eb 06                	jmp    800961 <strlcpy+0x3f>
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	eb 02                	jmp    800961 <strlcpy+0x3f>
  80095f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
  800964:	eb 02                	jmp    800968 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800968:	29 f8                	sub    %edi,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800978:	8a 01                	mov    (%ecx),%al
  80097a:	84 c0                	test   %al,%al
  80097c:	74 11                	je     80098f <strcmp+0x20>
  80097e:	3a 02                	cmp    (%edx),%al
  800980:	75 0d                	jne    80098f <strcmp+0x20>
		p++, q++;
  800982:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800983:	8a 41 01             	mov    0x1(%ecx),%al
  800986:	84 c0                	test   %al,%al
  800988:	74 05                	je     80098f <strcmp+0x20>
  80098a:	41                   	inc    %ecx
  80098b:	3a 02                	cmp    (%edx),%al
  80098d:	74 f3                	je     800982 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 c0             	movzbl %al,%eax
  800992:	0f b6 12             	movzbl (%edx),%edx
  800995:	29 d0                	sub    %edx,%eax
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	53                   	push   %ebx
  80099d:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a3:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	74 1b                	je     8009c5 <strncmp+0x2c>
  8009aa:	8a 1a                	mov    (%edx),%bl
  8009ac:	84 db                	test   %bl,%bl
  8009ae:	74 24                	je     8009d4 <strncmp+0x3b>
  8009b0:	3a 19                	cmp    (%ecx),%bl
  8009b2:	75 20                	jne    8009d4 <strncmp+0x3b>
  8009b4:	48                   	dec    %eax
  8009b5:	74 15                	je     8009cc <strncmp+0x33>
		n--, p++, q++;
  8009b7:	42                   	inc    %edx
  8009b8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b9:	8a 1a                	mov    (%edx),%bl
  8009bb:	84 db                	test   %bl,%bl
  8009bd:	74 15                	je     8009d4 <strncmp+0x3b>
  8009bf:	3a 19                	cmp    (%ecx),%bl
  8009c1:	74 f1                	je     8009b4 <strncmp+0x1b>
  8009c3:	eb 0f                	jmp    8009d4 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	eb 05                	jmp    8009d1 <strncmp+0x38>
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d4:	0f b6 02             	movzbl (%edx),%eax
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	29 d0                	sub    %edx,%eax
  8009dc:	eb f3                	jmp    8009d1 <strncmp+0x38>

008009de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009e7:	8a 10                	mov    (%eax),%dl
  8009e9:	84 d2                	test   %dl,%dl
  8009eb:	74 19                	je     800a06 <strchr+0x28>
		if (*s == c)
  8009ed:	38 ca                	cmp    %cl,%dl
  8009ef:	75 07                	jne    8009f8 <strchr+0x1a>
  8009f1:	eb 18                	jmp    800a0b <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f3:	40                   	inc    %eax
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 13                	je     800a0b <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f8:	8a 50 01             	mov    0x1(%eax),%dl
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f4                	jne    8009f3 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 05                	jmp    800a0b <strchr+0x2d>
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a16:	8a 10                	mov    (%eax),%dl
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 11                	je     800a2d <strfind+0x20>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	75 06                	jne    800a26 <strfind+0x19>
  800a20:	eb 0b                	jmp    800a2d <strfind+0x20>
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	74 07                	je     800a2d <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a26:	40                   	inc    %eax
  800a27:	8a 10                	mov    (%eax),%dl
  800a29:	84 d2                	test   %dl,%dl
  800a2b:	75 f5                	jne    800a22 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3e:	85 c9                	test   %ecx,%ecx
  800a40:	74 30                	je     800a72 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a42:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a48:	75 25                	jne    800a6f <memset+0x40>
  800a4a:	f6 c1 03             	test   $0x3,%cl
  800a4d:	75 20                	jne    800a6f <memset+0x40>
		c &= 0xFF;
  800a4f:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a52:	89 d3                	mov    %edx,%ebx
  800a54:	c1 e3 08             	shl    $0x8,%ebx
  800a57:	89 d6                	mov    %edx,%esi
  800a59:	c1 e6 18             	shl    $0x18,%esi
  800a5c:	89 d0                	mov    %edx,%eax
  800a5e:	c1 e0 10             	shl    $0x10,%eax
  800a61:	09 f0                	or     %esi,%eax
  800a63:	09 d0                	or     %edx,%eax
  800a65:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a67:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a6a:	fc                   	cld    
  800a6b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6d:	eb 03                	jmp    800a72 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6f:	fc                   	cld    
  800a70:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a72:	89 f8                	mov    %edi,%eax
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a87:	39 c6                	cmp    %eax,%esi
  800a89:	73 34                	jae    800abf <memmove+0x46>
  800a8b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8e:	39 d0                	cmp    %edx,%eax
  800a90:	73 2d                	jae    800abf <memmove+0x46>
		s += n;
		d += n;
  800a92:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a95:	f6 c2 03             	test   $0x3,%dl
  800a98:	75 1b                	jne    800ab5 <memmove+0x3c>
  800a9a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa0:	75 13                	jne    800ab5 <memmove+0x3c>
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 0e                	jne    800ab5 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa7:	83 ef 04             	sub    $0x4,%edi
  800aaa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aad:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ab0:	fd                   	std    
  800ab1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab3:	eb 07                	jmp    800abc <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab5:	4f                   	dec    %edi
  800ab6:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab9:	fd                   	std    
  800aba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abc:	fc                   	cld    
  800abd:	eb 20                	jmp    800adf <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac5:	75 13                	jne    800ada <memmove+0x61>
  800ac7:	a8 03                	test   $0x3,%al
  800ac9:	75 0f                	jne    800ada <memmove+0x61>
  800acb:	f6 c1 03             	test   $0x3,%cl
  800ace:	75 0a                	jne    800ada <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad8:	eb 05                	jmp    800adf <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	fc                   	cld    
  800add:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  800aec:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	89 04 24             	mov    %eax,(%esp)
  800afd:	e8 77 ff ff ff       	call   800a79 <memmove>
}
  800b02:	c9                   	leave  
  800b03:	c3                   	ret    

00800b04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b10:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	85 ff                	test   %edi,%edi
  800b15:	74 31                	je     800b48 <memcmp+0x44>
		if (*s1 != *s2)
  800b17:	8a 03                	mov    (%ebx),%al
  800b19:	8a 0e                	mov    (%esi),%cl
  800b1b:	38 c8                	cmp    %cl,%al
  800b1d:	74 18                	je     800b37 <memcmp+0x33>
  800b1f:	eb 0c                	jmp    800b2d <memcmp+0x29>
  800b21:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b25:	42                   	inc    %edx
  800b26:	8a 0c 16             	mov    (%esi,%edx,1),%cl
  800b29:	38 c8                	cmp    %cl,%al
  800b2b:	74 10                	je     800b3d <memcmp+0x39>
			return (int) *s1 - (int) *s2;
  800b2d:	0f b6 c0             	movzbl %al,%eax
  800b30:	0f b6 c9             	movzbl %cl,%ecx
  800b33:	29 c8                	sub    %ecx,%eax
  800b35:	eb 16                	jmp    800b4d <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b37:	4f                   	dec    %edi
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	39 fa                	cmp    %edi,%edx
  800b3f:	75 e0                	jne    800b21 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	eb 05                	jmp    800b4d <memcmp+0x49>
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b58:	89 c2                	mov    %eax,%edx
  800b5a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5d:	39 d0                	cmp    %edx,%eax
  800b5f:	73 12                	jae    800b73 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b61:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b64:	38 08                	cmp    %cl,(%eax)
  800b66:	75 06                	jne    800b6e <memfind+0x1c>
  800b68:	eb 09                	jmp    800b73 <memfind+0x21>
  800b6a:	38 08                	cmp    %cl,(%eax)
  800b6c:	74 05                	je     800b73 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6e:	40                   	inc    %eax
  800b6f:	39 d0                	cmp    %edx,%eax
  800b71:	75 f7                	jne    800b6a <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b81:	eb 01                	jmp    800b84 <strtol+0xf>
		s++;
  800b83:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b84:	8a 02                	mov    (%edx),%al
  800b86:	3c 20                	cmp    $0x20,%al
  800b88:	74 f9                	je     800b83 <strtol+0xe>
  800b8a:	3c 09                	cmp    $0x9,%al
  800b8c:	74 f5                	je     800b83 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8e:	3c 2b                	cmp    $0x2b,%al
  800b90:	75 08                	jne    800b9a <strtol+0x25>
		s++;
  800b92:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
  800b98:	eb 13                	jmp    800bad <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b9a:	3c 2d                	cmp    $0x2d,%al
  800b9c:	75 0a                	jne    800ba8 <strtol+0x33>
		s++, neg = 1;
  800b9e:	8d 52 01             	lea    0x1(%edx),%edx
  800ba1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba6:	eb 05                	jmp    800bad <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bad:	85 db                	test   %ebx,%ebx
  800baf:	74 05                	je     800bb6 <strtol+0x41>
  800bb1:	83 fb 10             	cmp    $0x10,%ebx
  800bb4:	75 28                	jne    800bde <strtol+0x69>
  800bb6:	8a 02                	mov    (%edx),%al
  800bb8:	3c 30                	cmp    $0x30,%al
  800bba:	75 10                	jne    800bcc <strtol+0x57>
  800bbc:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc0:	75 0a                	jne    800bcc <strtol+0x57>
		s += 2, base = 16;
  800bc2:	83 c2 02             	add    $0x2,%edx
  800bc5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bca:	eb 12                	jmp    800bde <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	75 0e                	jne    800bde <strtol+0x69>
  800bd0:	3c 30                	cmp    $0x30,%al
  800bd2:	75 05                	jne    800bd9 <strtol+0x64>
		s++, base = 8;
  800bd4:	42                   	inc    %edx
  800bd5:	b3 08                	mov    $0x8,%bl
  800bd7:	eb 05                	jmp    800bde <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bd9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be5:	8a 0a                	mov    (%edx),%cl
  800be7:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bea:	80 fb 09             	cmp    $0x9,%bl
  800bed:	77 08                	ja     800bf7 <strtol+0x82>
			dig = *s - '0';
  800bef:	0f be c9             	movsbl %cl,%ecx
  800bf2:	83 e9 30             	sub    $0x30,%ecx
  800bf5:	eb 1e                	jmp    800c15 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bf7:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bfa:	80 fb 19             	cmp    $0x19,%bl
  800bfd:	77 08                	ja     800c07 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bff:	0f be c9             	movsbl %cl,%ecx
  800c02:	83 e9 57             	sub    $0x57,%ecx
  800c05:	eb 0e                	jmp    800c15 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c07:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c0a:	80 fb 19             	cmp    $0x19,%bl
  800c0d:	77 12                	ja     800c21 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c0f:	0f be c9             	movsbl %cl,%ecx
  800c12:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c15:	39 f1                	cmp    %esi,%ecx
  800c17:	7d 0c                	jge    800c25 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c19:	42                   	inc    %edx
  800c1a:	0f af c6             	imul   %esi,%eax
  800c1d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c1f:	eb c4                	jmp    800be5 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c21:	89 c1                	mov    %eax,%ecx
  800c23:	eb 02                	jmp    800c27 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c25:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2b:	74 05                	je     800c32 <strtol+0xbd>
		*endptr = (char *) s;
  800c2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c30:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c32:	85 ff                	test   %edi,%edi
  800c34:	74 04                	je     800c3a <strtol+0xc5>
  800c36:	89 c8                	mov    %ecx,%eax
  800c38:	f7 d8                	neg    %eax
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    
	...

00800c40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	89 c3                	mov    %eax,%ebx
  800c52:	89 c7                	mov    %eax,%edi
  800c54:	51                   	push   %ecx
  800c55:	52                   	push   %edx
  800c56:	53                   	push   %ebx
  800c57:	54                   	push   %esp
  800c58:	55                   	push   %ebp
  800c59:	56                   	push   %esi
  800c5a:	57                   	push   %edi
  800c5b:	8d 35 65 0c 80 00    	lea    0x800c65,%esi
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	0f 34                	sysenter 

00800c65 <after_sysenter_label16>:
  800c65:	5f                   	pop    %edi
  800c66:	5e                   	pop    %esi
  800c67:	5d                   	pop    %ebp
  800c68:	5c                   	pop    %esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5a                   	pop    %edx
  800c6b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	51                   	push   %ecx
  800c86:	52                   	push   %edx
  800c87:	53                   	push   %ebx
  800c88:	54                   	push   %esp
  800c89:	55                   	push   %ebp
  800c8a:	56                   	push   %esi
  800c8b:	57                   	push   %edi
  800c8c:	8d 35 96 0c 80 00    	lea    0x800c96,%esi
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	0f 34                	sysenter 

00800c96 <after_sysenter_label41>:
  800c96:	5f                   	pop    %edi
  800c97:	5e                   	pop    %esi
  800c98:	5d                   	pop    %ebp
  800c99:	5c                   	pop    %esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5a                   	pop    %edx
  800c9c:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 20             	sub    $0x20,%esp

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	51                   	push   %ecx
  800cbb:	52                   	push   %edx
  800cbc:	53                   	push   %ebx
  800cbd:	54                   	push   %esp
  800cbe:	55                   	push   %ebp
  800cbf:	56                   	push   %esi
  800cc0:	57                   	push   %edi
  800cc1:	8d 35 cb 0c 80 00    	lea    0x800ccb,%esi
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	0f 34                	sysenter 

00800ccb <after_sysenter_label68>:
  800ccb:	5f                   	pop    %edi
  800ccc:	5e                   	pop    %esi
  800ccd:	5d                   	pop    %ebp
  800cce:	5c                   	pop    %esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5a                   	pop    %edx
  800cd1:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7e 28                	jle    800cfe <after_sysenter_label68+0x33>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cda:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ce1:	00 
  800ce2:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800ce9:	00 
  800cea:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800cf1:	00 
  800cf2:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800cf9:	e8 a2 f4 ff ff       	call   8001a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfe:	83 c4 20             	add    $0x20,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 02 00 00 00       	mov    $0x2,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	51                   	push   %ecx
  800d1b:	52                   	push   %edx
  800d1c:	53                   	push   %ebx
  800d1d:	54                   	push   %esp
  800d1e:	55                   	push   %ebp
  800d1f:	56                   	push   %esi
  800d20:	57                   	push   %edi
  800d21:	8d 35 2b 0d 80 00    	lea    0x800d2b,%esi
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	0f 34                	sysenter 

00800d2b <after_sysenter_label107>:
  800d2b:	5f                   	pop    %edi
  800d2c:	5e                   	pop    %esi
  800d2d:	5d                   	pop    %ebp
  800d2e:	5c                   	pop    %esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5a                   	pop    %edx
  800d31:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d32:	5b                   	pop    %ebx
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d40:	b8 04 00 00 00       	mov    $0x4,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 df                	mov    %ebx,%edi
  800d4d:	51                   	push   %ecx
  800d4e:	52                   	push   %edx
  800d4f:	53                   	push   %ebx
  800d50:	54                   	push   %esp
  800d51:	55                   	push   %ebp
  800d52:	56                   	push   %esi
  800d53:	57                   	push   %edi
  800d54:	8d 35 5e 0d 80 00    	lea    0x800d5e,%esi
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	0f 34                	sysenter 

00800d5e <after_sysenter_label133>:
  800d5e:	5f                   	pop    %edi
  800d5f:	5e                   	pop    %esi
  800d60:	5d                   	pop    %ebp
  800d61:	5c                   	pop    %esp
  800d62:	5b                   	pop    %ebx
  800d63:	5a                   	pop    %edx
  800d64:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d73:	b8 05 00 00 00       	mov    $0x5,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 cb                	mov    %ecx,%ebx
  800d7d:	89 cf                	mov    %ecx,%edi
  800d7f:	51                   	push   %ecx
  800d80:	52                   	push   %edx
  800d81:	53                   	push   %ebx
  800d82:	54                   	push   %esp
  800d83:	55                   	push   %ebp
  800d84:	56                   	push   %esi
  800d85:	57                   	push   %edi
  800d86:	8d 35 90 0d 80 00    	lea    0x800d90,%esi
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	0f 34                	sysenter 

00800d90 <after_sysenter_label159>:
  800d90:	5f                   	pop    %edi
  800d91:	5e                   	pop    %esi
  800d92:	5d                   	pop    %ebp
  800d93:	5c                   	pop    %esp
  800d94:	5b                   	pop    %ebx
  800d95:	5a                   	pop    %edx
  800d96:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800d97:	5b                   	pop    %ebx
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
	...

00800d9c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d9c:	55                   	push   %ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	83 ec 10             	sub    $0x10,%esp
  800da2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800da6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800daa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800db2:	89 cd                	mov    %ecx,%ebp
  800db4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	75 2c                	jne    800de8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dbc:	39 f9                	cmp    %edi,%ecx
  800dbe:	77 68                	ja     800e28 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dc0:	85 c9                	test   %ecx,%ecx
  800dc2:	75 0b                	jne    800dcf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dc4:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc9:	31 d2                	xor    %edx,%edx
  800dcb:	f7 f1                	div    %ecx
  800dcd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dcf:	31 d2                	xor    %edx,%edx
  800dd1:	89 f8                	mov    %edi,%eax
  800dd3:	f7 f1                	div    %ecx
  800dd5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd7:	89 f0                	mov    %esi,%eax
  800dd9:	f7 f1                	div    %ecx
  800ddb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de8:	39 f8                	cmp    %edi,%eax
  800dea:	77 2c                	ja     800e18 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dec:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800def:	83 f6 1f             	xor    $0x1f,%esi
  800df2:	75 4c                	jne    800e40 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800df4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800df6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dfb:	72 0a                	jb     800e07 <__udivdi3+0x6b>
  800dfd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e01:	0f 87 ad 00 00 00    	ja     800eb4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e07:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e10:	83 c4 10             	add    $0x10,%esp
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
  800e18:	31 ff                	xor    %edi,%edi
  800e1a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e1c:	89 f0                	mov    %esi,%eax
  800e1e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
  800e27:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	89 f0                	mov    %esi,%eax
  800e2c:	f7 f1                	div    %ecx
  800e2e:	89 c6                	mov    %eax,%esi
  800e30:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e32:	89 f0                	mov    %esi,%eax
  800e34:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e40:	89 f1                	mov    %esi,%ecx
  800e42:	d3 e0                	shl    %cl,%eax
  800e44:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e48:	b8 20 00 00 00       	mov    $0x20,%eax
  800e4d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e4f:	89 ea                	mov    %ebp,%edx
  800e51:	88 c1                	mov    %al,%cl
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e59:	09 ca                	or     %ecx,%edx
  800e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e5f:	89 f1                	mov    %esi,%ecx
  800e61:	d3 e5                	shl    %cl,%ebp
  800e63:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e67:	89 fd                	mov    %edi,%ebp
  800e69:	88 c1                	mov    %al,%cl
  800e6b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e6d:	89 fa                	mov    %edi,%edx
  800e6f:	89 f1                	mov    %esi,%ecx
  800e71:	d3 e2                	shl    %cl,%edx
  800e73:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e77:	88 c1                	mov    %al,%cl
  800e79:	d3 ef                	shr    %cl,%edi
  800e7b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e7d:	89 f8                	mov    %edi,%eax
  800e7f:	89 ea                	mov    %ebp,%edx
  800e81:	f7 74 24 08          	divl   0x8(%esp)
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e89:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8d:	39 d1                	cmp    %edx,%ecx
  800e8f:	72 17                	jb     800ea8 <__udivdi3+0x10c>
  800e91:	74 09                	je     800e9c <__udivdi3+0x100>
  800e93:	89 fe                	mov    %edi,%esi
  800e95:	31 ff                	xor    %edi,%edi
  800e97:	e9 41 ff ff ff       	jmp    800ddd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e9c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea0:	89 f1                	mov    %esi,%ecx
  800ea2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea4:	39 c2                	cmp    %eax,%edx
  800ea6:	73 eb                	jae    800e93 <__udivdi3+0xf7>
		{
		  q0--;
  800ea8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eab:	31 ff                	xor    %edi,%edi
  800ead:	e9 2b ff ff ff       	jmp    800ddd <__udivdi3+0x41>
  800eb2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eb4:	31 f6                	xor    %esi,%esi
  800eb6:	e9 22 ff ff ff       	jmp    800ddd <__udivdi3+0x41>
	...

00800ebc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ebc:	55                   	push   %ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	83 ec 20             	sub    $0x20,%esp
  800ec2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ec6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eca:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ece:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800ed2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ed6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eda:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800edc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ede:	85 ed                	test   %ebp,%ebp
  800ee0:	75 16                	jne    800ef8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800ee2:	39 f1                	cmp    %esi,%ecx
  800ee4:	0f 86 a6 00 00 00    	jbe    800f90 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eea:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800eec:	89 d0                	mov    %edx,%eax
  800eee:	31 d2                	xor    %edx,%edx
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ef8:	39 f5                	cmp    %esi,%ebp
  800efa:	0f 87 ac 00 00 00    	ja     800fac <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f00:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f03:	83 f0 1f             	xor    $0x1f,%eax
  800f06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0a:	0f 84 a8 00 00 00    	je     800fb8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f10:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f14:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f16:	bf 20 00 00 00       	mov    $0x20,%edi
  800f1b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f1f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	d3 e8                	shr    %cl,%eax
  800f27:	09 e8                	or     %ebp,%eax
  800f29:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f2d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f31:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f35:	d3 e0                	shl    %cl,%eax
  800f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f3b:	89 f2                	mov    %esi,%edx
  800f3d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f43:	d3 e0                	shl    %cl,%eax
  800f45:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f49:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f4d:	89 f9                	mov    %edi,%ecx
  800f4f:	d3 e8                	shr    %cl,%eax
  800f51:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f53:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f55:	89 f2                	mov    %esi,%edx
  800f57:	f7 74 24 18          	divl   0x18(%esp)
  800f5b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f5d:	f7 64 24 0c          	mull   0xc(%esp)
  800f61:	89 c5                	mov    %eax,%ebp
  800f63:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f65:	39 d6                	cmp    %edx,%esi
  800f67:	72 67                	jb     800fd0 <__umoddi3+0x114>
  800f69:	74 75                	je     800fe0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f6b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f6f:	29 e8                	sub    %ebp,%eax
  800f71:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f73:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f77:	d3 e8                	shr    %cl,%eax
  800f79:	89 f2                	mov    %esi,%edx
  800f7b:	89 f9                	mov    %edi,%ecx
  800f7d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f7f:	09 d0                	or     %edx,%eax
  800f81:	89 f2                	mov    %esi,%edx
  800f83:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f87:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f90:	85 c9                	test   %ecx,%ecx
  800f92:	75 0b                	jne    800f9f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f94:	b8 01 00 00 00       	mov    $0x1,%eax
  800f99:	31 d2                	xor    %edx,%edx
  800f9b:	f7 f1                	div    %ecx
  800f9d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	31 d2                	xor    %edx,%edx
  800fa3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fa5:	89 f8                	mov    %edi,%eax
  800fa7:	e9 3e ff ff ff       	jmp    800eea <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fac:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fae:	83 c4 20             	add    $0x20,%esp
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fb8:	39 f5                	cmp    %esi,%ebp
  800fba:	72 04                	jb     800fc0 <__umoddi3+0x104>
  800fbc:	39 f9                	cmp    %edi,%ecx
  800fbe:	77 06                	ja     800fc6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	29 cf                	sub    %ecx,%edi
  800fc4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fc6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fc8:	83 c4 20             	add    $0x20,%esp
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    
  800fcf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fd0:	89 d1                	mov    %edx,%ecx
  800fd2:	89 c5                	mov    %eax,%ebp
  800fd4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fd8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fdc:	eb 8d                	jmp    800f6b <__umoddi3+0xaf>
  800fde:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fe4:	72 ea                	jb     800fd0 <__umoddi3+0x114>
  800fe6:	89 f1                	mov    %esi,%ecx
  800fe8:	eb 81                	jmp    800f6b <__umoddi3+0xaf>
