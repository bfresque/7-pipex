# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/04/17 10:43:18 by bfresque          #+#    #+#              #
#    Updated: 2023/05/15 15:15:53 by bfresque         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = pipex

NAME_LIB = libft/libft/libft.a
NAME_GNL = get_next_line.a
NAME_PRINTF = libftprintf.a

CC = gcc

CFLAGS = -Wall #-Wextra -Werror -g3

GREEN = \033[92m
YELLOW = \033[33m
NEUTRAL = \033[0m
I = \033[3m

SRCS_LIB =	libft/libft/ft_isalpha.c \
			libft/libft/ft_isdigit.c \
			libft/libft/ft_isalnum.c \
			libft/libft/ft_isascii.c \
			libft/libft/ft_isprint.c \
			libft/libft/ft_strlen.c \
			libft/libft/ft_memset.c \
			libft/libft/ft_bzero.c \
			libft/libft/ft_memcpy.c \
			libft/libft/ft_memmove.c \
			libft/libft/ft_strlcpy.c \
			libft/libft/ft_strlcat.c \
			libft/libft/ft_toupper.c \
			libft/libft/ft_tolower.c \
			libft/libft/ft_strchr.c \
			libft/libft/ft_strrchr.c \
			libft/libft/ft_strncmp.c \
			libft/libft/ft_strcmp.c \
			libft/libft/ft_memchr.c \
			libft/libft/ft_memcmp.c \
			libft/libft/ft_strnstr.c \
			libft/libft/ft_atoi.c \
			libft/libft/ft_calloc.c \
			libft/libft/ft_strdup.c \
			libft/libft/ft_substr.c \
			libft/libft/ft_strjoin.c \
			libft/libft/ft_split.c \
			libft/libft/ft_strmapi.c \
			libft/libft/ft_striteri.c \
			libft/libft/ft_putchar_fd.c \
			libft/libft/ft_putstr_fd.c \
			libft/libft/ft_putendl_fd.c \
			libft/libft/ft_putnbr_fd.c \
			libft/libft/ft_strtrim.c \
			libft/libft/ft_itoa.c \
			libft/libft/ft_lstnew.c \
			libft/libft/ft_lstadd_front.c \
			libft/libft/ft_lstsize.c \
			libft/libft/ft_lstlast.c \
			libft/libft/ft_lstadd_back.c \
			libft/libft/ft_lstdelone.c \
			libft/libft/ft_lstclear.c \
			libft/libft/ft_lstiter.c \
			libft/libft/ft_lstmap.c \

SRCS_PRINTF =	libft/ft_printf/ft_print_b16.c \
				libft/ft_printf/ft_print_nbr.c \
				libft/ft_printf/ft_print_ptr.c \
				libft/ft_printf/ft_print_str.c \
				libft/ft_printf/ft_print_unbr.c \
				libft/ft_printf/ft_printf.c \

SRCS_GNL =	libft/get_next_line/get_next_line.c \
			libft/get_next_line/get_next_line_utils.c \

SRCS =	srcs/pipex.c \
		srcs/utils.c \
		srcs/find_and_verif.c \

OBJS = $(SRCS_LIB:.c=.o) $(SRCS_PRINTF:.c=.o) $(SRCS_GNL:.c=.o) $(SRCS:.c=.o)

AR = ar rcs

RM = rm -f

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "$(I)$(YELLOW)Compilation LIBFT Done $(NEUTRAL)"
	@echo "$(I)$(YELLOW)Compilation FT_PRINTF Done $(NEUTRAL)"
	@echo "$(I)$(YELLOW)Compilation GNL Done \n$(NEUTRAL)"
	@echo "$(GREEN)Compilation PIPEX Done $(NEUTRAL)"

all : $(NAME)

clean :
	@$(RM) $(OBJS)
	@echo "$(GREEN)Object files removed $(NEUTRAL)"

fclean : clean
	@$(RM) $(NAME)
	@echo "$(GREEN)Binary file removed $(NEUTRAL)"

re : fclean all

.PHONY: all clean fclean re