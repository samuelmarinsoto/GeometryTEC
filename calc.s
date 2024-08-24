assume cs:code, ds:data

data segment

cr equ 13d ; carriage return y
lf equ 10d ; line feed, para newlines

bienvenida db "Bienvenido a GeometryTEC, una herramienta para calcular areas y perimetros de figuras$",cr,lf
opciones db "Por favor, digite el numero al lado de la figura a calcular:"Î,cr,lf,"1) Cuadrado",cr,lf,"2) Rectangulo",cr,lf,"3) Triangulo (equilatero)",cr,lf,"4) Rombo",cr,lf,"5) Pentagono",cr,lf,"6) Hexagono",cr,lf,"7) Circulo",cr,lf,"8) Trapecio",cr,lf,"9) Paralelogramo$",cr,lf
area db "Area: $",cr,lf
perimetro db "Perimetro: $",cr,lf
pedirlado db "Por favor, digite el valor del lado: $",cr,lf
novalido db "Por favor, digite un numero entre -999,99 y 9999,99$",cr,lf
opcionmala db "Opcion no disponible$",cr,lf
seguirosalir db "Continuar con otro calculo, o salir?$",cr,lf
continuar db "1) Continuar$",cr,lf
salir db "2) Salir$",cr,lf

var1a dw 0
var2a dw 0
var1b dw 0
var2b dw 0

lado dw 0
perimetronum dw 0
areanum dw 0

lado_input db 10 dup('$')

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
    mov ah, 01h         ; Lee el char actual
    int 21h
    cmp al, 13          ; Chequea si es vacio, si lo es se termina el ciclo.
    je done
    mov [si], al        ; Guarda char no leido
    inc si              
    jmp get_input       ; Se va al siguiente char y se repie el proceso.

done:
    mov byte ptr [si], '$' 
    ret
get_input endp


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
	pop[di]
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
	lea si, lado_input
	call get_input

	cmp al, '1'
	jz llamar_cuadrado
	cmp al, '2'
	jz llamar_rectangulo
	cmp al, '3'
	jz llamar_triangulo
	cmp al, '4'
	jz llamar_rombo
	cmp al, '5'
	jz llamar_pentagono
	cmp al, '6'
	jz llamar_hexagono
	cmp al, '7'
	jz llamar_circulo
	cmp al, '8'
	jz llamar_trapezio
	cmp al, '9'
	jz llamar_paralelogramo

	; si entrada invalida
	dsp opcionmala
	jmp ask

llamar_cuadrado:
	call cuadrado
	jmp ask

llamar_rectangulo:
	call rectangulo
	jmp ask

llamar_triangulo:
	call triangulo
	jmp ask

llamar_rombo:
	call rombo
	jmp ask

llamar_pentagono:
	call pentagono
	jmp ask

llamar_hexagono:
	call hexagono
	jmp ask

llamar_circulo:
	call circulo
	jmp ask

llamar_trapezio:
	call trapezio
	jmp ask

llamar_paralelogramo:
	call paralelogramo
	jmp ask

cuadrado:
        ; Reinicia las variables a usar
        mov [lado], 0
        mov [perimetronum], 0
        mov [areanum], 0

        ; Pide el lado
        dsp pedirlado

        ; Lectura del string del lado recibido
        lea si, lado_input
        call get_input
        mov dx, offset lado_input
        call StringANum
        mov [lado], ax

        ; Calculo del perimetro del cuadrado
        mov ax, [lado]
        mov bx, 4
        mul bx
        mov [perimetronum], ax

        ; Calculo del area del cuadrado
        mov ax, [lado]
        mul [lado]
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

        ret

rectangulo:
	ret
triangulo:
	ret
rombo:
	ret
pentagono:
	ret
hexagono:
	ret
circulo:
	ret
trapezio:
	ret
paralelogramo:
	ret

exit:
	mov ax, 4ch
	int 21h

code ends

end start
