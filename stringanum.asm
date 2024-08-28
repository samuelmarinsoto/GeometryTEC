assume cs:code, ds:data

data segment
    cr equ 13          ; Carriage return
    lf equ 10          ; Line feed for newlines
    
    numero db "1023.10$", 0  ; Input string
    num_int_low  dw 0       ; 16-bit integer part
    num_int_high dw 0       ; 16-bit decimal part  
    current_byte dw 0
    
    search_byte db '.'     ; Decimal point for number
data ends
       
       
code segment
    mov ax, data
    mov ds, ax
    mov es, ax

    lea si, numero         ; Load address of the input string
    xor ax, ax
    xor dx, dx
    xor bx, bx
    xor cx, cx
    xor di, di
    xor bp, bp             ; Flag to indicate decimal part processing (0 = integer, 1 = decimal)

parse_loop:
    lodsb                  ; Load byte at [SI] into AL and increment SI
    mov ah, 0
    mov [current_byte], ax 
    cmp al, '$'            ; Check for string termination
    je end_parse

    cmp al, [search_byte]  ; Check if character is '.'
    je start_decimal

    cmp bp, 0
    je parse_integer
    jne parse_decimal

parse_integer:
    ; Convert ASCII digit to binary
    sub al, '0'            ; Convert ASCII to numerical value (0-9)
 
    ; Multiply current integer value by 10
    mov ax, num_int_high    ; Load current integer part
    mov cx, 10             ; Load multiplier
    mul cx                 ; Multiply AX by 10
    mov num_int_high, ax    ; Store result in num_int_low

    ; Add current digit  
    mov ax, [current_byte]
    add num_int_high, ax    ; Add the current digit to the integer part
    jmp parse_loop

start_decimal:
    mov bp, 1              ; Set flag to indicate decimal part processing
    jmp parse_loop

parse_decimal:
    ; Convert ASCII digit to binary
    sub al, '0'            ; Convert ASCII to numerical value (0-9)

    ; Multiply current decimal value by 10
    mov ax, num_int_low   ; Load current decimal part
    mov cx, 10             ; Load multiplier
    mul cx                 ; Multiply AX by 10
    mov num_int_low, ax   ; Store result in num_int_high

    ; Add current digit  
    mov ax, [current_byte]
    add num_int_low, ax   ; Add the current digit to the decimal part
    jmp parse_loop
    
end_parse:
    ; Further processing here
    ; a partir de aqui se mandan a donde sea

code ends
end
 
;; operaciones posibles 
;   
;add_32bit:
;    ; Add the lower 16 bits (decimal)
;    mov ax, [num1_low]       ; Load decimal part of num1 into AX
;    add ax, [num2_low]       ; Add decimal part of num2
;    mov [result_low], ax     ; Store result in the decimal part
;
;    ; Handle carry for upper 16 bits (integer)
;    mov ax, [num1_high]      ; Load integer part of num1 into AX
;    adc ax, [num2_high]      ; Add integer part of num2 and carry from the decimal addition
;    mov [result_high], ax    ; Store result in the integer part
;
;    ret
;    
;add_16bit_to_32bit:
;    ; Case 1: Adding 16-bit integer to 32-bit number
;    mov ax, [num1_high]        ; Load high 16 bits (integer) of the 32-bit number
;    add ax, [num2_16bit]       ; Add the 16-bit integer
;    mov [result_high], ax      ; Store result in high part
;    
;    ; The decimal part remains unchanged
;    mov ax, [num1_low]         ; Load the low 16 bits (decimal) of the 32-bit number
;    mov [result_low], ax       ; Store the same decimal part
;    
;    ret
;
;add_16bit_decimal_to_32bit:
;    ; Case 2: Adding 16-bit decimal to 32-bit number
;    mov ax, [num1_low]         ; Load low 16 bits (decimal) of the 32-bit number
;    add ax, [num2_16bit]       ; Add the 16-bit decimal
;    mov [result_low], ax       ; Store result in low part
;
;    ; Handle carry for the integer part
;    mov ax, [num1_high]        ; Load high 16 bits (integer) of the 32-bit number
;    adc ax, 0                  ; Add carry if there is one
;    mov [result_high], ax      ; Store result in high part
;
;    ret 

     
; multiply_32bit_16bit:
;    ; Multiply 32-bit number (num_high:num_low) by 16-bit number (num_16bit)
;    push cx                     ; Save CX
;    mov cx, [num_low]           ; Load low 16 bits into CX
;    mul word ptr [num_16bit]    ; Multiply low part by 16-bit number (result in DX:AX)
;    mov [temp_low], ax          ; Store low result temporarily
;    mov [temp_high], dx         ; Store high result temporarily
;
;    mov ax, [num_high]          ; Load high 16 bits into AX
;    mul word ptr [num_16bit]    ; Multiply high part by 16-bit number
;    add dx, ax                  ; Add intermediate result to high part
;    add ax, [temp_low]          ; Add low part result to AX
;    mov [result_low], ax        ; Store final low result
;    mov [result_high], dx       ; Store final high result
;    pop cx                      ; Restore CX
;    ret
       
; multiply_32bit_32bit:
;    ; Multiply 32-bit number (num1_high:num1_low) by another 32-bit number (num2_high:num2_low)
;    push si                     ; Save SI
;    push di                     ; Save DI
;
;    mov si, [num1_low]          ; Load low 16 bits of num1 into SI
;    mul word ptr [num2_low]     ; Multiply low parts (result in DX:AX)
;    mov [temp_low], ax          ; Store low result temporarily
;    mov [temp_high], dx         ; Store high result temporarily
;
;    mov ax, [num1_high]         ; Load high 16 bits of num1 into AX
;    mul word ptr [num2_low]     ; Multiply high part of num1 by low part of num2
;    add ax, [temp_high]         ; Add high result to intermediate result
;    adc dx, 0                   ; Add carry if any
;
;    mov [temp_high], dx         ; Store intermediate high result in temp_high
;    mov [temp_low], ax          ; Store intermediate low result in temp_low
;
;    mov ax, [num1_low]          ; Restore original low part
;    mul word ptr [num2_high]    ; Multiply low part by high part of num2
;    add ax, [temp_low]          ; Add low result to previous result
;    adc dx, [temp_high]         ; Add carry and high result
;    mov [result_low], ax        ; Store final low result
;    mov [result_high], dx       ; Store final high result
;
;    pop di                      ; Restore DI
;    pop si                      ; Restore SI
;    ret

; divide_32bit_16bit:
;    ; Divide 32-bit number (num_high:num_low) by 16-bit number (num_16bit)
;    push cx                     ; Save CX
;    mov cx, [num_high]          ; Load high 16 bits into CX
;    xor dx, dx                  ; Clear DX for division
;
;    div word ptr [num_16bit]    ; Divide high part by 16-bit number (result in AX, remainder in DX)
;    mov [temp_quotient], ax     ; Store quotient temporarily
;    mov ax, [num_low]           ; Load low 16 bits into AX
;
;    mul word ptr [num_16bit]    ; Multiply quotient by divisor
;    sub ax, cx                  ; Subtract high part result from low part
;    adc dx, 0                   ; Adjust with carry if needed
;
;    mov ax, [temp_quotient]     ; Restore quotient
;    div word ptr [num_16bit]    ; Divide by divisor to get final quotient
;    mov [result_quotient], ax   ; Store final quotient
;    mov [result_remainder], dx  ; Store remainder
;
;    pop cx                      ; Restore CX
;    ret

