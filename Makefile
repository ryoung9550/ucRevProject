# creation rules

default: bootstrap.bin

bootstrap.bin: bootstrap.asm
	nasm -f bin $^ -o $@

clean:
	rm *.bin
