.386
;model
.model flat, stdcall				;flat es como small
option casemap:none
;includes
;include \masm32\include\windows.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\masm32.inc
;include \masm32\include\masm32rt.inc
;include \masm32\include\user32.inc
include ReadFile.inc
;librerias
;includelib \masm32\lib\kernel32.lib
;includelib \masm32\lib\masm32.lib
;includelib \masm32\lib\user32.lib

.data

	directorio byte "C:\Users\llaaj\OneDrive\Documentos\GitHub\P2MP\KeyLogger\KeyLogger\keylogger.txt",NULL
	cadena1 db "Buscar: ",0
	cadena2 db "No se ha encontrado la cadena",0
	cadena3 db "La cadena fue ingresada el"
.data?
	palabra db 100 dup(?)
	temp dd ?
	temp2 dd ?
	manejo dd ?
	FileSize dd ?
	hMem dd ?
	BytesRead dd ?
.code
program:
	call main

	main proc
		invoke StdOut, addr cadena1
		invoke StdIn,addr palabra,100

		mov edx, offset directorio
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_HIDDEN,NULL
		mov manejo, eax
		cmp eax, INVALID_HANDLE_VALUE	;Error de creacion del archivo
		je fin_programa

		invoke GetFileSize,eax,0
		mov FileSize, eax
		inc eax

		invoke GlobalAlloc,GMEM_FIXED,eax
		mov hMem, eax

		add eax, FileSize
		mov BYTE PTR [eax],0   ; Set the last byte to NULL so that StdOut
                               ; can safely display the text in memory.

		invoke ReadFile,manejo,hMem,FileSize,ADDR BytesRead,0
		invoke CloseHandle,manejo

		call CompararString

		invoke StdOut,hMem
		invoke GlobalFree,hMem

		fin_programa:
		invoke ExitProcess,0
		ret
	main endp

	CompararString proc
	    XOR ESI, ESI
		XOR EDI, EDI
		XOR EBX, EBX
		XOR EAX, EAX

		LEA EDI, hMem
		LEA ESI, palabra

		MOV EAX, [EDI]
		MOV EBX, [ESI]
		MOV temp, EBX
		CMP EAX, temp
		JE Iguales
		JNE Siguiente

		Iguales:
		XOR EBX, EBX
		INC ESI
		MOV EBX, [ESI]
		MOV temp, EBX
		invoke StdOut, "%c\n"
		invoke StdOut, ebx
		invoke StdOut, ebx
		;print str$(ebx)
		;print str$(ebx)
		;printf("%c\n",ebx,ebx)
		MOV EBX, temp
		CMP EBX, 13
		JE FinCadena
		XOR EAX, EAX
		INC EDI
		MOV EAX, [EDI]
		MOV temp2, EAX
		invoke StdOut, "%c\n"
		invoke StdOut, eax
		invoke StdOut, eax
		;print str$(eax)
		;print str$(eax)
		;printf("%c\n",eax,eax)
		XOR EAX, EAX
		MOV EAX, temp2
		CMP temp, EAX
		JE Iguales
		JNE Reiniciar

		Siguiente:
		INC EDI
		MOV EAX, [EDI]
		CMP EAX, 0
		JE FinBuf
		CMP EAX, temp
		JE Iguales
		JNE Siguiente

		Reiniciar:
		XOR ESI, ESI
		LEA ESI, palabra
		MOV EBX, [ESI]
		MOV temp, EBX
		JMP Siguiente

		FinCadena:
		INC EDI
		MOV EAX, [EDI]
		CMP EAX, 13
		JE EscribirFH
		JNE FinCadena

		FinBuf:
		invoke StdOut, addr cadena2
		JMP Fin

		EscribirFH:
		;MOV vueltas, 50
		;imprimirArreglo3 palabra, vueltas
		invoke StdOut, addr cadena3
		
		INC EDI
		;escribirFechaBusqueda
		JMP Fin

		Fin:
		ret
	CompararString endp

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