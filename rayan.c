int parent_process(int f2, char **cmd2, t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_one.path, data->cmd_one.ac, envp);
	return (0);
}

int child_process(int f1, char **cmd1, t_data *data, char **av, char **envp)
{
	recup_cmd(data, av, envp);
	execve(data->cmd_two.path, data->cmd_two.ac, envp);
	return (0);
}

void	pipex(int f1, int f2, t_data *data, char **av, char **envp)
{
	pid_t	pid;
	pid = fork();
	
	if (pid < 0)
	{
		return (perror("Fork: "));
	}
	if (pid == 0)
	{
		child_process(f1, data->cmd_one.ac, data, av, envp);
	}
	else if (pid > 0)
	{
		parent_process(f2, data->cmd_two.ac, data, av, envp);
	}
}
