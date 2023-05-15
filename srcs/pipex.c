/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/15 12:57:08 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

char	**find_all_paths(char **envp, t_data *data)
{
	char *path;
	char **all_paths;
	int i = 0;

	while(*envp)
	{
		if(ft_strncmp_pipex("PATH=", *envp, 5) == 0)
		{
			path = &((*envp)[5]);
			break;
		}
		envp++;
		i++;
	}
	all_paths = ft_split(path, ':');
	return(all_paths);
}

char	*check_cmd_path(t_data *data, char *args, char **envp) 
{
	char	**temp_path;
	char	*valid_path;
	int		i;

	temp_path = find_all_paths(envp, data);
	valid_path = NULL;
	i = 0;
	while(temp_path[i] && !valid_path)
	{
		valid_path = ft_strjoin_pipex(temp_path[i], args);
		if (access(valid_path, F_OK | X_OK) != 0)
		{
			free(valid_path);
			valid_path = NULL;
		}
		i++;
	}
	if (access(valid_path, F_OK | X_OK) == 0)
		return (valid_path);
	else
		return("Invalid command"); // a faire perror
	return (valid_path);
}

t_cmd	verif_cmd(t_data *data, char *cmd_av, char **envp) // mets les args en tabs
{
	t_cmd	command;

	command.ac = ft_split(cmd_av, ' ');
	command.path = check_cmd_path(data, *command.ac, envp);

	// int i =0;
	if (execve(command.path, command.ac, envp) == -1) 
	{
		// printf("TESTTTTTTTTTTTT\n");
		perror("execve");
		exit(EXIT_FAILURE);
		// i++;
	}
	else
		printf("Le PATH de ma cmd est : %s\n", command.path); // a suppr
	
	return (command);
}

void	recup_cmd(t_data *data, char **av, char **envp)
{
	data->cmd_one = verif_cmd(data, av[2], envp);
	data->cmd_two = verif_cmd(data, av[3], envp);
}

int main(int ac, char **av, char **envp)
{
	t_data data;

	recup_cmd(&data, av, envp);
}
