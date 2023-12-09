start:
	;LD HL, example1
	;LD HL, example2
   LD HL, input
	PUSH HL
1:
	PUSH HL
   LD DE, w_one
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_two
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_three
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_four
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_five
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_six
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_seven
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_eight
	CALL do_numberify
   POP HL
	PUSH HL
   LD DE, w_nine
	CALL do_numberify
	POP HL
	INC HL
	LD A, (HL)
	CP 0
	JR NZ, 1b ; If we're not at the end of the input, keep going

   POP HL
	LD DE, bcdlist
	CALL parseinput

	LD BC, linecount
	LD HL, bcdlist ; The list to sum
	LD DE, result ; Where to put the total
	CALL bcdsumlist

	LD A, 0
	LD HL, result
	HALT

; HL: pointer to input
; DE: pointer to search string struct
do_numberify:
	PUSH HL
	PUSH DE
	POP HL
	LD A, (HL)
	INC HL
	INC HL
	PUSH HL
	POP DE
	POP HL
	CALL numberify
	RET

; HL: pointer to input
; DE: pointer to search string
; A: value to replace 1st character with
; Replaces e.g. 'five' with '5ive', inspired by https://en.wikipedia.org/wiki/Five_(group)
numberify:
   LD (numberify_tmp), A
   PUSH HL
	PUSH DE
	POP HL

	CALL strlen
	PUSH HL
	POP BC
	POP HL

; HL: pointer to input
; DE: pointer to search string
; BC: length of string pointed to by DE
; A: value to replace 1st character with
1:
	PUSH BC
	PUSH DE
	PUSH HL
	CALL strncmp
	POP HL
	POP DE
	POP BC
	RET NZ ; No match
	LD A, (numberify_tmp)
   LD (HL), A
	RET
numberify_tmp: DB 0

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

; HL: pointer to string
; on exit, HL contains string length in bytes
strlen:
   LD BC, 0x0
   LD A, 0
	CPIR
   LD HL, 0xffff
	SBC HL, BC
	RET

; BC: byte count
; HL: s1
; DE: s2
; Z set if equal, unset if not
strncmp:
	LD A, (DE)
   CPI
	RET NZ ; found a difference
	RET PO ; byte count reached
	INC DE ; onto the next byte
	JR strncmp

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

example1:
.incbin "example-input1"
	DB 0
example2:
.incbin "example-input2"
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
; ASCII digit, word length, word (null terminated)
w_one: DB "1", 3, "one", 0x0
w_two: DB "2", 3, "two", 0x0
w_three: DB "3", 5, "three", 0x0
w_four: DB "4", 4, "four", 0x0
w_five: DB "5", 4, "five", 0x0
w_six: DB "6", 3, "six", 0x0
w_seven: DB "7", 5, "seven", 0x0
w_eight: DB "8", 5, "eight", 0x0
w_nine: DB "9", 4, "nine", 0x0
errstr_overflow:
	DB "Arithmetic overflow",0
errstr_underflow:
	DB "Arithmetic underflow",0
errstr_badinput:
	DB "Bad input",0
bcdlist:
	DS 2000
