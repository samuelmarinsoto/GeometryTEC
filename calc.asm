assume cs:code, ds:data

data segment

cr equ 13d ; carriage return (devolverse a izquierda)
lf equ 10d ; line feed (bajar)

;buffersize + return(bytes read)
;+80 bytes (79 free bytes + null terminator)
buffer db 80,?, 80 dup ('?')

bienvenida db "Bienvenido a GeometryTEC, una herramienta para calcular areas y perimetros de figuras",lf,cr,"$"
opciones db "Por favor, digite el numero al lado de la figura a calcular:",cr,lf,"1) Cuadrado",cr,lf,"2) Rectangulo",cr,lf,"3) Triangulo (equilatero)",cr,lf,"4) Rombo",cr,lf,"5) Pentagono",cr,lf,"6) Hexagono",cr,lf,"7) Circulo",cr,lf,"8) Trapezio",cr,lf,"9) Paralelogramo",cr,lf,"Seleccion: ","$"
lado db lf,cr,"Lado: ","$"               
base db lf,cr,"Base: ","$"
altura db lf,cr,"Altura: ","$"
area db "Area: ","$"
perimetro db "Perimetro: ","$"
novalido db cr,lf,"Entrada debe ser numero entre 0 y 9999,99",cr,lf,"$"
opcionmala db cr,lf,"Opcion no disponible",cr,lf,"$"
seguirosalir db "Continuar con otro calculo, o salir?",cr,lf,"$"
continuar db "1) Continuar",cr,lf,"$"
salir db "2) Salir",cr,lf,"$"

data ends

; macros
dsp macro msg
	lea dx, msg
	call myprint
endm

code segment
;procedures
myprint proc near
    mov ah, 09h
    int 21h
    ret
myprint endp

get_input proc near
	mov ah, 01h
	int 21h
	ret
get_input endp

get_buffer proc near
    lea dx, buffer
    mov ah, 0ah     ; DOS function to read input
	int 21h
	
	; insert null terminator at end of bytes read
	mov bx, 0
	mov bl, buffer[1]
	mov buffer[bx+2], '$'
	ret
get_buffer endp

; Validates input: checks if the input is a positive number
validate_input proc
    lea si, buffer+2  ; Skip length byte and return code
    mov cl, 0              ; Counter for digits
validate_loop:
    lodsb                  ; load byte from string
    cmp al, '$'
    jz validated_input     ; if null terminator, validated
    cmp al, '.'
    je check_decimal       ; jump if decimal point
    cmp al, '0'
    jb invalid_input       ; jump if less than '0'
    cmp al, '9'
    ja invalid_input       ; jump if greater than '9'
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
validated_input:
    ret
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
	; p = 4*lado
	; a = lado*lado
    dsp lado
    call get_buffer
    ;call validate_input
    dsp buffer

rectangulo:
	; p = 2*base + 2*altura
	; a = base*altura
triangulo:
	; p = 3*l
	; a = sqrt(3)*lado*lado/2
rombo:
	; p = 4*lado
	; a = diag1*diag2/2
pentagono:
	; p = 5*lado
	; a = 5*lado*apotema/2
hexagono:
	; p = 6*lado
	; a = 3*lado*apotema
circulo:
	; p = 2*pi*r
	; a = pi*r*r
trapezio:
	; p = b_mayor+b_menor+2*lado
	; a = (b_mayor + b_menor)*altura/2
paralelogramo:
	; p = 2*base+2*lado
	; a = base*altura

exit:
	mov ax, 4ch
	int 21h

code ends

end start
