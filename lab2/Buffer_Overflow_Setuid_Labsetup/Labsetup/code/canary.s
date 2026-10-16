	.file	"stack.c"
	.text
	.globl	bof
	.type	bof, @function
bof:
.LFB6:
	.cfi_startproc
	endbr32
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%ebx
	subl	$132, %esp
	.cfi_offset 3, -12
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	8(%ebp), %edx
	movl	%edx, -124(%ebp)
	movl	%gs:20, %ecx
	movl	%ecx, -12(%ebp)
	xorl	%ecx, %ecx
	subl	$8, %esp
	pushl	-124(%ebp)
	leal	-112(%ebp), %edx
	pushl	%edx
	movl	%eax, %ebx
	call	strcpy@PLT
	addl	$16, %esp
	movl	$1, %eax
	movl	-12(%ebp), %ecx
	xorl	%gs:20, %ecx
	je	.L3
	call	__stack_chk_fail_local
.L3:
	movl	-4(%ebp), %ebx
	leave
	.cfi_restore 5
	.cfi_restore 3
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE6:
	.size	bof, .-bof
	.section	.rodata
.LC0:
	.string	"r"
.LC1:
	.string	"badfile"
.LC2:
	.string	"Opening badfile"
.LC3:
	.string	"Input size: %d\n"
.LC4:
	.string	"==== Returned Properly ====\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB7:
	.cfi_startproc
	endbr32
	leal	4(%esp), %ecx
	.cfi_def_cfa 1, 0
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	pushl	%ebx
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x78,0x6
	.cfi_escape 0x10,0x3,0x2,0x75,0x7c
	subl	$560, %esp
	call	__x86.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	%ecx, %eax
	movl	4(%eax), %eax
	movl	%eax, -556(%ebp)
	movl	%gs:20, %eax
	movl	%eax, -12(%ebp)
	xorl	%eax, %eax
	subl	$8, %esp
	leal	.LC0@GOTOFF(%ebx), %eax
	pushl	%eax
	leal	.LC1@GOTOFF(%ebx), %eax
	pushl	%eax
	call	fopen@PLT
	addl	$16, %esp
	movl	%eax, -540(%ebp)
	cmpl	$0, -540(%ebp)
	jne	.L5
	subl	$12, %esp
	leal	.LC2@GOTOFF(%ebx), %eax
	pushl	%eax
	call	perror@PLT
	addl	$16, %esp
	subl	$12, %esp
	pushl	$1
	call	exit@PLT
.L5:
	pushl	-540(%ebp)
	pushl	$517
	pushl	$1
	leal	-529(%ebp), %eax
	pushl	%eax
	call	fread@PLT
	addl	$16, %esp
	movl	%eax, -536(%ebp)
	subl	$8, %esp
	pushl	-536(%ebp)
	leal	.LC3@GOTOFF(%ebx), %eax
	pushl	%eax
	call	printf@PLT
	addl	$16, %esp
	subl	$12, %esp
	leal	-529(%ebp), %eax
	pushl	%eax
	call	dummy_function
	addl	$16, %esp
	movl	stdout@GOT(%ebx), %eax
	movl	(%eax), %eax
	pushl	%eax
	pushl	$28
	pushl	$1
	leal	.LC4@GOTOFF(%ebx), %eax
	pushl	%eax
	call	fwrite@PLT
	addl	$16, %esp
	movl	$1, %eax
	movl	-12(%ebp), %edx
	xorl	%gs:20, %edx
	je	.L7
	call	__stack_chk_fail_local
.L7:
	leal	-8(%ebp), %esp
	popl	%ecx
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	popl	%ebx
	.cfi_restore 3
	popl	%ebp
	.cfi_restore 5
	leal	-4(%ecx), %esp
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE7:
	.size	main, .-main
	.globl	dummy_function
	.type	dummy_function, @function
dummy_function:
.LFB8:
	.cfi_startproc
	endbr32
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%ebx
	subl	$1028, %esp
	.cfi_offset 3, -12
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	8(%ebp), %edx
	movl	%edx, -1020(%ebp)
	movl	%gs:20, %ecx
	movl	%ecx, -12(%ebp)
	xorl	%ecx, %ecx
	subl	$4, %esp
	pushl	$1000
	pushl	$0
	leal	-1012(%ebp), %edx
	pushl	%edx
	movl	%eax, %ebx
	call	memset@PLT
	addl	$16, %esp
	subl	$12, %esp
	pushl	-1020(%ebp)
	call	bof
	addl	$16, %esp
	nop
	movl	-12(%ebp), %eax
	xorl	%gs:20, %eax
	je	.L9
	call	__stack_chk_fail_local
.L9:
	movl	-4(%ebp), %ebx
	leave
	.cfi_restore 5
	.cfi_restore 3
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE8:
	.size	dummy_function, .-dummy_function
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB9:
	.cfi_startproc
	movl	(%esp), %eax
	ret
	.cfi_endproc
.LFE9:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB10:
	.cfi_startproc
	movl	(%esp), %ebx
	ret
	.cfi_endproc
.LFE10:
	.hidden	__stack_chk_fail_local
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 4
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 4
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 4
4:
