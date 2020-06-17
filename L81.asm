My_segment SEGMENT  
    
ASSUME SS:My_segment,DS:My_segment,CS:My_segment,ES:My_segment
.386   

org 80h                                
cmd_length db ?    
cmd_line db ?    
org 100h                               
     
start: 
jmp ParsingCmdLines                 
     
oldIRQ1 dd 0    
BufferToConsole db 4000 dup(0)
descriptor dw 0
filename db 126 dup (0)
StringInfoMsg db "Ctrl+P - write in file",13,10, "$"
StringErrorComandLineMsg db "Comand Line Error size",13,10,"$"
StringErrorCMDMsg db "CMD line is empty", 13,10,"$"
StringErrorParsMsg db "Error pars params in comand line",13,10,"$"
StringCreateFileMsg db 13,10,"The file you entered was not found. File is being created",13,10,"$"
StringFileErrorOpenMsg db 13,10,"File Error Open",13,10,"$"
StringFileErrorCloseMsg db "File Error Close", 13,10,"$"
StringFileErrorCreateMsg db "File Error Create ",13,10,"$"
StringFileErrorWriteMsg db "Error write", 13,10,"$"
StringErrorPositioningMsg db "Positioning error at the end of the file",13,10,"$"
StringSuccessMsg db 13,10,"Write to file occurred",13,10
StringNewStr db 13,10,"$"
symbls db 2000 dup(0)                                                        

ParsingCmdLines:                   
    call MakeParams 
    call CheckFile 

Install_handler:	
	cli                                 
	mov ah, 35h
	mov al, 09h                            
	int 21h                     
	
	mov word ptr cs:oldIRQ1,bx  
	mov word ptr cs:oldIRQ1+2,es 
	
	mov ah, 25h                         
	mov al, 09h                         
	lea dx, newIRQ1                 
	int 21h 
	sti                                
  	
  	mov ah,09h
  	lea dx,StringInfoMsg 
  	int 21h
  	
    mov dx, offset ParsingCmdLines    
    int 27h                             
    call Exit
    
Exit proc	                        
	mov ax, 4c00h
	int 21h
    ret
Exit endp    

Print_str macro msg
    push ax
    push dx
    mov ah,9
    mov dx,offset msg
    int 21h
    pop dx
    pop ax
endm                                                                               


MakeParams proc    
    cld                                  
	mov bp, sp      	                 
	mov cl, cmd_length
	dec cl                   
	cmp cl, 0                           
	jg NextStep0  
	Print_str StringErrorCMDMsg
    call Exit
NextStep0:
	mov cmd_length,cl
    mov si,82h
    lea di,filename
cycle1:
    mov ah, cs:[si]
    cmp ah," "
    je ErrorParsPoint    
    mov ds:[di],ah
    inc di
    inc si
    loop cycle1
    
    push cx
    xor cx,cx
    mov cl, cmd_length
    mov si,cx
    inc si
    mov filename[si],0
    pop cx
	ret
ErrorParsPoint:
    Print_str StringErrorParsMsg
    call Exit
    ret		
MakeParams endp


newIRQ1 proc far              
	pushf                 
	call cs:oldIRQ1  
	;cli                     
	pusha

    mov ah, 01h                 
    int 16h
    mov bh, ah                  
    jz EndnewIRQ1
   
    mov ah, 02h                
    int 16h
    and al, 4                   
    cmp al, 0
    je EndnewIRQ1
   
    cmp bh, 19h
    jne EndnewIRQ1
    mov ah, 00h
    int 16h      	 
	 
    mov ax,0B800h               
	mov ds,ax                  
	mov ax, cs
	mov es, ax

	mov di, offset BufferToConsole   
	xor si, si
	mov cx, 2000                
	rep movsw
WorkWithFile:
    call Filter	           
	call OpenFile            
	call SetInEndOfFile	
	call WriteFile	
	call CloseFile
	    
EndnewIRQ1: 
	popa
	;sti
	iret          
newIRQ1 endp

Filter proc                  
	mov ax, cs
	mov ds, ax
	mov cx, 2000
	mov di, offset BufferToConsole
	xor si, si
	xor bl, bl  
	
Buffer_shaping:                     
	mov ah, [di]
	mov BufferToConsole[si], ah
	cmp bl, 79                        
	jne Next_line_buffer
	mov byte ptr BufferToConsole[si+1], 0Dh 
	inc si
	mov bl, -1
	
Next_line_buffer:                  
	inc bl
	inc si
	add di, 2  	
loop Buffer_shaping 
    ret
Filter endp

SetInEndOfFile proc           
    pusha  
    mov bx, descriptor                                    
    xor cx, cx                        
    xor dx, dx    
    mov ah, 42h
    mov al, 02h  
    int 21h
    
    jc ErrorSetInEndOfFile                   
    jmp EndSetInEndOfFile                
    
ErrorSetInEndOfFile:
    Print_str StringErrorPositioningMsg
    popa
    call Exit
EndSetInEndOfFile:        
    popa    
    ret
SetInEndOfFile endp

OpenFile proc                   
    pusha   
    xor cx, cx 
    mov dx, offset filename
    mov ah, 3Dh                    
    mov al, 02h                    
    int 21h 
    jc ErrorOpen              	
    mov descriptor, ax  
    jmp ExitOpen 
ErrorOpen:
    Print_str StringFileErrorOpenMsg
    cmp ax, 02h
    
    popa
    call Exit
ExitOpen:
    popa    
    ret
OpenFile endp    

CloseFile proc                   
    pusha
    mov bx, descriptor               
    xor ax, ax    
    mov ah, 3Eh    
    int 21h
    jc ErrorClose              
    jmp ExitClose 
    
ErrorClose:
    Print_str StringFileErrorCloseMsg
    popa
    call Exit 
ExitClose:
    popa
    ret
CloseFile endp

WriteFile proc
    pusha
    xor ax,ax
    xor dx,dx
    mov ah,40h
    mov bx,descriptor
    mov cx,2025
    lea dx,BufferToConsole
    int 21h
    jc ErrorExitWriteFile
    jmp EndWriteFile
ErrorExitWriteFile:
    Print_str StringFileErrorWriteMsg  
    popa
    call Exit
EndWriteFile:    
    popa
    ret
WriteFile endp

CheckFile proc                     
    push cx
    push ax
     
    xor cx, cx 
    mov dx, offset filename
    mov ah, 3Dh                     
    mov al, 02h                 
    int 21h 
    jc FileNot
    jmp ExitCheckFile	

FileNot:                           
    Print_str StringCreateFileMsg    
    xor cx, cx
	lea dx, filename
	mov ah, 3Ch                  
	mov al, 00h
	int 21h 
    jc ErrorCreate
    jmp ExitCheckFile
ErrorCreate:
    Print_str StringFileErrorCreateMsg
    pop ax
    pop cx
    call Exit
    ret
ExitCheckFile:
    mov descriptor,ax
    call CloseFile
    pop ax
    pop cx
    ret         
CheckFile endp
                                                                 
My_segment ENDS                         
end start  
