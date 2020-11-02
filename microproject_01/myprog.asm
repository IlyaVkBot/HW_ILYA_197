format PE console
entry start

include 'win32a.inc'


section '.code' code readable executable

start:
    FINIT ; инициализаци€ сопроцессора

    call Input ;ввод числа

    FLD  [input] ; загрузка числа в вершину стека st(0)
    call Atan

    FSTP  [result] ; запись в память результата вычисления арктангенса

    ; вывод результата
    invoke printf, fmt_string, dword[input], \
                    dword[input+4], \
                    dword[result],dword[result+4]

    invoke getch
    invoke ExitProcess, 0 ; выход из программы с кодом возврата 0

;Ввод числа
Input:
    push strScanFloatText
    call [printf]
    add esp, 4

    push input ;ввод числа
    push strScanFloat
    call [scanf]
    add esp, 8

    ret

;Вычисление арктангенса числа из st(0)
;После вычислений число перемещается в sp(1)
;Результат находится в SP(0)
;Для вычислений используется 6 ячеек
Atan:
    FLDZ
    FCOMIP st1
    jne notzero
    FLDZ
    ret
    ;проверяем, что |input| < 1
notzero:
    FLD1
    FCOMIP st1
    jb normpos
    FLD1
    FCHS
    FCOMIP st1
    ja normneg

    FLDZ; загружаем 0 в стек
    jmp startloop
normneg:
    ;Вычитаем pi просто для красоты, чтобы результаты были от -pi/2 до pi/2
    FLDPI
    FCHS
    jmp norm
normpos:
    FLDPI
norm:
    ;если модуль больше 1, то нормализуем согласно алгоритму
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
    ;st0 - текущий x^2n + 1
    ;st1 - текущий 2n + 1
    ;st2 - текущий результат
    ;st3 - входное число

    ;Прибавление очередного слагаемого к результату
    FLD st1
    FDIVR st, st1
    FADD st3, st

    ;Проверка, достигнута ли нужная точность
    FDIV st, st3
    FABS
    FLD [eps]
    FCOMIP st1
    FSTP st
    ;Выход из алгоритма, если точность достигнута
    ja endloop

    ;Обновление счетчиков и вспомогательных переменных для следующей итерации цикла
    FCHS
    FMUL st, st3
    FMUL st, st3
    FLD1
    FADD st, st
    FADDP st2, st
    jmp continueloop
endloop:
    ;Выход из алгоритма
    FSTP st
    FSTP st
    ret

;-------------------------------third act - including HeapApi--------------------------
section '.data' data readable writable

    fmt_string db "input number = %lf, arctan(input) = %lf", 10, 0

    strScanFloat db '%lf', 0
    strScanFloatText db 'Input a: ', 0

    input dq ? ; входное число
    eps dq 0.0001 ; допуск
    result dq ? ; результат вычисления (формат двойной точности)

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