# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/04/17 10:43:18 by bfresque          #+#    #+#              #
#    Updated: 2023/06/14 14:54:56 by bfresque         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


NAME = pipex

CC = gcc

CFLAGS = -Wall -Wextra -Werror -g3

OBJ_DIR_PIPEX = srcs/obj_pipex

OBJ_DIR_LIBFT = libft/obj_libft

SRCS = srcs/pipex.c \
	srcs/utils_libft.c \
	srcs/error_and_free.c \
	srcs/find_and_verif.c \

SRC_LIBFT =	libft/libft/ft_isalpha.c \
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

SRCS_GNL =	libft/get_next_line/get_next_line.c \
			libft/get_next_line/get_next_line_utils.c \

SRCS_PRINTF =	libft/ft_printf/ft_print_b16.c \
				libft/ft_printf/ft_print_nbr.c \
				libft/ft_printf/ft_print_ptr.c \
				libft/ft_printf/ft_print_str.c \
				libft/ft_printf/ft_print_unbr.c \
				libft/ft_printf/ft_printf.c \

OBJS = $(SRCS:%.c=$(OBJ_DIR_PIPEX)/%.o) \
		$(SRC_LIBFT:%.c=$(OBJ_DIR_LIBFT)/%.o) \
		$(SRCS_GNL:%.c=$(OBJ_DIR_LIBFT)/%.o) \
		$(SRCS_PRINTF:%.c=$(OBJ_DIR_LIBFT)/%.o) \

AR = ar rcs

RM = rm -f

$(OBJ_DIR_PIPEX)/%.o $(OBJ_DIR_LIBFT)/%.o: %.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "\033[5;36m\n-gcc *.c libft done\033[0m"
	@echo "\033[5;36m-gcc *.c get_next_line done\033[0m"
	@echo "\033[5;36m-gcc *.c ft_printf done\033[0m"
	@echo "\033[5;36m-gcc *.c pipex done\n\033[0m"
	@echo "\033[1;32m[Make : 'pipex' is done]\033[0m"

all : $(NAME)

clean :
	@$(RM) $(OBJS)
	@echo "\033[1;33m[.o] Object files removed\033[0m"

fclean : clean
	@$(RM) $(NAME)
	@echo "\033[1;33m[.a] Binary file removed\033[0m"

re : fclean all

.PHONY: all clean fclean re
