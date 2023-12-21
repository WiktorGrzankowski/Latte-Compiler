section .data
   s0 db '', 0
   s1 db 'jebac pchw', 0

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
   mov rax, 15
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   call allocateArray
   push rax
   mov rcx, r12
   test rcx, rcx
   jz end_loop
init_loop:
   mov qword [rax], s0
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
   mov [rax + rdi * 8], rsi
   mov rax, 0
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 * rax]
   mov rdi, rax
   call printString
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
