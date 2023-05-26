/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_ptr.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/11/30 13:27:24 by bfresque          #+#    #+#             */
/*   Updated: 2023/01/12 11:51:19 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/ft_printf.h"

int	ft_ptr_len(unsigned long long nb)
{
	int	i;

	i = 0;
	while (nb != 0)
	{
		nb = nb / 16;
		i++;
	}
	return (i);
}

void	ft_ptr_base(unsigned long long nb)
{
	if (nb >= 16)
	{
		ft_ptr_base(nb / 16);
		ft_ptr_base(nb % 16);
	}
	else if (nb <= 9)
		ft_print_char(nb + '0');
	else
		ft_print_char(nb - 10 + 'a');
}

int	ft_print_ptr(unsigned long long ptr)
{
	int	printlen;

	printlen = 0;
	if (ptr == 0)
		printlen += write(1, "(nil)", 5);
	else
	{
		printlen += write(1, "0x", 2);
		ft_ptr_base(ptr);
		printlen += ft_ptr_len(ptr);
	}
	return (printlen);
}
