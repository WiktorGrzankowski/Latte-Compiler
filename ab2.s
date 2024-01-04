section .data
   s0 db '', 0
   s1 db 'other', 0

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
IntQueue_$_isEmpty:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
IntQueue_$_insert:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rdi, 0
   call allocateClass
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call IntQueue_$_isEmpty
   add rsp, 0
   cmp al, 1
   jne l0
   jne l1
l0:
   mov rax, s1
   mov rdi, rax
   call printString
l1:
end2:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 8
   call allocateClass
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   mov rax, 12
   mov rsi, rax
   call IntQueue_$_insert
   add rsp, 0
   mov rax, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
