#
#	NMH's Simple C Compiler, 2014
#	C runtime module for Darwin/x86-64
#

# Calling conventions as per System V Application Binary Interface:
# If the class is MEMORY, pass the argument on the stack. If the size of an object is larger than four eight bytes, or
# it contains unaligned fields, it has class MEMORY.
# If the class is INTEGER, the next available register of the sequence %rdi, %rsi, %rdx, %rcx, %r8 and %r9 is used.
# If the class is SSE, the next available vector register is used, the registers are taken in the order from %xmm0 to
# %xmm7.
# Once registers are assigned, the arguments passed in memory are pushed on the stack in reversed (right-to-left) order.
# For calls that may call functions that use varargs or stdargs (prototype-less calls or calls to functions containing
# ellipsis (...) in the declaration) %al is used as hidden argument to specify the number of vector registers used.

	.data
	.align	4
	.globl	Cenviron
Cenviron:
	.quad	0

	.text
	.globl	_main
_main:
	pushq	%rbp
	movq	%rsp,%rbp
	subq    $32, %rsp
	movl    %edi, -4(%rbp)	# argc
	movq    %rsi, -16(%rbp)	# argv
	movq    %rdx, -24(%rbp)	# envp

	pushq	%rdi
	call	C_init	#INIT
	popq	%rdi

	movq	-24(%rbp),%rax
	movq	%rax,Cenviron(%rip)

	movq	-16(%rbp), %rsi
	pushq	%rsi		# argv
	xorq	%rcx,%rcx
	movl	-4(%rbp),%ecx
	pushq	%rcx		# argc
	call	Cmain
	addq	$16,%rsp

	addq    $32, %rsp
	movq	%rbp,%rsp
	popq	%rbp
	ret

# internal switch(expr) routine
# %rsi = switch table, %rax = expr
	.text
	.globl	switch
switch:
	pushq	%rsi
	movq	%rdx,%rsi
	movq	%rax,%rbx
	cld
	lodsq
	movq	%rax,%rcx
next:	lodsq
	movq	%rax,%rdx
	lodsq
	cmpq	%rdx,%rbx
	jnz	no
	popq	%rsi
	jmp	*%rax
no:	loop	next
	lodsq
	popq	%rsi
	jmp	*%rax

# int setjmp(jmp_buf env);
	.text
	.globl	Csetjmp
Csetjmp:
	movq	8(%rsp),%rdx	# env
	movq	%rsp,(%rdx)
	addq	$8,(%rdx)
	movq	%rbp,8(%rdx)
	movq	(%rsp),%rax
	movq	%rax,16(%rdx)
	xorq	%rax,%rax
	ret

# void longjmp(jmp_buf env, int v);
	.text
	.globl	Clongjmp
Clongjmp:
	movq	16(%rsp),%rax	# v
	orq	%rax,%rax
	jne	vok
	incq	%rax
vok:	movq	8(%rsp),%rdx	# env
	movq	(%rdx),%rsp
	movq	8(%rdx),%rbp
	movq	16(%rdx),%rdx
	jmp	*%rdx

# void _exit(int rc);
	.text
	.globl	C_exit
C_exit:
	movq	8(%rsp),%rdi			# rc
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp

	call	_exit

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _sbrk(int size);
	.text
	.globl	C_sbrk
C_sbrk:
	movq	8(%rsp),%rdi			# size
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_sbrk

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _write(int fd, void *buf, int len);
	.text
	.globl	C_write
C_write:
	movq	24(%rsp),%rdx			# len
	movq	16(%rsp),%rsi			# buf
	movq	8(%rsp),%rdi			# fd
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_write

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _read(int fd, void *buf, int len);
	.text
	.globl	C_read
C_read:
	movq	24(%rsp),%rdx			# len
	movq	16(%rsp),%rsi			# buf
	movq	8(%rsp),%rdi			# fd
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_read

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _lseek(int fd, int pos, int how);
	.text
	.globl	C_lseek
C_lseek:
	movq	24(%rsp),%rdx			# how
	movq	16(%rsp),%rsi			# pos
	movq	8(%rsp),%rdi			# fd
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_lseek

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _creat(char *path, int mode);
	.text
	.globl	C_creat
C_creat:
	movq	16(%rsp),%rsi			# mode
	movq	8(%rsp),%rdi			# path
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_creat
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _open(char *path, int flags);
	.text
	.globl	C_open
C_open:
	movq	16(%rsp),%rsi			# flags
	movq	8(%rsp),%rdi			# path
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_open
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _close(int fd);
	.text
	.globl	C_close
C_close:
	movq	8(%rsp),%rdi			# fd
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_close
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _unlink(char *path);
	.text
	.globl	C_unlink
C_unlink:
	movq	8(%rsp),%rdi			# path
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp

	call	_unlink
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _rename(char *old, char *new);
	.text
	.globl	C_rename
C_rename:
	movq	16(%rsp),%rsi			# new
	movq	8(%rsp),%rdi			# old
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_rename
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _fork(void);
	.text
	.globl	C_fork
C_fork:
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp

	call	_fork
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _wait(int *rc);
	.data
ww:	.quad	0
	.text
	.globl	C_wait
C_wait:
	leaq	ww(%rip),%rdi
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_wait
	cltq

	movq    %rbp,%rsp
	popq    %rbp

	movq	8(%rsp),%rdx			# rc
	pushq	%rax
	pushq	%rbx
	movq	ww(%rip),%rax
	andb	$127,%al
	xorq	%rbx,%rbx
	movb	%ah,%bl
	test	%al,%al
	jz	wait_bye
	movq	ww(%rip),%rbx
wait_bye:
	movq	%rbx,(%rdx)
	popq	%rbx
	popq	%rax
	ret

# int _execve(char *path, char *argv[], char *envp[]);
	.text
	.globl	C_execve
C_execve:
	movq	24(%rsp),%rdx			# envp
	movq	16(%rsp),%rsi			# argv
	movq	8(%rsp),%rdi			# path
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp

	call	_execve
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int _time(void);
	.text
	.globl	C_time
C_time:
	xorq	%rdi,%rdi
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp

	call	_time

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int raise(int sig);
	.text
	.globl	Craise
Craise:
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_getpid
	cltq

	movq    %rbp,%rsp
	popq    %rbp

	movq	%rax,%rdi
	movq	8(%rsp),%rsi			# sig

	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp
	xorq	%rax,%rax

	call	_kill
	cltq

	movq    %rbp,%rsp
	popq    %rbp
	ret

# int signal(int sig, int (*fn)());
	.text
	.globl	Csignal
Csignal:
	movq	16(%rsp),%rsi			# fn
	movq	8(%rsp),%rdi			# sig
	pushq   %rbp
	movq    %rsp,%rbp
	andq    $~0xf,%rsp

	call	_signal

	movq    %rbp,%rsp
	popq    %rbp
	ret
