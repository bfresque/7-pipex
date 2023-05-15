/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/15 15:26:07 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"
#include <stdio.h>
#include <unistd.h>

int ft_fork_child(void)
{
	pid_t pid;
	

	pid = fork();

	if (pid == 0)
		ft_printf("\n%sJe suis le processus enfant.%s\n", MAGENTA, RESET);
	
	else if (pid > 0)
		ft_printf("\n%sJe suis le processus parents.%s\n", BLUE, RESET);
	
	else
		ft_printf("\n%sErreur lors de la création du processus enfant.%s\n", WHITE, RESET);
		
	return (0);
}


int main(int ac, char **av, char **envp)
{
	t_data data;

	ft_fork_child();
	recup_cmd(&data, av, envp);
	ft_printf("je passe\n");
}


// void child()
// {
// 	fork();
// 	if(pid == 0)
// 	{
		
// 	}
// }
// int main()
// {
// 	int i = 4;
// 	int *pipe_fd;

// 	pipe_fd = malloc(sizeof(int) * nb_pipe * 2 );
// 	while()
// 	while (i)
// 	{
// 		child_process(pipex);
// 		i--;
// 	}
// }
