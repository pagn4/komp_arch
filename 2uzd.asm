;Parašykite programą, skaitančią pirmuoju parametru
;pateikiamą failą ir sukeičiančią vietomis antruoju
;bei trečiuoju parametrais nurodomas failo eilutes.

.model small
.stack 100h
.data
    ;messeges:
    msgNothingEntered db "jokie perametrai nebuvo ivesti$", 0
    outputName db "rezults.txt", 0
    notGood db "perametrai ivesti klaidingai$"
    lackLines db "faile yra per mazai eiluciu$"
    fFile db "fail'inimas su failais$"
    char db 1 dup ('$') ; reading from file(one by one character)
    ;the file name given by the user is saved here
    inputName db 255 dup ('$')
    ;the lines which have to be swaped are saved here
    firstSwap db 255 dup('$')
    secondSwap db 255 dup('$')
    ;file descriptor numbers
    fileIn dw 0
    fileOut dw 0
    ;sawing the places in witch the last character was writen for each line to be swaped
    carryPlace1 dw 0
    carryPlace2 dw 0
    ;has it already been writen in a swaped possition. y-1, n-0
    done1 dw 0
    done2 dw 0
    ;how many bytes will each line to be swaped has 
    b1 dw 0
    b2 dw 0
    ;counter for the amount of lines in file
    linesIn dw 1
    ;counting the amount spaces between the perameters
    spaces dw 0
    ;which lines are to be swaped
    line1 dw 0
    line2 dw 0
.code
start:
    mov ax, @data
    mov ds, ax
    ;beggining to read what the user writes when starting the program
    MOV	ch, 0			
	MOV	cl, [es:0080h]
	CMP	cx, 0
	JE	nothingEntered		
	MOV	bx, 0081h
    mov di, offset inputName; index for where to write the file name
    input:
        mov al, [es:bx]
        ;see if its the end of input ascii 13
        cmp al, 13
        je finish
        ;save number 2 if its already the third character(counted by spaces)
        cmp spaces, 3
        je num2
        ;if it's a space we count it
        cmp al, ' '
        je space
        ;writing the file name inputed
        mov [di], al
        inc di
        
        inc bx
        returnSpace:
    jmp input
    finish:
    
    jmp check
    checked:
    ;file name ends in symbol in ascii 0
    mov al, 0 
    mov [di], al
    jmp workingWithFile


exit:
    mov ax, 4c00h
    int 21h
;if nothing has been entered we cary out this messege    
nothingEntered:
    mov ah, 9
    mov dx, offset msgNothingEntered
    int 21h
    JMP exit
;messege if the input is not correct
badEntry:
    mov ah, 9
    mov dx, offset notGood
    int 21h
    jmp exit
;counting the amount of spaces
space:
    push ax
    mov ax, spaces
    add ax, 1
    mov spaces, ax
    pop ax
    ;seeing if there are not spaces one after another
    inc bx
    mov al, [es:bx]
    cmp al, ' '
    je badEntry
    ;if there have already been 2 spaces we save the first number 
    cmp spaces, 2
    je num1
    
    jmp returnSpace
;checks if it is a number + saves it not as ascii symbols
num1:
    more1:
        cmp al, '0' ;checking if its a number
        jb badEntry
        cmp al, '9'
        ja badEntry
        ;saving it by multiplying the line1 by 10 
        mov ax, [line1]
        mov cx, 10
        mul cx
        jc bad
        ;making a number out of ascii symbol
        push ax
        mov al, [es:bx]
        sub al, 48
        mov cl, al
        pop ax
        ;finishing the line1*10+currentNumber
        add ax, cx
        jc badEntry
        mov [line1], ax
        
        inc bx
        mov al, [es:bx]
        cmp al, ' '
        jne more1;repeat until space
    jmp space    

bad:
jmp badEntry
;working on number 2 from the input 
num2:
    ;prety much the same as num2 counting
    cmp al, '0'
    jb badEntry
    cmp al, '9'
    ja badEntry

    mov ax, [line2]
    mov cx, 10
    mul cx
    jc bad
    push ax
    mov al, [es:bx]
    sub al, 48
    mov cl, al
    pop ax

    add ax, cx
    jc bad
    mov [line2], ax
    
    inc bx
    jmp returnSpace

check:
    ;checking if numbers of the lines to be swaped are not equal to eachother, or they aren't both 0
    mov ax, line2
    cmp line1, ax
    je bad

    cmp ax, 0
    je bad
    
    cmp line1, 0
    je bad

    jmp checked

;_______________________________________________
;           FILES  pt. 1
;_______________________________________________
workingWithFile:

    ;opening file for reading
    mov ax, 3d00h
    mov dx, offset inputName
    int 21h
    jc error
    mov [fileIn], ax
    mov bx, ax

    ;saving the indexes for where to write the information for the line to be swaped 
    mov di, offset firstSwap
    mov carryPlace1, di

    mov di, offset secondSwap
    mov carryPlace2, di

    readLoop1:
        ;reading
        mov ah, 3fh
        mov cx, 1
        mov dx, offset char
        int 21h
        jc error
        ;seeing if it's still reading something
        or ax, ax
        jz getOut
        ;if it's a newline we go count it
        cmp [char], 10
        je addLine
        ;checking if current line is one of the lines we want to swap 
        push ax
        mov ax, linesIn
        cmp line1, ax
        je number1
        cmp line2, ax
        je number2
        goOn:
        pop ax

        cmback:
    jmp readLoop1

    getOut:

    ;close reading file
    mov ah, 3Eh
    mov bx, fileIn
    int 21h
    jc error
    ;seeing the lines to be swaped are withing range of total lines in the file
    mov ax, linesIn
    add ax, -1
    cmp line1, ax
    ja notEoughLines
    cmp line2, ax
    ja notEoughLines

    jmp startSwitching
;exit that can be reached from the bottom by jump
closerExit:
    mov ax, 4c00h
    int 21h
;error message output
error:
    mov ah, 9
    mov dx, offset fFile
    int 21h
    jmp closerExit
;counting the amount of lines
addLine:
    push ax
    mov ax, linesIn
    add ax, 1
    mov linesIn, ax
    pop ax
    jmp cmback
;message if there are not enough lines in the file
notEoughLines:
    mov ah, 9
    mov dx, offset lackLines
    int 21h
    jmp closerExit
;saving line no. 1 (every one symbol)
number1:
    mov di, carryPlace1
    mov al, [char]
    mov [di], al
    inc di
    mov carryPlace1, di
    mov ax, b1
    add ax, 1
    mov b1, ax

    jmp goOn
;saving line no. 2
number2:
    mov di, carryPlace2
    mov al, [char]
    mov [di], al
    inc di
    mov carryPlace2, di
    mov ax, b2
    add ax, 1
    mov b2, ax
    jmp goOn

;---------------------------------------------------------
;               STARTING THE OUTPUT
;---------------------------------------------------------
startSwitching:
    mov linesIn, 1

    ;open file for reading
    mov ax, 3d00h
    mov dx, offset inputName
    int 21h
    jc error
    mov [fileIn], ax
    mov bx, ax
    ;open file for writing
    mov ax, 3c00h
    xor cx, cx
    mov dx, offset outputName
    int 21h
    jc closerError
    mov fileOut, ax

    readLoopFinal:
        mov bx, fileIn
        mov ah, 3fh
        mov cx, 1
        mov dx, offset char
        int 21h
        jc closerError
        ;seeing if it is the end of the file
        or ax, ax
        jz done
        ;counting the lines
        cmp [char], 10
        je addLinef
        
        push ax
        
        ;if it is not the line we need to swap with we jump to the place to check if it's the second line
        mov ax, [linesIn]
        cmp line1, ax
        jne nextLine
        ;if it is the line to be swaped and it has not been done yet we jump to write it to the file
        mov ax, [done1]  ;has it already been done?
        cmp ax, 0
        jne g
        ;if it passes all this we go write it to file
        add ax, 1
        mov done1, ax 
        
        jmp writeSwap2

        ;same as checking for the other line 
        nextLine:
        mov ax, [linesIn]
        cmp line2, ax
        jne go

        mov ax, [done2]
        cmp ax, 0
        jne g
        add ax, 1
        mov done2, ax
        
        jmp writeSwap1

        cmbacky:
        go:
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset char
        int 21h
        jc closerError

        g:
        pop ax

    jmp readLoopFinal

    done:

    jmp closerExit

;error output which is closer and not out of jump
closerError:
    mov ah, 9
    mov dx, offset fFile
    int 21h
    jmp closerExit
;count the lines
addLinef:
    push ax
    mov ax, linesIn
    add ax, 1
    mov linesIn, ax
    pop ax
    jmp cmbacky
;swaping begin
writeSwap2:
    mov cx, b2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset secondSwap
    int 21h
    jc closerError

    jmp g

writeSwap1:
    mov cx, b1
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset firstSwap
    int 21h
    jc closerError

    jmp g


end start
