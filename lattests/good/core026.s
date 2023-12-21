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
   global main
d:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
s:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   add rax, rdx
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 0
   call d
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call s
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
