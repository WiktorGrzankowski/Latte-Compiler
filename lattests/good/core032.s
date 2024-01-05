section .data
   s0 db "", 0

section .text
   extern printInt
   extern printString
   extern readString
   extern concat
   extern readInt
   extern error
   extern allocateArray
   extern allocateClass
   global main
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov rax, 42
   neg rax
   push rax
   mov rax, 1
   neg rax
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
