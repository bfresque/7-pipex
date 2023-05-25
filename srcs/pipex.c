/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/25 13:00:26 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"
#include <stdio.h>
#include <unistd.h>


// int parent_process(int f2, char **cmd2, t_data *data, char **av, char **envp)
// {
// 	printf("%sparent_process%s\n", BLUE, RESET);
// 	recup_cmd(data, av, envp);
// 	printf("\ncmd1 = %s\n", *data->cmd_one.ac);
// 	printf("PATH cmd1 = %s\n", data->cmd_one.path);
// 	execve(data->cmd_one.path, data->cmd_one.ac, envp);
// 	printf("%sEND parent_process%s\n", BLUE, RESET);
// 	return (0);
// }

// int child_process(int f1, char **cmd1, t_data *data, char **av, char **envp)
// {
// 	printf("%schild_process\n%s", MAGENTA, RESET);
// 	recup_cmd(data, av, envp);
// 	printf("\ncmd2 = %s\n", *data->cmd_two.ac);
// 	printf("PATH cmd2 = %s\n", data->cmd_two.path);
// 	execve(data->cmd_two.path, data->cmd_two.ac, envp);
// 	printf("%sEND child_process%s\n", MAGENTA, RESET);
// 	return (0);
// }

// void	pipex(int f1, int f2, t_data *data, char **av, char **envp)
// {
// 	int	end[2];

// 	pid_t	pid;
// 	// pid_t	wait_pid;
// 	int		status;
// 	pipe(end);
// 	pid = fork();
// 	printf("\npid = %d", pid);
// 	if (pid < 0) //Erreur lors de la création du processus enfant
// 	{
// 		// free
// 		return (perror("Fork: "));
// 	}
// 	if (pid == 0) // executera la 1er cmd
// 	{
// 		printf("\n%sJe suis le processus enfant%s\n", MAGENTA, RESET);
		
// 		close(end[0]); // Ferme l'extrémité de lecture de la pipe
// 		dup2(end[1], STDOUT_FILENO); // Redirige la sortie standard vers l'extrémité d'écriture de la pipe
// 		child_process(f1, data->cmd_one.ac, data, av, envp);
// 		printf("END de pipex enfant\n");

// 		close(end[1]); // Ferme l'extrémité d'écriture de la pipe
// 	}
// 	else if (pid > 0) // executera la 2e cmd
// 	{
// 		printf("\n%sJe suis le processus parent%s\n", BLUE, RESET);
		
// 		waitpid(pid, &status, 0); // Attend la terminaison du processus enfant
// 		close(end[1]); // Ferme l'extrémité d'écriture de la pipe
// 		dup2(end[0], STDIN_FILENO); // Redirige l'entrée standard vers l'extrémité de lecture de la pipe
// 		printf("pipex parent\n");
// 		parent_process(f2, data->cmd_two.ac, data, av, envp);
// 		printf("END pipex parent\n");
// 		close(end[0]); // Ferme l'extrémité de lecture de la pipe
// 	}
// 	printf("END de pipex\n");
// }


int child_process_one(int f2, char **cmd2, t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_one.path, data->cmd_one.ac, envp);
	return (0);
}

int child_process_two(int f1, char **cmd1, t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_two.path, data->cmd_two.ac, envp);
	return (0);
}

void	pipex(int f1, int f2, t_data *data, char **av, char **envp)
{
	pid_t	pid;

	pid = fork();
	if (pid < 0)
		return (perror("Fork: "));
	if (pid == 0)
		child_process_one(f1, data->cmd_one.ac, data, av, envp);

	pid = fork();
	if (pid < 0)
		return (perror("Fork: "));
	if (pid == 0)
		child_process_two(f1, data->cmd_one.ac, data, av, envp);
}

int main(int ac, char **av, char **envp)
{
	t_data data;
	int	f1;
	int	f2;

	f1 = open(av[1], O_RDONLY);
	f2 = open(av[4], O_CREAT | O_RDWR | O_TRUNC, 0644);
	if (f1 < 0 || f2 < 0)
		return (-1);
	
	pipex(f1, f2, &data, av, envp);
	
	printf("END je suis sorti youpi\n");
	return (0);
}



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
