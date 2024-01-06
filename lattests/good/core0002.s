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

X_$_f:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   push rax
   mov rax, 12
   mov rdi, rax
   pop rax
   mov [rax + 0], rdi
end1:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 8
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   mov [rbp - 8], rax
   sub rsp, 8
   mov rax, [rbp - 8]
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call X_$_f
   add rsp, 8
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
