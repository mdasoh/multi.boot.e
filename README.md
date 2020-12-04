<pre>
# multi.boot.e

prerequisites:
sudo apt-get install qemu-system-x86 nasm
an i586 or i686 toolchain here: https://wiki.osdev.org/GCC_Cross-Compiler#Prebuilt_Toolchains
next the floppy image: http://show.ing.me/m2-0014.144.gz ;decompress with gzip -d m2-0014.144

customization: edit your makefile with your favorite gnu editor

booting:
sudo make
when the qemu window appears, grub4dos will load grub2
you'll see at least some numbers
pressing a key should cause the screen to be flooded with numerals.

...and that means it booted

next up:
1. document the code
2. tidy it up
3. add physical memory management code from mm.e

</pre>
