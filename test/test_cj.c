#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_RESET   "\x1b[0m"

typedef struct {
    int total;
    int passed;
    int failed;
} TestResults;

static TestResults results = {0, 0, 0};

void test_assert(int condition, const char* test_name) {
    results.total++;
    if (condition) {
        printf(ANSI_COLOR_GREEN "✓ PASS" ANSI_COLOR_RESET " %s\n", test_name);
        results.passed++;
    } else {
        printf(ANSI_COLOR_RED "✗ FAIL" ANSI_COLOR_RESET " %s\n", test_name);
        results.failed++;
    }
}

char* run_command(const char* command) {
    FILE* fp = popen(command, "r");
    if (!fp) return NULL;
    
    size_t capacity = 1024;
    char* output = malloc(capacity);
    size_t length = 0;
    int c;
    
    while ((c = fgetc(fp)) != EOF) {
        if (length >= capacity - 1) {
            capacity *= 2;
            char* new_output = realloc(output, capacity);
            if (!new_output) {
                free(output);
                pclose(fp);
                return NULL;
            }
            output = new_output;
        }
        output[length++] = c;
    }
    
    output[length] = '\0';
    pclose(fp);
    return output;
}

int compare_json_output(const char* actual, const char* expected) {
    char* a = strdup(actual);
    char* e = strdup(expected);
    
    char* p;
    for (p = a; *p; p++) {
        if (*p == ' ' || *p == '\n' || *p == '\t') {
            memmove(p, p + 1, strlen(p));
            p--;
        }
    }
    
    for (p = e; *p; p++) {
        if (*p == ' ' || *p == '\n' || *p == '\t') {
            memmove(p, p + 1, strlen(p));
            p--;
        }
    }
    
    int result = strcmp(a, e) == 0;
    free(a);
    free(e);
    return result;
}

void test_basic_conversion() {
    printf(ANSI_COLOR_BLUE "\n=== Basic CSV Conversion Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj basic.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"no\": 1") != NULL, "Basic CSV field parsing");
        test_assert(strstr(output, "\"name\": \"Joe\"") != NULL, "String field parsing");
        test_assert(strstr(output, "\"memo\": \"\"") != NULL, "Empty field parsing");
        test_assert(output[0] == '[' && output[strlen(output)-2] == ']', "JSON array format");
        free(output);
    } else {
        test_assert(0, "Basic CSV to JSON conversion");
    }
}

void test_styled_output() {
    printf(ANSI_COLOR_BLUE "\n=== Styled Output Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj --styled basic.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "[\n  {\n") != NULL, "Styled output format");
        test_assert(strstr(output, "    \"no\": 1") != NULL, "Styled output indentation");
        free(output);
    } else {
        test_assert(0, "Styled output test");
    }
    
    output = run_command("../cj -s basic.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "[\n  {\n") != NULL, "Short option -s works");
        free(output);
    } else {
        test_assert(0, "Short option -s test");
    }
}

void test_quoted_fields() {
    printf(ANSI_COLOR_BLUE "\n=== Quoted Fields Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj quoted.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"name\": \"John Doe\"") != NULL, "Double quoted fields");
        test_assert(strstr(output, "\"description\": \"A, B, C\"") != NULL, "Quoted fields with commas");
        test_assert(strstr(output, "\"quote\": \"He said \\\"Hello\\\"\"") != NULL, "Escaped quotes in fields");
        free(output);
    } else {
        test_assert(0, "Quoted fields test");
    }
}

void test_numeric_detection() {
    printf(ANSI_COLOR_BLUE "\n=== Numeric Type Detection Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj numeric.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"integer\": 42") != NULL, "Integer detection");
        test_assert(strstr(output, "\"float\": 3.14") != NULL, "Float detection");
        test_assert(strstr(output, "\"negative\": -10") != NULL, "Negative number detection");
        test_assert(strstr(output, "\"text\": \"abc123\"") != NULL, "Text remains quoted");
        free(output);
    } else {
        test_assert(0, "Numeric detection test");
    }
}

void test_large_file() {
    printf(ANSI_COLOR_BLUE "\n=== Large File Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj large.csv 2>/dev/null | wc -c");
    if (output) {
        int size = atoi(output);
        test_assert(size > 1000, "Large file processing");
        free(output);
    } else {
        test_assert(0, "Large file test");
    }
}

void test_empty_fields() {
    printf(ANSI_COLOR_BLUE "\n=== Empty Fields Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj empty.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"empty1\": \"\"") != NULL, "Empty field handling");
        test_assert(strstr(output, "\"empty2\": \"\"") != NULL, "Multiple empty fields");
        free(output);
    } else {
        test_assert(0, "Empty fields test");
    }
}

void test_version_command() {
    printf(ANSI_COLOR_BLUE "\n=== Command Line Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj version 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "1.0.0") != NULL, "Version command");
        free(output);
    } else {
        test_assert(0, "Version command test");
    }
}

void test_usage_output() {
    char* output = run_command("../cj 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "Usage:") != NULL, "Usage output");
        test_assert(strstr(output, "cj [filename]") != NULL, "Usage format");
        free(output);
    } else {
        test_assert(0, "Usage output test");
    }
}

void test_error_handling() {
    printf(ANSI_COLOR_BLUE "\n=== Error Handling Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj nonexistent.csv 2>&1");
    if (output) {
        test_assert(strstr(output, "Error: Cannot open file") != NULL, "File not found error");
        free(output);
    } else {
        test_assert(0, "Error handling test");
    }
}

void test_special_characters() {
    printf(ANSI_COLOR_BLUE "\n=== Special Characters Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj special.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"id\": 1") != NULL, "Basic field parsing with special chars");
        test_assert(strstr(output, "\\\"") != NULL, "Quote escape");
        test_assert(strlen(output) > 100, "Output contains data");
        free(output);
    } else {
        test_assert(0, "Special characters test");
    }
}

void test_multiline_fields() {
    printf(ANSI_COLOR_BLUE "\n=== Multiline Fields Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj multiline.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"id\": 1") != NULL, "Multiline CSV basic parsing");
        test_assert(strstr(output, "\\n") != NULL, "Newline escaping in JSON");
        test_assert(strstr(output, "\"John Doe\"") != NULL, "Name field parsing");
        test_assert(strstr(output, "multiline") != NULL, "Multiline content preserved");
        free(output);
    } else {
        test_assert(0, "Multiline fields test");
    }
}

void test_complex_newlines() {
    printf(ANSI_COLOR_BLUE "\n=== Complex Newlines Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj complex_newlines.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"type\": \"unix\"") != NULL, "Unix newline type");
        test_assert(strstr(output, "\"type\": \"windows\"") != NULL, "Windows newline type");
        test_assert(strstr(output, "\"type\": \"mixed\"") != NULL, "Mixed newline type");
        test_assert(strstr(output, "\\n") != NULL, "Newlines properly escaped");
        test_assert(strstr(output, "\\t") != NULL, "Tabs properly escaped");
        free(output);
    } else {
        test_assert(0, "Complex newlines test");
    }
}

void test_edge_cases() {
    printf(ANSI_COLOR_BLUE "\n=== Edge Cases Tests ===" ANSI_COLOR_RESET "\n");
    
    char* output = run_command("../cj edge_cases.csv 2>/dev/null");
    if (output) {
        test_assert(strstr(output, "\"id\": 1") != NULL, "Edge case basic parsing");
        test_assert(strstr(output, "\"empty_multiline\": \"\"") != NULL, "Empty multiline field");
        test_assert(strstr(output, "\"only_newlines\"") != NULL, "Field with only newlines");
        test_assert(output[0] == '[', "Valid JSON array start");
        free(output);
    } else {
        test_assert(0, "Edge cases test");
    }
}

void print_summary() {
    printf(ANSI_COLOR_BLUE "\n=== Test Summary ===" ANSI_COLOR_RESET "\n");
    printf("Total tests: %d\n", results.total);
    printf(ANSI_COLOR_GREEN "Passed: %d" ANSI_COLOR_RESET "\n", results.passed);
    if (results.failed > 0) {
        printf(ANSI_COLOR_RED "Failed: %d" ANSI_COLOR_RESET "\n", results.failed);
    }
    
    if (results.failed == 0) {
        printf(ANSI_COLOR_GREEN "\n🎉 All tests passed!" ANSI_COLOR_RESET "\n");
    } else {
        printf(ANSI_COLOR_RED "\n❌ Some tests failed!" ANSI_COLOR_RESET "\n");
    }
}

int main() {
    printf(ANSI_COLOR_YELLOW "Running CJ CSV to JSON Converter Tests" ANSI_COLOR_RESET "\n");
    
    test_basic_conversion();
    test_styled_output();
    test_quoted_fields();
    test_numeric_detection();
    test_large_file();
    test_empty_fields();
    test_version_command();
    test_usage_output();
    test_error_handling();
    test_special_characters();
    test_multiline_fields();
    test_complex_newlines();
    test_edge_cases();
    
    print_summary();
    
    return results.failed > 0 ? 1 : 0;
}