section .data
   s0 db "", 0
   s1 db "bad", 0
   s2 db "good", 0

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
   sub rsp, 8
   mov rax, s1
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call f
   add rsp, 8
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
   mov rax, s2
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call printString
end2:
   mov rsp, rbp
   pop rbp
   ret
