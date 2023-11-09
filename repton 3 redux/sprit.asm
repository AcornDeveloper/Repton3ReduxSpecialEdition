; sprit

.place_a_sprite
 PHP
 SEI
 JSR calculate_sprite
.other
 TXA
 AND #&03
 TAY
 LDA masks,Y
 AND paras + &03
 BEQ sprit_finit
 TXA
 LSR A
 LSR A
 TAY
 LDA masks,Y
 AND paras + &04
 BEQ sprit_finit
 LDY #&00                               ;transfer 8 bytes from sprite to screen
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 STA (paras + &07),Y
.sprit_finit
 LDA paras + &05                        ;address is on &80 boundary, so c=1 only on loop exit
 CLC
 ADC #&08
 STA paras + &05
 TXA
 AND #&03
 TAY
 LDA paras + &07                        ;move to next screen column, c=0
 ADC addit_lo,Y
 STA paras + &07
 LDA paras + &08
 ADC addit_hi,Y
 BPL nexts
 LDA #HI(lomem)
.nexts
 STA paras + &08
 INX
 CPX #&10
 BCC other
 PLP                                    ;restore irq status
 RTS

.addit_lo                               ;row address add in for sprites
 EQUB LO(&08)
 EQUB LO(&08)
 EQUB LO(&08)
 EQUB LO(&E8)

.addit_hi
 EQUB HI(&08)
 EQUB HI(&08)
 EQUB HI(&08)
 EQUB HI(&E8)

.masks
 EQUD &1020408

.eor_a_sprite
 PHP
 SEI
 JSR calculate_sprite
.tuthr
 TXA
 AND #&03
 TAY
 LDA masks,Y
 AND paras + &03
 BEQ finis
 TXA
 LSR A
 LSR A
 TAY
 LDA masks,Y
 AND paras + &04
 BEQ finis
 LDY #&00                               ;eor a cell with the screen
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
 INY
 LDA (paras + &05),Y
 EOR (paras + &07),Y
 STA (paras + &07),Y
.finis
 LDA paras + &05                        ;address is on &80 boundary, so c=1 only on loop exit
 CLC
 ADC #&08
 STA paras + &05
 TXA
 AND #&03
 TAY
 LDA paras + &07                        ;c=0
 ADC addit_lo,Y
 STA paras + &07
 LDA paras + &08
 ADC addit_hi,Y
 BPL vests
 LDA #HI(lomem)
.vests
 STA paras + &08
 INX
 CPX #&10
 BCC tuthr
 PLP                                    ;restore irq status
 RTS

.calculate_sprite
 LDA start                              ;get screen start address
 SEC
 SBC #LO(map_sprite_offset)
 STA indir + &00
 LDA start + &01
 SBC #HI(map_sprite_offset)
 STA indir + &01
 LDX paras + &00                        ;paras = sprite number, get address from table
 LDA sprites_address_lsb,X
 STA paras + &05                        ;paras + &05/&06 sprite address
 LDA sprites_address_msb,X
 STA paras + &06
 LDA paras + &01
 ASL A
 ASL A
 ASL A
 ROL paras + &08
 CLC
 ADC indir + &00
 STA paras + &07                        ;paras + &07/&08 screen address
 LDA paras + &08
 AND #&01
 ADC indir + &01                        ;paras + &01/&02 screen coordinates x,y 0/31, 0/31
 STA paras + &08
 LDA paras + &02
 CLC
 ADC paras + &08
 BPL thats
 SEC
 SBC #HI(screen_size)
.thats
 STA paras + &08
 LDX #&00
 RTS

.seed
 EQUB &AA

.trek_repton                            ;put repton on trek-esque style
 LDY #&7F                               ;transfer background sprite to buffer
.create_repton_masked                   ;and with mask from foreground sprite
 LDA seed                               ;generate a quick random number
 ASL A
 BCC no_eor_seed
 EOR #&88
.no_eor_seed
 STA seed
 LDX map_sprites + &80 * code_repton,Y
 LDA mask_table,X                       ;get mask byte for sprite
 EOR #&FF                               ;invert it
 AND seed                               ;create sprite shimmer byte mask
 STA tempa
 LDX map_sprites + &80 * code_repton,Y
 LDA map_sprites + &80 * code_space,Y
 AND mask_table,X
 ORA tempa
 STA sprite_128,Y                       ;sprite number 48
 DEY
 BPL create_repton_masked               ;buffer now contains background/foregound shimmer
 LDA start
 SEC
 SBC #LO(map_sprite_offset)
 STA indir
 LDA start + &01
 SBC #HI(map_sprite_offset)
 STA indir + &01
 LDA #&11 << &03
 CLC
 ADC indir
 STA paras + &07
 LDA #&00
 ADC indir + &01
 CLC
 ADC #&11
 BPL trek_sprite_thats
 SEC
 SBC #HI(screen_size)
.trek_sprite_thats
 STA paras + &08
 LDA #&00
 STA paras + &05                        ;now transfer buffer to screen one row, eight cells at a time
 LDA #HI(sprite_128)                    ;checking for screen wrap-around
 STA paras + &06                        ;buffer must be page aligned
 LDX #&04                               ;row counter
.trek_transfer_four_lines
 TXA
 PHA
 LDX #&04
.trek_transfer_four_characters
 LDY #&07
.trek_transfer_row
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 BPL trek_transfer_row
 LDA paras + &05                        ;add &08 to buffer address
 CLC
 ADC #&08
 STA paras + &05
 LDA paras + &07                        ;add &08 to screen address, wrap around if necessary
 CLC
 ADC #&08
 STA paras + &07
 LDA paras + &08
 ADC #&00
 BPL trek_no_wrap_around_inner
 LDA #HI(lomem)
.trek_no_wrap_around_inner
 STA paras + &08
 DEX
 BNE trek_transfer_four_characters
 LDA paras + &07
 CLC
 ADC #&E0                               ;add &e0 to screen address, wrap around if necessary
 STA paras + &07
 LDA paras + &08
 ADC #&00
 BPL trek_no_wrap_around_outer
 LDA #HI(lomem)
.trek_no_wrap_around_outer
 STA paras + &08
 PLA
 TAX
 DEX
 BNE trek_transfer_four_lines
 RTS
