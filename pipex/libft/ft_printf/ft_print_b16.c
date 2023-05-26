/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_b16.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/11/30 11:54:50 by bfresque          #+#    #+#             */
/*   Updated: 2023/01/12 11:51:09 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/ft_printf.h"

int	ft_hex_len(unsigned int nb)
{
	int	len;

	len = 0;
	while (nb != 0)
	{
		nb = nb / 16;
		len++;
	}
	return (len);
}

void	ft_putnbr_hex(unsigned int nb, const char format)
{
	if (nb >= 16)
	{
		ft_putnbr_hex(nb / 16, format);
		ft_putnbr_hex(nb % 16, format);
	}
	else
	{
		if (nb <= 9)
			ft_print_char(nb + '0');
		else if (format == 'x')
			ft_print_char(nb - 10 + 'a');
		else if (format == 'X')
			ft_print_char(nb - 10 + 'A');
	}
}

int	ft_print_b16(unsigned int nb, const char format)
{
	if (nb == 0)
		return (write(1, "0", 1));
	else
		ft_putnbr_hex(nb, format);
	return (ft_hex_len(nb));
}
