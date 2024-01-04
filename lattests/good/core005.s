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
   mov rax, 0
   mov [rbp - 8], rax
   mov rax, 56
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   push rax
   mov rax, 45
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdx, rax
   push rdx
   mov rax, 2
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setle al
   cmp al, 1
   jne l0
   mov rax, 1
   mov [rbp - 8], rax
   jmp l1
l0:
   mov rax, 2
   mov [rbp - 8], rax
l1:
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
