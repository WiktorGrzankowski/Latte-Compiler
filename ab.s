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
IntQueue_$_isEmpty:
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
   jmp end5
end5:
   mov rsp, rbp
   pop rbp
   ret
IntQueue_$_insert:
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
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call IntQueue_$_isEmpty
   add rsp, 0
   cmp al, 1
   jne l0
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rax, [rbp - 24]
   mov rdi, [rbp - 8]
   mov [rdi + 0], rax
   jmp l1
l0:
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 24]
   mov rsi, rax
   pop rdi
   call Node_$_setNext
   add rsp, 0
l1:
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   mov rax, [rbp - 24]
   mov rdi, [rbp - 8]
   mov [rdi + 8], rax
end6:
   mov rsp, rbp
   pop rbp
   ret
IntQueue_$_first:
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
IntQueue_$_rmFirst:
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
IntQueue_$_size:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov [rbp - 16], rax
   mov rax, 0
   mov [rbp - 24], rax
l2:
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setne al
   cmp al, 1
   jne l3
   mov rax, [rbp - 16]
   mov rdi, rax
   push rdi
   pop rdi
   call Node_$_getNext
   add rsp, 0
   mov [rbp - 16], rax
   mov rax, [rbp - 24]
   inc rax
   mov [rbp - 24], rax
   jmp l2
l3:
   mov rax, [rbp - 24]
   jmp end9
end9:
   mov rsp, rbp
   pop rbp
   ret
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
   jmp end10
end10:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov rdi, 16
   call allocateClass
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, 3
   mov rdi, rax
   push rdi
   pop rdi
   call f
   add rsp, 0
   mov rsi, rax
   pop rdi
   call IntQueue_$_insert
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, 5
   mov rsi, rax
   pop rdi
   call IntQueue_$_insert
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, 7
   mov rsi, rax
   pop rdi
   call IntQueue_$_insert
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call IntQueue_$_first
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call IntQueue_$_rmFirst
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call IntQueue_$_size
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end11
end11:
   mov rsp, rbp
   pop rbp
   ret
