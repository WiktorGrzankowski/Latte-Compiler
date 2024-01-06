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
   mov rax, 17
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call ev
   add rsp, 8
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
ev:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
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
   sub rsp, 8
   mov rax, [rbp - 8]
   push rax
   mov rax, 2
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call ev
   add rsp, 8
   jmp end2
   jmp l1
l0:
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l2
   mov rax, 0
   jmp end2
   jmp l3
l2:
   mov rax, 1
   jmp end2
l3:
l1:
end2:
   mov rsp, rbp
   pop rbp
   ret
