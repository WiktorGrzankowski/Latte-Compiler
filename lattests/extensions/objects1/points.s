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
Point2_$_move:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov [rbp - 24], rdx
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, [rbp - 8]
   mov [rdi + 0], rax
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   push rax
   mov rax, [rbp - 24]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, [rbp - 8]
   mov [rdi + 8], rax
end1:
   mov rsp, rbp
   pop rbp
   ret
Point2_$_getX:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 0]
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
Point2_$_getY:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 8]
   jmp end3
end3:
   mov rsp, rbp
   pop rbp
   ret
Point3_$_moveZ:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   mov rax, [rax + 16]
   mov rax, [rbp - 8]
   mov rax, [rax + 16]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, [rbp - 8]
   mov [rdi + 16], rax
end4:
   mov rsp, rbp
   pop rbp
   ret
Point3_$_getZ:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 16]
   jmp end5
end5:
   mov rsp, rbp
   pop rbp
   ret
Point4_$_moveW:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   mov rax, [rax + 24]
   mov rax, [rbp - 8]
   mov rax, [rax + 24]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, [rbp - 8]
   mov [rdi + 24], rax
end6:
   mov rsp, rbp
   pop rbp
   ret
Point4_$_getW:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rax, [rax + 24]
   jmp end7
end7:
   mov rsp, rbp
   pop rbp
   ret
main:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov rdi, 24
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 8], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 16], r12
   pop r12
   mov [rbp - 8], rax
   mov rdi, 24
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 8], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 16], r12
   pop r12
   mov [rbp - 16], rax
   mov rdi, 32
   call allocateClass
   push r12
   mov r12, 0
   mov [rax + 24], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 0], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 8], r12
   pop r12
   push r12
   mov r12, 0
   mov [rax + 16], r12
   pop r12
   mov [rbp - 24], rax
   mov rax, [rbp - 16]
   mov rdi, rax
   push rdi
   mov rax, 2
   mov rsi, rax
   mov rax, 4
   mov rdx, rax
   pop rdi
   call Point2_$_move
   add rsp, 0
   mov rax, [rbp - 16]
   mov rdi, rax
   push rdi
   mov rax, 7
   mov rsi, rax
   pop rdi
   call Point3_$_moveZ
   add rsp, 0
   mov rax, [rbp - 16]
   mov [rbp - 8], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, 3
   mov rsi, rax
   mov rax, 5
   mov rdx, rax
   pop rdi
   call Point2_$_move
   add rsp, 0
   mov rax, [rbp - 24]
   mov rdi, rax
   push rdi
   mov rax, 1
   mov rsi, rax
   mov rax, 3
   mov rdx, rax
   pop rdi
   call Point2_$_move
   add rsp, 0
   mov rax, [rbp - 24]
   mov rdi, rax
   push rdi
   mov rax, 6
   mov rsi, rax
   pop rdi
   call Point3_$_moveZ
   add rsp, 0
   mov rax, [rbp - 24]
   mov rdi, rax
   push rdi
   mov rax, 2
   mov rsi, rax
   pop rdi
   call Point4_$_moveW
   add rsp, 0
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Point2_$_getX
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   pop rdi
   call Point2_$_getY
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, [rbp - 16]
   mov rdi, rax
   push rdi
   pop rdi
   call Point3_$_getZ
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, [rbp - 24]
   mov rdi, rax
   push rdi
   pop rdi
   call Point4_$_getW
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end8
end8:
   mov rsp, rbp
   pop rbp
   ret
