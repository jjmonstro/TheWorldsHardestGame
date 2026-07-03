# The Worlds Hardest Game (Assembly)

Projeto desenvolvido para a disciplina *SSC0955 - Introdução a Sistemas Computacionais*, do Instituto de Ciências Matemáticas e de Computação (ICMC-USP).

## Sobre o Projeto

O *The Worlds Hardest Game* é um jogo de labirinto em Assembly, inspirado no clássico *World's Hardest Game*, desenvolvido para o simulador utilizado na disciplina.

O objetivo é limpar os três níveis do jogo: coletar todas as moedas de cada fase e chegar até o ponto de saída, desviando dos obstáculos, que encerram a partida no primeiro contato.

---

## Mecânica do Jogo

O jogador controla um quadrado que se move por um labirinto de paredes fixas.

Durante a partida:

1. O jogador se move pelo labirinto usando as teclas W/A/S/D.
2. Um conjunto de obstáculos se movimenta automaticamente pelo cenário (8 no nível 1, 12 nos níveis 2 e 3).
3. Ao encostar em uma moeda, ela é coletada e some do mapa.
4. É preciso coletar **todas** as moedas do nível antes de poder vencer.
5. Com todas as moedas coletadas, o jogador deve chegar até a célula de saída (`J`) para passar de fase.
6. Se o jogador tocar em qualquer obstáculo, é *Game Over* imediato (não há sistema de vidas).
7. Ao vencer o terceiro e último nível, o jogo exibe a tela de vitória final.

Antes de cada fase, é exibida uma tela de introdução em pixel art com o desenho do labirinto daquele nível; basta apertar qualquer tecla para começar a jogar.

---

## Controles

| Tecla   | Função                                    |
| ------- | ------------------------------------------ |
| *W*   | Move o personagem para cima                |
| *A*   | Move o personagem para a esquerda          |
| *S*   | Move o personagem para baixo               |
| *D*   | Move o personagem para a direita           |
| *S/N* | Na tela de vitória final: jogar de novo / sair |

---

## Elementos do Jogo

### Personagem

| Elemento     | Significado                                          |
| ------------ | ----------------------------------------------------- |
| Quadrado (`cuadradof`) | Personagem controlado pelo jogador, sprite colorido próprio (char + cor) |

### Obstáculos

| Elemento             | Significado                                            |
| --------------------- | -------------------------------------------------------- |
| `elimina` | Obstáculo em movimento; qualquer contato encerra a partida |

### Coletáveis

| Símbolo | Significado                              |
| ------- | ------------------------------------------ |
| `i` (renderizado como sprite `punto`) | Moeda a ser coletada |

### Cenário

| Símbolo | Significado                                                |
| ------- | ------------------------------------------------------------ |
| `#`     | Parede do labirinto (desenhada com bloco colorido por nível) |
| `J`     | Ponto de saída / vitória da fase                              |
| ` `     | Caminho livre                                                 |

---

## Estrutura do Código

O código é dividido em blocos principais:

### 1. Telas e Mapas

* Mapas dos três níveis (paredes, moedas, ponto de saída);
* Telas de introdução de cada nível (pixel art gerado a partir de um editor de telas);
* Tela inicial, tela de derrota e tela de vitória final.

### 2. Inicialização das Variáveis

Configura:

* Posição inicial do jogador;
* Posições e direções dos obstáculos de cada nível;
* Contagem de moedas coletadas e total de moedas da fase;
* Cor das paredes do nível atual (`WallColor`).

### 3. Loop Principal

Executa continuamente:

* Leitura do teclado (`LerEntrada`);
* Movimentação do jogador e verificação de colisão com parede;
* Movimentação automática dos obstáculos;
* Verificação de colisão do jogador com obstáculos;
* Verificação de coleta de moeda;
* Verificação de vitória da fase;
* Atualização da tela.

### 4. Gráficos

Jogador, obstáculos e moedas são desenhados com sprites próprios (não apenas caracteres ASCII simples): cada um combina um caracter customizado no `charmap.mif` com uma cor, através da fórmula `valor = charcode + cor*128` usada pelo `outchar` do simulador.

### 5. Sistema de Pontuação/Progresso

O progresso é medido pela quantidade de moedas coletadas em relação ao total da fase, verificado a cada quadro do jogo.

### 6. Game Over

Ocorre quando:

```
Jogador × Obstáculo
```

A tela é limpa e são exibidas:

* Mensagem de fim de jogo ("VOCE MORREU!");
* Instrução para tentar novamente.

### 7. Vitória

Ao completar o terceiro nível (todas as moedas coletadas + saída alcançada), é exibida a tela final com a opção de jogar novamente (`S`) ou sair (`N`).

---

## Tecnologias Utilizadas

* Assembly do simulador da disciplina SSC0955
* Simulador do Prof. Simões
* `charmap.mif` customizado para os sprites do jogo

---

## Autores

João Pedro Correia
Mauricio Adrian Sagarnaga Arene
