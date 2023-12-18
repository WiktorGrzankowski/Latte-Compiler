section .data
   s0 db '', 0

section .text
   extern printInt
   extern printString
   extern readString
   extern concat
   extern readInt
   extern error
   global main
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   call readInt
   mov [rbp - 8], rax
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
