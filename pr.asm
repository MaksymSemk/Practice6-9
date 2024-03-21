.model small
.stack 100h

.data
filename    db "in.txt", 0
mes db "Succ $"
mesBad db "File error $"
handle dw 0

buffInd db 0; Index to keep track of the current position in buffer
oneChar db 0

keys db 10000*16 dup(0)
keyInd dw 0
isWord db 1
values dw 10000*8 dup(0)
valInd dw 0
number db 16 dup(0)
numberInd dw 0


.code
main proc
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
    push bx
    push cx
    push dx
    call procChar
    ;where to write oneChar
    ;mov al, oneChar        ; Load the character into AL register
    ;mov bl, buffInd           ; Index of the 5th element (0-based index)
    
    ;mov si, offset buffer  ; Load the base address of the array
    ;add si, bx            ; Calculate the address of the element to write into
    
   ; mov [si], al        ; Write the character into the array element

    ;add one to keyCount(pointer)
   ; inc buffInd

;return  vaulues
pop dx
pop cx
pop bx
pop ax
    or ax,ax
    jnz read_next
;clean number last number and write last number
        mov si, offset number
        dec numberInd
       mov bx, numberInd
    
        add si, bx
        mov al, 0
        mov [si], al
        call trnInNum
;fill keys array

 mov ah, 09h
 mov dx, offset mes
int 21h
ending:
main endp



procChar proc
    ;pop dx; save adress to dx
    ;mov saveV, dx
    cmp oneChar,0Dh
jnz notCR
;change isWord to 1
 mov isWord,1
 call trnInNum
    jmp endProc
notCR:
cmp oneChar,0Ah
jnz notLF
;change isWord to 1
mov isWord,1
    jmp endProc
notLF:
cmp oneChar,20h
jnz notSpace
;chance isWord to 0
mov isWord,0
; go to next position in keys
 mov ax, keyInd
 mov cx, 16
 ;div cx; now ax has number of keys
 shr ax, 4        ; Shift right by 4 position
 inc ax; go to next key 
mul cx; ax has position of next key
mov keyInd,ax
 
    jmp endProc
notSpace:
    cmp isWord, 0
    jnz itsWord
       ;save char to values
       mov si, offset number
       
        mov bx, numberInd
        add si, bx
        mov al, oneChar
        mov [si], al
        inc numberInd
          jmp endProc
itsWord:
    
         ;save char to keys
        mov si, offset keys

        mov bx, keyInd 
        add si, bx
        mov al, oneChar

        mov [si], al
        inc keyInd 
      

endProc:
    ;push dx
    ret
 procChar endp   


trnInNum PROC

    ;mov cx, valInd; value position
    ;dec cx
    
    ;mov si, offset number
    
    ;add si, numberInd; last char of this number
    ;dec si
    xor bx,bx
    mov cx,0
calcNum:

    mov si, offset number
    add si, numberInd; last char of this number
    dec si
    sub si,cx; get next char position
    ;read char
    xor ax,ax
    mov al, [si];load char to ax

    ;test if char is '-'
    cmp ax,45
    jnz notMinus
        neg bx;turn bx into negative number
        jmp afterCalc
    notMinus:        
    sub al,'0'; now we have theoretical number in ax

    ;get realnumber
    push cx
    cmp cx,0
    jnz notZer
    jmp endOFMul
    notZer:
    mulByTen:
    mov dx,10
        mul dx
        dec cx
        cmp cx, 0
        jnz mulByTen

    endOFMul:    
    pop cx
    add bx,ax;add to result
    
    inc cx
    cmp cx, numberInd
    jnz calcNum
afterCalc:    
;save number into values array

  mov si, offset values
  add si, valInd
 
  mov [si],bx;save number into array
  ;increment valInd by 2
  inc valInd
  inc valInd
  mov numberInd,0
  mov cx,0
  fillZeros:
    mov si, offset number
    add si, cx
    mov [si],0
    inc cx
    cmp cx,9
    jnz fillZeros


ret
trnInNum endp
end main



