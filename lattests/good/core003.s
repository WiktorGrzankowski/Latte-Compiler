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

f:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov al, 1
   cmp al, 1
   jne l0
   mov rax, 0
   jmp end1
   jmp l1
l0:
l1:
end1:
   mov rsp, rbp
   pop rbp
   ret
g:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov al, 0
   cmp al, 1
   jne l2
   jmp l3
l2:
   mov rax, 0
   jmp end2
l3:
end2:
   mov rsp, rbp
   pop rbp
   ret
p:
   push rbp
   mov rbp, rsp
   sub rsp, 0
end3:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   call p
   add rsp, 0
   mov rax, 0
   jmp end4
end4:
   mov rsp, rbp
   pop rbp
   ret
