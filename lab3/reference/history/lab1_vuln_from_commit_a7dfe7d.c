#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

static void print_ids(void)
{
    uid_t real_uid;
    uid_t effective_uid;
    uid_t saved_uid;

    if (getresuid(&real_uid, &effective_uid, &saved_uid) != 0) {
        perror("getresuid");
        exit(EXIT_FAILURE);
    }

    printf("getresuid: real_uid=%u effective_uid=%u saved_uid=%u\n",
           (unsigned int)real_uid, (unsigned int)effective_uid,
           (unsigned int)saved_uid);
    fflush(stdout);
}

static void usage(const char *program)
{
    fprintf(stderr, "Usage: %s identify | shell <text> | lookup\n", program);
}

int main(int argc, char **argv)
{
    print_ids();

    if (argc == 2 && strcmp(argv[1], "identify") == 0) {
        return EXIT_SUCCESS;
    }

    if (argc == 3 && strcmp(argv[1], "shell") == 0) {
        const char prefix[] = "echo lab1-input: ";
        size_t command_size = sizeof(prefix) + strlen(argv[2]);
        char *command = malloc(command_size);

        if (command == NULL) {
            perror("malloc");
            return EXIT_FAILURE;
        }
        snprintf(command, command_size, "%s%s", prefix, argv[2]);

        // Deliberately unsafe: input becomes Bash code in a privileged process. 
        execl("/bin/bash", "bash", "-p", "-c", command, (char *)NULL);
        perror("execl /bin/bash");
        free(command);
        return EXIT_FAILURE;
    }

    if (argc == 2 && strcmp(argv[1], "lookup") == 0) {
        char *const helper_argv[] = { (char *)"lab1-helper", NULL };

        // Deliberately unsafe: execvp searches the caller-controlled PATH.
        execvp("lab1-helper", helper_argv);
        perror("execvp lab1-helper");
        return EXIT_FAILURE;
    }

    usage(argv[0]);
    return EXIT_FAILURE;
}