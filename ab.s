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
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 24
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 8], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 16], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
