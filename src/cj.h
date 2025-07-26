#ifndef CJ_H
#define CJ_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "platform.h"

#define VERSION "1.0.0"
#define INITIAL_CAPACITY 16
#define INITIAL_LINE_SIZE 256

typedef struct {
    char** headers;
    char*** data;
    int num_headers;
    int num_rows;
    int headers_capacity;
    int rows_capacity;
    int* field_capacities;
} CSVData;

// Utility functions
void print_usage(void);
void print_version(void);
int is_numeric(const char* str);

// CSV parsing functions
char* read_csv_line(FILE* file);
char** parse_csv_line(char* line, int* field_count);
CSVData* read_csv(const char* filename);
void free_csv(CSVData* csv);

// JSON output functions
void print_json_value(const char* value);
void print_json(CSVData* csv, int styled);

#endif // CJ_H