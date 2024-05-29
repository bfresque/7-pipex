# **7-Pipex**

Debut le 17 avril 2023

## **INTRODUCTION :**

Les pipes : les pipes sont des mécanismes de communication interprocessus (IPC) qui permettent de transférer le flux de données d'un processus à un autre. Dans le contexte de Pipex, je vais utiliser les pipes pour transférer le flux de données entre les deux fichiers et les deux commandes.

Les redirections : les redirections sont des opérations qui permettent de rediriger le flux d'entrée/sortie standard (stdin/stdout) d'un processus vers un fichier ou vers un autre processus. Dans le contexte de Pipex, je vais utiliser les redirections pour lire et écrire les données dans les fichiers.

Les processus : un processus est une instance d'un programme en cours d'exécution. Dans le contexte de Pipex, je vais utiliser plusieurs processus pour exécuter les différentes commandes et réaliser les différentes étapes du transfert de données entre les fichiers.

Le concept clé de Pipex est de réaliser le transfert de données entre deux fichiers en utilisant les pipes et les redirections pour connecter les différentes étapes du processus. 

## **COMMANDES :**

- PPID : $ echo "PID = $$; PPID = $PPID"
- Voir tous les processus actifs : $ ps -e
- Tuer les processus fils : int kill(pid_t pid, int sig);
    -> il faut ajouter la lib <signal.h> 
- Check your fds currently open : ls -la /proc/$$/fd
- Check whether the command exists and is executable : access()
- La fonction dup2() permet de rediriger les entrées/sorties standard d'un descripteur de fichier vers un autre descripteur. Voici sa syntaxe :



**=> TEST :**
- valgrind --track-origins=yes --trace-children=yes --track-fds=yes --leak-check=full env -i ./pipex /dev/stdin "ls" "cat -e" /dev/stdout
- ./pipex /dev/stdin cat ls /dev/stdout, et je compare a < /dev/stdin cat | ls /dev/stdout
- env -i ./pipex infile "cat test.txt" "grep b" outfile // pour enlever l env
- valgrind --trace-children=yes ./pipex infile ls ls outfile //tester les leacks des childs
- valgrind --track-fds=yes ./pipex infile ls ls outfile // verifer les close/open des fd
- ./pipex infile lls ls outfile // la premiere doit foiree ma la deuxieme doit correctement etre executee vis versa
- ./pipex infile ./a.out cat test   // faire une condition(if av[1] == "./") si il y a un "./" directement envoyer dans le execve
- valgrind ./pipex infile ls ls outfile  // a tester avec les droits de infile et de outfile a 0 atention il doit retourner "infile ou outfile : permission denied"
- valgrind ./pipex infile "cat infile"  "/usr/bin/wc" outfile 

Autres tests : 
- cas classiques (fd NULL, n existe pas, pas les autorisations minimum, cmd pareil)
- cas particuliers (surtout cat|cat|ls ou yes|head)
- un nom de dossier (est ce que autre chose que cat pour ouvrir un dossier en msg d ereur ?)
- un chemin absolu / sans environement env -i (ou  -u)
- un executable
- les leaks en fonction des permission chmod 777 / chmod 0

ERREUR DETECTÉE:
./pipex outfile "cat outfile" "grep i" outfile 
	Erreur: si le fichier d'entree est le meme que celui vers lequel on redirige (d'apres bash on est sensé tout ecrase sans trier) nous trions une premiere fois puis nous ecrasons
SOLUTION: potentielle: suprimer le file(av[1]) avec rm et le recreer avec touch(av[1]) 



## **PIPE :**

En cas de succès, pipe renvoie 0. 
Par contre en cas d’échec, il renvoie -1, décrit l’erreur rencontrée dans errno, 
et ne remplit pas le tableau fourni.

0 = entre standard.
1 = sortie standard.
2 = sortie d'erreur.



## **FORK :**

La fonction fork() va dupliquer le processus courant. 
Lorsque l'ont va arriver au fork(), un nouveau processus identique au premier va être créer. C'est un peu comme si on se retrouvait a avoir lance deux fois le même programme. Sauf que fork() retourne un pid. 
Si le pid retourné est égal a 0, on est dans le processus qui vient d’être crée (processus fils). 
Sinon, le pid est égal au pid du processus fils.


