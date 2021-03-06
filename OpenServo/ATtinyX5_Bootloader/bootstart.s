/*
    Copyright (c) 2006 Michael P. Thompson <mpthompson@gmail.com>

    Permission is hereby granted, free of charge, to any person 
    obtaining a copy of this software and associated documentation 
    files (the "Software"), to deal in the Software without 
    restriction, including without limitation the rights to use, copy, 
    modify, merge, publish, distribute, sublicense, and/or sell copies 
    of the Software, and to permit persons to whom the Software is 
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be 
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
    DEALINGS IN THE SOFTWARE.

    $Id$
*/

/* Don't build if BOOTSTRAPPER defined. */
#ifndef BOOTSTRAPPER

#include <avr/io.h>

	.text

	/* Define this code section as the bootloader. */
	.section    .bootloader,"ax",@progbits

	.global bootstart
bootstart:

	.global __init
__init:

	.weak   __stack
	.set    __stack, RAMEND

	/* Make sure global interrupts are disabled. */
	cli

	/* Clear the status register. */
	clr r1
	out _SFR_IO_ADDR(SREG), r1

	/* Clear out MCUSR. */
	out _SFR_IO_ADDR(MCUSR), r1 

#if !defined(__AVR_ATtiny84__)
//#define WDTCR WDTSR
//#endif
	/* Disable watchdog. */
	in r16, _SFR_IO_ADDR(WDTCR)
	ori r16, (1<<WDCE)|(1<<WDE)
	out _SFR_IO_ADDR(WDTCR), r16
	clr r16
	out _SFR_IO_ADDR(WDTCR), r16
#endif	
	/* Configure stack. */
	ldi r28,lo8(__stack)
	ldi r29,hi8(__stack)
	out _SFR_IO_ADDR(SPH),r29
	out _SFR_IO_ADDR(SPL),r28

	/* Call the boot loader function. */
	rcall bootloader

	/* Jump to boot vector address. */
	rjmp    __boot_vector

	.size   bootstart,.-bootstart

#endif /* !BOOTSTRAPPER */
