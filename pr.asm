.model small
.stack 100h

.data
filename    db "in.txt", 0
mes db "Succ $"
mesBad db "File error $"
handle dw 0
keys dw 10000*8 dup(3)
keyCount dw 0;
keysLength equ ($ - keys)   ; Calculate the length of the array
oneChar dw ?
buffer db 256 dup(0)    ; Buffer to store characters read from the file
bufferIndex dw ?        ; Index to keep track of the current position in buffer
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
jmp end
cont:

mov [handle] , ax ; Save file handle for later

read_next:
    mov ah, 3Fh
    mov bx, [handle]  ; file handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read
    ; do something with [oneChar]
 

    mov cx, 1  ; counter
    mov si, offset oneChar   ; addr of source
    mov di, offset keys  ; addr of dest
    cld   ;  left-to-right order
    rep movsb   ; repeat bytes movs until CX=0

    or ax,ax
    jnz read_next

;print array

; Loop through the array and print each element
 ;   mov si, 0           ; Initialize source index to point to the beginning of the array
;print_loop:
    ;mov ah, 02h         ; DOS function for printing a character
    ;mov bx, keys
    ;add bx, si
    ;mov dx, bx ; Load the current element of the array into dl
   ; add dx, 30h         ; Convert the number to its ASCII representation
   ; int 21h             ; Call DOS interrupt to print the character

  ;  inc si              ; Move to the next element in the array
 ;   cmp si, keysLength ; Compare the current index with the length of the array
;    jl print_loop       ; If si < arrayLength, continue looping


 mov ah, 09h
 mov dx, offset mes
int 21h
end:
mov ah, 09h
 mov dx, offset mes
int 21h

end main
