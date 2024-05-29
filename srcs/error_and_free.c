/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   error_and_free.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/06/14 14:39:03 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/14 18:34:09 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

void	ft_free_tab(char **tab)
{
	int	i;

	i = 0;
	while (tab[i])
	{
		free(tab[i]);
		i++;
	}
	free(tab);
}

void	ft_mess_error(char *str)
{
	if (!ft_strncmp(str, "cd", ft_strlen(str)))
		return ;
	write(2, "command not found: ", 19);
	write(2, str, ft_strlen(str));
	write(2, "\n", 1);
}

void	ft_free_all_data(t_data *data)
{
	free(data->cmd_one.path);
	free(data->cmd_two.path);
	ft_free_tab(data->cmd_one.ac);
	ft_free_tab(data->cmd_two.ac);
}
