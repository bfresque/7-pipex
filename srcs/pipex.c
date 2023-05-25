/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/25 15:28:47 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

int child_process_one(char **cmd1, t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_one.path, data->cmd_one.ac, envp);
	return (0);
}

int child_process_two(char **cmd2, t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_two.path, data->cmd_two.ac, envp);
	return (0);
}

void	pipex(t_data *data, char **av, char **envp)
{
	int fd[2];
	pid_t	pid;
	int status;

	pipe(fd);
	pid = fork();
	if (pid < 0)
		return (perror("Fork: "));
	if (pid == 0)
	{
		close(fd[0]);
		dup2(fd[1], STDOUT_FILENO);
		child_process_one(data->cmd_one.ac, data, av, envp);
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
		child_process_two(data->cmd_two.ac, data, av, envp);
		close(fd[0]);
	}
}


int main(int ac, char **av, char **envp)
{
	int	f1;
	int	f2;

	t_data data;
	
	f1 = open(av[1], O_RDONLY);
	f2 = open(av[4], O_CREAT | O_RDWR | O_TRUNC, 0644);
	
	if (f1 < 0 || f2 < 0)
		return (-1);
	
	pipex(&data, av, envp);
	
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


// int main(int ac, char **av, char **envp)
// {
// 	t_data data;
// 	pid_t	pid;
// 	int fd[2];
// 	int	f1;
// 	int	f2;
// 	int status;

	
// 	f1 = open(av[1], O_RDONLY);
// 	f2 = open(av[4], O_CREAT | O_RDWR | O_TRUNC, 0644);
// 	if (f1 < 0 || f2 < 0)
// 		return (-1);
// 	pipe(fd);
// 	pid = fork();
// 	if (pid < 0)
// 		printf("errorr\n");
// 		// return (perror("Fork: "));
// 	if (pid == 0)
// 	{
// 		close(fd[0]);
// 		dup2(fd[1], STDOUT_FILENO);
// 		child_process_one(data.cmd_one.ac, &data, av, envp);
// 		close(fd[1]);
// 	}
// 	pid = fork();
// 	if (pid < 0)
// 		printf("errorr\n");
// 		// return (perror("Fork: "));
// 	if (pid == 0)
// 	{
// 		waitpid(pid, &status, 0);
// 		close(fd[1]);
// 		dup2(fd[0], STDOUT_FILENO);
// 		child_process_two(data.cmd_two.ac, &data, av, envp);
// 		close(fd[0]);
// 	}	
// 	return (0);
// }

