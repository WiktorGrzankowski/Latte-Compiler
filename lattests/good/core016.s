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
   mov rax, 17
   mov [rbp - 8], rax
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
   mov rax, [rbp - 8]
   push rax
   mov rax, 2
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov [rbp - 8], rax
   jmp l0
l1:
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
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
   jne l3
l2:
   mov rax, 1
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
l3:
end1:
   mov rsp, rbp
   pop rbp
   ret
