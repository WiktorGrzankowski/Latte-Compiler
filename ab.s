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
   push rax
   mov rax, 0
   mov rdi, rax
   push rax
   mov rax, 1
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 8]
   push rax
   mov rax, 1
   mov rdi, rax
   push rax
   mov rax, 2
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 8]
   push rax
   mov rax, 2
   mov rdi, rax
   push rax
   mov rax, 3
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   push r12
   mov rax, 4
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach1end
forEach1:
   mov r14, [r13]
   mov [rbp - 24], r14
   mov rax, [rbp - 16]
   push rax
   mov rax, [rbp - 24]
   mov rdi, rax
   push rax
   mov rax, [rbp - 24]
   push rax
   mov rax, 100
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   add r13, 8
   dec r12
   jnz forEach1
forEach1end:
   add rsp, 8
   mov rax, [rbp - 16]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach2end
forEach2:
   mov r14, [r13]
   mov [rbp - 24], r14
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   add r13, 8
   dec r12
   jnz forEach2
forEach2end:
   add rsp, 8
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
