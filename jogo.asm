; -----------------------------------------------------------------------------
; WORLD'S HARDEST GAME (ICMC Processor) - Single level
; - Text mode (30x40)
; - Uses only instructions documented in ProcessadorICMC2.pdf
; - Organized in the required routines for future expansion
; -----------------------------------------------------------------------------

jmp main

; -----------------------------------------------------------------------------
; Constants (chars, keys, states)
; -----------------------------------------------------------------------------
CharWall      : var #1
CharPlayer    : var #1
CharCoin      : var #1
CharObstacle  : var #1
CharStartEnd  : var #1
CharSpace     : var #1

static CharWall,     #'#'
static CharPlayer,   #'X'
static CharCoin,     #'i'
static CharObstacle, #'O'
static CharStartEnd, #'J'
static CharSpace,    #' '

KeyNone : var #1
static KeyNone, #255

StatePlay : var #1
StateLose : var #1
StateWin  : var #1

static StatePlay, #0
static StateLose, #1
static StateWin,  #2

; -----------------------------------------------------------------------------
; Game variables
; -----------------------------------------------------------------------------
GameState      : var #1
ReturnToTitle  : var #1
LastKey        : var #1

PlayerRow      : var #1
PlayerCol      : var #1
StartRow       : var #1
StartCol       : var #1
EndRow         : var #1
EndCol         : var #1
PrevPlayerRow  : var #1
PrevPlayerCol  : var #1

NextRow        : var #1
NextCol        : var #1
MoveAllowed    : var #1

CoinsCollected : var #1
CoinsTotal     : var #1

LevelIndex     : var #1 ; placeholder for future multiple levels

; -----------------------------------------------------------------------------
; UI strings
; -----------------------------------------------------------------------------
TitleLine1 : string "WORLD'S HARDEST GAME"
TitleLine2 : string "APERTE QUALQUER TECLA PARA JOGAR"

LoseLine1  : string "PERDEU!"
LoseLine2  : string "APERTE QUALQUER TECLA PARA REINICIAR"

WinLine1   : string "VOCE VENCEU!"
WinLine2   : string "QUER JOGAR NOVAMENTE? (S/N)"

ScoreLabel : string "PONTOS: "

; -----------------------------------------------------------------------------
; Map template (30 rows x 40 cols). Each row is 40 chars + '\0' terminator.
; -----------------------------------------------------------------------------
MapTemplate:
Row00 : string "########################################"
Row01 : string "#                                      #"
Row02 : string "#                                      #"
Row03 : string "#                                      #"
Row04 : string "#                                      #"
Row05 : string "########################################"
Row06 : string "#      #                        #      #"
Row07 : string "#      #                        #      #"
Row08 : string "#      #                        #      #"
Row09 : string "#      #                        #      #"
Row10 : string "#      #                        #      #"
Row11 : string "#      #                        #      #"
Row12 : string "#      #                        #      #"
Row13 : string "#      #                        #      #"
Row14 : string "#  J                i            J     #"
Row15 : string "#      #                        #      #"
Row16 : string "#      #                        #      #"
Row17 : string "#      #                        #      #"
Row18 : string "#      #                        #      #"
Row19 : string "#      #                        #      #"
Row20 : string "#      #                        #      #"
Row21 : string "#      #                        #      #"
Row22 : string "#      #                        #      #"
Row23 : string "#      #                        #      #"
Row24 : string "########################################"
Row25 : string "#                                      #"
Row26 : string "#                                      #"
Row27 : string "#                                      #"
Row28 : string "#                                      #"
Row29 : string "########################################"

; Current map (same layout as template): 30 * 41 = 1230 chars
MapCurrent : var #1230

; -----------------------------------------------------------------------------
; Obstaculos moveis (12)
; - ObsRows: linha atual
; - ObsCols: coluna atual (fixa neste nivel)
; - ObsDirs: direcao (0 = sobe, 1 = desce)
; - ObsRowInit: linha inicial
; -----------------------------------------------------------------------------
ObsCount : var #1
ObsFlip  : var #1
ObsTick  : var #1
ObsTickMax : var #1

ObsRows     : var #12
ObsPrevRows : var #12
ObsCols     : var #12
ObsDirs     : var #12
ObsRowInit  : var #12
ObsDirsInit : var #12

static ObsCount, #12
static ObsTickMax, #4

static ObsCols + #0,  #10
static ObsCols + #1,  #13
static ObsCols + #2,  #16
static ObsCols + #3,  #23
static ObsCols + #4,  #26
static ObsCols + #5,  #29
static ObsCols + #6,  #10
static ObsCols + #7,  #13
static ObsCols + #8,  #16
static ObsCols + #9,  #23
static ObsCols + #10, #26
static ObsCols + #11, #29

static ObsRowInit + #0,  #12
static ObsRowInit + #1,  #12
static ObsRowInit + #2,  #12
static ObsRowInit + #3,  #12
static ObsRowInit + #4,  #12
static ObsRowInit + #5,  #12
static ObsRowInit + #6,  #17
static ObsRowInit + #7,  #17
static ObsRowInit + #8,  #17
static ObsRowInit + #9,  #17
static ObsRowInit + #10, #17
static ObsRowInit + #11, #17

static ObsDirsInit + #0,  #1
static ObsDirsInit + #1,  #1
static ObsDirsInit + #2,  #1
static ObsDirsInit + #3,  #1
static ObsDirsInit + #4,  #1
static ObsDirsInit + #5,  #1
static ObsDirsInit + #6,  #0
static ObsDirsInit + #7,  #0
static ObsDirsInit + #8,  #0
static ObsDirsInit + #9,  #0
static ObsDirsInit + #10, #0
static ObsDirsInit + #11, #0

; -----------------------------------------------------------------------------
; Main flow
; -----------------------------------------------------------------------------
main:
    call TelaInicial

MainRestart:
    call InicializarJogo
    call DesenharTela

GameLoop:
    call LerEntrada
    call AtualizarJogador
    call AtualizarObstaculos
    call VerificarColisaoObstaculos
    call VerificarColetaMoeda
    call VerificarVitoria
    call AtualizarTela

    load r0, GameState
    loadn r1, #0
    cmp r0, r1
    jeq GameLoop

    loadn r1, #1
    cmp r0, r1
    jeq DoLose

    loadn r1, #2
    cmp r0, r1
    jeq DoWin

    jmp GameLoop

DoLose:
    call TelaDerrota
    jmp MainRestart

DoWin:
    call TelaVitoria
    load r0, ReturnToTitle
    loadn r1, #1
    cmp r0, r1
    jeq main
    jmp MainRestart

; -----------------------------------------------------------------------------
; TelaInicial
; -----------------------------------------------------------------------------
TelaInicial:
    push r0
    push r1
    push r2

    call ClearScreen

    loadn r0, #408  ; row 10, col 8
    loadn r1, #TitleLine1
    loadn r2, #0
    call ImprimeStr

    loadn r0, #482  ; row 12, col 2
    loadn r1, #TitleLine2
    loadn r2, #0
    call ImprimeStr

    call EsperaTecla

    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; InicializarJogo
; - copia o mapa do template para o mapa atual
; - zera score e estado
; - descobre inicio, fim e total de moedas
; -----------------------------------------------------------------------------
InicializarJogo:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    ; copia MapTemplate -> MapCurrent
    loadn r0, #0
    loadn r1, #MapTemplate
    loadn r2, #MapCurrent
    loadn r3, #1230
InitCopyLoop:
    loadi r4, r1
    storei r2, r4
    inc r1
    inc r2
    inc r0
    cmp r0, r3
    jne InitCopyLoop

    ; reset de variaveis
    loadn r0, #0
    store CoinsCollected, r0
    store CoinsTotal, r0
    store GameState, r0
    store ReturnToTitle, r0
    store LastKey, r0
    store MoveAllowed, r0
    store NextRow, r0
    store NextCol, r0
    store LevelIndex, r0

    ; var local: r5 = encontrou inicio?
    loadn r5, #0

    ; varre o mapa para achar J e contar moedas
    loadn r0, #0       ; row
InitRowLoop:
    loadn r1, #41
    mul r2, r0, r1
    loadn r3, #MapCurrent
    add r3, r3, r2     ; base da linha

    loadn r4, #0       ; col
InitColLoop:
    loadi r6, r3

    ; conta moedas
    loadn r7, #'i'
    cmp r6, r7
    jne InitCheckJ
    load r7, CoinsTotal
    inc r7
    store CoinsTotal, r7

InitCheckJ:
    loadn r7, #'J'
    cmp r6, r7
    jne InitNextCell

    loadn r7, #0
    cmp r5, r7
    jeq InitSaveStart

InitSaveEnd:
    store EndRow, r0
    store EndCol, r4
    jmp InitNextCell

InitSaveStart:
    store StartRow, r0
    store StartCol, r4
    store PlayerRow, r0
    store PlayerCol, r4
    loadn r5, #1

InitNextCell:
    inc r3
    inc r4
    loadn r7, #40
    cmp r4, r7
    jne InitColLoop

    inc r0
    loadn r7, #30
    cmp r0, r7
    jne InitRowLoop

    load r0, PlayerRow
    store PrevPlayerRow, r0
    load r0, PlayerCol
    store PrevPlayerCol, r0

    call InicializarObstaculos

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; InicializarObstaculos
; - copia linhas iniciais e direcoes iniciais para o estado atual
; -----------------------------------------------------------------------------
InicializarObstaculos:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r0, #0
    store ObsTick, r0
InitObsLoop:
    loadn r1, #ObsRowInit
    add r1, r1, r0
    loadi r2, r1
    loadn r3, #ObsRows
    add r3, r3, r0
    storei r3, r2

    loadn r1, #ObsDirsInit
    add r1, r1, r0
    loadi r2, r1
    loadn r3, #ObsDirs
    add r3, r3, r0
    storei r3, r2

    inc r0
    loadn r4, #12
    cmp r0, r4
    jne InitObsLoop

    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; LerEntrada
; - le o teclado (inchar) e grava em LastKey
; - se nenhuma tecla (255), grava 0
; -----------------------------------------------------------------------------
LerEntrada:
    push r0
    push r1

    inchar r0
    loadn r1, #255
    cmp r0, r1
    jeq LerEntradaVazia

    store LastKey, r0
    jmp LerEntradaFim

LerEntradaVazia:
    loadn r0, #0
    store LastKey, r0

LerEntradaFim:
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; AtualizarJogador
; - calcula nova posicao e valida contra paredes
; -----------------------------------------------------------------------------
AtualizarJogador:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    load r0, LastKey
    loadn r1, #0
    cmp r0, r1
    jeq AtualizarJogadorFim

    load r2, PlayerRow
    load r3, PlayerCol
    store PrevPlayerRow, r2
    store PrevPlayerCol, r3

    ; W / w
    loadn r4, #'W'
    cmp r0, r4
    jeq MoveUp
    loadn r4, #'w'
    cmp r0, r4
    jeq MoveUp

    ; A / a
    loadn r4, #'A'
    cmp r0, r4
    jeq MoveLeft
    loadn r4, #'a'
    cmp r0, r4
    jeq MoveLeft

    ; S / s
    loadn r4, #'S'
    cmp r0, r4
    jeq MoveDown
    loadn r4, #'s'
    cmp r0, r4
    jeq MoveDown

    ; D / d
    loadn r4, #'D'
    cmp r0, r4
    jeq MoveRight
    loadn r4, #'d'
    cmp r0, r4
    jeq MoveRight

    jmp AtualizarJogadorFim

MoveUp:
    loadn r4, #0
    cmp r2, r4
    jeq AtualizarJogadorFim
    dec r2
    store NextRow, r2
    store NextCol, r3
    jmp CheckMove

MoveLeft:
    loadn r4, #0
    cmp r3, r4
    jeq AtualizarJogadorFim
    dec r3
    store NextRow, r2
    store NextCol, r3
    jmp CheckMove

MoveDown:
    loadn r4, #29
    cmp r2, r4
    jeq AtualizarJogadorFim
    inc r2
    store NextRow, r2
    store NextCol, r3
    jmp CheckMove

MoveRight:
    loadn r4, #39
    cmp r3, r4
    jeq AtualizarJogadorFim
    inc r3
    store NextRow, r2
    store NextCol, r3
    jmp CheckMove

CheckMove:
    call VerificarColisao
    load r4, MoveAllowed
    loadn r5, #1
    cmp r4, r5
    jne AtualizarJogadorFim

    load r2, NextRow
    load r3, NextCol
    store PlayerRow, r2
    store PlayerCol, r3

AtualizarJogadorFim:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; AtualizarObstaculos
; - todos os obstaculos oscilam 5 celulas acima/abaixo da linha inicial
; - inversao sincronizada: ao atingir limite, todos invertem direcao
; - checa colisao com jogador antes e depois do movimento
; -----------------------------------------------------------------------------
AtualizarObstaculos:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    ; controla a velocidade dos obstaculos
    load r0, ObsTick
    inc r0
    store ObsTick, r0
    load r1, ObsTickMax
    cmp r0, r1
    jeg ObsMoveStartNow

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

ObsMoveStartNow:
    loadn r0, #0
    store ObsTick, r0

    loadn r0, #0
    loadn r1, #0
    store ObsFlip, r1

ObsCheckLoop:
    loadn r2, #ObsRows
    add r2, r2, r0
    loadi r3, r2          ; row atual

    loadn r4, #ObsRowInit
    add r4, r4, r0
    loadi r4, r4          ; row inicial

    loadn r5, #5
    add r6, r4, r5        ; limite inferior
    sub r7, r4, r5        ; limite superior

    loadn r2, #ObsDirs
    add r2, r2, r0
    loadi r2, r2          ; direcao

    loadn r5, #1
    cmp r2, r5
    jne ObsCheckUp
    cmp r3, r6
    jne ObsCheckUp
    loadn r1, #1
    store ObsFlip, r1

ObsCheckUp:
    loadn r5, #0
    cmp r2, r5
    jne ObsCheckNext
    cmp r3, r7
    jne ObsCheckNext
    loadn r1, #1
    store ObsFlip, r1

ObsCheckNext:
    inc r0
    loadn r5, #12
    cmp r0, r5
    jne ObsCheckLoop

    load r1, ObsFlip
    loadn r5, #1
    cmp r1, r5
    jne ObsMoveStart

    loadn r0, #0
ObsFlipLoop:
    loadn r2, #ObsDirs
    add r2, r2, r0
    loadi r3, r2
    loadn r5, #1
    cmp r3, r5
    jeq ObsFlipToUp
    loadn r3, #1
    storei r2, r3
    jmp ObsFlipNext

ObsFlipToUp:
    loadn r3, #0
    storei r2, r3

ObsFlipNext:
    inc r0
    loadn r5, #12
    cmp r0, r5
    jne ObsFlipLoop

ObsMoveStart:
    loadn r0, #0

ObsMoveLoop:
    loadn r2, #ObsRows
    add r2, r2, r0
    loadi r3, r2          ; row

    loadn r5, #ObsPrevRows
    add r5, r5, r0
    storei r5, r3

    loadn r4, #ObsCols
    add r4, r4, r0
    loadi r4, r4          ; col

    ; colisao: jogador entrou no obstaculo
    load r5, PlayerRow
    cmp r3, r5
    jne ObsNoPreHit
    load r5, PlayerCol
    cmp r4, r5
    jne ObsNoPreHit
    loadn r5, #1
    store GameState, r5

ObsNoPreHit:
    loadn r6, #ObsDirs
    add r6, r6, r0
    loadi r6, r6          ; direcao

    loadn r7, #1
    cmp r6, r7
    jne ObsMoveUp
    inc r3
    jmp ObsStoreRow

ObsMoveUp:
    dec r3

ObsStoreRow:
    storei r2, r3

    ; colisao: obstaculo entrou no jogador
    load r5, PlayerRow
    cmp r3, r5
    jne ObsNoPostHit
    load r5, PlayerCol
    cmp r4, r5
    jne ObsNoPostHit
    loadn r5, #1
    store GameState, r5

ObsNoPostHit:
    inc r0
    loadn r7, #12
    cmp r0, r7
    jne ObsMoveLoop

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; VerificarColisaoObstaculos
; - checa sobreposicao entre jogador e obstaculos
; -----------------------------------------------------------------------------
VerificarColisaoObstaculos:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r0, #0
ObsColLoop:
    loadn r1, #ObsRows
    add r1, r1, r0
    loadi r2, r1

    loadn r1, #ObsCols
    add r1, r1, r0
    loadi r3, r1

    load r4, PlayerRow
    cmp r2, r4
    jne ObsColNext
    load r4, PlayerCol
    cmp r3, r4
    jne ObsColNext
    loadn r4, #1
    store GameState, r4

ObsColNext:
    inc r0
    loadn r4, #12
    cmp r0, r4
    jne ObsColLoop

    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; VerificarColisao
; - MoveAllowed = 1 se pode mover
; - bloqueia apenas paredes
; -----------------------------------------------------------------------------
VerificarColisao:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6

    loadn r0, #1
    store MoveAllowed, r0

    load r1, NextRow
    load r2, NextCol

    loadn r3, #41
    mul r4, r1, r3
    loadn r5, #MapCurrent
    add r5, r5, r4
    add r5, r5, r2
    loadi r6, r5

    loadn r0, #'#'
    cmp r6, r0
    jne VerificarColisaoFim
    loadn r0, #0
    store MoveAllowed, r0

VerificarColisaoFim:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; VerificarColetaMoeda
; -----------------------------------------------------------------------------
VerificarColetaMoeda:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6

    load r1, PlayerRow
    load r2, PlayerCol

    loadn r3, #41
    mul r4, r1, r3
    loadn r5, #MapCurrent
    add r5, r5, r4
    add r5, r5, r2
    loadi r6, r5

    loadn r0, #'i'
    cmp r6, r0
    jne VerificarColetaFim

    loadn r0, #' '
    storei r5, r0

    load r0, CoinsCollected
    inc r0
    store CoinsCollected, r0

VerificarColetaFim:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; VerificarVitoria
; -----------------------------------------------------------------------------
VerificarVitoria:
    push r0
    push r1
    push r2
    push r3

    load r0, CoinsCollected
    load r1, CoinsTotal
    cmp r0, r1
    jne VerificarVitoriaFim

    load r2, PlayerRow
    load r3, EndRow
    cmp r2, r3
    jne VerificarVitoriaFim

    load r2, PlayerCol
    load r3, EndCol
    cmp r2, r3
    jne VerificarVitoriaFim

    loadn r0, #2
    store GameState, r0

VerificarVitoriaFim:
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; DesenharObstaculos
; -----------------------------------------------------------------------------
DesenharObstaculos:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r0, #0
DrawObsLoop:
    loadn r1, #ObsRows
    add r1, r1, r0
    loadi r2, r1          ; row

    loadn r1, #ObsCols
    add r1, r1, r0
    loadi r3, r1          ; col

    loadn r4, #40
    mul r2, r2, r4
    add r2, r2, r3

    load r4, CharObstacle
    outchar r4, r2

    inc r0
    loadn r4, #12
    cmp r0, r4
    jne DrawObsLoop

    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; DesenharJogador
; -----------------------------------------------------------------------------
DesenharJogador:
    push r0
    push r1
    push r2

    load r0, PlayerRow
    loadn r1, #40
    mul r0, r0, r1
    load r1, PlayerCol
    add r0, r0, r1

    load r2, CharPlayer
    outchar r2, r0

    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; DesenharTela
; - desenha mapa estatico, obstaculos, jogador e score
; -----------------------------------------------------------------------------
DesenharTela:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    loadn r0, #0       ; row
DrawRowLoop:
    loadn r1, #41
    mul r2, r0, r1
    loadn r3, #MapCurrent
    add r3, r3, r2     ; base da linha

    loadn r4, #0       ; col
DrawColLoop:
    loadi r5, r3       ; char do mapa

DrawChar:
    loadn r6, #40
    mul r7, r0, r6
    add r7, r7, r4     ; posicao na tela
    outchar r5, r7

    inc r3
    inc r4
    loadn r6, #40
    cmp r4, r6
    jne DrawColLoop

    inc r0
    loadn r6, #30
    cmp r0, r6
    jne DrawRowLoop

    call DesenharObstaculos
    call DesenharJogador
    call DesenharScore

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; AtualizarTela
; - atualiza somente elementos dinamicos para reduzir flicker e atraso
; -----------------------------------------------------------------------------
AtualizarTela:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    ; limpa posicao anterior do jogador
    load r0, PrevPlayerRow
    load r1, PrevPlayerCol
    loadn r2, #41
    mul r3, r0, r2
    loadn r4, #MapCurrent
    add r4, r4, r3
    add r4, r4, r1
    loadi r5, r4
    loadn r2, #40
    mul r3, r0, r2
    add r3, r3, r1
    outchar r5, r3

    ; limpa posicoes anteriores dos obstaculos
    loadn r0, #0
AtualizaLimpaObs:
    loadn r1, #ObsPrevRows
    add r1, r1, r0
    loadi r2, r1

    loadn r1, #ObsCols
    add r1, r1, r0
    loadi r3, r1

    loadn r4, #41
    mul r5, r2, r4
    loadn r6, #MapCurrent
    add r6, r6, r5
    add r6, r6, r3
    loadi r7, r6

    loadn r4, #40
    mul r5, r2, r4
    add r5, r5, r3
    outchar r7, r5

    inc r0
    loadn r4, #12
    cmp r0, r4
    jne AtualizaLimpaObs

    call DesenharObstaculos
    call DesenharJogador
    call DesenharScore

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; TelaDerrota
; -----------------------------------------------------------------------------
TelaDerrota:
    push r0
    push r1
    push r2

    call ClearScreen

    loadn r0, #496  ; row 12, col 16
    loadn r1, #LoseLine1
    loadn r2, #0
    call ImprimeStr

    loadn r0, #561  ; row 14, col 1
    loadn r1, #LoseLine2
    loadn r2, #0
    call ImprimeStr

    call EsperaTecla

    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; TelaVitoria
; -----------------------------------------------------------------------------
TelaVitoria:
    push r0
    push r1
    push r2

    call ClearScreen

    loadn r0, #494  ; row 12, col 14
    loadn r1, #WinLine1
    loadn r2, #0
    call ImprimeStr

    loadn r0, #563  ; row 14, col 3
    loadn r1, #WinLine2
    loadn r2, #0
    call ImprimeStr

TelaVitoriaLoop:
    inchar r0
    loadn r1, #255
    cmp r0, r1
    jeq TelaVitoriaLoop

    loadn r1, #'S'
    cmp r0, r1
    jeq TelaVitoriaYes
    loadn r1, #'s'
    cmp r0, r1
    jeq TelaVitoriaYes

    loadn r1, #'N'
    cmp r0, r1
    jeq TelaVitoriaNo
    loadn r1, #'n'
    cmp r0, r1
    jeq TelaVitoriaNo

    jmp TelaVitoriaLoop

TelaVitoriaYes:
    loadn r0, #0
    store ReturnToTitle, r0
    pop r2
    pop r1
    pop r0
    rts

TelaVitoriaNo:
    loadn r0, #1
    store ReturnToTitle, r0
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; DesenharScore
; -----------------------------------------------------------------------------
DesenharScore:
    push r0
    push r1
    push r2

    ; "PONTOS: " na linha 0, col 1
    loadn r0, #1
    loadn r1, #ScoreLabel
    loadn r2, #0
    call ImprimeStr

    ; X (moedas coletadas) em pos 9
    load r0, CoinsCollected
    loadn r1, #9
    call Print2Digits

    ; '/' em pos 11
    loadn r0, #'/'
    loadn r1, #11
    outchar r0, r1

    ; Y (total) em pos 12
    load r0, CoinsTotal
    loadn r1, #12
    call Print2Digits

    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; ClearScreen
; -----------------------------------------------------------------------------
ClearScreen:
    push r0
    push r1
    push r2

    loadn r0, #0
    loadn r1, #1200
    loadn r2, #' '
ClearScreenLoop:
    outchar r2, r0
    inc r0
    cmp r0, r1
    jne ClearScreenLoop

    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; EsperaTecla
; -----------------------------------------------------------------------------
EsperaTecla:
    push r0
    push r1

EsperaTeclaLoop:
    inchar r0
    loadn r1, #255
    cmp r0, r1
    jeq EsperaTeclaLoop

    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; ImprimeStr
; r0 = posicao na tela, r1 = endereco da string, r2 = cor (0)
; -----------------------------------------------------------------------------
ImprimeStr:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r3, #'\0'

ImprimeStrLoop:
    loadi r4, r1
    cmp r4, r3
    jeq ImprimeStrSai
    add r4, r2, r4
    outchar r4, r0
    inc r0
    inc r1
    jmp ImprimeStrLoop

ImprimeStrSai:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

; -----------------------------------------------------------------------------
; Print2Digits
; r0 = numero (0..99), r1 = posicao na tela
; -----------------------------------------------------------------------------
Print2Digits:
    push r0
    push r1
    push r2
    push r3

    loadn r2, #10
    div r3, r0, r2
    mul r2, r3, r2
    sub r0, r0, r2

    loadn r2, #48
    add r3, r3, r2
    outchar r3, r1
    inc r1

    add r0, r0, r2
    outchar r0, r1

    pop r3
    pop r2
    pop r1
    pop r0
    rts
