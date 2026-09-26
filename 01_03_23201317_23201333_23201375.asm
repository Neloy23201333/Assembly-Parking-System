; ==============================================================
; Project Title : Parking Management System
; Course        : CSE341-- Microprocessors
; Group         : 01
; ID'S          : 23201317,23201333,23201375
; ==============================================================

.MODEL SMALL
.STACK 100H

.DATA

newline DB 13,10,'$'
spaceMsg DB ' $'

welcomeMsg DB 13,10,'========================================',13,10
           DB '      PARKING MANAGEMENT SYSTEM',13,10
           DB '========================================',13,10,'$'

menuMsg DB 13,10,'--------------- MAIN MENU ---------------',13,10
        DB '1. Enter Vehicle with Auto Slot Assignment',13,10
        DB '2. Enter Vehicle with Manual Slot Selection',13,10
        DB '3. Search Vehicle',13,10
        DB '4. Vehicle Exit',13,10
        DB '5. Show Available Slots',13,10
        DB '6. Exit Program',13,10
        DB '-----------------------------------------',13,10,'$'

choiceMsg DB 'Enter your choice: $'
invalidChoiceMsg DB 13,10,'Invalid choice! Please select 1 to 6.$'

idPrompt DB 13,10,'Enter vehicle ID (01-99): $'
typePrompt DB 13,10,'Enter vehicle type (V=VIP, R=Regular): $'
vipCodePrompt DB 13,10,'Enter 4-digit VIP code: $'
slotPrompt DB 13,10,'Enter desired slot number (01-10): $'

digitOnlyMsg DB 13,10,'Only digits are allowed. Enter again: $'
invalidIDMsg DB 13,10,'Invalid ID! Vehicle ID 00 is not allowed.$'
invalidTypeMsg DB 13,10,'Invalid type! Enter V for VIP or R for Regular.$'
invalidVipDigitMsg DB 13,10,'VIP code must contain digits only. Access denied.$'
invalidVipCodeMsg DB 13,10,'Invalid VIP code. Access denied.$'
vipVerifiedMsg DB 13,10,'VIP verified successfully.$'
invalidSlotMsg DB 13,10,'Invalid slot number! Valid range is 01 to 10.$'

cmdAutoTitle DB 13,10,'--- AUTO SLOT ASSIGNMENT ---$'
cmdManualTitle DB 13,10,'--- MANUAL SLOT SELECTION ---$'
cmdSearchTitle DB 13,10,'--- VEHICLE SEARCH ---$'
cmdExitTitle DB 13,10,'--- VEHICLE EXIT ---$'
cmdAvailableTitle DB 13,10,'--- AVAILABLE SLOT DISPLAY ---$'

parkSuccessMsg DB 13,10,'Vehicle parked successfully.$'
assignedSlotMsg DB 13,10,'Assigned slot: $'
noSlotMsg DB 13,10,'No available slot for this category.$'
duplicateMsg DB 13,10,'This vehicle is already parked.$'
slotOccupiedMsg DB 13,10,'Selected slot is already occupied.$'
categoryErrorMsg DB 13,10,'Selected slot does not match vehicle category.$'
vipReservedMsg DB 13,10,'Error: This slot is reserved for VIP customers. Regular customers cannot access it.$'
regularReservedMsg DB 13,10,'Error: This slot is reserved for Regular customers. VIP customers cannot access it.$'
pressMsg DB 13,10,'Press any key to return to main menu...$'

foundMsg DB 13,10,'Vehicle found.$'
notFoundMsg DB 13,10,'Vehicle not found.$'
slotNoMsg DB 13,10,'Slot number: $'
categoryMsg DB 13,10,'Category: $'
vipText DB 'VIP$'
regularText DB 'Regular$'

exitSuccessMsg DB 13,10,'Vehicle exited successfully.$'
releasedSlotMsg DB 13,10,'Released slot: $'
hourPrompt DB 13,10,'Enter parked hours : $'
invalidHourMsg DB 13,10,'Invalid hour! Parking hour 00 is not allowed.$'
feeMsg DB 13,10,'Parking fee: $'
takaMsg DB ' Taka$'

vipAvailableMsg DB 13,10,'Available VIP Slots: $'
regularAvailableMsg DB 13,10,'Available Regular Slots: $'
noneMsg DB 'None$'
totalVipMsg DB 13,10,'Total VIP free slots: $'
totalRegularMsg DB 13,10,'Total Regular free slots: $'
totalFreeMsg DB 13,10,'Total free slots: $'
byeMsg DB 13,10,'Thank you for using Parking Management System.$'

; 0 = empty, 1 = occupied
slotStatus DB 10 DUP(0)


slotCategory DB 'V','V','V','R','R','R','R','R','R','R'

; vehicleID stores numeric  01-99 for each slot
vehicleID DB 10 DUP(0)

; Five predefined 4 digit VIP codes stored as ASCII characters
vipCodeList DB '1234','2580','3412','7777','9001'
vipInputCode DB 4 DUP(0)

inputID DB 0
inputType DB 0
typeOk DB 0
vipInputOk DB 0
vipVerified DB 0
inputSlot DB 0
foundFlag DB 0
foundIndex DB 0
freeCount DB 0
vipFree DB 0
regularFree DB 0
totalFree DB 0
tempDigit DB 0
parkingHour DB 0
parkingFee DW 0

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MAIN_MENU:
    CALL CLEAR_SCREEN_PROC
    LEA DX, welcomeMsg
    CALL PRINT_STRING
    CALL MAIN_MENU_PROC

    CMP AL, '1'
    JE OPTION_AUTO

    CMP AL, '2'
    JE OPTION_MANUAL

    CMP AL, '3'
    JE OPTION_SEARCH

    CMP AL, '4'
    JE OPTION_EXIT

    CMP AL, '5'
    JE OPTION_AVAILABLE

    CMP AL, '6'
    JE END_PROGRAM

    LEA DX, invalidChoiceMsg
    CALL PRINT_STRING
    CALL WAIT_KEY_PROC
    JMP MAIN_MENU

OPTION_AUTO:
    CALL AUTO_ASSIGN_PROC
    CALL WAIT_KEY_PROC
    JMP MAIN_MENU

OPTION_MANUAL:
    CALL MANUAL_SLOT_PROC
    CALL WAIT_KEY_PROC
    JMP MAIN_MENU

OPTION_SEARCH:
    CALL SEARCH_PROC
    CALL WAIT_KEY_PROC
    JMP MAIN_MENU

OPTION_EXIT:
    CALL VEHICLE_EXIT_PROC
    CALL WAIT_KEY_PROC
    JMP MAIN_MENU

OPTION_AVAILABLE:
    CALL DISPLAY_AVAILABLE_PROC
    CALL WAIT_KEY_PROC
    JMP MAIN_MENU

END_PROGRAM:
    LEA DX, byeMsg
    CALL PRINT_STRING
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; --------------------------------------------------------------
; Clears the screen off after errors/output.
; --------------------------------------------------------------
CLEAR_SCREEN_PROC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, 0600H
    MOV BH, 07H
    MOV CX, 0000H
    MOV DX, 184FH
    INT 10H

    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 0000H
    INT 10H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
CLEAR_SCREEN_PROC ENDP

; --------------------------------------------------------------
; flushes leftover enter from previous input 
; --------------------------------------------------------------
WAIT_KEY_PROC PROC
    PUSH AX
    PUSH DX

    LEA DX, pressMsg
    CALL PRINT_STRING

    MOV AH, 0CH
    MOV AL, 08H
    INT 21H

    POP DX
    POP AX
    RET
WAIT_KEY_PROC ENDP


PRINT_STRING PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV AH, 09H
    INT 21H

    POP DX
    POP CX
    POP AX
    RET
PRINT_STRING ENDP

; --------------------------------------------------------------
; Prints one character from DL.
; --------------------------------------------------------------
PRINT_CHAR PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP AX
    RET
PRINT_CHAR ENDP

; --------------------------------------------------------------
; Prints newline 
; --------------------------------------------------------------
PRINT_NEWLINE PROC
    PUSH DX

    LEA DX, newline
    CALL PRINT_STRING

    POP DX
    RET
PRINT_NEWLINE ENDP

; --------------------------------------------------------------
; Reads one character & skips ENTER keys.
; --------------------------------------------------------------
READ_CHAR PROC
READ_AGAIN:
    MOV AH, 01H
    INT 21H

    CMP AL, 0DH
    JE READ_AGAIN

    CMP AL, 0AH
    JE READ_AGAIN

    RET
READ_CHAR ENDP

; --------------------------------------------------------------
; Reads one digit character and returns numeric digit in AL.
; --------------------------------------------------------------
READ_DIGIT_PROC PROC
READ_DIGIT_AGAIN:
    CALL READ_CHAR

    CMP AL, '0'
    JB NOT_DIGIT

    CMP AL, '9'
    JA NOT_DIGIT

    SUB AL, 30H
    RET

NOT_DIGIT:
    LEA DX, digitOnlyMsg
    CALL PRINT_STRING
    JMP READ_DIGIT_AGAIN
READ_DIGIT_PROC ENDP

; --------------------------------------------------------------
; Prints number in AL from 0 to 99.
; --------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 0
    MOV BL, 10
    DIV BL

    MOV BH, AH

    CMP AL, 0
    JE PRINT_ONES

    ADD AL, 30H
    MOV DL, AL
    CALL PRINT_CHAR

PRINT_ONES:
    MOV DL, BH
    ADD DL, 30H
    CALL PRINT_CHAR

    POP DX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

; --------------------------------------------------------------
; Displays main menu and returns  choice in AL.
; --------------------------------------------------------------
MAIN_MENU_PROC PROC
    LEA DX, menuMsg
    CALL PRINT_STRING

    LEA DX, choiceMsg
    CALL PRINT_STRING

    CALL READ_CHAR
    RET
MAIN_MENU_PROC ENDP

; --------------------------------------------------------------
; Input vehicle ID  and stores it in inputID.
; --------------------------------------------------------------
INPUT_ID_PROC PROC
INPUT_ID_START:
    LEA DX, idPrompt
    CALL PRINT_STRING

    CALL READ_DIGIT_PROC
    MOV BL, 10
    MUL BL
    MOV tempDigit, AL

    CALL READ_DIGIT_PROC
    ADD AL, tempDigit

    CMP AL, 0
    JE BAD_VEHICLE_ID

    MOV inputID, AL
    RET

BAD_VEHICLE_ID:
    LEA DX, invalidIDMsg
    CALL PRINT_STRING
    JMP INPUT_ID_START
INPUT_ID_PROC ENDP

; --------------------------------------------------------------
; Inputs vehicle type and stores 'V' or 'R' in inputType.
; If VIP is selected, verifies a 4-digit VIP code first.
; --------------------------------------------------------------    

INPUT_TYPE_PROC PROC
INPUT_TYPE_START:
    MOV typeOk, 0
    MOV inputType, 0
    MOV vipVerified, 0
    MOV vipInputOk, 0

    LEA DX, typePrompt
    CALL PRINT_STRING

    CALL READ_CHAR

    CMP AL, 'V'
    JE VIP_TYPE_SELECTED

    CMP AL, 'v'
    JE VIP_TYPE_SELECTED

    CMP AL, 'R'
    JE STORE_REGULAR_TYPE

    CMP AL, 'r'
    JE STORE_REGULAR_TYPE

    LEA DX, invalidTypeMsg
    CALL PRINT_STRING
    JMP INPUT_TYPE_START

VIP_TYPE_SELECTED:
    CALL INPUT_VIP_CODE_PROC

    CMP vipInputOk, 1
    JNE VIP_DIGIT_FAILED

    CALL VERIFY_VIP_CODE_PROC

    CMP vipVerified, 1
    JNE VIP_CODE_FAILED

    MOV inputType, 'V'
    MOV typeOk, 1
    LEA DX, vipVerifiedMsg
    CALL PRINT_STRING
    RET

VIP_DIGIT_FAILED:
    LEA DX, invalidVipDigitMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

VIP_CODE_FAILED:
    LEA DX, invalidVipCodeMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

STORE_REGULAR_TYPE:
    MOV inputType, 'R'
    MOV typeOk, 1
    RET
INPUT_TYPE_PROC ENDP

; --------------------------------------------------------------
; Reads exactly 4 characters for VIP code.
; Only digits 0-9 are accepted.
; --------------------------------------------------------------
INPUT_VIP_CODE_PROC PROC
    PUSH AX
    PUSH CX
    PUSH SI

    MOV vipInputOk, 1

    LEA DX, vipCodePrompt
    CALL PRINT_STRING

    LEA SI, vipInputCode
    MOV CX, 4

READ_VIP_CODE_LOOP:
    CALL READ_CHAR

    CMP AL, '0'
    JB BAD_VIP_CODE_DIGIT

    CMP AL, '9'
    JA BAD_VIP_CODE_DIGIT

    MOV [SI], AL
    INC SI
    LOOP READ_VIP_CODE_LOOP
    JMP INPUT_VIP_CODE_END

BAD_VIP_CODE_DIGIT:
    MOV vipInputOk, 0

INPUT_VIP_CODE_END:
    POP SI
    POP CX
    POP AX
    RET
INPUT_VIP_CODE_PROC ENDP

; --------------------------------------------------------------
; Compares the entered 4-digit code with 5 stored VIP codes.
; --------------------------------------------------------------
VERIFY_VIP_CODE_PROC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV vipVerified, 0
    MOV BX, 0
    MOV DL, 5

VERIFY_NEXT_CODE:
    LEA SI, vipInputCode
    LEA DI, vipCodeList
    ADD DI, BX
    MOV CL, 4

VERIFY_DIGIT_LOOP:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE VERIFY_CODE_NOT_MATCH

    INC SI
    INC DI
    DEC CL
    JNZ VERIFY_DIGIT_LOOP

    MOV vipVerified, 1
    JMP VERIFY_DONE

VERIFY_CODE_NOT_MATCH:
    ADD BX, 4
    DEC DL
    JNZ VERIFY_NEXT_CODE

VERIFY_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
VERIFY_VIP_CODE_PROC ENDP

; --------------------------------------------------------------
; Inputs slot number from 01 to 10 and stores it in inputSlot.
; --------------------------------------------------------------
INPUT_SLOT_PROC PROC
INPUT_SLOT_START:
    LEA DX, slotPrompt
    CALL PRINT_STRING

    CALL READ_DIGIT_PROC
    MOV BL, 10
    MUL BL
    MOV tempDigit, AL

    CALL READ_DIGIT_PROC
    ADD AL, tempDigit

    CMP AL, 1
    JB BAD_SLOT_INPUT

    CMP AL, 10
    JA BAD_SLOT_INPUT

    MOV inputSlot, AL
    RET

BAD_SLOT_INPUT:
    LEA DX, invalidSlotMsg
    CALL PRINT_STRING
    JMP INPUT_SLOT_START
INPUT_SLOT_PROC ENDP


; --------------------------------------------------------------
; Inputs parked hours from 01 to 99 and stores it in parkingHour.
; used during vehicle exit
; --------------------------------------------------------------
INPUT_HOUR_PROC PROC
INPUT_HOUR_START:
    LEA DX, hourPrompt
    CALL PRINT_STRING

    CALL READ_DIGIT_PROC
    MOV BL, 10
    MUL BL
    MOV tempDigit, AL

    CALL READ_DIGIT_PROC
    ADD AL, tempDigit

    CMP AL, 0
    JE BAD_HOUR_INPUT

    MOV parkingHour, AL
    RET

BAD_HOUR_INPUT:
    LEA DX, invalidHourMsg
    CALL PRINT_STRING
    JMP INPUT_HOUR_START
INPUT_HOUR_PROC ENDP

; --------------------------------------------------------------
; Calculates parking fee.

; --------------------------------------------------------------
CALCULATE_FEE_PROC PROC
    PUSH AX
    PUSH BX

    MOV AL, parkingHour
    MOV AH, 0
    MOV BL, 10
    MUL BL
    MOV parkingFee, AX

    POP BX
    POP AX
    RET
CALCULATE_FEE_PROC ENDP

; --------------------------------------------------------------
; Prints number in AX from 0 to 999.
; This is used for parking fee because fee can be more than 99.
; --------------------------------------------------------------
PRINT_WORD_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0
    MOV BX, 10

    CMP AX, 0
    JNE PRINT_WORD_DIVIDE

    MOV DL, '0'
    CALL PRINT_CHAR
    JMP PRINT_WORD_DONE

PRINT_WORD_DIVIDE:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PRINT_WORD_DIVIDE

PRINT_WORD_LOOP:
    POP DX
    ADD DL, 30H
    CALL PRINT_CHAR
    LOOP PRINT_WORD_LOOP

PRINT_WORD_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_WORD_NUM ENDP

; --------------------------------------------------------------
; Searches inputID in vehicleID array.
; --------------------------------------------------------------
FIND_VEHICLE_PROC PROC
    PUSH AX
    PUSH CX
    PUSH SI

    MOV foundFlag, 0
    MOV SI, 0
    MOV CX, 10

FIND_LOOP:
    CMP BYTE PTR slotStatus[SI], 1
    JNE FIND_NEXT

    MOV AL, vehicleID[SI]
    CMP AL, inputID
    JE VEHICLE_FOUND

FIND_NEXT:
    INC SI
    LOOP FIND_LOOP
    JMP FIND_END

VEHICLE_FOUND:
    MOV foundFlag, 1
    MOV AX, SI
    MOV foundIndex, AL

FIND_END:
    POP SI
    POP CX
    POP AX
    RET
FIND_VEHICLE_PROC ENDP

; --------------------------------------------------------------
; Prints category of slot index SI.
; --------------------------------------------------------------
PRINT_CATEGORY_PROC PROC
    PUSH AX
    PUSH DX

    MOV AL, slotCategory[SI]
    CMP AL, 'V'
    JE PRINT_VIP_CATEGORY

    LEA DX, regularText
    CALL PRINT_STRING
    JMP PRINT_CATEGORY_END

PRINT_VIP_CATEGORY:
    LEA DX, vipText
    CALL PRINT_STRING

PRINT_CATEGORY_END:
    POP DX
    POP AX
    RET
PRINT_CATEGORY_PROC ENDP

; --------------------------------------------------------------
; Feature 1: Vehicle Entry and Automatic Slot Assignment
; --------------------------------------------------------------
AUTO_ASSIGN_PROC PROC
    LEA DX, cmdAutoTitle
    CALL PRINT_STRING

    CALL INPUT_ID_PROC
    CALL FIND_VEHICLE_PROC

    CMP foundFlag, 1
    JE AUTO_DUPLICATE

    CALL INPUT_TYPE_PROC
    CMP typeOk, 1
    JNE AUTO_TYPE_DENIED

    MOV SI, 0
    MOV CX, 10

AUTO_SEARCH_LOOP:
    MOV AL, slotCategory[SI]
    CMP AL, inputType
    JNE AUTO_NEXT_SLOT

    CMP BYTE PTR slotStatus[SI], 0
    JE AUTO_ASSIGN_HERE

AUTO_NEXT_SLOT:
    INC SI
    LOOP AUTO_SEARCH_LOOP

    LEA DX, noSlotMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

AUTO_ASSIGN_HERE:
    MOV BYTE PTR slotStatus[SI], 1
    MOV AL, inputID
    MOV vehicleID[SI], AL

    LEA DX, parkSuccessMsg
    CALL PRINT_STRING

    LEA DX, assignedSlotMsg
    CALL PRINT_STRING

    MOV AX, SI
    INC AX
    CALL PRINT_NUM
    CALL PRINT_NEWLINE
    RET

AUTO_TYPE_DENIED:
    RET

AUTO_DUPLICATE:
    LEA DX, duplicateMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET
AUTO_ASSIGN_PROC ENDP

; --------------------------------------------------------------
; Feature 2: Manual Slot Selection with Validation
; --------------------------------------------------------------
MANUAL_SLOT_PROC PROC
    LEA DX, cmdManualTitle
    CALL PRINT_STRING

    CALL INPUT_ID_PROC
    CALL FIND_VEHICLE_PROC

    CMP foundFlag, 1
    JE MANUAL_DUPLICATE

    CALL INPUT_TYPE_PROC
    CMP typeOk, 1
    JNE MANUAL_TYPE_DENIED

    CALL INPUT_SLOT_PROC

    MOV AL, inputSlot
    DEC AL
    MOV AH, 0
    MOV SI, AX

    CMP BYTE PTR slotStatus[SI], 1
    JE MANUAL_OCCUPIED

    MOV AL, slotCategory[SI]
    CMP AL, inputType
    JNE MANUAL_BAD_CATEGORY

    MOV BYTE PTR slotStatus[SI], 1
    MOV AL, inputID
    MOV vehicleID[SI], AL

    LEA DX, parkSuccessMsg
    CALL PRINT_STRING

    LEA DX, assignedSlotMsg
    CALL PRINT_STRING

    MOV AL, inputSlot
    CALL PRINT_NUM
    CALL PRINT_NEWLINE
    RET

MANUAL_TYPE_DENIED:
    RET

MANUAL_DUPLICATE:
    LEA DX, duplicateMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

MANUAL_OCCUPIED:
    LEA DX, slotOccupiedMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

MANUAL_BAD_CATEGORY:
    ; Exact category error. Slot category is checked before returning.
   
    CMP inputType, 'R'
    JNE MANUAL_VIP_WRONG_SLOT

    CMP BYTE PTR slotCategory[SI], 'V'
    JE MANUAL_REGULAR_IN_VIP
    JMP MANUAL_GENERIC_CATEGORY_ERR

MANUAL_VIP_WRONG_SLOT:
    CMP BYTE PTR slotCategory[SI], 'R'
    JE MANUAL_VIP_IN_REGULAR
    JMP MANUAL_GENERIC_CATEGORY_ERR

MANUAL_REGULAR_IN_VIP:
    LEA DX, vipReservedMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

MANUAL_VIP_IN_REGULAR:
    LEA DX, regularReservedMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET

MANUAL_GENERIC_CATEGORY_ERR:
    LEA DX, categoryErrorMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET
MANUAL_SLOT_PROC ENDP

; --------------------------------------------------------------
; Feature 5: Vehicle Search
; --------------------------------------------------------------
SEARCH_PROC PROC
    LEA DX, cmdSearchTitle
    CALL PRINT_STRING

    CALL INPUT_ID_PROC
    CALL FIND_VEHICLE_PROC

    CMP foundFlag, 1
    JNE SEARCH_NOT_FOUND

    LEA DX, foundMsg
    CALL PRINT_STRING

    LEA DX, slotNoMsg
    CALL PRINT_STRING

    MOV AL, foundIndex
    INC AL
    CALL PRINT_NUM

    MOV AL, foundIndex
    MOV AH, 0
    MOV SI, AX

    LEA DX, categoryMsg
    CALL PRINT_STRING
    CALL PRINT_CATEGORY_PROC
    CALL PRINT_NEWLINE
    RET

SEARCH_NOT_FOUND:
    LEA DX, notFoundMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET
SEARCH_PROC ENDP

; --------------------------------------------------------------
; Feature 4: Vehicle Exit and Slot Release
; --------------------------------------------------------------
VEHICLE_EXIT_PROC PROC
    LEA DX, cmdExitTitle
    CALL PRINT_STRING

    CALL INPUT_ID_PROC
    CALL FIND_VEHICLE_PROC

    CMP foundFlag, 1
    JNE EXIT_NOT_FOUND

    MOV AL, foundIndex
    MOV AH, 0
    MOV SI, AX

    CALL INPUT_HOUR_PROC
    CALL CALCULATE_FEE_PROC

    MOV BYTE PTR slotStatus[SI], 0
    MOV BYTE PTR vehicleID[SI], 0

    LEA DX, exitSuccessMsg
    CALL PRINT_STRING

    LEA DX, releasedSlotMsg
    CALL PRINT_STRING

    MOV AL, foundIndex
    INC AL
    CALL PRINT_NUM

    LEA DX, feeMsg
    CALL PRINT_STRING

    MOV AX, parkingFee
    CALL PRINT_WORD_NUM

    LEA DX, takaMsg
    CALL PRINT_STRING

    CALL PRINT_NEWLINE
    RET

EXIT_NOT_FOUND:
    LEA DX, notFoundMsg
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    RET
VEHICLE_EXIT_PROC ENDP

; --------------------------------------------------------------
; Feature 6: Available Slot Display
; --------------------------------------------------------------
DISPLAY_AVAILABLE_PROC PROC
    LEA DX, cmdAvailableTitle
    CALL PRINT_STRING

    LEA DX, vipAvailableMsg
    CALL PRINT_STRING

    MOV freeCount, 0
    MOV SI, 0
    MOV CX, 10

DISPLAY_VIP_LOOP:
    MOV AL, slotCategory[SI]
    CMP AL, 'V'
    JNE DISPLAY_VIP_NEXT

    CMP BYTE PTR slotStatus[SI], 0
    JNE DISPLAY_VIP_NEXT

    MOV AX, SI
    INC AX
    CALL PRINT_NUM

    LEA DX, spaceMsg
    CALL PRINT_STRING

    INC BYTE PTR freeCount

DISPLAY_VIP_NEXT:
    INC SI
    LOOP DISPLAY_VIP_LOOP

    CMP freeCount, 0
    JNE VIP_DISPLAY_DONE

    LEA DX, noneMsg
    CALL PRINT_STRING

VIP_DISPLAY_DONE:
    MOV AL, freeCount
    MOV vipFree, AL
    CALL PRINT_NEWLINE

    LEA DX, regularAvailableMsg
    CALL PRINT_STRING

    MOV freeCount, 0
    MOV SI, 0
    MOV CX, 10

DISPLAY_REGULAR_LOOP:
    MOV AL, slotCategory[SI]
    CMP AL, 'R'
    JNE DISPLAY_REGULAR_NEXT

    CMP BYTE PTR slotStatus[SI], 0
    JNE DISPLAY_REGULAR_NEXT

    MOV AX, SI
    INC AX
    CALL PRINT_NUM

    LEA DX, spaceMsg
    CALL PRINT_STRING

    INC BYTE PTR freeCount

DISPLAY_REGULAR_NEXT:
    INC SI
    LOOP DISPLAY_REGULAR_LOOP

    CMP freeCount, 0
    JNE REGULAR_DISPLAY_DONE

    LEA DX, noneMsg
    CALL PRINT_STRING

REGULAR_DISPLAY_DONE:
    MOV AL, freeCount
    MOV regularFree, AL
    CALL PRINT_NEWLINE

    MOV AL, vipFree
    ADD AL, regularFree
    MOV totalFree, AL

    LEA DX, totalVipMsg
    CALL PRINT_STRING
    MOV AL, vipFree
    CALL PRINT_NUM

    LEA DX, totalRegularMsg
    CALL PRINT_STRING
    MOV AL, regularFree
    CALL PRINT_NUM

    LEA DX, totalFreeMsg
    CALL PRINT_STRING
    MOV AL, totalFree
    CALL PRINT_NUM
    CALL PRINT_NEWLINE

    RET
DISPLAY_AVAILABLE_PROC ENDP

END MAIN
