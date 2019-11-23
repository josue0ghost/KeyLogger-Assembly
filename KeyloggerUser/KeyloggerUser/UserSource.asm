.386
;model
.model flat, stdcall				;flat es como small
option casemap:none
;includes
;include \masm32\include\windows.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc
;include \masm32\include\user32.inc
include ReadFile.inc
;librerias
;includelib \masm32\lib\kernel32.lib
;includelib \masm32\lib\masm32.lib
;includelib \masm32\lib\user32.lib

.data

	directorio byte "C:\Users\llaaj\OneDrive\Documentos\GitHub\P2MP\KeyLogger\KeyLogger\keylogger.txt",NULL
	cadena1 db "Buscar: ",0
	cadena2 db "No se encontraron mas coincidencias...",0
	cadena3 db "La cadena fue ingresada el: ",0
	cadena4 db "No existen mas fechas...",0
	espacio db 20h
.data?
	palabra db 100 dup(?)
	temp dd ?
	temp2 dd ?
	manejo dd ?
	FileSize dd ?
	hMem dd ?
	BytesRead dd ?
	contador dd ?
.code
program:
	call main

	main proc
		busqueda:
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

		invoke GlobalFree,hMem

		mov eax, 10
		push eax
		print esp
		pop eax
		jmp busqueda

		fin_programa:
		invoke ExitProcess,0
		ret
	main endp

	CompararString proc
	    XOR ESI, ESI
		XOR EDI, EDI
		XOR EBX, EBX
		XOR EAX, EAX
		
		MOV EDI, hMem
		LEA ESI, palabra

		MOVZX EAX, BYTE PTR [EDI]
		MOV temp2, EAX
		;print uhex$(eax),13,10
		MOVZX EBX, BYTE PTR [ESI]
		;print uhex$(ebx),13,10
		MOV temp, EBX
		CMP EBX, temp2
		JE Iguales
		JNE Siguiente
		;------------------------------------IGUALES
		Iguales:
		XOR EBX, EBX
		INC ESI
		;ADD ESI, 4
		
		MOVZX EBX, BYTE PTR [ESI]
		;print uhex$(ebx),13,10
		MOV temp, EBX

		MOV EBX, temp
		CMP EBX, 0
		JE VerifyPalabraCompleta
		JNE SigueBuscando

		VerifyPalabraCompleta:
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]
		CMP EAX, 20h		;si hay un espacio
		JE EscribirFH
		CMP EAX, 13d		;O un salto de linea
		JE EscribirFH
		JNE Reiniciar	;De lo contrario, no encontro una palabra completa

		;Sigue buscando
		SigueBuscando:
		XOR EAX, EAX
		INC EDI
		;ADD EDI, 4
		MOVZX EAX, BYTE PTR [EDI]
		MOV temp2, EAX
		;print uhex$(eax),13,10

		XOR EAX, EAX
		MOV EAX, temp2

		;CMP EAX, 13
		;je EscribirFH
		CMP temp, EAX
		JE Iguales
		JNE Reiniciar

		;----------------------------------SIGUIENTE
		Siguiente:
		INC EDI
		;ADD EDI, 4
		MOVZX EAX, BYTE PTR [EDI]
		;print uhex$(eax),13,10
		CMP EAX, 0				;Si es NULL, fin de hMem
		JE FinBuf

		CMP EAX, temp
		JE Iguales
		JNE Siguiente

		Reiniciar:
		XOR ESI, ESI
		LEA ESI, palabra
		MOVZX EBX, BYTE PTR [ESI]
		;print uhex$(ebx),13,10
		MOV temp, EBX
		JMP Siguiente

		FinCadena:
		INC EDI
		;ADD EDI, 4

		MOVZX EAX, BYTE PTR [EDI]
		;;print uhex$(eax),13,10
		CMP EAX, 13
		JE EscribirFH
		JNE FinCadena

		FinBuf:
		invoke StdOut, addr cadena2
		JMP Fin

		EscribirFH:
		DEC EDI
		invoke StdOut, addr cadena3
		INC EDI						;la fecha esta a 2 caracteres
		MOVZX EAX, BYTE PTR [EDI]
		INC EDI						;de distancia
		MOVZX EAX, BYTE PTR [EDI]
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]
		CMP EAX, 0					;ver si no es el fin del programa
		JE NoFecha

		MOV ECX, 19d
		MOV contador, ECX
		DEC EDI
		FechaSiguiente:
			INC EDI
			MOVZX EAX, BYTE PTR [EDI]
			push eax
			print esp
			pop eax
		DEC contador
		jz endloop
		jmp FechaSiguiente

		endloop:
		MOV EAX, 10d
		push eax
		print esp
		pop eax
		jmp Reiniciar				;en busqueda de mas coincidencias

		NoFecha:
		invoke StdOut, addr cadena4	;no existen mas fechas

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