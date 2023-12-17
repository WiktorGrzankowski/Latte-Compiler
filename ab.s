section .data
   s0 db '', 0
   s1 db 'pierd', 0

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
   sub rsp, 16
   mov rax, s0
   mov [rbp - 0], rax
   mov rax, s1
   mov [rbp - 8], rax
   mov rax, [rbp - 0]
   mov rdi, rax
   call printString
   mov rax, [rbp - 8]
   mov rdi, rax
   call printString
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
