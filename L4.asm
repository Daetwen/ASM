.model small
.stack 100h

.data
direction db 0
position dw 648
Lives dw 1
count dw 0
ArrayBots dw 5 dup(0)
ArrayBotsDirections db 5 dup(1,2,3,3,4)

.code

PrintHorizontalBorder proc
    push ax
    push es
    push cx
    mov ax,0B800h
    mov es,ax
    
    mov ah,1
    mov al,178
    mov cx,80
Loop_HorizontalBorder:    
    mov es:[di],ax
    add di,2
    loop Loop_HorizontalBorder
    pop cx
    pop es
    pop ax
    ret
PrintHorizontalBorder endp

PrintVerticalBorder proc
    push ax
    push es
    push cx
    mov ax,0B800h
    mov es,ax
    
    mov ah,1
    mov al,178
    mov cx,23
Loop_VerticalBorder:    
    mov es:[di],ax
    add di,160
    loop Loop_VerticalBorder
    pop cx
    pop es
    pop ax
    ret
PrintVerticalBorder endp

PrintTwo proc
    push cx
    push ax
    mov cx,2
    mov ah,1
    mov al,178
Loop_Two:    
    mov es:[di],ax
    add di,2
    loop Loop_Two
    pop ax
    pop cx
    ret
PrintTwo endp

PrintThree proc
    push cx
    push ax
    mov cx,3
    mov ah,1
    mov al,178
Loop_Three:    
    mov es:[di],ax
    add di,2
    loop Loop_Three
    pop ax
    pop cx
    ret
PrintThree endp

PrintSegment proc
push di    
    mov cx,4
    mov si,0
FirstMetka:    
Loop_First:    
    call PrintTwo
    call PrintTwo
    add di,2
    loop Loop_First
    inc si
    add di,300
    mov cx,2
    cmp si,2
    jl FirstMetka
    sub di,160
    mov cx,2
    cmp si,3
    jl FirstMetka
    add di,160
    cmp si,4
    jl FirstMetka
    add di,320
    mov cx,2
    cmp si,5
    jl FirstMetka
    sub di,480
    mov cx,2
    cmp si,6
    jl FirstMetka
pop di
push di
    add di,322
    call PrintThree
    add di,4
    call PrintThree
    add di,462
    call PrintThree
    add di,346
    call PrintThree
    sub di,26
    mov cx,4
Loop_Second:
    call PrintThree
    add di,154
    loop Loop_Second     
pop di
push di
    add di,328
    mov cx,4
Loop_Therd:    
    call PrintTwo
    add di,156
    loop Loop_Therd
    sub di,326
    call PrintTwo
    add di,8
    mov cx,3
Loop_Fore:
    call PrintTwo
    add di,156
    loop Loop_Fore
    sub di,14
    call PrintTwo
    add di,2
    call PrintTwo
    add di,10
    call PrintTwo
    add di,2
    call PrintTwo
    add di,290
    mov cx,2
Loop_Five:
    call PrintTwo
    add di,2
    call PrintTwo
    add di,150
    loop Loop_Five         
pop di         
    ret
PrintSegment endp

PrintBorders proc
  
    mov di,0
    call PrintHorizontalBorder
    mov di,3840
    call PrintHorizontalBorder
    mov di,160
    call PrintVerticalBorder
    mov di,318
    call PrintVerticalBorder
    mov di,162
    mov cx,4
    mov si,0
Loop_PrintBorders1:
    push cx
    push si    
    call PrintSegment
    pop si
    pop cx
    add di,40
    loop Loop_PrintBorders1
    mov di,2082 
    mov cx,4
    inc si
    cmp si,1
    je Loop_PrintBorders1 

    ret
PrintBorders endp

PrintPoints proc
    mov di,162
    mov ah,1
    mov al,178
    mov bh,15
    mov bl,249
Loop_PrintPoints:   
    cmp es:[di],ax
    jne Pointtt
    add di,2
    cmp di,4000
    jg End_PrintPoints
    jmp Loop_PrintPoints 
Pointtt:
    mov es:[di],bx
    add di,2
    cmp di,4000
    jg End_PrintPoints
    jmp Loop_PrintPoints
End_PrintPoints:        
    ret
PrintPoints endp    

IsDeath proc
    push bx
    push ax
    push cx
    mov bh,14
    mov bl,2
    mov ah,4
    mov al,42   
    cmp es:[si],ax
    je Death_point
    jmp End_IsDeath
Death_point:
    mov es:[si],bx 
    push cx
    mov cx,Lives
    dec cx
    mov Lives,cx
    cmp cx,0
    call End_Moving
    pop cx
End_IsDeath:
    pop cx
    pop ax
    pop bx
    ret        
IsDeath endp    

End_Moving proc
    pop dx     
    pop cx 
    pop si
    pop ax         
    mov ax, 4c00h
    int 21h
    ret
End_Moving endp    

IsBorder proc
    push ax
    mov ah,1
    mov al,178
    cmp es:[si],ax
    je Border_point
    jmp End_IsBorder
Border_point:
    mov dx,1
End_IsBorder:
    pop ax 
    ret       
IsBorder endp

IsOtherBot proc
    push ax
    mov ah,4
    mov al,42
    cmp es:[si],ax
    je OtherBot_point
    jmp End_IsOtherBot
OtherBot_point:
    mov dx,1
End_IsOtherBot:
    pop ax 
    ret       
IsOtherBot endp

IsBonus proc
    push ax
    push si
    mov ah,2
    mov al,48
    cmp es:[si],ax
    je Bonus_point
    jmp End_IsBonus
Bonus_point:
    call PrintOneBonus
    push ax
    mov ax,count
    add ax,2 
    call PrintCount
    mov count,ax
    pop ax
End_IsBonus:
    pop si
    pop ax
    ret
IsBonus endp 

IsPoint proc
    push ax
    push si
    mov ah,15
    mov al,249
    cmp es:[si],ax
    je IsPoint_point
    jmp End_IsPoint
IsPoint_point:
    push ax
    mov ax,count
    add ax,1 
    call PrintCount
    mov count,ax
    pop ax
End_IsPoint:
    pop si
    pop ax
    ret
IsPoint endp    

IsBonusByBot proc
    push ax
    push si
    mov ah,2
    mov al,48
    cmp es:[si],ax
    je Bonus_pointByBot
    jmp End_IsBonusByBot
Bonus_pointByBot:
    call PrintOneBonus
End_IsBonusByBot:
    pop si
    pop ax
    ret
IsBonusByBot endp

IsDeathByBot proc
    push bx
    push cx
    mov bh,14
    mov bl,2   
    cmp es:[si],bx
    je Death_pointByBot
    jmp End_IsDeathByBot
Death_pointByBot:
    mov es:[si],bx 
    push cx
    mov cx,Lives
    dec cx
    mov Lives,cx
    cmp cx,0
    call End_Moving
    pop cx
End_IsDeathByBot:
    pop cx
    pop bx
    ret
IsDeathByBot endp    

PrintCount proc
    push bx
    push cx
    push dx
    push ax
    push si
    mov bx, 10
    xor cx,cx
Convert:
    xor dx,dx
    div bx
    mov dh,4           
    add dl, 30h
    push dx          
    inc cx           
    or ax, ax
    jnz Convert
    xor si,si
Show1:
    pop dx 
    mov es:[si],dx           
    add si,2
    dec cx            
    jnz Show1
    pop si
    pop ax
    pop dx
    pop cx
    pop bx
    ret
PrintCount endp

SpawnBots proc
    push bx
    push si
    push cx
    mov bh,4
    mov bl,42
    mov si,0
    mov cx,5
Random_cycle1:
    push ax
    push cx
    push dx
    xor ax,ax
    mov cx,0
    mov dx,569
    mov ah,86h
    int 15h
    pop dx
    pop cx
    pop ax    
    call random    
    cmp ax,170
    jl Random_cycle1
    cmp ax,3680
    jg Random_cycle1
    mov di,ax
    mov ah,1 
    mov al,178
    cmp es:[di],ax
    je Random_cycle1    
IsWorld:
    mov ArrayBots[si],di
    add si,2
    mov es:[di],bx
    loop Random_cycle1
    pop cx         
    pop si
    pop bx
    ret
SpawnBots endp    

MoveBotUp proc
    mov di,ArrayBots[si]    
    push si
    mov si,di
    sub si,160
    call IsBorder
    call IsOtherBot
    call IsDeathByBot
    pop si
    cmp dx,1
    je EndMoveBotUp
    mov byte ptr es:[di],' '
    push si
    mov si,di
    call IsBonusByBot
    pop si
    sub di,160
    mov es:[di],bx
    mov ArrayBots[si],di
EndMoveBotUp:
    xor dx,dx
    ret
MoveBotUp endp     
    
MoveBotDown proc
    mov di,ArrayBots[si] 
    push si
    mov si,di
    add si,160
    call IsBorder
    call IsOtherBot
    call IsDeathByBot
    pop si
    cmp dx,1
    je EndMoveBotDown 
    mov byte ptr es:[di],' '
    add di,160
    push si
    mov si,di
    call IsBonusByBot
    pop si
    mov es:[di],bx
    mov ArrayBots[si],di
EndMoveBotDown:
    xor dx,dx 
    ret
MoveBotDown endp    
    
MoveBotLeft proc
    mov di,ArrayBots[si]    
    push si
    mov si,di
    sub si,2
    call IsBorder
    call IsOtherBot
    call IsDeathByBot
    pop si
    cmp dx,1
    je EndMoveBotLeft 
    mov byte ptr es:[di],' '
    sub di,2
    push si
    mov si,di
    call IsBonusByBot
    pop si
    mov es:[di],bx
    mov ArrayBots[si],di
EndMoveBotLeft:
    xor dx,dx    
    ret
MoveBotLeft endp     
    
MoveBotRight proc
    mov di,ArrayBots[si]    
    push si
    mov si,di
    add si,2
    call IsBorder
    call IsOtherBot
    call IsDeathByBot
    pop si
    cmp dx,1
    je EndMoveBotRight 
    mov byte ptr es:[di],' '
    add di,2
    push si
    mov si,di
    call IsBonusByBot
    pop si
    mov es:[di],bx
    mov ArrayBots[si],di
EndMoveBotRight:
    xor dx,dx     
    ret
MoveBotRight endp    

AllMoving proc
    push ax
    push si
    push cx
    push dx
    push bx
    
    push ax
    xor ax,ax
    call PrintCount
    pop ax
    call SpawnBots
    mov bh,4
    mov bl,42
    mov ch,14
    mov cl,2
    mov si,position
    mov es:[si],cx
AllMoving_cycle:
    mov ah,1
    int 16h
    jz NoButton
    cmp ax,4800h   ;Up
    je One
    cmp ax,5000h   ;Down
    je Two
    cmp ax,4D00h   ;Right
    je Three
    cmp ax,4B00h   ;Left
    je Fore
    mov ax,0C00h
    int 21h
    jmp MovingBotsCycle1
One:
    mov direction,1
    mov ax,0C00h
    int 21h
    jmp NoButton
Two:
    mov direction,2
    mov ax,0C00h
    int 21h
    jmp NoButton
Three:
    mov direction,3
    mov ax,0C00h
    int 21h
    jmp NoButton
Fore:
    mov direction,4
    mov ax,0C00h
    int 21h
    jmp NoButton     
up:
    call PersonMovingUp
    jmp MovingBotsCycle1
down:
    call PersonMovingDown
    jmp MovingBotsCycle1
left:
    call PersonMovingLeft
    jmp MovingBotsCycle1
right:
    call PersonMovingRight
    jmp MovingBotsCycle1
   
NoButton: 
    mov ax,0C00h
    int 21h   
    cmp direction,0
    je MovingBotsCycle1
    cmp direction,1
    je up
    cmp direction,2
    je down
    cmp direction,3
    je right
    cmp direction,4
    je left
MovingBotsCycle1:
    push cx
    push si
    push dx
    mov cx,5
    mov si,0
MovingBotsCycle2:
    push cx
    push dx
    mov cx,0
    mov dx,2000
    mov ah,86h
    int 15h
    pop dx
    pop cx
    xor dx,dx
    call random
    cmp ax,1000
    jl up3
    cmp ax,1500
    jl down3
    cmp ax,2200
    jl right3
    cmp ax,2800
    jl left3
MoveBotAccordingDirection:    
    cmp ArrayBotsDirections[si],1    
    je up2
    cmp ArrayBotsDirections[si],2    
    je down2
    cmp ArrayBotsDirections[si],3    
    je right2
    cmp ArrayBotsDirections[si],4    
    je left2
NextBot:
    add si,2
    loop MovingBotsCycle2  
    pop dx  
    pop si
    pop cx
    ;push ax
    ;push cx
    ;push dx
    ;mov cx,2
    ;mov dx,500
    ;mov ah,86h
    ;int 15h
    ;pop dx
    ;pop cx
    ;pop ax
    jmp AllMoving_cycle
up2:
    call MoveBotUp
    jmp NextBot
down2:
    call MoveBotDown
    jmp NextBot
left2:
    call MoveBotLeft
    jmp NextBot
right2:
    call MoveBotRight
    jmp NextBot
up3:
    mov ArrayBotsDirections[si],1
    jmp MoveBotAccordingDirection
down3:
    mov ArrayBotsDirections[si],2
    jmp MoveBotAccordingDirection
left3:
    mov ArrayBotsDirections[si],3
    jmp MoveBotAccordingDirection
right3:
    mov ArrayBotsDirections[si],4
    jmp MoveBotAccordingDirection               
    pop bx 
    pop dx
    pop cx
    pop si
    pop ax
    ret
AllMoving endp
         
PersonMovingUp proc 
    push si
    sub si,160
    call IsBorder
    pop si
    cmp dx,1
    jne firststation
    mov dx,0
    jmp EndPersonMovingUp
firststation:
    mov byte ptr es:[si],' '    
    sub si,160
    mov dx,0
    call IsBonus
    call IsPoint
    push si
    call IsDeath
    pop si
    mov es:[si],cx
EndPersonMovingUp: 
    ret
PersonMovingUp endp    
    
PersonMovingDown proc
    push si
    add si,160
    call IsBorder
    pop si
    cmp dx,1
    jne secondstation
    mov dx,0
    jmp EndPersonMovingDown
secondstation:
    mov byte ptr es:[si],' '
    add si,160
    mov dx,0
    call IsBonus
    call IsPoint
    push si
    call IsDeath
    pop si
    mov es:[si],cx
EndPersonMovingDown:     
    ret
PersonMovingDown endp        
    
PersonMovingRight proc
    push si
    add si,2
    call IsBorder
    pop si
    cmp dx,1
    jne thirdstation
    mov dx,0
    jmp EndPersonMovingRight
thirdstation:
    mov byte ptr es:[si],' '
    add si,2
    mov dx,0
    call IsBonus
    call IsPoint
    push si
    call IsDeath
    pop si
    mov es:[si],cx
    mov dx,0
EndPersonMovingRight:     
    ret
PersonMovingRight endp
        
PersonMovingLeft proc 
    push si
    sub si,2
    call IsBorder
    pop si
    cmp dx,1
    jne forestation
    mov dx,0
    jmp EndPersonMovingLeft
forestation:
    mov byte ptr es:[si],' '
    sub si,2
    mov dx,0
    call IsBonus
    call IsPoint
    push si
    call IsDeath
    pop si
    mov es:[si],cx
EndPersonMovingLeft:     
    ret
PersonMovingLeft endp

random proc
    push dx
    push bx
    push cx
    mov ah,2Ch
	int 21h

	mov al,dl
	mul dh
	mov dx,2
	mul dx	
    
    pop cx
    pop bx
	pop dx
	ret
random endp	

PrintOneBonus proc
    push dx
    mov dh,1
    mov dl,178
    push si
    push bx
    push cx
    mov si,0
    mov ch,2
    mov cl,48
Loop_PrintOneBonus:
    push cx
    push dx 
    call random
    pop dx
    pop cx
    mov si,ax
    cmp si,162
    jl  Loop_PrintOneBonus
    cmp si,3400
    jg  Loop_PrintOneBonus
    cmp es:[si],dx
    je  Loop_PrintOneBonus
    mov es:[si],cx
    pop cx
    pop bx
    pop si
    pop dx
    ret
PrintOneBonus endp

main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    mov ax,0003h
    int 10h
    mov ax,0B800h
    mov es,ax
    mov di,0
    mov dx,0
    call PrintBorders
    call PrintPoints
    
    push cx
    mov cx,20
Loop_PrintBonus:
    push ax
    push cx
    push dx
    xor ax,ax
    mov cx,1
    mov dx,2000
    mov ah,86h
    int 15h
    pop dx
    pop cx
    pop ax
    call PrintOneBonus
    loop  Loop_PrintBonus
    pop cx 
    call AllMoving    
EndGame:     
    mov ax, 4c00h
    int 21h 
;ends
end main
