; sqeze

.write_vector_patch                     ;patch in write character routine
 LDA wrchv + &01
 STA vectr + &01                        ;store oswrch vector
 LDA wrchv
 STA vectr
 LDA #LO(patch_character)
 STA wrchv
 LDA #HI(patch_character)
 STA wrchv + &01
 RTS

.setup_custom_mode                      ;modify mode 5 to use 8k of memory with start address at &6000
 LDA #&00                               ;clear screen
 TAX
.video

 FOR screen_page, 0, 31
  STA lomem + screen_page * &100,X
 NEXT

 DEX
 BNE video

 LDX #&0C                               ;screen start address
 STX sheila
 LDA #HI(lomem)                         ;starts at &6000
 STA tempa
 LSR A
 LSR A
 LSR A
 STA sheila + &01
 LDX #&0D
 STX sheila
 LDA #LO(lomem)
 LSR tempa
 ROR A
 LSR tempa
 ROR A
 LSR tempa
 ROR A
 STA sheila + &01
 LDA #&01                               ;number of characters per line
 STA sheila
 LDA #32
 STA sheila + &01
 LDA #&02                               ;horizontal sync position
 STA sheila
 LDA #45
 STA sheila + &01
 PHP
 SEI
 LDX sheila + &42
 LDA #&FF
 STA sheila + &42
 LDA #&0C
 STA sheila + &40
 LDA #&05
 STA sheila + &40
 STX sheila + &42
 LDA #LO(lomem)                         ;setup page zero screen address copy
 STA start
 LDA #HI(lomem)
 STA start + &01
 PLP                                    ;restore irq status
 RTS

.write_characters                       ;write number of characters in a to oswrch pointed at by x/y
 STX indir
 STY indir + &01
 TAX
 LDY #&00
.round
 LDA (indir),Y
 JSR oswrch
 INY
 DEX
 BNE round
 RTS

.sqeze_bytes
 EQUD &100
 EQUD &00
 EQUD &00
 EQUD &00
 EQUD &5028100
 EQUD &9010000
 EQUD &508
 EQUD &82000404

.vectr                                  ;vector store
 EQUW &00

.save_a_reg  EQUB &00
.save_x_reg  EQUB &00
.save_y_reg  EQUB &00
.flaps       EQUB &00
.sqeze_count EQUB &00
.sqeze_addrs EQUW lomem
.sqeze_masks EQUW &00
.sqeze_store EQUW &00
.sqeze_works EQUB &00

.patch_character                        ;patch in reduced width character printing for oswrch
 STA save_a_reg
 STX save_x_reg
 STY save_y_reg
 LDA flaps
 BNE traps
 LDA sqeze_count
 BNE not_zero
 LDA save_a_reg
 CMP #&20                               ;>= space
 BCS chars                              ;handle in game
 TAY
 LDA sqeze_bytes,Y
 AND #&0F
 STA sqeze_count
 LDA sqeze_bytes,Y
 BPL wings
 STY flaps
.wings                                  ;not character trap, use o/s
 LDA save_a_reg
 LDX save_x_reg
 LDY save_y_reg
 JMP (vectr)

.not_zero
 LDA save_a_reg
 DEC sqeze_count
 JMP (vectr)

.traps
 LDX sqeze_count
 LDA save_a_reg
 STA sqeze_store - &01,X
 DEC sqeze_count
 BNE wings
 LDA flaps
 CMP #31
 BNE cotin
 LDA sqeze_store + &01
 ASL A
 ASL A
 ASL A
 ROL sqeze_addrs + &01
 STA sqeze_addrs
 LDA sqeze_addrs + &01
 AND #&01
 ADC sqeze_store
 ADC #HI(lomem)
 STA sqeze_addrs + &01
.comms
 LDA #&00
 STA flaps
 LDA save_a_reg
 LDX save_x_reg
 LDY save_y_reg
 JMP (vectr)

.cotin
 LDA sqeze_store
 ROL A
 ROL A
 AND #&01
 TAX
 LDA sqeze_store
 AND #&0F
 STA sqeze_masks,X
 JMP comms

.chars                                  ;print out reduced width characters taking
 SEC                                    ;precedence over the operating system through oswrch
 SBC #&20                               ;calculate index into character table
 PHA
 CMP #95
 BNE nodel
 LDA sqeze_addrs
 SEC
 SBC #&08
 STA sqeze_addrs
 LDA sqeze_addrs + &01
 SBC #&00
 CMP #HI(lomem)                         ;check to see if wrapped around screen memory
 BCS lower
 LDA #HI(himem)
.lower
 STA sqeze_addrs + &01
 LDA #&00
.nodel
 ASL A
 ROL trubl + &01
 ASL A
 ROL trubl + &01
 ASL A
 ROL trubl + &01
 STA trubl
 CLC
 LDA trubl + &01
 AND #&07
 ADC #&12
 STA trubl + &01
 LDA sqeze_addrs
 STA teeth
 LDA sqeze_addrs + &01
 STA teeth + &01
 LDY #&07                               ;print out the reduced width character
.celit
 LDA (trubl),Y
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 PHA
 LDA table,X
 LDX sqeze_masks
 AND sqeze_small,X
 STA sqeze_works
 PLA
 EOR #&0F
 TAX
 LDA table,X
 LDX sqeze_masks + &01
 AND sqeze_small,X
 ORA sqeze_works
 STA (teeth),Y
 DEY
 BPL celit
 PLA
 CMP #95
 BEQ delete
 LDA sqeze_addrs
 CLC
 ADC #&08
 STA sqeze_addrs
 LDA sqeze_addrs + &01
 ADC #&00
 BPL sqeze_wraps
 LDA #HI(lomem)
.sqeze_wraps
 STA sqeze_addrs + &01
.delete
 LDA save_a_reg
 LDX save_x_reg
 LDY save_y_reg
 RTS

.table
 EQUD &33221100
 EQUD &77665544
 EQUD &BBAA9988
 EQUD &FFEEDDCC
.sqeze_small
 EQUD &FFF00F00

; make_sound

.color                                  ;map colour table store
 EQUB &00                               ;default colours
 EQUB &04
 EQUB &03
 EQUB &02

.decimal_convert                        ;convert passed binary in tempa/tempx
 LDA #31                                ;into decimal and print out beiggining at tab x/y
 JSR oswrch
 TXA
 JSR oswrch
 TYA
 JSR oswrch
 LDA #17
 JSR oswrch
 LDA #&02
 JSR oswrch
 LDX #&00
.volum                                  ;divide tempa/tempx by 10
 LDY #&10
 LDA #&00
.shape
 ASL tempa
 ROL tempx
 ROL A
 CMP #10
 BCC slipy
 SBC #10
 INC tempa
.slipy
 DEY
 BNE shape
 PHA
 INX
 LDA tempa
 ORA tempx
 BNE volum
.words
 PLA                                    ;retrieve byte and convert to ascii number
 CLC
 ADC #48
 JSR oswrch
 DEX
 BNE words
.silen
 RTS

.noise                                  ;sound block information
 EQUW &11
 EQUW 1
 EQUW 200
 EQUW 20

 EQUW &10
 EQUW -8
 EQUW 4
 EQUW 7

 EQUW &10
 EQUW -10
 EQUW 0
 EQUW 4

 EQUW &11
 EQUW 1
 EQUW 100
 EQUW 10

 EQUW &10
 EQUW -15
 EQUW 2
 EQUW 3

 EQUW &10
 EQUW -12
 EQUW 6
 EQUW 3

 EQUW &11
 EQUW 3
 EQUW 50
 EQUW 15

 EQUW &10
 EQUW 4
 EQUW 5
 EQUW 4

 EQUW &10
 EQUW -15
 EQUW 1
 EQUW 3

 EQUW &11
 EQUW -15
 EQUW 80
 EQUW &02

 EQUW &10                               ;countdown
 EQUW -12
 EQUW &00
 EQUW &04

.make_sound
 LDX gates                              ;exit if sound off
 BNE silen
 LDY #HI(noise)
 ASL A
 ASL A
 ASL A
 ADC #LO(noise)                         ;c=0
 BCC no_noise_inc
 INY
.no_noise_inc
 TAX
 LDA #&07
 JMP osword                             ;make the sound

.get_colours_from_map                   ;get four physical colours from map and store
 LDA grids                              ;map number * 4
 ASL A
 ASL A
 TAX
 LDY #&00
.get_colours
 LDA map_physical_colours,X             ;get colour from map file
 STA color,Y                            ;store in table
 INX
 INY
 CPY #&04
 BCC get_colours                        ;roll into routine below

.set_screen_colours                     ;get physical colours from saved colours and set screen
 LDA #19                                ;wait for vertical sync
 JSR osbyte
 LDX #&03                               ;change all four colours
.physical
 LDA #19
 JSR oswrch
 TXA
 JSR oswrch
 LDA color,X                            ;get physical colour
 JSR oswrch
 LDA #&00
 JSR oswrch
 JSR oswrch
 JSR oswrch
 DEX
 BPL physical
 RTS

.escape_kill_repton                     ;test for escape key and kill repton if pressed
 LDX #bbc_escape
 JSR read_a_passed_key
 BPL escape_kill_repton_exit
 INC death
.escape_kill_repton_exit
 RTS

.ticks
 EQUB &09
.toggl
 EQUB &00

.countdown                              ;check for last part of timer
 LDA watch + &01                        ;high byte > 0
 BNE escape_kill_repton_exit            ;yes, exit
 DEC ticks
 BNE escape_kill_repton_exit
 LDA #&09
 STA ticks
 INC toggl
 LDY #&07
 LDA toggl
 AND #&01
 BNE selet                              ;flash toggle
 LDA grids                              ;get colour 0 from map
 ASL A
 ASL A
 TAX
 LDY map_physical_colours,X
.selet
 STY fasts + &01
 LDA #19                                ;wait then flash screen white
 JSR osbyte
 LDX #LO(fasts)                         ;fast colour change using osword
 LDY #HI(fasts)
 LDA #&0C
 JSR osword
 LDA toggl
 AND #&01
 BEQ escape_kill_repton_exit
 LDA #10
 JMP make_sound                         ;countdown sound

.fasts                                  ;colour change block
 EQUD &00
 EQUB &00

.test_space_key                         ;test space and joystick
 LDY #&00                               ;y=vector code
 BIT combined_bbc_l_key                 ;load file?
 BMI test_space_exit                    ;yes
 INY
 BIT combined_bbc_p_key                 ;enter password?
 BMI test_space_exit                    ;yes
 INY
 BIT combined_bbc_space_key             ;play game?
 BMI test_space_exit                    ;yes
 LDA #128                               ;read joystick
 LDX #&00
 JSR osbyte
 TXA
 AND #&01                               ;fire button?
 BNE keyin                              ;yes, play game
 LDY #&FF                               ;nothing happening
 RTS
.keyin                                  ;play game
 LDY #&02
 RTS
.test_space_exit
 RTS
