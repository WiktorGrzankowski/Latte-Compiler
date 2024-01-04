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
f:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 8]
   mov rdx, rax
   pop rax
   imul rax, rdx
   push rax
   mov rax, 3
   mov rdx, rax
   pop rax
   add rax, rdx
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
z:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov rax, 12
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   call z
   add rsp, 0
   mov rdi, rax
   call f
   add rsp, 0
   mov rax, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
