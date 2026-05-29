# Programming Notes

## SAM D21 Physical Memory Map

### Internal Flash

Start: `0x00000000`, Size: `0x00040000` (256 kiB)

Erase per Row; Write per Page

Number of Pages: 4096, Page Size: 64 bytes, Pages per Row: 4

#### Bootloader (SAM-BA)

Start: `0x00000000`, Size: `0x00002000` (8kiB)

### User Row (in NVM)

At `0x00804000`.

First two 32 bit words are used for calibration data. For the rest see SAM-D21 Family Datasheet.

- `BOOTPROT` - Bits `[2:0]`
- `EEPROM`   - Bits `[6:4]`

### Internal SRAM

Start: `0x20000000`, Size: `0x00008000` (32 kiB)

### Peripheral Regions

- Bridge A
  - Start: `0x40000000`, Size `0x00010000` (64 kiB)
- Bridge B
  - Start: `0x41000000`, Size `0x00010000` (64 kiB)
- Bridge C
  - Start: `0x42000000`, Size `0x00010000` (64 kiB)

## Cortex-M0+

### Vector Table

Fixed at `0x00000000`.

`VTOR` (Vector Table Offset) at `0xE000ED08`: Bits `[31:7]`

The least-significant bit of each enabled vector must be 1, indicating the exception handler is written in Thumb code.

| Exception types       | Address      |
| --------------------- | ------------ |
| Initial Stack Pointer | `0x00000000` |
| Reset                 | `0x00000004` |
| NMI                   | `0x00000008` |
| Hard Fault            | `0x0000000C` |
| SVCall                | `0x0000002C` |
| PendSv                | `0x00000038` |
| SysTick               | `0x0000003C` |
| IRQs                  | `0x00000040` |
