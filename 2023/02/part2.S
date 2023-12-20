		  ;LD HL, example1
		  LD HL, input
		  LD DE, games
		  CALL parseinput
		  LD (IX), 0 ; Terminate list
		  LD IX, games
1:
		  PUSH IX ; Pointer to game
		  CALL calcpower
		  POP IY ; Pointer to game
		  ; Load power into BC
		  LD B, (IY+2)
		  LD C, (IY+1)
		  ; Add it to cumulative result
		  LD HL, (result)
		  ADD HL, BC
		  JR NC, 2f
		  PUSH HL
		  LD HL, (result+2)
		  INC HL
		  LD (result+2), HL
		  POP HL
2:
		  LD (result), HL
		  LD A, (IX)
		  CP 0
		  JR NZ, 1b ; More games to process
3:
		  LD HL, result
		  HALT

parseinput:
		  LD IX, games ; pointer to parsed game data
		  LD IY, games ; pointer to current game hand
		  INC IY
		  INC IY
		  INC IY
		  INC IY
1:		  
		  LD A, (HL)
		  CP 0
		  RET Z

		  ; Line starts with 'Game '
		  LD DE, s_game
		  CALL skipstr

		  ; Followed by game#
		  CALL parsenum
		  LD (IX), A   ; Game number
		  LD (IX+1), 0 ; MSB of game power
		  LD (IX+2), 0 ; LSB of game power
		  LD (IX+3), 0 ; # of rounds

		  LD DE, s_colonspace
		  CALL skipstr

		  ; parse a game hand
7:
		  LD (IY), 0   ; r
		  LD (IY+1), 0 ; g
		  LD (IY+2), 0 ; b
2:
		  LD A, (HL)
		  CP 0x0a ; newline, next game
		  JR Z, 99f
		  CP 0x3b ; ';', end of hand
		  JR Z, 10f
		  CP 0x2c ; ',', next number
		  JR NZ, 8f
		  INC HL
		  CALL eatspace
8:
		  ; Next number
		  CALL parsenum
		  PUSH AF
		  CALL eatspace
		  LD DE, s_red
		  PUSH HL
		  CALL strcmp
		  POP HL
		  JR NZ, 3f
		  POP AF
		  LD (IY), A
		  LD DE, s_red
		  CALL skipstr
		  JR 2b
3:
		  LD DE, s_green
		  PUSH HL
		  CALL strcmp
		  POP HL
		  JR NZ, 4f
		  POP AF
		  LD (IY+1), A
		  LD DE, s_green
		  CALL skipstr
		  JR 2b

4:
		  LD DE, s_blue
		  PUSH HL
		  CALL strcmp
		  POP HL
		  CALL NZ, e_badinput
		  POP AF
		  LD (IY+2), A
		  LD DE, s_blue
		  CALL skipstr
		  JR 2b

		  ; End of hand
10:
		  INC HL
		  INC IY
		  INC IY
		  INC IY
		  LD A, (IX+3)
		  INC A
		  LD (IX+3), A
		  CALL eatspace
		  JP 7b
		  
; End of game. 
99:
		  LD A, (IX+3)
		  INC A
		  LD (IX+3), A
		  INC IY
		  INC IY
		  INC IY
		  PUSH IY
		  POP IX
		  INC IY
		  INC IY
		  INC IY
		  INC IY
		  INC HL
		  JP 1b

eatspace:
		  LD DE, s_space
		  CALL skipstr
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
; Returns with Z set if possible, unset if not possible
calcpower:
		  PUSH IX
		  LD IY, gamebuffer
		  LD (IY), 0
		  LD (IY+1), 0
		  LD (IY+2), 0
		  LD B, (IX+3) ; Number of hands
		  INC IX
		  INC IX
		  INC IX
		  INC IX ; Points to first hand
1:
		  ; Check red
		  LD A, (IY)
		  CP (IX)
		  JR NC, 2f
		  LD A, (IX)
		  LD (IY), A
2:
		  ; Check green
		  LD A, (IY+1)
		  CP (IX+1)
		  JR NC, 3f
		  LD A, (IX+1)
		  LD (IY+1), A
3:
		  ; Check blue
		  LD A, (IY+2)
		  CP (IX+2)
		  JR NC, 4f
		  LD A, (IX+2)
		  LD (IY+2), A
4:
		  INC IX
		  INC IX
		  INC IX
		  DJNZ 1b
		  POP IY
		  LD A, (gamebuffer)
		  LD (IY+1), A
		  ; Load game power into BC
		  PUSH IY
		  POP HL
		  INC HL
		  LD E, (HL)
		  INC HL
		  LD D, (HL)
		  LD A, (gamebuffer+1)
		  CALL mulDE
		  PUSH HL
		  POP DE
		  LD A, (gamebuffer+2)
		  CALL mulDE
		  ; Power in HL
		  LD (IY+1), L
		  LD (IY+2), H
		  RET
gamebuffer:
		  DB 0, 0, 0

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

result: DW 0, 0
e_badinput:
		  PUSH HL
		  PUSH AF
		  LD HL, s_badinput
		  LD A, 0xE4
		  HALT
e_overflow:
		  PUSH HL
		  PUSH AF
		  LD HL, s_overflow
		  LD A, 0xD4
		  HALT
s_badinput:
		  DB "Bad input", 0
s_overflow:
		  DB "Overflow", 0
s_game:
		  DB "Game ", 0
s_colonspace:
		  DB ": ", 0
s_space:
		  DB " ", 0
s_red:
		  DB "red", 0
s_green:
		  DB "green", 0
s_blue:
		  DB "blue", 0
example1:
		  .incbin "input-example1"
		  DB 0
example1_broken:
		  .incbin "input-example1-broken"
		  DB 0
input:
		  .incbin "input"
		  DB 0
games:
