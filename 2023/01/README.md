There is a crude sed+awk implementation in `part1.sh`.

A Z80 implementation is in `part1.S`.

You can run this on Debian Linux by first `apt-get install -y sdcc-ucsim` to
install a Z80 emulator and running `make`.

If you are unlucky enough that your input generates a total which is more than
65,535 it will fail because the code uses a 16 bit accumulator.
