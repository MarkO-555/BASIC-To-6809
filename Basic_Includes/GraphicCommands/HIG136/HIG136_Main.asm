; Graphics commands for screen mode HIG136
; Resolution of 256x192x16 colours
ScreenWidth_HIG136    EQU 256
ScreenHeight_HIG136   EQU 192
BytesPerRow_HIG136    EQU ScreenWidth_HIG136/2
Screen_Size_HIG136    EQU $6000
;
; SET a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
;
; Make sure the values of y is between 0 and 191 or bad things will happen
;
; x location is 0 to 254 (128 bytes) per row
; y location is 0 to 191 (192 rows)
;
; A=Y value, B=X value
;
; Byte to draw pixel on screen
; = xxx1 x1xx = 20 is the byte
; = xxxx 1111 = x, pixel value carry =0 then even (left) pixel
;
; 128 bytes per row
; y * 128 + x
; A=y value, B=x value
; Line colour will have it's colour in the high nibble and the low nibble at this point
SET_HIG136:
DoSet_HIG136:
        PSHS    D               ; Save x & y coordinate on the stack
        LSRA
        RORB
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X
        LDB     1,S
        ANDB    #%00000001
        BNE     SetOddPixel_HIG136 ; Go colour the Odd Pixel
; Set the even pixel
        LDA     #%00001111
        ANDA    ,X              ; Get the odd pixel value on screen
        STA     ,X              ; Save only the odd pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%11110000      ; Save the even pixel
        ORA     ,X
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return
; Set the odd pixel
SetOddPixel_HIG136:
        LDA     #%11110000
        ANDA    ,X              ; Get the even pixel value on screen
        STA     ,X              ; Save only the even pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%00001111      ; Save the odd pixel
        ORA     ,X              ; Combine the pixels
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
POINT_HIG136:
        PSHS    B               ; Save x coordinate on the stack
        LSRA
        RORB
        ADDD    BEGGRP          ; Add the Video Start Address
        STD     Point1_HIG136+1   ; Self mod location below
Point1_HIG136:
        LDB     >$FFFF          ; B = The colour of the Even and Odd pixel
        LDA     ,S+             ; Get the value Check if it's even or odd, fix the stack
        ANDA    #%00000001
        BNE     GetOddPixel_HIG136 ; Go get the colour the Odd Pixel
; Get the even pixel
        LSRB
        LSRB
        LSRB
        LSRB                    ; Got the value in B
        RTS                     ; return
GetOddPixel_HIG136:
        ANDB    #%00001111      ; Got the value in B
        RTS                     ; return

; Colour the screen Colour B
GCLS_HIG136:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG136,X ; Screen Size
        STU     GCLSComp_HIG136+1 ; Self mod end address
        ANDB    #%00001111
        PSHS    B  
        LSLB
        LSLB
        LSLB
        LSLB
        ORB     ,S+
        TFR     B,A             ; A = B
!       STD     ,X++
GCLSComp_HIG136:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS
