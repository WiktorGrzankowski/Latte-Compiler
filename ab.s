section .data
   s0 db '', 0
   s1 db 'anim', 0
   s2 db 'doggo', 0
   s3 db 'owczarek', 0

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
___Animal___sayName___:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdi, rax
   call printString
end1:
   mov rsp, rbp
   pop rbp
   ret
___Dog___sayBreed___:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdi, rax
   call printString
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
   push r12
   mov r12, s0
   mov [rax + 0], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   push rax
   mov rax, s1
   mov rdi, rax
   pop rax
   mov [rax + 0], rdi
   mov rax, [rbp - 8]
   mov rdi, rax
   call ___Animal___sayName___
   add rsp, 0
   mov rdi, 16
   call allocateClass
   push r12
   mov r12, s0
   mov [rax + 0], r12
   pop r12
   push r12
   mov r12, s0
   mov [rax + 8], r12
   pop r12
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   push rax
   mov rax, s2
   mov rdi, rax
   pop rax
   mov [rax + 8], rdi
   mov rax, [rbp - 16]
   push rax
   mov rax, s3
   mov rdi, rax
   pop rax
   mov [rax + 0], rdi
   mov rax, [rbp - 16]
   mov rdi, rax
   call ___Dog___sayBreed___
   add rsp, 0
   mov rax, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
