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
   
add_32bit:
    ; Add the lower 16 bits (decimal)
    mov ax, [num1_low]       ; Load decimal part of num1 into AX
    add ax, [num2_low]       ; Add decimal part of num2
    mov [result_low], ax     ; Store result in the decimal part

    ; Handle carry for upper 16 bits (integer)
    mov ax, [num1_high]      ; Load integer part of num1 into AX
    adc ax, [num2_high]      ; Add integer part of num2 and carry from the decimal addition
    mov [result_high], ax    ; Store result in the integer part

    ret
    
add_16bit_to_32bit:
    ; Case 1: Adding 16-bit integer to 32-bit number
    mov ax, [num1_high]        ; Load high 16 bits (integer) of the 32-bit number
    add ax, [num2_16bit]       ; Add the 16-bit integer
    mov [result_high], ax      ; Store result in high part
    
    ; The decimal part remains unchanged
    mov ax, [num1_low]         ; Load the low 16 bits (decimal) of the 32-bit number
    mov [result_low], ax       ; Store the same decimal part
    
    ret

add_16bit_decimal_to_32bit:
    ; Case 2: Adding 16-bit decimal to 32-bit number
    mov ax, [num1_low]         ; Load low 16 bits (decimal) of the 32-bit number
    add ax, [num2_16bit]       ; Add the 16-bit decimal
    mov [result_low], ax       ; Store result in low part

    ; Handle carry for the integer part
    mov ax, [num1_high]        ; Load high 16 bits (integer) of the 32-bit number
    adc ax, 0                  ; Add carry if there is one
    mov [result_high], ax      ; Store result in high part

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
    ; We perform: num_int_high = num_int_high * 10 + al

    ; Multiply high part by 10
    mov ax, num_int_high    ; Load current integer part
    mov cx, 10              ; Load multiplier
    mul cx                  ; Multiply AX by 10, result in DX:AX
    add ax, num_int_high    ; Add carry to integer part
    adc dx, 0               ; Handle carry if necessary
    mov num_int_high, ax    ; Store result

    ; Add current digit
    add num_int_high, al    ; Add the current digit to the integer part
    adc dx, 0               ; Handle overflow if any
    mov num_int_high, ax    ; Store result in num_int_high

    jmp parse_loop
    
start_decimal:
    mov bp, 1               ; Set flag to indicate decimal part processing
    jmp parse_loop

parse_decimal:
    ; Convert ASCII digit to binary
    sub al, '0'             ; Convert ASCII to numerical value (0-9)

    ; Multiply current decimal value by 10
    ; We perform: num_int_low = num_int_low * 10 + al

    ; Multiply low part by 10
    mov ax, num_int_low     ; Load current decimal part
    mov cx, 10              ; Load multiplier
    mul cx                  ; Multiply AX by 10, result in DX:AX
    add ax, num_int_low     ; Add carry to decimal part
    adc dx, 0               ; Handle carry if necessary
    mov num_int_low, ax     ; Store result

    ; Add current digit
    add num_int_low, al     ; Add the current digit to the decimal part
    adc dx, 0               ; Handle overflow if any
    mov num_int_low, ax     ; Store result in num_int_low

    jmp parse_loop     
    

end_parse:

    ; (Further processing here)   
    a partir de aqui se mandan a donde sea




code ends
end