/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:59:36 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/30 10:17:26 by bfresque         ###   ########.fr       */
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

# define INT_MAX 2147483647
# define INT_MIN -2147483648

# define STDIN 0
# define STDOUT 1
# define STDERR 2

# define INFILE 0
# define OUTFILE 1

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

# define RESET "\033[0m"
# define BLACK "\033[30m"
# define RED "\033[31m"
# define GREEN "\033[32m"
# define YELLOW "\033[33m"
# define BLUE "\033[34m"
# define MAGENTA "\033[35m"
# define CYAN "\033[36m"
# define WHITE "\033[37m"

/*********************	pipex.c ********************************/

/*********************	find_and_verif.c ***********************/
// char	**find_all_paths(char **envp);
// char	*check_cmd_path(char *args, char **envp);
// t_cmd	verif_cmd(char *cmd_av, char **envp);
void	recup_cmd(t_data *data, char **av, char **envp);

/*********************	utils.c ********************************/
int		ft_strncmp_pipex(char *s1, char *s2, int n);
char	*ft_strjoin_pipex(char *s1, char *s2);
void	ft_free_all_data(t_data *data);
void	ft_free_tab(char **tab);

#endif