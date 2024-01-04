section .data
   s0 db '', 0
   s1 db 'git', 0

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
Animal_$_f:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, s1
   mov rdi, rax
   call printString
end1:
   mov rsp, rbp
   pop rbp
   ret
Animal_$_z:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rdi, rax
   call Animal_$_f
   add rsp, 0
end2:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 0
   call allocateClass
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call Animal_$_z
   add rsp, 0
   mov rax, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
