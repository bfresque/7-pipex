# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tester.sh                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: bfresque <bfresque@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/02/03 15:52:37 by nserve            #+#    #+#              #
#    Updated: 2023/06/13 15:10:15 by bfresque         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

PROJECT_DIRECTORY="../pipex"

NC="\033[0m"
BOLD="\033[1m"
ULINE="\033[4m"
RED="\033[0;91m"
GREEN="\033[0;92m"
YELLOW="\033[0;93m"
BLUE="\033[0;94m"
MAGENTA="\033[0;95m"

#Check bash cmd are installed
commands_needed=("awk" "sleep" "date" "awk" "dirname" "touch" "chmod" "ping" "git" "mkdir" "make" "nm" "grep" "wc" "cat" "hostname" "head")
for command_needed in "${commands_needed[@]}"
do
	command -v $command_needed > /dev/null 2>&1 || fatal_error "'$command_needed' command not installed... Aborting."
done

#Check valgrind is installed
LEAKS=1
MEMLEAKS=""
LEAK_RETURN=240
if ! command -v valgrind > /dev/null 2>&1
then
	printf "${YELLOW}valgrind is not installed. Memory leaks detection is not enabled...${NC}\n"
	LEAKS=0
else
	if [ $LEAKS -gt 0 ]
	then
		MEMLEAKS="valgrind  --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --undef-value-errors=no --error-exitcode=$LEAK_RETURN --trace-children=yes --track-fds=yes --suppressions=assets/supp.supp"
	fi
fi

#Create outs folder
if ! mkdir -p outs > /dev/null 2>&1
then
	fatal_error "Unable to create the out logs folder..."
fi
if ! [ -w outs ]
then
	fatal_error "Unable to write to the 'outs' folder as your user...${NC}"
fi

TESTS_OK=0
TESTS_KO=0
TESTS_LK=0
TESTS_TO=0
#exec 3>&1 see later purpose

#Test functions
pipex_summary()
{
	exec 1>&3
	printf "\n\n"
	printf "\t${BOLD}Summary${NC}\n\n" > /dev/stdout
	
	[ $TESTS_OK -gt 0 ] && printf "${GREEN}$TESTS_OK OK${NC}"
	[ $TESTS_OK -gt 0 ] && [ $TESTS_KO -gt 0 ] && printf " - "
	[ $TESTS_KO -gt 0 ] && printf "${RED}$TESTS_KO KO${NC}"
	([ $TESTS_OK -gt 0 ] || [ $TESTS_KO -gt 0 ]) && [ $TESTS_LK -gt 0 ] && printf " - "
	[ $TESTS_LK -gt 0 ] && printf "${RED}$TESTS_LK LK${NC}"
	([ $TESTS_OK -gt 0 ] || [ $TESTS_KO -gt 0 ] || [ $TESTS_LK -gt 0 ]) && [ $TESTS_TO -gt 0 ] && printf " - "
	[ $TESTS_TO -gt 0 ] && printf "${RED}$TESTS_TO TO${NC}"
	printf "\n\n"
	
	printf "${GREEN}OK${NC}: Test passed\n"
	printf "${YELLOW}OK${NC}: Not optimal or like bash (should not invalidate the project)\n"
	printf "${RED}KO${NC}: Test did not pass\n"
	printf "${RED}LK${NC}: Test detected leaks\n"
	printf "${RED}TO${NC}: Test timed out\n"
	
	if [ $TESTS_KO -eq 0 ] && [ $TESTS_LK -eq 0 ] && [ $TESTS_TO -eq 0 ]
	then
		exit 0
	else
		exit 1
	fi
}

should_execute()
{
	ref=$1
	shift
	tests=("$@")
	if [ ${#tests} -eq 0 ]
	then
		return 0
	else
		for test_number in "${tests[@]}"
		do
			if [ "$ref" == "$test_number" ]; then return 0; fi
		done
	fi
	return 1
}

wait_for_timeout()
{
	sleep 5
	if kill -0 $1 > /dev/null 2>&1
	then
		kill $1
	fi
}

pipex_test()
{
	$MEMLEAKS "$@" &
	bg_process=$!
	wait_for_timeout $bg_process &
	wait $bg_process
	status_code=$?
	return $status_code
}

pipex_verbose()
{
	if [ "$result" != "OK" ] || [ "$result_color" != "$GREEN" ]
	then
		[ -f outs/test-$num.txt ] && echo "Your pipex:" && cat outs/test-$num.txt
		[ -f outs/test-$num-original.txt ] && echo "Bash:" && cat outs/test-$num-original.txt
		[ -f outs/test-$num-tty.txt ] && echo "Your tty output:" && cat outs/test-$num-tty.txt
		[ -f outs/test-$num-exit.txt ] && echo "Your exit status:" && cat outs/test-$num-exit.txt
	fi
}

printf "\n"
printf "${BOLD}Tests:${NC}\n\n"
trap pipex_summary SIGINT
num="00"
test_suites=("$@")

# TEST 01
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program compiles"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute "${num##0}" "${test_suites[@]}"
then
	make -C $PROJECT_DIRECTORY > outs/test-$num.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" > outs/test-$num-exit.txt
	if [ $status_code -eq 0 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		TESTS_KO=$(($TESTS_KO + 1))
		result="KO"
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 02
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program is executable as ./pipex"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	if [ -x $PROJECT_DIRECTORY/pipex ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		TESTS_KO=$(($TESTS_KO + 1))
		result="KO"
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 0
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the last command's status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	PATH=$PWD/assets:$PATH pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "exit_status" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 5 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 03
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program does not crash with no parameters"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -ne 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 04
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program does not crash with one parameter"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -ne 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 05
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program does not crash with two parameters"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -ne 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 06
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program does not crash with three parameters"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -ne 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 07
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles infile's open error"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "not-existing/deepthought.txt" "grep Now" "wc -w" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 08
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output when infile's open error occur is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "not-existing/deepthought.txt" "grep Now" "wc -w" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< /dev/null grep Now | wc -w > outs/test-$num-original.txt 2>&1
	if [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 09
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles outfile's open error"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "not-existing/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -ne 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 10
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles execve errors"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	chmod 644 assets/deepthought.txt
	PATH=$PWD/assets:$PATH pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "not-executable" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -ne 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 11
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles path that doesn't exist"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	PATH=/not/existing:$PATH pipex_test env -i $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 127 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 12
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program uses the environment list"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	PATH=$PWD/assets:$PATH VAR1="hello" VAR2="world" pipex_test $PROJECT_DIRECTORY/pipex "/dev/null" "env_var" "cat" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	VAR1="hello" VAR2="world" ./assets/env_var > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${BOLD}Mandatory tests:${NC}\n"
printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"cat\" \"hostname\" \"outs/test-xx.txt\"\n\n"

# TEST 10
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "hostname" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" > outs/test-$num-exit.txt
	if [ $status_code -eq 0 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST 11
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "hostname" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt cat | hostname > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"head -2\" \"outs/test-xx.txt\"\n\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "head -2" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" > outs/test-$num-exit.txt
	if [ $status_code -eq 0 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "head -2" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt grep Now | head -2 > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"wc -w\" \"outs/test-xx.txt\"\n\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" > outs/test-$num-exit.txt
	if [ $status_code -eq 0 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "wc -w" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt grep Now | wc -w > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"cat\" \"outs/test-xx.txt\"\n"
printf "${ULINE}then:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"wc -w\" \"cat\" \"outs/test-xx.txt\"\n\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "cat" "outs/test-$num.txt" > outs/test-$num.0-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" > outs/test-$num-exit.txt
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "wc -w" "cat" "outs/test-$num.txt" > outs/test-$num.1-tty.txt 2>&1
	status_code2=$?
	echo -e "Exit status: $status_code2`[ $status_code2 -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" >> outs/test-$num-exit.txt
	if [ $status_code -eq 0 ] && [ $status_code2 -eq 0 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ] || [ $status_code2 -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ] || [ $status_code2 -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "cat" "outs/test-$num.txt" > outs/test-$num.0-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "wc -w" "cat" "outs/test-$num.txt" > outs/test-$num.1-tty.txt 2>&1
	status_code2=$?
	echo -e "Exit status: $status_code2`[ $status_code2 -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" >> outs/test-$num-exit.txt
	< assets/deepthought.txt grep Now | cat > outs/test-$num-original.txt
	< assets/deepthought.txt wc -w | cat > outs/test-$num-original.txt
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ] && [ $status_code2 -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ] || [ $status_code2 -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"notexisting\" \"wc\" \"outs/test-xx.txt\"\n"
printf "${ULINE}(notexisting is a command that is not supposed to exist)${NC}\n\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program handles the command"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "notexisting" "wc" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command contains 'command not found'"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "notexisting" "wc" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if grep -i "command not found" outs/test-$num-tty.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
			result_color=$RED
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "notexisting" "wc" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< /dev/null cat | wc > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"cat\" \"notexisting\" \"outs/test-xx.txt\"\n"
printf "${ULINE}(notexisting is a command that is not supposed to exist)${NC}\n\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "notexisting" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 127 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command contains 'command not found'"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "notexisting" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if grep -i "command not found" outs/test-$num-tty.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
			result_color=$RED
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "notexisting" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt cat | cat /dev/null > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"grep Now\" \"$(which cat)\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "$(which cat)" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "grep Now" "$(which cat)" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt grep Now | $(which cat) > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next test will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"/dev/urandom\" \"cat\" \"head -1\" \"outs/test-xx.txt\"\n\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program does not timeout"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "/dev/urandom" "cat" "head -1" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: 0" > outs/test-$num-exit.txt
	if [ $status_code -eq 0 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"yes\" \"head\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "yes" "head" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "yes" "head" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt yes | head > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose


# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"\" \"\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "" "" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "" "" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< assets/deepthought.txt | > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"\" \"\" \"\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "" "" "" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 2 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command contains 'syntax error near unexpected token \`|'"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "" "" "" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if grep -i "syntax error near unexpected token \`|'" outs/test-$num-tty.txt > /dev/null 2>&1 && [ $status_code -eq 2 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"cat\"  \"/cat\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "/cat" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -lt 128 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command contains 'No such file or directory'"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "cat" "/cat" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if grep -i "No such file or directory" outs/test-$num-tty.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"assets/deepthought.txt\" \"sleep 2\"  \"sleep 1\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	$PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "sleep 2" "sleep 1" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The excecution of the program last 2s"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	(time $PROJECT_DIRECTORY/pipex "assets/deepthought.txt" "sleep 2" "sleep 1" "outs/test-$num.txt") > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if grep -i "2.0" outs/test-$num-tty.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# **************************************************************************** #

printf "\n${ULINE}The next tests will use the following command:${NC}\n"
printf "$PROJECT_DIRECTORY/pipex \"/dev/stdin\" \"cat\" \"cat\" \"ls\" \"outs/test-xx.txt\"\n"

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The program exits with the right status code"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "/dev/stdin" "cat" "cat" "ls" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	if [ $status_code -lt 128 ] # 128 is the last code that bash uses before signals
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		if [ $status_code -eq 0 ]
		then
			result_color=$GREEN
		else
			result_color=$YELLOW
		fi
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_KO=$(($TESTS_KO + 1))
			result="KO"
		fi
		result_color=$RED
	fi
	printf "\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose

# TEST
num=$(echo "$num 1" | awk '{printf "%02d", $1 + $2}')
description="The output of the command is correct"
printf "${BLUE}# $num: %-69s  []${NC}" "$description"
if should_execute ${num##0} ${test_suites[@]}
then
	pipex_test $PROJECT_DIRECTORY/pipex "/dev/stdin" "cat" "cat" "ls" "outs/test-$num.txt" > outs/test-$num-tty.txt 2>&1
	status_code=$?
	echo -e "Exit status: $status_code`[ $status_code -eq $LEAK_RETURN ] && printf " (Leak special exit code)"`\nExpected: <128" > outs/test-$num-exit.txt
	< /dev/urandom cat | cat | ls > outs/test-$num-original.txt 2>&1
	if diff outs/test-$num-original.txt outs/test-$num.txt > /dev/null 2>&1 && [ $status_code -lt 128 ]
	then
		TESTS_OK=$(($TESTS_OK + 1))
		result="OK"
		result_color=$GREEN
	else
		if [ $status_code -eq 143 ]
		then
			TESTS_TO=$(($TESTS_TO + 1))
			result="TO"
			result_color=$RED
		elif [ $status_code -eq $LEAK_RETURN ]
		then
			TESTS_LK=$(($TESTS_LK + 1))
			result="LK"
		else
			TESTS_OK=$(($TESTS_OK + 1))
			result="OK"
			result_color=$YELLOW
		fi
	fi
	printf "\r\r\r${result_color}# $num: %-69s [%s]\n${NC}" "$description" "$result"
else
	printf "\n"
fi
pipex_verbose
