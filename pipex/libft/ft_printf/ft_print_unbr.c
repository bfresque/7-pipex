/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_unbr.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/11/29 13:23:38 by bfresque          #+#    #+#             */
/*   Updated: 2023/01/12 11:51:26 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/ft_printf.h"

long int	ft_size_unum(unsigned int n)
{
	int	len;

	len = 0;
	while (n != 0)
	{
		n /= 10;
		len++;
	}
	return (len);
}

char	*ft_uitoa(unsigned int n)
{
	char					*str;
	long unsigned int		i;

	i = ft_size_unum(n);
	str = malloc(sizeof(char) * i + 1);
	if (!str)
		return (NULL);
	str[i] = '\0';
	while (n > 0)
	{
		i--;
		str[i] = '0' + (n % 10);
		n /= 10;
	}
	return (str);
}

int	ft_print_unsigned(unsigned int n)
{
	int		printlen;
	char	*num;

	printlen = 0;
	if (n == 0)
		printlen += write(1, "0", 1);
	else
	{
		num = ft_uitoa(n);
		printlen += ft_print_str(num);
		free(num);
	}
	return (printlen);
}
