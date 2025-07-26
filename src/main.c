#include "cj.h"

int main(int argc, char* argv[]) {
    if (argc == 1) {
        print_usage();
        return 0;
    }
    
    if (argc == 2) {
        if (strcmp(argv[1], "version") == 0) {
            print_version();
            return 0;
        }
        
        CSVData* csv = read_csv(argv[1]);
        if (!csv) return 1;
        
        print_json(csv, 0);
        printf("\n");
        free_csv(csv);
        return 0;
    }
    
    if (argc == 3) {
        if (strcmp(argv[1], "--styled") == 0 || strcmp(argv[1], "-s") == 0) {
            CSVData* csv = read_csv(argv[2]);
            if (!csv) return 1;
            
            print_json(csv, 1);
            free_csv(csv);
            return 0;
        }
    }
    
    print_usage();
    return 1;
}