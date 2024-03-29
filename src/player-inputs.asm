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
  ; Check collision with wall
  LDA player_1_y
  CMP #PLAYER_TOP_BOUND
  BCC P1ReadUpDone

  LDA #BUTTON_UP
  BIT buttonsP1
  BEQ P1ReadUpDone

  ; move player
  DEC player_1_y

  ; set player direction
  LDA #UP
  STA player_1_dir

  ; set walking flag
  LDA #TRUE
  STA player_1_walking
P1ReadUpDone:

P1ReadRight:
  ; Check collision with wall
  LDA player_1_x
  CMP #PLAYER1_RIGHT_BOUND
  BCS P1ReadRightDone

  ; check if player is already walking
  LDA player_1_walking
  CMP #TRUE
  BEQ P2ReadA

  LDA #BUTTON_RIGHT
  BIT buttonsP1
  BEQ P1ReadRightDone
  
  ; move player
  INC player_1_x

  ; set player direction
  LDA #RIGHT
  STA player_1_dir

  ; set walking flag
  LDA #TRUE
  STA player_1_walking
P1ReadRightDone:

P1ReadDown:
  ; Check collision with wall
  LDA player_1_y
  CMP #PLAYER_BOT_BOUND
  BCS P1ReadDownDone

  ; check if player is already walking
  LDA player_1_walking
  CMP #TRUE
  BEQ P2ReadA

  LDA #BUTTON_DOWN
  BIT buttonsP1
  BEQ P1ReadDownDone

  ; move player
  INC player_1_y

  ; set player direction
  LDA #DOWN
  STA player_1_dir

  ; set walking flag
  LDA #TRUE
  STA player_1_walking
P1ReadDownDone:

P1ReadLeft:
  ; Check collision with wall
  LDA player_1_x
  CMP #PLAYER1_LEFT_BOUND
  BCC P1ReadLeftDone

  ; check if player is already walking
  LDA player_1_walking
  CMP #TRUE
  BEQ P2ReadA

  LDA #BUTTON_LEFT
  BIT buttonsP1
  BEQ P1ReadLeftDone

  ; move player
  DEC player_1_x

  ; set player direction
  LDA #LEFT
  STA player_1_dir

  ; set walking flag
  LDA #TRUE
  STA player_1_walking
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
  ; Check collision with wall
  LDA player_2_y
  CMP #PLAYER_TOP_BOUND
  BCC P2ReadUpDone

  LDA #BUTTON_UP
  BIT buttonsP2
  BEQ P2ReadUpDone

  ; move player
  DEC player_2_y

  ; set player direction
  LDA #UP
  STA player_2_dir

  ; set walking flag
  LDA #TRUE
  STA player_2_walking
P2ReadUpDone:

P2ReadRight:
  ; Check collision with wall
  LDA player_2_x
  CMP #PLAYER2_RIGHT_BOUND
  BCS P2ReadRightDone

  ; check if player is already walking
  LDA player_2_walking
  CMP #TRUE
  BEQ P2ReadLeftDone

  LDA #BUTTON_RIGHT
  BIT buttonsP2
  BEQ P2ReadRightDone
  
  ; move player
  INC player_2_x

  ; set player direction
  LDA #RIGHT
  STA player_2_dir

  ; set walking flag
  LDA #TRUE
  STA player_2_walking
P2ReadRightDone:

P2ReadDown:
  ; Check collision with wall
  LDA player_2_y
  CMP #PLAYER_BOT_BOUND
  BCS P2ReadDownDone

  ; check if player is already walking
  LDA player_2_walking
  CMP #TRUE
  BEQ P2ReadLeftDone

  LDA #BUTTON_DOWN
  BIT buttonsP2
  BEQ P2ReadDownDone

  ; move player
  INC player_2_y

  ; set player direction
  LDA #DOWN
  STA player_2_dir

  ; set walking flag
  LDA #TRUE
  STA player_2_walking
P2ReadDownDone:

P2ReadLeft:
  ; Check collision with wall
  LDA player_2_x
  CMP #PLAYER2_LEFT_BOUND
  BCC P2ReadLeftDone

  ; check if player is already walking
  LDA player_2_walking
  CMP #TRUE
  BEQ P2ReadLeftDone

  LDA #BUTTON_LEFT
  BIT buttonsP2
  BEQ P2ReadLeftDone

  ; move player
  DEC player_2_x

  ; set player direction
  LDA #LEFT
  STA player_2_dir

  ; set walking flag
  LDA #TRUE
  STA player_2_walking
P2ReadLeftDone:
  
HandleGameInputsDone:
  RTS