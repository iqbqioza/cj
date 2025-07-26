#include "cj.h"

char* read_csv_line(FILE* file) {
    size_t capacity = INITIAL_LINE_SIZE;
    char* line = malloc(capacity);
    if (!line) return NULL;
    
    size_t length = 0;
    int c;
    int in_quotes = 0;
    char quote_char = 0;
    
    while ((c = fgetc(file)) != EOF) {
        if (length >= capacity - 1) {
            capacity *= 2;
            char* new_line = realloc(line, capacity);
            if (!new_line) {
                free(line);
                return NULL;
            }
            line = new_line;
        }
        
        if (!in_quotes && (c == '"' || c == '\'')) {
            in_quotes = 1;
            quote_char = c;
            line[length++] = c;
        } else if (in_quotes && c == quote_char) {
            int next_c = fgetc(file);
            if (next_c == quote_char) {
                line[length++] = c;
                line[length++] = next_c;
            } else {
                line[length++] = c;
                in_quotes = 0;
                if (next_c != EOF) {
                    ungetc(next_c, file);
                }
            }
        } else if (!in_quotes && (c == '\n' || c == '\r')) {
            if (c == '\r') {
                int next_c = fgetc(file);
                if (next_c != '\n' && next_c != EOF) {
                    ungetc(next_c, file);
                }
            }
            break;
        } else {
            line[length++] = c;
        }
    }
    
    if (length == 0 && c == EOF) {
        free(line);
        return NULL;
    }
    
    line[length] = '\0';
    return line;
}

char** parse_csv_line(char* line, int* field_count) {
    size_t capacity = INITIAL_CAPACITY;
    char** fields = malloc(capacity * sizeof(char*));
    if (!fields) return NULL;
    
    *field_count = 0;
    char* ptr = line;
    
    while (*ptr) {
        if ((size_t)*field_count >= capacity) {
            capacity *= 2;
            char** new_fields = realloc(fields, capacity * sizeof(char*));
            if (!new_fields) {
                for (int i = 0; i < *field_count; i++) {
                    free(fields[i]);
                }
                free(fields);
                return NULL;
            }
            fields = new_fields;
        }
        
        while (*ptr == ' ' || *ptr == '\t') ptr++;
        
        size_t field_capacity = INITIAL_LINE_SIZE;
        char* field = malloc(field_capacity);
        if (!field) {
            for (int i = 0; i < *field_count; i++) {
                free(fields[i]);
            }
            free(fields);
            return NULL;
        }
        
        size_t field_length = 0;
        int in_quotes = 0;
        char quote_char = 0;
        
        if (*ptr == '"' || *ptr == '\'') {
            quote_char = *ptr;
            in_quotes = 1;
            ptr++;
        }
        
        while (*ptr && (in_quotes || *ptr != ',')) {
            if (in_quotes && *ptr == quote_char) {
                if (*(ptr + 1) == quote_char) {
                    if (field_length >= field_capacity - 1) {
                        field_capacity *= 2;
                        char* new_field = realloc(field, field_capacity);
                        if (!new_field) {
                            free(field);
                            for (int i = 0; i < *field_count; i++) {
                                free(fields[i]);
                            }
                            free(fields);
                            return NULL;
                        }
                        field = new_field;
                    }
                    field[field_length++] = *ptr;
                    ptr += 2;
                } else {
                    in_quotes = 0;
                    ptr++;
                    continue;
                }
            } else {
                if (field_length >= field_capacity - 1) {
                    field_capacity *= 2;
                    char* new_field = realloc(field, field_capacity);
                    if (!new_field) {
                        free(field);
                        for (int i = 0; i < *field_count; i++) {
                            free(fields[i]);
                        }
                        free(fields);
                        return NULL;
                    }
                    field = new_field;
                }
                
                field[field_length++] = *ptr;
                ptr++;
            }
        }
        
        field[field_length] = '\0';
        
        char* trimmed_field = field;
        while (*trimmed_field == ' ' || *trimmed_field == '\t') trimmed_field++;
        char* end = trimmed_field + strlen(trimmed_field) - 1;
        while (end >= trimmed_field && (*end == ' ' || *end == '\t')) {
            *end = '\0';
            end--;
        }
        
        fields[*field_count] = malloc(strlen(trimmed_field) + 1);
        if (!fields[*field_count]) {
            free(field);
            for (int i = 0; i < *field_count; i++) {
                free(fields[i]);
            }
            free(fields);
            return NULL;
        }
        strcpy(fields[*field_count], trimmed_field);
        free(field);
        
        (*field_count)++;
        
        if (*ptr == ',') ptr++;
    }
    
    return fields;
}

CSVData* read_csv(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s'\n", filename);
        return NULL;
    }
    
    CSVData* csv = malloc(sizeof(CSVData));
    if (!csv) {
        fclose(file);
        return NULL;
    }
    
    csv->headers = NULL;
    csv->data = NULL;
    csv->num_headers = 0;
    csv->num_rows = 0;
    csv->headers_capacity = 0;
    csv->rows_capacity = INITIAL_CAPACITY;
    csv->field_capacities = NULL;
    
    char* line = read_csv_line(file);
    if (line) {
        csv->headers = parse_csv_line(line, &csv->num_headers);
        csv->headers_capacity = csv->num_headers;
        free(line);
        
        if (!csv->headers) {
            free(csv);
            fclose(file);
            return NULL;
        }
    }
    
    csv->data = malloc(csv->rows_capacity * sizeof(char**));
    csv->field_capacities = malloc(csv->rows_capacity * sizeof(int));
    if (!csv->data || !csv->field_capacities) {
        if (csv->headers) {
            for (int i = 0; i < csv->num_headers; i++) {
                free(csv->headers[i]);
            }
            free(csv->headers);
        }
        free(csv->data);
        free(csv->field_capacities);
        free(csv);
        fclose(file);
        return NULL;
    }
    
    while ((line = read_csv_line(file)) != NULL) {
        if (strlen(line) == 0) {
            free(line);
            continue;
        }
        
        if (csv->num_rows >= csv->rows_capacity) {
            csv->rows_capacity *= 2;
            char*** new_data = realloc(csv->data, csv->rows_capacity * sizeof(char**));
            int* new_capacities = realloc(csv->field_capacities, csv->rows_capacity * sizeof(int));
            if (!new_data || !new_capacities) {
                free(line);
                break;
            }
            csv->data = new_data;
            csv->field_capacities = new_capacities;
        }
        
        int field_count;
        csv->data[csv->num_rows] = parse_csv_line(line, &field_count);
        csv->field_capacities[csv->num_rows] = field_count;
        
        if (!csv->data[csv->num_rows]) {
            free(line);
            break;
        }
        
        csv->num_rows++;
        free(line);
    }
    
    fclose(file);
    return csv;
}

void free_csv(CSVData* csv) {
    if (!csv) return;
    
    if (csv->headers) {
        for (int i = 0; i < csv->num_headers; i++) {
            free(csv->headers[i]);
        }
        free(csv->headers);
    }
    
    if (csv->data) {
        for (int i = 0; i < csv->num_rows; i++) {
            if (csv->data[i]) {
                for (int j = 0; j < csv->field_capacities[i]; j++) {
                    free(csv->data[i][j]);
                }
                free(csv->data[i]);
            }
        }
        free(csv->data);
    }
    
    free(csv->field_capacities);
    free(csv);
}