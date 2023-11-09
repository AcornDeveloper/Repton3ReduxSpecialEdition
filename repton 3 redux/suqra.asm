; square

.transporter_square_pattern
 LDA #&06                               ;transporter sound
 JSR make_sound
 LDA #&0F
 STA pages + &00
 LDA #&01
 STA pages + &01
.capit
 LDA pages + &00
 STA tempx
 STA tempy
 LDA #19                                ;wait between each square rendered
 JSR osbyte
 LDX #&03
 STX pages + &02
.square
 JSR transporter_square_edge
 DEC pages + &02
 BPL square
 LDA pages + &00
 STA tempx
 STA tempy
 LDX #&01 << &03                        ;place four corner pieces on
 JSR transporter_square
 LDA pages + &00
 CLC
 ADC pages + &01
 STA tempx
 LDX #&03 << &03
 JSR transporter_square
 INC pages + &01
 INC pages + &01
 LDA tempx
 STA tempy
 LDX #&07 << &03
 JSR transporter_square
 LDA pages + &00
 STA tempx
 LDX #&06 << &03
 JSR transporter_square
 DEC pages + &00
 BPL capit
 RTS

.transporter_square_edge                ;render a transporter side
 LDX pages + &01
.lines
 TXA
 PHA
 LDY pages + &02
 LDX strip,Y
 JSR transporter_square
 LDX pages + &02
 LDA tempx
 CLC
 ADC xdire,X
 STA tempx
 LDA tempy
 CLC
 ADC ydire,X
 STA tempy
 PLA
 TAX
 DEX
 BNE lines
 RTS

.xdire                                  ;table overlap
 EQUB &00
.ydire
 EQUB &FF
 EQUB &00
 EQUB &01
 EQUB &00

.strip
 EQUB &04 << &03
 EQUB &08 << &03
 EQUB &05 << &03
 EQUB &02 << &03

.square_block                           ;definitions for each of the transporter blocks
 EQUD &F7F7F0F0
 EQUD &C6C6C7C7
 EQUD &FFFFF0F0
 EQUD &00000F0F
 EQUD &FEFEF0F0
 EQUD &36363E3E
 EQUD &C6C6C6C6
 EQUD &C6C6C6C6
 EQUD &36363636
 EQUD &36363636
 EQUD &C7C7C6C6
 EQUD &F0F0F7F7
 EQUD &3E3E3636
 EQUD &F0F0FEFE
 EQUD &0F0F0000
 EQUD &F0F0FFFF

.transporter_square                     ;put one of eight different graphics on screen
 LDA tempx                              ;left/right/top/bottom/corners
 ASL A                                  ;index into square piece
 ASL A
 ASL A
 ADC start                              ;c=0
 STA indir
 LDA tempy
 ADC start + &01
 BPL square_posit
 SBC #&1F                               ;c=0
.square_posit
 STA indir + &01
 LDY #&07
 LDA square_block - &01,X               ;transfer 8 bytes of transporter graphic
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 DEX
 DEY
 LDA square_block - &01,X
 STA (indir),Y
 RTS
