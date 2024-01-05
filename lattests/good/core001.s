section .data
   s0 db "", 0
   s3 db "/* world", 0
   s1 db "=", 0
   s2 db "hello */", 0

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
   sub rsp, 32
   mov rax, 10
   mov rdi, rax
   push rdi
   pop rdi
   call fac
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 10
   mov rdi, rax
   push rdi
   pop rdi
   call rfac
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 10
   mov rdi, rax
   push rdi
   pop rdi
   call mfac
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, 10
   mov rdi, rax
   push rdi
   pop rdi
   call ifac
   add rsp, 0
   mov rdi, rax
   call printInt
   mov rax, s0
   mov [rbp - 8], rax
   mov rax, 10
   mov [rbp - 16], rax
   mov rax, 1
   mov [rbp - 24], rax
l0:
   mov rax, [rbp - 16]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l1
   mov rax, [rbp - 24]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov [rbp - 24], rax
   mov rax, [rbp - 16]
   dec rax
   mov [rbp - 16], rax
   jmp l0
l1:
   mov rax, [rbp - 24]
   mov rdi, rax
   call printInt
   mov rax, s1
   mov rdi, rax
   push rdi
   mov rax, 60
   mov rsi, rax
   pop rdi
   call repStr
   add rsp, 0
   mov rdi, rax
   call printString
   mov rax, s2
   mov rdi, rax
   call printString
   mov rax, s3
   mov rdi, rax
   call printString
   mov rax, 0
   jmp end1
end1:
   mov rsp, rbp
   pop rbp
   ret
fac:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov rax, 0
   mov [rbp - 16], rax
   mov rax, 0
   mov [rbp - 24], rax
   mov rax, 1
   mov [rbp - 16], rax
   mov rax, [rbp - 8]
   mov [rbp - 24], rax
l2:
   mov rax, [rbp - 24]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l3
   mov rax, [rbp - 16]
   push rax
   mov rax, [rbp - 24]
   mov rdx, rax
   pop rax
   imul rax, rdx
   mov [rbp - 16], rax
   mov rax, [rbp - 24]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov [rbp - 24], rax
   jmp l2
l3:
   mov rax, [rbp - 16]
   jmp end2
end2:
   mov rsp, rbp
   pop rbp
   ret
rfac:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   cmp al, 1
   jne l4
   mov rax, 1
   jmp end3
   jmp l5
l4:
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 8]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdi, rax
   push rdi
   pop rdi
   call rfac
   add rsp, 0
   mov rdx, rax
   pop rax
   imul rax, rdx
   jmp end3
l5:
end3:
   mov rsp, rbp
   pop rbp
   ret
mfac:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   cmp al, 1
   jne l6
   mov rax, 1
   jmp end4
   jmp l7
l6:
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 8]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdi, rax
   push rdi
   pop rdi
   call nfac
   add rsp, 0
   mov rdx, rax
   pop rax
   imul rax, rdx
   jmp end4
l7:
end4:
   mov rsp, rbp
   pop rbp
   ret
nfac:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, 0
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setne al
   cmp al, 1
   jne l8
   mov rax, [rbp - 8]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   sub rax, rdx
   mov rdi, rax
   push rdi
   pop rdi
   call mfac
   add rsp, 0
   push rax
   mov rax, [rbp - 8]
   mov rdx, rax
   pop rax
   imul rax, rdx
   jmp end5
   jmp l9
l8:
   mov rax, 1
   jmp end5
l9:
end5:
   mov rsp, rbp
   pop rbp
   ret
ifac:
   push rbp
   mov rbp, rsp
   sub rsp, 16
   mov [rbp - 8], rdi
   mov rax, 1
   mov rdi, rax
   push rdi
   mov rax, [rbp - 8]
   mov rsi, rax
   pop rdi
   call ifac2f
   add rsp, 0
   jmp end6
end6:
   mov rsp, rbp
   pop rbp
   ret
ifac2f:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 16]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   sete al
   cmp al, 1
   jne l10
   mov rax, [rbp - 8]
   jmp end7
l10:
   mov rax, [rbp - 8]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 16]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setg al
   cmp al, 1
   jne l11
   mov rax, 1
   jmp end7
l11:
   mov rax, 0
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   push rax
   mov rax, [rbp - 16]
   mov rdx, rax
   pop rax
   add rax, rdx
   push rax
   mov rax, 2
   mov rcx, rax
   xor rdx, rdx
   pop rax
   cqo
   idiv rcx
   mov [rbp - 24], rax
   mov rax, [rbp - 8]
   mov rdi, rax
   push rdi
   mov rax, [rbp - 24]
   mov rsi, rax
   pop rdi
   call ifac2f
   add rsp, 0
   push rax
   mov rax, [rbp - 24]
   push rax
   mov rax, 1
   mov rdx, rax
   pop rax
   add rax, rdx
   mov rdi, rax
   push rdi
   mov rax, [rbp - 16]
   mov rsi, rax
   pop rdi
   call ifac2f
   add rsp, 0
   mov rdx, rax
   pop rax
   imul rax, rdx
   jmp end7
end7:
   mov rsp, rbp
   pop rbp
   ret
repStr:
   push rbp
   mov rbp, rsp
   sub rsp, 32
   mov [rbp - 8], rdi
   mov [rbp - 16], rsi
   mov rax, s0
   mov [rbp - 24], rax
   mov rax, 0
   mov [rbp - 32], rax
l12:
   mov rax, [rbp - 32]
   mov rdx, rax
   push rdx
   mov rax, [rbp - 16]
   mov rcx, rax
   pop rdx
   xor rax, rax
   cmp rdx, rcx
   setl al
   cmp al, 1
   jne l13
   mov rax, [rbp - 24]
   push rax
   mov rax, [rbp - 8]
   mov rsi, rax
   pop rax
   mov rdi, rax
   call concat
   mov [rbp - 24], rax
   mov rax, [rbp - 32]
   inc rax
   mov [rbp - 32], rax
   jmp l12
l13:
   mov rax, [rbp - 24]
   jmp end8
end8:
   mov rsp, rbp
   pop rbp
   ret
