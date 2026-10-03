
.macro macroexample

    lda #4
    lda #5

.endmacro

.segment "ZEROPAGE"
step_pointer:   .res 2          ; zero page pointer to the step table, shown as a word

.segment "BSS"
frame_count:    .res 2          ; global, shown as a word
history:        .res 8          ; global, shown as a byte array

.segment "RODATA"
steps:          .byte 1, 2, 4, 8, 16, 32, 64, 128

.segment "CODE"

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
    macroexample

    ; BSS isn't cleared on load
    stz frame_count
    stz frame_count+1

    lda #<steps
    sta step_pointer
    lda #>steps
    sta step_pointer+1

loop:
    jsr update
    jmp loop

; Variables declared inside a .proc are local to it, so show in the Locals view while stepping through it.
.proc update
.segment "BSS"
step_index:     .res 1          ; local, shown as a byte
last_step:      .res 1          ; local, shown as a byte
.segment "CODE"
    inc frame_count
    bne :+
    inc frame_count+1
:
    ldy step_index
    cpy #8                      ; BSS isn't cleared on load, so keep the index in range
    bcc :+
    ldy #0
:
    lda (step_pointer), y
    sta last_step
    sta history, y

    iny
    cpy #8
    bne :+
    ldy #0
:
    sty step_index
    rts
.endproc
