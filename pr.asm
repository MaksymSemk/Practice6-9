.model small
.stack 100h

.data
filename    db "in.txt", 0
mes db "Succ $"
mesBad db "File error $"
handle dw 0
buffer dw 10000*8 dup(0)
buffInd db 0; Index to keep track of the current position in buffer
oneChar db 0
.code
main:
    mov ax, @data
    mov ds, ax

mov dx, offset fileName; Address filename with ds:dx 
mov ah, 03Dh ;DOS Open-File function number 
mov  al, 0;  0 = Read-only access 
int 21h; Call DOS to open file 

jc error ;Call routine to handle errors
    jmp cont
 error:
     mov ah, 09h
 mov dx, offset mesBad
int 21h
jmp ending
cont:

mov [handle] , ax ; Save file handle for later

;read file and put characters into buffer
read_next:
    mov ah, 3Fh
    mov bx, [handle]  ; file handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read
    ; do something with [oneChar]
 
    ;save ax
    push ax
    ;where to write oneChar
    mov al, oneChar        ; Load the character into AL register
    mov bl, buffInd           ; Index of the 5th element (0-based index)
    
    mov si, offset buffer  ; Load the base address of the array
    add si, bx            ; Calculate the address of the element to write into
    
    mov [si], al        ; Write the character into the array element

    ;add one to keyCount(pointer)
    inc buffInd
    inc buffInd

;return ax vaulue
pop ax
    or ax,ax
    jnz read_next


;fill keys array




 mov ah, 09h
 mov dx, offset mes
int 21h
ending:


end main
