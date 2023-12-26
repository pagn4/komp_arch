;prigram that disassembles functions mov, out, not, rcr, xlat

;the program doesn's process all the cases of mov
;(also the reading of the file is not very optimal)
;doesn't have any trouble provessing other functions

;helpful resource(26-30p.): https://datasheetspdf.com/pdf-file/544568/Intel/8086/1

;will add a .com file for all cases of mov given by my computer architecture practical lesson lecturer
;(it is called DIS1.COM)


.model small
.stack 100h
.data
    ;messages for bad data + other things(help etc.)
    noInput db "Nieko nebuvo ivesta$", 0
    needHelpMsg db "Jei reikia pagalbos paleisdami programa iveskite /?$", 0
    newLine db 13, 10, '$'
    helpMsg db "Paleisdami programa surasykite ir naudojamus failus, t.y. duomenu faila ir rezultatu faila (atskirtus vienu tarpu)$", 0
    badSpaces db "Ivesti duomenys nera tinkamai atskirti$", 0
    file db "Klaida su failais. Patikrinkite ar jie egzistuoja ir ar juos ivedete gerai.$", 0
    failedRead db "Klaida skaitant faila$", 0
    failedWrite db "Klaida rasant faila$", 0
    ;files
    input db 255 dup('$')
    output db 255 dup('$')
    counter dw 256

    toSee db 255 dup('$') 

    first db "[bx]+[si]", 0
    second db "[bx]+[di]", 0
    third db "[bp]+[si]", 0
    fourth db "[bp]+[di]", 0

    plus db "+", 0
    wIs dw 0
    character dw 0
    thisOne dw 0
    howMuch dw 0
    reg dw 0
    ;commands
    theXlat db "xlat", 0
    theNot db "not ", 0
    theMov db "mov ", 0
    theOut db "out ", 0
    theRcr db "rcr ", 0
    theVOID db "Komanda nerasta", 0
    siStart dw 0
    ; comma + space
    seperate db ", ", 0
    hhh db "h",0
    uno db "1", 0
    wasMov dw 0
    bracket db "[",0
    bracketEnd db "]", 0
    ;16 bits    w=1
    theAx db "ax", 0
    theCx db "cx", 0
    theDx db "dx", 0
    theBx db "bx", 0
    theSp db "sp", 0
    theBp db "bp", 0
    theSi db "si", 0
    theDi db "di", 0

    zero db "0", 0
    ;8-bit      w=0
    theAl db "al", 0
    theCl db "cl", 0
    theDl db "dl", 0
    theBl db "bl", 0
    theAh db "ah", 0
    theCh db "ch", 0
    theDh db "dh", 0
    theBh db "bh", 0

    ;segments
    theEs db "es", 0
    theCs db "cs", 0
    theSs db "ss", 0
    theDs db "ds", 0

    fileIn dw 0
    fileOut dw 0

    siLeft dw 0
    siBegin dw 0
    wasRead db 60000 dup ('$')

    wasSpace dw 0
.code
start:
    mov ax, @data
    mov ds, ax

    ;processing file names given via command line when runing the program
    mov	ch, 0			
	mov	cl, [es:0080h]
	cmp	cx, 0
	je	nothingEntered	

    mov bx, 0081h
    mov di, offset input
    read:
        mov al, [es:bx]

        cmp al, 32
        je processSpaces
        

        goOn:

        ;checking if there is "/?" to see if the user needs help
        cmp al, 47
        je checkForHelp
        noHelp:

        ;checking if there are no more characters
        cmp al, 13
        je finish

        mov [di], al
        inc di
        processed:
        inc bx
        jmp read

    finish:

    mov al, 0
    mov [di], al

    jmp step2

exit:
    mov ax, 4c00h
    int 21h


;output if nothing has been entered when running the program 
nothingEntered:
    mov ah, 9
    mov dx, offset noInput
    int 21h
    mov ah, 9 
    offerHelp:
    mov dx, offset newLine
    int 21h
    mov ah, 9
    
    mov dx, offset needHelpMsg
    int 21h
    jmp exit

;checking if there was "/?" entered
checkForHelp:
    inc bx
    mov al, [es:bx]
    cmp al, 63
    je helpNeeded
    dec bx
    mov al, [es:bx]
    jmp noHelp

;output for the case where the user wrote "/?"
helpNeeded:
    mov ah, 9
    mov dx, offset helpMsg
    int 21h
    jmp exit

;output for when the spaces between the file names was more than one
badPlacedSpaces:
    mov ah, 9
    mov dx, offset badSpaces
    int 21h
    jmp offerHelp

;processing spaces between perameters entered
; if it is the first space nothing has to be done
; if it is the second space we need to continue writing the upcoming perameter as the output name
; if it is the third space we see that it perameters were input in a wrong way 
processSpaces:
    push ax
    mov ax, [wasSpace]
    inc ax
    mov [wasSpace], ax
    cmp ax, 3
    je badPlacedSpaces
    cmp ax, 1
    je done 
    mov al, 0
    mov [di], al
    mov di, offset output

    done:
    pop ax
    jmp processed

;___________________________________________________
;finished reading input by user. Time to read files
;___________________________________________________
step2:
    ;open input file
    mov ax, 3d00h
    mov dx, offset input
    int 21h
    jc badFile
    mov [fileIn], ax

    ;open output file
    mov ax, 3c00h
    xor cx, cx
    mov dx, offset output
    int 21h
    jc badFile
    mov [fileOut], ax

    readLoop:
        ;reading 
        mov bx, fileIn
        ;reading
        mov ah, 3fh
        mov cx, 60000
        mov dx, offset wasRead
        int 21h
        jc readError


        or ax, ax
        jz getOut
        
        mov si, offset wasRead
        mov [siBegin], si
        mov [siStart], si
        add [siBegin], ax
        call checking

    jmp readLoop

   
    getOut: 

    jmp exit

;output for trouble when opening files
badFile:
    mov ah, 9
    mov dx, offset file
    int 21h
    jmp offerHelp


;errors when writing or reading the files 
readError:
    mov ah, 9
    mov dx, offset failedRead
    int 21h
    jmp exit


writeError:
    mov ah, 9
    mov dx, offset failedWrite
    int 21h
    jmp exit

back:
jmp readLoop

proc checking


    


    goCheck:
 
    
    ;(last minute changes might not be well done)
    ;outputing the positions of each command starting with 100h

    mov ax, [counter]
    add ax, si
    sub ax, [siStart]

    mov [counter], ax
    mov [thisOne], ax
    call getHex8

    call sep




    mov dl, [si]

    ;check for xlat
        cmp dl, 215
        jne checkNot
        mov cx, 4
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset theXlat
        int 21h
        jc writeError
        jmp found

    ;check for not
    checkNot:
        cmp dl, 246
        jne checkNot2
        mov cx, 4
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset theNot
        int 21h
        jc writeError
        mov wIs, 0
        inc si
        mov dl, [si]
        sub dl, 16
        call modxxxrm
        jmp found
        checkNot2:
        cmp dl, 247
        jne checkOut
        mov cx, 4
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset theNot
        int 21h
        ;jc writeError
        mov wIs, 1
        inc si
        mov dl, [si]
        sub dl, 16
        call modxxxrm
        jmp found
        

    ;check for out
    checkOut:
        cmp dl, 238
        je yes
        cmp dl, 239
        je yes 
        jmp checkOut2
        yes:
            sub dl, 238
            mov wIs, 0
            cmp dl, 1
            jne stay
            mov wIs, 1
            stay:
            mov cx, 4
            mov bx, fileOut
            mov ah, 40h
            mov dx, offset theOut
            int 21h  

            call printDx
            call sep
            cmp wIs, 0
            jne big
            call printAl
            jmp f
            big:
            call printAx
            f:
            jmp found 
        checkOut2:
            cmp dl, 230
            je yes2
            cmp dl, 231
            je yes2
            jmp checkRcr
                yes2:
                sub dl, 230
                mov wIs, 0
                cmp dl, 1
                jne stay2
                mov wIs, 1
                stay2:
                inc si
                mov dl, [si]
                mov [thisOne], dx
                mov cx, 4
                mov bx, fileOut
                mov ah, 40h
                mov dx, offset theOut
                int 21h
                call getHex8
                 
                mov cx, 1
                mov bx, fileOut
                mov ah, 40h
                mov dx, offset hhh
                int 21h
                call sep
                cmp wIs, 1
                je bigger
                call printAl
                jmp found
                bigger:
                call printAx
                jmp found


    ;check for rcr
    checkRcr:
        
        cmp dl, 210
        jne notRcr1
        mov [wIs], 0
        call doRcr1
        call printCl
        jmp found
        notRcr1:
        cmp dl, 211
        jne rcr2
        mov [wIs], 1
        call doRcr1
        call printCl
        jmp found
        rcr2:
        cmp dl, 208
        jne notRcr3
        mov [wIs], 0
        call doRcr1
        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset uno
        int 21h
        jmp found
        notRcr3:
        cmp dl, 209
        jne checkMov
        mov [wIs],1 
        call doRcr1
        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset uno
        int 21h
        
        jmp found

    ;checking movs
    checkMov:
        mov [siLeft], si
        mov wasMov, 0
        call checkingTheMovs
        cmp [siLeft], si
        je nothingLeft
        
        jmp found
    ;if none of the checked commands were found output that we didn't recognise it
    nothingLeft:
        mov cx, 15
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset theVOID
        int 21h
        jc writeError2

    ;adding new line after every comand with its perameters when found or after nothing was found
    found:
        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset newLine
        int 21h
        jc writeError2

    jmp incSi
   
;moving on to the next byte
incSi:
    
    inc si
    cmp si, [siBegin]
    jae n
    jmp goCheck
    n:
    ret
checking endp



writeError2:
    mov ah, 9
    mov dx, offset failedWrite
    int 21h
    jmp exit




; processing the case where byte is:    mod xxx r/m
proc modxxxrm

    cmp dl, 192
    jae registers
    jmp other



        registers:
        sub dl,192
        cmp wIs, 1
        je bit16


        cmp wIs, 0
        je bit8


        ret
        ;outputing registers for when it is 8bit
        bit8:
             cmp dl, 0
                jne eight2
                call printAl
                ret
            eight2:
                cmp dl, 1
                jne eight3
                call printCl
                ret
            eight3:
                cmp dl, 2
                jne sixteen4
                call printDl
                ret
            eight4:
                cmp dl, 3
                jne eight5
                call printBl
                ret
            eight5:
                cmp dl, 4
                jne eight6
                call printAh
                ret
            eight6:
                cmp dl, 5
                jne eight7
                call printCh
                ret
            eight7:
                cmp dl, 6
                jne eight8
                call printDh
                ret
            eight8:
                call printBh
                ret

        ;outputing registers for when it is 16bit
        bit16:
                cmp dl, 0
                jne sixteen2
                call printAx
                ret
            sixteen2:
                cmp dl, 1
                jne sixteen3
                call printCx
                ret
            sixteen3:
                cmp dl, 2
                jne sixteen4
                call printDx
                ret
            sixteen4:
                cmp dl, 3
                jne sixteen5
                call printBx
                ret
            sixteen5:
                cmp dl, 4
                jne sixteen6
                call printSp
                ret
            sixteen6:
                cmp dl, 5
                jne sixteen7
                call printBp
                ret
            sixteen7:
                cmp dl, 6
                jne sixteen8
                call printSi
                ret
            sixteen8:
                call printCx
                ret

    other:
        mov al, dl
        and al, 11111000B
        sub dl, al

        cmp dl, 0
        jne m1
        call one
        jmp checkMod
        m1:
        cmp dl, 1
        jne m2
        call two
        jmp checkMod
        m2:
        cmp dl, 2
        jne m3
        call three
        jmp checkMod
        m3:
        cmp dl, 3
        jne m4
        call four
        jmp checkMod
        m4:
        cmp dl, 4
        jne m5
        call bracketf
        call printSi
        call bracketb
        jmp checkMod
        m5:
        cmp dl, 5
        jne m6
        call bracketf
        call printDi
        call bracketb
        jmp checkMod
        m6:
        cmp dl, 7
        jne m7
        call bracketf
        call printBx
        call bracketb
        jmp checkMod
        m7:
            mov dl, [si]
            mov al, dl
            and al, 11000000B
            cmp al, 00000000B
            jne tohere
            call bracketf
                inc si
                inc si
                xor dx, dx
                mov dl, [si]
                xor ax, ax
                mov ax, dx
                mov [thisOne], ax
                call getHex8
                xor dx,dx
                dec si
                mov dl, [si]
                xor ax, ax
                mov ax, dx
                mov [thisOne],ax

                call getHex8
                inc si

                mov cx, 1
                mov bx, fileOut
                mov ah, 40h
                mov dx, offset hhh
                int 21h  
                call bracketb              
                ret
            ret
            tohere:
            call bracketf
            call printBp
            call bracketb
        

        checkMod:
            mov dl, [si]
            mov al, dl
            and al, 11000000B
            cmp al, 00000000B
            jne nextMod
            ret
            nextMod:
            call ppp
            cmp al, 01000000B
            jne to16
            jmp to8
             ret
            to16:
                
                inc si
                inc si
                xor dx, dx
                mov dl, [si]
                xor ax, ax
                mov ax, dx
                mov [thisOne], ax
                call getHex8
                dec si
                xor dx, dx
                mov dl, [si]
                xor ax, ax
                mov ax, dx
                mov [thisOne],ax

                call getHex8
                inc si

                mov cx, 1
                mov bx, fileOut
                mov ah, 40h
                mov dx, offset hhh
                int 21h                
                ret

            to8:
                xor ax, ax
                xor dx,dx
                inc si
                mov dl, [si]
                mov ax, dx

                mov [thisOne], ax
                call getHex8
                mov cx, 1
                mov bx, fileOut
                mov ah, 40h
                mov dx, offset hhh
                int 21h    


            ret
modxxxrm endp

;some printing functions for easier ouput
proc ppp
    mov cx, 1
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset plus
    int 21h
    ret
ppp endp

proc one
    mov cx, 9
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset first
    int 21h
    ret
one endp

proc two
    mov cx, 9
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset second
    int 21h
    ret
two endp

proc three
    mov cx, 9
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset third
    int 21h
    ret
three endp

proc four
    mov cx, 9
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset fourth
    int 21h
    ret
four endp







;printing registers and other stuff
proc printAx
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theAx
    int 21h
    ret
printAx endp
proc printCx
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theCx
    int 21h
    ret
printCx endp
proc printDx
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theDx
    int 21h
    ret
printDx endp
proc printBx
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theBx
    int 21h
    ret
printBx endp
proc printSp
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theSp
    int 21h
    ret
printSp endp
proc printBp
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theBp
    int 21h
    ret
printBp endp
proc printSi
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theSi
    int 21h
    ret
printSi endp
proc printDi
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theDi
    int 21h
    ret
printDi endp
proc printAl
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theAl
    int 21h
    ret
printAl endp
proc printCl
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theCl
    int 21h
    ret
printCl endp
proc printDl
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theDl
    int 21h
    ret
printDl endp
proc printBl
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theBl
    int 21h
    ret
printBl endp
proc printAh
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theAh
    int 21h
    ret
printAh endp
proc printCh
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theCh
    int 21h
    ret
printCh endp
proc printDh
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theDh
    int 21h
    ret
printDh endp
proc printBh
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theBh
    int 21h
    ret
printBh endp
proc printEs
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theEs
    int 21h
    ret
printEs endp
proc printCs
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theCs
    int 21h
    ret
printCs endp
proc printSs
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theSs
    int 21h
    ret
printSs endp
proc printDs
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theDs
    int 21h
    ret
printDs endp

proc sep
    mov cx, 2
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset seperate
    int 21h
ret
sep endp

;converting dec to hex
proc getHex8
    mov cx, 0
    try:
        
        mov ax, [thisOne]
        add cx, 1

        xor dx, dx
        mov bx, 16
        div bx

        mov [thisOne], ax

        add dx, '0'
        cmp dx, '9'
        jbe gud
        add dx, 7
        gud:
        push dx

        cmp ax, 16
        jb last
        jmp try

    last:
        add ax, '0'
        cmp ax, '9'
        jbe gud2
        add ax, 7
        gud2:
        push ax

    printing:
        xor ax, ax
        pop ax

        cmp ax, '0'
        jb outtt
        cmp ax, 'F'
        ja outtt

        cmp ax, '9'
        jbe allGood
        cmp ax, 'A'
        jae allGood
        jmp outtt

        allGood:

        mov [character], ax

        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset character
        int 21h
      
        

        jae printing
        
    outtt:
   push ax
    ret

getHex8 endp
  
;processing rcr command
proc doRcr1
        mov cx, 4
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset theRcr
        int 21h

        inc si
        mov dl, [si]
        sub dl, 24
        call modxxxrm
        call sep

        ret

doRcr1 endp

;function to print "mov "
proc printMov
    mov cx, 4
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset theMov
    int 21h
    jc writeError3
    ret
printMov endp

; printing ():
proc bracketf
    mov cx, 1
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset bracket
    int 21h
    jc writeError3
    ret
bracketf endp
proc bracketb
    mov cx, 1
    mov bx, fileOut
    mov ah, 40h
    mov dx, offset bracketEnd
    int 21h
    jc writeError3
ret
bracketb endp
writeError3:
    mov ah, 9
    mov dx, offset failedWrite
    int 21h
    jmp exit

;checking if it's mov function
proc checkingTheMovs

    mov al, dl
    and al, 10110000B
    cmp al, 10110000B
    
    je c
    jmp case2
    c:

    call printMov
    
    mov wIs, 0
    mov dl ,[si]
    mov al, dl
    and al, 00001000B
    cmp al, 00001000B
    jne w1
    mov wIs, 1
    w1:
    mov al, 192
    and dl, 00000001B
    add al, dl
    mov dl, [si]
    and dl, 00000010B
    add al, dl
    mov dl, [si]
    and dl, 00000100B
    add al, dl
    mov dl,al 
    call modxxxrm
    call sep
    xor dx, dx
    cmp wIs, 0
    jne sixteeen
    inc si
    mov dl, [si]
    mov [thisOne], dx
    call getHex8
    jmp letterh
    sixteeen:
    inc si
    inc si
    mov dl, [si]
    mov [thisOne], dx
    call getHex8
    xor dx, dx
    dec si
    mov dl, [si]
    mov [thisOne], dx
    call getHex8
    inc si
    letterh:
    mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset hhh
        int 21h
    ret
    case2:
        mov dl, [si]
        mov al, dl
        mov wIs, 0
        cmp al, 11000110B
        je aha
        cmp al, 11000111B
        jne case3
        mov wIs, 1
        aha:
            call printMov       
            inc si
            mov dl, [si]
            call modxxxrm
            call sep
            cmp wIs, 1
            je w2
            inc si
            mov dl, [si]
            call getHex8
            jmp ddd
            w2:
            inc si
            inc si
            mov dl, [si]
            call getHex8
            dec si
            mov dl, [si]
            call getHex8
            inc si 
            ddd:
            mov cx, 1
            mov bx, fileOut
            mov ah, 40h
            mov dx, offset hhh
            int 21h
            ret
    case3:
        mov dl, [si]
        mov al, dl
        cmp dl, 10001110B
        jne case4
        call printMov
    
        inc si
        mov dl, [si]
        mov al, dl
        and al, 00011000B
        sub dl, al
        
        cmp al, 00000000B
        jne n1
        call printEs
        jmp n4
        n1:
        cmp al, 00001000B
        jne n2
        call printCs
        jmp n4
        n2:
        cmp al, 00010000B
        jne n3
        call printSs
        jmp n4
        n3:
        call printDs
        n4:
        call sep
        mov wIs, 1
        mov dl, [si]
        mov al, dl
        and al, 00011000B
        sub dl, al
        call modxxxrm
        ret

    case4:
        mov dl, [si]
        mov al, dl
        cmp al, 10001100B
        jne case5
        call printMov
        inc si
        mov dl, [si]
        mov al, dl
        and al, 00011000B
        sub dl, al
        mov wIs, 1
        call modxxxrm
        call sep
        mov dl, [si]
        mov al, dl
        and al, 00011000B

        cmp al, 00000000B
        jne nn1
        call printEs
        jmp nn4
        nn1:
        cmp al, 00001000B
        jne nn2
        call printCs
        jmp nn4
        nn2:
        cmp al, 00010000B
        jne nn3
        call printSs
        jmp nn4
        nn3:
        call printDs
        nn4:
        ret
    case5:
        mov dl, [si]
        cmp dl, 10001000B
        jne yesw
        mov wIs, 0
        yesw:
        cmp dl, 10001001B
        jne otherWay
        mov wIs, 1
        call printMov
        inc si
        mov dl, [si]
        mov al, dl
        and al, 00111000B
        sub dl, al
        call modxxxrm
        call sep
        mov ah, 0
        mov bl, 8
        div bl
        add al, 192
        mov dl, al 
        call modxxxrm
        
        otherWay:
        mov dl, [si]
        cmp dl, 10001010B
        jne yesww
        mov wIs, 0
        yesww:
        cmp dl, 10001011B
        jne case6
        mov wIs, 1
        call printMov
        inc si
        mov dl, [si]
        mov al, dl
        and al, 00111000B
        mov ah, 0
        mov bl, 8
        div bl
        add al, 192
        mov dl, al 
        call modxxxrm
        call sep
        mov dl, [si]
        xor ax, ax
        mov al, dl
        and al, 00111000B
        sub dl, al
        call modxxxrm
        ret


    case6:
        mov dl, [si]
        mov al, dl
        cmp al, 10100000B
        jne longer
        call printMov
        call printAx
        call sep
        call bracketf
        inc si
        xor ax, ax
        mov dl, [si]
        mov al, dl
        mov [thisOne], ax
        call getHex8
        jmp theh
        longer:
        cmp al, 10100001B
        jne case7
        call printMov
        call printAx
        call sep
        call bracketf
        inc si
        inc si
        xor ax, ax
        mov dl, [si]
        mov al, dl
        mov [thisOne], ax
        call getHex8
        dec si
        xor ax,ax
        mov dl, [si]
        mov al, dl
        mov [thisOne], ax
        call getHex8
        inc si
        theh:
        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset hhh
        int 21h
        call bracketb
        ret
    case7:
        mov dl, [si]
        mov al, dl
        cmp al, 10100010B
        jne longerr
        call printMov
        
        call bracketf
        inc si
        xor ax, ax
        mov dl, [si]
        mov al, dl
        mov [thisOne], ax
        call getHex8
        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset hhh
        int 21h
        call bracketb
        call sep
        call printAx
        ret
        
        longerr:
        cmp al, 10100011B
        jne noMore
        call printMov
        
        call bracketf
        inc si
        inc si
        xor ax, ax
        mov dl, [si]
        mov al, dl
        mov [thisOne], ax
        call getHex8
        dec si
        xor ax,ax
        mov dl, [si]
        mov al, dl
        mov [thisOne], ax
        call getHex8
        mov cx, 1
        mov bx, fileOut
        mov ah, 40h
        mov dx, offset hhh
        int 21h
        call bracketb
        inc si
        call sep
        call printAx
        

noMore:

    ret
checkingTheMovs endp



end start