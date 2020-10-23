;Snimshchikov Ilya (197), variant 2
format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize     db 'Input vector size: ', 0
        strIncorSize   db 'Incorrect size of vector: %d', 10, 0
        strVecElemI    db '[%d]: ', 0
        strScanInt     db '%d', 0
        strVecElemOut  db '[%d]: %d', 10, 0
        strVecBEmpty   db 'formed vector is empty', 10, 0
        strVecB        db 'formed vector:', 10, 0

        vec_last dd ?
        vec_first dd ?
        vec_size     dd ?
        vec_size_b   dd 0
        i            dd ?
        tmp          dd ?
        vec          rd 100
        vecB         rd 100
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
        call VectorInput

        call VectorFirstLast

        call FormVecB

        call PrintB
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jng wrongSize
        cmp eax, 100
        jg wrongSize
        jmp getVector
; wrong size (less than zero or greater than 100)
wrongSize:
        push [vec_size]
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
; else continue inputting vector
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector

        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;---------------------------------------------------------------------------------
VectorFirstLast:
        mov eax, [vec]
        mov [vec_first], eax
        mov eax, [vec_size]
        mov eax, [vec + 4*eax - 4]
        mov [vec_last], eax
        ret
;--------------------------------------------------------------------------
FormVecB:
        xor ecx, ecx ;counter for b
        xor ebx, ebx ;counter for a
formVecBLoop:
        mov eax, [vec+4*ebx]
        cmp eax, [vec_first]
        je continueFormBLoop
        cmp eax, [vec_last]
        je continueFormBLoop

        mov eax, [vec+4*ebx]
        mov [vecB+4*ecx], eax
        inc [vec_size_b]
        inc ecx
continueFormBLoop:
        inc ebx
        cmp ebx, [vec_size]
        je formVecBEnd
        jmp formVecBLoop

formVecBEnd:
        ret
;--------------------------------------------------------------------------------
PrintB:
        cmp [vec_size_b], 0
        je emptyB

        push strVecB
        call [printf]
        add esp, 4

        xor ecx, ecx             ; ecx = 0
        mov ebx, vecB            ; ebx = &vec
VecBLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size_b]
        je endOutputB
        mov [i], ecx

        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]
        add esp, 12

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp VecBLoop
emptyB:
        push strVecBEmpty
        call [printf]
        add esp, 4
endOutputB:
        ret
;-------------------------------------------------------------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'
import kernel,\
       ExitProcess, 'ExitProcess'
import msvcrt,\
       printf, 'printf',\
       scanf, 'scanf',\
       getch, '_getch'