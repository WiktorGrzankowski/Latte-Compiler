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
   sub rsp, 32
   mov rax, 0
   mov [rbp - 8], rax
   mov rax, 0
   mov [rbp - 16], rax
   mov rax, 0
   mov [rbp - 24], rax
   mov rax, 1
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov [rbp - 16], rax
   mov rax, 5000000
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
l0:
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 24]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l1
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   push rax
   mov rax, [rbp - 8]
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov [rbp - 8], rax
   jmp l0
l1:
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
