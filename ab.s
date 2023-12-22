section .data
   s0 db '', 0
   s1 db 'pchw', 0

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
   mov rax, 12
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   push rax
   mov rcx, r12
   test rcx, rcx
   jz end_loop
init_loop:
   mov qword [rax + 8], s0
   add rax, 8
   loop init_loop
end_loop:
   pop rax
   pop r12
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   push rax
   mov rax, 0
   mov rdi, rax
   push rax
   mov rax, s1
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, 11
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov rdi, rax
   call printString
   mov rax, [rbp - 8]
   mov rax, [rax]
   mov rdi, rax
   call printInt
   push r12
   mov rax, 12
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
   mov rax, 2
   mov rdi, rax
   push rax
   mov rax, 912312
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, 11
   push rax
   mov rax, [rbp - 16]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 16]
   mov rax, [rax]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
