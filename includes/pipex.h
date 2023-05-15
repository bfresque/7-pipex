/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/04/17 10:59:36 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/12 13:50:42 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include "../includes/get_next_line.h"
# include "../includes/libft.h"
# include "../includes/ft_printf.h"
# include <stdio.h>
# include <stdlib.h>

# define INT_MAX 2147483647
# define INT_MIN -2147483648

typedef struct s_cmd
{
	char	**ac;
	char	*path;
	;
}	t_cmd;

typedef struct s_data
{
	char	**all_paths;
	t_cmd	cmd_one;
	t_cmd	cmd_two;
	char *test;
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


/*********************	utils.c ********************************/
int	ft_strncmp_pipex(char *s1, char *s2, int n);
char	*ft_strjoin_pipex(char *s1, char *s2);

#endif