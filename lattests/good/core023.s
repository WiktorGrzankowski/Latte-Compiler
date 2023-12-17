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
   sub rsp, 112
   mov rax, 1
   mov [rbp - 8], rax
   mov rax, 2
   mov [rbp - 16], rax
   mov rax, 1
   mov [rbp - 24], rax
   mov rax, 2
   mov [rbp - 32], rax
   mov rax, 1
   mov [rbp - 40], rax
   mov rax, 2
   mov [rbp - 48], rax
   mov rax, 1
   mov [rbp - 56], rax
   mov rax, 2
   mov [rbp - 64], rax
   mov rax, 1
   mov [rbp - 72], rax
   mov rax, 2
   mov [rbp - 80], rax
   mov rax, 1
   mov [rbp - 88], rax
   mov rax, 2
   mov [rbp - 96], rax
   mov rax, 1
   mov [rbp - 104], rax
   mov rax, 2
   mov [rbp - 112], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   mov rax, [rbp - 16]
   mov rsi, rax
   mov rax, [rbp - 24]
   mov rdx, rax
   mov rax, [rbp - 32]
   mov rcx, rax
   mov rax, [rbp - 40]
   mov r8, rax
   mov rax, [rbp - 48]
   mov r9, rax
   sub rsp, 64
   mov rax, [rbp - 56]
   mov [rsp + 0], rax
   mov rax, [rbp - 64]
   mov [rsp + 8], rax
   mov rax, [rbp - 72]
   mov [rsp + 16], rax
   mov rax, [rbp - 80]
   mov [rsp + 24], rax
   mov rax, [rbp - 88]
   mov [rsp + 32], rax
   mov rax, [rbp - 96]
   mov [rsp + 40], rax
   mov rax, [rbp - 104]
   mov [rsp + 48], rax
   mov rax, [rbp - 112]
   mov [rsp + 56], rax
   call foo
   add rsp, 64
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
foo:
   push rbp
   mov rbp, rsp
   sub rsp, 56
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov [rbp - 24], rdx
   mov [rbp - 32], rcx
   mov [rbp - 40], r8
   mov [rbp - 48], r9
   mov rax, 2
   push rax
   mov rax, [rbp - 8]
   mov rdx, rax
   pop rax
   imul rax, rdx
   push rax
   mov rax, [rbp - 16]
   push rax
   mov rax, 2
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp - 24]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp - 32]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp - 40]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp - 48]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 24]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 32]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 40]
   push rax
   mov rax, 2
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 48]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 56]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 64]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp + 72]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, 10
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov rax, rdx
   mov [rbp - 56], rax
   mov rax, [rbp - 56]
   mov rdi, rax
   call printInt
   mov rax, [rbp - 56]
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
