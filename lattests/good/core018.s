section .data
   s0 db "", 0

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
   sub rsp, 32
   call readInt
   mov [rbp - 8], rax
   call readString
   mov [rbp - 16], rax
   call readString
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   push rax
   mov rax, 5
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdi, rax
   call printInt
   mov rax, [rbp - 16]
   push rax
   mov rax, [rbp - 24]
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
