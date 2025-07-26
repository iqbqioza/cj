@echo off
REM Windows batch script for building cj CSV to JSON converter

setlocal enabledelayedexpansion

REM Configuration
set VERSION=1.0.0
set BUILD_DIR=build
set TARGET=cj.exe

REM Detect architecture
set ARCH=unknown
if defined PROCESSOR_ARCHITEW6432 (
    set ARCH=%PROCESSOR_ARCHITEW6432%
) else (
    set ARCH=%PROCESSOR_ARCHITECTURE%
)

if /i "%ARCH%"=="AMD64" set ARCH_NAME=amd64
if /i "%ARCH%"=="x86" set ARCH_NAME=i386
if /i "%ARCH%"=="ARM64" set ARCH_NAME=arm64
if /i "%ARCH%"=="ARM" set ARCH_NAME=arm

REM Colors (basic Windows console colors)
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo %BLUE%[INFO]%NC% cj Windows Build Script v%VERSION%
echo %BLUE%[INFO]%NC% Target Architecture: %ARCH_NAME%
echo.

REM Check for required tools
echo %BLUE%[INFO]%NC% Checking build dependencies...

where gcc >nul 2>&1
if %ERRORLEVEL% neq 0 (
    where cl >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        echo %RED%[ERROR]%NC% No C compiler found. Please install MinGW-w64 or Visual Studio Build Tools
        pause
        exit /b 1
    ) else (
        echo %GREEN%[SUCCESS]%NC% MSVC compiler found
        set COMPILER=cl
        set CFLAGS=/W3 /O2 /std:c11
        set LINKER_FLAGS=
    )
) else (
    echo %GREEN%[SUCCESS]%NC% GCC compiler found
    set COMPILER=gcc
    set CFLAGS=-Wall -Wextra -std=c99 -O2 -static
    set LINKER_FLAGS=
)

where make >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %YELLOW%[WARNING]%NC% Make not found, using direct compilation
    set USE_MAKE=0
) else (
    echo %GREEN%[SUCCESS]%NC% Make found
    set USE_MAKE=1
)

echo.

REM Create build directory
if not exist %BUILD_DIR% mkdir %BUILD_DIR%

REM Clean previous builds
echo %BLUE%[INFO]%NC% Cleaning previous builds...
if exist %TARGET% del %TARGET%
if exist src\*.obj del src\*.obj
if exist src\*.o del src\*.o

echo.

REM Build the project
echo %BLUE%[INFO]%NC% Building cj for Windows...

if %USE_MAKE%==1 (
    REM Use Makefile if available
    make
    if !ERRORLEVEL! neq 0 (
        echo %RED%[ERROR]%NC% Build failed using make
        pause
        exit /b 1
    )
) else (
    REM Direct compilation
    if "%COMPILER%"=="cl" (
        REM MSVC compilation
        if /i "%ARCH_NAME%"=="arm64" (
            REM ARM64 specific MSVC flags
            cl %CFLAGS% /D_ARM64_ /Fe:%TARGET% src\main.c src\utils.c src\csv_parser.c src\json_output.c src\platform.c %LINKER_FLAGS%
        ) else (
            cl %CFLAGS% /Fe:%TARGET% src\main.c src\utils.c src\csv_parser.c src\json_output.c src\platform.c %LINKER_FLAGS%
        )
    ) else (
        REM GCC compilation
        if /i "%ARCH_NAME%"=="arm64" (
            REM ARM64 specific GCC flags
            gcc %CFLAGS% -D_ARM64_ -o %TARGET% src\main.c src\utils.c src\csv_parser.c src\json_output.c src\platform.c %LINKER_FLAGS%
        ) else (
            gcc %CFLAGS% -o %TARGET% src\main.c src\utils.c src\csv_parser.c src\json_output.c src\platform.c %LINKER_FLAGS%
        )
    )
    
    if !ERRORLEVEL! neq 0 (
        echo %RED%[ERROR]%NC% Build failed
        pause
        exit /b 1
    )
)

if exist %TARGET% (
    echo %GREEN%[SUCCESS]%NC% Build completed: %TARGET%
    
    REM Show file information
    echo.
    echo %BLUE%[INFO]%NC% Binary information:
    dir %TARGET% | findstr %TARGET%
    
    REM Test the binary
    echo.
    echo %BLUE%[INFO]%NC% Testing binary...
    %TARGET% version
    
    if !ERRORLEVEL!==0 (
        echo %GREEN%[SUCCESS]%NC% Binary test passed
    ) else (
        echo %YELLOW%[WARNING]%NC% Binary test failed
    )
    
    REM Copy to build directory
    copy %TARGET% %BUILD_DIR%\%TARGET% >nul
    echo %GREEN%[SUCCESS]%NC% Binary copied to %BUILD_DIR%\%TARGET%
    
) else (
    echo %RED%[ERROR]%NC% Build failed - executable not created
    pause
    exit /b 1
)

echo.
echo %GREEN%[SUCCESS]%NC% Windows build process completed!
echo.
echo Usage:
echo   %TARGET% input.csv          - Convert CSV to JSON
echo   %TARGET% --styled input.csv - Convert CSV to formatted JSON
echo   %TARGET% version            - Show version information
echo.

pause