@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@   Copyright (C) 2006 by Yuri Ovcharenko                                 @
@   amwsoft@gmail.com                                                     @
@                                                                         @
@   This program is free software; you can redistribute it and/or modify  @
@   it under the terms of the GNU Library General Public License as       @
@   published by the Free Software Foundation; either version 2 of the    @
@   License, or (at your option) any later version.                       @
@                                                                         @
@   This program is distributed in the hope that it will be useful,       @
@   but WITHOUT ANY WARRANTY; without even the implied warranty of        @
@   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         @
@   GNU General Public License for more details.                          @
@                                                                         @
@   You should have received a copy of the GNU Library General Public     @
@   License along with this program; if not, write to the                 @
@   Free Software Foundation, Inc.,                                       @
@   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@   This file is part of DSP project                                      @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@--------------------------------------------------------------------------
	.equ	USR_MODE,		0x10
	.equ	FIQ_MODE,		0x11
	.equ	IRQ_MODE,		0x12
	.equ	SVC_MODE,		0x13
	.equ	ABT_MODE,		0x17
	.equ	UNDEF_MODE,		0x1B
	.equ	SYS_MODE,		0x1F
@--------------------------------------------------------------------------
	.equ	I_BIT,			0x80 @ when I bit is set, IRQ is disabled
	.equ	F_BIT,			0x40 @ when F bit is set, FIQ is disabled
@--------------------------------------------------------------------------
	.equ	TOP_STACK,		_stack
	.equ	UNDEF_STACK_SIZE,	0x00000100
	.equ	ABT_STACK_SIZE,		0x00000100
	.equ	FIQ_STACK_SIZE,		0x00000100
	.equ	IRQ_STACK_SIZE,		0x00000100
	.equ	SVC_STACK_SIZE,		0x00000100
	.equ	USR_STACK_SIZE,		0x00000800
@ Advanced Interrupt controller (AIC) definitions
	.equ	VIC_VECT_ADDR,		0xFFFFFF00
@--------------------------------------------------------------------------
	.extern	low_level_init
	.extern debug_regs
	.extern	debug_send_str
	.extern debug_dump_registers
	.extern debug_dump_stack
	.extern	main
@--------------------------------------------------------------------------
@	Entry point
	.global _start
@--------------------------------------------------------------------------
	.section .vectors
	.code	32
	.arm
@--------------------------------------------------------------------------
@	Exeption vectors
EXCEPTION_VECTORS:
	ldr	pc, RESET_ADDR
	ldr	pc, UNDEF_ADDR
	ldr	pc, SWI_ADDR
	ldr	pc, PREFETCH_ABORT_ADDR
	ldr	pc, DATA_ABORT_ADDR
	.word	0
	ldr	pc, IRQ_ADDR
	ldr	pc, FIQ_ADDR
RESET_ADDR:		.word	_start
UNDEF_ADDR:		.word	UNDEF_handler
SWI_ADDR:		.word	SWI_handler
PREFETCH_ABORT_ADDR:	.word	PREFETCH_ABORT_handler
DATA_ABORT_ADDR:	.word	DATA_ABORT_handler
IRQ_ADDR:		.word	IRQ_handler
FIQ_ADDR:		.word	FIQ_handler
@--------------------------------------------------------------------------
	.section .text
	.code	32
	.arm
@--------------------------------------------------------------------------
@	Prepare register and stack dump
@	All registers must be saved in exception handler
@
	.extern debug_level
_dump_prepare:
@	Save registers to debug_regs
	mov	r1, sp
	ldr	r4, [r1], #4	@ SPSR
	mov	r3, #13
	ldr	r0, =debug_regs
1:
	ldr	r2, [r1], #4	@ r0-r12 in stack
	str	r2, [r0], #4
	subs	r3, r3, #1
	bne	1b
	ldr	r2, [r1], #4	@ lr address in stack
	add	r0, r0, #4	@ Advance to lr location (skip sp location)
	str	r2, [r0], #4	@ lr
	str	r4, [r0], #4	@ SPSR
@	Determine address of stack for mode where exception occurred
	sub	r0, r0, #0xC	@ Move to sp address in debug_regs
	mrs	r1, CPSR	@ Save current MODE
@	Switch in Prevoius Mode (where exception occurred)
	mrs	r2, SPSR
	mov	r3, r2
	bic	r3, r3, #0xFFFFFFE0
	cmp	r3, #USR_MODE
	moveq	r3, #SYS_MODE
	bic	r2, r2, #0x1F
	orr	r2, r2, r3
	orr	r2, r2, #(I_BIT | F_BIT)
	msr	CPSR, r2
@	Get sp and return to exception mode
	mov	r3, sp		@ Get sp
	msr	CPSR, r1	@ Restore Exception MODE
@	Save sp to debug_regs
	str	r3, [r0]
@	Return to exception handler
	mov	pc, lr
@--------------------------------------------------------------------------
UNDEF_handler:

	stmdb	sp!, {r0-r12, lr}
	mrs	r0, SPSR
	stmdb	sp!, {r0}
	bl	_dump_prepare
	ldr	a1, =Undef_String
	bl	debug_send_str
	bl	debug_dump_registers
	bl	debug_dump_stack
	ldr	a1, =Stopped_String
	bl	debug_send_str
Undef_Stop:
	b	Undef_Stop

	ldmia	sp!, {r0}
	msr	SPSR, r0
	ldmia	sp!, {r0-r12, pc}^
@--------------------------------------------------------------------------
SWI_handler:
	stmdb	sp!, {r0, r1, lr}
	b	__executable_start
	ldmia	sp!, {r0, r1, pc}^
@-------------------------------------------------------------------------------
PREFETCH_ABORT_handler:
	sub	lr, lr, #4
	stmdb	sp!, {r0-r12, lr}
	mrs	r0, SPSR
	stmdb	sp!, {r0}
	bl	_dump_prepare
	ldr	a1, =PAbt_String
	bl	debug_send_str
	bl	debug_dump_registers
	bl	debug_dump_stack
	ldr	a1, =Stopped_String
	bl	debug_send_str
PAbt_Stop:
	b	PAbt_Stop

	ldmia	sp!, {r0}
	msr	SPSR, r0
	ldmia	sp!, {r0-r12, pc}^
@--------------------------------------------------------------------------
DATA_ABORT_handler:
	sub	lr, lr, #8
	stmdb	sp!, {r0-r12, lr}
	mrs	r0, SPSR
	stmdb	sp!, {r0}
	bl	_dump_prepare
	ldr	a1, =DAbt_String
	bl	debug_send_str
	bl	debug_dump_registers
	bl	debug_dump_stack
	ldr	a1, =Stopped_String
	bl	debug_send_str
DAbt_Stop:
	b	DAbt_Stop

	ldmia	sp!, {r0}
	msr	SPSR, r0
	ldmia	sp!, {r0-r12, pc}^
@--------------------------------------------------------------------------
IRQ_handler:
@ Adjust and save LR_irq to IRQ stack
	sub	lr, lr, #4
	stmdb	sp!, {r0, r1, lr}	@ Save IRQ mode registers
@ Read ISR address from VIC
	ldr	r0, =VIC_VECT_ADDR
	ldr	r1, [r0]
@ Save SPSR in IRQ stack
	mrs	r0, SPSR
	stmdb	sp!, {r0}
@ Enable Interrupts and Switch in SYS Mode
	mrs	r0, CPSR
@ 	bic	r0, r0, #I_BIT
	orr	r0, r0, #SYS_MODE
	msr	CPSR, r0
@ Branch to ISR
	stmdb	sp!, {r2-r12, lr}	@ Save SYS mode registers
	@ Save return address then call user defined handler.
	@ Handler _MUST_ be defined with "naked" attribute
	@ _MUST_ starts with asm("stmdb sp!, {lr}") and
	@ _MUST_ ends with asm("ldmia sp!, {pc}")
	mov	lr, pc
	bx	r1
	ldmia	sp!, {r2-r12, lr}	@ Restore SYS mode registers
@ Disable Interrupt and switch back in IRQ mode
	mrs	r0, CPSR
	bic	r0, r0, #SYS_MODE
	orr	r0, r0, #(I_BIT| IRQ_MODE)
	msr	CPSR, r0
@ Update the priority hardware
	mov	r1, #0			@ Value have no meaning (may be any value)
	ldr	r0, =VIC_VECT_ADDR
	str	r1, [r0]
@ Restore SPSR_irq from IRQ stack
	ldmia	sp!, {r0}
	msr	SPSR, r0
@ Restore adjusted LR_irq from IRQ stack directly in the PC
	ldmia	sp!, {r0, r1, pc}^	@ Restore IRQ mode registers
@--------------------------------------------------------------------------
FIQ_handler:
	sub	lr, lr, #4
	stmdb	sp!, {lr}
@ 	ldr	r0, =0xFFFFF400
@ 	ldr	r1, =~5
@ 	str	r1, [r0, #0x38]
@
@ 	b	0

	ldr	a1, =FIQ_String
	bl	debug_send_str
FIQ_Stop:
	b	FIQ_Stop

	ldmia	sp!, {pc}^
@--------------------------------------------------------------------------
@ RESET handler
_start:
@--------------------------------------------------------------------------
@ Setup Stack for each mode
_stack_config:
	ldr	r0, =TOP_STACK
@  Enter Undefined Instruction Mode and set its Stack Pointer
	msr	cpsr_c, #(UNDEF_MODE | I_BIT | F_BIT)
	mov	sp, r0
	sub	r0, r0, #UNDEF_STACK_SIZE
@  Enter Abort Mode and set its Stack Pointer
	msr	cpsr_c, #(ABT_MODE | I_BIT | F_BIT)
	mov	sp, r0
	sub	r0, r0, #ABT_STACK_SIZE
@  Enter FIQ Mode and set its Stack Pointer
	msr	cpsr_c, #(FIQ_MODE | I_BIT | F_BIT)
	mov	sp, r0
	sub	r0, r0, #FIQ_STACK_SIZE
@  Enter IRQ Mode and set its Stack Pointer
	msr	cpsr_c, #(IRQ_MODE | I_BIT | F_BIT)
	mov	sp, r0
	sub	r0, r0, #IRQ_STACK_SIZE
@  Enter Supervisor Mode and set its Stack Pointer
	msr	cpsr_c, #(SVC_MODE | I_BIT | F_BIT)
	mov	sp, r0
	sub	r0, r0, #SVC_STACK_SIZE
@  Enter User Mode and set its Stack Pointer
	msr	cpsr_c, #USR_MODE
	mov	sp, r0
@  Setup a default Stack Limit (when compiled with "-mapcs-stack-check")
	sub	sl, sp, #USR_STACK_SIZE
@--------------------------------------------------------------------------
@	low_level_init() is a function to initialize
@	critical hardware such as MAM, Memory Map, PLL etc...
@	This is a normal C function and must be an ARM code
@	Prototype is void low_level_init(void)
_low_level_init:
	bl	low_level_init
@--------------------------------------------------------------------------
@ Initialize .ramvectors section
_ramvectors_init:
	ldr	r0, =__ramvectors_lma__
	ldr	r1, = _ramvectors
	ldr	r2, =_eramvectors
_ramvectors_reloc:
	cmp	r1, r2
	ldrlo	r3, [r0], #4
	strlo	r3, [r1], #4
	blo	_ramvectors_reloc
@--------------------------------------------------------------------------
@ Initialize .ramfunc section
_ramfunc_init:
	ldr	r0, =__ramfunc_lma__
	ldr	r1, = _ramfunc
	ldr	r2, =_eramfunc
_ramfunc_reloc:
	cmp	r1, r2
	ldrlo	r3, [r0], #4
	strlo	r3, [r1], #4
	blo	_ramfunc_reloc
@--------------------------------------------------------------------------
@ Initialize .data section
_data_init:
	ldr	r0, =__data_lma__
	ldr	r1, = _data
	ldr	r2, =_edata
_data_reloc:
	cmp	r1, r2
	ldrlo	r3, [r0], #4
	strlo	r3, [r1], #4
	blo	_data_reloc
@--------------------------------------------------------------------------
@ Clear .bss section
_bss_init:
	mov     r0, #0
	ldr     r1, =__bss_start__
	ldr     r2, =__bss_end__
_bss_zero:
	cmp	r1, r2
	strlo	r0, [r1], #4
	blo	_bss_zero
@--------------------------------------------------------------------------
@ Call main
	mov	r0, #0
	mov	r1, #0
	mov	r2, #0
	mov	r3, #0
	mov	r4, #0
	bl	main
@--------------------------------------------------------------------------
@	Return value from main()
@--------------------------------------------------------------------------
	b	__executable_start
@--------------------------------------------------------------------------
@	Error messages
	.section .rodata
Undef_String:
	.asciz	"UNDEFINED INSTRUCTION\r\n"
PAbt_String:
	.asciz	"PREFETCH ABORT\r\n"
DAbt_String:
	.asciz	"DATA ABORT\r\n"
FIQ_String:
	.asciz	"FIQ\r\n"
IRQ_String:
	.asciz	"IRQ\r\n"
Stopped_String:
	.asciz	"STOPPED\r\n"
@--------------------------------------------------------------------------
	.align	4
@--------------------------------------------------------------------------
@	Stacks
	.global _top_stack
	.global _und_stack_size
	.global _abt_stack_size
	.global _fiq_stack_size
	.global _irq_stack_size
	.global _svc_stack_size
	.global _usr_stack_size
_top_stack:		.word	TOP_STACK
_und_stack_size:	.word	UNDEF_STACK_SIZE
_abt_stack_size:	.word	ABT_STACK_SIZE
_fiq_stack_size:	.word	FIQ_STACK_SIZE
_irq_stack_size:	.word	IRQ_STACK_SIZE
_svc_stack_size:	.word	SVC_STACK_SIZE
_usr_stack_size:	.word	USR_STACK_SIZE
@--------------------------------------------------------------------------
	.align	4
@--------------------------------------------------------------------------
