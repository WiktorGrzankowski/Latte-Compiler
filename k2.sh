nasm -f elf64 ab2.s
gcc -m64  lib/runtime.o -o ab2 ab2.o
