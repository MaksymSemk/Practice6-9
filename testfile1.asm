.model small
.stack 100h

.data
src db 10 dup(0)     ; Source array
dest db 10 dup(0)    ; Destination array
oneChar db 1         ; Single character buffer for input from stdin

.code
main proc
    mov cx, 10         ; Set counter to 10

    ; Copy 10 bytes from source to destination
    mov si, offset src   ; Address of source
    mov di, offset dest  ; Address of destination
    cld                   ; Set direction flag to left-to-right
    rep movsb             ; Repeat bytes move until CX = 0

    mov ah, 02h
    mov dl, '1'
    int 21h


main endp
end main