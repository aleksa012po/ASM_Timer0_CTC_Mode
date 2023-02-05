;
; Timer0CTCMode.asm
;
; Created: 24/06/2022 23:58:45
; Author : Aleksandar Bogdanovic
;

.include "m328pdef.inc"
.org 0x00


timer0:
    LDI   R16, 0b00010000	; toggle PB4 (D12) / Load Immediate (Loads an 8-bit constant directly to register 16 to 31)
    LDI   R17, 0b00000000	; R17=0 / Load Immediate (Loads an 8-bit constant directly to register 16 to 31)
    ;--------------------------------------------
    SBI   DDRB, 4			; set PB4 for output / Set Bit in I/O Register (Sets a specified bit in an I/O Register. This instruction operates on the lower 32 I/O Registers – addresses 0-31)
    OUT   PORTB, R17		; PB4 = 0 / Store Register to I/O Location (Store Register to I/O Location{(Ports, Timers, Configuration Registers, etc.})
    ;--------------------------------------------
    LDI   R18, 61			; set loop counter / Load Immediate (Loads an 8-bit constant directly to register 16 to 31)
L1: RCALL timer0_delay		; apply delay via timer0 / – Relative Call to Subroutine (Relative call to an address within PC-2K+1 and PC+2K {words}. The return address {the instruction after the RCALL} is stored onto the Stack)
    DEC   R18				; decrement timer
    BRNE  L1				; go back and repeat / Branch if Not Equal (Conditional relative branch)
    ;--------------------------------------------
    EOR   R17, R16			; R17 = R17 XOR R16 / Exclusive OR (Performs the logical EOR between the contents of register Rd and register Rr and places the result in the destination register Rd.)
    OUT   PORTB, R17		; toggle PB4 / Store Register to I/O Location (Store Register to I/O Location{(Ports, Timers, Configuration Registers, etc.})
    LDI   R18, 61			; re-set loop counter / Load Immediate (Loads an 8-bit constant directly to register 16 to 31)
    RJMP  L1				; go back & repeat toggle / Relative Jump (Relative jump to an address within PC-2K+1 and PC+2K {words})
;===============================================================
timer0_delay:				; 0.64 ms delay via timer0
    ;---------------------------------------------------------
    CLR   R20				; clear register R20 / Clear Register (Clears a register. This instruction performs an Exclusive OR between a register and itself. This will clear all bits in the register)
    OUT   TCNT0, R20		; initialize timer0 with count=0 / Store Register to I/O Location (Store Register to I/O Location{(Ports, Timers, Configuration Registers, etc.})
    LDI   R20, 9			; R20 = 9 / Load Immediate (Loads an 8-bit constant directly to register 16 to 31)
    OUT   OCR0A, R20		; OCR0 = 9
    LDI   R20, 0b00001101	; R20 = 0b00001101 / Load Immediate (Loads an 8-bit constant directly to register 16 to 31)
    OUT   TCCR0B, R20		; timer0: CTC mode, prescaler 1024
    ;---------------------------------------------------------
L2: IN    R20, TIFR0		; get TIFR0 byte & check / Load an I/O Location to Register (Loads data from the I/O Space {Ports, Timers, Configuration Registers, etc.} into register Rd in the Register File)
    SBRS  R20, OCF0A		; if OCF0=1, skip next instruction / Skip if Bit in Register is Set (This instruction tests a single bit in a register and skips the next instruction if the bit is set)
    RJMP  L2				; else, loop back & check TOV0 flag / Relative Jump (Relative jump to an address within PC-2K+1 and PC+2K {words})
    ;---------------------------------------------------------
    CLR   R20				; clear register R20 / Clear Register (Clears a register. This instruction performs an Exclusive OR between a register and itself. This will clear all bits in the register)
    OUT   TCCR0B, R20		; stop timer0 / Store Register to I/O Location
    ;---------------------------------------------------------
    LDI   R20, (1<<OCF0A)	; Load Immediate (Loads an 8-bit constant directly to register 16 to 31)  OCF0
    OUT   TIFR0, R20		; clear OCF0 flag / Store Register to I/O Location
    RET