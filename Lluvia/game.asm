  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring

;;;;;;;;;;;;;;;

;DECLARACIÓN DE VARIABLES

rightWall = $F4
bulletX = 0
puntaje = 0

    
  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  ;STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up STAck
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2


LoadPalettes:
  LDA $2002             ; read PPU STAtus to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; STArt out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

LoadSprites:
  LDX #$00              ; STArt at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$14              ; Compare X to hex $20, decimal 32
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
              
LoadSprites2:
	LDX #$14
LoadSprintesLoop2:
	LDA sprites,x
	STA $0200,x
	INX
	CPX #$24
	BNE LoadSprintesLoop2

	;para disparo azul
	LDA #$00
	STA $0D
	STA $0B
	
	;para disparo naranja
	LDA #$00
	STA $0E
	STA $0F
	
	
LoadBlueShoots:
	LDX #0
LoadBlueShootsLoop:
	LDY #16
	LDA sprites,Y
	STA $0224,X
	INY
	INX
	LDA sprites,Y
	STA $0224,X
	INY
	INX
	LDA sprites,Y
	STA $0224,X
	INY
	INX
	LDA sprites,Y
	STA $0224,X
	INX
	CPX #24
	BNE LoadBlueShootsLoop
	
	
LoadOrangeShoots:
	LDX #0
LoadOrangeShootsLoop:
	LDY #36
	LDA sprites,Y
	STA $023C,X
	INY
	INX
	LDA sprites,Y
	STA $023C,X
	INY
	INX
	LDA sprites,Y
	STA $023C,X
	INY
	INX
	LDA sprites,Y
	STA $023C,X
	INX
	CPX #24
	BNE LoadOrangeShootsLoop
 

  LDA #%10000000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00010000   ; enable sprites
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
 

NMI:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, STArt the transfer


LatchController:
  LDA #$01
  STA $4016
  STA $4017
  LDA #$00
  STA $4016
  STA $4017    ; tell both the controllers to latch buttons



;--------------------------------------------------------------CONTROL 1----------------------------------------------------------------------------------------------------------------
ReadA:
  LDA $4016        ;player 1 - A
  AND #%00000001   ;mira si el botón está presionado (1 si lo está)
  BNE Fire
  LDX #0
  STX $0B
  BEQ NoFire

Fire:
  LDX $0B
  CPX #1
  BEQ NoFire
  
  LDX $0D
  LDA #$1
  STA $0227,X
  
  LDA $0200
  CLC
  ADC #4 ;CENTRAR
  STA $0224,X
  
  INX
  INX
  INX
  INX
  CPX #24
  BMI NoReinicio
  LDX #0
 NoReinicio:
  STX $0D
  LDX #1
  STX $0B
  
NoFire:
	
  LDX #0
 CICLO:
  
  LDA $0227,X
  CMP #0
  STX $0A
  BEQ NoMueveAUX
  CLC
  ADC #4
  ;CMP #253
  ;BNE NoResetDisparo
  ;LDA #1
 NoResetDisparo:
  STA $0227,X
  STX $0A
  LDA $0227,X
  CMP #241
  BNE NoMueveAUX
  VerificaContacto:
  	LDY $0224,X
  	LDX $0214
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin
  	INX
  	STX $1A
  	CPY $1A
  	BNE NoMueve

  	JMP LoadWin
  	NoMueveAUX:
  	JMP NoMueve
  	CICLOAUX:
  	JMP CICLO
  	
  LoadWin:
	LDX #0
	LDY #40
  LoadWinLoop:
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	CPX #16
	BNE LoadWinLoop

	JMP FIN
 NoMueve:
  LDX $0A
  INX
  INX
  INX
  INX
  CPX #24
  BMI CICLOAUX


ReadB: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadSelect   ; branch to ReadBDone if button is NOT pressed (0)
             
ReadSelect:         ;No hace nada con el select
  LDA $4016
  AND #%00000001
  BEQ ReadStart  

ReadStart:    ;No hace nada con el start
  LDA $4016
  AND #%00000001
  BEQ ReadUp

ReadUp:         ;Se mueve hacia arriba con la presion de arriba
  LDA $4016
  AND #%00000001
  BEQ ReadDown


  ;lee la posición vertical de cada sprite
  LDA $0200
  SEC
  SBC #$02
  STA $0200

  LDA $0204
  SEC
  SBC #$02
  STA $0204
  
  LDA $0208
  SEC
  SBC #$02
  STA $0208
  
  LDA $020C
  SEC
  SBC #$02
  STA $020C


ReadDown:     ;Mueve hacia abajo
  LDA $4016
  AND #%00000001
  BEQ ReadLeft
  
  ;lee la posición vertical de cada sprite
  LDA $0200
  CLC
  ADC #$02
  STA $0200   

  LDA $0204
  CLC
  ADC #$02
  STA $0204

  LDA $0208
  CLC
  ADC #$02
  STA $0208

  LDA $020C
  CLC
  ADC #$02
  STA $020C

  ;LDA $0210
  ;CLC
  ;ADC #$02
  ;STA $0210


ReadLeft:
  LDA $4016       ; player 1 - LEFT
  AND #%00000001  ; only look at bit 0
  BEQ ReadRight   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  
 
ReadRight:
  LDA $4016       ; player 1 - Rigth
  AND #%00000001  ; only look at bit 0
  BEQ ReadA2   ; branch to ReadADone if button is NOT pressed (0)
                ; add instructions here to do something when button IS pressed (1)
				
;--------------------------------------------------------------CONTROL 2---------------------------------------------------------------------------------------------------------------
ReadA2:
  LDA $4017        ;player 1 - A
  AND #%00000001   ;mira si el botón está presionado (1 si lo está)
  BNE Fire2
  LDX #0
  STX $0F
  BEQ NoFire2

Fire2:
  LDX $0F
  CPX #1
  BEQ NoFire2
  
  LDX $0E
  LDA #$F6
  STA $023F,X
  
  LDA $0214
  CLC
  ADC #4
  STA $023C,X
  
  INX
  INX
  INX
  INX
  CPX #24
  BMI NoReinicio2
  LDX #0
 NoReinicio2:
  STX $0E
  LDX #1
  STX $0F
  
NoFire2:
	
  LDX #0
 CICLO2:
  
  LDA $023F,X
  CMP #$F7
  STX $09
  BEQ NoMueveAUX2
  SEC
  SBC #4
  ;CMP #1
  ;BNE NoResetDisparo2
  ;LDA #$F6
 NoResetDisparo2:
  STA $023F,X
  STX $09
  LDA $023F,X
  CMP #6
  BNE NoMueveAUX2
  VerificaContacto2:
  	LDY $023C,X
  	LDX $0204
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BEQ LoadWin2
  	INX
  	STX $1A
  	CPY $1A
  	BNE NoMueve2
  	

  	JMP LoadWin2
  	NoMueveAUX2:
  	JMP NoMueve2
  	CICLOAUX2:
  	JMP CICLO2
  	
  LoadWin2:
	LDX #0
	LDY #44
  LoadWinLoop2:
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	LDA sprites,Y
	STA $0254,X
	INX
	INY
	CPX #16
	BNE LoadWinLoop2

	JMP FIN
 NoMueve2:
  LDX $09
  INX
  INX
  INX
  INX
  CPX #24
  BMI CICLOAUX2

  

ReadB2: 
  LDA $4017       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadSelect2   ; branch to ReadBDone if button is NOT pressed (0)
             
ReadSelect2:         ;No hace nada con el select
  LDA $4017
  AND #%00000001
  BEQ ReadStart2 

ReadStart2:    ;No hace nada con el start
  LDA $4017
  AND #%00000001
  BEQ ReadUp2

ReadUp2:         ;Se mueve hacia arriba con la presion de arriba
  LDA $4017
  AND #%00000001
  BEQ ReadDown2

  ;lee la posición vertical de cada sprite
  LDA $0214
  SEC
  SBC #$02
  STA $0214

  LDA $0218
  SEC
  SBC #$02
  STA $0218
  
  LDA $021C
  SEC
  SBC #$02
  STA $021C
  
  LDA $0220
  SEC
  SBC #$02
  STA $0220

  ;LDA $0210
  ;SEC
  ;SBC #$02
  ;STA $0210
  
 

ReadDown2:     ;Mueve hacia abajo
  LDA $4017
  AND #%00000001
  BEQ ReadLeft2
  
  ;lee la posición vertical de cada sprite
  LDA $0214
  CLC
  ADC #$02
  STA $0214   

  LDA $0218
  CLC
  ADC #$02
  STA $0218

  LDA $021C
  CLC
  ADC #$02
  STA $021C

  LDA $0220
  CLC
  ADC #$02
  STA $0220

  ;LDA $0210
  ;CLC
  ;ADC #$02
  ;STA $0210


ReadLeft2:
  LDA $4017      ; player 1 - LEFT
  AND #%00000001  ; only look at bit 0
  BEQ ReadRight2   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  
 
ReadRight2:
  LDA $4017       ; player 1 - Rigth
  AND #%00000001  ; only look at bit 0
  BEQ ReadDone  ; branch to ReadADone if button is NOT pressed (0)
                ; add instructions here to do something when button IS pressed (1)
  

ReadDone:
  
  RTI             ; return from interrupt

  
  
FIN:
   INY
hola1: NOP
   NOP
hola2: CPX #1
   DEX
   SBC #0
   BCS hola1
   DEY
   BNE hola2       
	
	JMP RESET
	
  
;;;;;;;;;;;;;;  
  
  
  
  .bank 1
  .org $E000
palette: ;Se carga la paleta de colores
  ;.db $0F,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$0F
  ;.db $0F,$1C,$15,$14,$31,$02,$38,$3C,$0F,$1C,$15,$14,$31,$02,$38,$3C
  .db $0F,$12,$16,$16,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$0F
  .db $0F,$12,$16,$16,$31,$02,$38,$3C,$0F,$1C,$15,$14,$31,$02,$38,$3C

sprites: ;se cargan los sprites
     ;vert tile attr horiz
  .db $80, $00, $00, $08   ;sprite 0
  .db $80, $01, $00, $10   ;sprite 1
  .db $88, $02, $00, $08   ;sprite 2
  .db $88, $03, $00, $10   ;sprite 3
  .db $84, $04, $00, $00   ;disparo
  .db $80, $06, $00, $E8   ;sprite 0
  .db $80, $05, $00, $F0   ;sprite 1
  .db $88, $08, $00, $E8   ;sprite 2
  .db $88, $07, $00, $F0   ;sprite 3
  .db $84, $09, $00, $F7   ;disparo
  .db $94, $0A, $00, $70   ;1
  .db $94, $0C, $00, $78   ;w
  .db $94, $0D, $00, $80   ;i
  .db $94, $0E, $00, $88   ;n
  .db $94, $0B, $00, $70   ;2
 
  

  .org $FFFA     ;first of the three vectors STArts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1   