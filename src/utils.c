#include "cj.h"

void print_usage() {
    printf("Usage:\n");
    printf("  cj [filename]           Convert CSV to JSON\n");
    printf("  cj version              Show version\n");
    printf("  cj --styled|-s [file]   Convert CSV to formatted JSON\n");
    printf("  cj                      Show this help\n");
}

void print_version() {
    printf("cj version %s\n", VERSION);
    printf("Built for: %s\n", get_platform_info());
    printf("Repository: https://github.com/iqbqioza/cj\n");
    printf("License: MIT\n");
    printf("Copyright (c) 2025 Takuya Okada(@iqbqioza) and cj contributors\n");
}

int is_numeric(const char* str) {
    if (*str == '\0') return 0;
    if (*str == '-' || *str == '+') str++;
    int has_dot = 0;
    while (*str) {
        if (*str == '.') {
            if (has_dot) return 0;
            has_dot = 1;
        } else if (!isdigit(*str)) {
            return 0;
        }
        str++;
    }
    return 1;
}