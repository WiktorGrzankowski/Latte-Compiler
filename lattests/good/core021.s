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
   sub rsp, 0
   mov al, 1
   cmp al, 1
   jne l0
   mov rax, 1
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
l0:
end1:
   mov rsp, rbp
   pop rbp
   ret
