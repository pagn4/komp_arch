;27 Parašykite programą, kuri įveda simbolių eilutę
;ir atspausdina rastų mažųjų ASCII raidžių skaičių. 
;Pvz.: įvedus abs 52d4 turi atspausdinti 4
.model small
.stack 100h
.data
    endl db 0dh, 0ah, 24h
    buff db 255, ?, 255 dup(?)
.code

start:
    mov ax, @data
    mov ds, ax

    mov ah, 0ah
    mov dx, offset buff
    int 21h

    mov ah, 9
    mov dx, offset endl
    int 21h

    mov bx, offset buff+2
    xor cx,cx
    
    mov cl, [buff+1]
    l:
        mov al, [bx]
        cmp al, 'a'
        jb nope
        cmp al, 'z'
        ja nope

    

        nope:
        mov [bx], al
    loop l
    mov ah, 40h
    mov bx, 1
    xor cx, cx
    mov cl, [buff+1]
    mov dx, offset buff+2
    int 21h

    mov ax, 04C00h
    int 21h
end start
