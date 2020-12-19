/****************************************************************************
 *                                                                          *
 *               GNU ADA RUN-TIME LIBRARY (GNARL) COMPONENTS                *
 *                                                                          *
 *                                  C R T 0                                 *
 *                                                                          *
 *                               Assembly File                              *
 *                                                                          *
 *                          Copyright (C) 2013 AdaCore                      *
 *                                                                          *
 * GNAT is free software;  you can  redistribute it  and/or modify it under *
 * terms of the  GNU General Public License as published  by the Free Soft- *
 * ware  Foundation;  either version 2,  or (at your option) any later ver- *
 * sion.  GNAT is distributed in the hope that it will be useful, but WITH- *
 * OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY *
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License *
 * for  more details.  You should have  received  a copy of the GNU General *
 * Public License  distributed with GNAT;  see file COPYING.  If not, write *
 * to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, *
 * MA 02111-1307, USA.                                                      *
 *                                                                          *
 * As a  special  exception,  if you  link  this file  with other  files to *
 * produce an executable,  this file does not by itself cause the resulting *
 * executable to be covered by the GNU General Public License. This except- *
 * ion does not  however invalidate  any other reasons  why the  executable *
 * file might be covered by the  GNU Public License.                        *
 *                                                                          *
 ****************************************************************************/

/* This file is specific to the  Raspberry PI 0 board.  */
/* Ref: ARM DDI 0100E */
/* This file contains the trap table and start up code for the Zero Footprint */
/* Profile and the multitasking executive in the Ravenscar Profiles */
/* implemented for bareboard targets. */

/* The steps are:  Copy the trap vectors to address 0;  disable interrupts; */
/* set the stack pointers; clear BSS;  go to "main" */

/* Startup code */
	.global __start_ram

	.section .traps,"ax"
	/* The following provide default definitions for trap vectors that
	loop back to the trap address, so the system will stop in a safe
	state. The Ravenscar runtimes now can install their handlers by simply
	exporting the relevant symbols. */

	.weak   __reset                 /* reset - supervisor mode  */
	.weak	__gnat_undef_trap	/* Undefined instruction trap */
	.weak	__gnat_svc_trap		/* Supervisor call trap or software interrupt */
	.weak	__gnat_pabt_trap	/* prefetch abort trap	*/
        .weak	__gnat_dabt_trap	/* data abort trap */
        .weak	__gnat_irq_trap		/* Interrupt */
        .weak	__gnat_fiq_trap		/* Fast interrupt */

	.p2align 5

		.type	__start_ram, %function
__start_ram:
__traps:
/* will be copied to address 0 */
__reset:                ldr pc, reset_handler   /* program start, both initially and after reset */
__gnat_undef_trap:	ldr pc,undefined_handler
__gnat_svc_trap:	ldr pc,swi_handler
__gnat_pabt_trap:	ldr pc,prefetch_handler
__gnat_dabt_trap:	ldr pc,data_handler
			ldr pc,unused_handler
                        ldr pc,irq_handler
__gnat_fiq_trap:	ldr pc,fiq_handler

reset_handler:       .word reset
undefined_handler:   .word hang
swi_handler:         .word hang
prefetch_handler:    .word hang
data_handler:        .word hang
unused_handler:      .word hang
irq_handler:         .word __gnat_irq_trap
fiq_handler:         .word hang

reset:
hang:
__gnat_irq_trap:           /* will be overridden by compiler for interrupt handling  */
         ldr r0, =__start_ram      /* #0x8000  */
         mov r1, #0x0000
         ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}  /* 8 words of trap table  */
         stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
         ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}  /* 8 addresses  */
         stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}

	/* rpi0 starts in SVC mode, so no need to switch to SVC mode.  */
	/* disable all interrupts for the time being  */
	cpsid   if

		/* Set stacks.  */
		/* set up the stack for IRQ  */
 	cps	#18  /* 10010 */
	mov	sp, #0x1000
	
        	/* set up the stack for SVC  */
        cps	#19  /* 10011 */
	mov	sp, #0x8000  /* and IRQ stack at 0x1000;  both descending  */
  	
	sub     sp, sp, #0x4  /* don't use 8000 itself */
	
/*  Removed setting up of:  
   VFP VBAR TLBs I-Cache Branch Predictor SMP MMU from RPi2 version*/

	
	/* Clear .bss */
	.global __bss_start, __bss_words
	ldr     r0, =zeros8
        ldmia   r0,{r3,r4,r5,r6,r7,r8,r9,r10}
	ldr	r0, bsss
        ldr	r1, bssw
	mov	r2,#0
0:	cmp	r1,#0
	beq	2f         /* none left? */
	cmp     r1, #8
	blt     1f         /* no more 8's? */
	stmia r0!,{r3,r4,r5,r6,r7,r8,r9,r10}
        subs	r1,r1,#8
	b       0b
1:	str	r2,[r0],#4    /* singles */
	subs	r1,r1,#1
	bne	1b             /* not finished? */
2:

	/* Call the main routine */
	bl	main
_inf_loop:
        b       _inf_loop
    
zeros8:  .word 0,0,0,0,0,0,0,0   /* for zeroising blocks in BSS */ 
bsss:    .word __bss_start
bssw:    .word __bss_words
	.size	__start_ram, . - __start_ram

/* dummy function for simplicity  */
	.global __gnat_last_chance_handler
__gnat_last_chance_handler:
    ldr  r0, last_chance_handler
    add  r0, r0, #1             /* record number of occurrences */
    str  r0, last_chance_handler
   # Return from the function
    mov     pc, lr
last_chance_handler: .word 0  /* no. of occurrences  */

/* stack sizes are defined in RAM.ld;  here they are stored in memory so that
* applications can check that stacks remain within limits  */
abt_stack_size:
	.word	_ABORT_STACK_SIZE
undef_stack_size:
	.word	_UNDEF_STACK_SIZE
svc_stack_size:
	.word	_SVC_STACK_SIZE
fiq_stack_size:
	.word	_FIQ_STACK_SIZE
irq_stack_size:
	.word	_IRQ_STACK_SIZE


/* In the RPi2 version there is an include:
*	#include	"memmap.S"
* this file contains 4096 .long directives only.
* The first 1040 lines set up a different value each;  the remainder set up 0's */
