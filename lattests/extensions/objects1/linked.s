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
Node_$_setElem:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rax, [rbp - 16]
   mov rdi, [rbp - 8]
   mov [rdi + 0], rax
end1:
   mov rsp, rbp
   pop rbp
   ret
Node_$_setNext:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   mov rax, [rbp - 16]
   mov rdi, [rbp - 8]
   mov [rdi + 8], rax
end2:
   mov rsp, rbp
   pop rbp
   ret
Node_$_getElem:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
Node_$_getNext:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   jmp end4
end4:
   mov rsp, rbp
   pop rbp
   ret
Stack_$_push:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rdi, 16
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   mov [rbp - 24], rax
   mov rax, [rbp - 24]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call Node_$_setElem
   add rsp, 0
   mov rax, [rbp - 24]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rsi, rax
   pop rdi
   call Node_$_setNext
   add rsp, 0
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rax, [rbp - 24]
   mov rdi, [rbp - 8]
   mov [rdi + 0], rax
end5:
   mov rsp, rbp
   pop rbp
   ret
Stack_$_isEmpty:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   jmp end6
end6:
   mov rsp, rbp
   pop rbp
   ret
Stack_$_top:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdi, rax
   push rdi
   pop rdi
   call Node_$_getElem
   add rsp, 0
   jmp end7
end7:
   mov rsp, rbp
   pop rbp
   ret
Stack_$_pop:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rdi, rax
   push rdi
   pop rdi
   call Node_$_getNext
   add rsp, 0
   mov rdi, [rbp - 8]
   mov [rdi + 0], rax
end8:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 8
   call allocateClass
   mov [rbp - 8], rax
   mov rax, 0
   mov [rbp - 16], rax
l0:
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, 10
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l1
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call Stack_$_push
   add rsp, 0
   mov rax, [rbp - 16]
   inc rax
   mov [rbp - 16], rax
   jmp l0
l1:
l2:
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Stack_$_isEmpty
   add rsp, 0
   xor rax, 1
   cmp al, 1
   jne l3
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Stack_$_top
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Stack_$_pop
   add rsp, 0
   jmp l2
l3:
   mov rax, 0
   jmp end9
end9:
   mov rsp, rbp
   pop rbp
   ret
