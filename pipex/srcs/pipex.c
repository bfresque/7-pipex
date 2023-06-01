/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/01 10:22:13 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

void	child_process_one(t_data *data, char **av, char **envp,	int	fd[2])
{
	int	f1;
	
	f1 = open(av[1], O_RDONLY);
	if (f1 < 0)
	{
		ft_free_all_data(data);
		perror(av[1]);
		exit(-1);
	}
	close(fd[0]);
	dup2(fd[1], STDOUT_FILENO);
	if(data->cmd_one.path != NULL)
	{
		if (execve(data->cmd_one.path, data->cmd_one.ac, envp) == -1)
		{
			ft_mess_error("Error: Execve child one\n");// ?????????????????
			exit(-1);
		}
	}
	close(fd[1]);
	close(f1);
}

void	child_process_two(t_data *data, char **av, char **envp, int	fd[2])
{
	int	f2;

	f2 = open(av[4], O_CREAT | O_RDWR | O_TRUNC, 0644);
	if (f2 < 0)
	{
		ft_free_all_data(data);
		perror(av[4]);
		exit(-1);
	}
	close(fd[1]);
	dup2(fd[0], STDIN_FILENO);
	close(fd[0]);
	dup2(f2, STDOUT_FILENO);
	if(data->cmd_two.path != NULL)
	{
		if (execve(data->cmd_two.path, data->cmd_two.ac, envp) == -1)
		{
			ft_mess_error("Error: Execve child two\n");// ?????????????????
			exit(-1);
		}
	}
	close(f2);
}

void	pipex(t_data *data, char **av, char **envp)
{
	pid_t	pid;
	int		status;
	int		fd[2];

	recup_cmd(data, av, envp);
	pipe(fd);
	pid = fork();
	if (pid < 0)
		perror("Fork one");
	if (pid == 0)
		child_process_one(data, av, envp, fd);
	pid = fork();
	if (pid < 0)
		perror("Fork two");
	if (pid == 0)
	{
		waitpid(pid, &status, 0);
		child_process_two(data, av, envp, fd);
	}
	close(fd[0]);
	close(fd[1]);
	ft_free_all_data(data);
}

int	main(int ac, char **av, char **envp)
{
	t_data	data;

	(void)ac;
	if(ac == 5)
	{
		pipex(&data, av, envp);
	}
	else
		ft_printf("Error: Bad numbers of arguments\n");
	return (0);
}


/*
valgrind --trace-children=yes ./pipex infile ls ls outfile //tester les leacks des childs 
valgrind --track-fds=yes ./pipex infile ls ls outfile // verifer les close/open des fd
./pipex infile lls ls outfile // la premiere doit foiree ma la deuxieme doit correctement etre executee vis versa

./pipex infile ./a.out cat test   // faire une condition(if av[1] == "./") si il y a un "./" directement envoyer dans le execve
valgrind ./pipex infile ls ls outfile  // a tester avec les droits de infile et de outfile a 0 atention il doit retourner "infile ou outfile : permission denied"

NE PAS EXECVE S'IL N'Y A PAS DE CHEMIN 

tester avec :
- un nom de dossier
- un chemin absolu
- sans environement env -i (ou  -u)
*/