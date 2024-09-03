.data
dw0 dd 999999
dw1 dd 999999
w0 dw 0
w1 dw 0
exp0 db -2
exp1 db -2

.code

mul16 proc near
    

mul16 endp

start: 
    mov ax, @data
    mov ds, ax

    call mul16

    mov ax, 4c00h
    int 21h

end start