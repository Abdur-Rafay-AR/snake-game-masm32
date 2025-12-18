TITLE Snake Game (snake.asm)

INCLUDE Irvine32.inc

MapWidth EQU 30
MapHeight EQU 20
MapOffsetX EQU 10
MapOffsetY EQU 1
SnakeMaxLen EQU 100

KEY_UP    EQU 48h
KEY_DOWN  EQU 50h
KEY_LEFT  EQU 4Bh
KEY_RIGHT EQU 4Dh

.data
    gameOver    BYTE 0
    score       DWORD 0
    
    snakeX      BYTE SnakeMaxLen DUP(?)
    snakeY      BYTE SnakeMaxLen DUP(?)
    snakeLen    DWORD 3
    
    dirX        SBYTE 1
    dirY        SBYTE 0
    
    foodX       BYTE ?
    foodY       BYTE ?
    
    lastTailX   BYTE ?
    lastTailY   BYTE ?
    didGrow     BYTE 0

    strScore    BYTE "Score: ",0
    strGameOver BYTE "GAME OVER!",0
    strStart    BYTE "Press any key to start...",0
    strWelcomeTitle BYTE "=== SNAKE GAME ===",0
    strWelcomeInstr BYTE "Use Arrow Keys or WASD to move",0
    
    ; ASCII Art Title
    strTitle1   BYTE "   _____ _   _          _  ________ ",0
    strTitle2   BYTE "  / ____| \\ | |   /\\   | |/ /  ____|",0
    strTitle3   BYTE " | (___ |  \\| |  /  \\  | ' /| |__   ",0
    strTitle4   BYTE "  \\___ \\|    | / /\\ \\ |  < |  __|  ",0
    strTitle5   BYTE "  ____) | |\\  |/ ____ \\| . \\| |____ ",0
    strTitle6   BYTE " |_____/|_| \\_/_/    \\_\\_|\\_\\______|",0

    
    ; Menu Strings
    strMenuTitle    BYTE "=== MAIN MENU ===",0
    strMenuOpt1     BYTE "1. Start Game",0
    strMenuOpt2     BYTE "2. Exit",0
    strDiffTitle    BYTE "=== SELECT DIFFICULTY ===",0
    strDiffOpt1     BYTE "1. Easy (Slow, No Obstacles)",0
    strDiffOpt2     BYTE "2. Medium (Normal, Few Obstacles)",0
    strDiffOpt3     BYTE "3. Hard (Fast, Many Obstacles)",0
    strPlayAgain    BYTE "Play Again? (y/n): ",0
    strInvalid      BYTE "Invalid Selection!",0

    symHead     BYTE '@'
    symBody     BYTE 'o'
    symFood     BYTE 'A'
    symWall     BYTE '#'
    symObstacle BYTE 'X'
    
    ; Game Settings
    gameSpeed       DWORD 100
    difficulty      DWORD 1
    
    ; Obstacles
    MAX_OBSTACLES   EQU 20
    obstaclesX      BYTE MAX_OBSTACLES DUP(?)
    obstaclesY      BYTE MAX_OBSTACLES DUP(?)
    obstacleCount   DWORD 0

; Prototypes
DrawFullSnake PROTO
InitGame PROTO
DrawWalls PROTO
DrawGame PROTO
Input PROTO
Logic PROTO
GenerateFood PROTO
ShowGameOver PROTO
MainMenu PROTO
DifficultyMenu PROTO
GenerateObstacles PROTO

.code
main PROC
    call Randomize

MenuLoop:
    INVOKE MainMenu
    cmp al, '2'
    je ExitGame
    
    INVOKE DifficultyMenu
    INVOKE InitGame
    INVOKE GenerateObstacles
    
    INVOKE DrawWalls
    INVOKE DrawFullSnake

GameLoop:
    cmp gameOver, 1
    je EndGameLabel
    
    INVOKE Input
    INVOKE Logic
    INVOKE DrawGame
    
    mov eax, gameSpeed
    call Delay
    
    jmp GameLoop

EndGameLabel:
    INVOKE ShowGameOver
    cmp al, 'y'
    je MenuLoop
    cmp al, 'Y'
    je MenuLoop

ExitGame:
    exit
main ENDP

DrawFullSnake PROC USES eax ecx edx esi
    mov eax, green
    call SetTextColor
    
    movzx eax, foodX
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, foodY
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    mov al, symFood
    call WriteChar
    mov eax, white
    call SetTextColor

    mov eax, lightBlue
    call SetTextColor
    mov ecx, snakeLen
    mov esi, 0
DrawLoop:
    movzx eax, snakeX[esi]
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, snakeY[esi]
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    
    cmp esi, 0
    jne Body
    mov al, symHead
    jmp Print
Body:
    mov al, symBody
Print:
    call WriteChar
    inc esi
    loop DrawLoop
    mov eax, white
    call SetTextColor
    ret
DrawFullSnake ENDP

InitGame PROC
    mov snakeX[0], 20
    mov snakeY[0], 10
    mov snakeX[1], 19
    mov snakeY[1], 10
    mov snakeX[2], 18
    mov snakeY[2], 10
    
    mov snakeLen, 3
    mov dirX, 1
    mov dirY, 0
    mov score, 0
    mov gameOver, 0
    
    INVOKE GenerateFood
    ret
InitGame ENDP

DrawWalls PROC USES eax ecx edx esi
    call ClrScr
    
    mov eax, brown
    call SetTextColor
    
    mov dl, MapOffsetX
    mov dh, MapOffsetY
    call Gotoxy
    mov ecx, MapWidth + 2
L1: mov al, symWall
    call WriteChar
    mov al, ' '
    call WriteChar
    loop L1
    
    mov ecx, MapHeight
    mov dh, MapOffsetY + 1
L2:
    mov dl, MapOffsetX
    call Gotoxy
    mov al, symWall
    call WriteChar
    
    mov dl, (MapWidth + 1) * 2 + MapOffsetX
    call Gotoxy
    mov al, symWall
    call WriteChar
    
    inc dh
    loop L2
    
    mov dl, MapOffsetX
    mov dh, MapHeight + 1 + MapOffsetY
    call Gotoxy
    mov ecx, MapWidth + 2
L3: mov al, symWall
    call WriteChar
    mov al, ' '
    call WriteChar
    loop L3
    
    ; Draw Obstacles
    cmp obstacleCount, 0
    je SkipObsDraw
    
    mov eax, lightRed
    call SetTextColor
    
    mov ecx, obstacleCount
    mov esi, 0
DrawObsLoop:
    movzx eax, obstaclesX[esi]
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, obstaclesY[esi]
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    mov al, symObstacle
    call WriteChar
    
    inc esi
    loop DrawObsLoop
    
SkipObsDraw:
    mov eax, white
    call SetTextColor
    ret
DrawWalls ENDP

DrawGame PROC USES eax edx
    cmp didGrow, 1
    je SkipErase
    
    movzx eax, lastTailX
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, lastTailY
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    mov al, ' '
    call WriteChar
SkipErase:

    mov eax, lightBlue
    call SetTextColor
    
    movzx eax, snakeX[0]
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, snakeY[0]
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    mov al, symHead
    call WriteChar
    
    movzx eax, snakeX[1]
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, snakeY[1]
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    mov al, symBody
    call WriteChar
    mov eax, white
    call SetTextColor
    
    mov eax, green
    call SetTextColor
    
    movzx eax, foodX
    inc eax
    add eax, eax
    add eax, MapOffsetX
    mov dl, al
    
    mov dh, foodY
    inc dh
    add dh, MapOffsetY
    call Gotoxy
    mov al, symFood
    call WriteChar
    mov eax, white
    call SetTextColor
    
    mov eax, yellow
    call SetTextColor
    mov dl, 35
    mov dh, MapHeight + 3 + MapOffsetY
    call Gotoxy
    mov edx, OFFSET strScore
    call WriteString
    mov eax, score
    call WriteDec
    mov eax, white
    call SetTextColor
    
    ret
DrawGame ENDP

Input PROC USES eax
    call ReadKey
    jz NoKey
    
    cmp ah, KEY_UP
    je DirUp
    cmp ah, KEY_DOWN
    je DirDown
    cmp ah, KEY_LEFT
    je DirLeft
    cmp ah, KEY_RIGHT
    je DirRight
    
    cmp al, 'w'
    je DirUp
    cmp al, 's'
    je DirDown
    cmp al, 'a'
    je DirLeft
    cmp al, 'd'
    je DirRight
    
    jmp NoKey

DirUp:
    cmp dirY, 1
    je NoKey
    mov dirX, 0
    mov dirY, -1
    jmp NoKey

DirDown:
    cmp dirY, -1
    je NoKey
    mov dirX, 0
    mov dirY, 1
    jmp NoKey

DirLeft:
    cmp dirX, 1
    je NoKey
    mov dirX, -1
    mov dirY, 0
    jmp NoKey

DirRight:
    cmp dirX, -1
    je NoKey
    mov dirX, 1
    mov dirY, 0
    jmp NoKey

NoKey:
    ret
Input ENDP

Logic PROC USES eax ecx esi
    mov didGrow, 0

    mov esi, snakeLen
    dec esi
    mov al, snakeX[esi]
    mov lastTailX, al
    mov al, snakeY[esi]
    mov lastTailY, al

    mov ecx, snakeLen
    dec ecx
    mov esi, snakeLen
    dec esi
    
MoveLoop:
    mov al, snakeX[esi-1]
    mov snakeX[esi], al
    mov al, snakeY[esi-1]
    mov snakeY[esi], al
    
    dec esi
    loop MoveLoop
    
MoveHead:
    mov al, snakeX[0]
    add al, dirX
    mov snakeX[0], al
    
    mov al, snakeY[0]
    add al, dirY
    mov snakeY[0], al
    
    cmp snakeX[0], 0
    jl Die
    cmp snakeX[0], MapWidth
    jge Die
    cmp snakeY[0], 0
    jl Die
    cmp snakeY[0], MapHeight
    jge Die
    
    ; Check Obstacle Collision
    cmp obstacleCount, 0
    je SkipObsCol
    
    mov ecx, obstacleCount
    mov esi, 0
ObsColLoop:
    mov al, snakeX[0]
    cmp al, obstaclesX[esi]
    jne NextObsCol
    mov al, snakeY[0]
    cmp al, obstaclesY[esi]
    je Die
NextObsCol:
    inc esi
    loop ObsColLoop
SkipObsCol:
    
    mov ecx, snakeLen
    dec ecx
    mov esi, 1
SelfColLoop:
    mov al, snakeX[0]
    cmp al, snakeX[esi]
    jne NextCheck
    mov al, snakeY[0]
    cmp al, snakeY[esi]
    je Die
NextCheck:
    inc esi
    loop SelfColLoop
    
    mov al, snakeX[0]
    cmp al, foodX
    jne FinishLogic
    mov al, snakeY[0]
    cmp al, foodY
    jne FinishLogic
    
    inc score
    inc snakeLen
    mov didGrow, 1
    
    mov esi, snakeLen
    dec esi
    mov al, lastTailX
    mov snakeX[esi], al
    mov al, lastTailY
    mov snakeY[esi], al
    
    INVOKE GenerateFood
    jmp FinishLogic

Die:
    mov gameOver, 1

FinishLogic:
    ret
Logic ENDP

GenerateFood PROC USES eax ecx esi
RetryGen:
    mov eax, MapWidth
    call RandomRange
    mov foodX, al
    
    mov eax, MapHeight
    call RandomRange
    mov foodY, al
    
    mov ecx, snakeLen
    mov esi, 0
CheckGen:
    mov al, foodX
    cmp al, snakeX[esi]
    jne NextGenCheck
    mov al, foodY
    cmp al, snakeY[esi]
    je RetryGen
NextGenCheck:
    inc esi
    loop CheckGen
    
    ; Check Obstacles
    cmp obstacleCount, 0
    je EndGenFood
    
    mov ecx, obstacleCount
    mov esi, 0
CheckGenObs:
    mov al, foodX
    cmp al, obstaclesX[esi]
    jne NextGenObs
    mov al, foodY
    cmp al, obstaclesY[esi]
    je RetryGen
NextGenObs:
    inc esi
    loop CheckGenObs
    
EndGenFood:
    ret
GenerateFood ENDP

ShowGameOver PROC
    call ClrScr
    mov eax, lightRed + (white * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET strGameOver
    call WriteString
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 10
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET strScore
    call WriteString
    mov eax, score
    call WriteDec
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov edx, OFFSET strPlayAgain
    call WriteString
    
    call ReadChar
    ret
ShowGameOver ENDP

MainMenu PROC
    call ClrScr
    
    ; Draw Snake Game Title
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    
    mov dh, 5
    mov dl, 31
    call Gotoxy
    mov edx, OFFSET strWelcomeTitle
    call WriteString
    
    ; Draw Main Menu Title
    mov eax, yellow + (blue * 16)
    call SetTextColor
    
    mov dh, 8
    mov dl, 31
    call Gotoxy
    mov edx, OFFSET strMenuTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 11
    mov dl, 33
    call Gotoxy
    mov edx, OFFSET strMenuOpt1
    call WriteString
    
    mov dh, 13
    mov dl, 33
    call Gotoxy
    mov edx, OFFSET strMenuOpt2
    call WriteString
    
    call ReadChar
    ret
MainMenu ENDP

DifficultyMenu PROC USES eax edx
    call ClrScr
    
    mov eax, yellow + (blue * 16)
    call SetTextColor
    
    mov dh, 8
    mov dl, 27
    call Gotoxy
    mov edx, OFFSET strDiffTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 11
    mov dl, 26
    call Gotoxy
    mov edx, OFFSET strDiffOpt1
    call WriteString
    
    mov dh, 13
    mov dl, 23
    call Gotoxy
    mov edx, OFFSET strDiffOpt2
    call WriteString
    
    mov dh, 15
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET strDiffOpt3
    call WriteString
    
    call ReadChar
    
    cmp al, '1'
    je SetEasy
    cmp al, '2'
    je SetMedium
    cmp al, '3'
    je SetHard
    jmp SetEasy ; Default to Easy

SetEasy:
    mov gameSpeed, 150
    mov obstacleCount, 0
    ret
SetMedium:
    mov gameSpeed, 100
    mov obstacleCount, 5
    ret
SetHard:
    mov gameSpeed, 80
    mov obstacleCount, 15
    ret
DifficultyMenu ENDP

GenerateObstacles PROC USES eax ecx esi
    cmp obstacleCount, 0
    je NoObstacles
    
    mov ecx, obstacleCount
    mov esi, 0
GenObsLoop:
    ; Random X (1 to MapWidth-1)
    mov eax, MapWidth
    dec eax
    call RandomRange
    inc eax
    mov obstaclesX[esi], al
    
    ; Random Y (1 to MapHeight-1)
    mov eax, MapHeight
    dec eax
    call RandomRange
    inc eax
    mov obstaclesY[esi], al
    
    ; Check if obstacle is on snake (simple check for start pos)
    cmp obstaclesX[esi], 20
    jne NextObs
    cmp obstaclesY[esi], 10
    je GenObsLoop ; Retry
    
NextObs:
    inc esi
    loop GenObsLoop
    
NoObstacles:
    ret
GenerateObstacles ENDP

END main
