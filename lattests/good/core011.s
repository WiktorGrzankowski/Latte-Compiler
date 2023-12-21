section .data
   s0 db '', 0

section .text
   extern printInt
   extern printString
   extern readString
   extern concat
   extern readInt
   extern error
   extern allocateArray
   global main
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov rax, 1
   neg rax
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
