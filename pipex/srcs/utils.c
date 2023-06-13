/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/05/10 14:38:54 by bfresque          #+#    #+#             */
/*   Updated: 2023/06/13 10:14:16 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/pipex.h"

int	ft_strncmp_pipex(char *s1, char *s2, int n)
{
	int	i;

	i = 0;
	while ((i < n) && (s1[i] == s2[i]) && s1[i] && s2[i])
		i++;
	if (i < n)
		return (s1[i] - s2[i]);
	return (0);
}

char	*ft_strjoin_pipex(char *s1, char *s2)
{
	int		i;
	int		j;
	char	*dest;

	i = ft_strlen(s1) + ft_strlen(s2);
	dest = malloc(sizeof(char) *(i + 2));
	if (!dest)
		return (NULL);
	i = 0;
	j = 0;
	while (s1[i])
	{
		dest[i] = s1[i];
		i++;
	}
	dest[i] = '/';
	i++;
	while (s2[j])
	{
		dest[i + j] = s2[j];
		j++;
	}
	dest[i + j] = '\0';
	return (dest);
}

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
	char	*s2;
	int		i;
	int		y;

	s2 = " : command not found\n";
	i = ft_strlen(str);
	y = ft_strlen(s2);
	write(2, str, i);
	write(2, s2, y);
}

void	ft_free_all_data(t_data *data)
{
	free(data->cmd_one.path);
	free(data->cmd_two.path);
	ft_free_tab(data->cmd_one.ac);
	ft_free_tab(data->cmd_two.ac);
}
