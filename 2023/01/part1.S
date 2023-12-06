   ;LD HL, example
   LD HL, input
   LD DE, bcdlist

   CALL parseinput

   LD BC, linecount
   LD HL, bcdlist ; The list to sum
	LD DE, result ; Where to put the total
   CALL bcdsumlist

	LD A, 0
	LD HL, result
   HALT

; findnumber, store n1 and n2
; findnext store n2
parseinput:
   CALL findnext

   CP 1 ; number
	JR Z, 1f
	CP 2 ; newline - shouldn't happen
	CALL Z, e_badinput
	CP 0xFF
	RET Z

	INC HL
	JR parseinput
1:
   LD A, (HL)
	SUB 0x30 ; ASCII to int
   LD (DE), A
	INC DE
   LD (DE), A
	INC HL

loop2:
   CALL findnext

   CP 1 ; number
	JR Z, hit2

	CP 2 ; newline
	JR Z, next

	CP 0xFF
	RET Z

	INC HL
	JR loop2
hit2:
   LD A, (HL)
	SUB 0x30 ; ASCII to int
   LD (DE), A
   INC HL
	JR loop2
next:
   INC DE
	INC HL

   ; Increment the line count
   PUSH DE
	PUSH HL
	LD DE, one
	LD HL, linecount
	CALL sumwords
	POP HL
	POP DE

	JR parseinput


; HL: pointer to value 
; DE: pointer to value to add
; result is stored in HL
; Clobbers: A, DE and HL
sumwords:
	LD A, (DE)
	ADD A, (HL)
	LD (HL), A

   INC DE
	INC HL
	LD A, (DE)
	ADC A, (HL)
	CALL C, e_overflow
	LD (HL), A

	RET

; HL: Current buffer location
; returns with A set to:
;   0xFF: EOF
;   1: number
;   2: newline
findnext:
   LD A, (HL)
   ; Input is null terminated
   CP 0
   JR NZ, 1f
   LD A, 0xFF
	RET

1:
	CP 0x0A ; newline
   JR NZ, 1f
   LD A, 2
	RET

1:
   CALL isnumeric
   CP 1
   JR NZ, 1f
	RET

1:
   INC HL
   JR findnext

; Tests whether the value in A is an ASCII 0-9
; Returns result in A: 1 if so, 0 if not
; No other registers modified
isnumeric:
	ADD A, 198 ; ASCII '9'
	JR C, 1f
	ADD A, 10
	JR NC, 1f
	LD A, 1
	RET
1:
   LD A, 0
   RET

; DE: pointer to result
; HL: pointer to list
; BC: pointer to number of elements
bcdsumlist:
	; Load 2-digit big-endian BCD value from HL into A
   CALL loadbcd
	PUSH HL ; Save list position
	PUSH BC

	PUSH DE ; emulate LD HL, DE
	POP HL
	CALL add8b32

	PUSH BC ; Emulate LD HL, BC
	POP HL

	PUSH HL
	LD A, 1
	CALL sub8b16
	POP HL

	LD B, 2
	CALL iszero
	JR Z, 1f ; Return once no elements left

	POP BC
	POP HL ; Restore list position
	INC HL ; Advance to next entry
	INC HL ; Advance to next entry

   JR bcdsumlist
1:
   POP BC
	POP HL
   RET

; HL: pointer to 2-digit BCD value (big-endian)
; Returns value in A
loadbcd:
   PUSH BC
   PUSH HL

   LD A, (HL)
	CALL mul10
	INC HL
	ADD A, (HL)
	CALL C, e_overflow

	POP HL
	POP BC
   RET

; Multiplies the value in A by 10
; Trashes: B
mul10:
	LD B, A
   SLA A
	SLA A ; x4
	ADD A, B
	SLA A
	RET

; HL: pointer to value
; A: number to add
add8b32:
   ADD A, (HL)
	LD (HL), A
	RET NC
	INC HL
	LD A, 1
	ADD A, (HL)
	LD (HL), A
	RET NC
	INC HL
	LD A, 1
	ADD A, (HL)
	LD (HL), A
	RET NC
	INC HL
	LD A, 1
	ADD A, (HL)
	LD (HL), A
	CALL C, e_overflow
	RET

; HL: pointer to value
; A: number to subtract
; Clobbers: B, A, HL
sub8b16:
   PUSH HL
	PUSH BC
   LD B, A
	LD A, (HL)
	SBC A, B
	LD (HL), A
	JR NC, 1f
	INC HL
	LD B, 0
	LD A, (HL)
	SBC A, B
	LD (HL), A
	CALL C, e_underflow
1:
   POP BC
   POP HL
	RET

; B: byte count (0 means 256)
; HL: pointer to value
; clobbers: A, B, HL
; On return, Z is set if all bytes are 0
iszero:
   PUSH HL
	PUSH BC
1:
   LD A, (HL)
	CP 0
	JR NZ, 1f
	DEC B
	JR Z, 1f
	INC HL
	JR 1b
1:
   POP BC
	POP HL
	RET

e_overflow:
   PUSH HL
   PUSH BC
   LD HL, errstr_overflow
	LD B, 254
	HALT

e_underflow:
   PUSH HL
   LD HL, errstr_underflow
	LD B, 254
	HALT

e_badinput:
   LD HL, errstr_badinput
	LD B, 253
	HALT

example:
.incbin "example-input"
   DB 0
input:
.incbin "input"
   DB 0
one:
   DW 0x1
linecount:
   DW 0
result:
   DB 0x0, 0x0, 0x0, 0x0
errstr_overflow:
   DB "Arithmetic overflow",0
errstr_underflow:
   DB "Arithmetic underflow",0
errstr_badinput:
   DB "Bad input",0
bcdlist:
   DS 2000
