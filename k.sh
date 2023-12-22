nasm -f elf64 ab.s
gcc -m64  lib/runtime.o -o ab ab.o