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
   global main
main:
   push rbp
   mov rbp, rsp
   sub rsp, 8
   mov rax, 1
   mov [rbp - 8], rax
   sub rsp, 8
   mov rax, 2
   mov [rbp - 16], rax
   sub rsp, 8
   mov rax, 3
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
