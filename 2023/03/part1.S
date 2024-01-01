		  ;LD HL, example1
		  LD HL, input

		  PUSH HL
		  CALL calcdimensions
		  POP HL

		  PUSH HL
		  LD DE, data
		  CALL normalise
		  LD HL, data
		  HALT
		  LD A, (cols)
		  DEC A ; Newlines have been removed now
		  LD (cols), A
		  POP HL

		  PUSH HL
		  LD DE, parts
		  CALL indexparts
		  POP HL

		  HALT

; Find out the dimensions of the input
calcdimensions:
		  PUSH HL
		  ; Find out how wide the input is, in bytes
		  LD BC, 0x00ff
		  LD A, 0x0a
		  CPIR
		  LD A, 0xff
		  SUB C
		  LD (cols), A

		  ; Find out how tall the input is, in bytes
		  POP HL
		  LD A, (cols)
		  LD C, A
		  LD B, 0
		  LD DE, 0
		  XOR A
1:
		  CP (HL)
		  JR Z, 2f
		  ADD HL, BC
		  INC E
		  JR 1b
2:
		  LD A, E
		  LD (rows), A
		  RET

; Strip newlines
; Map '.' to 0xFE
; Convert ASCII digits to decimal
; Map all symbols to 0x80
; Replace null terminator with 0xFF (to avoid clashing with '0')
; TODO: surround area with 'empty' cells
normalise:
		  LD A, 0xFE
		  LD A, (cols)
		  LD B, A
		  LD A, 0xFE
		  INC B
1:
		  LD (DE), A
		  INC DE
		  DJNZ 1b
		  LD (DE), A
		  INC DE
1:
		  LD A, (HL)
		  LD (DE), A
		  CP 0
		  JR Z, 99f
		  CP 0x0A
		  JR Z, 81f ; Skip incrementing write pointer, so we eliminate newlines
		  CP 0x2E
		  JR NZ, 2f
		  LD A, 0xFE
		  LD (DE), A
		  JR 80f
2:
		  CP 0x30 ; '0'
		  JR Z, 3f
		  CP 0x31 ; '1'
		  JR Z, 3f
		  CP 0x32 ; '2'
		  JR Z, 3f
		  CP 0x33 ; '3'
		  JR Z, 3f
		  CP 0x34 ; '4'
		  JR Z, 3f
		  CP 0x35 ; '5'
		  JR Z, 3f
		  CP 0x36 ; '6'
		  JR Z, 3f
		  CP 0x37 ; '7'
		  JR Z, 3f
		  CP 0x38 ; '8'
		  JR Z, 3f
		  CP 0x39 ; '9'
		  JR NZ, 4f
3:
		  SUB 0x30 ; atoi
		  LD (DE), A
		  JR 80f
4:
		  LD A, 0x80; symbol
		  LD (DE), A
80:
		  INC DE
		  INC HL
		  JR 1b
81:
		  ; Replace newlines with two blanks
		  LD A, 0xFE
		  LD (DE), A
		  INC DE
		  INC HL
		  LD A, 0xFE
		  LD (DE), A
		  INC DE
		  JP 1b
99:
		  LD A, 0xFE
		  LD A, (cols)
		  LD B, A
		  LD A, 0xFE
		  INC B
1:
		  LD (DE), A
		  INC DE
		  DJNZ 1b
		  LD A, 0xFF; End of input marker
		  LD (DE), A
		  RET

; HL points to input data
; DE points to part index
indexparts:
		  LD (indexparts_inputdata), HL
		  PUSH DE
		  POP IX
1:
		  LD A, (HL)
		  CP 0xFF
		  RET Z
		  CP 0x80
		  JR NZ, 2f
		  PUSH HL
		  SUB A ; reset C
		  LD BC, (indexparts_inputdata)
		  SBC HL, BC
		  LD (IX),   L
		  LD (IX+1), H
		  HALT
		  ;LD (IX+2), 0x0 ; part no. LSB
		  ;LD (IX+3), 0x0 ; part no. MSB
		  INC IX
		  INC IX
		  INC IX
		  INC IX
		  POP HL
2:
		  INC HL
		  JR 1b
indexparts_inputdata: DW 0

getcoords:
		  LD HL, 0x0
		  RET
; HL points to string
; B has length of string
; A has character
instr:
		  CP (HL)
		  RET Z
		  INC HL
		  DJNZ instr

		  RET

; Multiply DE by A
; Result ends up in HL
mulDE:
		  LD B, 0
		  LD C, A

		  LD A, 8 ; bits in multiplicand
		  LD HL, 0 ; result
1:
		  SRL B
		  RR C ; Divide BC by two, moving LSB into carry flag

		  JR NC, 2f

		  ADD HL, DE
2:
		  EX DE, HL
		  ADD HL, HL
		  EX DE, HL

		  DEC A
		  JR NZ, 1b
		  RET

; Divide DE by A
; Result ends up in HL
divDE:
		  LD C, A
		  LD B, 16
		  XOR A
		  
1:
		  ADD HL, HL
		  RLA
		  JR C, 2f
		  CP C
		  JR C, 3f

2:
		  SUB C
		  INC L

3:
		  DJNZ 1b

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

; HL: s1
; DE: s2
; Z set if equal, unset if not
strcmp:
		  PUSH HL
		  PUSH DE
		  POP HL
		  CALL strlen
		  PUSH HL
		  POP BC
		  POP HL

		  LD A, (DE)
		  CPI
		  RET NZ ; found a difference
		  RET PO ; byte count reached
		  INC DE ; onto the next byte
		  JR strncmp

; HL: pointer to string
; on exit, HL contains string length in bytes
strlen:
		  LD BC, 0x0
		  LD A, 0
		  CPIR
		  LD HL, 0xffff
		  SBC HL, BC
		  RET

; HL: pointer to input
; Returns with A set to the number parsed
parsenum:
		  LD A, (HL)
		  CALL cp_ascii_num
		  CALL NZ, e_badinput
		  LD A, 0
		  PUSH AF
1:
		  LD A, (HL)
		  CALL cp_ascii_num
		  JR NZ, 1f

		  POP AF
		  CALL mul10

		  ADD A, (HL)
		  SUB 0x30 ; ASCII to int
		  PUSH AF
		  INC HL
		  JR 1b
1:
		  POP AF
		  RET

cp_ascii_num:
		  SUB 0x30
		  JR C, 1f
		  SUB 10
		  JR NC, 1f
		  XOR A; set Z=1
		  RET
1:
		  LD A, 1
		  OR A; set Z=0
		  RET
; Consume input matching a string

; HL: pointer to input
; DE: pointer to string to skip
; on exit, HL is advanced to the byte following the string
skipstr:
		  PUSH HL
		  PUSH DE
		  POP HL
		  CALL strlen
		  PUSH HL
		  POP BC
		  POP HL
		  ; HL: pointer to input
		  ; DE: pointer to string to skip
		  ; BC: length of string in DE
		  PUSH BC
		  PUSH HL
		  CALL strncmp
		  JR Z, 1f
		  POP HL
		  POP BC
		  CALL e_badinput
1:
		  POP HL
		  POP BC
		  ADD HL, BC
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

; IX: Pointer to game
; IY: Pointer to comparison
; Returns with Z set if possible, unset if not possible
comparegame:
		  INC IX
		  LD B, (IX) ; Number of hands
		  INC IX ; Points to first hand
1:
		  LD A, B
		  CP 0
		  RET Z
		  CALL comparehand
		  JR C, 1f
		  INC IX
		  INC IX
		  INC IX
		  DEC B
		  JR 1b
1:
		  INC IX
		  INC IX
		  INC IX
		  DEC B
		  JR NZ, 1b
		  LD A, 1
		  CP 0
		  RET

; IX: Pointer to hand
; IY: Pointer to comparison
; Returns with C set if not possible, unset if possible
comparehand:
		  LD A, (IY)
		  CP (IX)
		  RET C
		  LD A, (IY+1)
		  CP (IX+1)
		  RET C
		  LD A, (IY+2)
		  CP (IX+2)
		  RET

result: DW 0
e_badinput:
		  PUSH HL
		  PUSH AF
		  LD HL, e_badinput
		  LD A, 0xE4
		  HALT
s_badinput:   .asciz "Bad input"
cols: DB 0
rows: DB 0
; Partrecord is:
; xynn
; x: x coordinate
; y: y coordinate
; nn: part number
; coords of 0xff, 0xff indicate 'no entry' (end of list)
parts: .fill 750, 4, 0xFFFFFFFF
example1:
		  .incbin "input-example1"
		  DB 0
input:
		  .incbin "input"
		  DB 0
data: DB 0
