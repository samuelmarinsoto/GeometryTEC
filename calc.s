assume cs:code, ds:data

data segment

cr equ 13d ; carriage return y
lf equ 10d ; line feed, para newlines

input db 20 DUP (?)

bienvenida db "Bienvenido a GeometryTEC, una herramienta para calcular areas y perimetros de figuras$",cr,lf
opciones db "Por favor, digite el numero al lado de la figura a calcular:",cr,lf,"1) Cuadrado",cr,lf,"2) Rectangulo",cr,lf,"3) Triangulo (equilatero)",cr,lf,"4) Rombo",cr,lf,"5) Pentagono",cr,lf,"6) Hexagono",cr,lf,"7) Circulo",cr,lf,"8) Trapezio",cr,lf,"9) Paralelogramo$",cr,lf,cr,lf
area db "Area: $",cr,lf
perimetro db "Perimetro: $",cr,lf
novalido db "Entrada debe ser numero entre 0 y 9999,99$",cr,lf
opcionmala db "Opcion no disponible$",cr,lf
seguirosalir db "Continuar con otro calculo, o salir?$",cr,lf
continuar db "1) Continuar$",cr,lf
salir db "2) Salir$",cr,lf

data ends

; macros
dsp macro msg
	mov ah, 09h
	lea dx, msg
	int 21h
endm


code segment
;procedures
get_input proc near
	mov ah, 01h
	int 21h
	ret
get_input endp

get_buffer proc near
	lea dx, input
	mov ah, 0ah
	int 21h
	ret
get_buffer endp

; Validates input: checks if the input is a positive number
validate_input proc
    lea si, input + 2  ; Skip length byte and return code
    mov cl, 0              ; Counter for digits
validate_loop:
    lodsb                  ; load byte from string
    cmp al, '0'
    jb invalid_input       ; jump if less than '0'
    cmp al, '9'
    ja invalid_input       ; jump if greater than '9'
    cmp al, '.'
    je check_decimal       ; jump if decimal point
    inc cl                 ; count valid characters
    jmp validate_loop      ; continue loop
check_decimal:
    ; check if there is more than one decimal point
    lodsb
    cmp al, '.'            ; compare it with '.'
    je invalid_input       ; jump if it's another decimal point
    jmp validate_loop      ; continue loop
invalid_input:
    ; display error message
	dsp novalido
    jmp ask              ; restart input process
validate_input endp

start:
	; init DS
	mov ax, data
	mov ds, ax
	
	dsp bienvenida

ask:
	dsp opciones
	call get_input

	cmp al, '1'
	jz cuadrado
	cmp al, '2'
	jz rectangulo
	cmp al, '3'
	jz triangulo
	cmp al, '4'
	jz rombo
	cmp al, '5'
	jz pentagono
	cmp al, '6'
	jz hexagono
	cmp al, '7'
	jz circulo
	cmp al, '8'
	jz trapezio
	cmp al, '9'
	jz paralelogramo

	; si entrada invalida
	dsp opcionmala
	jmp ask

cuadrado:
	call get_buffer
	call validate_input
	
rectangulo:
triangulo:
rombo:
pentagono:
hexagono:
circulo:
trapezio:
paralelogramo:

exit:
	mov ax, 4ch
	int 21h

code ends

end start
