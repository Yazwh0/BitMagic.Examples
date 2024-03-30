
; 10 SYS 2064
    .byte $0C, $08              ; $080C - pointer to next line of BASIC code
    .byte $0A, $00              ; 2-byte line number ($000A = 10)
    .byte $9E                   ; SYS BASIC token
    .byte $20                   ; [space]
    .byte $32, $30, $36, $34    ; $32="2",$30="0",$36="6",$34="4"
    .byte $00                   ; End of Line
    .byte $00, $00              ; This is address $080C containing
                                ; 2-byte pointer to next line of BASIC code
                                ; ($0000 = end of program)
    .byte $00, $00              ; Padding so code starts at $0810
    cld
    stz $9F25

    lda #1
    lda #2
    lda #3

loop:
    inc
    jmp loop

