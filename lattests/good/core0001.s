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

f:
   push rbp
   mov rbp, rsp
   sub rsp, 48
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov [rbp - 24], rdx
   mov [rbp - 32], rcx
   mov [rbp - 40], r8
   mov [rbp - 48], r9
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 32]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 40]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 48]
   mov rdi, rax
   call printInt
   mov rax, [rbp + 16]
   mov rdi, rax
   call printInt
   mov rax, [rbp + 24]
   mov rdi, rax
   call printInt
end1:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   sub rsp, 64
   mov rax, 1
   mov [rsp + 0], rax
   mov rax, 2
   mov [rsp + 8], rax
   mov rax, 3
   mov [rsp + 16], rax
   mov rax, 4
   mov [rsp + 24], rax
   mov rax, 5
   mov [rsp + 32], rax
   mov rax, 6
   mov [rsp + 40], rax
   mov rax, 70
   mov [rsp + 48], rax
   mov rax, 80
   mov [rsp + 56], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   mov rdx, [rsp + 16]
   mov rcx, [rsp + 24]
   mov r8, [rsp + 32]
   mov r9, [rsp + 40]
   sub rsp, -48
   call f
   add rsp, 16
   mov rax, 0
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
