section .data
   s0 db '', 0
   s1 db 'Mircia', 0

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
   mov rdi, 16
   call allocateClass
   push r12
   mov r12, s0
   mov [rax + 0], r12
   pop r12
   push r12
   mov r12, s0
   mov [rax + 8], r12
   pop r12
   mov [rbp - 8], rax
   push r12
   mov rax, 2
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   push rax
   mov rax, 0
   mov rdi, rax
   push rax
   mov rax, [rbp - 8]
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, 0
   push rax
   mov rax, [rbp - 16]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   push rax
   mov rax, s1
   mov rdi, rax
   pop rax
   mov [rax + 0], rdi
   mov rax, 0
   push rax
   mov rax, [rbp - 16]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov rax, [rax + 0]
   mov rdi, rax
   call printString
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
