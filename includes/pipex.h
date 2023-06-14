/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:59:36 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/14 15:06:57 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include "../includes/get_next_line.h"
# include "../includes/libft.h"
# include "../includes/ft_printf.h"

# include <unistd.h>
# include <stdlib.h>
# include <stddef.h>
# include <stdio.h>
# include <stdint.h>
# include <string.h>
# include <fcntl.h>
# include <sys/stat.h>
# include <sys/types.h>
# include <sys/wait.h>

typedef struct s_cmd
{
	char	**ac;
	char	*path;
}	t_cmd;

typedef struct s_data
{
	char	**all_paths;
	t_cmd	cmd_one;
	t_cmd	cmd_two;
	char	*test;
}	t_data;

/*********************	find_and_verif.c ***********************/
char	*ft_check_paths(char *args, char **envp);

/*********************	utils_libft.c **************************/
int		ft_strncmp_pipex(char *s1, char *s2, int n);
int		ft_strchr_pipex(char *str, char c);
char	*ft_strjoin_pipex(char *s1, char *s2);

/*********************	error_and_free.c ***********************/
void	ft_free_all_data(t_data *data);
void	ft_free_tab(char **tab);
void	ft_mess_error(char *str);

#endif