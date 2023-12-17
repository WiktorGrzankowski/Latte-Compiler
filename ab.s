section .data
   s0 db '', 0

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
   sub rsp, 0
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
f:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   call g
   add rsp, 0
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
g:
   push rbp
   mov rbp, rsp
   sub rsp, 0
end3:
   mov rsp, rbp
   pop rbp
   ret
