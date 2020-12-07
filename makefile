
HOME = /root

run: all
	qemu-system-x86_64 \
	-drive file=$(HOME)/src/multi.boot.e/m2-0014.144,cache=none,format=raw,if=floppy,index=0 \
	-netdev tap,id=nd0,br=eth0 -device ne2k_pci,netdev=nd0,mac=00:03:12:34:56:78 \
	-vga virtio -display gtk,gl=on \
	-enable-kvm -k en-us -monitor stdio -m 256 -boot a

all: m2.bin $(HOME)/src/m2/m2-0014.144
	mount -t vfat -o loop,shortname=lower $(HOME)/src/multi.boot.e/m2-0014.144 /b
	cp -a m2.bin /b/sys
	umount /b

m2.o: m2.asm
	nasm -f elf32 -o m2.o m2.asm

m2.bin: m2.o
	$(HOME)/app/i686-elf-4.9.1-Linux-x86_64/bin/i686-elf-g++ -nostdlib -Tmyld.lds -o m2.bin m2.o

dump:; $(HOME)/app/i686-elf-4.9.1-Linux-x86_64/bin/i686-elf-objdump -Maddr16,data16 -r -d m2.o | less
