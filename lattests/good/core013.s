section .data
   s0 db "", 0
   s3 db "!", 0
   s1 db "&&", 0
   s4 db "false", 0
   s5 db "true", 0
   s2 db "||", 0

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
   mov rax, s1
   mov rdi, rax
   call printString
   mov rax, 1
   neg rax
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 0
   je l0
   push rax
   mov rax, 0
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   and rax, rcx
l0:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, 2
   neg rax
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 0
   je l1
   push rax
   mov rax, 1
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   and rax, rcx
l1:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, 3
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 0
   je l2
   push rax
   mov rax, 5
   neg rax
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   and rax, rcx
l2:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, 234234
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 0
   je l3
   push rax
   mov rax, 21321
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   and rax, rcx
l3:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, s2
   mov rdi, rax
   call printString
   mov rax, 1
   neg rax
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 1
   je l4
   push rax
   mov rax, 0
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   or rax, rcx
l4:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, 2
   neg rax
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 1
   je l5
   push rax
   mov rax, 1
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   or rax, rcx
l5:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, 3
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 1
   je l6
   push rax
   mov rax, 5
   neg rax
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   or rax, rcx
l6:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, 234234
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   cmp al, 1
   je l7
   push rax
   mov rax, 21321
   mov rdi, rax
   push rdi
   pop rdi
   call test
   add rsp, 0
   mov rcx, rax
   pop rax
   or rax, rcx
l7:
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov rax, s3
   mov rdi, rax
   call printString
   mov al, 1
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
   mov al, 0
   mov rdi, rax
   push rdi
   pop rdi
   call printBool
   add rsp, 0
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
   xor al, 1
   cmp al, 1
   jne l8
   mov rax, s4
   mov rdi, rax
   call printString
   jmp l9
l8:
   mov rax, s5
   mov rdi, rax
   call printString
l9:
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
test:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
