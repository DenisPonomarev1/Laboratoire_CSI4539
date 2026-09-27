#define _GNU_SOURCE
#include <fcntl.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main(void)
{
    uid_t real_uid;
    uid_t effective_uid;
    uid_t saved_uid;
    const char *marker = "/tmp/lab1_t5_path.marker";
    int marker_fd;

    if (getresuid(&real_uid, &effective_uid, &saved_uid) != 0) {
        perror("getresuid");
        return 1;
    }
    printf("PATH substitute getresuid: real_uid=%u effective_uid=%u saved_uid=%u\n",
           (unsigned int)real_uid, (unsigned int)effective_uid,
           (unsigned int)saved_uid);

    marker_fd = open(marker, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (marker_fd < 0) {
        perror("open marker");
        return 1;
    }
    if (dprintf(marker_fd, "real_uid=%u effective_uid=%u saved_uid=%u\n",
                (unsigned int)real_uid, (unsigned int)effective_uid,
                (unsigned int)saved_uid) < 0) {
        perror("write marker");
        close(marker_fd);
        return 1;
    }
    close(marker_fd);
    return 0;
}