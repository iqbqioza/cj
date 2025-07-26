#include "platform.h"
#include <stdio.h>

const char* get_platform_info(void) {
    static char platform_info[128];
    
    snprintf(platform_info, sizeof(platform_info), 
             "Platform: %s, Architecture: %s, Target: %s",
             PLATFORM_NAME, ARCH_NAME, PLATFORM_STRING);
    
    return platform_info;
}