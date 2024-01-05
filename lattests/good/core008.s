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
   sub rsp, 16
   mov rax, 0
   mov [rbp - 8], rax
   mov rax, 7
   mov [rbp - 16], rax
   mov rax, 1234234
   neg rax
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
