section .data
   s0 db "", 0
   s1 db "ok", 0

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
   mov rax, 1
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l0
   mov rax, s1
   mov rdi, rax
   call printString
l0:
   mov rax, [rbp - 8]
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
l1:
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l2
   jmp l3
l2:
   mov rax, s1
   mov rdi, rax
   call printString
l3:
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
