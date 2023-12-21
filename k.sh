nasm -f elf64 ab.s
gcc -m64  -fPIE lib/runtime.o -o ab ab.o