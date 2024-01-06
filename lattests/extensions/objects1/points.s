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
   sub rsp, 24
   mov rax, [rbp - 16]
   mov [rsp + 0], rax
   mov rax, 2
   mov [rsp + 8], rax
   mov rax, 4
   mov [rsp + 16], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   mov rdx, [rsp + 16]
   call Point2_$_move
   add rsp, 24
   sub rsp, 16
   mov rax, [rbp - 16]
   mov [rsp + 0], rax
   mov rax, 7
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call Point3_$_moveZ
   add rsp, 16
   mov rax, [rbp - 16]
   mov [rbp - 8], rax
   sub rsp, 24
   mov rax, [rbp - 8]
   mov [rsp + 0], rax
   mov rax, 3
   mov [rsp + 8], rax
   mov rax, 5
   mov [rsp + 16], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   mov rdx, [rsp + 16]
   call Point2_$_move
   add rsp, 24
   sub rsp, 24
   mov rax, [rbp - 24]
   mov [rsp + 0], rax
   mov rax, 1
   mov [rsp + 8], rax
   mov rax, 3
   mov [rsp + 16], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   mov rdx, [rsp + 16]
   call Point2_$_move
   add rsp, 24
   sub rsp, 16
   mov rax, [rbp - 24]
   mov [rsp + 0], rax
   mov rax, 6
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call Point3_$_moveZ
   add rsp, 16
   sub rsp, 16
   mov rax, [rbp - 24]
   mov [rsp + 0], rax
   mov rax, 2
   mov [rsp + 8], rax
   mov rdi, [rsp + 0]
   mov rsi, [rsp + 8]
   call Point4_$_moveW
   add rsp, 16
   sub rsp, 8
   mov rax, [rbp - 8]
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call Point2_$_getX
   add rsp, 8
   mov rdi, rax
   call printInt
   sub rsp, 8
   mov rax, [rbp - 8]
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call Point2_$_getY
   add rsp, 8
   mov rdi, rax
   call printInt
   sub rsp, 8
   mov rax, [rbp - 16]
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call Point3_$_getZ
   add rsp, 8
   mov rdi, rax
   call printInt
   sub rsp, 8
   mov rax, [rbp - 24]
   mov [rsp + 0], rax
   mov rdi, [rsp + 0]
   call Point4_$_getW
   add rsp, 8
   mov rdi, rax
   call printInt
   mov rax, 0
   jmp end8
end8:
   mov rsp, rbp
   pop rbp
   ret
