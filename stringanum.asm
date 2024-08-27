assume cs:code, ds:data

data segment
    cr equ 13   ; carriage return
    lf equ 10   ; line feed for newlines   
    
    
    numero db "1023.10$", 0  ; Input string
    ; 32bit integer part: num_int_high:num_int_low
    num_int_low  dw 0
    num_int_high dw 0
    ; 32bit decimal part: num_dec_high:num_dec_low
    num_dec_low  dw 0
    num_dec_high dw 0
    search_byte db '.'       ; Decimal point for number
data ends


mov ax, data
; Segmento de datos
mov ds, ax
mov es, ax

lea si, numero          ; Load address of the input string
xor ax, ax
xor dx, dx
xor bx, bx
xor cx, cx
xor di, di
xor bp, bp              ; Flag to indicate decimal part processing (0 = integer, 1 = decimal) 

 
; operaciones posibles 
   
; 32bit(DX:AX)*16bit(BX)   
multiply_32bit_16bit:
    push cx           ; Save registers that will be used
    push bx

    mov cx, ax        ; Copy low part of 32-bit number to CX
    mul bx            ; Multiply AX by BX (result in DX:AX)

    xchg ax, cx       ; Exchange AX and CX to save low result
    mov bx, dx        ; Save high part in BX

    mov ax, dx        ; Get high part of the original number
    mul bx            ; Multiply high part by BX

    add dx, ax        ; Add intermediate result to high part
    add ax, cx        ; Add low part result to AX

    mov dx, bx        ; Move final high part back to DX

    pop bx            ; Restore original registers
    pop cx
    ret               ; Return to caller  

; 32bit(DX:AX)*16bit(BX:CX) = DX:AX:BX:CX (we're cooked)    
multiply_32bit_32bit:
    push si
    push di

    mov si, ax        ; Store AX in SI
    mul cx            ; Multiply AX by CX (AX*CX -> DX:AX)

    mov di, ax        ; Save low part of the result
    mov ax, si        ; Restore AX from SI
    mul bx            ; Multiply AX by BX (AX*BX -> DX:AX)
    add ax, dx        ; Add the high part from previous result

    ; Now AX contains the low 16 bits, DX the high 16 bits
    mov si, dx        ; Store this part in SI
    mov ax, di        ; Restore DI (low part of AX*CX result)

    mul cx            ; Multiply AX by CX (AX*CX -> DX:AX)
    add di, ax        ; Add low part of result to DI
    adc si, dx        ; Add high part with carry

    mov cx, di        ; Save low result in CX
    mov bx, si        ; Save high result in BX

    ; Now, multiply high parts DX by BX
    mov ax, dx
    mul bx
    add dx, ax        ; Combine results

    pop di
    pop si
    ret
    
; 32bit(DX:AX)+32bitBX:CX) 
add_32bit:
    add ax, cx        ; Add low parts
    adc dx, bx        ; Add high parts with carry
    ret               ; Return to caller  
    
; 32bit(DX:AX)/32bitBX) = AX Quotient DX Remainder   
divide_32bit_16bit:
    push cx           ; Save registers
    push bx

    mov cx, dx        ; Move high part to CX
    xor dx, dx        ; Clear DX

    div bx            ; Divide high part by BX (AX = CX/BX, DX = remainder)
    mov si, ax        ; Save the partial quotient in SI
    mov ax, cx        ; Restore AX

    mul bx            ; Multiply quotient by BX
    sub ax, cx        ; Subtract from the original high part
    adc dx, 0         ; Adjust with carry

    mov ax, si        ; Restore partial quotient
    div bx            ; Divide by BX to get the full quotient
    ; Now, AX contains the quotient and DX the remainder

    pop bx            ; Restore registers
    pop cx
    ret
 
 
 
parse_loop:
    lodsb                   ; Load byte at [SI] into AL and increment SI
    cmp al, '$'             ; Check for string termination
    je end_parse

    cmp al, [search_byte]   ; Check if character is '.'
    je start_decimal

    cmp bp, 0
    je parse_integer
    jne parse_decimal
    
    
    
parse_integer:
    ; Convert ASCII digit to binary
    sub al, '0'             ; Convert ASCII to numerical value (0-9)

    ; Multiply current integer value by 10
    ; [num_int_high:num_int_low] = [num_int_high:num_int_low] * 10 + al

    ; Multiply low part by 10
    mov bx, num_int_low
    mov cx, 10
    mul cx                  ; DX:AX = BX * 10
    ; AX = lower 16 bits, DX = upper 16 bits

    ; Add the result to current high and low 
    
    mov num_int_low, ax     ; Store new low part
    mov ax, num_int_high
    add ax, dx              ; Add carry to high part
    adc ax, 0               ; Add overflow if any
    mov num_int_high, ax    ; Store new high part

    ; Add current digit al to low part
    mov ax, num_int_low
    add ax, al              ; Add digit
    adc num_int_high, 0     ; Handle carry
    mov num_int_low, ax     ; Store result

    jmp parse_loop   
    
start_decimal:
    mov bp, 1               ; Set flag to indicate decimal part processing
    jmp parse_loop

parse_decimal:
    ; Convert ASCII digit to binary
    sub al, '0'             ; Convert ASCII to numerical value (0-9)

    ; Multiply current decimal value by 10
    ; We perform: [num_dec_high:num_dec_low] = [num_dec_high:num_dec_low] * 10 + al

    ; Multiply low part by 10
    mov bx, num_dec_low
    mov cx, 10
    mul cx                  ; DX:AX = BX * 10
    ; AX = lower 16 bits, DX = upper 16 bits

    ; Add the result to current high and low
    mov num_dec_low, ax     ; Store new low part
    mov ax, num_dec_high
    add ax, dx              ; Add carry to high part
    adc ax, 0               ; Add overflow if any
    mov num_dec_high, ax    ; Store new high part

    ; Add current digit al to low part
    mov ax, num_dec_low
    add ax, al              ; Add digit
    adc num_dec_high, 0     ; Handle carry
    mov num_dec_low, ax     ; Store result

    jmp parse_loop         
    

end_parse:
    ; Example: Multiply integer part by 100
    mov ax, num_int_low    ; Load the low part of the 32bit number into AX
    mov dx, num_int_high   ; Load the high part into DX
    mov bx, 100            ; Load the multiplier into BX
    call multiply_32bit_16bit  ; Perform the multiplication

    ; Store the result back
    mov num_int_low, ax
    mov num_int_high, dx

    ; (Further processing here)




code ends
end