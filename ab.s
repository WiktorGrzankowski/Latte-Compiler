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
___C___f___:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 0]
   mov rdi, rax
   call printInt
end1:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 8
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   mov rax, 120
   mov rsi, rax
   call ___C___f___
   add rsp, 0
   mov rax, 0
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
