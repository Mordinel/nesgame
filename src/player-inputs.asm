; Game Playing State Inputs
HandleGameInputs:
; Check A Button
  LDA #BUTTON_A
  BIT buttonsP1 
  BEQ P1ReadADone
  LDA bullet_1_dir
  CMP #DEAD
  BNE P1ReadADone
  ; set bullet enum
  LDA player_1_dir
  STA bullet_1_dir
  ; set bullet x, y coords
  LDA player_1_x
  CLC
  ADC #$06
  STA bullet_1_x
  LDA player_1_y
  CLC
  ADC #$06
  STA bullet_1_y
P1ReadADone:

P1ReadUp:
  LDA #BUTTON_UP
  BIT buttonsP1
  BEQ P1ReadUpDone

  ; move player
  DEC player_1_y

  ; set player direction
  LDA #UP
  STA player_1_dir
P1ReadUpDone:

P1ReadRight:
  LDA #BUTTON_RIGHT
  BIT buttonsP1
  BEQ P1ReadRightDone
  
  ; move player
  INC player_1_x

  ; set player direction
  LDA #RIGHT
  STA player_1_dir
P1ReadRightDone:

P1ReadDown:
  LDA #BUTTON_DOWN
  BIT buttonsP1
  BEQ P1ReadDownDone

  ; move player
  INC player_1_y

  ; set player direction
  LDA #DOWN
  STA player_1_dir
P1ReadDownDone:

P1ReadLeft:
  LDA #BUTTON_LEFT
  BIT buttonsP1
  BEQ P1ReadLeftDone

  ; move player
  DEC player_1_x

  ; set player direction
  LDA #LEFT
  STA player_1_dir
P1ReadLeftDone:

P2ReadA
; Check A Button
  LDA #BUTTON_A
  BIT buttonsP2 
  BEQ P2ReadADone
  LDA bullet_2_dir
  CMP #DEAD
  BNE P2ReadADone
  ; set bullet enum
  LDA player_2_dir
  STA bullet_2_dir
  ; set bullet x, y coords
  LDA player_2_x
  CLC
  ADC #$06
  STA bullet_2_x
  LDA player_2_y
  CLC
  ADC #$06
  STA bullet_2_y
P2ReadADone:

P2ReadUp:
  LDA #BUTTON_UP
  BIT buttonsP2
  BEQ P2ReadUpDone

  ; move player
  DEC player_2_y

  ; set player direction
  LDA #UP
  STA player_2_dir
P2ReadUpDone:

P2ReadRight:
  LDA #BUTTON_RIGHT
  BIT buttonsP2
  BEQ P2ReadRightDone
  
  ; move player
  INC player_2_x

  ; set player direction
  LDA #RIGHT
  STA player_2_dir
P2ReadRightDone:

P2ReadDown:
  LDA #BUTTON_DOWN
  BIT buttonsP2
  BEQ P2ReadDownDone

  ; move player
  INC player_2_y

  ; set player direction
  LDA #DOWN
  STA player_2_dir
P2ReadDownDone:

P2ReadLeft:
  LDA #BUTTON_LEFT
  BIT buttonsP2
  BEQ P2ReadLeftDone

  ; move player
  DEC player_2_x

  ; set player direction
  LDA #LEFT
  STA player_2_dir
P2ReadLeftDone:
  
HandleGameInputsDone:
  RTS