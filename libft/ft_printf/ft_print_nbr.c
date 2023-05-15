/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_nbr.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/11/29 11:46:27 by bfresque          #+#    #+#             */
/*   Updated: 2023/02/06 10:13:37 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/ft_printf.h"
#include "../../includes/libft.h"

long int	ft_size_num(int n)
{
	int	len;

	len = 0;
	if (n <= 0)
		len = 1;
	while (n != 0)
	{
		n /= 10;
		len++;
	}
	return (len);
}

char	*ft_itoa_printf(int n)
{
	char			*str;
	long int		i;
	unsigned int	nb;

	i = ft_size_num(n);
	str = malloc(sizeof(char) * i + 1);
	if (!str)
		return (NULL);
	str[i] = '\0';
	if (n == 0)
		str[0] = '0';
	if (n < 0)
	{
		nb = n * -1;
		str[0] = '-';
	}
	else
		nb = n;
	while (nb > 0)
	{
		i--;
		str[i] = '0' + (nb % 10);
		nb /= 10;
	}
	return (str);
}

int	ft_print_nbr(int nb)
{
	int		len;
	char	*num;

	len = 0;
	num = ft_itoa_printf(nb);
	len = ft_print_str(num);
	free(num);
	return (len);
}
