/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_utils.c                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/12/02 11:24:18 by bfresque          #+#    #+#             */
/*   Updated: 2023/02/06 10:10:36 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/get_next_line.h"
#include "../../includes/libft.h"
#include <stdio.h>

size_t	ft_strlen_gnl(const char *s)
{
	int	i;

	i = 0;
	while (s[i])
		i++;
	return (i);
}

char	*ft_strchr_gnl(const char *s, int c )
{
	char	*str;

	str = (char *)s;
	while (*str != c && *str != 0)
		str++;
	if (*str == c)
		return (str);
	else
		return (NULL);
}

void	*ft_calloc_gnl(size_t nmemb, size_t size)
{
	char	*tab;
	size_t	i;
	size_t	total;

	if (nmemb >= SIZE_MAX || size >= SIZE_MAX)
		return (NULL);
	total = nmemb * size;
	tab = malloc(total);
	if (!tab)
		return (NULL);
	i = 0;
	while (i < total)
	{
		tab[i] = '\0';
		i++;
	}
	return (tab);
}

char	*ft_strjoin_gnl(char *s1, char *s2)
{
	char	*dest;
	int		i;
	int		j;

	if (!s1)
	{
		s1 = malloc(sizeof(char) * 1);
		s1[0] = '\0';
	}
	dest = malloc(sizeof(char) * (ft_strlen_gnl(s1) + ft_strlen_gnl(s2) + 1));
	if (!dest || !s1 || !s2)
	{
		free(s1);
		free(dest);
		return (NULL);
	}
	i = 0;
	j = 0;
	while (s1[i] != 0)
		dest[j++] = s1[i++];
	j = 0;
	while (s2[j] != 0)
		dest[i++] = s2[j++];
	dest[ft_strlen_gnl(s1) + ft_strlen_gnl(s2)] = '\0';
	return (dest);
}
