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

main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   sub rsp, 8
   mov rax, 5
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call fac
   add rsp, 8
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
fac:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov rax, 0
   mov [rbp - 16], rax
   mov rax, 0
   mov [rbp - 24], rax
   mov rax, 1
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov [rbp - 24], rax
l0:
   mov rax, [rbp - 24]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l1
   mov rax, [rbp - 16]
   push rax
   mov rax, [rbp - 24]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov [rbp - 16], rax
   mov rax, [rbp - 24]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov [rbp - 24], rax
   jmp l0
l1:
   mov rax, [rbp - 16]
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
