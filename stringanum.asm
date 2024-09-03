assume cs:code, ds:data

data segment
    cr equ 13          ; Retorno de carro
    lf equ 10          ; Salto de linea
    
    numero db "1023.10$", 0  ; Cadena de entrada
    num_int_low  dw 0       ; Parte entera de 16 bits
    num_int_high dw 0       ; Parte decimal de 16 bits  
    current_byte dw 0
    
    search_byte db '.'     ; Punto decimal
data ends
       
       
code segment
    mov ax, data
    mov ds, ax
    mov es, ax

    lea si, numero         ; Carga la direccion de la cadena en SI
    xor ax, ax
    xor dx, dx
    xor bx, bx
    xor cx, cx
    xor di, di
    xor bp, bp             ; Bandera para indicar si se esta procesando la parte decimal (0 = entero, 1 = decimal)

parse_loop:
    lodsb                  ; Carga el byte en [SI] en AL y aumenta SI
    mov ah, 0
    mov [current_byte], ax 
    cmp al, '$'            ; Verifica el fin de la cadena
    je end_parse

    cmp al, [search_byte]  ; Verifica si el caracter es '.'
    je start_decimal

    cmp bp, 0
    je parse_integer
    jne parse_decimal

parse_integer:
    sub al, '0'            ; Convierte ASCII a valor numérico (0-9)
 
    mov ax, num_int_high    ; Carga la parte entera actual
    mov cx, 10             ; Carga el multiplicador
    mul cx                 ; Multiplica AX por 10
    mov num_int_high, ax    ; Almacena el resultado en num_int_high

    mov ax, [current_byte]
    add num_int_high, ax    ; Suma el dígito actual a la parte entera
    jmp parse_loop

start_decimal:
    mov bp, 1              ; Indica que ahora se procesará la parte decimal
    jmp parse_loop

parse_decimal:
    sub al, '0'            ; Convierte ASCII a valor numérico (0-9)

    mov ax, num_int_low   ; Carga la parte decimal actual
    mov cx, 10             ; Carga el multiplicador
    mul cx                 ; Multiplica AX por 10
    mov num_int_low, ax   ; Almacena el resultado en num_int_low

    mov ax, [current_byte]
    add num_int_low, ax   ; Suma el dígito actual a la parte decimal
    jmp parse_loop
    
end_parse:
    ; a partir de aqui se mandan a donde sea

code ends
end
 
