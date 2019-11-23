.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc
include ReadFile.inc

.data
	directorio byte "C:\Users\Public\keylogger.txt",NULL
	cadena1 db "Buscar: ",0
	cadena2 db "No se encontraron mas coincidencias...",0
	cadena3 db "La cadena fue ingresada el: ",0
	cadena4 db "No existen mas fechas...",0
	menu1 db "1. Buscar",0
	menu2 db "2. Ver archivo",0
.data?
	palabra db 100 dup(?)	;palabra ingresada para busqueda
	temp dd ?				;temporales para el mapeo de la palabra
	temp2 dd ?				;ingresada y el buffer del archivo
	manejo dd ?				;handler del archivo
	FileSize dd ?			;tamanio del archivo
	fileBuffer dd ?				;texto del archivo
	BytesRead dd ?			;bytes leidos
	contador dd ?			;contador para impresion de hora y fecha
	menuin db ?				;entrada del menu
.code
program:
	call main

	main proc
		menu:
		mov eax, offset menu1		
		invoke StdOut, eax			;"1. Buscar"
		mov eax, 10					;fin de linea
		push eax
		print esp					;print extended stack pointer
		pop eax
		mov eax, offset menu2		;"2. Ver archivo"
		invoke StdOut, eax
		invoke StdIn, addr menuin,5	;entrada del menu

		mov al, menuin[0]			;mov del primer caracter del buffer
		sub al, 30h					;y obtencion de codigo ASCII
		cmp al,1					;Si '1' fue ingresado
		jz buscar					;Algoritmo de busqueda
		cmp al,2					;Si '2' fue ingresado
		jz mostrar					;Algoritmo de impresion de texto
		jmp menu					;default muestra menu nuevamente

		mostrar:
		xor eax, eax
		mov edx, offset directorio
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_HIDDEN,NULL
		mov manejo, eax
		cmp eax, INVALID_HANDLE_VALUE	;Error de creacion del archivo
		je fin_programa

		invoke GetFileSize,eax,0
		mov FileSize, eax
		inc eax						;para una lectura apropiada

		invoke GlobalAlloc,GMEM_FIXED,eax
		mov fileBuffer, eax

		add eax, FileSize
		mov BYTE PTR [eax],0		;Hace nulo el ultimo byte
									;Asi se puede mostrar con StdOut
		invoke ReadFile,manejo,fileBuffer,FileSize,ADDR BytesRead,0
		invoke CloseHandle,manejo
		invoke StdOut, fileBuffer			;impresion del archivo
		invoke GlobalFree,fileBuffer		;libera el espacio de memoria
		
		mov eax, 10
		push eax
		print esp					;imprime un salto de linea
		pop eax

		jmp menu

		buscar:
		invoke StdOut, addr cadena1		;"Buscar: "
		invoke StdIn,addr palabra,100	;Palabra ingresada

		mov edx, offset directorio
		INVOKE CreateFile, edx, GENERIC_WRITE OR GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_HIDDEN,NULL
		mov manejo, eax
		cmp eax, INVALID_HANDLE_VALUE	;Error de creacion del archivo
		je fin_programa

		invoke GetFileSize,eax,0
		mov FileSize, eax
		inc eax							;para poder hacer una lectura correcta

		invoke GlobalAlloc,GMEM_FIXED,eax
		mov fileBuffer, eax

		add eax, FileSize
		mov BYTE PTR [eax],0		;Hace nulo el ultimo byte
									;Asi se puede mostrar con StdOut

		invoke ReadFile,manejo,fileBuffer,FileSize,ADDR BytesRead,0
		invoke CloseHandle,manejo

		call CompararString			;Compara letra por letra hasta encontrar las demás fechas

		invoke GlobalFree,fileBuffer

		mov eax, 10
		push eax
		print esp					;salto de linea
		pop eax
		jmp menu

		fin_programa:
		invoke ExitProcess,0
		ret
	main endp

	CompararString proc
	    XOR ESI, ESI
		XOR EDI, EDI
		XOR EBX, EBX
		XOR EAX, EAX
		
		MOV EDI, fileBuffer				;Indice destino = archivo leido
		LEA ESI, palabra			;indice fuente = lectura del archivo

		MOVZX EAX, BYTE PTR [EDI]	;EAX = fileBuffer[0]
		MOV temp2, EAX				;var temp = eax
		MOVZX EBX, BYTE PTR [ESI]	;EbX = palabra_ingresada[0]
		MOV temp, EBX				;var temp = ebx
		CMP EBX, temp2				;Si fileBuffer[0] = palabra_ingresada[0]
		JE Iguales
		JNE Siguiente

		;------------------------------------IGUALES----------------------------------
		Iguales:
		XOR EBX, EBX
		INC ESI						
		
		MOVZX EBX, BYTE PTR [ESI]	;palabra_ingresada[j+1]
		MOV temp, EBX				;temp = ebx

		CMP EBX, 0					;si palabra_ingresada[i] = 0 entonces
									;ha terminado de recorrer las letras de la palabra
		JE VerifyPalabraCompleta	;hay que verificar que evaluo una palabra completa valida
		JNE SigueBuscando			;de lo contrario, seguira buscando palabras validas

		VerifyPalabraCompleta:
		INC EDI						
		MOVZX EAX, BYTE PTR [EDI]	;eax = fileBuffer[i+1]
		CMP EAX, 20h				;si hay un espacio
		JE EscribirFH
		CMP EAX, 13d				;O un salto de linea
		JE EscribirFH				;la palabra fue valida y procede a buscar la hora y fecha
		JNE Reiniciar				;De lo contrario

		SigueBuscando:
		XOR EAX, EAX
		
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]	;eax = fileBuffer[i+1]
		MOV temp2, EAX				;temp2 = eax

		CMP temp, EAX				;si palabra_ingresada[j] = fileBuffer[i]
		JE Iguales
		JNE Reiniciar

		;----------------------------------SIGUIENTE----------------------------------------
		Siguiente:
		INC EDI
		MOVZX EAX, BYTE PTR [EDI]	;eax = fileBuffer[i+1]
		CMP EAX, 0					;Si es NULL, fin de fileBuffer
		JE FinBuf

		CMP EAX, temp				;Si fileBuffer[i] = palabra_ingresada[j]
		JE Iguales
		JNE Siguiente

		Reiniciar:
		XOR ESI, ESI
		LEA ESI, palabra			;reinicia el apuntador de la palabra
		MOVZX EBX, BYTE PTR [ESI]	;ebx = palabra_ingresada[0]
		MOV temp, EBX				;temp = ebx
		JMP Siguiente

		FinCadena:
		INC EDI						

		MOVZX EAX, BYTE PTR [EDI]	;fileBuffer[i+1]
		CMP EAX, 13
		JE EscribirFH
		JNE FinCadena

		FinBuf:
		invoke StdOut, addr cadena2	;"No se encontraron mas coincidencias..."
		JMP Fin

		EscribirFH:
		invoke StdOut, addr cadena3
		INC EDI						;la fecha esta a 2 caracteres
		INC EDI						;de distancia
		MOVZX EAX, BYTE PTR [EDI]	;fileBuffer[i+1]
		CMP EAX, 0					;ver si no es el fin del programa
		JE NoFecha

		MOV ECX, 19d
		MOV contador, ECX
		;DEC EDI						;fileBuffer[i-1]
		FechaSiguiente:
			INC EDI		
			MOVZX EAX, BYTE PTR [EDI]	;eax = fileBuffer[i+1]
			push eax
			print esp				;print extended stack pointer
			pop eax
		DEC contador	

		jz endloop
		jmp FechaSiguiente

		endloop:
		MOV EAX, 10d
		push eax
		print esp					;print extended stack pointer
		pop eax
		jmp Reiniciar				;en busqueda de mas coincidencias

		NoFecha:
		invoke StdOut, addr cadena4	;no existen mas fechas
									;esto pasaría en el caso de que se intentara leer espacio nulo
		
		Fin:
		MOV EAX, 10d
		push eax
		print esp					;print extended stack pointer
		pop eax
		ret
	CompararString endp
end program