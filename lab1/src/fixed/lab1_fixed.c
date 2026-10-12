#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

static void print_ids(const char *label)
{
    uid_t real_uid;
    uid_t effective_uid;
    uid_t saved_uid;

    if (getresuid(&real_uid, &effective_uid, &saved_uid) != 0) {
        perror("getresuid");
        exit(EXIT_FAILURE);
    }

    printf("%s getresuid: real_uid=%u effective_uid=%u saved_uid=%u\n",
           label, (unsigned int)real_uid, (unsigned int)effective_uid,
           (unsigned int)saved_uid);
    fflush(stdout);
}

int main(int argc, char **argv)
{
    int verify_drop = argc > 1 && strcmp(argv[1], "--verify-drop") == 0;
    const char *text = verify_drop ? (argc > 2 ? argv[2] : "drop-check")
                                   : (argc > 1 ? argv[1] : "safe default");
    uid_t real_uid;
    uid_t effective_uid;
    uid_t saved_uid;
    char *const command_argv[] = {
        (char *)"/usr/bin/printf", (char *)"fixed input: %s\n", (char *)text,
        NULL
    };
    char *const clean_environment[] = {
        (char *)"PATH=/usr/bin:/bin", (char *)"IFS= \t\n", (char *)"LANG=C",
        NULL
    };

    print_ids("before-drop");
    if (getresuid(&real_uid, &effective_uid, &saved_uid) != 0) {
        perror("getresuid");
        return EXIT_FAILURE;
    }

    /* Drop real, effective, and saved IDs before invoking another program. */
    if (setresuid(real_uid, real_uid, real_uid) != 0) {
        perror("setresuid permanent drop");
        return EXIT_FAILURE;
    }
    print_ids("after-drop");

    if (verify_drop) {
        errno = 0;
        if (setresuid(0, 0, 0) == 0) {
            fprintf(stderr, "UNEXPECTED: privilege re-elevation succeeded\n");
            return EXIT_FAILURE;
        }
        printf("EXPECTED: setresuid(0, 0, 0) failed: %s\n", strerror(errno));
        print_ids("after-re-elevation-attempt");
    }

    execve("/usr/bin/printf", command_argv, clean_environment);
    perror("execve /usr/bin/printf");
    return EXIT_FAILURE;
}