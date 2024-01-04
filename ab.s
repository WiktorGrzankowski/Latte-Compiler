section .data
   s0 db "", 0
   s1 db "I'm a shape", 0
   s2 db "I'm just a shape", 0
   s4 db "I'm really a circle", 0
   s3 db "I'm really a rectangle", 0
   s5 db "I'm really a square", 0

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
Shape_$_tell:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, s1
   mov rdi, rax
   call printString
end9:
   mov rsp, rbp
   pop rbp
   ret
Shape_$_tellAgain:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, s2
   mov rdi, rax
   call printString
end10:
   mov rsp, rbp
   pop rbp
   ret
Rectangle_$_tellAgain:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, s3
   mov rdi, rax
   call printString
end11:
   mov rsp, rbp
   pop rbp
   ret
Circle_$_tellAgain:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, s4
   mov rdi, rax
   call printString
end12:
   mov rsp, rbp
   pop rbp
   ret
Square_$_tellAgain:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, s5
   mov rdi, rax
   call printString
end13:
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
   mov rdi, 0
   call allocateClass
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call Stack_$_push
   add rsp, 0
   mov rdi, 0
   call allocateClass
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call Stack_$_push
   add rsp, 0
   mov rdi, 0
   call allocateClass
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call Stack_$_push
   add rsp, 0
   mov rdi, 0
   call allocateClass
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call Stack_$_push
   add rsp, 0
l0:
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Stack_$_isEmpty
   add rsp, 0
   xor rax, 1
   cmp al, 1
   jne l1
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Stack_$_top
   add rsp, 0
   mov [rbp - 16], rax
   mov rax, [rbp - 16]
   mov rdi, rax
   push rdi
   pop rdi
   call Shape_$_tell
   add rsp, 0
   mov rax, [rbp - 16]
   mov rdi, rax
   push rdi
   pop rdi
   call Shape_$_tellAgain
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Stack_$_pop
   add rsp, 0
   jmp l0
l1:
   mov rax, 0
   jmp end14
end14:
   mov rsp, rbp
   pop rbp
   ret
