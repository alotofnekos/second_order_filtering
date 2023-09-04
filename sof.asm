
;note: For some reason _printf/_main doesnt work on my system, but main/printf does
section .data
    signal_cnt db "The signal has %d samples.", 13,10,0
    signal dd -1, 3, 4, 0, 9, -8, -2, 0x80000000
    cfh0 db "Enter coefficient h0:",13,10,0
    cfh1 db "Enter coefficient h1:",13,10,0
    cfh2 db "Enter coefficient h2:",13,10,0
    output db "Filter output:",13,10,0
    comma db ", ",0
    ln db " ",13,10,0
    scanish db "%d",0
    h0 dd 0
    h1 dd 0
    h2 dd 0 
    answer dd 0
    counter dd 0
    sample dd 0 
    h_sample dd 0
    fil db "%d",0
    cont db "Want to try again? (y/n):",0
    res dd 0

section .text
global _main
extern _printf, _scanf, _getchar, _gets, _system

_main:
    MOV ebp, esp ; for correct debugging
    
.loop:
    ; get address of next element in signal array
    MOV ESI, signal
    MOV ECX, 0
    MOV EDX, 0
    MOV EBX, 0
    ; loop through signal array
    LOOP_START:
        MOV EBX, [ESI + EDX * 4] ; load current value from signal array
        CMP EBX, 0x80000000 ; check if current value is 0x80000000
        JE .done ; if so its done
        INC EDX 
        JMP LOOP_START
.done:
    mov dword [sample],EDX   ; store the result in "sample"
    mov dword [h_sample],EDX
    push edx
    push signal_cnt
    call _printf
    add esp, 8 ; add 8 to remove the two parameters from the stack
    
    mov dword [answer],0
    JMP .get_input

.get_input:
    MOV EAX, 0
    push cfh0
    call _printf
    add esp, 4
    push h0
    push scanish
    call _scanf
    add esp, 8
    call _getchar

    push cfh1
    call _printf
    add esp, 4
    push h1
    push scanish
    call _scanf
    add esp, 8
    call _getchar

    push cfh2
    call _printf
    add esp, 4
    push h2
    push scanish
    call _scanf
    add esp, 8
    call _getchar

    push output
    call _printf
    add esp, 4
    MOV ESI, signal
    MOV EDX, 0
    MOV ECX, 0
    JMP .mulh2

.mulh2:
    MOV EDX, dword [counter]
    MOV ECX, [ESI + EDX*4] ; load current value from signal array
    MOV EBX, dword [h2]
    MOV EAX, ECX
    MUL EBX
    add dword [answer], EAX
    JMP .mulh1

.mulh1:
    MOV EDX, dword [counter]
    MOV ECX,[ESI + EDX*4 + 4] ; load current value from signal array
    MOV EBX, dword [h1]
    MOV EAX, ECX
    MUL EBX
    add dword [answer], EAX
    JMP .mulh0

.mulh0:
    MOV EDX, dword [counter]
    MOV ECX, [ESI + EDX*4 + 8] ; load current value from signal array
    MOV EBX, dword [h0]
    MOV EAX, ECX
    MUL EBX
    add dword [answer], EAX

    push dword [answer] ; print the answer
    push fil
    call _printf
    add esp, 8
    MOV ecx, dword [sample]
    DEC ecx
    MOV dword[sample], ecx
    CMP ECX, 2
    JE .cont
    push comma
    call _printf
    add esp, 4
    MOV dword [answer],0
    MOV EDX, dword [counter]
    INC EDX 
    MOV dword [counter], EDX
    JMP .mulh2
.cont:
    mov EBX, dword [h_sample]
    mov dword [sample], EBX
    MOV dword [counter], 0
    MOV dword [h0], 0
    MOV dword [h1], 0
    MOV dword [h2], 0
    MOV dword [answer], 0
    push ln
    call _printf
    add esp, 4
    push cont
    call _printf
    add esp, 4
    push res
    push scanish
    call _scanf
    add esp, 8
    call _getchar
    MOV EDX, dword [res]
    CMP EAX, "y"
    JE .get_input
    CMP EAX, "n"
    JE .dis
    JMP .cont
.dis:
    RET ; return from main function
