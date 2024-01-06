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
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, rax
   call printInt
end1:
   mov rsp, rbp
   pop rbp
   ret
f2:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   sub rsp, 16
   sub rsp, 16
   mov rax, 10
   mov [rsp + 0], rax
   mov rax, 10
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call f2
   add rsp, 16
   mov [rsp + 0], rax
   mov rax, 1
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call f
   add rsp, 16
   sub rsp, 16
   mov rax, 1
   mov [rsp + 0], rax
   sub rsp, 16
   mov rax, 10
   mov [rsp + 0], rax
   mov rax, 10
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call f2
   add rsp, 16
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call f
   add rsp, 16
   mov rax, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
