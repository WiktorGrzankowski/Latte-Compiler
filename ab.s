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
   push r12
   mov rax, 5
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, 2
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
