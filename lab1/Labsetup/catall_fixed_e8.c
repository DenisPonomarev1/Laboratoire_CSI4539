/* catall_fixed_debug.c
 * Copie de catall_fixed.c, avec le MEME ordre d'operations, mais
 * instrumentee pour T8 : affiche les UID avant/apres l'abandon de
 * privilege et tente une re-elevation (seteuid(0)) pour prouver
 * qu'elle echoue. Continue ensuite normalement (dup2 + execve) pour
 * confirmer que la fonctionnalite (lire un fichier protege) reste
 * intacte malgre l'abandon de privilege.
 */
#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>

static void print_uids(const char *label)
{
    uid_t r, e, s;
    getresuid(&r, &e, &s);
    fprintf(stderr, "[T8] %s : real=%d effective=%d saved=%d\n", label, r, e, s);
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file>\n", argv[0]);
        return 1;
    }

    print_uids("AVANT abandon de privilege");

    /* --- Etape privilegiee (encore root ici) --- */
    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        perror("open failed");
        return 1;
    }

    /* --- E8 : abandon definitif et irreversible du privilege --- */
    if (setresuid(getuid(), getuid(), getuid()) != 0) {
        fprintf(stderr, "setresuid failed: %s\n", strerror(errno));
        close(fd);
        return 1;
    }

    print_uids("APRES abandon de privilege");

    /* --- Tentative de re-elevation -- DOIT echouer --- */
    errno = 0;
    if (seteuid(0) == 0) {
        fprintf(stderr, "!!! RE-ELEVATION REUSSIE -- ECHEC DE LA CORRECTION !!!\n");
        print_uids("APRES tentative de re-elevation");
        close(fd);
        return 1;
    } else {
        fprintf(stderr, "[T8] Tentative de re-elevation (seteuid(0)) : ECHEC comme prevu.\n");
        fprintf(stderr, "[T8]   errno=%d (%s)\n", errno, strerror(errno));
    }

    /* --- A partir d'ici, aucun privilege root : on continue comme
     * catall_fixed.c pour confirmer que la fonctionnalite reste intacte --- */
    if (dup2(fd, STDIN_FILENO) == -1) {
        perror("dup2 failed");
        close(fd);
        return 1;
    }
    close(fd);

    fprintf(stderr, "[T8] Contenu du fichier (via /bin/cat, sans argument) :\n");

    char *v[2];
    v[0] = "/bin/cat";
    v[1] = NULL;
    char *safe_env[] = { "PATH=/usr/bin:/bin", NULL };

    execve(v[0], v, safe_env);
    perror("execve failed");
    return 1;
}