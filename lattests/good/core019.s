section .data
   s0 db "", 0
   s1 db "foo", 0

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
   mov rax, 78
   mov [rbp - 8], rax
   mov rax, 1
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
l0:
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 76
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l1
   mov rax, [rbp - 8]
   dec rax
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   push rax
   mov rax, 7
   mov rdx, rax
   pop rax
   add rax, rdx
   mov [rbp - 24], rax
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   jmp l0
l1:
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 4
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l2
   mov rax, 4
   mov [rbp - 32], rax
   mov rax, [rbp - 32]
   mov rdi, rax
   call printInt
   jmp l3
l2:
   mov rax, s1
   mov rdi, rax
   call printString
l3:
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
