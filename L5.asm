.model small
.stack 100h
.data
sumbl db 1 dup(0)
argc dw 0
maxcmdsize equ 126
cmd_length dw ?
cmd_line db maxcmdsize dup(?)
buf db maxcmdsize+2,?,maxcmdsize dup('$')  
filename db 126 dup("$")
position dw 0
localsize dw 0
number dw 0
stringinfile dw 0
StringFileOpenMsg db "File was opened ", 13,10, "$"
StringFileCloseMsg db "File was closed ", 13,10, "$"
StringErrorComandLineMsg db "Comand Line Error size",13,10,"$"
StringFileErrorOpenMsg db "File Error Open", 13,10, "$"
StringFileErrorCloseMsg db "File Error Close", 13,10, "$"
StringBeginMsg db "The program has begun ", 13,10, "$"
StringErrorParsMsg db "Error pars params in comand line",13,10,"$" 
StringErrorOwerflowMsg db "Error Owerflow of size: size your entered biger the 32767",13,10,"$"
StringEndMsg db "The program has end ", 13,10, "$"
StringinFileMsg db "The number of the matching line in the file: $"
StringAmpleAmountMsg db "Satisfying number of lines: $"
StringNewStr db 13,10,"$"
StringScobka db ") $"
StringSizeMsg db ".   size: $"
.code


Print_str macro msg
    push ax
    push dx
    mov ah,9
    mov dx,offset msg
    int 21h
    pop dx
    pop ax
endm 


Show_AX proc
    push bx
    push cx
    push dx
    push ax
    mov bx, 10
    xor cx,cx
Convert:
    xor dx,dx
    div bx           
    add dl, 30h
    push dx          
    inc cx           
    or ax, ax
    jnz Convert
Show1:
    pop dx 
    mov ah,2           
    int 21h
    dec cx            
    jnz Show1
    pop ax
    pop dx
    pop cx
    pop bx
    ret
Show_AX endp

IsEnough proc
    push si
    mov si,stringinfile
    inc si
    mov stringinfile,si
    pop si
    push bx
    mov bx,si
    add position,si
    cmp bx,localsize
    jle EndIsEnough
    mov bx,number
    inc bx
    mov number,bx
    push ax
    mov ax,number
    call Show_AX
    pop ax
    Print_str StringScobka
    Print_str StringinFileMsg
    push ax
    mov ax,stringinfile
    call Show_AX
    Print_str StringSizeMsg
    mov ax,si
    call Show_AX
    pop ax
    
    Print_str StringNewStr
EndIsEnough:
    pop bx    
    ret
IsEnough endp

Makeparams proc
    push si
    push di
    push dx
    push cx
    xor si,si
    xor di,di   
sravn:    
    cmp cmd_line[si],' '
    jne nextstep
    call SkipSpaces
    inc argc
    cmp argc,2
    je second
    cmp argc,3
    je third
nextstep:
    mov dl,cmd_line[si]
    mov buf[di],dl
    inc di
    inc si
    xor dx,dx
    mov dx,cmd_length
    cmp si,dx
    jne sravn
    jmp third 
second:
    mov cx,di
    xor di,di
secondcycle:
    xor dx,dx
    mov dl,buf[di]
    mov filename[di],dl
    mov buf[di],"$"
    inc di
    loop secondcycle
    mov filename[di],0
    xor di,di
    jmp sravn
third:
    mov cx,di
    xor di,di
thirdcycle:
    cmp buf[di],30h
    jl ErrorEnded2
    cmp buf[di],39h
    jg ErrorEnded2
    push ax
    push bx
    mov bx,10
    mov ax,localsize
    mul bx
    mov localsize,ax
    pop bx
    pop ax
    
    push ax
    xor ax,ax
    mov al,buf[di]
    sub al,30h
    add localsize,ax
    pop ax
    jc ErrorEnded1
    inc di
    loop thirdcycle
    push cx
    xor cx,cx
    call IsNumberValid
    cmp cx,1
    je ErrorEnded1
    pop cx
    jmp EndMakeparams    
ErrorEnded1:
    pop cx
    Print_str StringErrorOwerflowMsg
    jmp ErrorEnds        
ErrorEnded2:
    Print_str StringErrorParsMsg
ErrorEnds:
    pop cx    
    pop dx    
    pop si
    pop di
    jmp Exit                      
EndMakeparams:
    pop cx    
    pop dx    
    pop si
    pop di
    ret
Makeparams endp    

IsNumberValid proc
    cmp localsize,32767
    jle Valid
    mov cx,1
    jmp ExitIsNumberValid    
Valid:
    mov cx,0
ExitIsNumberValid:          
    ret
IsNumberValid endp    

SkipSpaces proc
SkipCycle:    
    cmp cmd_line[si],' '
    je skip
    jmp EndSkip
skip:
    inc si
    jmp SkipCycle
EndSkip:    
    ret
SkipSpaces endp    


start:
    mov ax, @data
    mov es, ax
    
    xor cx,cx
    mov cl,ds:[80h]
    mov bx,cx
    mov si,81h
    mov di,offset cmd_line
    rep movsb
    
    mov ds,ax
    Print_str StringBeginMsg
    mov cmd_length,bx

    call Makeparams    
    
    mov dx,offset filename
    mov ah,3Dh
    mov al,00h
    int 21h
    jc ErrorExit2 
    Print_str StringFileOpenMsg
    mov bx,ax
    mov di,01
    push si
Cycle:    
    call Read
    jmp Cycle
Close:
    call Ended
    jmp Exit
    
ErrorExit1:    
    Print_str StringErrorComandLineMsg
    jmp Exit
ErrorExit2:
    mov ah,3Eh
    int 21h
    jc ErrorExit3
    Print_str StringFileErrorOpenMsg
    jmp Exit
ErrorExit3:
    Print_str StringFileErrorCloseMsg                
Exit:
    Print_str StringEndMsg    
    mov ax, 4c00h
    int 21h

    Read proc
    push cx
    push si
    xor si,si
    mov cx,1
ReadCycle:    
    mov dx,offset sumbl
    mov ah,3Fh
    int 21h
    jc ErrorExit2
    mov cx,ax
    jcxz Close
    inc si
    cmp sumbl,13
    je EndRead
    cmp sumbl,10
    je Decr 
    jmp ReadCycle
Decr:
    dec si
    jmp ReadCycle    
EndRead:
    dec si     
    call IsEnough   
    pop si
    pop cx
    ret
Read endp
    
Ended proc
    cmp buf,13
    call IsEnough
    mov ah,3Eh
    int 21h
    jc ErrorExit3 
    Print_str StringNewStr
    Print_str StringAmpleAmountMsg
    push ax
    mov ax,number
    call Show_AX
    pop ax
    Print_str StringNewStr
    Print_str StringFileCloseMsg
    ret
Ended endp        
    
end start