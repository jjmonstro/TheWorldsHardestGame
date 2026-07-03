//   PUSHA -- Empilha (push) todos os 8 registradores de uso geral
//   POPA  -- Desempilha (pop) todos os 8 registradores de uso geral

#include <stdio.h>
#include <stdlib.h>

#define TAMANHO_MEMORIA 32768
#define MAX_VAL 65535

// Flag register 
#define STACK_UNDERFLOW 8
#define STACK_OVERFLOW  7

unsigned int MEMORY[TAMANHO_MEMORIA]; // Memoria de programa e de dados do Processador
int reg[8];                            // 8 registradores de uso geral
int FR[16] = {0};                      // Flag Register
int SP;                                // Stack Pointer

// PUSHA -- Salva todos os registradores na pilha
void PUSHA(void) {
	int i;

	for (i = 0; i < 8; i++) {
		if (SP <= 0) { // Nao ha mais espaco na pilha
			FR[STACK_OVERFLOW] = 1;
			printf("PUSHA: Stack Overflow! Nao foi possivel empilhar reg[%d]\n", i);
			return;
		}

		MEMORY[SP] = reg[i]; // M[SP] <- Rx
		SP--;                //          SP--
	}
}

// POPA -- Restaura todos os registradores a partir da pilha
//       -- Desempilha na ordem INVERSA da PUSHA (x = 7..0), para que cada
void POPA(void) {
	int i;

	for (i = 7; i >= 0; i--) {
		if (SP >= TAMANHO_MEMORIA - 1) { // Pilha vazia
			FR[STACK_UNDERFLOW] = 1;
			printf("POPA: Stack Underflow! Nao foi possivel desempilhar reg[%d]\n", i);
			return;
		}

		SP++;                // SP++
		reg[i] = MEMORY[SP]; //        Rx <- M[SP]
	}
}


// Testa PUSHA/POPA: preenche os registradores, empilha, altera (simulando
// uso pelo resto do programa) e depois desempilha
int main(void) {
	int i;
	int sucesso = 1;

	SP = TAMANHO_MEMORIA - 1; // mesma inicializacao usada em STATE_RESET do processador

	printf("=== Teste das funcoes PUSHA e POPA ===\n\n");

	// 1) Inicializa os registradores com valores conhecidos
	for (i = 0; i < 8; i++)
		reg[i] = (i + 1) * 10; // reg[0]=10, reg[1]=20, ..., reg[7]=80

	printf("Registradores ANTES do PUSHA:\n");
	for (i = 0; i < 8; i++)
		printf("  reg[%d] = %d\n", i, reg[i]);
	printf("SP antes do PUSHA: %d\n\n", SP);

	// 2) Empilha todos os registradores
	PUSHA();
	printf("SP depois do PUSHA: %d (esperado: %d)\n\n", SP, TAMANHO_MEMORIA - 9);

	// 3) Simula o uso dos registradores por outra parte do programa
	for (i = 0; i < 8; i++)
		reg[i] = 0;

	printf("Registradores ZERADOS (simulando uso pelo programa):\n");
	for (i = 0; i < 8; i++)
		printf("  reg[%d] = %d\n", i, reg[i]);
	printf("\n");

	// 4) Restaura todos os registradores
	POPA();
	printf("SP depois do POPA: %d (esperado: %d)\n\n", SP, TAMANHO_MEMORIA - 1);

	printf("Registradores DEPOIS do POPA (devem ser iguais aos valores iniciais):\n");
	for (i = 0; i < 8; i++) {
		printf("  reg[%d] = %d\n", i, reg[i]);
		if (reg[i] != (i + 1) * 10)
			sucesso = 0;
	}

	if (SP != TAMANHO_MEMORIA - 1)
		sucesso = 0;

	printf("\n");
	if (sucesso)
		printf("TESTE OK: todos os registradores e o SP foram restaurados corretamente!\n");
	else
		printf("TESTE FALHOU: algum registrador ou o SP nao foi restaurado corretamente.\n");

	// 5) Teste extra: forca um Stack Overflow para checar a protecao
	printf("\n=== Teste extra: Stack Overflow ===\n");
	SP = 3; // deixa so 3 posicoes livres na pilha (menos que os 8 registradores)
	FR[STACK_OVERFLOW] = 0;
	PUSHA();
	printf("FR[STACK_OVERFLOW] = %d (esperado: 1)\n", FR[STACK_OVERFLOW]);

	// 6) Teste extra: forca um Stack Underflow para checar a protecao
	printf("\n=== Teste extra: Stack Underflow ===\n");
	SP = TAMANHO_MEMORIA - 1; // pilha "vazia"
	FR[STACK_UNDERFLOW] = 0;
	POPA();
	printf("FR[STACK_UNDERFLOW] = %d (esperado: 1)\n", FR[STACK_UNDERFLOW]);

	return 0;
}
