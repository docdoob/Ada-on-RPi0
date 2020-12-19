/****************************************************************************
 *                                                                          *
 *                         GNAT COMPILER COMPONENTS                         *
 *                                                                          *
 *                                  A R M                                   *
 *                                                                          *
 *                            Linker Script File                            *
 *                                                                          *
 *      Copyright (C) 1999-2002 Universidad Politecnica de Madrid           *
 *             Copyright (C) 2003-2006 The European Space Agency            *
 *                   Copyright (C) 2003-2013 AdaCore                        *
 *                                                                          *
 * GNAT is free software;  you can  redistribute it  and/or modify it under *
 * terms of the  GNU General Public License as published  by the Free Soft- *
 * ware  Foundation;  either version 2,  or (at your option) any later ver- *
 * sion.  GNAT is distributed in the hope that it will be useful, but WITH- *
 * OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY *
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License *
 * for  more details.  You should have  received  a copy of the GNU General *
 * Public License  distributed with GNAT;  see file COPYING.  If not, write *
 * to  the  Free Software Foundation,  51  Franklin  Street,  Fifth  Floor, *
 * Boston, MA 02110-1301, USA.                                              *
 *                                                                          *
 * As a  special  exception,  if you  link  this file  with other  files to *
 * produce an executable,  this file does not by itself cause the resulting *
 * executable to be covered by the GNU General Public License. This except- *
 * ion does not  however invalidate  any other reasons  why the  executable *
 * file might be covered by the  GNU Public License.                        *
 *                                                                          *
 * GNARL was developed by the GNARL team at Florida State University.       *
 * Extensive contributions were provided by Ada Core Technologies, Inc.     *
 * The  executive  was developed  by the  Real-Time  Systems  Group  at the *
 * Technical University of Madrid.                                          *
 *                                                                          *
 ****************************************************************************/

/* This is a ARM specific version of this file */

/* This script replaces ld's default linker script, providing the
   appropriate memory map and output format. */

_DEFAULT_STACK_SIZE = (20 * 1024);

_SVC_STACK_SIZE   =  28672;
_UNDEF_STACK_SIZE =  256;
_ABORT_STACK_SIZE =  256;
_IRQ_STACK_SIZE   = 3072;
_FIQ_STACK_SIZE   =  256;
_MON_STACK_SIZE   =  256;

ENTRY(__start_ram);

MEMORY
{
  SRAM (rwx) : ORIGIN = 0x8000, LENGTH = 32M
}

REGION_ALIAS("REGION_CODE", SRAM)
REGION_ALIAS("REGION_DATA", SRAM)

/*
 * The memory map looks like this:
 * +--------------------------------+ <- low memory
 * | .traps                         |
 * +--------------------------------+
 * |                                |
 * |       __interrupt_stack_end    |
 * |    interrupt stack space       |
 * |       __interrupt_stack_start  |
 * |                                |
 * |       __stack_end              |
 * |    stack space                 |
 * |       __stack_start            | top of stack
 * |       _end                     | 
 * |                                |
 * +--------------------------------+
 * | .data                          | initialized data goes here
 * |                                |
 * +--------------------------------+
 * | .bss                           |
 * |       __bss_start              | start of bss, cleared by start-ram
 * |    uninitialized data          |
 * |       __bss_end                |
 * |                                |
 * +--------------------------------+
 * |    heap space                  |
 * |                                |
 * +--------------------------------+
 * |  remote monitor                |
 * +--------------------------------+ <- high memory
 */

SECTIONS
{
  .text :
  {
    KEEP (*(.traps))
    *(.text .text.* .gnu.linkonce.t*)
  } > REGION_CODE

  .rodata :
  {
    *(.rodata .rodata.* .gnu.linkonce.r*)
  } > REGION_CODE

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } > REGION_CODE
  /* .ARM.exidx is 4-bytes aligned, so __exidx_start needs to be
     aligned too. Note that assigning the location counter also makes
     ld attach the following symbols to the next section (instead of the
     previous section which is the default), so will properly
     consider the location counter of .ARM.exidx for __exidx_start and
      __exidx_end and not the previous section's one. */
  . = ALIGN(0x4);
  PROVIDE_HIDDEN (__exidx_start = .);
  .ARM.exidx   : { *(.ARM.exidx* .gnu.linkonce.armexidx.*) } > REGION_CODE
  PROVIDE_HIDDEN (__exidx_end = .);

  .data :
  {
    __data_start = .;
    *(.data .data.* .gnu.linkonce.d*)
    . = ALIGN(0x4);
    __data_end = .;
  } > REGION_DATA
  __data_words = (__data_end - __data_start) >> 2;

  .bss (NOLOAD): {
   . = ALIGN(0x8);
   __bss_start = .;

   *(.bss .bss.*)
   *(COMMON)

   /* Align the stack to 64 bits */

   . = ALIGN(0x8);
   __bss_end = .;

 
   __heap_start = .;
   __heap_end = ORIGIN(REGION_DATA) + LENGTH(REGION_DATA);
  } > REGION_DATA

   __bss_words = (__bss_end - __bss_start) >> 2;

}

