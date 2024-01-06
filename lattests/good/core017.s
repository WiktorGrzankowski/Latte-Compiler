section .data
   s0 db "", 0
   s1 db "apa", 0
   s3 db "false", 0
   s2 db "true", 0

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
   mov rax, 4
   mov [rbp - 8], rax
   mov rax, 3
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setle al
   cmp al, 0
   je l0
   push rax
   mov rax, 4
   mov rdx, rax
   push rdx
   mov rax, 2
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setne al
   cmp al, 0
   je l1
   push rax
   mov al, 1
   mov rcx, rax
   pop rax
   and rax, rcx
l1:
   mov rcx, rax
   pop rax
   and rax, rcx
l0:
   cmp al, 1
   jne l2
   sub rsp, 8
   mov al, 1
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   jmp l3
l2:
   mov rax, s1
   mov rdi, rax
   call printString
l3:
   sub rsp, 8
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
   je l4
   push rax
   sub rsp, 8
   mov rax, 1
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call dontCallMe
   add rsp, 8
   mov rcx, rax
   pop rax
   or rax, rcx
l4:
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   sub rsp, 8
   mov rax, 4
   mov rdx, rax
   push rdx
   mov rax, 5
   neg rax
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 0
   je l5
   push rax
   sub rsp, 8
   mov rax, 2
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call dontCallMe
   add rsp, 8
   mov rcx, rax
   pop rax
   and rax, rcx
l5:
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   sub rsp, 8
   mov rax, 4
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   cmp al, 0
   je l6
   push rax
   mov al, 1
   mov rdx, rax
   push rdx
   mov al, 0
   xor al, 1
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   cmp al, 0
   je l7
   push rax
   mov al, 1
   mov rcx, rax
   pop rax
   and rax, rcx
l7:
   mov rcx, rax
   pop rax
   and rax, rcx
l6:
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   sub rsp, 8
   sub rsp, 16
   mov al, 0
   mov [rsp + 0], rax
   mov al, 0
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call implies
   add rsp, 16
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   sub rsp, 8
   sub rsp, 16
   mov al, 0
   mov [rsp + 0], rax
   mov al, 1
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call implies
   add rsp, 16
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   sub rsp, 8
   sub rsp, 16
   mov al, 1
   mov [rsp + 0], rax
   mov al, 0
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call implies
   add rsp, 16
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   sub rsp, 8
   sub rsp, 16
   mov al, 1
   mov [rsp + 0], rax
   mov al, 1
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call implies
   add rsp, 16
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call printBool
   add rsp, 8
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
dontCallMe:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov al, 1
   jmp end2
end2:
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
   jne l8
   mov rax, s2
   mov rdi, rax
   call printString
   jmp l9
l8:
   mov rax, s3
   mov rdi, rax
   call printString
l9:
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
implies:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   xor al, 1
   cmp al, 1
   je l10
   push rax
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 16]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   mov rcx, rax
   pop rax
   or rax, rcx
l10:
   jmp end4
end4:
   mov rsp, rbp
   pop rbp
   ret
