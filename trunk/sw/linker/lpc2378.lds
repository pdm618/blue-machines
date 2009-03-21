/* Linker script, for LPC23xx */

OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
__DYNAMIC = 0;

MEMORY
{
	FLASH		(rx)	:	ORIGIN = 0x00000000, LENGTH = 0x00080000
	RAMVECTORS	(rwx)	:	ORIGIN = 0x40000000, LENGTH = 0x00000040
	RAM		(rwx)	:	ORIGIN = 0x40000040, LENGTH = 0x00007FC0
	EXT1		(rwx)	:	ORIGIN = 0x80000000, LENGTH = 0x00010000
	EXT2		(rwx)	:	ORIGIN = 0x81000000, LENGTH = 0x00010000
}

/* Section Definitions */

SECTIONS
{
	_vectors = 0x00000000;
	_evectors = 0x00000040;
	_stack = 0x40008000;
	PROVIDE (__executable_start = 0x00000000);

	/* First section is .vectors which is used for ARM Exception vectors in Flash */
	. = 0x00000000;

	/* Second section is .text which is used for code */
	.text :
	{
		/* ARM Exception vectors */
		. = _vectors;
		KEEP (*(.vectors*))
		. = _evectors;
		KEEP (*crt0.o (.text))		/* Startup code */
		*(.text*)			/* remaining code */
		*(.glue_7t) *(.glue_7)
	} >FLASH
	. = ALIGN(4);

	/* .rodata section which is used for read-only data (constants) */

	.rodata :
	{
		*(.rodata*)
	} >FLASH

	. = ALIGN(4);

	_etext = . ;
	PROVIDE (etext = .);

	/* Exception Vectors in RAM. Used after REMAP */
	__ramvectors_lma__ = _etext;
	.ramvectors : AT(__ramvectors_lma__)
	{
		_ramvectors = .;
		*(.ramvectors*)
		. = _ramvectors + LENGTH(RAMVECTORS);
		_eramvectors = .;
		PROVIDE(eramvectors = .);
	}>RAMVECTORS

	__eramvectors_lma__ = __ramvectors_lma__ + _eramvectors - _ramvectors;
	PROVIDE(eramvectors_lma = __eramvectors_lma__);

	/* .ramfunc section which is used for function running in RAM */

	__ramfunc_lma__ = __eramvectors_lma__;
	.ramfunc : AT(__ramfunc_lma__)
	{
		_ramfunc = .;
		*(.ramfunc*)
		_eramfunc = . ;
		PROVIDE (eramfunc = .);
	} >RAM
	. = ALIGN(4);
	__eramfunc_lma__ = __ramfunc_lma__ + _eramfunc - _ramfunc;
	PROVIDE (eramfunc_lma = __eramfunc_lma__);

	/* .data section which is used for initialized data */

	__data_lma__ = __eramfunc_lma__;

	.data : AT (__data_lma__)
	{
		_data = . ;
		*(.data*)
	/*	SORT(CONSTRUCTORS)*/
		_edata = . ;
	} >RAM
	. = ALIGN(4);

	__edata_lma__ = __data_lma__ + _edata - _data;
	PROVIDE (edata_lma = __edata_lma__);

	/* .bss section which is used for uninitialized data */

	.bss :
	{
		__bss_start = . ;
		__bss_start__ = . ;
		*(.bss*)
		*(COMMON)
	} >RAM

	. = ALIGN(4);

	__bss_end = . ;
	__bss_end__ = . ;

	_end = .;
	PROVIDE (end = .);

	/* Stabs debugging sections.  */
	.stab          0 : { *(.stab) }
	.stabstr       0 : { *(.stabstr) }
	.stab.excl     0 : { *(.stab.excl) }
	.stab.exclstr  0 : { *(.stab.exclstr) }
	.stab.index    0 : { *(.stab.index) }
	.stab.indexstr 0 : { *(.stab.indexstr) }
	.comment       0 : { *(.comment) }
	/* DWARF debug sections.
	Symbols in the DWARF debugging sections are relative to the beginning
	of the section so we begin them at 0.  */
	/* DWARF 1 */
	.debug          0 : { *(.debug) }
	.line           0 : { *(.line) }
	/* GNU DWARF 1 extensions */
	.debug_srcinfo  0 : { *(.debug_srcinfo) }
	.debug_sfnames  0 : { *(.debug_sfnames) }
	/* DWARF 1.1 and DWARF 2 */
	.debug_aranges  0 : { *(.debug_aranges) }
	.debug_pubnames 0 : { *(.debug_pubnames) }
	/* DWARF 2 */
	.debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
	.debug_abbrev   0 : { *(.debug_abbrev) }
	.debug_line     0 : { *(.debug_line) }
	.debug_frame    0 : { *(.debug_frame) }
	.debug_str      0 : { *(.debug_str) }
	.debug_loc      0 : { *(.debug_loc) }
	.debug_macinfo  0 : { *(.debug_macinfo) }
	/* SGI/MIPS DWARF 2 extensions */
	.debug_weaknames 0 : { *(.debug_weaknames) }
	.debug_funcnames 0 : { *(.debug_funcnames) }
	.debug_typenames 0 : { *(.debug_typenames) }
	.debug_varnames  0 : { *(.debug_varnames) }
}
