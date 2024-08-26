assume cs:code, ds:data

data segment
    cr equ 13      ; carriage return
    lf equ 10      ; line feed for newlines

    numero db "1023.10$", 0  ; Proper null-terminated string
    numeroentero dw 0        ; Holds the integer part
    numerodec dw 0           ; Holds the decimal part
    search_byte db '.'       ; Decimal point for number
    leftdec db 0             ; Bytes read until decimal
    rightdec db 0            ; Bytes read after decimal
data ends

code segment
    assume cs:code, ds:data

    lea si, numero  ; Load address of the string into SI
    xor cx, cx      ; Clear counter (for leftdec)
    xor ax, ax      ; Clear AX
    xor dx, dx      ; Clear DX (integer part accumulator)
    xor bx, bx      ; Clear BX (decimal part accumulator)
    xor di, di      ; Clear DI (decimal multiplier)
    xor bp, bp      ; Clear BP (flag for decimal processing)

read_loop:
    lodsb           ; Load next byte from [SI] into AL
    cmp al, 0       ; End of string check
    je finish       ; If end of string, finish parsing

    cmp al, [search_byte]  ; Check if it's the decimal point
    je found_decimal       ; If yes, switch to decimal parsing

    ; Convert ASCII to number
    sub al, '0'
    ; Integer part processing
    mov ax, 10       ; Move the multiplier 10 into AX
    imul dx          ; Multiply integer accumulator by AX (10)
    add dx, ax       ; Add current digit

    inc cx           ; Increment leftdec counter
    jmp read_loop    ; Continue reading

found_decimal:
    mov [leftdec], cl  ; Save the leftdec count
    mov bp, 1          ; Set BP flag for decimal processing
    mov di, 10         ; Initialize decimal multiplier

decimal_loop:
    lodsb           ; Load next byte from [SI] into AL
    cmp al, 0       ; End of string check
    je finish       ; If end of string, finish parsing

    ; Convert ASCII to number
    sub al, '0'
    ; Decimal part processing
    mov ax, 10      ; ax=10
    imul bx         ; 
    add bx, ax      ; Add to decimal accumulator  

    inc cx          ; Increment rightdec counter
    jmp decimal_loop ; Continue reading


finish:
    ; mul int by 100
    mov ax, 100
    mul dx

    ; Store the final result in the variables 
    mov [numeroentero], dx  ; Store integer part
    mov [numerodec], bx     ; Store decimal part   

    ; Program exit (assuming this is for DOS)
    mov ax, 4C00h
    int 21h

code ends
end