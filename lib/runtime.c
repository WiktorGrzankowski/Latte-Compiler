#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
    int c;
    while ((c = getchar()) != '\n' && c != EOF);
    return i;
}

char* readString() {
    char* buffer = NULL;
    size_t bufferSize = 0;
    ssize_t bytesRead;

    bytesRead = getline(&buffer, &bufferSize, stdin);

    if (bytesRead == -1) {
        perror("Error in reading input string.");
        exit(1);
    }

    if (bytesRead > 0 && buffer[bytesRead - 1] == '\n') {
        buffer[bytesRead - 1] = '\0';
    }

    return buffer;
}

char* concat(const char* s1, const char* s2) {
    const int len1 = strlen(s1);
    const int len = len1 + strlen(s2) + 1;
    char* res = malloc(len);
    strcpy(res, s1);
    strcpy(res + len1, s2);
    return res;
}

void* allocateArray(size_t numElements, size_t elementSize) {
    void* ptr = calloc(numElements, elementSize);

    if (ptr == NULL) {
        perror("Memory allocation failed.");
        exit(1);
    }

    return ptr;
}

void error() {
    exit(1);
}