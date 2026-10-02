#include <netinet/in.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>

int main(void)
{
    int socket_fd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    if (socket_fd < 0) {
        perror("socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)");
        return 1;
    }

    printf("Raw ICMP socket opened (uid=%ld, euid=%ld) with CAP_NET_RAW.\n",
           (long)getuid(), (long)geteuid());
    close(socket_fd);
    return 0;
}