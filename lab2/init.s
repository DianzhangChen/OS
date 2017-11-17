	.file	"init.c"
	.stabs	"kern/init.c",100,0,2,.Ltext0
	.text
.Ltext0:
	.stabs	"gcc2_compiled.",60,0,0,0
	.stabs	"int:t(0,1)=r(0,1);-2147483648;2147483647;",128,0,0,0
	.stabs	"char:t(0,2)=r(0,2);0;127;",128,0,0,0
	.stabs	"long int:t(0,3)=r(0,3);-2147483648;2147483647;",128,0,0,0
	.stabs	"unsigned int:t(0,4)=r(0,4);0;-1;",128,0,0,0
	.stabs	"long unsigned int:t(0,5)=r(0,5);0;-1;",128,0,0,0
	.stabs	"long long int:t(0,6)=r(0,6);0;-1;",128,0,0,0
	.stabs	"long long unsigned int:t(0,7)=r(0,7);0;-1;",128,0,0,0
	.stabs	"short int:t(0,8)=r(0,8);-32768;32767;",128,0,0,0
	.stabs	"short unsigned int:t(0,9)=r(0,9);0;65535;",128,0,0,0
	.stabs	"signed char:t(0,10)=r(0,10);-128;127;",128,0,0,0
	.stabs	"unsigned char:t(0,11)=r(0,11);0;255;",128,0,0,0
	.stabs	"float:t(0,12)=r(0,1);4;0;",128,0,0,0
	.stabs	"double:t(0,13)=r(0,1);8;0;",128,0,0,0
	.stabs	"long double:t(0,14)=r(0,1);12;0;",128,0,0,0
	.stabs	"void:t(0,15)=(0,15)",128,0,0,0
	.stabs	"./inc/stdio.h",130,0,0,0
	.stabs	"./inc/stdarg.h",130,0,0,0
	.stabs	"va_list:t(2,1)=(2,2)=*(0,2)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.stabs	"./inc/string.h",130,0,0,0
	.stabs	"./inc/types.h",130,0,0,0
	.stabs	"bool:t(4,1)=(0,1)",128,0,0,0
	.stabs	"int8_t:t(4,2)=(0,10)",128,0,0,0
	.stabs	"uint8_t:t(4,3)=(0,11)",128,0,0,0
	.stabs	"int16_t:t(4,4)=(0,8)",128,0,0,0
	.stabs	"uint16_t:t(4,5)=(0,9)",128,0,0,0
	.stabs	"int32_t:t(4,6)=(0,1)",128,0,0,0
	.stabs	"uint32_t:t(4,7)=(0,4)",128,0,0,0
	.stabs	"int64_t:t(4,8)=(0,6)",128,0,0,0
	.stabs	"uint64_t:t(4,9)=(0,7)",128,0,0,0
	.stabs	"intptr_t:t(4,10)=(4,6)",128,0,0,0
	.stabs	"uintptr_t:t(4,11)=(4,7)",128,0,0,0
	.stabs	"physaddr_t:t(4,12)=(4,7)",128,0,0,0
	.stabs	"ppn_t:t(4,13)=(4,7)",128,0,0,0
	.stabs	"size_t:t(4,14)=(4,7)",128,0,0,0
	.stabs	"ssize_t:t(4,15)=(4,6)",128,0,0,0
	.stabs	"off_t:t(4,16)=(4,6)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"entering test_backtrace %d\n"
.LC1:
	.string	"leaving test_backtrace %d\n"
	.text
	.align 4
	.stabs	"test_backtrace:F(0,15)",36,0,0,test_backtrace
	.stabs	"x:p(0,1)",160,0,0,32
	.globl	test_backtrace
	.type	test_backtrace, @function
test_backtrace:
	.stabn	68,0,13,.LM0-.LFBB1
.LM0:
.LFBB1:
.LFB0:
	.cfi_startproc
	pushl	%ebx
	.cfi_def_cfa_offset 8
	.cfi_offset 3, -8
	subl	$24, %esp
	.cfi_def_cfa_offset 32
	movl	32(%esp), %ebx
	.stabn	68,0,14,.LM1-.LFBB1
.LM1:
	movl	%ebx, 4(%esp)
	movl	$.LC0, (%esp)
	call	cprintf
	.stabn	68,0,15,.LM2-.LFBB1
.LM2:
	testl	%ebx, %ebx
	jle	.L2
	.stabn	68,0,16,.LM3-.LFBB1
.LM3:
	leal	-1(%ebx), %eax
	movl	%eax, (%esp)
	call	test_backtrace
.L3:
	.stabn	68,0,19,.LM4-.LFBB1
.LM4:
	movl	%ebx, 4(%esp)
	movl	$.LC1, (%esp)
	call	cprintf
	.stabn	68,0,20,.LM5-.LFBB1
.LM5:
	addl	$24, %esp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	popl	%ebx
	.cfi_def_cfa_offset 4
	.cfi_restore 3
	ret
	.align 4
.L2:
	.cfi_restore_state
	.stabn	68,0,18,.LM6-.LFBB1
.LM6:
	movl	$0, 8(%esp)
	movl	$0, 4(%esp)
	movl	$0, (%esp)
	call	mon_backtrace
	jmp	.L3
	.cfi_endproc
.LFE0:
	.size	test_backtrace, .-test_backtrace
	.stabs	"x:r(0,1)",64,0,0,3
.Lscope1:
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.LC2:
	.string	"6828 decimal is %o octal!%n\n%n"
	.align 4
.LC3:
	.string	"pading space in the right to number 22: %-8d.\n"
	.section	.rodata.str1.1
.LC4:
	.string	"chnum1: %d chnum2: %d\n"
.LC5:
	.string	"%n"
.LC6:
	.string	"%s%n"
.LC7:
	.string	"chnum1: %d\n"
.LC8:
	.string	"show me the sign: %+d, %+d\n"
	.text
	.align 4
	.stabs	"i386_init:F(0,15)",36,0,0,i386_init
	.globl	i386_init
	.type	i386_init, @function
i386_init:
	.stabn	68,0,24,.LM7-.LFBB2
.LM7:
.LFBB2:
.LFB1:
	.cfi_startproc
	pushl	%edi
	.cfi_def_cfa_offset 8
	.cfi_offset 7, -8
	pushl	%ebx
	.cfi_def_cfa_offset 12
	.cfi_offset 3, -12
	subl	$292, %esp
	.cfi_def_cfa_offset 304
	.stabn	68,0,27,.LM8-.LFBB2
.LM8:
	movb	$0, 286(%esp)
	movb	$0, 287(%esp)
	leal	30(%esp), %edi
	movl	$256, %ecx
	xorl	%eax, %eax
	rep stosb
	.stabn	68,0,32,.LM9-.LFBB2
.LM9:
	movl	$end, %eax
	subl	$edata, %eax
	movl	%eax, 8(%esp)
	movl	$0, 4(%esp)
	movl	$edata, (%esp)
	call	memset
	.stabn	68,0,36,.LM10-.LFBB2
.LM10:
	call	cons_init
	.stabn	68,0,38,.LM11-.LFBB2
.LM11:
	leal	287(%esp), %eax
	movl	%eax, 12(%esp)
	leal	286(%esp), %ebx
	movl	%ebx, 8(%esp)
	movl	$6828, 4(%esp)
	movl	$.LC2, (%esp)
	call	cprintf
	.stabn	68,0,39,.LM12-.LFBB2
.LM12:
	movl	$22, 4(%esp)
	movl	$.LC3, (%esp)
	call	cprintf
	.stabn	68,0,40,.LM13-.LFBB2
.LM13:
	movsbl	287(%esp), %eax
	movl	%eax, 8(%esp)
	movsbl	286(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$.LC4, (%esp)
	call	cprintf
	.stabn	68,0,41,.LM14-.LFBB2
.LM14:
	movl	$0, 4(%esp)
	movl	$.LC5, (%esp)
	call	cprintf
	.stabn	68,0,42,.LM15-.LFBB2
.LM15:
	movl	$255, 8(%esp)
	movl	$13, 4(%esp)
	leal	30(%esp), %edi
	movl	%edi, (%esp)
	call	memset
	.stabn	68,0,43,.LM16-.LFBB2
.LM16:
	movl	%ebx, 8(%esp)
	movl	%edi, 4(%esp)
	movl	$.LC6, (%esp)
	call	cprintf
	.stabn	68,0,44,.LM17-.LFBB2
.LM17:
	movsbl	286(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$.LC7, (%esp)
	call	cprintf
	.stabn	68,0,45,.LM18-.LFBB2
.LM18:
	movl	$-1024, 8(%esp)
	movl	$1024, 4(%esp)
	movl	$.LC8, (%esp)
	call	cprintf
	.stabn	68,0,49,.LM19-.LFBB2
.LM19:
	movl	$5, (%esp)
	call	test_backtrace
	.align 4
.L6:
	.stabn	68,0,53,.LM20-.LFBB2
.LM20:
	movl	$0, (%esp)
	call	monitor
	jmp	.L6
	.cfi_endproc
.LFE1:
	.size	i386_init, .-i386_init
	.stabs	"chnum1:(0,2)",128,0,0,286
	.stabs	"chnum2:(0,2)",128,0,0,287
	.stabs	"ntest:(0,16)=ar(0,17)=r(0,17);0;-1;;0;255;(0,2)",128,0,0,30
	.stabn	192,0,0,.LFBB2-.LFBB2
	.stabn	224,0,0,.Lscope2-.LFBB2
.Lscope2:
	.section	.rodata.str1.1
.LC9:
	.string	"kernel panic at %s:%d: "
.LC10:
	.string	"\n"
	.text
	.align 4
	.stabs	"_panic:F(0,15)",36,0,0,_panic
	.stabs	"file:p(0,18)=*(0,2)",160,0,0,32
	.stabs	"line:p(0,1)",160,0,0,36
	.stabs	"fmt:p(0,18)",160,0,0,40
	.globl	_panic
	.type	_panic, @function
_panic:
	.stabn	68,0,69,.LM21-.LFBB3
.LM21:
.LFBB3:
.LFB2:
	.cfi_startproc
	pushl	%esi
	.cfi_def_cfa_offset 8
	.cfi_offset 6, -8
	pushl	%ebx
	.cfi_def_cfa_offset 12
	.cfi_offset 3, -12
	subl	$20, %esp
	.cfi_def_cfa_offset 32
	movl	40(%esp), %ebx
	.stabn	68,0,72,.LM22-.LFBB3
.LM22:
	movl	panicstr, %eax
	testl	%eax, %eax
	je	.L11
	.align 4
.L10:
	.stabn	68,0,88,.LM23-.LFBB3
.LM23:
	movl	$0, (%esp)
	call	monitor
	jmp	.L10
.L11:
	.stabn	68,0,74,.LM24-.LFBB3
.LM24:
	movl	%ebx, panicstr
	.stabn	68,0,77,.LM25-.LFBB3
.LM25:
/APP
/  77 "kern/init.c" 1
	cli; cld
/  0 "" 2
	.stabn	68,0,79,.LM26-.LFBB3
.LM26:
/NO_APP
	leal	44(%esp), %esi
	.stabn	68,0,80,.LM27-.LFBB3
.LM27:
	movl	36(%esp), %eax
	movl	%eax, 8(%esp)
	movl	32(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$.LC9, (%esp)
	call	cprintf
	.stabn	68,0,81,.LM28-.LFBB3
.LM28:
	movl	%esi, 4(%esp)
	movl	%ebx, (%esp)
	call	vcprintf
	.stabn	68,0,82,.LM29-.LFBB3
.LM29:
	movl	$.LC10, (%esp)
	call	cprintf
	jmp	.L10
	.cfi_endproc
.LFE2:
	.size	_panic, .-_panic
	.stabs	"file:r(0,18)",64,0,0,0
	.stabs	"line:r(0,1)",64,0,0,0
	.stabs	"fmt:r(0,18)",64,0,0,3
.Lscope3:
	.section	.rodata.str1.1
.LC11:
	.string	"kernel warning at %s:%d: "
	.text
	.align 4
	.stabs	"_warn:F(0,15)",36,0,0,_warn
	.stabs	"file:p(0,18)",160,0,0,32
	.stabs	"line:p(0,1)",160,0,0,36
	.stabs	"fmt:p(0,18)",160,0,0,40
	.globl	_warn
	.type	_warn, @function
_warn:
	.stabn	68,0,94,.LM30-.LFBB4
.LM30:
.LFBB4:
.LFB3:
	.cfi_startproc
	pushl	%ebx
	.cfi_def_cfa_offset 8
	.cfi_offset 3, -8
	subl	$24, %esp
	.cfi_def_cfa_offset 32
	.stabn	68,0,97,.LM31-.LFBB4
.LM31:
	leal	44(%esp), %ebx
	.stabn	68,0,98,.LM32-.LFBB4
.LM32:
	movl	36(%esp), %eax
	movl	%eax, 8(%esp)
	movl	32(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$.LC11, (%esp)
	call	cprintf
	.stabn	68,0,99,.LM33-.LFBB4
.LM33:
	movl	%ebx, 4(%esp)
	movl	40(%esp), %eax
	movl	%eax, (%esp)
	call	vcprintf
	.stabn	68,0,100,.LM34-.LFBB4
.LM34:
	movl	$.LC10, (%esp)
	call	cprintf
	.stabn	68,0,102,.LM35-.LFBB4
.LM35:
	addl	$24, %esp
	.cfi_def_cfa_offset 8
	popl	%ebx
	.cfi_def_cfa_offset 4
	.cfi_restore 3
	ret
	.cfi_endproc
.LFE3:
	.size	_warn, .-_warn
	.stabs	"file:r(0,18)",64,0,0,0
	.stabs	"line:r(0,1)",64,0,0,0
	.stabs	"fmt:r(0,18)",64,0,0,0
.Lscope4:
	.local	panicstr
	.comm	panicstr,4,4
	.stabs	"panicstr:S(0,18)",40,0,0,panicstr
	.stabs	"",100,0,0,.Letext0
.Letext0:
	.ident	"GCC: (GNU) 4.6.1"
