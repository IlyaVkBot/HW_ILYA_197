format PE console
entry start

include 'win32a.inc'


section '.code' code readable executable

start:
    FINIT ; ������������ ������������

    call Input ;���� �����

    FLD  [input] ; �������� ����� � ������� ����� st(0)
    call Atan

    FSTP  [result] ; ������ � ������ ���������� ���������� �����������

    ; ����� ����������
    invoke printf, fmt_string, dword[input], \
                    dword[input+4], \
                    dword[result],dword[result+4]

    invoke getch
    invoke ExitProcess, 0 ; ����� �� ��������� � ����� �������� 0

;���� �����
Input:
    push strScanFloatText
    call [printf]
    add esp, 4

    push input ;���� �����
    push strScanFloat
    call [scanf]
    add esp, 8

    ret

;���������� ����������� ����� �� st(0)
;����� ���������� ����� ������������ � sp(1)
;��������� ��������� � SP(0)
;��� ���������� ������������ 6 �����
Atan:
    FLDZ
    FCOMIP st1
    jne notzero
    FLDZ
    ret
    ;���������, ��� |input| < 1
notzero:
    FLD1
    FCOMIP st1
    jb normpos
    FLD1
    FCHS
    FCOMIP st1
    ja normneg

    FLDZ; ��������� 0 � ����
    jmp startloop
normneg:
    ;�������� pi ������ ��� �������, ����� ���������� ���� �� -pi/2 �� pi/2
    FLDPI
    FCHS
    jmp norm
normpos:
    FLDPI
norm:
    ;���� ������ ������ 1, �� ����������� �������� ���������
    FLD1
    FCHS
    FDIVRP st2, st
    FLD1
    FADD st, st
    FDIVP st1, st

startloop:
    FLD1
    FLD st2
continueloop:
    ;st0 - ������� x^2n + 1
    ;st1 - ������� 2n + 1
    ;st2 - ������� ���������
    ;st3 - ������� �����

    ;����������� ���������� ���������� � ����������
    FLD st1
    FDIVR st, st1
    FADD st3, st

    ;��������, ���������� �� ������ ��������
    FDIV st, st3
    FABS
    FLD [eps]
    FCOMIP st1
    FSTP st
    ;����� �� ���������, ���� �������� ����������
    ja endloop

    ;���������� ��������� � ��������������� ���������� ��� ��������� �������� �����
    FCHS
    FMUL st, st3
    FMUL st, st3
    FLD1
    FADD st, st
    FADDP st2, st
    jmp continueloop
endloop:
    ;����� �� ���������
    FSTP st
    FSTP st
    ret

;-------------------------------third act - including HeapApi--------------------------
section '.data' data readable writable

    fmt_string db "input number = %lf, arctan(input) = %lf", 10, 0

    strScanFloat db '%lf', 0
    strScanFloatText db 'Input a: ', 0

    input dq ? ; ������� �����
    eps dq 0.0001 ; ������
    result dq ? ; ��������� ���������� (������ ������� ��������)

section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
    include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           sprintf, 'sprintf',\
           scanf, 'scanf',\
           getch, '_getch'