	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		PROCESSOR 16F877
	;	Clock = XT 4MHz, standard fuse settings
		__CONFIG 0x3731
	
	;	LABEL EQUATES	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		INCLUDE "P16F877A.INC"	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;DATA SEGMENT;;;;;;;;;;;;;;;;;
	
	
	Oper	EQU	34	; Operation code store 
	Temp	EQU	35	; Temporary register for operations
	
	ResultHunTho EQU 36   ; Result Number
	ResultTenTho EQU 37
	ResultTho EQU	38
	ResultHun EQU	39
	ResultTen EQU	40
	ResultUnit EQU 41
	
	TempTenTho EQU	42  ; Temporary Number for devision and modulation
	TempTho EQU	43
	TempHun EQU	44
	TempTen EQU	45
	TempUnit EQU 46
	
	Num1TenTho EQU	47   ; Number  1
	Num1Tho EQU	48
	Num1Hun EQU	49
	Num1Ten EQU	50
	Num1Unit EQU 51
	
	
	Num2TenTho EQU	52    ; Number  2
	Num2Tho EQU	53
	Num2Hun EQU	54
	Num2Ten EQU	55
	Num2Unit EQU 56
	
	cursor EQU 57     ; Cursor to determine at which state Iam
	
	resultFlag EQU 58   ; flag to determine if I reached result state
	
	timer0OverflowCounter EQU 59  ; Timer0 interput counter

	carryReg EQU 60 ; carry for addition
	
	ResultTenThoT EQU	62   ; Temporary result for devision
	ResultThoT EQU		63
	ResultHunT EQU		64
	ResultTenT EQU		65
	ResultUnitT EQU 	66
	
	divFlag EQU 	67    ;flag to determine if I had divison opreation
	keepPushCounter EQU 	68
	RS	EQU	1	; Register select output bit
	E	EQU	2	; Display data strobe
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Program begins ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
		ORG	0		; Default start address 
		NOP			; required for ICD mode
		GOTO init
	
	ORG 0x04
	GOTO ISR
	
	ISR:
	;;;;;;;;;;;;;;;timer0 interput ;;;;;;;;;;;;;;;;
		BANKSEL INTCON			
		BTFSS INTCON, TMR0IF	;check if timer intrupt
		GOTO PushInterrupt	
		BCF INTCON, TMR0IF
		BCF INTCON, TMR0IE 
	
		MOVF	timer0OverflowCounter,W		; check if overflow couter reach 17 (two secods)
		MOVWF	Temp
		MOVLW	0x17
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO twoSecondsReached
		GOTO incrementCounter
	
	twoSecondsReached:

		MOVF	cursor,W	; check if we reached result state
		MOVWF	Temp
		MOVLW	0x0C
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	incrementCounter

		MOVF	cursor,W	; check if we reached result state
		MOVWF	Temp
		MOVLW	0x0D
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	restart

		INCF cursor	; Increment the cursor position every two seconds
		MOVF	cursor,W	; check if we reached result state
		MOVWF	Temp
		MOVLW	0x0B
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	ResultCalc


		CLRF timer0OverflowCounter

	incrementCounter:
		INCF timer0OverflowCounter
		MOVF	timer0OverflowCounter,W		; check if overflow couter reach 23 (three secods)
		MOVWF	Temp
		MOVLW	0x23
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO askKeep

		BANKSEL TMR0
		CLRF TMR0
		
		BANKSEL INTCON
		BSF INTCON, TMR0IE 
		GOTO EndISR	
	
		;;;;;;;;;;;;;;;Push button interput ;;;;;;;;;;;;;;;;
	PushInterrupt:
		BTFSS INTCON, INTF
		GOTO EndISR	
		BCF INTCON, INTF
		BCF INTCON, INTE
		
		; THE TASK WHEN hit
		MOVF	cursor,W		; check if cursor at first digit
		MOVWF	Temp
		MOVLW	00
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state0
	
		MOVF	cursor,W		; check if cursor at second digit
		MOVWF	Temp
		MOVLW	01
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state1
	
		MOVF	cursor,W		; check ... third
		MOVWF	Temp
		MOVLW	02
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state2
	
		MOVF	cursor,W		; check ...fourth
		MOVWF	Temp
		MOVLW	03
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state3
	
		MOVF	cursor,W		; check ...fifth
		MOVWF	Temp
		MOVLW	04
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state4
	
		
		MOVF	cursor,W		; check if cursor at Operation char
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state5
		
		MOVF	cursor,W		; check if cursor at first digit of the second number
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state6
	
		MOVF	cursor,W		; check ...second
		MOVWF	Temp
		MOVLW	07
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state7
	
		MOVF	cursor,W		; check ...third
		MOVWF	Temp
		MOVLW	08
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state8
	
		MOVF	cursor,W		; check ...fourth
		MOVWF	Temp
		MOVLW	09
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state9
	
		MOVF	cursor,W		; check ...fifth
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state10	
	
		MOVF	cursor,W		; check ...fifth
		MOVWF	Temp
		MOVLW	0x0C
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	state11
	
		

	state0:
		INCF Num1TenTho
		MOVF	Num1TenTho,W		;incrementng ten thousend register of Num 1
		MOVWF	Temp
		MOVLW	07
		SUBWF	Temp
		BTFSC	STATUS,Z
		CLRF Num1TenTho
		GOTO continue
	
	state1:					;incrementng thousend register of Num 1
		INCF Num1Tho
		MOVF	Num1TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho1
		MOVF	Num1Tho,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Tho
		GOTO continue
		
	fullTenTho1:
		MOVF	Num1Tho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Tho
		GOTO continue
	
	state2:				;incrementng Hundred register of Num 1
		INCF Num1Hun
		MOVF	Num1TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho2
		GOTO HunNotMax
		
	fullTenTho2:
		MOVF	Num1Tho,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTho2
		GOTO HunNotMax
	fullTho2:
		MOVF	Num1Hun,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Hun
		GOTO continue
	
	HunNotMax:
		MOVF	Num1Hun,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Hun
		GOTO continue
		
	state3:				;incrementng Tens register of Num 1
		INCF Num1Ten
		MOVF	Num1TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho3
		GOTO TenNotMax
		
	fullTenTho3:
		MOVF	Num1Tho,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTho3
		GOTO TenNotMax
	fullTho3:
		MOVF	Num1Hun,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullHun3
		GOTO TenNotMax
	
	fullHun3:
		MOVF	Num1Ten,W		; check 
		MOVWF	Temp
		MOVLW	04
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Ten
		GOTO continue
		
	TenNotMax:
		MOVF	Num1Ten,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Ten
		GOTO continue
	
	
	state4:		;incrementng Units register of Num 1
		INCF Num1Unit
		MOVF	Num1TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho4
		GOTO UnitNotMax
		
	fullTenTho4:
		MOVF	Num1Tho,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTho4
		GOTO UnitNotMax
		
	fullTho4:
		MOVF	Num1Hun,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullHun4
		GOTO UnitNotMax
	
	fullHun4:
		MOVF	Num1Ten,W		; check 
		MOVWF	Temp
		MOVLW	03
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTen4
		GOTO UnitNotMax
		
	fullTen4:
		MOVF	Num1Unit,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Unit
		GOTO continue
		
	UnitNotMax:
		MOVF	Num1Unit,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num1Unit
		GOTO continue
	
	
	state5:   ;changing opreation register
	
		MOVF	Oper,W		
		MOVWF	Temp
		MOVLW	'+'
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	addoper
		
		MOVF	Oper,W	
		MOVWF	Temp
		MOVLW	'/'
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	divoper
		
		MOVF	Oper,W	
		MOVWF	Temp
		MOVLW	'%'
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	modoper
		
	addoper:
		movlW '/'
		MOVWF	Oper
		GOTO continue
	
	divoper:
		movlW '%'
		MOVWF	Oper
		GOTO continue
		
	modoper:
		movlW '+'
		MOVWF	Oper
		GOTO continue
		
		GOTO continue
	
	
	
	state6:     
		INCF Num2TenTho
		MOVF	Num2TenTho,W		;incrementng ten thousend register of Num 2
		MOVWF	Temp
		MOVLW	07
		SUBWF	Temp
		BTFSC	STATUS,Z
		CLRF Num2TenTho
		GOTO continue
	
	state7:					;incrementng thousend register of Num 2
		INCF Num2Tho
		MOVF	Num2TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho7
		MOVF	Num2Tho,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Tho
		GOTO continue
		
	fullTenTho7:
		MOVF	Num2Tho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Tho
		GOTO continue
	
	state8:				;incrementng Hundred register of Num 2
		INCF Num2Hun
		MOVF	Num2TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho8
		GOTO HunNotMax2
		
	fullTenTho8:
		MOVF	Num2Tho,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTho8
		GOTO HunNotMax2
	fullTho8:
		MOVF	Num2Hun,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Hun
		GOTO continue
	
	HunNotMax2:
		MOVF	Num2Hun,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Hun
		GOTO continue
		
	state9:				;incrementng Tens register of Num 2
		INCF Num2Ten
		MOVF	Num2TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho9
		GOTO TenNotMax2
		
	fullTenTho9:
		MOVF	Num2Tho,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTho9
		GOTO TenNotMax2
	fullTho9:
		MOVF	Num2Hun,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullHun9
		GOTO TenNotMax2
	
	fullHun9:
		MOVF	Num2Ten,W		; check 
		MOVWF	Temp
		MOVLW	04
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Ten
		GOTO continue
		
	TenNotMax2:
		MOVF	Num2Ten,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Ten
		GOTO continue
	
	
	state10:		;incrementng Units register of Num 2
		INCF Num2Unit
		MOVF	Num2TenTho,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTenTho10
		GOTO UnitNotMax2
		
	fullTenTho10:
		MOVF	Num2Tho,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTho10
		GOTO UnitNotMax2
		
	fullTho10:
		MOVF	Num2Hun,W		; check 
		MOVWF	Temp
		MOVLW	05
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullHun10
		GOTO UnitNotMax2
	
	fullHun10:
		MOVF	Num2Ten,W		; check 
		MOVWF	Temp
		MOVLW	03
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO fullTen10
		GOTO UnitNotMax2
		
	fullTen10:
		MOVF	Num2Unit,W		; check 
		MOVWF	Temp
		MOVLW	06
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Unit
		GOTO continue
		
	UnitNotMax2:
		MOVF	Num2Unit,W		; check 
		MOVWF	Temp
		MOVLW	0x0A
		SUBWF	Temp
		BTFSC	STATUS,C
		CLRF Num2Unit
		GOTO continue
	
	
;;;;;;;;;;;;;;;;; Calculation at the result state;;;;;;;;;;
	ResultCalc:

		CLRF timer0OverflowCounter
		INCF cursor	
		MOVLW	0x01
		MOVWF resultFlag
		BANKSEL TMR0
		CLRF TMR0
		
		BANKSEL INTCON
		BSF INTCON, TMR0IE 	

		MOVF	Oper,W	
		MOVWF	Temp
		MOVLW	'+'
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	addcalc
		
		MOVF	Oper,W		
		MOVWF	Temp
		MOVLW	'/'
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	divcalc
		
		MOVF	Oper,W	
		MOVWF	Temp
		MOVLW	'%'
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO	modcalc
		
   ;;;;;;;;;;;;;;;;;;;;;;;Addtion Calculation ;;;;;;;;;;;;;;;;;;;		
addcalc:

    MOVF 		Num1Unit,W
    ADDWF 		Num2Unit, W
	MOVWF		Temp
    MOVLW		0x0A
   	SUBWF		Temp,W
    BTFSC    	STATUS,C
    GOTO     	carryTen
    MOVF 		Temp,W
    MOVWF     	ResultUnit
    CLRf     	carryReg
    GOTO     	TensAdd

carryTen:
	MOVLW 		0x0A 
	SUBWF 		Temp, W	     
    MOVWF   	ResultUnit
    MOVLW   	01
    MOVWF   	carryReg

TensAdd:
    MOVF     	Num1Ten, W
    ADDWF     	Num2Ten, W
    ADDWF     	carryReg, W
    CLRf     	carryReg
	MOVWF		Temp
 	MOVLW		0x0A
   	SUBWF		Temp,W
    BTFSC    	STATUS,C
    GOTO     	carryHun
	MOVF 		Temp,W
    MOVWF     	ResultTen
    GOTO    	 HunAdd

carryHun:
	MOVLW 		0x0A 
	SUBWF 		Temp, W	 
    MOVWF    	ResultTen
    MOVLW     	01
    MOVWF     	carryReg

HunAdd:
    MOVF     	Num1Hun, W
    ADDWF     	Num2Hun, W
    ADDWF     	carryReg, W
    CLRf     	carryReg
	MOVWF		Temp
 	MOVLW		0x0A
   	SUBWF		Temp,W
    BTFSC    	STATUS,C
    GOTO 		carryTho
    MOVF 		Temp,W
    MOVWF 		ResultHun
    GOTO 		ThoAdd

carryTho:
	MOVLW 		0x0A 
	SUBWF 		Temp, W	
    MOVWF 		ResultHun
    MOVLW 		01
    MOVWF 		carryReg

ThoAdd:
    MOVF 		Num1Tho, W
    ADDWF 		Num2Tho, W
    ADDWF 		carryReg, W
    CLRf 		carryReg
	MOVWF		Temp
 	MOVLW		0x0A
   	SUBWF		Temp,W
    BTFSC    	STATUS,C
    GOTO     	carryTenTho
    MOVF 		Temp,W
    MOVWF     	ResultTho
    GOTO     	TenThoAdd

carryTenTho:
	MOVLW 		0x0A 
	SUBWF 		Temp, W
    MOVWF 		ResultTenTho
    MOVLW 		01
    MOVWF 		carryReg

TenThoAdd:
    MOVF 		Num1TenTho, W
    ADDWF 		Num2TenTho, W
    ADDWF 		carryReg, W
    CLRf 		carryReg
	MOVWF		Temp
 	MOVLW		0x0A
   	SUBWF		Temp,W
    BTFSC    	STATUS,C
    GOTO     	carryHunTho
    MOVF 		Temp,W
    MOVWF     	ResultTenTho
    GOTO     	continue       

carryHunTho:
	MOVLW 		0x0A 
	SUBWF 		Temp, W
    MOVWF ResultTenTho
    MOVLW 01
    MOVWF ResultHunTho
    GOTO continue
    
  
   ;;;;;;;;;;;;;;;;;;;;;;;Division Calculation ;;;;;;;;;;;;;;;;;;;
divcalc:
	MOVLW	0x01
	MOVWF divFlag
		
	MOVF	Num1Unit,W
	MOVWF	TempUnit
	MOVF	Num1Ten,W
	MOVWF	TempTen
	MOVF	Num1Hun,W
	MOVWF	TempHun
	MOVF	Num1Tho,W
	MOVWF	TempTho
	MOVF	Num1TenTho,W
	MOVWF	TempTenTho

DivLoop:
		BSF		STATUS,C			; Negative detect flag	
		MOVF	Num2TenTho,W		; get first number
		SUBWF	TempTenTho,W		; subtract second
		MOVWF	ResultTenThoT		; and store result
		BTFSS	STATUS,C			; answer negative?
		GOTO	exitDiv				; yes, minus result
	
		BSF		STATUS,C			; Negative detect flag		
		MOVF	Num2Tho,W			; get first number
		SUBWF	TempTho,W			; subtract second
		MOVWF	ResultThoT			; and store result
		BTFSS	STATUS,C			; answer negative?
		GOTO	takeFromTenThoDiv	; yes, minus result
		GOTO	subHunDiv

takeFromTenThoDiv:
	MOVF	ResultTenThoT,W		; 
	BTFSC	STATUS,Z			; check if Z
	GOTO	exitDiv
	DECF  	ResultTenThoT
   	MOVF	TempTho,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Tho,W		; get first number
	SUBWF	Temp,W			; subtract second
	MOVWF	ResultThoT		; and store result
	
subHunDiv:
	BSF		STATUS,C			; Negative detect flag		
	MOVF	Num2Hun,W			; get first number
	SUBWF	TempHun,W			; subtract second
	MOVWF	ResultHunT			; and store result
	BTFSS	STATUS,C			; answer negative?
	GOTO	takeFromThoDiv		; yes, minus result
	GOTO 	subTenDiv

takeFromThoDiv:
	MOVF	ResultThoT,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTenTho2Div
	DECF  	ResultThoT
   	MOVF	TempHun,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Hun,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultHunT		; and store result
	GOTO	subTenDiv

takeFromTenTho2Div:
	MOVF	ResultTenThoT,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exitDiv
	DECF  	ResultTenThoT
   	MOVLW	D'9'
	MOVWF	ResultThoT		; and store result
	MOVF	TempHun,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Hun,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultHunT		; and store result

	
subTenDiv:	
	BSF		STATUS,C			; Negative detect flag		
	MOVF	Num2Ten,W			; get first number
	SUBWF	TempTen,W			; subtract second
	MOVWF	ResultTenT			; and store result
	
	BTFSS	STATUS,C			; answer negative?
	GOTO	takeFromHunDiv		; yes, minus result
	GOTO	subUnitDiv

takeFromHunDiv:
   	MOVF	ResultHunT,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTho2Div
	DECF  	ResultHunT
   	MOVF	TempTen,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Ten,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTenT		; and store result
	GOTO	subUnitDiv
	
takeFromTho2Div:
	MOVF	ResultThoT,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTenTho3Div
	DECF  	ResultThoT
	MOVLW	D'9'
	MOVWF	ResultHunT
   	MOVF	TempTen,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Ten,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTenT		; and store result
	GOTO	subUnitDiv

takeFromTenTho3Div:
	MOVF	ResultTenThoT,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exitDiv
	DECF  	ResultTenThoT
   	MOVLW	D'9'
	MOVWF	ResultThoT		; and store result
	MOVLW	D'9'
	MOVWF	ResultHunT		; and store result
	MOVF	TempTen,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Ten,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTenT		; and store result
	
subUnitDiv:
	BSF		STATUS,C		; Negative detect flag		
	MOVF	Num2Unit,W		; get first number
	SUBWF	TempUnit,W		; subtract second
	MOVWF	ResultUnitT		; and store 

	BTFSS	STATUS,C		; answer negative?
	GOTO	takeFromTenDiv		; yes, minus result
	GOTO	subDoneDiv

takeFromTenDiv:
   	MOVF	ResultTenT,W		; 
	BTFSC	STATUS,Z			; check if Z
	GOTO	takeFromHun2Div
	DECF  	ResultTenT
   	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W			; get first number
	SUBWF	Temp,W				; subtract second
	MOVWF	ResultUnitT			; and store result
	GOTO	subDoneDiv
	
takeFromHun2Div:
   	MOVF	ResultHunT,W		; 
	BTFSC	STATUS,Z		; check if Z
	GOTO	takeFromTho3Div
	DECF  	ResultHunT
	MOVLW	D'9'
	MOVWF	ResultTenT	
   	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W			; subtract second
	MOVWF	ResultUnitT		; and store result
	GOTO	subDoneDiv
	
takeFromTho3Div:
	MOVF	ResultThoT,W		; 
	BTFSC	STATUS,Z		; check if Z
	GOTO	takeFromTenTho4Div
	DECF  	ResultThoT
	MOVLW	D'9'
	MOVWF	ResultHunT
	MOVLW	D'9'
	MOVWF	ResultTenT
	
    MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultUnitT		; and store result
	GOTO	subDoneDiv

takeFromTenTho4Div:
	MOVF	ResultTenThoT,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exitDiv
	DECF  	ResultTenThoT
   	MOVLW	D'9'
	MOVWF	ResultThoT		; and store result
	MOVLW	D'9'
	MOVWF	ResultHunT		; and store result
	MOVLW	D'9'
	MOVWF	ResultTenT		; and store result     	
	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultUnitT		; and store result
	
subDoneDiv:
	MOVF	ResultUnitT,W
	MOVWF	TempUnit
	MOVF	ResultTenT,W
	MOVWF	TempTen
	MOVF	ResultHunT,W
	MOVWF	TempHun
	MOVF	ResultThoT,W
	MOVWF	TempTho
	MOVF	ResultTenThoT,W
	MOVWF	TempTenTho
	

	INCF 	ResultUnit
	BSF		STATUS,C			; Negative detect flag
	MOVLW 	D'10'
	SUBWF  	ResultUnit,W
	BTFSS	STATUS,C		; answer positive?
	GOTO 	DivLoop
	GOTO 	addTenDiv
	

addTenDiv:
	MOVWF 	ResultUnit
	INCF 	ResultTen
	BSF		STATUS,C			; Negative detect flag
	MOVLW 	D'10'
	SUBWF  	ResultTen,W
	BTFSS	STATUS,C		; answer positive?
	GOTO 	DivLoop
	GOTO 	addHunDiv


addHunDiv:
	MOVWF 	ResultTen
	INCF 	ResultHun
	BSF		STATUS,C			; Negative detect flag
	MOVLW 	D'10'
	SUBWF  	ResultHun,W
	BTFSS	STATUS,C		; answer positive?
	GOTO 	DivLoop
	GOTO 	addThoDiv


addThoDiv:
	MOVWF 	ResultHun
	INCF 	ResultTho
	BSF		STATUS,C			; Negative detect flag
	MOVLW 	D'10'
	SUBWF  	ResultTho,W
	BTFSS	STATUS,C		; answer positive?
	GOTO 	DivLoop
	GOTO 	addTenThoDiv


addTenThoDiv:
	MOVWF 	ResultTho
	INCF 	ResultTenTho
	GOTO 	DivLoop

exitDiv:
	GOTO continue
	

	
   ;;;;;;;;;;;;;;;;;;;;;;;Modulation Calculation ;;;;;;;;;;;;;;;;;;;	
modcalc:
	MOVF	Num1Unit,W
	MOVWF	TempUnit
	MOVF	Num1Ten,W
	MOVWF	TempTen
	MOVF	Num1Hun,W
	MOVWF	TempHun
	MOVF	Num1Tho,W
	MOVWF	TempTho
	MOVF	Num1TenTho,W
	MOVWF	TempTenTho
	
ModLoop:
	
	BSF	STATUS,C	; Negative detect flag	
	MOVF	Num2TenTho,W		; get first number
	SUBWF	TempTenTho,W		; subtract second
	MOVWF	ResultTenTho		; and store result
	BTFSS	STATUS,C	; answer negative?
	GOTO	exit		; yes, minus result

	BSF	STATUS,C	; Negative detect flag		
	MOVF	Num2Tho,W		; get first number
	SUBWF	TempTho,W		; subtract second
	MOVWF	ResultTho		; and store result
	BTFSS	STATUS,C	; answer negative?
	GOTO	takeFromTenTho		; yes, minus result
	GOTO	subHun

takeFromTenTho:
	MOVF	ResultTenTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exit
	DECF  ResultTenTho
   	MOVF	TempTho,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Tho,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTho		; and store result
	
subHun:
	BSF	STATUS,C	; Negative detect flag		
	MOVF	Num2Hun,W		; get first number
	SUBWF	TempHun,W		; subtract second
	MOVWF	ResultHun		; and store result
	BTFSS	STATUS,C	; answer negative?
	GOTO	takeFromTho		; yes, minus result
	GOTO	subTen
	
takeFromTho:
	MOVF	ResultTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTenTho2
	DECF  ResultTho
   	MOVF	TempHun,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Hun,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultHun		; and store result
	GOTO	subTen

takeFromTenTho2:
	MOVF	ResultTenTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exit
	DECF  ResultTenTho
   	MOVLW	D'9'
	MOVWF	ResultTho		; and store result
	MOVF	TempHun,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Hun,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultHun		; and store result
	
subTen:	
	BSF	STATUS,C	; Negative detect flag		
	MOVF	Num2Ten,W		; get first number
	SUBWF	TempTen,W		; subtract second
	MOVWF	ResultTen		; and store result

	BTFSS	STATUS,C	; answer negative?
	GOTO	takeFromHun		; yes, minus result
	GOTO	subUnit

takeFromHun:
   	MOVF	ResultHun,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTho2
	DECF  ResultHun
   	MOVF	TempTen,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Ten,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTen		; and store result
	GOTO	subUnit
	
takeFromTho2:
	MOVF	ResultTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTenTho3
	DECF  ResultTho
	  MOVLW	D'9'
	MOVWF	ResultHun
   	MOVF	TempTen,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Ten,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTen		; and store result
	GOTO	subUnit

takeFromTenTho3:
	MOVF	ResultTenTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exit
	DECF  ResultTenTho
   	MOVLW	D'9'
	MOVWF	ResultTho		; and store result
	MOVLW	D'9'
	MOVWF	ResultHun		; and store result
	MOVF	TempTen,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Ten,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultTen		; and store result
	
subUnit:
	BSF	STATUS,C	; Negative detect flag		
	MOVF	Num2Unit,W		; get first number
	SUBWF	TempUnit,W		; subtract second
	MOVWF	ResultUnit		; and store 

	BTFSS	STATUS,C	; answer negative?
	GOTO	takeFromTen		; yes, minus result
	GOTO	subDone

takeFromTen:
   	MOVF	ResultTen,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromHun2
	DECF  ResultTen
   	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultUnit		; and store result
	GOTO	subDone
	
takeFromHun2:
   	MOVF	ResultHun,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTho3
	DECF  ResultHun
	MOVLW	D'9'
	MOVWF	ResultTen	
   	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultUnit		; and store result
	GOTO	subDone
	
takeFromTho3:
	MOVF	ResultTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	takeFromTenTho4
	DECF  ResultTho
	MOVLW	D'9'
	MOVWF	ResultHun
	MOVLW	D'9'
	MOVWF	ResultTen
	
     	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultUnit		; and store result
	GOTO	subDone

takeFromTenTho4:
	MOVF	ResultTenTho,W		; 
	BTFSC	STATUS,Z	; check if Z
	GOTO	exit
	DECF  ResultTenTho
   	MOVLW	D'9'
	MOVWF	ResultTho		; and store result
	MOVLW	D'9'
	MOVWF	ResultHun		; and store result
	MOVLW	D'9'
	MOVWF	ResultTen		; and store result     	
	MOVF	TempUnit,W
	ADDLW 	D'10'
	MOVWF	Temp
	MOVF	Num2Unit,W		; get first number
	SUBWF	Temp,W		; subtract second
	MOVWF	ResultUnit		; and store result
	
subDone:
	MOVF	ResultUnit,W
	MOVWF	TempUnit
	MOVF	ResultTen,W
	MOVWF	TempTen
	MOVF	ResultHun,W
	MOVWF	TempHun
	MOVF	ResultTho,W
	MOVWF	TempTho
	MOVF	ResultTenTho,W
	MOVWF	TempTenTho
   GOTO ModLoop
	
exit:
   	MOVF	TempUnit,W
	MOVWF	ResultUnit
	MOVF	TempTen,W
	MOVWF	ResultTen
	MOVF	TempHun,W
	MOVWF	ResultHun
	MOVF	TempTho,W
	MOVWF	ResultTho
	MOVF	TempTenTho,W
	MOVWF	ResultTenTho
	GOTO continue
 
askKeep:
	MOVLW	0x02
	MOVWF resultFlag
INCF cursor
	CLRF timer0OverflowCounter
		BANKSEL TMR0
		CLRF TMR0
		
		BANKSEL INTCON
		BSF INTCON, TMR0IE

	GOTO continue
	
state11:
	INCF keepPushCounter
	GOTO continue

restart:
	MOVLW	0x00
	MOVWF resultFlag
	MOVWF divFlag
	CLRF timer0OverflowCounter
	CLRF keepPushCounter
    CLRF carryReg
	BANKSEL TMR0
	CLRF TMR0
		
	BANKSEL INTCON
	BSF INTCON, TMR0IE

		MOVF	keepPushCounter,W		; check 
		MOVWF	Temp
		MOVLW	01
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO restaetWithoutClear
		GOTO restaetWithClear

restaetWithoutClear:
	MOVLW	0x05
	MOVWF cursor
	GOTO continue

restaetWithClear:
	MOVLW	0x00
	MOVWF cursor
	GOTO continue

	continue:
		CLRF timer0OverflowCounter
		BANKSEL TMR0
		CLRF TMR0
		BANKSEL INTCON
		BSF INTCON, INTE	
	
	EndISR:
		BANKSEL PORTD
		retfie
	
	
;;;;;;;;;;;Init the project;;;;;;;;
	init:
	
		CLRF timer0OverflowCounter
		CLRF resultFlag
	
		BANKSEL TRISB
		BSF TRISB, TRISB0
	
		BANKSEL	TRISD		; Select bank D
		CLRF	TRISD		; Display port is output
	
		BANKSEL INTCON 
	
		BSF INTCON, GIE
		BSF INTCON, INTE
		BSF INTCON, TMR0IE 
		
		BANKSEL OPTION_REG
		MOVLW b'00000111'
		MOVWF OPTION_REG
	
		GOTO	start		; Jump to main program
	
	
	INCLUDE "LCDIS.INC"
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Things need to be done before looping in main
	start 
		CALL	inid		; Initialise the display
		MOVLW	0x80		; position to home cursor
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
	
		CLRW	DFlag		; Digit flags = 
		
		CLRF Num1TenTho
		CLRF Num1Tho
		CLRF Num1Hun
		CLRF Num1Ten
		CLRF Num1Unit
	
		CLRW Num2TenTho
		CLRW Num2Tho
		CLRW Num2Hun
		CLRW Num2Ten
		CLRW Num2Unit
		movlW '+'
		MOVWF	Oper
		
		movlW 00
		MOVWF	cursor
	
		
	BANKSEL PORTD ; Bank 0 
	
	printOperation:
		MOVF	resultFlag,W		; check 
		MOVWF	Temp
		MOVLW	01
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO printResult

		MOVF	resultFlag,W		; check 
		MOVWF	Temp
		MOVLW	02
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO printKeep

		GOTO printInput
	
	printInput:
		MOVLW	0x80		; position to home cursor
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
	;Sending DATA "Enter Operation" Message 
		movlW A'E' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
	
		movlW A'N' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'T' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'E' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'R' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'O' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'P' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'E' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'R' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'A' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'T' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'I' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'O' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'N' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
	
	
		MOVLW	0xC0		; Move the cursor to beginning of Second Line
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
	
		MOVF	Num1TenTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num1Tho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num1Hun,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num1Ten,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num1Unit,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
	
		MOVF	Oper,W 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
	
		MOVF	Num2TenTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num2Tho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num2Hun,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num2Ten,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	Num2Unit,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
	GOTO printOperation
	
	
printResult:

		MOVLW	0x80		; position to home cursor
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
	;Sending DATA "Enter Operation" Message 
		movlW A'R' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'E' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'S' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'U' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'L' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'T' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A':' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		
	
		MOVLW	0xC0		; Move the cursor to beginning of Second Line
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
	
		MOVF	ResultHunTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	ResultTenTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	ResultTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	ResultHun,W 
		BSF	Select,RS	; Select data mode
		ADDLW	030
		CALL	send		; and send code
		MOVF	ResultTen,W 	
		ADDLW	030
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	ResultUnit,W 
		ADDLW	030
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		
		MOVF	divFlag,W		; check div flag
		MOVWF	Temp
		MOVLW	01
		SUBWF	Temp
		BTFSC	STATUS,Z
		GOTO printWithMod
		GOTO printWithoutMod
		
printWithoutMod:
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		
		GOTO printOperation
		
	printWithMod:
		movlW A'r' 
		BSF	Select,RS	; Select data mode
		CALL	send
		
		MOVF	TempTenTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	TempTho,W 
		ADDLW	030	
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	TempHun,W 
		BSF	Select,RS	; Select data mode
		ADDLW	030
		CALL	send		; and send code
		MOVF	TempTen,W 	
		ADDLW	030
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		MOVF	TempUnit,W 
		ADDLW	030
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		
		GOTO printOperation
	
printKeep:

		MOVLW	0x80		; position to home cursor
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
	;Sending DATA "Enter Keep" Message 
		movlW A'K' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'E' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'E' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'P' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'?' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'[' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'1' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A':' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'Y' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A',' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A'2' 
		BSF	Select,RS	; Select data mode
		CALL	send		; and send code
		movlW A':' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A'N' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A']' 
		BSF	Select,RS	; Select data mode
		CALL	send
		movlW A' ' 
		BSF	Select,RS	; Select data mode
		CALL	send
		GOTO printOperation

	End