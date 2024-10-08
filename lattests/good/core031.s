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
   sub rsp, 16
   mov rax, 1
   mov [rsp + 0], rax
   mov rax, 1
   neg rax
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call f
   add rsp, 16
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
f:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 0
   je l0
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   mov rcx, rax
   pop rax
   and rax, rcx
l0:
   cmp al, 1
   je l1
   push rax
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 0
   je l2
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   mov rcx, rax
   pop rax
   and rax, rcx
l2:
   mov rcx, rax
   pop rax
   or rax, rcx
l1:
   cmp al, 1
   jne l3
   mov rax, 7
   jmp end2
   jmp l4
l3:
   mov rax, 42
   jmp end2
l4:
end2:
   mov rsp, rbp
   pop rbp
   ret
