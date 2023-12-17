#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>

void printInt(long long i) {
    printf("%lld\n", i);
}

void printString(const char* s) {
    printf("%s\n", s);
}

long long readInt() {
    long long i;
    scanf("%lld", &i);
    return i;
}

char* readString() {
    char* buffer = NULL;
    size_t bufferSize = 0;
    ssize_t bytesRead;

    bytesRead = getline(&buffer, &bufferSize, stdin);

    if (bytesRead == -1) {
        perror("Błąd podczas wczytywania napisu.");
        exit(1);
    }

    if (bytesRead > 0 && buffer[bytesRead - 1] == '\n') {
        buffer[bytesRead - 1] = '\0';
    }

    return buffer;
}

void error() {
    exit(1);
}