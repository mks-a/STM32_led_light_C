OUTPUT_ARCH(arm)

_estack = 0x20005000;	/* End of SRAM */

_min_heap_size = 0; /* 0x280;		 should be 5kb */
_min_stack_size = 0; /* 0x780;	 	should be 15kb */

MEMORY
{
	/* FLASH RAM Section and permissions in brackets. R - read; X - execute */
	FLASH (RX) : ORIGIN = 0x08000000, LENGTH = 0x20000	/* 128kb */
	/* W - write, A - allocate, I - initialize?, L - load */ 
	SRAM (WAIL) : ORIGIN = 0x20000000, LENGTH = 0x5000 /* 20kb */
}

/* Entry point */
ENTRY(main)

SECTIONS
{
	/* reset vector */
	.reset : 
	{
		*startup.o (.text)		/* Startup code (ARM vectors and reset handler) */
		. = ALIGN(4);
	} > FLASH
  
	.text :	/*section type in binary file*/ 
	{
		. = ALIGN(4);
		*(.text);	/* section type in *.s file */ 
		*(.code);	/* in case we have .code sections in *.s file it should also go to FLASH RAM */
		. = ALIGN(4);
		_etext = .;	/* define global symbol at the end of .text section */
	} > FLASH		/* goes to FLASH RAM */
	
	. = ALIGN(4);
	.bss : /* bss section in binary file */
	{
		/* This is used by the startup in order to initialize the .bss secion */
		_sbss = .;		/* define symbol at the beginning of .bss section */
		__bss_start__ = _sbss;
		*(.bss);		/* .bss section in SRAM */
		*(.bss*)
		. = ALIGN(4);
		_ebss = .;		/* define a global synbol at the end of .bss section */
		__bss_end__ = _ebss;
	} > SRAM
	
	/* used by the startup to initialize data */
	_sidata = LOADADDR(.data);
	
	.data :	/* Initialized data section */
	{
		. = ALIGN(4);
		_sdata = .;		/* define global symbol at the beginning of .data section */
		*(.data)
		*(.data*)
		. = ALIGN(4);
		_edata = .;		/* define global symbol at the end of .data section */
	} > FLASH
	
	/* User_heap_stack section, used to check that there is enough RAM left */
	._user_heap_stack :
	{
		. = ALIGN(4);
		PROVIDE ( end = . );
		PROVIDE ( _end = . );
		. = . + _min_heap_size;
		. = . + _min_stack_size;
		. = ALIGN(4);
	} > SRAM
  
	/* Remove information from the standard libraries */
	/DISCARD/ :
    {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }
}