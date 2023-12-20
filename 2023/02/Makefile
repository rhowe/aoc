AS := z80-unknown-coff-as
LD := z80-unknown-coff-ld
OBJCOPY := z80-unknown-coff-objcopy

.PHONY: clean all run-part1 run-part2

all: run-part1 run-part2

# This doesn't work - for some reason the simulation stops, but if you run it
# manually and just use "run" to continue the simulation it'll complete
run-part2: part2.hex
	sz80 $^ -e run -e "(rom[HL+3] << 24) + (rom[HL+2] << 16) + (rom[HL+1] << 8) + rom[HL]" -e quit

run-part1: part1.hex
	sz80 $^ -e run -e "HL" -e quit

clean:
	rm -f part1 part2 *.o *.hex

part1.hex: part1
	$(OBJCOPY) -O ihex $^ $@

part2.hex: part2
	$(OBJCOPY) -O ihex $^ $@

%.o: %.S
	$(AS) -o $@ $^

part1: part1.o
	$(LD) -o $@ $^

part2: part2.o
	$(LD) -o $@ $^
