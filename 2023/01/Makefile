AS := z80-unknown-coff-as
LD := z80-unknown-coff-ld
OBJCOPY := z80-unknown-coff-objcopy

.PHONY: clean all run-part1

all: run-part1

run-part1: part1.hex
	sz80 $^ -e run -e "(rom[HL+1] << 8) + rom[HL]" -e quit

clean:
	rm -f part1 *.o *.hex

part1.hex: part1
	$(OBJCOPY) -O ihex $^ $@

%.o: %.S
	$(AS) -o $@ $^

part1: part1.o
	$(LD) -o $@ $^
