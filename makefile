
HOME = /root
MNT = /b
SRC = $(HOME)/src/multi.boot.e

run: $(SRC)/m2-0014.144
	qemu-system-x86_64 \
	-drive file=$(SRC)/m2-0014.144,cache=none,format=raw,if=floppy,index=0 \
	-netdev tap,id=nd0,br=eth0 -device ne2k_pci,netdev=nd0,mac=00:03:12:34:56:78 \
	-vga virtio -display gtk,gl=on \
	-enable-kvm -k en-us -monitor stdio -m 256 -boot a

$(SRC)/m2-0014.144: m2.bin
	mount -t vfat -o loop,shortname=lower $(SRC)/m2-0014.144 $(MNT)
	cp -a m2.bin $(MNT)/sys
	umount $(MNT)

m2.o: m2.asm
	nasm -f elf32 -o m2.o m2.asm

m2.bin: m2.o
	$(HOME)/app/i686-elf-4.9.1-Linux-x86_64/bin/i686-elf-g++ -nostdlib -Tmyld.lds -o m2.bin m2.o

dump:; $(HOME)/app/i686-elf-4.9.1-Linux-x86_64/bin/i686-elf-objdump -Maddr16,data16 -r -d m2.o | less
