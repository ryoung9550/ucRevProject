# creation rules

default: bootstrap.bin

run:
	qemu-system-i386 -fda bootstrap.bin

bootstrap.bin: bootstrap.asm
	nasm -g -f bin $^ -o $@

clean:
	rm *.bin
