; =============================================================================
; THE HARDEST GAME - Assembly ICMC  v2
; Baseado no prototipo de jogoor.asm
;
; 3 niveis com cenarios completamente diferentes:
;   Nivel 1 - LABIRINTO: corredor simples, obstaculos verticais
;   Nivel 2 - CRUZAMENTO: dois corredores se cruzam, obstaculos em X
;   Nivel 3 - CAOS: campo aberto, obstaculos em todas as direcoes
;
; Controles: W/A/S/D
; Coletar todas as moedas 'i' e chegar em 'J' para vencer o nivel
; Obstaculos 'O' matam ao toque
; =============================================================================

jmp main    ; pula incondicionalmente para main

; =============================================================================
; CONSTANTES (estaticas, inicializadas com static)
;
; "NOME : var #N"       -> reserva N palavras de memoria com o rotulo NOME
; "static NOME, #valor" -> escreve "valor" naquele endereco assim que o
;                          programa carrega (equivale a uma inicializacao)
; =============================================================================
CharWall      : var #1    ; reserva 1 palavra p/ guardar o char+cor da parede
CharPlayer    : var #1    ; reserva 1 palavra p/ guardar o char+cor do jogador
CharCoin      : var #1    ; reserva 1 palavra p/ guardar o char+cor da moeda
CharObstacle  : var #1    ; reserva 1 palavra p/ guardar o char+cor do obstaculo
CharStartEnd  : var #1    ; reserva 1 palavra p/ guardar o char+cor do start/end ('J')
CharSpace     : var #1    ; reserva 1 palavra p/ guardar o char+cor do espaco vazio

static CharWall,     #35    ; '#'
; --- SKINS REAIS (do editor de sprites, char+cor ja embutidos) ---
; formula usada nas skins: valor = char + cor*128 (o char fica nos 7 bits baixos)
static CharPlayer,   #2313   ; cuadradof: char 9 + cor 18
static CharCoin,     #105   ; 'i'  (a moeda eh trocada na hora de desenhar, ver DesenharTela)
static CharObstacle, #523   ; elimina: char 11 + cor 4
static CharStartEnd, #74    ; 'J'
static CharSpace,    #32    ; ' '

KeyNone : var #1    ; reserva 1 palavra p/ guardar o valor "nenhuma tecla" (255)
static KeyNone, #255    ; inicializa KeyNone com 255

; =============================================================================
; VARIAVEIS DO JOGO
; =============================================================================
GameState      : var #1   ; 0=jogando 1=perdeu 2=ganhou nivel
ReturnToTitle  : var #1
LastKey        : var #1

PlayerRow      : var #1
PlayerCol      : var #1
PrevPlayerRow  : var #1
PrevPlayerCol  : var #1
NextRow        : var #1
NextCol        : var #1
MoveAllowed    : var #1

CoinsCollected : var #1
CoinsTotal     : var #1

LevelIndex     : var #1   ; 0, 1, 2

; =============================================================================
; STRINGS DE UI
; "NOME : string "texto"" -> guarda o texto na memoria, um char por posicao,
;                            terminado com um 0 (usado por ImprimeStr pra
;                            saber onde a string acaba)
; =============================================================================
TitleLine1  : string "THE HARDEST GAME"
TitleLine2  : string "W/A/S/D PARA MOVER"
TitleLine3  : string "COLETE AS MOEDAS E CHEGUE EM J"
TitleLine4  : string "APERTE QUALQUER TECLA"

LoseLine1   : string "VOCE MORREU!"
LoseLine2   : string "QUALQUER TECLA PARA TENTAR NOVAMENTE"

WinLine1    : string "NIVEL CONCLUIDO!"
WinLine2    : string "QUALQUER TECLA PARA CONTINUAR"

FinalLine1  : string "VOCE VENCEU O JOGO!"
FinalLine2  : string "S = JOGAR DE NOVO   N = SAIR"

ScoreLabel  : string "MOEDAS:"
NivelLabel  : string "NV:"

; =============================================================================
; MAPA - NIVEL 1: LABIRINTO
; Tema: corredor central com pilares e obstaculos verticais
; 'J' = start (esq) e end (dir), 'i' = moedas
; =============================================================================
Map1:
L1R00 : string "########################################"
L1R01 : string "#                                      #"
L1R02 : string "#  ######    i    i    i   ######   J  #"
L1R03 : string "#  #    #                  #    #      #"
L1R04 : string "#  #    #                  #    #      #"
L1R05 : string "#  #    ######################    #    #"
L1R06 : string "#  #                              #    #"
L1R07 : string "#  #    ######################    #    #"
L1R08 : string "#  #    #                  #    #      #"
L1R09 : string "#  #    #    i    i    i   #    #      #"
L1R10 : string "#  ######                  ######      #"
L1R11 : string "#                                      #"
L1R12 : string "#      #########################       #"
L1R13 : string "#      #                       #       #"
L1R14 : string "# J        i   i   i   i   i   #       #"
L1R15 : string "#      #                       #       #"
L1R16 : string "#      #########################       #"
L1R17 : string "#                                      #"
L1R18 : string "#  ######                  ######      #"
L1R19 : string "#  #    #    i    i    i   #    #      #"
L1R20 : string "#  #    #                  #    #      #"
L1R21 : string "#  #    ######################    #    #"
L1R22 : string "#  #                              #    #"
L1R23 : string "#  #    ######################    #    #"
L1R24 : string "#  #    #                  #    #      #"
L1R25 : string "#  #    #    i    i    i   #    #      #"
L1R26 : string "#  ######                  ######      #"
L1R27 : string "#                                      #"
L1R28 : string "#                                      #"
L1R29 : string "########################################"

; =============================================================================
; MAPA - NIVEL 2: CRUZAMENTO
; Tema: dois corredores (horizontal e vertical) se cruzam no centro
; obstaculos se movem horizontal E vertical
; =============================================================================
Map2:
L2R00 : string "########################################"
L2R01 : string "#         #              #             #"
L2R02 : string "#         #     i        #             #"
L2R03 : string "#         #              #             #"
L2R04 : string "#   i     #              #    i        #"
L2R05 : string "#                        #             #"
L2R06 : string "#         #              #             #"
L2R07 : string "##########                    ##########"
L2R08 : string "#                                      #"
L2R09 : string "#   J        i    i    i      i     J  #"
L2R10 : string "#                                      #"
L2R11 : string "##########                    ##########"
L2R12 : string "#         #              #             #"
L2R13 : string "#   i     #              #    i        #"
L2R14 : string "#         #     i        #             #"
L2R15 : string "#         #              #             #"
L2R16 : string "#         #              #             #"
L2R17 : string "#         ##############               #"
L2R18 : string "#                    #                 #"
L2R19 : string "#    i    i    i     #    i    i    i  #"
L2R20 : string "#                    #                 #"
L2R21 : string "#         ##############               #"
L2R22 : string "#         #                            #"
L2R23 : string "#   i     #              i             #"
L2R24 : string "#         #                            #"
L2R25 : string "#         #                            #"
L2R26 : string "#         #                            #"
L2R27 : string "#                                      #"
L2R28 : string "#                                      #"
L2R29 : string "########################################"

; =============================================================================
; MAPA - NIVEL 3: CAOS
; Tema: campo aberto com ilhas, muitas moedas, obstaculos em todas direcoes
; =============================================================================
Map3:
L3R00 : string "########################################"
L3R01 : string "#  J                               i  #"
L3R02 : string "#      ###    i    i    i    ###      #"
L3R03 : string "#      # #                 # #        #"
L3R04 : string "#      # ###################  #       #"
L3R05 : string "#  i   #                       #   i  #"
L3R06 : string "#      #   ###########         #      #"
L3R07 : string "#      #   #         #         #      #"
L3R08 : string "#  i   #   # i  i  i #         #   i  #"
L3R09 : string "#          #         #                #"
L3R10 : string "#      #####         ###########      #"
L3R11 : string "#                                     #"
L3R12 : string "#  i   #########   #########   i      #"
L3R13 : string "#      #       #   #       #          #"
L3R14 : string "#      # i   i       i   i #          #"
L3R15 : string "#      #       #   #       #          #"
L3R16 : string "#  i   #########   #########   i      #"
L3R17 : string "#                                     #"
L3R18 : string "#      #####         ###########      #"
L3R19 : string "#          #         #                #"
L3R20 : string "#  i   #   # i  i  i #         #   i  #"
L3R21 : string "#      #   #         #         #      #"
L3R22 : string "#      #   ###########         #      #"
L3R23 : string "#  i   #                       #   i  #"
L3R24 : string "#      # ###################  #       #"
L3R25 : string "#      # #                 # #        #"
L3R26 : string "#      ###    i    i    i    ###      #"
L3R27 : string "#                              i      #"
L3R28 : string "#  i                               J  #"
L3R29 : string "########################################"

; =============================================================================
; MAPA ATUAL (buffer de trabalho) - 30 linhas * 41 chars = 1230
; =============================================================================
MapCurrent : var #1230

; =============================================================================
; OBSTACULOS
; Nivel 1: 8 obstaculos verticais (oscilam entre linhas fixas)
; Nivel 2: 6 obstaculos horizontais + 6 verticais
; Nivel 3: 12 obstaculos mistos
; Usamos o maximo de 12 para todos os niveis.
; =============================================================================
ObsCount    : var #1    ; quantos obstaculos o nivel atual realmente usa (<=12)
ObsTick     : var #1    ; contador de frames desde a ultima vez que os obstaculos se moveram
ObsTickMax  : var #1    ; quantos frames esperar entre um movimento e outro dos obstaculos
ObsFlip     : var #1    ; vira 1 quando algum obstaculo bateu no limite e precisa inverter a direcao

; cada array abaixo reserva 12 posicoes (uma por obstaculo). Pra acessar o
; obstaculo de indice N, o codigo faz "NOME + #N" e usa loadi/storei
; (endereco base + deslocamento = acesso tipo vetor/array)
ObsRows     : var #12   ; linha atual de cada obstaculo
ObsPrevRows : var #12   ; linha do frame anterior (usado pra apagar o rastro)
ObsCols     : var #12   ; coluna atual de cada obstaculo
ObsPrevCols : var #12   ; para obstaculos horizontais
ObsDirs     : var #12   ; 0=cima/esq  1=baixo/dir
ObsRowInit  : var #12   ; linha inicial/de referencia (usada pra saber ate onde ele pode andar)
ObsColInit  : var #12   ; coluna inicial/de referencia (idem)
ObsDirsInit : var #12   ; direcao inicial de cada obstaculo
ObsIsHoriz  : var #12   ; 0=vertical 1=horizontal

; --- Nivel 1: 8 obstaculos verticais ---
; Colunas fixas no corredor central, oscilam 5 linhas ao redor do centro
static ObsCount, #8
static ObsTickMax, #5

static ObsCols    + #0,  #10
static ObsCols    + #1,  #14
static ObsCols    + #2,  #18
static ObsCols    + #3,  #22
static ObsCols    + #4,  #26
static ObsCols    + #5,  #30
static ObsCols    + #6,  #10
static ObsCols    + #7,  #14

static ObsColInit + #0,  #10
static ObsColInit + #1,  #14
static ObsColInit + #2,  #18
static ObsColInit + #3,  #22
static ObsColInit + #4,  #26
static ObsColInit + #5,  #30
static ObsColInit + #6,  #10
static ObsColInit + #7,  #14

static ObsRowInit + #0,  #6
static ObsRowInit + #1,  #8
static ObsRowInit + #2,  #6
static ObsRowInit + #3,  #8
static ObsRowInit + #4,  #6
static ObsRowInit + #5,  #8
static ObsRowInit + #6,  #20
static ObsRowInit + #7,  #22

static ObsDirsInit + #0,  #1
static ObsDirsInit + #1,  #0
static ObsDirsInit + #2,  #1
static ObsDirsInit + #3,  #0
static ObsDirsInit + #4,  #1
static ObsDirsInit + #5,  #0
static ObsDirsInit + #6,  #1
static ObsDirsInit + #7,  #0

static ObsIsHoriz + #0,  #0
static ObsIsHoriz + #1,  #0
static ObsIsHoriz + #2,  #0
static ObsIsHoriz + #3,  #0
static ObsIsHoriz + #4,  #0
static ObsIsHoriz + #5,  #0
static ObsIsHoriz + #6,  #0
static ObsIsHoriz + #7,  #0
static ObsIsHoriz + #8,  #0
static ObsIsHoriz + #9,  #0
static ObsIsHoriz + #10, #0
static ObsIsHoriz + #11, #0

; --- Dados temporarios de nivel ---
; Estes arrays guardam a config dos obstaculos para cada nivel
; para podermos trocar ao mudar de nivel

; NIVEL 2: 6 horiz + 6 vert
Lv2ObsCount   : var #1
static Lv2ObsCount, #12

Lv2Cols       : var #12
Lv2Rows       : var #12
Lv2IsHoriz    : var #12
Lv2DirsInit   : var #12
Lv2RowInit    : var #12
Lv2ColInit    : var #12

static Lv2Cols    + #0,  #10   ; horiz no corredor linha 8
static Lv2Cols    + #1,  #18
static Lv2Cols    + #2,  #26
static Lv2Cols    + #3,  #10   ; horiz no corredor linha 19
static Lv2Cols    + #4,  #18
static Lv2Cols    + #5,  #26
static Lv2Cols    + #6,  #20   ; vert nas colunas
static Lv2Cols    + #7,  #20
static Lv2Cols    + #8,  #10
static Lv2Cols    + #9,  #10
static Lv2Cols    + #10, #30
static Lv2Cols    + #11, #30

static Lv2Rows    + #0,  #8
static Lv2Rows    + #1,  #8
static Lv2Rows    + #2,  #8
static Lv2Rows    + #3,  #19
static Lv2Rows    + #4,  #19
static Lv2Rows    + #5,  #19
static Lv2Rows    + #6,  #2
static Lv2Rows    + #7,  #13
static Lv2Rows    + #8,  #2
static Lv2Rows    + #9,  #13
static Lv2Rows    + #10, #2
static Lv2Rows    + #11, #13

static Lv2ColInit + #0,  #10
static Lv2ColInit + #1,  #18
static Lv2ColInit + #2,  #26
static Lv2ColInit + #3,  #10
static Lv2ColInit + #4,  #18
static Lv2ColInit + #5,  #26
static Lv2ColInit + #6,  #20
static Lv2ColInit + #7,  #20
static Lv2ColInit + #8,  #10
static Lv2ColInit + #9,  #10
static Lv2ColInit + #10, #30
static Lv2ColInit + #11, #30

static Lv2RowInit + #0,  #8
static Lv2RowInit + #1,  #8
static Lv2RowInit + #2,  #8
static Lv2RowInit + #3,  #19
static Lv2RowInit + #4,  #19
static Lv2RowInit + #5,  #19
static Lv2RowInit + #6,  #2
static Lv2RowInit + #7,  #13
static Lv2RowInit + #8,  #2
static Lv2RowInit + #9,  #13
static Lv2RowInit + #10, #2
static Lv2RowInit + #11, #13

static Lv2DirsInit + #0,  #1
static Lv2DirsInit + #1,  #0
static Lv2DirsInit + #2,  #1
static Lv2DirsInit + #3,  #0
static Lv2DirsInit + #4,  #1
static Lv2DirsInit + #5,  #0
static Lv2DirsInit + #6,  #1
static Lv2DirsInit + #7,  #0
static Lv2DirsInit + #8,  #1
static Lv2DirsInit + #9,  #0
static Lv2DirsInit + #10, #1
static Lv2DirsInit + #11, #0

static Lv2IsHoriz + #0,  #1
static Lv2IsHoriz + #1,  #1
static Lv2IsHoriz + #2,  #1
static Lv2IsHoriz + #3,  #1
static Lv2IsHoriz + #4,  #1
static Lv2IsHoriz + #5,  #1
static Lv2IsHoriz + #6,  #0
static Lv2IsHoriz + #7,  #0
static Lv2IsHoriz + #8,  #0
static Lv2IsHoriz + #9,  #0
static Lv2IsHoriz + #10, #0
static Lv2IsHoriz + #11, #0

; NIVEL 3: 12 obstaculos mistos (mais caos)
Lv3ObsCount  : var #1
static Lv3ObsCount, #12

Lv3Cols      : var #12
Lv3Rows      : var #12
Lv3IsHoriz   : var #12
Lv3DirsInit  : var #12
Lv3RowInit   : var #12
Lv3ColInit   : var #12

static Lv3Cols    + #0,  #8
static Lv3Cols    + #1,  #16
static Lv3Cols    + #2,  #24
static Lv3Cols    + #3,  #32
static Lv3Cols    + #4,  #8
static Lv3Cols    + #5,  #16
static Lv3Cols    + #6,  #24
static Lv3Cols    + #7,  #32
static Lv3Cols    + #8,  #12
static Lv3Cols    + #9,  #20
static Lv3Cols    + #10, #28
static Lv3Cols    + #11, #36

static Lv3Rows    + #0,  #5
static Lv3Rows    + #1,  #5
static Lv3Rows    + #2,  #5
static Lv3Rows    + #3,  #5
static Lv3Rows    + #4,  #20
static Lv3Rows    + #5,  #20
static Lv3Rows    + #6,  #20
static Lv3Rows    + #7,  #20
static Lv3Rows    + #8,  #12
static Lv3Rows    + #9,  #12
static Lv3Rows    + #10, #12
static Lv3Rows    + #11, #12

static Lv3ColInit + #0,  #8
static Lv3ColInit + #1,  #16
static Lv3ColInit + #2,  #24
static Lv3ColInit + #3,  #32
static Lv3ColInit + #4,  #8
static Lv3ColInit + #5,  #16
static Lv3ColInit + #6,  #24
static Lv3ColInit + #7,  #32
static Lv3ColInit + #8,  #12
static Lv3ColInit + #9,  #20
static Lv3ColInit + #10, #28
static Lv3ColInit + #11, #36

static Lv3RowInit + #0,  #5
static Lv3RowInit + #1,  #5
static Lv3RowInit + #2,  #5
static Lv3RowInit + #3,  #5
static Lv3RowInit + #4,  #20
static Lv3RowInit + #5,  #20
static Lv3RowInit + #6,  #20
static Lv3RowInit + #7,  #20
static Lv3RowInit + #8,  #12
static Lv3RowInit + #9,  #12
static Lv3RowInit + #10, #12
static Lv3RowInit + #11, #12

static Lv3DirsInit + #0,  #1
static Lv3DirsInit + #1,  #0
static Lv3DirsInit + #2,  #1
static Lv3DirsInit + #3,  #0
static Lv3DirsInit + #4,  #0
static Lv3DirsInit + #5,  #1
static Lv3DirsInit + #6,  #0
static Lv3DirsInit + #7,  #1
static Lv3DirsInit + #8,  #1
static Lv3DirsInit + #9,  #0
static Lv3DirsInit + #10, #1
static Lv3DirsInit + #11, #0

static Lv3IsHoriz + #0,  #0
static Lv3IsHoriz + #1,  #0
static Lv3IsHoriz + #2,  #0
static Lv3IsHoriz + #3,  #0
static Lv3IsHoriz + #4,  #0
static Lv3IsHoriz + #5,  #0
static Lv3IsHoriz + #6,  #0
static Lv3IsHoriz + #7,  #0
static Lv3IsHoriz + #8,  #1
static Lv3IsHoriz + #9,  #1
static Lv3IsHoriz + #10, #1
static Lv3IsHoriz + #11, #1

; =============================================================================
; PONTEIROS PARA MAPAS (resolvidos com loadn)
MapPtr    : var #1   ; guarda o endereco do mapa atual

; =============================================================================
; FLUXO PRINCIPAL
; =============================================================================
main:
    call TelaInicial    ; chama a sub-rotina TelaInicial (guarda o endereco de retorno e desvia para la)

MainRestart:
    load r0, LevelIndex    ; r0 recebe o valor atual guardado na variavel LevelIndex
    loadn r1, #0    ; r1 recebe o numero literal 0
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq SetupLevel1    ; se a comparacao anterior deu IGUAL, pula para SetupLevel1

    loadn r1, #1    ; r1 recebe o numero literal 1
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq SetupLevel2    ; se a comparacao anterior deu IGUAL, pula para SetupLevel2

    jmp SetupLevel3    ; pula incondicionalmente para SetupLevel3

SetupLevel1:
    loadn r0, #Map1    ; r0 recebe o endereco de "Map1" (constante/rotulo, nao o conteudo)
    store MapPtr, r0    ; guarda o valor de r0 na variavel MapPtr
    call CarregarObstaculosNivel1    ; chama a sub-rotina CarregarObstaculosNivel1 (guarda o endereco de retorno e desvia para la)
    jmp DoInit    ; pula incondicionalmente para DoInit

SetupLevel2:
    loadn r0, #Map2    ; r0 recebe o endereco de "Map2" (constante/rotulo, nao o conteudo)
    store MapPtr, r0    ; guarda o valor de r0 na variavel MapPtr
    call CarregarObstaculosNivel2    ; chama a sub-rotina CarregarObstaculosNivel2 (guarda o endereco de retorno e desvia para la)
    jmp DoInit    ; pula incondicionalmente para DoInit

SetupLevel3:
    loadn r0, #Map3    ; r0 recebe o endereco de "Map3" (constante/rotulo, nao o conteudo)
    store MapPtr, r0    ; guarda o valor de r0 na variavel MapPtr
    call CarregarObstaculosNivel3    ; chama a sub-rotina CarregarObstaculosNivel3 (guarda o endereco de retorno e desvia para la)

DoInit:
    call InicializarJogo    ; chama a sub-rotina InicializarJogo (guarda o endereco de retorno e desvia para la)
    call DesenharTela    ; chama a sub-rotina DesenharTela (guarda o endereco de retorno e desvia para la)

GameLoop:
    call LerEntrada    ; chama a sub-rotina LerEntrada (guarda o endereco de retorno e desvia para la)
    call AtualizarJogador    ; chama a sub-rotina AtualizarJogador (guarda o endereco de retorno e desvia para la)
    call AtualizarObstaculos    ; chama a sub-rotina AtualizarObstaculos (guarda o endereco de retorno e desvia para la)
    call VerificarColisaoObstaculos    ; chama a sub-rotina VerificarColisaoObstaculos (guarda o endereco de retorno e desvia para la)
    call VerificarColetaMoeda    ; chama a sub-rotina VerificarColetaMoeda (guarda o endereco de retorno e desvia para la)
    call VerificarVitoria    ; chama a sub-rotina VerificarVitoria (guarda o endereco de retorno e desvia para la)
    call AtualizarTela    ; chama a sub-rotina AtualizarTela (guarda o endereco de retorno e desvia para la)

    load r0, GameState    ; r0 recebe o valor atual guardado na variavel GameState
    loadn r1, #0    ; r1 recebe o numero literal 0
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq GameLoop    ; se a comparacao anterior deu IGUAL, pula para GameLoop

    loadn r1, #1    ; r1 recebe o numero literal 1
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq DoLose    ; se a comparacao anterior deu IGUAL, pula para DoLose

    loadn r1, #2    ; r1 recebe o numero literal 2
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq DoWin    ; se a comparacao anterior deu IGUAL, pula para DoWin

    jmp GameLoop    ; pula incondicionalmente para GameLoop

DoLose:
    call TelaDerrota    ; chama a sub-rotina TelaDerrota (guarda o endereco de retorno e desvia para la)
    jmp MainRestart    ; pula incondicionalmente para MainRestart

DoWin:
    ; avanca nivel
    load r0, LevelIndex    ; r0 recebe o valor atual guardado na variavel LevelIndex
    inc r0    ; incrementa r0 em 1 (soma 1)
    store LevelIndex, r0    ; guarda o valor de r0 na variavel LevelIndex
    loadn r1, #3    ; r1 recebe o numero literal 3
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jle ProximoNivel    ; se a comparacao anterior deu MENOR OU IGUAL, pula para ProximoNivel
    ; completou todos os 3 niveis
    call TelaVitoriaFinal    ; chama a sub-rotina TelaVitoriaFinal (guarda o endereco de retorno e desvia para la)
    load r0, ReturnToTitle    ; r0 recebe o valor atual guardado na variavel ReturnToTitle
    loadn r1, #1    ; r1 recebe o numero literal 1
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq VoltarTitulo    ; se a comparacao anterior deu IGUAL, pula para VoltarTitulo
    ; reinicia do nivel 1
    loadn r0, #0    ; r0 recebe o numero literal 0
    store LevelIndex, r0    ; guarda o valor de r0 na variavel LevelIndex
    jmp MainRestart    ; pula incondicionalmente para MainRestart

ProximoNivel:
    call TelaNivelConcluido    ; chama a sub-rotina TelaNivelConcluido (guarda o endereco de retorno e desvia para la)
    jmp MainRestart    ; pula incondicionalmente para MainRestart

VoltarTitulo:
    loadn r0, #0    ; r0 recebe o numero literal 0
    store LevelIndex, r0    ; guarda o valor de r0 na variavel LevelIndex
    jmp main    ; pula incondicionalmente para main

; =============================================================================
; CarregarObstaculosNivel1
; Copia dados estaticos do nivel 1 (ja em ObsCols etc via static)
; =============================================================================
CarregarObstaculosNivel1:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #8    ; r0 recebe o numero literal 8
    store ObsCount, r0    ; guarda o valor de r0 na variavel ObsCount
    loadn r0, #5    ; r0 recebe o numero literal 5
    store ObsTickMax, r0    ; guarda o valor de r0 na variavel ObsTickMax

    ; ObsCols e ObsRowInit e ObsDirsInit e ObsIsHoriz ja estao
    ; setados pelos static acima para o nivel 1.
    ; Nada a fazer aqui alem de resetar o tick.
    loadn r0, #0    ; r0 recebe o numero literal 0
    store ObsTick, r0    ; guarda o valor de r0 na variavel ObsTick

    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; CarregarObstaculosNivel2
; Copia Lv2* -> Obs*
; =============================================================================
CarregarObstaculosNivel2:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r0, Lv2ObsCount    ; r0 recebe o valor atual guardado na variavel Lv2ObsCount
    store ObsCount, r0    ; guarda o valor de r0 na variavel ObsCount
    loadn r0, #4    ; r0 recebe o numero literal 4
    store ObsTickMax, r0    ; guarda o valor de r0 na variavel ObsTickMax
    loadn r0, #0    ; r0 recebe o numero literal 0
    store ObsTick, r0    ; guarda o valor de r0 na variavel ObsTick

    loadn r0, #0    ; r0 recebe o numero literal 0
Lv2CopyLoop:
    ; ObsCols
    loadn r1, #Lv2Cols    ; r1 recebe o endereco de "Lv2Cols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsCols    ; r3 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; ObsColInit
    loadn r1, #Lv2ColInit    ; r1 recebe o endereco de "Lv2ColInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsColInit    ; r3 recebe o endereco de "ObsColInit" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; ObsRows
    loadn r1, #Lv2Rows    ; r1 recebe o endereco de "Lv2Rows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsRows    ; r3 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; ObsRowInit
    loadn r1, #Lv2RowInit    ; r1 recebe o endereco de "Lv2RowInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsRowInit    ; r3 recebe o endereco de "ObsRowInit" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; ObsDirsInit
    loadn r1, #Lv2DirsInit    ; r1 recebe o endereco de "Lv2DirsInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsDirsInit    ; r3 recebe o endereco de "ObsDirsInit" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; ObsIsHoriz
    loadn r1, #Lv2IsHoriz    ; r1 recebe o endereco de "Lv2IsHoriz" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsIsHoriz    ; r3 recebe o endereco de "ObsIsHoriz" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    inc r0    ; incrementa r0 em 1 (soma 1)
    loadn r4, #12    ; r4 recebe o numero literal 12
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne Lv2CopyLoop    ; se a comparacao anterior deu DIFERENTE, pula para Lv2CopyLoop

    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; CarregarObstaculosNivel3
; =============================================================================
CarregarObstaculosNivel3:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r0, Lv3ObsCount    ; r0 recebe o valor atual guardado na variavel Lv3ObsCount
    store ObsCount, r0    ; guarda o valor de r0 na variavel ObsCount
    loadn r0, #3    ; r0 recebe o numero literal 3
    store ObsTickMax, r0    ; guarda o valor de r0 na variavel ObsTickMax
    loadn r0, #0    ; r0 recebe o numero literal 0
    store ObsTick, r0    ; guarda o valor de r0 na variavel ObsTick

    loadn r0, #0    ; r0 recebe o numero literal 0
Lv3CopyLoop:
    loadn r1, #Lv3Cols    ; r1 recebe o endereco de "Lv3Cols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsCols    ; r3 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #Lv3ColInit    ; r1 recebe o endereco de "Lv3ColInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsColInit    ; r3 recebe o endereco de "ObsColInit" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #Lv3Rows    ; r1 recebe o endereco de "Lv3Rows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsRows    ; r3 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #Lv3RowInit    ; r1 recebe o endereco de "Lv3RowInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsRowInit    ; r3 recebe o endereco de "ObsRowInit" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #Lv3DirsInit    ; r1 recebe o endereco de "Lv3DirsInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsDirsInit    ; r3 recebe o endereco de "ObsDirsInit" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #Lv3IsHoriz    ; r1 recebe o endereco de "Lv3IsHoriz" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsIsHoriz    ; r3 recebe o endereco de "ObsIsHoriz" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    inc r0    ; incrementa r0 em 1 (soma 1)
    loadn r4, #12    ; r4 recebe o numero literal 12
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne Lv3CopyLoop    ; se a comparacao anterior deu DIFERENTE, pula para Lv3CopyLoop

    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; InicializarJogo
; =============================================================================
InicializarJogo:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r7    ; salva r7 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    ; copia MapPtr -> MapCurrent (1230 chars)
    loadn r0, #0    ; r0 recebe o numero literal 0
    load r1, MapPtr    ; r1 recebe o valor atual guardado na variavel MapPtr
    loadn r2, #MapCurrent    ; r2 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    loadn r3, #1230    ; r3 recebe o numero literal 1230
InitCopyLoop:
    loadi r4, r1    ; r4 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    storei r2, r4    ; guarda o valor de r4 no endereco de memoria apontado por r2 (escrita indireta, tipo ponteiro)
    inc r1    ; incrementa r1 em 1 (soma 1)
    inc r2    ; incrementa r2 em 1 (soma 1)
    inc r0    ; incrementa r0 em 1 (soma 1)
    cmp r0, r3    ; compara r0 com r3 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne InitCopyLoop    ; se a comparacao anterior deu DIFERENTE, pula para InitCopyLoop

    ; zera variaveis
    loadn r0, #0    ; r0 recebe o numero literal 0
    store CoinsCollected, r0    ; guarda o valor de r0 na variavel CoinsCollected
    store CoinsTotal, r0    ; guarda o valor de r0 na variavel CoinsTotal
    store GameState, r0    ; guarda o valor de r0 na variavel GameState
    store ReturnToTitle, r0    ; guarda o valor de r0 na variavel ReturnToTitle
    store LastKey, r0    ; guarda o valor de r0 na variavel LastKey
    store MoveAllowed, r0    ; guarda o valor de r0 na variavel MoveAllowed
    store NextRow, r0    ; guarda o valor de r0 na variavel NextRow
    store NextCol, r0    ; guarda o valor de r0 na variavel NextCol

    ; encontra J e conta moedas
    loadn r5, #0   ; encontrou primeiro J?

    loadn r0, #0   ; row
InitRowLoop:
    loadn r1, #41    ; r1 recebe o numero literal 41
    mul r2, r0, r1    ; r2 recebe r0 * r1
    loadn r3, #MapCurrent    ; r3 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    add r3, r3, r2    ; r3 recebe r3 + r2

    loadn r4, #0   ; col
InitColLoop:
    loadi r6, r3    ; r6 recebe o valor guardado no endereco de memoria apontado por r3 (leitura indireta, tipo ponteiro)

    ; conta moeda
    loadn r7, #105   ; 'i'
    cmp r6, r7    ; compara r6 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne InitCheckJ    ; se a comparacao anterior deu DIFERENTE, pula para InitCheckJ
    load r7, CoinsTotal    ; r7 recebe o valor atual guardado na variavel CoinsTotal
    inc r7    ; incrementa r7 em 1 (soma 1)
    store CoinsTotal, r7    ; guarda o valor de r7 na variavel CoinsTotal

InitCheckJ:
    loadn r7, #74    ; 'J'
    cmp r6, r7    ; compara r6 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne InitNextCell    ; se a comparacao anterior deu DIFERENTE, pula para InitNextCell

    loadn r7, #0    ; r7 recebe o numero literal 0
    cmp r5, r7    ; compara r5 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq InitSaveStart    ; se a comparacao anterior deu IGUAL, pula para InitSaveStart

InitSaveEnd:
    store EndRow, r0    ; guarda o valor de r0 na variavel EndRow
    store EndCol, r4    ; guarda o valor de r4 na variavel EndCol
    jmp InitNextCell    ; pula incondicionalmente para InitNextCell

InitSaveStart:
    store StartRow, r0    ; guarda o valor de r0 na variavel StartRow
    store StartCol, r4    ; guarda o valor de r4 na variavel StartCol
    store PlayerRow, r0    ; guarda o valor de r0 na variavel PlayerRow
    store PlayerCol, r4    ; guarda o valor de r4 na variavel PlayerCol
    loadn r5, #1    ; r5 recebe o numero literal 1

InitNextCell:
    inc r3    ; incrementa r3 em 1 (soma 1)
    inc r4    ; incrementa r4 em 1 (soma 1)
    loadn r7, #40    ; r7 recebe o numero literal 40
    cmp r4, r7    ; compara r4 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne InitColLoop    ; se a comparacao anterior deu DIFERENTE, pula para InitColLoop

    inc r0    ; incrementa r0 em 1 (soma 1)
    loadn r7, #30    ; r7 recebe o numero literal 30
    cmp r0, r7    ; compara r0 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne InitRowLoop    ; se a comparacao anterior deu DIFERENTE, pula para InitRowLoop

    load r0, PlayerRow    ; r0 recebe o valor atual guardado na variavel PlayerRow
    store PrevPlayerRow, r0    ; guarda o valor de r0 na variavel PrevPlayerRow
    load r0, PlayerCol    ; r0 recebe o valor atual guardado na variavel PlayerCol
    store PrevPlayerCol, r0    ; guarda o valor de r0 na variavel PrevPlayerCol

    call InicializarObstaculos    ; chama a sub-rotina InicializarObstaculos (guarda o endereco de retorno e desvia para la)

    pop r7    ; restaura r7 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; --- variaveis auxiliares de InicializarJogo ---
StartRow : var #1
StartCol : var #1
EndRow   : var #1
EndCol   : var #1

; =============================================================================
; InicializarObstaculos
; =============================================================================
InicializarObstaculos:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #0    ; r0 recebe o numero literal 0
    store ObsTick, r0    ; guarda o valor de r0 na variavel ObsTick

InitObsLoop:
    loadn r1, #ObsRowInit    ; r1 recebe o endereco de "ObsRowInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsRows    ; r3 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #ObsColInit    ; r1 recebe o endereco de "ObsColInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsCols    ; r3 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #ObsDirsInit    ; r1 recebe o endereco de "ObsDirsInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsDirs    ; r3 recebe o endereco de "ObsDirs" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; PrevRows = Rows, PrevCols = Cols
    loadn r1, #ObsRowInit    ; r1 recebe o endereco de "ObsRowInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsPrevRows    ; r3 recebe o endereco de "ObsPrevRows" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #ObsColInit    ; r1 recebe o endereco de "ObsColInit" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsPrevCols    ; r3 recebe o endereco de "ObsPrevCols" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    inc r0    ; incrementa r0 em 1 (soma 1)
    loadn r4, #12    ; r4 recebe o numero literal 12
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne InitObsLoop    ; se a comparacao anterior deu DIFERENTE, pula para InitObsLoop

    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; LerEntrada
; =============================================================================
LerEntrada:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    inchar r0    ; r0 recebe o codigo da tecla pressionada AGORA (255 se nenhuma tecla estiver pressionada)
    loadn r1, #255    ; r1 recebe o numero literal 255
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq LerEntradaVazia    ; se a comparacao anterior deu IGUAL, pula para LerEntradaVazia

    store LastKey, r0    ; guarda o valor de r0 na variavel LastKey
    jmp LerEntradaFim    ; pula incondicionalmente para LerEntradaFim

LerEntradaVazia:
    loadn r0, #0    ; r0 recebe o numero literal 0
    store LastKey, r0    ; guarda o valor de r0 na variavel LastKey

LerEntradaFim:
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; AtualizarJogador
; =============================================================================
AtualizarJogador:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r7    ; salva r7 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r0, LastKey    ; r0 recebe o valor atual guardado na variavel LastKey
    loadn r1, #0    ; r1 recebe o numero literal 0
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq AtualizarJogadorFim    ; se a comparacao anterior deu IGUAL, pula para AtualizarJogadorFim

    load r2, PlayerRow    ; r2 recebe o valor atual guardado na variavel PlayerRow
    load r3, PlayerCol    ; r3 recebe o valor atual guardado na variavel PlayerCol
    store PrevPlayerRow, r2    ; guarda o valor de r2 na variavel PrevPlayerRow
    store PrevPlayerCol, r3    ; guarda o valor de r3 na variavel PrevPlayerCol

    loadn r4, #87    ; 'W'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveUp    ; se a comparacao anterior deu IGUAL, pula para MoveUp
    loadn r4, #119   ; 'w'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveUp    ; se a comparacao anterior deu IGUAL, pula para MoveUp

    loadn r4, #65    ; 'A'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveLeft    ; se a comparacao anterior deu IGUAL, pula para MoveLeft
    loadn r4, #97    ; 'a'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveLeft    ; se a comparacao anterior deu IGUAL, pula para MoveLeft

    loadn r4, #83    ; 'S'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveDown    ; se a comparacao anterior deu IGUAL, pula para MoveDown
    loadn r4, #115   ; 's'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveDown    ; se a comparacao anterior deu IGUAL, pula para MoveDown

    loadn r4, #68    ; 'D'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveRight    ; se a comparacao anterior deu IGUAL, pula para MoveRight
    loadn r4, #100   ; 'd'
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq MoveRight    ; se a comparacao anterior deu IGUAL, pula para MoveRight

    jmp AtualizarJogadorFim    ; pula incondicionalmente para AtualizarJogadorFim

MoveUp:
    loadn r4, #0    ; r4 recebe o numero literal 0
    cmp r2, r4    ; compara r2 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq AtualizarJogadorFim    ; se a comparacao anterior deu IGUAL, pula para AtualizarJogadorFim
    dec r2    ; decrementa r2 em 1 (subtrai 1)
    store NextRow, r2    ; guarda o valor de r2 na variavel NextRow
    store NextCol, r3    ; guarda o valor de r3 na variavel NextCol
    jmp CheckMove    ; pula incondicionalmente para CheckMove

MoveLeft:
    loadn r4, #0    ; r4 recebe o numero literal 0
    cmp r3, r4    ; compara r3 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq AtualizarJogadorFim    ; se a comparacao anterior deu IGUAL, pula para AtualizarJogadorFim
    dec r3    ; decrementa r3 em 1 (subtrai 1)
    store NextRow, r2    ; guarda o valor de r2 na variavel NextRow
    store NextCol, r3    ; guarda o valor de r3 na variavel NextCol
    jmp CheckMove    ; pula incondicionalmente para CheckMove

MoveDown:
    loadn r4, #29    ; r4 recebe o numero literal 29
    cmp r2, r4    ; compara r2 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq AtualizarJogadorFim    ; se a comparacao anterior deu IGUAL, pula para AtualizarJogadorFim
    inc r2    ; incrementa r2 em 1 (soma 1)
    store NextRow, r2    ; guarda o valor de r2 na variavel NextRow
    store NextCol, r3    ; guarda o valor de r3 na variavel NextCol
    jmp CheckMove    ; pula incondicionalmente para CheckMove

MoveRight:
    loadn r4, #39    ; r4 recebe o numero literal 39
    cmp r3, r4    ; compara r3 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq AtualizarJogadorFim    ; se a comparacao anterior deu IGUAL, pula para AtualizarJogadorFim
    inc r3    ; incrementa r3 em 1 (soma 1)
    store NextRow, r2    ; guarda o valor de r2 na variavel NextRow
    store NextCol, r3    ; guarda o valor de r3 na variavel NextCol

CheckMove:
    call VerificarColisao    ; chama a sub-rotina VerificarColisao (guarda o endereco de retorno e desvia para la)
    load r4, MoveAllowed    ; r4 recebe o valor atual guardado na variavel MoveAllowed
    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r4, r5    ; compara r4 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne AtualizarJogadorFim    ; se a comparacao anterior deu DIFERENTE, pula para AtualizarJogadorFim

    load r2, NextRow    ; r2 recebe o valor atual guardado na variavel NextRow
    load r3, NextCol    ; r3 recebe o valor atual guardado na variavel NextCol
    store PlayerRow, r2    ; guarda o valor de r2 na variavel PlayerRow
    store PlayerCol, r3    ; guarda o valor de r3 na variavel PlayerCol

AtualizarJogadorFim:
    pop r7    ; restaura r7 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; AtualizarObstaculos
; Suporta obstaculos horizontais E verticais (ObsIsHoriz)
; =============================================================================
AtualizarObstaculos:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r7    ; salva r7 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r0, ObsTick    ; r0 recebe o valor atual guardado na variavel ObsTick
    inc r0    ; incrementa r0 em 1 (soma 1)
    store ObsTick, r0    ; guarda o valor de r0 na variavel ObsTick
    load r1, ObsTickMax    ; r1 recebe o valor atual guardado na variavel ObsTickMax
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq ObsMoveStartNow    ; se a comparacao anterior deu IGUAL, pula para ObsMoveStartNow

    pop r7    ; restaura r7 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

ObsMoveStartNow:
    loadn r0, #0    ; r0 recebe o numero literal 0
    store ObsTick, r0    ; guarda o valor de r0 na variavel ObsTick
    loadn r0, #0    ; r0 recebe o numero literal 0
    store ObsFlip, r0    ; guarda o valor de r0 na variavel ObsFlip

    ; --- verifica se algum obstaculo chegou no limite ---
    loadn r0, #0    ; r0 recebe o numero literal 0
ObsCheckLoop:
    loadn r1, #ObsIsHoriz    ; r1 recebe o endereco de "ObsIsHoriz" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r1, r1      ; 0=vert 1=horiz

    loadn r2, #1    ; r2 recebe o numero literal 1
    cmp r1, r2    ; compara r1 com r2 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq ObsCheckHoriz    ; se a comparacao anterior deu IGUAL, pula para ObsCheckHoriz

    ; vertical: compara row com rowInit +/- 5
    loadn r2, #ObsRows    ; r2 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r2, r2, r0    ; r2 recebe r2 + r0
    loadi r3, r2      ; row atual

    loadn r4, #ObsRowInit    ; r4 recebe o endereco de "ObsRowInit" (constante/rotulo, nao o conteudo)
    add r4, r4, r0    ; r4 recebe r4 + r0
    loadi r4, r4    ; r4 recebe o valor guardado no endereco de memoria apontado por r4 (leitura indireta, tipo ponteiro)

    loadn r5, #5    ; r5 recebe o numero literal 5
    add r6, r4, r5    ; r6 recebe r4 + r5
    sub r7, r4, r5    ; r7 recebe r4 - r5

    loadn r2, #ObsDirs    ; r2 recebe o endereco de "ObsDirs" (constante/rotulo, nao o conteudo)
    add r2, r2, r0    ; r2 recebe r2 + r0
    loadi r2, r2    ; r2 recebe o valor guardado no endereco de memoria apontado por r2 (leitura indireta, tipo ponteiro)

    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r2, r5    ; compara r2 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckVertUp    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckVertUp
    cmp r3, r6    ; compara r3 com r6 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckNext    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckNext
    loadn r5, #1    ; r5 recebe o numero literal 1
    store ObsFlip, r5    ; guarda o valor de r5 na variavel ObsFlip
    jmp ObsCheckNext    ; pula incondicionalmente para ObsCheckNext

ObsCheckVertUp:
    cmp r3, r7    ; compara r3 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckNext    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckNext
    loadn r5, #1    ; r5 recebe o numero literal 1
    store ObsFlip, r5    ; guarda o valor de r5 na variavel ObsFlip
    jmp ObsCheckNext    ; pula incondicionalmente para ObsCheckNext

ObsCheckHoriz:
    ; horizontal: compara col com colInit +/- 6
    loadn r2, #ObsCols    ; r2 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r2, r2, r0    ; r2 recebe r2 + r0
    loadi r3, r2      ; col atual

    loadn r4, #ObsColInit    ; r4 recebe o endereco de "ObsColInit" (constante/rotulo, nao o conteudo)
    add r4, r4, r0    ; r4 recebe r4 + r0
    loadi r4, r4    ; r4 recebe o valor guardado no endereco de memoria apontado por r4 (leitura indireta, tipo ponteiro)

    loadn r5, #6    ; r5 recebe o numero literal 6
    add r6, r4, r5    ; r6 recebe r4 + r5
    sub r7, r4, r5    ; r7 recebe r4 - r5

    loadn r2, #ObsDirs    ; r2 recebe o endereco de "ObsDirs" (constante/rotulo, nao o conteudo)
    add r2, r2, r0    ; r2 recebe r2 + r0
    loadi r2, r2    ; r2 recebe o valor guardado no endereco de memoria apontado por r2 (leitura indireta, tipo ponteiro)

    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r2, r5    ; compara r2 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckHorizLeft    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckHorizLeft
    cmp r3, r6    ; compara r3 com r6 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckNext    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckNext
    loadn r5, #1    ; r5 recebe o numero literal 1
    store ObsFlip, r5    ; guarda o valor de r5 na variavel ObsFlip
    jmp ObsCheckNext    ; pula incondicionalmente para ObsCheckNext

ObsCheckHorizLeft:
    cmp r3, r7    ; compara r3 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckNext    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckNext
    loadn r5, #1    ; r5 recebe o numero literal 1
    store ObsFlip, r5    ; guarda o valor de r5 na variavel ObsFlip

ObsCheckNext:
    inc r0    ; incrementa r0 em 1 (soma 1)
    load r4, ObsCount    ; r4 recebe o valor atual guardado na variavel ObsCount
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsCheckLoop    ; se a comparacao anterior deu DIFERENTE, pula para ObsCheckLoop

    ; --- inverte direcao se necessario ---
    load r1, ObsFlip    ; r1 recebe o valor atual guardado na variavel ObsFlip
    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r1, r5    ; compara r1 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsMoveStart    ; se a comparacao anterior deu DIFERENTE, pula para ObsMoveStart

    loadn r0, #0    ; r0 recebe o numero literal 0
ObsFlipLoop:
    loadn r2, #ObsDirs    ; r2 recebe o endereco de "ObsDirs" (constante/rotulo, nao o conteudo)
    add r2, r2, r0    ; r2 recebe r2 + r0
    loadi r3, r2    ; r3 recebe o valor guardado no endereco de memoria apontado por r2 (leitura indireta, tipo ponteiro)
    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r3, r5    ; compara r3 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq ObsFlipToUp    ; se a comparacao anterior deu IGUAL, pula para ObsFlipToUp
    loadn r3, #1    ; r3 recebe o numero literal 1
    storei r2, r3    ; guarda o valor de r3 no endereco de memoria apontado por r2 (escrita indireta, tipo ponteiro)
    jmp ObsFlipNext    ; pula incondicionalmente para ObsFlipNext

ObsFlipToUp:
    loadn r3, #0    ; r3 recebe o numero literal 0
    storei r2, r3    ; guarda o valor de r3 no endereco de memoria apontado por r2 (escrita indireta, tipo ponteiro)

ObsFlipNext:
    inc r0    ; incrementa r0 em 1 (soma 1)
    load r4, ObsCount    ; r4 recebe o valor atual guardado na variavel ObsCount
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsFlipLoop    ; se a comparacao anterior deu DIFERENTE, pula para ObsFlipLoop

    ; --- move cada obstaculo ---
ObsMoveStart:
    loadn r0, #0    ; r0 recebe o numero literal 0

ObsMoveLoop:
    ; salva posicao anterior
    loadn r1, #ObsRows    ; r1 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsPrevRows    ; r3 recebe o endereco de "ObsPrevRows" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    loadn r1, #ObsCols    ; r1 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    loadn r3, #ObsPrevCols    ; r3 recebe o endereco de "ObsPrevCols" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    storei r3, r2    ; guarda o valor de r2 no endereco de memoria apontado por r3 (escrita indireta, tipo ponteiro)

    ; col e row atuais
    loadn r4, #ObsCols    ; r4 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r4, r4, r0    ; r4 recebe r4 + r0
    loadi r4, r4      ; col

    loadn r3, #ObsRows    ; r3 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r3, r3, r0    ; r3 recebe r3 + r0
    loadi r3, r3      ; row

    ; colisao pre-movimento
    load r5, PlayerRow    ; r5 recebe o valor atual guardado na variavel PlayerRow
    cmp r3, r5    ; compara r3 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsPreNoHit    ; se a comparacao anterior deu DIFERENTE, pula para ObsPreNoHit
    load r5, PlayerCol    ; r5 recebe o valor atual guardado na variavel PlayerCol
    cmp r4, r5    ; compara r4 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsPreNoHit    ; se a comparacao anterior deu DIFERENTE, pula para ObsPreNoHit
    loadn r5, #1    ; r5 recebe o numero literal 1
    store GameState, r5    ; guarda o valor de r5 na variavel GameState

ObsPreNoHit:
    loadn r6, #ObsDirs    ; r6 recebe o endereco de "ObsDirs" (constante/rotulo, nao o conteudo)
    add r6, r6, r0    ; r6 recebe r6 + r0
    loadi r6, r6    ; r6 recebe o valor guardado no endereco de memoria apontado por r6 (leitura indireta, tipo ponteiro)

    loadn r7, #ObsIsHoriz    ; r7 recebe o endereco de "ObsIsHoriz" (constante/rotulo, nao o conteudo)
    add r7, r7, r0    ; r7 recebe r7 + r0
    loadi r7, r7    ; r7 recebe o valor guardado no endereco de memoria apontado por r7 (leitura indireta, tipo ponteiro)

    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r7, r5    ; compara r7 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq ObsDoHoriz    ; se a comparacao anterior deu IGUAL, pula para ObsDoHoriz

    ; vertical
    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r6, r5    ; compara r6 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsMoveVertUp    ; se a comparacao anterior deu DIFERENTE, pula para ObsMoveVertUp
    inc r3    ; incrementa r3 em 1 (soma 1)
    jmp ObsStorePos    ; pula incondicionalmente para ObsStorePos

ObsMoveVertUp:
    dec r3    ; decrementa r3 em 1 (subtrai 1)
    jmp ObsStorePos    ; pula incondicionalmente para ObsStorePos

ObsDoHoriz:
    loadn r5, #1    ; r5 recebe o numero literal 1
    cmp r6, r5    ; compara r6 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsMoveHorizLeft    ; se a comparacao anterior deu DIFERENTE, pula para ObsMoveHorizLeft
    inc r4    ; incrementa r4 em 1 (soma 1)
    jmp ObsStorePos    ; pula incondicionalmente para ObsStorePos

ObsMoveHorizLeft:
    dec r4    ; decrementa r4 em 1 (subtrai 1)

ObsStorePos:
    loadn r1, #ObsRows    ; r1 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    storei r1, r3    ; guarda o valor de r3 no endereco de memoria apontado por r1 (escrita indireta, tipo ponteiro)

    loadn r1, #ObsCols    ; r1 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    storei r1, r4    ; guarda o valor de r4 no endereco de memoria apontado por r1 (escrita indireta, tipo ponteiro)

    ; colisao pos-movimento
    load r5, PlayerRow    ; r5 recebe o valor atual guardado na variavel PlayerRow
    cmp r3, r5    ; compara r3 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsPostNoHit    ; se a comparacao anterior deu DIFERENTE, pula para ObsPostNoHit
    load r5, PlayerCol    ; r5 recebe o valor atual guardado na variavel PlayerCol
    cmp r4, r5    ; compara r4 com r5 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsPostNoHit    ; se a comparacao anterior deu DIFERENTE, pula para ObsPostNoHit
    loadn r5, #1    ; r5 recebe o numero literal 1
    store GameState, r5    ; guarda o valor de r5 na variavel GameState

ObsPostNoHit:
    inc r0    ; incrementa r0 em 1 (soma 1)
    load r7, ObsCount    ; r7 recebe o valor atual guardado na variavel ObsCount
    cmp r0, r7    ; compara r0 com r7 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsMoveLoop    ; se a comparacao anterior deu DIFERENTE, pula para ObsMoveLoop

    pop r7    ; restaura r7 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; VerificarColisaoObstaculos
; =============================================================================
VerificarColisaoObstaculos:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #0    ; r0 recebe o numero literal 0
ObsColLoop:
    loadn r1, #ObsRows    ; r1 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)

    loadn r1, #ObsCols    ; r1 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r3, r1    ; r3 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)

    load r4, PlayerRow    ; r4 recebe o valor atual guardado na variavel PlayerRow
    cmp r2, r4    ; compara r2 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsColNext    ; se a comparacao anterior deu DIFERENTE, pula para ObsColNext
    load r4, PlayerCol    ; r4 recebe o valor atual guardado na variavel PlayerCol
    cmp r3, r4    ; compara r3 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsColNext    ; se a comparacao anterior deu DIFERENTE, pula para ObsColNext
    loadn r4, #1    ; r4 recebe o numero literal 1
    store GameState, r4    ; guarda o valor de r4 na variavel GameState

ObsColNext:
    inc r0    ; incrementa r0 em 1 (soma 1)
    load r4, ObsCount    ; r4 recebe o valor atual guardado na variavel ObsCount
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ObsColLoop    ; se a comparacao anterior deu DIFERENTE, pula para ObsColLoop

    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; VerificarColisao (paredes)
; =============================================================================
VerificarColisao:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #1    ; r0 recebe o numero literal 1
    store MoveAllowed, r0    ; guarda o valor de r0 na variavel MoveAllowed

    load r1, NextRow    ; r1 recebe o valor atual guardado na variavel NextRow
    load r2, NextCol    ; r2 recebe o valor atual guardado na variavel NextCol

    loadn r3, #41    ; r3 recebe o numero literal 41
    mul r4, r1, r3    ; r4 recebe r1 * r3
    loadn r5, #MapCurrent    ; r5 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    add r5, r5, r4    ; r5 recebe r5 + r4
    add r5, r5, r2    ; r5 recebe r5 + r2
    loadi r6, r5    ; r6 recebe o valor guardado no endereco de memoria apontado por r5 (leitura indireta, tipo ponteiro)

    loadn r0, #35    ; '#'
    cmp r6, r0    ; compara r6 com r0 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne VerificarColisaoFim    ; se a comparacao anterior deu DIFERENTE, pula para VerificarColisaoFim
    loadn r0, #0    ; r0 recebe o numero literal 0
    store MoveAllowed, r0    ; guarda o valor de r0 na variavel MoveAllowed

VerificarColisaoFim:
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; VerificarColetaMoeda
; =============================================================================
VerificarColetaMoeda:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r1, PlayerRow    ; r1 recebe o valor atual guardado na variavel PlayerRow
    load r2, PlayerCol    ; r2 recebe o valor atual guardado na variavel PlayerCol

    loadn r3, #41    ; r3 recebe o numero literal 41
    mul r4, r1, r3    ; r4 recebe r1 * r3
    loadn r5, #MapCurrent    ; r5 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    add r5, r5, r4    ; r5 recebe r5 + r4
    add r5, r5, r2    ; r5 recebe r5 + r2
    loadi r6, r5    ; r6 recebe o valor guardado no endereco de memoria apontado por r5 (leitura indireta, tipo ponteiro)

    loadn r0, #105   ; 'i'
    cmp r6, r0    ; compara r6 com r0 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne VerificarColetaFim    ; se a comparacao anterior deu DIFERENTE, pula para VerificarColetaFim

    loadn r0, #32    ; ' '
    storei r5, r0    ; guarda o valor de r0 no endereco de memoria apontado por r5 (escrita indireta, tipo ponteiro)

    load r0, CoinsCollected    ; r0 recebe o valor atual guardado na variavel CoinsCollected
    inc r0    ; incrementa r0 em 1 (soma 1)
    store CoinsCollected, r0    ; guarda o valor de r0 na variavel CoinsCollected

VerificarColetaFim:
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; VerificarVitoria
; =============================================================================
VerificarVitoria:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r0, CoinsCollected    ; r0 recebe o valor atual guardado na variavel CoinsCollected
    load r1, CoinsTotal    ; r1 recebe o valor atual guardado na variavel CoinsTotal
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne VerificarVitoriaFim    ; se a comparacao anterior deu DIFERENTE, pula para VerificarVitoriaFim

    load r2, PlayerRow    ; r2 recebe o valor atual guardado na variavel PlayerRow
    load r3, EndRow    ; r3 recebe o valor atual guardado na variavel EndRow
    cmp r2, r3    ; compara r2 com r3 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne VerificarVitoriaFim    ; se a comparacao anterior deu DIFERENTE, pula para VerificarVitoriaFim

    load r2, PlayerCol    ; r2 recebe o valor atual guardado na variavel PlayerCol
    load r3, EndCol    ; r3 recebe o valor atual guardado na variavel EndCol
    cmp r2, r3    ; compara r2 com r3 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne VerificarVitoriaFim    ; se a comparacao anterior deu DIFERENTE, pula para VerificarVitoriaFim

    loadn r0, #2    ; r0 recebe o numero literal 2
    store GameState, r0    ; guarda o valor de r0 na variavel GameState

VerificarVitoriaFim:
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; DesenharTela (completa)
; =============================================================================
DesenharTela:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r7    ; salva r7 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #0    ; r0 recebe o numero literal 0 -- r0 vai ser o contador de LINHA (0 a 29)
DrawRowLoop:
    ; calcula o endereco de inicio da linha atual dentro de MapCurrent
    ; cada linha do mapa ocupa 41 posicoes na memoria (40 colunas visiveis + 1 de folga)
    loadn r1, #41    ; r1 recebe o numero literal 41
    mul r2, r0, r1    ; r2 recebe r0 * r1
    loadn r3, #MapCurrent    ; r3 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    add r3, r3, r2    ; r3 recebe r3 + r2 -- r3 agora aponta pro inicio da linha r0 no mapa

    loadn r4, #0    ; r4 recebe o numero literal 0 -- r4 vai ser o contador de COLUNA (0 a 39)
DrawColLoop:
    loadi r5, r3    ; r5 recebe o valor guardado no endereco de memoria apontado por r3 (leitura indireta, tipo ponteiro)

    ; se a celula for uma moeda ('i' = 105), troca pelo sprite "punto"
    loadn r6, #105    ; r6 recebe o numero literal 105
    cmp r5, r6    ; compara r5 com r6 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne DrawColSkipCoinSkin    ; se a comparacao anterior deu DIFERENTE, pula para DrawColSkipCoinSkin
    loadn r5, #2826    ; punto (char10 + cor22)
DrawColSkipCoinSkin:

    ; calcula a posicao linear na TELA (0 a 1199): linha*40 + coluna
    ; repara que aqui o passo eh 40 (largura visivel), diferente do 41 usado no mapa em memoria
    loadn r6, #40    ; r6 recebe o numero literal 40
    mul r7, r0, r6    ; r7 recebe r0 * r6
    add r7, r7, r4    ; r7 recebe r7 + r4
    outchar r5, r7    ; desenha na tela o caractere+cor de r5 na posicao r7 (0 a 1199, linha*40+coluna)

    inc r3    ; incrementa r3 em 1 (soma 1)
    inc r4    ; incrementa r4 em 1 (soma 1)
    loadn r6, #40    ; r6 recebe o numero literal 40
    cmp r4, r6    ; compara r4 com r6 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne DrawColLoop    ; se a comparacao anterior deu DIFERENTE, pula para DrawColLoop

    inc r0    ; incrementa r0 em 1 (soma 1)
    loadn r6, #30    ; r6 recebe o numero literal 30
    cmp r0, r6    ; compara r0 com r6 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne DrawRowLoop    ; se a comparacao anterior deu DIFERENTE, pula para DrawRowLoop

    call DesenharObstaculos    ; chama a sub-rotina DesenharObstaculos (guarda o endereco de retorno e desvia para la)
    call DesenharJogador    ; chama a sub-rotina DesenharJogador (guarda o endereco de retorno e desvia para la)
    call DesenharHUD    ; chama a sub-rotina DesenharHUD (guarda o endereco de retorno e desvia para la)

    pop r7    ; restaura r7 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; AtualizarTela (so elementos dinamicos)
; =============================================================================
AtualizarTela:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r5    ; salva r5 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r6    ; salva r6 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r7    ; salva r7 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    ; limpa posicao anterior do jogador
    load r0, PrevPlayerRow    ; r0 recebe o valor atual guardado na variavel PrevPlayerRow
    load r1, PrevPlayerCol    ; r1 recebe o valor atual guardado na variavel PrevPlayerCol
    loadn r2, #41    ; r2 recebe o numero literal 41
    mul r3, r0, r2    ; r3 recebe r0 * r2
    loadn r4, #MapCurrent    ; r4 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    add r4, r4, r3    ; r4 recebe r4 + r3
    add r4, r4, r1    ; r4 recebe r4 + r1
    loadi r5, r4    ; r5 recebe o valor guardado no endereco de memoria apontado por r4 (leitura indireta, tipo ponteiro)

    ; se a celula descoberta for uma moeda, usa o sprite "punto" em vez do 'i' cru
    loadn r6, #105    ; r6 recebe o numero literal 105
    cmp r5, r6    ; compara r5 com r6 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne AtualizarTelaPlayerSkipCoinSkin    ; se a comparacao anterior deu DIFERENTE, pula para AtualizarTelaPlayerSkipCoinSkin
    loadn r5, #2826    ; r5 recebe o numero literal 2826
AtualizarTelaPlayerSkipCoinSkin:

    loadn r2, #40    ; r2 recebe o numero literal 40
    mul r3, r0, r2    ; r3 recebe r0 * r2
    add r3, r3, r1    ; r3 recebe r3 + r1
    outchar r5, r3    ; desenha na tela o caractere+cor de r5 na posicao r3 (0 a 1199, linha*40+coluna)

    ; limpa posicoes anteriores dos obstaculos
    loadn r0, #0    ; r0 recebe o numero literal 0
LimpaObsLoop:
    loadn r1, #ObsPrevRows    ; r1 recebe o endereco de "ObsPrevRows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)

    loadn r1, #ObsPrevCols    ; r1 recebe o endereco de "ObsPrevCols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r3, r1    ; r3 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)

    loadn r4, #41    ; r4 recebe o numero literal 41
    mul r5, r2, r4    ; r5 recebe r2 * r4
    loadn r6, #MapCurrent    ; r6 recebe o endereco de "MapCurrent" (constante/rotulo, nao o conteudo)
    add r6, r6, r5    ; r6 recebe r6 + r5
    add r6, r6, r3    ; r6 recebe r6 + r3
    loadi r7, r6    ; r7 recebe o valor guardado no endereco de memoria apontado por r6 (leitura indireta, tipo ponteiro)

    ; se a celula descoberta for uma moeda, usa o sprite "punto" em vez do 'i' cru
    loadn r4, #105    ; r4 recebe o numero literal 105
    cmp r7, r4    ; compara r7 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne LimpaObsSkipCoinSkin    ; se a comparacao anterior deu DIFERENTE, pula para LimpaObsSkipCoinSkin
    loadn r7, #2826    ; r7 recebe o numero literal 2826
LimpaObsSkipCoinSkin:

    loadn r4, #40    ; r4 recebe o numero literal 40
    mul r5, r2, r4    ; r5 recebe r2 * r4
    add r5, r5, r3    ; r5 recebe r5 + r3
    outchar r7, r5    ; desenha na tela o caractere+cor de r7 na posicao r5 (0 a 1199, linha*40+coluna)

    inc r0    ; incrementa r0 em 1 (soma 1)
    load r4, ObsCount    ; r4 recebe o valor atual guardado na variavel ObsCount
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne LimpaObsLoop    ; se a comparacao anterior deu DIFERENTE, pula para LimpaObsLoop

    call DesenharObstaculos    ; chama a sub-rotina DesenharObstaculos (guarda o endereco de retorno e desvia para la)
    call DesenharJogador    ; chama a sub-rotina DesenharJogador (guarda o endereco de retorno e desvia para la)
    call DesenharHUD    ; chama a sub-rotina DesenharHUD (guarda o endereco de retorno e desvia para la)

    pop r7    ; restaura r7 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r6    ; restaura r6 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r5    ; restaura r5 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; DesenharObstaculos
; =============================================================================
DesenharObstaculos:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #0    ; r0 recebe o numero literal 0
DrawObsLoop:
    loadn r1, #ObsRows    ; r1 recebe o endereco de "ObsRows" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r2, r1    ; r2 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)

    loadn r1, #ObsCols    ; r1 recebe o endereco de "ObsCols" (constante/rotulo, nao o conteudo)
    add r1, r1, r0    ; r1 recebe r1 + r0
    loadi r3, r1    ; r3 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)

    loadn r4, #40    ; r4 recebe o numero literal 40
    mul r2, r2, r4    ; r2 recebe r2 * r4
    add r2, r2, r3    ; r2 recebe r2 + r3

    load r4, CharObstacle    ; r4 recebe o valor atual guardado na variavel CharObstacle
    outchar r4, r2    ; desenha na tela o caractere+cor de r4 na posicao r2 (0 a 1199, linha*40+coluna)

    inc r0    ; incrementa r0 em 1 (soma 1)
    load r4, ObsCount    ; r4 recebe o valor atual guardado na variavel ObsCount
    cmp r0, r4    ; compara r0 com r4 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne DrawObsLoop    ; se a comparacao anterior deu DIFERENTE, pula para DrawObsLoop

    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; DesenharJogador
; =============================================================================
DesenharJogador:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    load r0, PlayerRow    ; r0 recebe o valor atual guardado na variavel PlayerRow
    loadn r1, #40    ; r1 recebe o numero literal 40
    mul r0, r0, r1    ; r0 recebe r0 * r1
    load r1, PlayerCol    ; r1 recebe o valor atual guardado na variavel PlayerCol
    add r0, r0, r1    ; r0 recebe r0 + r1

    load r2, CharPlayer    ; r2 recebe o valor atual guardado na variavel CharPlayer
    outchar r2, r0    ; desenha na tela o caractere+cor de r2 na posicao r0 (0 a 1199, linha*40+coluna)

    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; DesenharHUD - linha 0: moedas e nivel
; =============================================================================
DesenharHUD:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    ; "NV:" na col 0
    loadn r0, #0    ; r0 recebe o numero literal 0
    loadn r1, #NivelLabel    ; r1 recebe o endereco de "NivelLabel" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; numero do nivel
    load r0, LevelIndex    ; r0 recebe o valor atual guardado na variavel LevelIndex
    inc r0              ; mostra 1/2/3 em vez de 0/1/2
    loadn r1, #3    ; r1 recebe o numero literal 3
    call Print2Digits    ; chama a sub-rotina Print2Digits (guarda o endereco de retorno e desvia para la)

    ; "MOEDAS:" na col 6
    loadn r0, #6    ; r0 recebe o numero literal 6
    loadn r1, #ScoreLabel    ; r1 recebe o endereco de "ScoreLabel" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; coletadas/total
    load r0, CoinsCollected    ; r0 recebe o valor atual guardado na variavel CoinsCollected
    loadn r1, #13    ; r1 recebe o numero literal 13
    call Print2Digits    ; chama a sub-rotina Print2Digits (guarda o endereco de retorno e desvia para la)

    loadn r0, #47    ; '/'
    loadn r1, #15    ; r1 recebe o numero literal 15
    outchar r0, r1    ; desenha na tela o caractere+cor de r0 na posicao r1 (0 a 1199, linha*40+coluna)

    load r0, CoinsTotal    ; r0 recebe o valor atual guardado na variavel CoinsTotal
    loadn r1, #16    ; r1 recebe o numero literal 16
    call Print2Digits    ; chama a sub-rotina Print2Digits (guarda o endereco de retorno e desvia para la)

    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; TelaInicial
; =============================================================================
TelaInicial:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    call ClearScreen    ; chama a sub-rotina ClearScreen (guarda o endereco de retorno e desvia para la)

    ; Linha 10 col 10 = pos 410  "THE HARDEST GAME"
    loadn r0, #410    ; r0 recebe o numero literal 410
    loadn r1, #TitleLine1    ; r1 recebe o endereco de "TitleLine1" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; Linha 12 col 11 = pos 491  "W/A/S/D PARA MOVER"
    loadn r0, #491    ; r0 recebe o numero literal 491
    loadn r1, #TitleLine2    ; r1 recebe o endereco de "TitleLine2" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; Linha 14 col 5 = pos 565
    loadn r0, #565    ; r0 recebe o numero literal 565
    loadn r1, #TitleLine3    ; r1 recebe o endereco de "TitleLine3" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; Linha 17 col 9 = pos 689
    loadn r0, #689    ; r0 recebe o numero literal 689
    loadn r1, #TitleLine4    ; r1 recebe o endereco de "TitleLine4" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    call EsperaTecla    ; chama a sub-rotina EsperaTecla (guarda o endereco de retorno e desvia para la)

    ; Reseta nivel
    loadn r0, #0    ; r0 recebe o numero literal 0
    store LevelIndex, r0    ; guarda o valor de r0 na variavel LevelIndex

    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; TelaNivelConcluido
; =============================================================================
TelaNivelConcluido:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    call ClearScreen    ; chama a sub-rotina ClearScreen (guarda o endereco de retorno e desvia para la)

    ; "NIVEL CONCLUIDO!" linha 14 col 12 = pos 572
    loadn r0, #572    ; r0 recebe o numero literal 572
    loadn r1, #WinLine1    ; r1 recebe o endereco de "WinLine1" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; "QUALQUER TECLA PARA CONTINUAR" linha 16 col 5 = pos 645
    loadn r0, #645    ; r0 recebe o numero literal 645
    loadn r1, #WinLine2    ; r1 recebe o endereco de "WinLine2" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    call EsperaTecla    ; chama a sub-rotina EsperaTecla (guarda o endereco de retorno e desvia para la)

    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; TelaDerrota
; =============================================================================
TelaDerrota:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    call ClearScreen    ; chama a sub-rotina ClearScreen (guarda o endereco de retorno e desvia para la)

    ; "VOCE MORREU!" linha 13 col 14 = pos 534
    loadn r0, #534    ; r0 recebe o numero literal 534
    loadn r1, #LoseLine1    ; r1 recebe o endereco de "LoseLine1" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; linha 15 col 2 = pos 602
    loadn r0, #602    ; r0 recebe o numero literal 602
    loadn r1, #LoseLine2    ; r1 recebe o endereco de "LoseLine2" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    call EsperaTecla    ; chama a sub-rotina EsperaTecla (guarda o endereco de retorno e desvia para la)

    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; TelaVitoriaFinal
; =============================================================================
TelaVitoriaFinal:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    call ClearScreen    ; chama a sub-rotina ClearScreen (guarda o endereco de retorno e desvia para la)

    ; "VOCE VENCEU O JOGO!" linha 13 col 10 = pos 530
    loadn r0, #530    ; r0 recebe o numero literal 530
    loadn r1, #FinalLine1    ; r1 recebe o endereco de "FinalLine1" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

    ; "S = JOGAR DE NOVO   N = SAIR" linha 15 col 6 = pos 606
    loadn r0, #606    ; r0 recebe o numero literal 606
    loadn r1, #FinalLine2    ; r1 recebe o endereco de "FinalLine2" (constante/rotulo, nao o conteudo)
    loadn r2, #0    ; r2 recebe o numero literal 0
    call ImprimeStr    ; chama a sub-rotina ImprimeStr (guarda o endereco de retorno e desvia para la)

TelaVitoriaLoop:
    inchar r0    ; r0 recebe o codigo da tecla pressionada AGORA (255 se nenhuma tecla estiver pressionada)
    loadn r1, #255    ; r1 recebe o numero literal 255
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq TelaVitoriaLoop    ; se a comparacao anterior deu IGUAL, pula para TelaVitoriaLoop

    loadn r1, #83    ; 'S'
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq VitoriaSimRestart    ; se a comparacao anterior deu IGUAL, pula para VitoriaSimRestart
    loadn r1, #115   ; 's'
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq VitoriaSimRestart    ; se a comparacao anterior deu IGUAL, pula para VitoriaSimRestart

    loadn r1, #78    ; 'N'
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq VitoriaVoltaTitulo    ; se a comparacao anterior deu IGUAL, pula para VitoriaVoltaTitulo
    loadn r1, #110   ; 'n'
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq VitoriaVoltaTitulo    ; se a comparacao anterior deu IGUAL, pula para VitoriaVoltaTitulo

    jmp TelaVitoriaLoop    ; pula incondicionalmente para TelaVitoriaLoop

VitoriaSimRestart:
    loadn r0, #0    ; r0 recebe o numero literal 0
    store ReturnToTitle, r0    ; guarda o valor de r0 na variavel ReturnToTitle
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

VitoriaVoltaTitulo:
    loadn r0, #1    ; r0 recebe o numero literal 1
    store ReturnToTitle, r0    ; guarda o valor de r0 na variavel ReturnToTitle
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; ClearScreen
; =============================================================================
ClearScreen:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r0, #0    ; r0 recebe o numero literal 0
    loadn r1, #1200    ; r1 recebe o numero literal 1200
    loadn r2, #32    ; ' '
ClearScreenLoop:
    outchar r2, r0    ; desenha na tela o caractere+cor de r2 na posicao r0 (0 a 1199, linha*40+coluna)
    inc r0    ; incrementa r0 em 1 (soma 1)
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne ClearScreenLoop    ; se a comparacao anterior deu DIFERENTE, pula para ClearScreenLoop

    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; EsperaTecla
; =============================================================================
EsperaTecla:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)

EsperaTeclaLoop:
    inchar r0    ; r0 recebe o codigo da tecla pressionada AGORA (255 se nenhuma tecla estiver pressionada)
    loadn r1, #255    ; r1 recebe o numero literal 255
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq EsperaTeclaLoop    ; se a comparacao anterior deu IGUAL, pula para EsperaTeclaLoop

EsperaTeclaRelease:
    inchar r0    ; r0 recebe o codigo da tecla pressionada AGORA (255 se nenhuma tecla estiver pressionada)
    loadn r1, #255    ; r1 recebe o numero literal 255
    cmp r0, r1    ; compara r0 com r1 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jne EsperaTeclaRelease    ; se a comparacao anterior deu DIFERENTE, pula para EsperaTeclaRelease

    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; ImprimeStr  r0=pos tela  r1=addr string  r2=cor
; =============================================================================
ImprimeStr:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r4    ; salva r4 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r3, #0    ; r3 recebe o numero literal 0

ImprimeStrLoop:
    loadi r4, r1    ; r4 recebe o valor guardado no endereco de memoria apontado por r1 (leitura indireta, tipo ponteiro)
    cmp r4, r3    ; compara r4 com r3 e guarda o resultado para o proximo salto condicional (jeq/jne/jle)
    jeq ImprimeStrSai    ; se a comparacao anterior deu IGUAL, pula para ImprimeStrSai
    add r4, r2, r4    ; r4 recebe r2 + r4
    outchar r4, r0    ; desenha na tela o caractere+cor de r4 na posicao r0 (0 a 1199, linha*40+coluna)
    inc r0    ; incrementa r0 em 1 (soma 1)
    inc r1    ; incrementa r1 em 1 (soma 1)
    jmp ImprimeStrLoop    ; pula incondicionalmente para ImprimeStrLoop

ImprimeStrSai:
    pop r4    ; restaura r4 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

; =============================================================================
; Print2Digits  r0=numero(0..99)  r1=pos tela
; =============================================================================
Print2Digits:
    push r0    ; salva r0 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r1    ; salva r1 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r2    ; salva r2 na pilha (preserva o registrador antes de usa-lo aqui dentro)
    push r3    ; salva r3 na pilha (preserva o registrador antes de usa-lo aqui dentro)

    loadn r2, #10    ; r2 recebe o numero literal 10
    div r3, r0, r2    ; r3 recebe r0 / r2
    mul r2, r3, r2    ; r2 recebe r3 * r2
    sub r0, r0, r2    ; r0 recebe r0 - r2

    loadn r2, #48    ; r2 recebe o numero literal 48
    add r3, r3, r2    ; r3 recebe r3 + r2
    outchar r3, r1    ; desenha na tela o caractere+cor de r3 na posicao r1 (0 a 1199, linha*40+coluna)
    inc r1    ; incrementa r1 em 1 (soma 1)

    add r0, r0, r2    ; r0 recebe r0 + r2
    outchar r0, r1    ; desenha na tela o caractere+cor de r0 na posicao r1 (0 a 1199, linha*40+coluna)

    pop r3    ; restaura r3 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r2    ; restaura r2 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r1    ; restaura r1 da pilha (devolve o valor que ele tinha antes desta rotina)
    pop r0    ; restaura r0 da pilha (devolve o valor que ele tinha antes desta rotina)
    rts    ; retorna da sub-rotina (volta para quem deu o call)

halt    ; encerra a execucao do programa
