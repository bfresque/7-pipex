/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/25 16:56:27 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

int	child_process_one(t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_one.path, data->cmd_one.ac, envp);
	return (0);
}

int	child_process_two(t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_two.path, data->cmd_two.ac, envp);
	return (0);
}

void	pipex(t_data *data, char **av, char **envp)
{
	pid_t	pid;
	int		fd[2];
	int		f2;
	int		status;

	pipe(fd);
	pid = fork();
	if (pid < 0)
		return (perror("Fork: "));
	if (pid == 0)
	{
		close(fd[0]);
		dup2(fd[1], STDOUT_FILENO);
		child_process_one(data, av, envp);
		close(fd[1]);
	}
	pid = fork();
	if (pid < 0)
		return (perror("Fork: "));
	if (pid == 0)
	{
		waitpid(pid, &status, 0);
		close(fd[1]);
		dup2(fd[0], STDIN_FILENO);
		close(fd[0]);
		f2 = open(av[4], O_CREAT | O_RDWR | O_TRUNC, 0644);
		if (f2 < 0)
		{
			perror("Erreur lors de l'ouverture du fichier de sortie");
			exit(1);
		}
		dup2(f2, STDOUT_FILENO);
		child_process_two(data, av, envp);
		close(f2);
	}
}

int	main(int ac, char **av, char **envp)
{
	t_data	data;
	int		f1;

	(void)ac;
	f1 = open(av[1], O_RDONLY);
	if (f1 < 0)
		return (-1);
	pipex(&data, av, envp);
	close(f1);
	return (0);
}
