/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   find_and_verif.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/05/15 14:16:43 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/01 14:36:58 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

char	**find_all_paths(char **envp)
{
	char	*path;
	char	**all_paths;

	while (*envp)
	{
		if (ft_strncmp_pipex("PATH=", *envp, 5) == 0)
		{
			path = &((*envp)[5]);
			break ;
		}
		envp++;
	}
	all_paths = ft_split(path, ':');
	return (all_paths);
}

int	ft_strchr_pipex(char *str, char c)
{
	int	i;

	i = 0;
	while (str[i])
	{
		if (str[i] == c)
		{
			return (1);
		}
		i++;
	}
	return (0);
}


char	*check_cmd_path(char *args, char **envp)
{
	char	**temp_path;
	char	*valid_path;
	int		i;


	// if ((ft_strchr_pipex(args, '.') == 1) && (ft_strchr_pipex(args, '/') == 1))
	// {
	// 	execve(data->cmd_one.path, data->cmd_one.ac, envp) == -1
	// }
	
	if (ft_strchr_pipex(args, '/') == 1)
	{
		if (access(args, 0) == 0)
			return (args);
		return (NULL);
	}
	temp_path = find_all_paths(envp);
	valid_path = NULL;
	i = 0;
	while (temp_path[i] && !valid_path)
	{
		valid_path = ft_strjoin_pipex(temp_path[i], args);
		if (access(valid_path, X_OK) != 0)
		{
			free(valid_path);
			valid_path = NULL;
		}
		i++;
	}
	ft_free_tab(temp_path);
	if (valid_path != NULL)
	{
		if (access(valid_path, X_OK) == 0)
			return (valid_path);
	}
	else if (valid_path == NULL)
		ft_mess_error(args);
	return (valid_path);
}

void	recup_cmd(t_data *data, char **av, char **envp)
{
	data->cmd_one.ac = ft_split(av[2], ' ');
	data->cmd_two.ac = ft_split(av[3], ' ');

	data->cmd_one.path = check_cmd_path(*data->cmd_one.ac, envp);
	data->cmd_two.path = check_cmd_path(*data->cmd_two.ac, envp);
}


// t_cmd	verif_cmd(char *cmd_av, char **envp)
// {
// 	t_cmd	command;

// 	command.ac = ft_split(cmd_av, ' ');
// 	command.path = check_cmd_path(*command.ac, envp);
// 	return (command);
// }

// void	recup_cmd(t_data *data, char **av, char **envp)
// {
// 	data->cmd_one = verif_cmd(av[2], envp);

// 	data->cmd_two = verif_cmd(av[3], envp);

// }
