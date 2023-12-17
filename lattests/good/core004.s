section .data
   s0 db '', 0

section .text
   extern printInt
   extern printString
   extern readString
   extern concat
   extern readInt
   extern error
   global main
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov al, 1
   mov rdx, rax
   push rdx
   mov al, 1
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   cmp al, 1
   jne l0
   mov rax, 42
   mov rdi, rax
   call printInt
l0:
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
