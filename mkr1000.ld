ENTRY(Reset_Handler)

MEMORY {
  FLASH (rx)  : ORIGIN = /* NVM Start */ 0x00000000 + /* Bootloader Size */ 0x00002000 , LENGTH = /* Total Main NVM */ 0x00040000 - /* Bootloader Size */ 0x00002000 
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
} 

_estack = ORIGIN(RAM) + LENGTH(RAM); /* top of stack, used for first entry in the vector table*/

SECTIONS 
{
  .isr_vector : 
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } > FLASH

  .text : 
  {
    . = ALIGN(4);
    *(.text*)
    *(.rodata*)
    . = ALIGN(4);
    _etext = .;     /* end of of code */
  } > FLASH

  .data : AT(_etext) /* VMA in RAM and LMA just after .text */
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } > RAM

  .bss : 
  {
    . = ALIGN(4);
    _sbss = .;
    *(.bss*)
    *(COMMON) /* uninitialized sections without explicit sections */
    . = ALIGN(4);
    _ebss = .;
  } > RAM

  .user_heap_stack : 
  {
    . = ALIGN(4);
    . = . + 0x400; /* at least 1 kiB of stack & heap */
  } > RAM
}
