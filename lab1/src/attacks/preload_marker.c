#define _GNU_SOURCE
#include <fcntl.h>
#include <unistd.h>

__attribute__((constructor)) static void record_preload(void)
{
    const char *marker = "/tmp/lab1_t6_preload.marker";
    int marker_fd = open(marker, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    if (marker_fd >= 0) {
        static const char message[] = "LD_PRELOAD library loaded\n";

        if (write(marker_fd, message, sizeof(message) - 1) < 0) {
            close(marker_fd);
            return;
        }
        close(marker_fd);
    }
}