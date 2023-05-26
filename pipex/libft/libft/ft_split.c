/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_split.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/11/10 15:23:13 by bfresque          #+#    #+#             */
/*   Updated: 2023/05/10 13:26:11 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/libft.h"

static char	ft_separateur(char cmp, char c)
{
	if (cmp == c)
		return (1);
	return (0);
}

static int	ft_alloctxt(char **tab, char *s, char c)
{
	int	word_len;
	int	i;

	i = 0;
	while (*s)
	{
		while (*s && ft_separateur(*s, c))
			s++;
		word_len = 0;
		while (*s && ft_separateur(*s, c) == 0)
		{
			word_len++;
			s++;
		}
		if (word_len != 0)
		{
			tab[i] = malloc(word_len + 1);
			if (tab[i] == 0)
				return (0);
			tab[i++][word_len] = 0;
		}
	}
	return (1);
}

static void	ft_filltab(char **tab, char *s, char c)
{
	int	i;
	int	j;

	i = 0;
	while (*s && tab[i])
	{
		while (*s && ft_separateur(*s, c))
			s++;
		j = 0;
		while (*s && ft_separateur(*s, c) == 0)
			tab[i][j++] = *(s++);
		i++;
	}
}

static unsigned int	ft_countwords(char *s, char c)
{
	int	count;
	int	i;

	i = 0;
	count = 0;
	while (s[i])
	{
		if (s[i] && ft_separateur(s[i], c) == 0)
		{
			count++;
			i++;
		}
		while (s[i] && ft_separateur(s[i], c) == 0)
			i++;
		while (s[i] && ft_separateur(s[i], c))
			i++;
	}
	return (count);
}

char	**ft_split(char *s, char c)
{
	char				**tab;
	unsigned int		nb_words;
	unsigned int		i;

	if (!s)
		return (NULL);
	nb_words = ft_countwords(s, c);
	tab = malloc((nb_words + 1) * sizeof(char *));
	if (tab == 0)
		return (0);
	tab[nb_words] = 0;
	if (nb_words > 0)
	{
		if (ft_alloctxt(tab, s, c) == 0)
		{
			i = 0;
			while (tab[i])
				free(tab[i++]);
			free(tab);
			return (0);
		}
		ft_filltab(tab, s, c);
	}
	return (tab);
}
