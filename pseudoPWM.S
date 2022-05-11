; Stack registers
.equ SPH , 0x3E
.equ SPL , 0x3D
.equ RAMEND , 0x0AFF
.equ SREG , 0x3F

.equ DIDR2, 0x7D

; Timer/Counter0 registers
.equ DDRD , 0x0A
.equ DDRB , 0x04
.equ PORTD , 0x0B
.equ PORTB , 0x05
.equ DDRC , 0x07
.equ PORTC , 0x08
.equ TCCR0A , 0x24
.equ TCCR0B , 0x25
.equ OCR0A , 0x27
.equ OCR0B, 0x28
.equ TIMSK0, 0x6E

.equ D6 , 6

; TCCR0A bits
.equ COM0A1 , 7
.equ COM0A0 , 6
.equ COM0B1 , 5
.equ COM0B0 , 4
.equ WGM01 , 1
.equ WGM00 , 0

; TCCR0B bits
.equ WGM02 , 3
.equ CS02 , 2
.equ CS01 , 1
.equ CS00 , 0

.org 0x0000
    rjmp reset; Power on interrupt 
.org 0x58
    rjmp OCR0B_int
.org 0x5c
   rjmp TCNT0_ovflow_int 
.org 0xAC; The vector table would end here if all interrupts are used

reset:
    ldi r16 , hi8(RAMEND)
    out SPH , r16
    ldi r16 , lo8(RAMEND)
    out SPL , r16
    rcall pwmsetup
    ;rcall adcsetup
    ;rcall analogoutsetup
    sei

main:
  rjmp main

pwmsetup:
; Setup the 8-bit Timer/Counter 0 to operate in Fast PWM mode
  ldi r16, 0b00000101
  sts TIMSK0, r16
  ldi r16, (0<<COM0B1)|(0<<COM0B0)|(0<<COM0A1)|(0<<COM0A0)|(1<<WGM01)|(1<<WGM00)
  out TCCR0A ,r16
  ldi r16 , (0<<WGM02)|(1<<CS02)|(0<<CS01)|(1<<CS00)
  out TCCR0B , r16
  ldi r16, 0x20 ; width of the ping
  out OCR0B, r16
ret

OCR0B_int:
  ; For these two interrupts, I could afford to sacrifice the memory registers 
  ; exclusively for saving and restoring SREG. They must not be used elsewhere 
  ; in the code. If registers cannot be exclusive, they must be pushed to the stack 
  ; before anything else happens in the ISR.
  in r25, SREG ; save SREG
  ldi r17, 0b00000000
  ldi r19, 0b01000000
  out DDRD, r19
  out PORTD, r17
  out SREG , r25 ; restore SREG
reti

TCNT0_ovflow_int:
  in r23, SREG ; save SREG
  ldi r18, 0b01000000
  out DDRD, r18
  out PORTD, r18         
  out SREG , r23 ; restore SREG
reti
