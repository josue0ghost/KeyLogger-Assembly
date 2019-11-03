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
directorio db "c:\tasm\bin\keylogger.txt",0
error1 db "No se pudo crear el archivo",0

fecha db "	Fecha: ",0
hora db "	Hora: ",0
slash db "/",0
puntos db ":",0
.data?
manejo db ?
berror1 db 1 dup(?)
key db ?
;code segment
.code
program:
	call main

	main proc
		;call crear

		cmp berror1, 01h				;hubo un error al crear el archivo
		jz fin_programa

		keylogger:

		invoke StdIn, addr key, 1
		mov ah, 01h						;lee entrada del teclado
		;int 21h

		mov al, key						;moviendo la entrada a la variable "key"
	
		cmp al, 20h						;si es un espacio
		jz ObtenerFH
		cmp al, 0ah						;si es un ENTER
		jz ObtenerFH
		jmp seguir						;de lo contrario, sigue leyendo teclado

		ObtenerFH:
		call hora_fecha

		seguir:
		invoke StdOut, addr key
		jmp keylogger


		fin_programa:
		invoke ExitProcess,0
	main endp

	;crear proc
		;invoke CreateFile, addr directorio, GENERIC_READ OR GENERIC_WRITE, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		;mov manejo,eax
		;cmp manejo, INVALID_HANDLE_VALUE
		;jz nocrea
		;invoke ExitProcess,0
;
		;nocrea:
		;invoke MessageBox,NULL,addr error1,addr error1,MB_OK
		;invoke ExitProcess,0
		;ret
	;crear endp

	hora_fecha proc
		local systime:SYSTEMTIME

		invoke GetLocalTime, addr systime
	
		invoke StdOut, addr fecha
		mov ax, systime.wDay
		print str$(ax)
		invoke StdOut, addr slash
		mov ax, systime.wMonth
		print str$(ax)
		invoke StdOut, addr slash
		mov ax, systime.wYear
		print str$(ax)
		

		invoke StdOut, addr hora
		mov ax, systime.wHour
		print str$(ax)
		invoke StdOut, addr puntos
		mov ax, systime.wMinute
		print str$(ax)
		invoke StdOut, addr puntos
		mov ax, systime.wSecond
		print str$(ax)

		ret
	hora_fecha endp
end program

