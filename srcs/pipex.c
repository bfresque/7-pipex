/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/14 15:32:10 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

void	recup_cmd(t_data *data, char **av, char **envp)
{
	data->cmd_one.ac = ft_split(av[2], ' ');
	data->cmd_two.ac = ft_split(av[3], ' ');
	data->cmd_one.path = ft_check_paths(*data->cmd_one.ac, envp);
	data->cmd_two.path = ft_check_paths(*data->cmd_two.ac, envp);
}

void	child_process_one(t_data *data, char **av, char **envp, int fd[2])
{
	int	f1;

	f1 = open(av[1], O_RDONLY);
	if (f1 < 0)
	{
		ft_free_all_data(data);
		perror(av[1]);
		exit(-1);
	}
	dup2(fd[1], 1);
	close(fd[0]);
	close(fd[1]);
	dup2(f1, 0);
	close(f1);
	if ((data->cmd_one.path != NULL)
		&& (execve(data->cmd_one.path, data->cmd_one.ac, envp) == -1))
	{
		close(1);
		close(0);
		close(fd[1]);
		close(fd[0]);
		ft_free_all_data(data);
		perror("Error: Execve child one");
		exit(-1);
	}
}

void	child_process_two(t_data *data, char **av, char **envp, int fd[2])
{
	int	f2;

	f2 = open(av[4], O_CREAT | O_RDWR | O_TRUNC, 0644);
	if (f2 < 0)
	{
		ft_free_all_data(data);
		perror(av[4]);
		exit(-1);
	}
	dup2(f2, 1);
	close(f2);
	dup2(fd[0], 0);
	close(fd[0]);
	close(fd[1]);
	if ((data->cmd_two.path != NULL)
		&& (execve(data->cmd_two.path, data->cmd_two.ac, envp) == -1))
	{
		close(1);
		close(0);
		close(fd[1]);
		close(fd[0]);
		ft_free_all_data(data);
		perror("Error: Execve child two");
		exit(-1);
	}
}

void	pipex(t_data *data, char **av, char **envp)
{
	pid_t	pid1;
	pid_t	pid2;
	int		fd[2];

	if (pipe(fd) < 0)
	{
		perror("pipe");
		exit(-1);
	}
	recup_cmd(data, av, envp);
	pid1 = fork();
	if (pid1 == 0)
		child_process_one(data, av, envp, fd);
	pid2 = fork();
	if (pid2 == 0)
		child_process_two(data, av, envp, fd);
	close(fd[0]);
	close(fd[1]);
	waitpid(pid1, NULL, 0);
	waitpid(pid2, NULL, 0);
	ft_free_all_data(data);
}

int	main(int ac, char **av, char **envp)
{
	t_data	data;
	int		fd;

	if (ac != 5)
		return (ft_printf("Error : bad numbers arguments\n"));
	fd = open(av[1], O_DIRECTORY);
	if (fd > 0)
	{
		ft_printf("cat: %s: Is a directory\n", av[1]);
		close(fd);
		exit(-1);
	}
	pipex(&data, av, envp);
	(void)ac;
	return (0);
}
