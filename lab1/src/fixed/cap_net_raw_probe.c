#include <errno.h>
#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

int main(void)
{
    int socket_fd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);

    if (socket_fd < 0) {
        perror("socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)");
        return errno == EPERM ? 1 : 2;
    }

    puts("Raw ICMP socket opened with the process capability.");
    close(socket_fd);
    return 0;
}