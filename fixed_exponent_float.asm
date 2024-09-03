.data
whole0 dw 5000
float0 dw 0
whole1 dw 0
float1 dw 5000
producth dw 0
productl dw 0
productfloat dw 0
; 9999,9999*9999,9999 = 99999998
; actual output: 5F59ECC,2BB7 => 99983052.1707
; 5000*0.5 = 2500
; actual output: 
carry dw 0
resultah dw 0
resultal dw 0
resultbh dw 0
resultbl dw 0
resultch dw 0
resultcl dw 0
resultdh dw 0
resultdl dw 0

.code

check_carry proc near
    jnc no_increment
    inc carry
    no_increment:
        ret
check_carry endp

mul16 proc near
    ; input: word0h:word0l * word1h:word1l, each 16bit whole 16bit float
    ; output: producth:productl:productfloat, 32bit whole 16bit float
    mov ax, whole0
    mul whole1 ; dx:ax
    mov resultah, dx
    mov resultal, ax
    xor ax, ax
    xor dx, dx
    
    mov ax, whole0
    mul float1
    mov resultbh, dx
    mov resultbl, ax
    xor ax, ax
    xor dx, dx
    
    mov ax, whole1
    mul float0
    mov resultch, dx
    mov resultcl, ax
    xor ax, ax
    xor dx, dx
    
    mov ax, float0
    mul float1
    mov resultdh, dx
    mov resultdl, ax
    xor ax, ax
    xor dx, dx
    
    mov ax, resultdh
    add ax, resultcl
    call check_carry
    clc ; CF = 0
    add ax, resultbl
    call check_carry
    clc
    mov productfloat, ax
    xor ax, ax
        
    mov ax, carry
    mov carry, 0
    add ax, resultch
    call check_carry
    clc
    add ax, resultbh
    call check_carry
    clc
    add ax, resultal
    call check_carry
    clc
    mov productl, ax
    xor ax, ax
    
    mov ax, carry
    add ax, resultah
    mov producth, ax
    
    ; clear variables
    xor ax, ax
    clc
    mov carry, 0
    mov resultah, 0
    mov resultal, 0
    mov resultbh, 0
    mov resultbl, 0
    mov resultch, 0
    mov resultcl, 0
    mov resultdh, 0
    mov resultdl, 0
    
    ret
mul16 endp

start: 
    mov ax, @data
    mov ds, ax

    call mul16

    mov ax, 4c00h
    int 21h

end start