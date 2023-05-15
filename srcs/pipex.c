/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:58:58 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/15 12:40:00 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"



t_cmd	decoupe_cmd(t_data *data, char *ac_cmd)
{
	t_cmd	command;
	char	**acs;

	acs = ft_split(ac_cmd, ' ');
	command.ac = acs;
	return (command);
}

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
			// printf("envp[%d] = %s\n", i, *envp);
			break;
		}
		envp++;
		i++;
	}
	all_paths = ft_split(path, ':');
	return(all_paths);
}

// char	*check_cmd_path(t_data *data, char *cmd_ac, char **envp)
// {
// 	int		i;
// 	char	**all_paths;
// 	char	*cmd_path;

// 	all_paths = find_all_paths(envp, data);
// 	i = 0;
// 	while (all_paths[i])
// 	{
// 		cmd_path = ft_strjoin_pipex(all_paths[i], cmd_ac);
// 		printf("cmd and path : %s\n", cmd_path);
// 		if (access(cmd_path, F_OK | X_OK) == 0)
// 			break ;
// 		i++;
// 	}
// 	return (cmd_path);
// }


char *check_cmd_path(t_data *data, char *args, char **envp) 
{
	char **temp_path;
	char *valid_path;
	int i;

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

t_cmd	verif_cmd(t_data *data, char *cmd, char **envp)
{
	t_cmd	command;

	command = decoupe_cmd(data, cmd);
	if (command.ac == NULL)
		return (command);
	command.path = check_cmd_path(data, *command.ac, envp);
	printf("\n\n command path :  = %s\n", command.path);
	return (command);
}

void	recup_cmd(t_data *data, char **av, char **envp)
{
	data->cmd_one = verif_cmd(data, av[2], envp);
	data->cmd_two = verif_cmd(data, av[3], envp);
	// printf("cmd_one first argc : %s\n", *data->cmd_one.ac);
}

int main(int ac, char **av, char **envp)
{
	t_data data;

	recup_cmd(&data, av, envp);
	// printf("\n\n tab first = %s\n", *data.all_paths);
}

 
// void	all_ac(int ac, char **av, char **envp, t_data *data)
// {
// 	int i = 1;
// 	char *cmd = NULL;
// 	int  y = 0;
// 	while (i < ac)
// 	{
// 		cmd[y] = av[i];
// 		// data->all_ac = ft_split(av[i], ' ');
// 		// printf("ac = %s\n", *data->all_ac);
// 		i++;
// 		y++;
// 	}
// 	printf("tt ac = %s\n", cmd);
// } 

// #include <unistd.h>
// #include <stdio.h>
// #include <stdlib.h>

// int main() {
//     char *const argv[] = {"ls", "-l", NULL};
//     char *const envp[] = {NULL};

//     if (execve("/bin/ls", argv, envp) == -1) {
//         perror("execve");
//         exit(EXIT_FAILURE);
//     }

//     // Cette ligne ne sera jamais exécutée
//     printf("Ce message ne sera jamais affiché\n");

//     return 0;
// }