  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;

  .rsset $0000
testing .rs 1
buttonsP1 .rs 1 ; player 1 controller data
buttonsP2 .rs 1 ; player 2 controller data
playerFrame .rs 1
bg_ptr_lo .rs 1 ; bg pointer low byte
bg_ptr_hi .rs 1 ; bg pointer high byte

bg_money_offset .rs 1 ; offset to money
money_thousands .rs 1 ; money counter for thousands
money_hundreds  .rs 1 ; money counter for hundreds
money_tens      .rs 1 ; money counter for tens
money_ones      .rs 1 ; money counter for ones

cam_x .rs 1 ; x camera PPUSCROLL
cam_y .rs 1 ; y camera PPUSCROLL

; Players
player_1_dir      .rs 1 ; player 1 direction
player_1_x        .rs 1 ; player 1 x
player_1_y        .rs 1 ; player 1 y
player_1_a_counter .rs 1
player_1_a_frame  .rs 1 ; player 1 animation frame
player_1_health   .rs 1 ; player 1 health
player_1_score    .rs 1 ; player 1 score
player_1_walking  .rs 1 ; player 1 is walking

player_2_dir      .rs 1 ; player 2 direction
player_2_x        .rs 1 ; player 2 x
player_2_y        .rs 1 ; player 2 y
player_2_a_counter .rs 1
player_2_a_frame  .rs 1 ; player 2 animation frame
player_2_health   .rs 1 ; player 2 health
player_2_score    .rs 1 ; player 2 score
player_2_walking  .rs 1

; Bullets
bullet_1_dir      .rs 1 ; bullet 1 direction
bullet_1_x        .rs 1 ; bullet 1 x coord
bullet_1_y        .rs 1 ; bullet 1 y coord

bullet_2_dir      .rs 1 ; bullet 2 direction
bullet_2_x        .rs 1 ; bullet 2 x coord
bullet_2_y        .rs 1 ; bullet 2 y coord

death_anim_fc .rs 1
death_anim_frame .rs 1
death_anim_counter .rs 1

; misc constants
TRUE = $01
FALSE = $00

MAX_SCORE = $05

; Bullet constants
BULLET_VEL = $05
BULLET_OFFSET = $10

; bg ui offsets
PLAYER_1_HEALTHBAR = $43
PLAYER_1_SCORECOUNT = $4E

PLAYER_2_HEALTHBAR = $5A
PLAYER_2_SCORECOUNT = $51

; Direction Enum
DEAD  = $0
UP    = $1
RIGHT = $2
DOWN  = $3
LEFT  = $4

ROOM_UP    = $22
ROOM_RIGHT = $F7
ROOM_DOWN  = $DF
ROOM_LEFT  = $08

BUTTON_A = $80
BUTTON_B = $40
BUTTON_SELECT = $20
BUTTON_START = $10
BUTTON_UP = $08
BUTTON_DOWN = $04
BUTTON_LEFT = $02
BUTTON_RIGHT = $01

P1_START_X = $29
P1_START_Y = $70
P2_START_X = $C7
P2_START_Y = $8D

PLAYER_TOP_BOUND = $20
PLAYER_BOT_BOUND = $D8
PLAYER1_LEFT_BOUND = $06
PLAYER1_RIGHT_BOUND = $59
PLAYER2_LEFT_BOUND = $97
PLAYER2_RIGHT_BOUND = $E9

  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
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
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x    ;move all sprites off screen
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2


LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$28              ; Compare X to hex $28, decimal 40 to load 10 sprites
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

LoadBackground:
  LDA $2002       ; reset high/low latch
  LDA #$20
  STA $2006       ; write high byte
  LDA #$00
  STA $2006       ; write low byte

  ; set up pointer to bg
  LDA #LOW(background) ; #$00
  STA bg_ptr_lo  ; put low byte of bg into pointer
  LDA #HIGH(background)
  STA bg_ptr_hi   ; put high byte into pointer

  LDX #$04
  LDY #$00
LoadBackgroundLoop:
  LDA [bg_ptr_lo], y ; one byte from address + y
  STA $2007
  INY                 ; increment inner loop counter
  BNE LoadBackgroundLoop 
  INC bg_ptr_hi
  DEX 
  BNE LoadBackgroundLoop
      
LoadAttribute:
 CLC
 LDA $2002              ; read PPU status to reset the high/low latch
 LDA #$23
 STA $2006              ; write the high byte of $23C0 address
 LDA #$C0
 STA $2006              ; write the low byte of $23C0 address
 LDX #$00               ; start out at 0
LoadAttributeLoop:
 LDA attribute, x       ; load data from address (attribute + the value in x)
 STA $2007              ; write to PPU
 INX                    ; X = X + 1
 CPX #$40               ; Compare X to hex $40, decimal 64
 BNE LoadAttributeLoop  ; Branch to LoadAttributeLoop if compare was Not Equal to zero
                        ; if compare was equal to 64, keep going down

						
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

  LDA #$00         ; set PPUSCROLL x and y coords
  STA $2005        ; x
  STA $2005        ; y

InitVariables:
  LDA #$00
  STA player_1_a_counter
  STA player_1_a_frame
  STA player_2_a_counter
  STA player_2_a_frame
  STA playerFrame
  STA cam_x
  STA cam_y
  STA money_thousands
  STA money_hundreds
  STA money_tens
  STA money_ones
  STA bullet_1_dir
  STA bullet_1_x
  STA bullet_1_y
  STA bullet_2_dir
  STA bullet_2_x
  STA bullet_2_y
  STA death_anim_fc
  STA death_anim_frame
  STA death_anim_counter
  LDA #$88          ; 132 tiles from bg offset
  STA bg_money_offset

  LDA #$03
  STA player_1_health
  STA player_2_health

  LDA #$00
  STA player_1_score
  STA player_2_score

  LDA #RIGHT
  STA player_1_dir
  LDA #LEFT
  STA player_2_dir
  ; player positions
  LDA #P1_START_X
  STA player_1_x
  LDA #P2_START_X
  STA player_2_x
  LDA #P1_START_Y
  STA player_1_y
  LDA #P2_START_Y
  STA player_2_y

Forever:
  NOP
  JMP Forever     ;jump back to Forever, infinite loop
  
Subroutines:

BulletCollision:

Bullet1:
  LDA bullet_1_dir
  CMP #DEAD
  BEQ Bullet2

  ; if alive
  LDA bullet_1_x         ; load bullet 1 x
  ADC #$08               ; add width of bullet sprite
  SEC
  SBC player_2_x         ; subtract player 2 x
  BCC Bullet2            ; if carry cleared then bullet hasn't reached player 2 yet, so branch

  ; if has reached player 2 x
  LDA bullet_1_x         ; load bullet 1 x
  SBC #$10               ; sub width of player metasprite
  SEC
  SBC player_2_x         ; sub player 2 x
  BCS Bullet2            ; if carry set then bullet is passed the player, so branch

  ; if has not passed player 2 x
  LDA bullet_1_y         ; load bullet 1 y
  ADC #$04               ; add height of bullet sprite
  SEC
  SBC player_2_y         ; sub player 2 y
  BCC Bullet2            ; if carry cleared then bullet is above the player, so branch

  ; if is above the bottom of player 2
  LDA bullet_1_y         ; load bullet 1 y
  SBC #$10               ; sub the height of the player 2 metasprite
  SEC 
  SBC player_2_y         ; sub player 2 y
  BCS Bullet2            ; if carry set, then bullet is below the player so branch

  ; if is below the top of player 2 (HIT)
  LDA #DEAD
  STA bullet_1_dir       ; kill bullet

  DEC player_2_health    ; decrement player 2 health
  BNE Bullet2            ; if not zero, branch

  ; if zero
  LDA #DEAD
  STA player_2_dir

  INC player_1_score
  LDA player_1_score     ; increase player 1 score
  CMP #MAX_SCORE
  BNE Bullet2            ; if player 1 score is not 10, branch

  ; if player 1 score is 10
  LDA #$00
  STA player_1_score     ; set player 1 score to 0
  STA player_2_score     ; set player 1 score to 0

Bullet2:
  LDA bullet_2_dir
  CMP #DEAD
  BEQ BulletCollisionDone

  ; if alive
  LDA bullet_2_x             ; load bullet 2 x
  SBC #$14                   ; sub width of player metasprite + width of bullet metasprite
  SEC
  SBC player_1_x             ; subtract player 1 x
  BCS BulletCollisionDone    ; if carry set then bullet hasn't reached player 1 yet, so branch

  LDA bullet_2_x             ; load bullet 2 x
  ADC #$08                   ; add width of bullet sprite
  SEC
  SBC player_1_x             ; sub player 1 x
  BCC BulletCollisionDone    ; if carry cleared, then the bullet has passed player 1

  LDA bullet_2_y             ; load bullet 2 y
  SBC #$10                   ; sub height of player sprite
  SEC
  SBC player_1_y             ; sub player 1 y
  BCS BulletCollisionDone    ; if carry set then bullet is below the player, so branch

  LDA bullet_2_y             ; load bullet 2 y
  ADC #$04                   ; add the height of the bullet sprite
  SEC
  SBC player_1_y             ; sub player 2 y
  BCC BulletCollisionDone    ; if carry cleared, then bullet is above the player so branch

  ; HIT
  LDA #DEAD
  STA bullet_2_dir           ; kill bullet

  DEC player_1_health        ; decrement player 1 health
  BNE BulletCollisionDone    ; if not zero, branch

  ; if zero
  LDA #DEAD
  STA player_1_dir

  INC player_2_score
  LDA player_2_score         ; increase player 2 score
  CMP #MAX_SCORE
  BNE BulletCollisionDone    ; if player 2 score is not 10, branch

  ; if player 1 score is 10
  LDA #$00
  STA player_2_score        ; set player 2 score to 0
  STA player_1_score     ; set player 1 score to 0

BulletCollisionDone:
  RTS

UpdateScores:
  LDA $2002         ; release hi/lo latch

P1Score:
  ; set vram addr of player 1 counter
  LDX #$20
  LDY #PLAYER_1_SCORECOUNT
  STX $2006
  STY $2006

  LDA player_1_score
  CMP #MAX_SCORE
  BCS P2Score          ; if score is greater than 9, branch
  STA $2007

P2Score:
  ; set vram addr of player 1 counter
  LDX #$20
  LDY #PLAYER_2_SCORECOUNT
  STX $2006
  STY $2006

  LDA player_2_score
  CMP #MAX_SCORE
  BCS UpdateScoresDone ; if score is greater than 9, branch
  STA $2007

UpdateScoresDone:
  RTS

UpdateHealthbars:
  LDA $2002                 ; release the hi/lo latch

P1Health:
  LDX #$20                  ; hi addr = $20
  LDY #PLAYER_1_HEALTHBAR   ; load player 1 healthbar address
  STX $2006                 ; give ppu a draw location in vram
  STY $2006 

  ; Check player 1 health values
  LDA player_1_health
  CMP #$00
  BEQ P1Health0
  CMP #$01
  BEQ P1Health1
  CMP #$02
  BEQ P1Health2
  CMP #$03
  BEQ P1Health3
  JMP P1Health0 ; default to 0 health

P1Health0:      ; draw 0 health
  LDA #$5D
  STA $2007
  STA $2007
  LDA #$5E
  STA $2007
  JMP P2Health
P1Health1:      ; draw 1 health
  LDA #$57
  STA $2007
  LDA #$5D
  STA $2007
  LDA #$5E
  STA $2007
  JMP P2Health
P1Health2:      ; draw 2 health
  LDA #$57
  STA $2007
  STA $2007
  LDA #$5E
  STA $2007
  JMP P2Health
P1Health3:      ; draw 3 health
  LDA #$57
  STA $2007
  LDA #$57
  STA $2007
  LDA #$5B
  STA $2007
  JMP P2Health

P2Health:
  LDX #$20                  ; hi addr = $20
  LDY #PLAYER_2_HEALTHBAR   ; load player 2 healthbar address
  STX $2006                 ; give ppu a draw location in vram
  STY $2006 

  ; check player 2 health values
  LDA player_2_health
  CMP #$00
  BEQ P2Health0
  CMP #$01
  BEQ P2Health1
  CMP #$02
  BEQ P2Health2
  CMP #$03
  BEQ P2Health3
  JMP P2Health0 ; default to 0 health

P2Health0:      ; draw 0 health
  LDA #$5D
  STA $2007
  STA $2007
  LDA #$5E
  STA $2007
  JMP UpdateHealthBarsDone
P2Health1:      ; draw 1 health
  LDA #$5D
  STA $2007
  STA $2007
  LDA #$5B
  STA $2007
  JMP UpdateHealthBarsDone
P2Health2:      ; draw 2 health
  LDA #$5D
  STA $2007
  LDA #$57
  STA $2007
  LDA #$5B
  STA $2007
  JMP UpdateHealthBarsDone
P2Health3:      ; draw 3 health
  LDA #$57
  STA $2007
  STA $2007
  LDA #$5B
  STA $2007
  JMP UpdateHealthBarsDone

UpdateHealthBarsDone:
  RTS

; loads cam values and writes PPUSCROLL with them
CameraScroll:
  LDX cam_x
  LDY cam_y
  STX $2005
  STY $2005
  RTS

; Moves bullet in the correct direction if it is not dead.
HandleBullet:
  LDA bullet_1_y
  CMP #ROOM_UP
  BCC set_bullet_dead
  CMP #ROOM_DOWN
  BCS set_bullet_dead
  LDA bullet_1_x
  CMP #ROOM_LEFT
  BCC set_bullet_dead
  CMP #ROOM_RIGHT
  BCS set_bullet_dead
  JMP chk_dead
set_bullet_dead:  
  LDA #DEAD
  STA bullet_1_dir
  ; if the bullet is dead, set x and y to 0 and end the subroutine
chk_dead:
  LDA bullet_1_dir
  CMP #DEAD
  BNE chk_dir
  LDA #$00
  STA bullet_1_x
  STA bullet_1_y
  JMP HandleBulletDone
chk_dir:
  ; if the bullet is not dead, increment its x or y coords based on the bullet's direction
  CMP #UP
  BNE HandleBullet_chk_r
  LDA bullet_1_y
  SEC
  SBC #BULLET_VEL
  STA bullet_1_y
  JMP HandleBulletDone
HandleBullet_chk_r:
  CMP #RIGHT
  BNE HandleBullet_chk_d
  LDA bullet_1_x
  CLC
  ADC #BULLET_VEL
  STA bullet_1_x
  JMP HandleBulletDone
HandleBullet_chk_d:
  CMP #DOWN
  BNE HandleBullet_chk_l
  LDA bullet_1_y
  CLC
  ADC #BULLET_VEL
  STA bullet_1_y
  JMP HandleBulletDone
HandleBullet_chk_l:
  LDA bullet_1_x
  SEC
  SBC #BULLET_VEL
  STA bullet_1_x
HandleBulletDone:
  ; store bullet x, y in sprite memory addresses
  LDA bullet_1_y
  STA $0210
  LDA bullet_1_x
  STA $0213
  RTS

; Totally DRY code here....
HandleBullet2:
  LDA bullet_2_y
  CMP #ROOM_UP
  BCC set_bullet2_dead
  CMP #ROOM_DOWN
  BCS set_bullet2_dead
  LDA bullet_2_x
  CMP #ROOM_LEFT
  BCC set_bullet2_dead
  CMP #ROOM_RIGHT
  BCS set_bullet2_dead
  JMP chk_dead2
set_bullet2_dead:  
  LDA #DEAD
  STA bullet_2_dir
  ; if the bullet is dead, set x and y to 0 and end the subroutine
chk_dead2:
  LDA bullet_2_dir
  CMP #DEAD
  BNE chk_dir2
  LDA #$00
  STA bullet_2_x
  STA bullet_2_y
  JMP HandleBullet2Done
chk_dir2:
  ; if the bullet is not dead, increment its x or y coords based on the bullet's direction
  CMP #UP
  BNE HandleBullet2_chk_r
  LDA bullet_2_y
  SEC
  SBC #BULLET_VEL
  STA bullet_2_y
  JMP HandleBullet2Done
HandleBullet2_chk_r:
  CMP #RIGHT
  BNE HandleBullet2_chk_d
  LDA bullet_2_x
  CLC
  ADC #BULLET_VEL
  STA bullet_2_x
  JMP HandleBullet2Done
HandleBullet2_chk_d:
  CMP #DOWN
  BNE HandleBullet2_chk_l
  LDA bullet_2_y
  CLC
  ADC #BULLET_VEL
  STA bullet_2_y
  JMP HandleBullet2Done
HandleBullet2_chk_l:
  LDA bullet_2_x
  SEC
  SBC #BULLET_VEL
  STA bullet_2_x
HandleBullet2Done:
  ; store bullet x, y in sprite memory addresses
  LDA bullet_2_y
  STA $0224
  LDA bullet_2_x
  STA $0227
  RTS

IdleSprite:
  LDA player_1_walking
  CMP #$00
  JMP IdleSpriteDone

  ; Change player sprite direction
  LDA #%00000000 ; Set to not flip horizontal
  STA $0202
  STA $020A
  LDA #%01000000 ; Set to flip horizontal
  STA $0206
  STA $020E

  ; Set correct sprite tiles
  LDA #$22
  STA $0201
  STA $0205
  LDA #$32
  STA $0209
  STA $020D

IdleSpriteDone:
  RTS

DeathAnimation:
  LDA death_anim_fc
  CMP #$05 ; "Framerate"
  BNE SetDeathSpriteAtt
  LDA #$00
  STA death_anim_fc
  LDA death_anim_frame
  CMP #$01
  BEQ SetAnimFrameToZero
  LDA #$01
  STA death_anim_frame
  JMP SetDeathSpriteAtt
SetAnimFrameToZero:
  LDA #$00
  STA death_anim_frame
SetDeathSpriteAtt:
  LDA player_1_dir
  CMP #DEAD
  BEQ Player1DeathSprites
  LDA death_anim_frame
  CMP #$01
  BEQ SetP2DeathSprite1
  JMP SetP2DeathSprite0
Player1DeathSprites:
  LDA death_anim_frame
  CMP #$01
  BEQ SetP1DeathSprite1
SetP1DeathSprite0:
  LDA $0202
  ORA #%00000011
  STA $0202
  LDA $0206
  ORA #%00000011
  STA $0206
  LDA $020A
  ORA #%00000011
  STA $020A
  LDA $020E
  ORA #%00000011
  STA $020E
  JMP IncrementDeathCounters
SetP1DeathSprite1:
  LDA $0202
  AND #%11111100
  STA $0202
  LDA $0206
  AND #%11111100
  STA $0206
  LDA $020A
  AND #%11111100
  STA $020A
  LDA $020E
  AND #%11111100
  STA $020E
  JMP IncrementDeathCounters
SetP2DeathSprite0:
  LDA $0216
  ORA #%00000011
  STA $0216
  LDA $021A
  ORA #%00000011
  STA $021A
  LDA $021E
  ORA #%00000011
  STA $021E
  LDA $0222
  ORA #%00000011
  STA $0222
  JMP IncrementDeathCounters
SetP2DeathSprite1:
  LDA $0216
  AND #%11111101
  STA $0216
  LDA $021A
  AND #%11111101
  STA $021A
  LDA $021E
  AND #%11111101
  STA $021E
  LDA $0222
  AND #%11111101
  STA $0222
IncrementDeathCounters:
  INC death_anim_fc
  INC death_anim_counter
  

  LDA death_anim_counter
  CMP #$5A ; How long it lasts
  BEQ ResetGameVariables
  JMP ReturnFromInterrupt

SubroutinesDone:

ResetGameVariables:
  LDA #$00
  STA player_1_a_counter
  STA player_1_a_frame
  STA player_2_a_counter
  STA player_2_a_frame
  STA bullet_1_dir
  STA bullet_1_x
  STA bullet_1_y
  STA bullet_2_dir
  STA bullet_2_x
  STA bullet_2_y
  STA death_anim_fc
  STA death_anim_frame
  STA death_anim_counter
  LDA #$03
  STA player_1_health
  STA player_2_health
  LDA #RIGHT
  STA player_1_dir
  LDA #LEFT
  STA player_2_dir
  ; player positions
  LDA #P1_START_X
  STA player_1_x
  LDA #P2_START_X
  STA player_2_x
  LDA #P1_START_Y
  STA player_1_y
  LDA #P2_START_Y
  STA player_2_y
  JMP ReturnFromInterrupt
 
NMI:
  ; player stuff?
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer

  ; Set is walking flag
  LDA #FALSE
  STA player_1_walking
  STA player_2_walking

  ;LDA $0200
  ;STA player_1_y
  ;LDA $0203
  ;STA player_1_x

  LDA player_1_dir
  CMP #DEAD
  BEQ GotoDeathAnimation
  LDA player_2_dir
  CMP #DEAD
  BNE SubroutineCalls
GotoDeathAnimation:
  JMP DeathAnimation

SubroutineCalls:
  JSR ReadControllers ; do the controller thing
  JSR HandleGameInputs   
  JSR HandleBullet       ; handle player bullet
  JSR HandleBullet2
  JSR Player1Sprite
  JSR BulletCollision    ; do bullet collision
  JSR UpdateHealthbars   ; Update player health bars
  JSR UpdateScores       ; Update player score counts

  LDA player_1_walking
  CMP #FALSE
  BEQ EndP1WalkCheck
  JSR Player1Animation
EndP1WalkCheck:
  LDA player_2_walking
  CMP #FALSE
  BEQ EndP2WalkCheck
  JSR Player2Animation
EndP2WalkCheck:

  JSR CameraScroll       ; set camera scroll

ReturnFromInterrupt:
  RTI             ; return from interrupt

  ; external files
  .include "player-animation.asm"
  .include "read-controllers.asm"
  .include "player-inputs.asm"
  .include "sprite-handler.asm"

 
;;;;;;;;;;;;;;  
  

  .bank 1
  .org $E000
palette:
  ; background palettes
  .db $0F,$0F,$08,$37 ; 00
  .db $01,$0F,$17,$37 ; 01
  .db $0F,$00,$0C,$08 ; 10
  .db $0F,$00,$10,$30 ; 11
  
  ; sprite palettes
  .db $0C,$11,$0F,$30 ; 00
  .db $0C,$05,$1D,$30 ; 01
  .db $22,$29,$1A,$0F ; 10
  .db $0C,$10,$30,$0F ; 11


  .include "background.asm"

sprites:
     ;vert tile attr horiz
  .db $00, $02, $00, $00   ;sprite 0
  .db $00, $03, $00, $08   ;sprite 1
  .db $08, $12, $00, $00   ;sprite 2
  .db $08, $13, $00, $08   ;sprite 3

bullet:
  .db $88, $08, $00, $88   ;sprite 3

p2sprite
  .db $00, $03, %01000001, $00   ;sprite 0
  .db $00, $02, %01000001, $08   ;sprite 1
  .db $08, $13, %01000001, $00   ;sprite 2
  .db $08, $12, %01000001, $08   ;sprite 3

bullet2:
  .db $88, $08, $00, $88   ;sprite 3

endsprites:

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "cowboy.chr"   ;includes 8KB graphics file from SMB1
