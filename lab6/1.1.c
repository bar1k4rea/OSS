#include <stdio.h>
#include <string.h>

extern char **environ;

int main(int argc, char *argv[]) {
    int cnt = 0;
    char **ptr = environ;
    while (*ptr++)
        cnt++;
    printf("Number of evironment variables: %d\n", cnt);

    return 0;
}
