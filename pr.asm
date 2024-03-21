.model small
.stack 100h

.data
filename  db "in.txt", 0
mes db "Succ $"
mesBad db "File error $"
handle dw 0

buffInd db 0; Index to keep track of the current position in buffer
oneChar db 0

presInd dw 0
newInd dw 0
keys db 10000*16 dup(0)
keyInd dw 0
keyTemp db 16 dup(0)
keyTempInd dw 0
isWord db 1
values dw 10000*8 dup(0)
valInd dw 0
number db 16 dup(0)
numberInd dw 0
quantity db 100 dup(0)

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
     ;   mov si, offset number
     ;   dec numberInd
    ;   mov bx, numberInd
;
    ;    add si, bx
    ;    mov al, 0
    ;    mov [si], al
    ;    call trnInNum
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
 ;mov ax, keyInd
 ;mov cx, 16
 ;div cx; now ax has number of keys
 ;shr ax, 4        ; Shift right by 4 position
 ;inc ax; go to next key 
;mul cx; ax has position of next key
;mov keyInd,ax
 ;check if key exists
    call checkKey
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
        ;mov si, offset keys
       ; mov bx, keyInd 
       ; add si, bx
       ; mov al, oneChar
       ; mov [si], al
       ; inc keyInd 
        ;add char to KeyTemp
        mov si, offset keyTemp
        mov bx, keyTempInd 
        add si, bx
        mov al, oneChar
        mov [si], al
        inc keyTempInd 
      

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
  mov ax, presInd
  shl ax, 1  ; calc real index in values
  add si, ax
  add bx, [si];add previously saved number
  mov [si],bx;save number into array
  ;increment valInd by 2
  ;inc valInd
  ;inc valInd
  mov numberInd,0
  mov cx,0
  ;fill number by 0
  fillZeros:
    mov si, offset number
    add si, cx
    mov [si],0
    inc cx
    cmp cx,9
    jnz fillZeros

ret
trnInNum endp

checkKey proc
    mov ax,0
    mov bx, 0; presence of key
    mov cx, 0
    mov dx,0
    ;check if keyInd is 0
    cmp newInd,0
    jnz findKey
jmp addNewKey  
    findKey:
    mov dx,0
        checkPresKey:
        mov si, offset keys
        shl cx, 4
        add si, cx
        shr cx,4
        add si, dx; next char offset
        mov al,[si]; next char
        mov di, offset keyTemp
        add di,dx
        mov ah, [di]; next char in keyTemp
        cmp al,ah
        jne notEqualChar
            mov bx,1; this char present in current key
            jmp contComp
            notEqualChar:
            mov bx,0; this char dont present in current key
            mov dx, 15; go to next key
        contComp:
            inc dx
            cmp dx,16
            jnz checkPresKey
        ;check if key is present   
    cmp bx,0
    jnz keyPresent 
    inc cx
    cmp cx, newInd
    jne findKey
 ;   new key
    ;add new key to key array
    mov cx, 0  ; counter
    addNewKey:
    
    mov si, offset keyTemp   ; addr of source
    add si, cx
    mov di, offset keys  ; addr of dest
    mov ax,  newInd
    shl ax,4 
    add di,cx
    add di, ax ; addr of dest
    mov al, [si]
    mov [di], al 
    inc cx
    cmp cx, 16
    jnz addNewKey
     mov cx, newInd
    mov presInd,cx
    inc newInd
   
    ; set new 1 to array of quantities

     ;add to quantity one
    mov si, offset quantity
    add si, presInd
    mov al,1
    mov [si],al
    jmp endOfCheck;goto end

keyPresent:
    ;key index in cx
    ;add 1 to this index
    mov presInd,cx
    ;add to quantity one
    mov si, offset quantity
    add si, presInd
    mov al, [si]
    inc al
    mov [si],al
endOfCheck:
   ;fill temp key by 0
    mov keyTempInd,0
    mov cx,0
  fillZeroskey:
    mov si, offset keyTemp
    add si, cx
    mov [si],0
    inc cx
    cmp cx,15
    jnz fillZeroskey  
    ret
checkKey endp
end main



