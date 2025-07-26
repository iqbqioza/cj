#ifndef PLATFORM_H
#define PLATFORM_H

// Platform detection macros
#ifdef __linux__
    #define PLATFORM_LINUX 1
    #ifdef __x86_64__
        #define PLATFORM_LINUX_AMD64 1
    #elif __aarch64__
        #define PLATFORM_LINUX_ARM64 1
    #endif
#elif __APPLE__
    #include <TargetConditionals.h>
    #define PLATFORM_DARWIN 1
    #ifdef __x86_64__
        #define PLATFORM_DARWIN_AMD64 1
    #elif __arm64__
        #define PLATFORM_DARWIN_ARM64 1
    #endif
#elif defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
    #define PLATFORM_WINDOWS 1
    #if defined(_M_ARM64) || defined(__aarch64__)
        #define PLATFORM_WINDOWS_ARM64 1
    #elif defined(_WIN64) || defined(_M_X64) || defined(__x86_64__)
        #define PLATFORM_WINDOWS_AMD64 1
    #elif defined(_M_IX86) || defined(__i386__) || defined(_M_IX86)
        #define PLATFORM_WINDOWS_I386 1
    #elif defined(_M_ARM) || defined(__arm__)
        #define PLATFORM_WINDOWS_ARM 1
    #else
        #ifdef _WIN64
            #define PLATFORM_WINDOWS_AMD64 1  // Default 64-bit
        #else
            #define PLATFORM_WINDOWS_I386 1   // Default 32-bit
        #endif
    #endif
    
    // Windows-specific includes and definitions
    #ifndef WIN32_LEAN_AND_MEAN
        #define WIN32_LEAN_AND_MEAN
    #endif
    
    // Define MSVC compatibility macros for MinGW
    #ifdef __MINGW32__
        #ifndef _CRT_SECURE_NO_WARNINGS
            #define _CRT_SECURE_NO_WARNINGS
        #endif
    #endif
#endif

// Architecture detection
#if defined(__x86_64__) || defined(_M_X64)
    #define ARCH_AMD64 1
    #define ARCH_NAME "amd64"
#elif defined(__aarch64__) || defined(_M_ARM64) || defined(__arm64__)
    #define ARCH_ARM64 1
    #define ARCH_NAME "arm64"
#elif defined(__i386__) || defined(_M_IX86) || defined(__i486__) || defined(__i586__) || defined(__i686__)
    #define ARCH_I386 1
    #define ARCH_NAME "i386"
#elif defined(__arm__) || defined(_M_ARM)
    #define ARCH_ARM 1
    #define ARCH_NAME "arm"
#else
    #define ARCH_UNKNOWN 1
    #define ARCH_NAME "unknown"
#endif

// Platform name
#ifdef PLATFORM_LINUX
    #define PLATFORM_NAME "linux"
#elif PLATFORM_DARWIN
    #define PLATFORM_NAME "darwin"
#elif PLATFORM_WINDOWS
    #define PLATFORM_NAME "windows"
#else
    #define PLATFORM_NAME "unknown"
#endif

// Full platform string
#define PLATFORM_STRING PLATFORM_NAME "-" ARCH_NAME

// Platform-specific optimizations and compatibility
#ifdef PLATFORM_LINUX_AMD64
    // Linux x86_64 specific optimizations can go here
#endif

#ifdef PLATFORM_LINUX_ARM64
    // Linux ARM64 specific optimizations can go here
#endif

#ifdef PLATFORM_DARWIN_AMD64
    // macOS Intel specific optimizations can go here
#endif

#ifdef PLATFORM_DARWIN_ARM64
    // macOS Apple Silicon specific optimizations can go here
#endif

#ifdef PLATFORM_WINDOWS_ARM64
    // Windows ARM64 specific optimizations can go here
#endif

#ifdef PLATFORM_WINDOWS
    // Windows-specific compatibility
    #ifdef _MSC_VER
        // MSVC-specific definitions
        #define strdup _strdup
        #define snprintf _snprintf
        #pragma warning(disable: 4996) // Disable deprecated function warnings
        
        // Windows ARM64 specific MSVC settings
        #ifdef PLATFORM_WINDOWS_ARM64
            // ARM64-specific optimizations for MSVC
            #pragma optimize("t", on)  // Favor speed optimizations
        #endif
    #endif
    
    // MinGW ARM64 support
    #if defined(__MINGW64__) && defined(__aarch64__)
        // MinGW ARM64 specific settings
        #ifndef _ARM64_
            #define _ARM64_
        #endif
    #endif
    
    // Windows file path separator
    #define PATH_SEPARATOR "\\"
    #define PATH_SEPARATOR_CHAR '\\'
#else
    // Unix-like systems
    #define PATH_SEPARATOR "/"
    #define PATH_SEPARATOR_CHAR '/'
#endif

// Function to get platform information at runtime
const char* get_platform_info(void);

#endif // PLATFORM_H