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
doubleArray:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   push r12
   mov rax, [rbp - 8]
   mov rax, [rax]
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 16], rax
   mov rax, 0
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach1end
forEach1:
   mov r14, [r13]
   mov [rbp - 32], r14
   mov rax, [rbp - 16]
   push rax
   mov rax, [rbp - 24]
   mov rdi, rax
   push rax
   mov rax, 2
   push rax
   mov rax, [rbp - 32]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 24]
   inc rax
   mov [rbp - 24], rax
   add r13, 8
   dec r12
   jnz forEach1
forEach1end:
   add rsp, 8
   mov rax, [rbp - 16]
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
shiftLeft:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov rax, 0
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov [rbp - 16], rax
   mov rax, 0
   mov [rbp - 24], rax
l1:
   mov rax, [rbp - 24]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rax, [rax]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l2
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 24]
   mov rdi, rax
   push rax
   mov rax, [rbp - 24]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 24]
   inc rax
   mov [rbp - 24], rax
   jmp l1
l2:
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 8]
   mov rax, [rax]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdi, rax
   push rax
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
scalProd:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, 0
   mov [rbp - 24], rax
   mov rax, 0
   mov [rbp - 32], rax
l3:
   mov rax, [rbp - 32]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rax, [rax]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l4
   mov rax, [rbp - 24]
   push rax
   mov rax, [rbp - 32]
   push rax
   mov rax, [rbp - 8]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   push rax
   mov rax, [rbp - 32]
   push rax
   mov rax, [rbp - 16]
   mov rdi, rax
   pop rax
   mov rax, [rdi + 8 + 8 * rax]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov rdx, rax
   pop rax
   add rax, rdx
   mov [rbp - 24], rax
   mov rax, [rbp - 32]
   inc rax
   mov [rbp - 32], rax
   jmp l3
l4:
   mov rax, [rbp - 24]
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   push r12
   mov rax, 5
   mov rdi, rax
   mov r12, rdi
   mov rsi, 8
   add rdi, 1
   call allocateArray
   mov [rax], r12
   pop r12
   mov [rbp - 8], rax
   mov rax, 0
   mov [rbp - 16], rax
l5:
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 8]
   mov rax, [rax]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l6
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdi, rax
   push rax
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   pop rax
   mov [rax + 8 + rdi * 8], rsi
   mov rax, [rbp - 16]
   inc rax
   mov [rbp - 16], rax
   jmp l5
l6:
   mov rax, [rbp - 8]
   mov rdi, rax
   call shiftLeft
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   call doubleArray
   add rsp, 0
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach8end
forEach8:
   mov r14, [r13]
   mov [rbp - 32], r14
   mov rax, [rbp - 32]
   mov rdi, rax
   call printInt
   add r13, 8
   dec r12
   jnz forEach8
forEach8end:
   add rsp, 8
   mov rax, [rbp - 24]
   mov r12, [rax]
   add rax, 8
   mov r13, rax
   sub rsp, 8
   test r12, r12
   jz forEach9end
forEach9:
   mov r14, [r13]
   mov [rbp - 32], r14
   mov rax, [rbp - 32]
   mov rdi, rax
   call printInt
   add r13, 8
   dec r12
   jnz forEach9
forEach9end:
   add rsp, 8
   mov rax, [rbp - 8]
   mov rdi, rax
   mov rax, [rbp - 24]
   mov rsi, rax
   call scalProd
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end4
end4:
   mov rsp, rbp
   pop rbp
   ret
