/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pendu.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/05/17 12:10:24 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/17 14:41:22 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>

#define SIZE 3

void initializeBoard(char board[SIZE][SIZE]) {
	int i, j;
	for (i = 0; i < SIZE; i++) {
		for (j = 0; j < SIZE; j++) {
			board[i][j] = ' ';
		}
	}
}

void printBoard(char board[SIZE][SIZE]) {
	int i, j;
	for (i = 0; i < SIZE; i++) {
		for (j = 0; j < SIZE; j++) {
			printf(" %c ", board[i][j]);
			if (j < SIZE - 1) {
				printf("|");
			}
		}
		printf("\n");
		if (i < SIZE - 1) {
			printf("---+---+---\n");
		}
	}
}

int checkWin(char board[SIZE][SIZE], char player) {
	int i;
	for (i = 0; i < SIZE; i++) {
		if (board[i][0] == player && board[i][1] == player && board[i][2] == player) {
			return 1;
		}
		if (board[0][i] == player && board[1][i] == player && board[2][i] == player) {
			return 1;
		}
	}
	if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
		return 1;
	}
	if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
		return 1;
	}
	return 0;
}

int isBoardFull(char board[SIZE][SIZE]) {
	int i, j;
	for (i = 0; i < SIZE; i++) {
		for (j = 0; j < SIZE; j++) {
			if (board[i][j] == ' ') {
				return 0;
			}
		}
	}
	return 1;
}

int main() {
	char board[SIZE][SIZE];
	int row, col;
	int currentPlayer = 1;
	int moves = 0;

	initializeBoard(board);

	while (1) {
		printf("Tour du joueur %d\n", currentPlayer);
		printf("Entrez la ligne et la colonne (0-2) : ");
		scanf("%d %d", &row, &col);

		if (row < 0 || row >= SIZE || col < 0 || col >= SIZE || board[row][col] != ' ') {
			printf("Mouvement invalide ! Veuillez réessayer.\n");
			continue;
		}

		if (currentPlayer == 1) {
			board[row][col] = 'X';
		} else {
			board[row][col] = 'O';
		}

		printBoard(board);

		if (checkWin(board, 'X')) {
			printf("Le joueur 1 (X) a gagné !\n");
			break;
		}
		if (checkWin(board, 'O')) {
			printf("Le joueur 2 (O) a gagné !\n");
			break;
		}

		moves++;

		if (isBoardFull(board)) {
			printf("Match nul !\n");
			break;
		}

		currentPlayer = (currentPlayer == 1) ? 2 : 1;
	}

	return 0;
}
