.model small
.stack 100h

.data
oneChar db 0
presInd dw 0
newInd dw 0
keys db 10000*16 dup(0)
keyTemp db 16 dup(0)
keyTempInd dw 0
isWord db 1
values dw 10000 dup(0)
number db 16 dup(0)
numberInd dw 0
quantity dw 8100 dup(0)

.code
main proc
    mov ax, @data
    mov ds, ax

;read stdin and put characters into keyTemp or number
read_next:
    mov ah, 3Fh
    mov bx, 0  ; file handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read
    ; do something with [oneChar]

    ;save ax
    push ax

    call procChar ;process char
pop ax
    or ax,ax
    jnz read_next
;remove last char in number
    mov si, offset number
    dec numberInd
    add si, numberInd
    mov [si],0
    ;turn it into number
    call trnInNum
 ;calculate average value
 call calcAvr   
 call sortArr
 call writeArrays
ending:
mov ax, 4C00h
    int 21h
main endp


procChar proc
    ;pop dx; save adress to dx
    ;mov saveV, dx
    cmp oneChar,0Dh
jnz notCR
;change isWord to 1
cmp isWord,0
jne endProc
mov isWord,1
 call trnInNum
    jmp endProc
notCR:
cmp oneChar,0Ah
jnz notLF
;change isWord to 1

cmp isWord,0
jnz endProc
mov isWord,1
 call trnInNum
    jmp endProc
notLF:
cmp oneChar,20h
jnz notSpace
;chance isWord to 0
mov isWord,0
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
        mov si, offset keyTemp
        mov bx, keyTempInd 
        add si, bx
        mov al, oneChar
        mov [si], al
        inc keyTempInd 
      

endProc:
    ret
 procChar endp   


trnInNum PROC
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
    mov cx, presInd
    shl cx,1
    add si, cx
    mov ax,1
    mov [si],ax
    jmp endOfCheck;goto end

keyPresent:
    ;key index in cx
    ;add 1 to this index
    mov presInd,cx
    ;add to quantity one
    mov si, offset quantity
    mov cx, presInd
    shl cx,1
    add si, cx
    mov ax, [si]
    inc ax
    mov [si],ax
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


calcAvr proc

mov cx,0;counter
calcAv:
mov si, offset values
shl cx,1
add si,cx; next number

mov di, offset quantity
add di, cx;present quantity of this number
shr cx,1
mov ax, [si]; mov number to ax
mov bx, [di]; mov quantity to dx
mov dx,0
div bx; get average of these numbers
mov [si], ax; put average to values
inc cx
cmp cx, newInd
jnz calcAv

ret
calcAvr endp

writeArrays proc
mov cx,0
makeString:
mov ax,0
mov presInd,ax
mov dx,0
push cx
    mov di, offset quantity
    shl cx,1
    add di,cx;get index of numbers
    mov cx, [di]
    writeKey:
    mov si, offset keys
    mov ax,0
    mov ax, cx; index of cell
    shl ax, 4; real index of cell
    add si, ax
    add si, presInd
    ;write char
    mov ah, 02h
    mov bx,dx; save counter to bx
    mov dl, [si]
    cmp dl, 0 

    jne notEndOfKey
        jmp gotoNewLine
    notEndOfKey:
    int 21h
    mov dx,bx
    inc presInd
    inc dx
    cmp dx, 16
    jnz writeKey
gotoNewLine:
;go to new line
    mov ah, 02h
mov dl, 0dh
int 21h
 mov ah, 02h
mov dl, 0ah
int 21h
;check if its not the last key-average
pop cx
inc cx
cmp cx, newInd
jnz makeString

ret
writeArrays endp

turnInChar proc
pop dx
pop bx; get index
shl bx,1
mov ax, [values+bx]; get in ax number
cmp ax, 10000
jc positive
    neg ax
positive:
shr bx, 1
push bx
push dx
mov cx,15;number ind
makeChar:
    mov dx,0
    mov bx,10
    div bx; remainder in dx, quontient in ax
    mov si, offset keyTemp
    add si, cx; location to write
    add dx, '0'
    mov [si], dl
    cmp ax, 0
    jnz contSetNumb
        mov bx, 16
        mov numberInd, bx
        sub numberInd, cx
        jmp reverse_number
    contSetNumb:
    dec cx
    cmp cx, -1
    jne makeChar  
;we wrote number into chars
reverse_number:
mov cx, 16
sub cx, numberInd
mov dx,0
reverse:
    mov si, offset keyTemp
    add si, cx
    mov di, offset number
    add di, dx
    mov al,[si]
    mov [di], al
    inc dx
    inc cx
    cmp cx,16
    jnz reverse
ret
turnInChar endp

addMinus proc
mov bx,cx
shl bx,1
mov ax, [values+bx]; get in ax number
cmp ax, 10000
jc positiveVal
    mov ah,02h
    mov dl, '-'
    int 21h
positiveVal:
ret
addMinus endp

sortArr proc
pop dx; save address
;set array of pointers
mov cx,0
fillArrayOfPoint:

    
    mov di, offset quantity
    shl cx,1
    add di,cx
    shr cx,1    
    mov [di],cx;mov to quantity address of next value
    inc cx
    cmp cx, newInd
    jnz fillArrayOfPoint

;sort array of pointers
mov cx, word ptr newInd
    dec cx  ; count-1
outerLoop:
    push cx
    lea si, quantity
innerLoop:
    mov ax, [si];get index
    push ax; remember index of numb
    shl ax,1; get index in values
    add ax,offset values;get address of values
    mov di, ax
    mov ax, [di]
    mov bx, [si+2];get next index
    push bx; remember index of next numb
    shl bx,1; get next index in values
    add bx,offset values
   mov di, bx
    mov bx, [di]
    cmp ax, bx;compare value with next value
    pop bx
    pop ax
    jg nextStep
    xchg bx, ax
    mov [si], ax
    MOV [si+2],bx
nextStep:
    add si, 2
    loop innerLoop
    pop cx
    loop outerLoop
push dx
ret
sortArr endp
end main