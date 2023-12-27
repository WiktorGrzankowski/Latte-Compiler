section .data
   s0 db '', 0
   s2 db ' ', 0
   s3 db 'concatenation', 0
   s5 db 'false', 0
   s1 db 'string', 0
   s4 db 'true', 0

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
   mov rax, 56
   mov [rbp - 8], rax
   mov rax, 23
   neg rax
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov rdi, rax
   call printInt
   mov rax, 45
   push rax
   mov rax, 2
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rdi, rax
   call printInt
   mov rax, 78
   push rax
   mov rax, 3
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rax, rdx
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   mov rdi, rax
   call printBool
   add rsp, 0
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setle al
   mov rdi, rax
   call printBool
   add rsp, 0
   mov rax, s1
   push rax
   mov rax, s2
   mov rsi, rax
   pop rax
   mov rdi, rax
   call concat
   push rax
   mov rax, s3
   mov rsi, rax
   pop rax
   mov rdi, rax
   call concat
   mov rdi, rax
   call printString
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
printBool:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   cmp al, 1
   jne l0
   mov rax, s4
   mov rdi, rax
   call printString
   jmp end2
   jne l1
l0:
   mov rax, s5
   mov rdi, rax
   call printString
   jmp end2
l1:
end2:
   mov rsp, rbp
   pop rbp
   ret
