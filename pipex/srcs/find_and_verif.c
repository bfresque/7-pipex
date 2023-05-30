/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   find_and_verif.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/05/15 14:16:43 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/30 14:24:35 by bfresque         ###   ########.fr       */
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

char	*check_cmd_path(char *args, char **envp)
{
	char	**temp_path;
	char	*valid_path;
	int		i;

	temp_path = find_all_paths(envp);
	valid_path = NULL;
	i = 0;
	while (temp_path[i] && !valid_path)
	{
		valid_path = ft_strjoin_pipex(temp_path[i], args);
		if (access(valid_path, F_OK | X_OK) != 0)
		{
			free(valid_path);
			valid_path = NULL;
		}
		i++;
	}
	ft_free_tab(temp_path);
	if (valid_path != NULL)
	{
		if (access(valid_path, F_OK | X_OK) == 0)
			return (valid_path);
	}
	else if (valid_path == NULL)
	{
		ft_mess_error(args);
		//free()
		//exit
	}
	return (valid_path);
}

t_cmd	verif_cmd(char *cmd_av, char **envp)
{
	t_cmd	command;

	command.ac = ft_split(cmd_av, ' ');
	command.path = check_cmd_path(*command.ac, envp);
	return (command);
}

void	recup_cmd(t_data *data, char **av, char **envp)
{
	data->cmd_one = verif_cmd(av[2], envp);
	// if(data->cmd_one.path == NULL)
	// {
	// 	// ft_free_tab(data->cmd_one.ac);
	// 	// exit(-1);
	// }
	data->cmd_two = verif_cmd(av[3], envp);
	// if(data->cmd_two.path == NULL)
	// {
	// 	free(data->cmd_one.path);
	// 	ft_free_tab(data->cmd_one.ac);
	// 	ft_free_tab(data->cmd_two.ac);
	// 	exit(-1);
	// }
}
