/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/12/02 11:24:07 by bfresque          #+#    #+#             */
/*   Updated: 2023/02/06 10:11:36 by bfresque         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/get_next_line.h"
#include "../../includes/libft.h"
#include <stdio.h>

char	*ft_free_gnl(char *str, char *buffer)
{
	char	*temp;

	temp = ft_strjoin_gnl(str, buffer);
	free(str);
	return (temp);
}

char	*ft_line_gnl(char *str)
{
	char	*dest;
	int		i;

	i = 0;
	if (!str[i])
		return (NULL);
	while (str[i] && str[i] != '\n')
		i++;
	dest = ft_calloc_gnl(i + 2, sizeof(char));
	i = 0;
	while (str[i] && str[i] != '\n')
	{
		dest[i] = str[i];
		i++;
	}
	if (str[i] && str[i] == '\n')
		dest[i++] = '\n';
	return (dest);
}

char	*ft_buf_gnl(char *str)
{
	int		i;
	int		j;
	char	*dest;

	i = 0;
	while (str[i] && str[i] != '\n')
		i++;
	if (!str[i])
	{
		free(str);
		return (NULL);
	}
	dest = ft_calloc_gnl((ft_strlen_gnl(str) - i + 1), sizeof(char));
	j = 0;
	while (str[i])
		dest[j++] = str[++i];
	free(str);
	return (dest);
}

char	*get_next_line(int fd)
{
	static char	*str;
	char		*buffer;
	char		*line;
	int			i;

	i = 1;
	if (fd < 0 || BUFFER_SIZE <= 0)
		return (NULL);
	if (str == 0)
		str = ft_calloc_gnl(1, 1);
	buffer = ft_calloc_gnl(BUFFER_SIZE + 1, sizeof(char));
	while (i > 0 && !(ft_strchr_gnl(buffer, '\n')))
	{
		i = read(fd, buffer, BUFFER_SIZE);
		if (i == -1)
		{
			free(buffer);
			return (NULL);
		}
		buffer[i] = '\0';
		str = ft_free_gnl(str, buffer);
	}
	free(buffer);
	return (line = ft_line_gnl(str), str = ft_buf_gnl(str), line);
}

// int main()
// {
// 	int		i;
// 	int		fd;
// 	char	*str;
// 	fd = open("Celine.txt", O_RDONLY);
// 	i = 0;
// 	 while(i < 50)
// 	{
// 		str =get_next_line(fd);
// 		printf("%s", str);
// 		free(str);
// 		i++;
// 	}
// }
