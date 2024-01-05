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
   mov rax, [rbp - 8]
   push rax
   mov rax, 1
   mov rdi, rax
   push rax
   mov rax, 12
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 8]
   push rax
   mov rax, 0
   mov rdi, rax
   push rax
   mov rax, 999
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
end1:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   push r12
   mov rax, 3
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call f
   add rsp, 0
   mov rax, [rbp - 8]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach1end
forEach1:
   mov r14, [r13]
   mov [rbp - 16], r14
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   add r13, 8
   dec r12
   jnz forEach1
forEach1end:
   add rsp, 8
   mov rax, 0
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
