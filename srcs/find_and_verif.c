/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   find_and_verif.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/05/15 14:16:43 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/14 15:04:57 by bfresque         ###   ########.fr       */
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
	if (path == NULL)
		return (NULL);
	all_paths = ft_split(path, ':');
	return (all_paths);
}

char	*check_absolute_path(char *args)
{
	if (ft_strchr_pipex(args, '/') == 1)
	{
		if (access(args, F_OK | X_OK) == 0)
			return (ft_strdup(args));
		else
			return (NULL);
	}
	return (NULL);
}

char	*find_valid_path(char **temp_path, char *args)
{
	char	*valid_path;
	int		i;

	i = 0;
	valid_path = NULL;
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
	return (valid_path);
}

char	*check_cmd_path(char *args, char **envp)
{
	char	**temp_path;
	char	*valid_path;

	temp_path = find_all_paths(envp);
	if (ft_isascii(temp_path[0][0]) == 0)
	{
		write(2, "No such file or directory: ", 28);
		write(2, args, ft_strlen(args));
		write(2, "\n", 1);
		return (NULL);
	}
	valid_path = find_valid_path(temp_path, args);
	ft_free_tab(temp_path);
	if (valid_path != NULL)
	{
		if (access(valid_path, F_OK | X_OK) == 0)
			return (valid_path);
	}
	ft_mess_error(args);
	return (NULL);
}

char	*ft_check_paths(char *args, char **envp)
{
	char	*valid_path;

	valid_path = check_absolute_path(args);
	if (valid_path != NULL)
		return (valid_path);
	valid_path = check_cmd_path(args, envp);
	return (valid_path);
}
