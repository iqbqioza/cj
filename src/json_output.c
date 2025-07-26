#include "cj.h"

void print_json_value(const char* value) {
    if (strlen(value) == 0) {
        printf("\"\"");
    } else if (is_numeric(value)) {
        printf("%s", value);
    } else {
        printf("\"");
        for (const char* p = value; *p; p++) {
            if (*p == '"') {
                printf("\\\"");
            } else if (*p == '\\') {
                printf("\\\\");
            } else if (*p == '\n') {
                printf("\\n");
            } else if (*p == '\r') {
                printf("\\r");
            } else if (*p == '\t') {
                printf("\\t");
            } else {
                printf("%c", *p);
            }
        }
        printf("\"");
    }
}

void print_json(CSVData* csv, int styled) {
    printf("[");
    if (styled) printf("\n");
    
    for (int i = 0; i < csv->num_rows; i++) {
        if (styled) printf("  ");
        printf("{");
        if (styled) printf("\n");
        
        int max_fields = csv->field_capacities[i] < csv->num_headers ? 
                        csv->field_capacities[i] : csv->num_headers;
        
        for (int j = 0; j < csv->num_headers; j++) {
            if (styled) printf("    ");
            printf("\"%s\": ", csv->headers[j]);
            
            if (j < max_fields) {
                print_json_value(csv->data[i][j]);
            } else {
                printf("\"\"");
            }
            
            if (j < csv->num_headers - 1) {
                printf(",");
            }
            if (styled) printf("\n");
        }
        
        if (styled) printf("  ");
        printf("}");
        
        if (i < csv->num_rows - 1) {
            printf(",");
        }
        if (styled) printf("\n");
    }
    
    printf("]");
    if (styled) printf("\n");
}