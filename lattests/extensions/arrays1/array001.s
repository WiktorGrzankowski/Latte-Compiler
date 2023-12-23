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
   sub rsp, 32
   push r12
   mov rax, 10
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, 0
   mov [rbp - 16], rax
l0:
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rax, [rax]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l1
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdi, rax
   push rax
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 16]
   inc rax
   mov [rbp - 16], rax
   jmp l0
l1:
   mov rax, [rbp - 8]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach3end
forEach3:
   mov r14, [r13]
   mov [rbp - 24], r14
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   add r13, 8
   dec r12
   jnz forEach3
forEach3end:
   add rsp, 8
   mov rax, 45
   mov [rbp - 24], rax
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
