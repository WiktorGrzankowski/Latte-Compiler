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
   call foo
   add rsp, 0
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
foo:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov rax, 10
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
