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
funkcja_ifbooltrudny:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   xor rax, 1
   cmp al, 0
   je l0
   push rax
   mov rax, [rbp - 8]
   mov rcx, rax
   pop rax
   and rax, rcx
l0:
   cmp al, 1
   je l1
   push rax
   mov rax, [rbp - 8]
   cmp al, 1
   je l2
   push rax
   mov rax, [rbp - 16]
   xor rax, 1
   mov rcx, rax
   pop rax
   or rax, rcx
l2:
   xor rax, 1
   mov rcx, rax
   pop rax
   or rax, rcx
l1:
   cmp al, 1
   jne l3
   mov rax, 1042
   mov rdi, rax
   call printInt
   jmp l4
l3:
   mov rax, 2042
   mov rdi, rax
   call printInt
l4:
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov al, 0
   mov rdi, rax
   mov al, 1
   mov rsi, rax
   call funkcja_ifbooltrudny
   add rsp, 0
   mov rax, 0
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
