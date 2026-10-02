/* show_ids.c
 * Petit utilitaire pour E4 : affiche UID reel, effectif et sauvegarde
 * via getresuid(). Une fois compile et installe comme binaire Set-UID
 * root (meme traitement que catall), il demontre le meme comportement
 * du noyau que catall lors de son execution : l'UID effectif devient
 * celui du proprietaire du fichier (root), independamment de qui lance
 * le programme.
 *
 * Ce fichier ne modifie pas catall.c ; il sert uniquement a observer
 * le mecanisme de privilege de maniere isolee.
 */
#define _GNU_SOURCE
#define _DEFAULT_SOURCE
#include <unistd.h>
#include <stdio.h>

int main(void)
{
    uid_t ruid, euid, suid;

    if (getresuid(&ruid, &euid, &suid) != 0) {
        perror("getresuid");
        return 1;
    }

    printf("UID reel       (ruid) = %d\n", ruid);
    printf("UID effectif   (euid) = %d\n", euid);
    printf("UID sauvegarde (suid) = %d\n", suid);

    return 0;
}