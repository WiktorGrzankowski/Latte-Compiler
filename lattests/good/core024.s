section .data
   s0 db '', 0
   s2 db 'NOOO', 0
   s1 db 'yes', 0

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
   mov rax, 1
   mov rdi, rax
   mov rax, 2
   mov rsi, rax
   call f
   add rsp, 0
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
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   je l0
   push rax
   call e
   add rsp, 0
   mov rcx, rax
   pop rax
   or rax, rcx
l0:
   cmp al, 1
   jne l1
   mov rax, s1
   mov rdi, rax
   call printString
l1:
end2:
   mov rsp, rbp
   pop rbp
   ret
e:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov rax, s2
   mov rdi, rax
   call printString
   mov al, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
