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
   sub rsp, 16
   mov rax, 0
   mov [rbp - 8], rax
   mov rdi, 8
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Counter_$_incr
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Counter_$_incr
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Counter_$_incr
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Counter_$_value
   add rsp, 0
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
Counter_$_incr:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   inc rax
   mov rdi, [rbp - 8]
   mov [rdi + 0], rax
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
Counter_$_value:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
