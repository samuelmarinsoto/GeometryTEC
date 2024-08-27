assume cs:code, ds:data

data segment

cr equ 13d ; carriage return (devolverse a izquierda)
lf equ 10d ; line feed (bajar)

;buffersize + return(bytes read)
;+80 bytes (79 free bytes + null terminator)
buffer db 80,?, 80 dup ('?')
lado_input db 10 dup('$')

bienvenida db "Bienvenido a GeometryTEC, una herramienta para calcular areas y perimetros de figuras","$"
opciones db lf,cr,"Por favor, digite el numero al lado de la figura a calcular:",cr,lf,"1) Cuadrado",cr,lf,"2) Rectangulo",cr,lf,"3) Triangulo (equilatero)",cr,lf,"4) Rombo",cr,lf,"5) Pentagono",cr,lf,"6) Hexagono",cr,lf,"7) Circulo",cr,lf,"8) Trapezio",cr,lf,"9) Paralelogramo",cr,lf,"Seleccion: ","$"
seguirosalir db cr,lf,"Calculo exitoso. Continuar con otro calculo, o salir?",cr,lf,"1) Continuar",cr,lf,"2) Salir",cr,lf,"Seleccion: ","$"

lado db lf,cr,"Lado: ","$"               
base db lf,cr,"Base: ","$"
altura db lf,cr,"Altura: ","$"
area db lf,cr,"Area: ","$"
perimetro db lf,cr,"Perimetro: ","$"

novalido db cr,lf,"Entrada debe ser numero entre 0 y 9999,99",cr,lf,"$"
opcionmala db cr,lf,"Opcion no disponible",cr,lf,"$"

ladonum dw 0
perimetronum dw 0
areanum dw 0

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

StringANum proc
	push bx
	push cx
	push dx
	push si

	mov si, dx
	xor ax, ax
	mov bx, 10

BCadNumPos:
	mov cl, [si]
	cmp cl, 13
	je finStringANum
	cmp cl, '$'
	je finStringANum

	mul bx
	sub cl, '0'
	add ax, cx
	inc si
	jmp BCadNumPos

finStringANum:
	pop si
	pop dx
	pop cx
	pop bx
	ret
StringANum endp

NumAString proc
	push ax
	push bx
	push cx
	push dx
	push di
	mov bx, 10
	mov di, dx
	xor cx, cx
	cmp ax, 0  ; Caso en el que es cero
	je CasoCero

BNumCadPos:
	xor dx, dx
	div bx
	add dl, '0'
	push dx
	inc cx
	cmp ax, 0
	jne BNumCadPos

CasoCero:
	cmp cx, 0
	je ImprimirCero
	
BInvertirPos:
	pop [di]
	inc di
	loop BInvertirPos
	
	mov byte ptr [di], '$'
	
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
ImprimirCero:
    	mov byte ptr [di], '0'
    	inc di
    	mov byte ptr [di], '$'
    	pop di
    	pop dx
    	pop cx
    	pop bx
    	pop ax
    	ret
NumAString endp

start:
	; init DS
	mov ax, data
	mov ds, ax
	
	dsp bienvenida

ask:
	dsp opciones
	call get_input

	cmp al, '1'
	jz near cuadrado
	cmp al, '2'
	jz near rectangulo
	cmp al, '3'
	jz near triangulo
	cmp al, '4'
	jz near rombo
	cmp al, '5'
	jz near pentagono
	cmp al, '6'
	jz near hexagono
	cmp al, '7'
	jz near circulo
	cmp al, '8'
	jz near trapezio
	cmp al, '9'
	jz near paralelogramo

	; si entrada invalida
	dsp opcionmala
	jmp near ask

cuadrado:
	; p = 4*lado
	; a = lado*lado
	
    ; Reinicia las variables a usar
	mov [ladonum], 0
	mov [perimetronum], 0
	mov [areanum], 0

	; Pide el lado
	dsp lado

	; Lectura del string del lado recibido
	call get_buffer
	call validate_input
	lea dx, buffer+2        ; buffer+2 skips the length byte and return code
	call StringANum
	mov [ladonum], ax

	; Calculo del perimetro del cuadrado
	mov ax, [ladonum]
	mov bx, 4
	mul bx
	mov [perimetronum], ax

	; Calculo del area del cuadrado
	mov ax, [ladonum]
	mul [ladonum]
	mov [areanum], ax

	; Impresion del perimetro
	dsp perimetro
	; Convierte el perimetro a string y lo imprime
	mov ax, [perimetronum]
	lea dx, lado_input 
	call NumAString
	dsp lado_input

	; Impresion del area
	dsp area
	; Convierte el area a string y lo imprime
	mov ax, [areanum]
	lea dx, lado_input 
	call NumAString
	dsp lado_input

	jmp near confirmar_salida

rectangulo:
	; p = 2*base + 2*altura
	; a = base*altura
	jmp near confirmar_salida
	
triangulo:
	; p = 3*l
	; a = sqrt(3)*lado*lado/2
	jmp near confirmar_salida
	
rombo:
	; p = 4*lado
	; a = diag1*diag2/2
	jmp near confirmar_salida
	
pentagono:
	; p = 5*lado
	; a = 5*lado*apotema/2
	jmp near confirmar_salida
	
hexagono:
	; p = 6*lado
	; a = 3*lado*apotema
	jmp near confirmar_salida
	
circulo:
	; p = 2*pi*r
	; a = pi*r*r
	jmp near confirmar_salida
	
trapezio:
	; p = b_mayor+b_menor+2*lado
	; a = (b_mayor + b_menor)*altura/2
	jmp near confirmar_salida
	
paralelogramo:
	; p = 2*base+2*lado
	; a = base*altura
	jmp near confirmar_salida

confirmar_salida:
	dsp seguirosalir
	call get_input

	cmp al, '1'
	jz near ask
	cmp al, '2'
	jz near exit

	; si entrada invalida
	dsp opcionmala
	jmp near confirmar_salida

exit:
	mov ax, 4ch
	int 21h

code ends

end start
