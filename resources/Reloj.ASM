	LIST P=16F84

;===============
; DATA
;===============

; SFR - Special Function Registers
; Bank 0
TMR0	EQU	01H
PCL		EQU	02H 
STATUS	EQU	03H
PA		EQU	05H
TRISA	EQU	05H
TRISB	EQU	06H
PB		EQU	06H
INTCON	EQU	0BH
VAR		EQU	10H

; Bank 1
OP		EQU	01H

; GPR - General Purpose Registers
SEG		EQU	11H 
AUX		EQU	12H
MIN		EQU	15H
MIN10	EQU	16H
SEG10	EQU	17H
RETA	EQU	18H
HORA10	EQU	19H
HORA	EQU	20H
VAL		EQU	21H 	; Asociado al minutero
VAL1	EQU	22H		; Asociado al horario

;===============
; TEXT
;===============

	ORG	0
	GOTO	INICIO

	ORG	80
INICIO
	; BANK1
	BSF	STATUS, 5
	CLRF	TRISB
	MOVLW	B'00010011' ; RA4/T0CKI, RA0 y RA1 ahora son input
	MOVWF	TRISA

	MOVLW	B'00000111'	; El prescalar es 1:256
	MOVWF	OP

	; BANK0
	BCF	STATUS, 5	
	MOVLW	B'10100000'	; Interrupciones globales (GIE) y por overflow de TMR0
	MOVWF	INTCON

	CLRF	SEG
	CLRF	VAR
	MOVLW	D'100'
	MOVWF	VAR
	MOVLW	D'217'
	MOVWF	TMR0
	CLRF	SEG10
	CLRF	MIN
	CLRF	MIN10
	CLRF	HORA
	CLRF	HORA10
	BCF	PA,3
	BCF	VAL,0

BOTONES
	; Los botones hacen que los bits sean 0 cuando han sido presionados
	; En esta parte se maneja el uso de estos botones

	BTFSS	PA,0 		; Si PA<0> = 0, GOTO a MINU (el boton ha sido presionado)
	GOTO	MINUTO
	BCF	VAL,0			; Si PA<0> = 1, entonces VAL<0> = 0

	BTFSS	PA,1 		; Si PA<1> = 0, GOTO a HOR (el boton ha sido presionado)
	GOTO	HOR
	BCF	VAL1,0			; Si PA<0> = 1, entonces VAL1<0> = 0

PRINCIPAL
	; Esta rutina se comunica con BOTONES al final, generando un ciclo entre las mismas
	; Hará CALLs a RETARDO, 
	MOVF	MIN,0
	MOVWF	PB
	BSF	PB,4
	CALL	RETARDO
	BCF	PB,4
	MOVF	MIN10,0
	MOVWF	PB
	BSF	PB,5
	CALL	RETARDO
	BCF	PB,5
	MOVF	HORA,0
	MOVWF	PB
	BSF	PB,6
	CALL	RETARDO
	BCF	PB,6
	MOVF	HORA10,0
	MOVWF	PB
	BSF	PB,7
	CALL	RETARDO
	BCF	PB,7
	GOTO	BOTONES

MINUTO
	; En esta sección se aumenta 1 al minutero, manejando el presionar el boton
	; Tambien se maneja en caso que el minutero sea 59
	; En este caso se le suma 1 al horario

	BTFSC	VAL,0		; Si VAL<0> = 0, entonces NO se hace GOTO a M1 
	GOTO	M1

	BSF		VAL,0		; VAL<0> = 1
	INCF	MIN,1
	MOVF	MIN,0		; Los contenidos de MIN son cargados a W
	SUBLW	D'10'		; W -= 10

	BTFSS	STATUS,2	; Si Z = 1, entonces NO se va M1
	GOTO	M1
	CLRF	MIN			; Como Z = 1, entonces se hace clear a MIN

	INCF	MIN10,1		
	MOVF	MIN10,0
	SUBLW	D'6'

	BTFSS	STATUS,2
	GOTO	M1

	CLRF	MIN10

M1	
	GOTO	PRINCIPAL	

HOR	
	BTFSC	VAL1,0
	GOTO	H1
	BSF		VAL1,0
	INCF	HORA,1
	MOVF	HORA,0
	SUBLW	D'10'
	BTFSS	STATUS,2
	GOTO	H2
	CLRF	HORA
	INCF	HORA10,1
	GOTO	H1

H2	
	MOVF	HORA,0
	SUBLW	D'4'
	BTFSS	STATUS,2
	GOTO	H1
	MOVF	HORA10,0
	SUBLW	D'2'
	BTFSS	STATUS,2
	GOTO	H1
	CLRF	HORA
	CLRF	HORA10

H1	
	GOTO	PRINCIPAL	


RETARDO
	; Reestablece RETA a 256
	MOVLW	H'FF'
	MOVWF	RETA


COUNTDOWN	
	; Disminuye el valor de RETA hasta llegar a 0
	DECFSZ	RETA,1			; Si el valor de RETA llega a cero se sale del CALL
	GOTO	COUNTDOWN		; Si el valor de RETA NO llega a cero, se regresa COUNTDOWN
	RETURN
	
	; Manejo de la interrupcción de TMR0
	ORG	4
	MOVWF	AUX
	DECFSZ	VAR,1
	GOTO	A1
	BTFSS	PA,2
	GOTO	UNO
	BCF	PA,2
	GOTO	CERO
	
UNO	
	BSF	PA,2

CERO	INCF	SEG,1
	MOVF	SEG,0
	SUBLW	D'60'
	BTFSS	STATUS,2
	GOTO	A2
	CLRF	SEG
	INCF	MIN,1
	MOVF	MIN,0
	SUBLW	D'10'
	BTFSS	STATUS,2
	GOTO	A2
	CLRF	MIN
	INCF	MIN10,1
	MOVF	MIN10,0
	SUBLW	D'6'
	BTFSS	STATUS,2
	GOTO	A2
	CLRF	MIN10
	INCF	HORA,1
	MOVF	HORA,0
	SUBLW	D'10'
	BTFSS	STATUS,2
	GOTO	A5
	CLRF	HORA
	INCF	HORA10,1
	GOTO	A2
A5	MOVF	HORA,0
	SUBLW	D'4'
	BTFSS	STATUS,2
	GOTO	A2
	MOVF	HORA10,0
	SUBLW	D'2'
	BTFSS	STATUS,2
	GOTO	A2
	CLRF	HORA
	CLRF	HORA10
A2	MOVLW	D'100'
	MOVWF	VAR
A1	MOVLW	D'217'
	MOVWF	TMR0
	BCF	INTCON,2
	MOVF	AUX,0
	RETFIE
	
	END
	
	