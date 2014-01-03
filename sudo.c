/**
* sudo for Windows™
*
* This source code in origin is from superuser.
* see: http://superuser.com/questions/122418/theres-no-sudo-command-in-cygwin
*
* @filename sudo.c
*/

#pragma comment(lib, "user32.lib")
#pragma comment(lib, "shell32.lib")

#ifndef UNICODE
#define UNICODE
#endif
#include <windows.h>
#include <shellapi.h>
#include <wchar.h>


LPWSTR *mergestrings(LPWSTR *left, LPCWSTR right)
{
    size_t size = ( 1 + lstrlen(*left) + lstrlen(right) ) * sizeof(LPWSTR*);
    if ( *left ) {
        LPWSTR leftcopy = _wcsdup(*left);
        *left = (LPWSTR)realloc(*left, size);
        *left = lstrcpy(*left, leftcopy);
        *left = lstrcat(*left, right);
        free( leftcopy );
    }
    else
        *left = _wcsdup(right);
    return left;
}


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE prevInstance, LPSTR lpcommand, int nShowCmd)
{
    DWORD result = 0x2a;
    LPWSTR *argv = NULL;
    int argc = 0;
    if ( argv = CommandLineToArgvW(GetCommandLineW(), &argc) ) {
        if ( argc < 2 ) {
            LPWSTR usagemsg = NULL;
            usagemsg = *mergestrings(&usagemsg, argv[0]);
            usagemsg = *mergestrings(&usagemsg, TEXT(" <command_to_run> [arguments]"));
            MessageBox(NULL, usagemsg, TEXT("Usage:"), MB_OK | MB_ICONEXCLAMATION );
            LocalFree( argv );
            free( usagemsg );
            return ERROR_BAD_ARGUMENTS;
        }
        else {
            LPWSTR command = argv[1];
            LPWSTR arguments = NULL;
            int c;
            for ( c = 2; c < argc; c++ ) {
                arguments = *mergestrings(&arguments, argv[c]);
                arguments = *mergestrings(&arguments, TEXT(" "));
            }
            result = (DWORD)ShellExecute(NULL, TEXT("runas"), command, arguments, NULL, SW_SHOWNORMAL);
            LocalFree( argv );
            if ( arguments )
                free( arguments );
            switch ( result )
            {
                case 0:
                    result = ERROR_OUTOFMEMORY;
                    break;

                case 27:
                case 31:
                    result = ERROR_NO_ASSOCIATION;
                    break;

                case 28:
                case 29:
                case 30:
                    result = ERROR_DDE_FAIL;
                    break;
                case 32:
                    result = ERROR_DLL_NOT_FOUND;
                    break;
                default:
                    if ( result > 32 )
                        result = 0x2a;
            }
        }
    }
    else
        result = GetLastError();

    if (result != 0x2a) {
        LPWSTR errormsg = NULL;
        FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER,
                      NULL, result, 0, (LPWSTR)&errormsg, 0, NULL);
        MessageBox(NULL, errormsg, TEXT("Error:"), MB_OK | MB_ICONERROR);
        LocalFree( errormsg );
        return result;
    }
    else
        return NO_ERROR;
}
