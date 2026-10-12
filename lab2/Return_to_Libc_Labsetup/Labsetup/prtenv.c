#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    char *p = getenv("MYSH");
    if (p == NULL) {
        printf("MYSH is not set\n");
        return 1;
    }
    printf("MYSH address: 0x%.8x\n", (unsigned int)p);
    return 0;
}
