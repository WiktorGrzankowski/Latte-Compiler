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
   extern allocateClass
   global main
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   push r12
   mov rax, 12
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
   mov rax, 1
   mov rdi, rax
   push rax
   mov rdi, 16
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 8], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, 1
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   push rax
   mov rax, 12
   mov rdi, rax
   pop rax
   mov [rax + 0], rdi
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
