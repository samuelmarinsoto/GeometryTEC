assume cs:code, ds:data

data segment

cr equ 13d ; retorno de carro
lf equ 10d ; salto de linea


buffer db 80,?, 80 dup ('?') ; espacio de memoria de 80 bytes que almacena entrada del usuario  

lado_input db 10 dup('$') ; espacio utilizado para almacenar el numero ingreasado por el usuario
 
; Mensajes que imprime la consola
bienvenida db "Bienvenido a GeometryTEC, una herramienta para calcular areas y perimetros de figuras","$"
opciones db lf,cr,"Por favor, digite el numero al lado de la figura a calcular:",cr,lf,"1) Cuadrado",cr,lf,"2) Rectangulo",cr,lf,"3) Triangulo (equilatero)",cr,lf,"4) Rombo",cr,lf,"5) Pentagono",cr,lf,"6) Hexagono",cr,lf,"7) Circulo",cr,lf,"8) Trapezio",cr,lf,"9) Paralelogramo",cr,lf,"Seleccion: ","$"
seguirosalir db cr,lf,"Calculo exitoso. Continuar con otro calculo, o salir?",cr,lf,"1) Continuar",cr,lf,"2) Salir",cr,lf,"Seleccion: ","$"

lado db lf,cr,"Lado: ","$"               
base db lf,cr,"Base: ","$"
base1 db lf, cr, "Base 1: ", "$"
base2 db lf, cr, "Base 2: ", "$"
altura db lf,cr,"Altura: ","$"
diagonal1 db lf, cr, "Diagonal 1: ", "$"
diagonal2 db lf, cr, "Diagonal 2: ", "$"
apotema db lf, cr, "Apotema: ", "$"
radio db lf, cr, "Radio: ", "$"

area db lf,cr,"Area: ","$"
perimetro db lf,cr,"Perimetro: ","$"

novalido db cr,lf,"Entrada debe ser numero entre 0 y 9999,99",cr,lf,"$"
opcionmala db cr,lf,"Opcion no disponible",cr,lf,"$"

; variables numericas  tipo double word que almacenan diversas variables de las figuras
ladonum dw 0
perimetronum dw 0
areanum dw 0
diagonal1num dw 0
diagonal2num dw 0
apotema_num dw 0
radio_num dw 0
base1_num dw 0
base2_num dw 0
altura_num dw 0
base_num dw 0

data ends

; macros
dsp macro msg
	lea dx, msg
	call myprint
endm
   
   
code segment
;procedimientos
myprint proc near ; imprime mensaje en pantalla usando la funcion 09h de DOS 21h
    mov ah, 09h
    int 21h
    ret
myprint endp

get_input proc near ; lee caracter del teclado usando la funcion 01h de DOS 21h
	mov ah, 01h
	int 21h
	ret
get_input endp

get_buffer proc near; lee cadena de texto del teclado y la almacena en buffer
    lea dx, buffer
    mov ah, 0ah     
	int 21h
	
	; anade terminador '$' al final de la cadena
	mov bx, 0
	mov bl, buffer[1]
	mov buffer[bx+2], '$'
	ret
get_buffer endp

; Valida si la entrada del usuario es un numero positio
validate_input proc
    lea si, buffer+2
    mov cl, 0              ; contador de digitos
validate_loop:
    lodsb                  ; carga byte de string
    cmp al, '$'
    jz validated_input     ; valida imput si se llega al terminador '$'
    cmp al, '.'
    je check_decimal       ; salta si encuentra decimal
    cmp al, '0'
    jb invalid_input       ; salta si menor a '0'
    cmp al, '9'
    ja invalid_input       ; invalida inputs si llega el contador de digitos llega a '9'
    inc cl                 ; cuenta caracteres validos
    jmp validate_loop      ; continua bucle
check_decimal:
    ; revisa si hay mas de un decimal
    lodsb
    cmp al, '.'            ; compara byte actual con '.'
    je invalid_input       ; se invalida el input si es otro decimal
    jmp validate_loop      ; continua bucle
invalid_input:
    ; muestra mensaje de error
	dsp novalido
    jmp ask              ; Empieza de cero el proceso de entrada
validated_input:
    ret
validate_input endp

; pasa el string ingresado por el usuario a un numero en el cual se pueden aplicar operaciones
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
    ; multiplica valor acumulado por 10 antes de sumar digito nuevo
	mul bx
	sub cl, '0' ; caracter se convierte en su valor numerico restando valor ASCII del caracter '0'
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

; pasa el numero operado a un string para poder imprimirlo
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
	add dl, '0' ; caracter se convierte en su valor ASCII sumandole '0'
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

ask: ; compara input de usuario para saber que figura calcular
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

	; si entrada invalida pone mensaje de respuesta invalida y vuelve a mostrar opciones
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

	; Reinicia las variables a usar
    mov [ladonum], 0
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la base
    dsp base
    call get_buffer
    call validate_input
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [ladonum], ax       ; Guarda la base en ladonum

    ; Pide la altura
    dsp altura
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov bx, ax              ; Guarda la altura en bx

    ; Calculo del perimetro del rectangulo
    mov ax, [ladonum]
    add ax, bx              ; ax = base + altura
    shl ax, 1               ; ax = 2 * (base + altura)
    mov [perimetronum], ax

    ; Calculo del area del rectangulo
    mov ax, [ladonum]
    mul bx                  ; ax = base * altura
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
	
triangulo:
	; p = 3*lado
	; a = sqrt(3)*lado*lado/2

	; Reinicia las variables a usar
    mov [ladonum], 0
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide el lado
    dsp lado
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [ladonum], ax       ; Guarda el lado en ladonum

    ; Calculo del perimetro del tri�ngulo
    mov ax, [ladonum]
    mov bx, 3
    mul bx                  ; ax = lado * 3
    mov [perimetronum], ax

    ; Calculo del area del tri�ngulo
    ; Area = (lado^2 * 3) / 8
    ; Primero, calcula lado^2
    mov ax, [ladonum]
    mul [ladonum]           ; ax = lado^2

    ; Multiplicamos por 3
    mov bx, 3
    mul bx                  ; ax = lado^2 * 3

    ; Divide el resultado por 8
    mov cx, 8
    div cx                  ; ax = (lado^2 * 3) / 8
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
	
rombo:
	; p = 4*lado
	; a = diag1*diag2/2
	
	; Reinicia las variables a usar
    mov [ladonum], 0       ; Lado del rombo
    mov [diagonal1num], 0  ; Diagonal 1
    mov [diagonal2num], 0  ; Diagonal 2
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la longitud del lado
    dsp lado
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [ladonum], ax       ; Guarda el lado en ladonum

    ; Pide la longitud de la diagonal 1
    dsp diagonal1
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [diagonal1num], ax  ; Guarda diagonal1 en diagonal1num

    ; Pide la longitud de la diagonal 2
    dsp diagonal2
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [diagonal2num], ax  ; Guarda diagonal2 en diagonal2num

    ; Calculo del perimetro del rombo
    ; Per�metro = 4 * lado
    mov ax, [ladonum]
    mov bx, 4
    mul bx                  ; ax = lado * 4
    mov [perimetronum], ax

    ; Calculo del �rea del rombo
    ; Area = (diagonal1 * diagonal2) / 2
    mov ax, [diagonal1num]
    mul [diagonal2num]      ; ax = diagonal1 * diagonal2
    mov bx, 2
    div bx                  ; ax = (diagonal1 * diagonal2) / 2
    mov [areanum], ax

    ; Impresion del per�metro
    dsp perimetro
    ; Convierte el per�metro a string y lo imprime
    mov ax, [perimetronum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

    ; Impresion del �rea
    dsp area
    ; Convierte el �rea a string y lo imprime
    mov ax, [areanum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input
    
	jmp near confirmar_salida
	
pentagono:
	; p = 5*lado
	; a = 5*lado*apotema/2
	
    ; Reinicia las variables a usar
    mov [ladonum], 0      ; Lado del pent�gono
    mov [apotema_num], 0  ; Apotema del pent�gono
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la longitud del lado
    dsp lado
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [ladonum], ax      ; Guarda el lado en ladonum

    ; Pide la longitud del apotema
    dsp apotema
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [apotema_num], ax  ; Guarda el apotema en apotema_num

    ; Calculo del perimetro del pent�gono
    ; Per�metro = 5 * lado
    mov ax, [ladonum]
    mov bx, 5
    mul bx                  ; ax = lado * 5
    mov [perimetronum], ax

    ; Calculo del �rea del pent�gono
    ; Area = (1/2) * Perimeter * Apotema
    ; Area = (1/2) * (5 * lado) * apotema
    mov ax, [perimetronum]  ; Load perimeter into ax
    mov bx, [apotema_num]   ; Load apotema into bx
    mul bx                  ; ax = Perimeter * Apotema
    mov cx, 2
    div cx                  ; ax = (1/2) * (Perimeter * Apotema)
    mov [areanum], ax

    ; Impresi�n del per�metro
    dsp perimetro
    ; Convierte el per�metro a string y lo imprime
    mov ax, [perimetronum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

    ; Impresi�n del �rea
    dsp area
    ; Convierte el �rea a string y lo imprime
    mov ax, [areanum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input
    
	jmp near confirmar_salida
	
hexagono:
	; p = 6*lado
	; a = 3*lado*apotema

	; Reinicia las variables a usar
    mov [ladonum], 0      ; Lado del pent�gono
    mov [apotema_num], 0  ; Apotema del pent�gono
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la longitud del lado
    dsp lado
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [ladonum], ax      ; Guarda el lado en ladonum

    ; Pide la longitud del apotema
    dsp apotema
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [apotema_num], ax  ; Guarda el apotema en apotema_num

    ; Calculo del perimetro del pent�gono
    ; Per�metro = 5 * lado
    mov ax, [ladonum]
    mov bx, 6
    mul bx                  ; ax = lado * 6
    mov [perimetronum], ax

    ; Calculo del �rea del pent�gono
    ; Area = (1/2) * Perimeter * Apotema
    ; Area = (1/2) * (5 * lado) * apotema
    mov ax, [perimetronum]  ; Load perimeter into ax
    mov bx, [apotema_num]   ; Load apotema into bx
    mul bx                  ; ax = Perimeter * Apotema
    mov cx, 2
    div cx                  ; ax = (1/2) * (Perimeter * Apotema)
    mov [areanum], ax

    ; Impresi�n del per�metro
    dsp perimetro
    ; Convierte el per�metro a string y lo imprime
    mov ax, [perimetronum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

    ; Impresi�n del �rea
    dsp area
    ; Convierte el �rea a string y lo imprime
    mov ax, [areanum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input
    
	jmp near confirmar_salida
	
circulo:
	; p = 2*pi*r
	; a = pi*r*r

	; Reinicia las variables a usar
    mov [radio_num], 0      ; Radio del c�rculo
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la longitud del radio
    dsp radio
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [radio_num], ax      ; Guarda el radio en radio_num

    ; Calculo de la circunferencia del c�rculo
    ; Circunferencia = (63 * radio) / 10
    mov ax, [radio_num]
    mov bx, 63
    mul bx                  ; ax = 63 * radio
    mov cx, 10
    div cx                  ; ax = (63 * radio) / 10
    mov [perimetronum], ax

    ; Calculo del �rea del c�rculo
    ; Area = (31 * radio^2) / 10
    mov ax, [radio_num]
    mul ax                  ; ax = radio^2
    mov bx, 31
    mul bx                  ; ax = 31 * radio^2
    mov cx, 10
    div cx                  ; ax = (31 * radio^2) / 10
    mov [areanum], ax

    ; Impresi�n de la circunferencia
    dsp perimetro
    ; Convierte la circunferencia a string y lo imprime
    mov ax, [perimetronum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

    ; Impresi�n del �rea
    dsp area
    ; Convierte el �rea a string y lo imprime
    mov ax, [areanum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input
    
	jmp near confirmar_salida
	
trapezio:
	; p = b_mayor+b_menor+2*lado
	; a = (b_mayor + b_menor)*altura/2

	; Reinicia las variables a usar
    mov [base1_num], 0
    mov [base2_num], 0
    mov [ladonum], 0      ; Using ladonum for the side length
    mov [altura_num], 0
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la longitud de base 1
    dsp base1
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [base1_num], ax     ; Guarda la base 1 en base1_num

    ; Pide la longitud de base 2
    dsp base2
    call get_buffer
    lea dx, buffer+2
    call StringANum
    mov [base2_num], ax     ; Guarda la base 2 en base2_num

    ; Pide la longitud del lado
    dsp lado
    call get_buffer
    lea dx, buffer+2
    call StringANum
    mov [ladonum], ax      ; Guarda el lado en ladonum

    ; Pide la altura
    dsp altura
    call get_buffer
    lea dx, buffer+2
    call StringANum
    mov [altura_num], ax    ; Guarda la altura en altura_num

    ; Calculo del per�metro del trapecio
    ; Per�metro = base1 + base2 + 2 * lado
    mov ax, [base1_num]
    add ax, [base2_num]
    mov bx, [ladonum]
    shl bx, 1               ; bx = 2 * lado
    add ax, bx              ; ax = base1 + base2 + 2 * lado
    mov [perimetronum], ax

    ; Calculo del �rea del trapecio
    ; �rea = ((base1 + base2) * altura) / 2
    mov ax, [base1_num]
    add ax, [base2_num]
    mov bx, [altura_num]
    mul bx                  ; ax = (base1 + base2) * altura
    mov cx, 2
    div cx                  ; ax = ((base1 + base2) * altura) / 2
    mov [areanum], ax

    ; Impresi�n del per�metro
    dsp perimetro
    ; Convierte el per�metro a string y lo imprime
    mov ax, [perimetronum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

    ; Impresi�n del �rea
    dsp area
    ; Convierte el �rea a string y lo imprime
    mov ax, [areanum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

	jmp near confirmar_salida
	
paralelogramo:
	; p = 2*base+2*lado
	; a = base*altura

	; Reinicia las variables a usar
    mov [base_num], 0
    mov [ladonum], 0      ; Using ladonum for the side length
    mov [altura_num], 0
    mov [perimetronum], 0
    mov [areanum], 0

    ; Pide la longitud de la base
    dsp base
    call get_buffer
    lea dx, buffer+2        ; buffer+2 skips the length byte and return code
    call StringANum
    mov [base_num], ax      ; Guarda la base en base_num

    ; Pide la longitud del lado
    dsp lado
    call get_buffer
    lea dx, buffer+2
    call StringANum
    mov [ladonum], ax     ; Guarda el lado en ladonum

    ; Pide la altura
    dsp altura
    call get_buffer
    lea dx, buffer+2
    call StringANum
    mov [altura_num], ax   ; Guarda la altura en altura_num

    ; Calculo del per�metro del paralelogramo
    ; Per�metro = 2 * (base + lado)
    mov ax, [base_num]
    add ax, [ladonum]
    shl ax, 1              ; ax = 2 * (base + lado)
    mov [perimetronum], ax

    ; Calculo del �rea del paralelogramo
    ; �rea = base * altura
    mov ax, [base_num]
    mov bx, [altura_num]
    mul bx                 ; ax = base * altura
    mov [areanum], ax

    ; Impresi�n del per�metro
    dsp perimetro
    ; Convierte el per�metro a string y lo imprime
    mov ax, [perimetronum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input

    ; Impresi�n del �rea
    dsp area
    ; Convierte el �rea a string y lo imprime
    mov ax, [areanum]
    lea dx, lado_input 
    call NumAString
    dsp lado_input
    
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
