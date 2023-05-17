/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/17 15:10:51 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"
#include <stdio.h>
#include <unistd.h>

int	openfile (char *ac, int sortie)
{
	if (sortie == INFILE)
	{
		if (access(ac, F_OK))
			return (STDIN);
		return (open(ac, O_RDONLY));
	}
	else
		return (open(ac, O_CREAT | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH));
}

char	*getPath (char *cmd, char **env)
{
	char	*path;
	char	*dir;
	char	*temp;
	int		i;

	i = 0;
	while (env[i] && ft_strncmp_pipex(env[i], "PATH=", 5))
		i++;
	if (!env[i])
		return (cmd);
	path = env[i] + 5;
	while (path && str_ichr(path, ':') > -1)
	{
		dir = str_ndup(path, str_ichr(path, ':'));
		temp = ft_strjoin_pipex(dir, cmd);
		free(dir);
		if (access(temp, F_OK) == 0)
			return (temp);
		free(temp);
		path += str_ichr(path, ':') + 1;
	}
	return (cmd);
}

void	exec (char *cmd, char **env)
{
	char	**args;
	char	*path;

	args = str_split(cmd, ' ');
	if (str_ichr(args[0], '/') > -1)
		path = args[0];
	else
		path = getPath(args[0], env);
	exit(0);
}

void	ft_pipex(char *cmd, char **envp, int fdin)
{
	pid_t pid;
	int fd[2];

	pipe(fd);
	pid = fork();
	if (pid)
	{
		close(fd[1]);
		dup2(fd[0], STDIN);
		waitpid(pid, NULL, 0);
	}
	else
	{
		close(fd[0]);
		dup2(fd[1], STDOUT);
		if (fdin == STDIN)
			exit(1);
		else
			exec(cmd, env);
	}
}

int main(int ac, char **av, char **envp)
{
	t_data data;
	int fdin;
	int fdout;

	fdin = openfile(av[1], INFILE);
	fdout = openfile(av[4], OUTFILE);
	dup2(fdin, STDIN);
	dup2(fdout, STDOUT);
	ft_pipex(av[2], env, fdin);
	
	// (fd1, fd2, &data, av, envp);
	
	// ft_printf("je passe\n");
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
