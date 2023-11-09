; rocks

.rock_maintenance                       ;control all rocks in map
 LDX #&00
 STX pages + &04
 LDA repty
 STA pages + &01
 JSR rocks_lines
 LDY repty
 DEY
 DEY
 STY pages + &01
 JSR rocks_lines                        ;test rocks on repton's row and fall if any can fall
 LDA kicks                              ;is repton moving a rock?
 BNE exit_rocks                         ;yes so exit
 LDY repty
 DEY
 STY pages + &01
 JSR rocks_lines
 DEC quart                              ;scan a quarter of the map at a time, as too
 LDA quart                              ;slow to scan all the map for rocks at once
 AND #&03                               ;scan from bottom to top
 TAX
 LDA piece,X                            ;get starting point
 STA pages + &01
 LDX #&05
 STX pages + &04
.rocks_lines
 LDA #27                                ;map x coordinate
 STA pages + &00
.cross
 LDA pages + &01                        ;map y coordinate
 LDX pages + &00
 JSR get_map_byte
 TAX                                    ;is it a rock?
 BEQ drops                              ;yes
 CMP #24
 BNE bashm
.drops
 STA worka
 JSR check_hit_monsters                 ;check hit a monster
 LDX pages + &00
 LDY pages + &01
 INY
 TYA
 JSR get_map_byte                       ;get map byte at this location
 TAY
 LDX reason,Y                           ;get reason/jump code
 BEQ resume                             ;do nothing
 LDA #HI(resume - &01)                  ;push resume address on stack
 PHA
 LDA #LO(resume - &01)
 PHA
 LDA polyc + &01,X
 PHA
 LDA polyc,X
 PHA
 RTS                                    ;execute reason routine

.resume
 JSR check_hit_monsters                 ;check hit a monster
.bashm
 DEC pages + &00
 BPL cross
 INC pages + &01
 LDY repty
 CPY pages + &01
 BNE rocks
 INC pages + &01
.rocks
 DEC pages + &04
 BPL rocks_lines
.exit_rocks
 RTS

.piece                                  ;starting point
 EQUB &00
 EQUB &06
 EQUB &0C
 EQUB &12

.polyc                                  ;vector table of routines
 EQUW exit_rocks               - &01
 EQUW rock_falling             - &01
 EQUW rock_fall_left_and_right - &01
 EQUW rock_fall_left           - &01
 EQUW rock_fall_right          - &01

.reason
 EQUB &02 << &01
 EQUB &02 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &02 << &01
 EQUB &02 << &01
 EQUB &01 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &03 << &01
 EQUB &04 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &03 << &01
 EQUB &04 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &02 << &01
 EQUB &02 << &01
 EQUB &00 << &01
 EQUB &02 << &01
 EQUB &00 << &01
 EQUB &02 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01
 EQUB &00 << &01

.rock_falling
 JSR move_rock
 LDX pages + &00
 LDY pages + &01
 INY
 JSR stone
 LDX pages + &00
 LDY pages + &01
 INY
 INY
 TYA
 JSR get_map_byte
 CMP #code_repton
 BEQ bonk_on_head
 RTS

.rock_fall_left_and_right
 LDA kicks
 BNE nears
 LDX pages + &00
 DEX
 LDA pages + &01
 JSR get_map_byte
 CMP #code_space
 BNE rock_fall_right
 LDX pages + &00
 DEX
 LDY pages + &01
 INY
 TYA
 JSR get_map_byte
 CMP #code_space
 BNE rock_fall_right
 JSR move_rock
 LDX pages + &00
 DEX
 LDY pages + &01
 INY
 JSR stone
 LDX pages + &00
 DEX
 LDY pages + &01
 INY
 INY
 TYA
 JSR get_map_byte                       ;get map byte to see if repton
 CMP #code_repton
 BEQ bonk_on_head                       ;it's repton so kill him
 INC pages + &01
 INC pages + &01
 RTS

.bonk_on_head
 INC death
.nears
 RTS

.rock_fall_left
 LDX pages + &00
 DEX
 LDA pages + &01
 JSR get_map_byte
 CMP #code_space
 BNE nears
 LDX pages + &00
 DEX
 LDY pages + &01
 INY
 TYA
 JSR get_map_byte
 CMP #code_space
 BNE nears
 JSR move_rock
 LDX pages + &00
 DEX
 LDY pages + &01
 INY
 JSR stone
 LDX pages + &00
 DEX
 LDY pages + &01
 INY
 INY
 TYA
 JSR get_map_byte
 CMP #code_repton
 BEQ bonk_on_head
 INC pages + &01
 INC pages + &01
 RTS

.rock_fall_right
 LDX pages + &00
 INX
 LDA pages + &01
 JSR get_map_byte
 CMP #code_space
 BNE nears
 LDX pages + &00
 INX
 LDY pages + &01
 INY
 TYA
 JSR get_map_byte
 CMP #code_space
 BNE nears
 JSR move_rock
 LDX pages + &00
 INX
 LDY pages + &01
 INY
 JSR stone
 LDX pages + &00
 INX
 LDY pages + &01
 INY
 INY
 TYA
 JSR get_map_byte
 CMP #code_repton                       ;is it repton?
 BEQ bonk_on_head                       ;yes
 INC pages + &01
 INC pages + &01
.nifes
 RTS

.stone
 STX pages + &02
 STY pages + &03
 LDA worka
 STA paras
 JSR write_map_byte
 LDA pages + &02
 STA tempa
 LDA pages + &03
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 JSR calculate_sprite_plot_mask
 BCS hatch
 JSR eor_a_sprite
 LDA #code_space
 STA paras
 JSR eor_a_sprite
.hatch
 LDA worka
 CMP #24
 BNE nifes
 LDX pages + &02
 LDY pages + &03
 INY
 TYA
 JSR get_map_byte
 CMP #code_space
 BEQ nifes
 LDA #47
 STA paras
 LDX pages + &02
 LDY pages + &03
 JSR write_map_byte
 LDA pages + &02
 STA tempa
 LDA pages + &03
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 JSR calculate_sprite_plot_mask         ;is sprite on?
 BCS depth                              ;no
 JSR eor_a_sprite
 LDA #24
 STA paras
 JSR eor_a_sprite
.depth
 LDX #&03
.lucid
 LDA anoth,X
 BPL stein
 LDA #&20
 STA anoth,X
 LDA pages + &02
 STA xcoor,X
 LDA pages + &03
 STA ycoor,X
 LDA #&04
 JMP make_sound
.stein
 DEX
 BPL lucid
 RTS

.move_rock
 LDA #&01
 JSR make_sound
 LDA #code_space
 STA paras + &00
 LDX pages + &00
 LDY pages + &01
 JSR write_map_byte
 LDA pages + &00
 STA tempa
 LDA pages + &01
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 JSR calculate_sprite_plot_mask
 BCS rocks_other
 JSR eor_a_sprite                       ;erase previous rock position
 LDA worka
 STA paras + &00
 JMP eor_a_sprite

.check_hit_monsters                     ;check rock has hit any of the active monsters
 LDX #&03
.hit_monster_loop
 LDA anoth,X                            ;monster on?
 BNE no_monster                         ;no
 LDA xcoor,X
 CMP pages + &00
 BNE no_monster
 LDA ycoor,X
 CMP pages + &01
 BNE no_monster
 LDA #20                                ;add 20 points
 CLC
 ADC score + &00
 STA score + &00
 LDA #&00
 ADC score + &01
 STA score + &01
 DEC monst                              ;decrease number of monsters
 DEC anoth,X                            ;kill monster
 STX aloof                              ;save index
 LDA #&05
 JSR make_sound
 LDX aloof
 INC wait_flag
 JSR eor_a_monster_no_check             ;x=aloof on exit
.no_monster
 DEX
 BPL hit_monster_loop
.rocks_other
 RTS

.rocks_finis
 EQUW &011F
 EQUB 14
 EQUS "Amazing, you have completed all"
 EQUW &011F
 EQUB 16
 EQUS "the screens."
 EQUW &011F
 EQUB 18
 EQUS "To enter the competition, make a"
 EQUW &011F
 EQUB 20
 EQUS "note of the number below and"
 EQUW &011F
 EQUB 22
 EQUS "which set of screens you used."
 EQUW &0211
 EQUW &071F
 EQUB 25
 EQUS "COMPETITION NUMBER"
 EQUW &0B1F
 EQUB 27
.nofin
 EQUW &31F
 EQUB 14
 EQUS "Now try and do that from the"
 EQUW &21F
 EQUB 16
 EQUS "start without using any of the"
 EQUW &031F
 EQUB 18
 EQUS "passwords and picking up all"
 EQUW &081F
 EQUB 20
 EQUS "the eight crowns."
.rocks_retun
 EQUW &0111
 EQUW &051F
 EQUB 30
 EQUS "Press       to continue"
 EQUW &061F
 EQUB 11
 EQUS "HAS BEEN COMPLETED ''"
 EQUW &0211
 EQUW &0B1F
 EQUB 30
 EQUS "SPACE"
 EQUW &0311

.congratulations_finished               ;finished all maps
 JSR setup_custom_mode
 JSR all_colours_to_black
 JSR print_repton_sign
 LDX #LO(rocks_retun)
 LDY #HI(rocks_retun)
 LDA #congratulations_finished-rocks_retun
 JSR write_characters
 LDA tiara
 CMP #&08
 BCC nonum
 LDA userp
 BNE nonum
 LDX #LO(rocks_finis)
 LDY #HI(rocks_finis)
 LDA #nofin-rocks_finis
 JSR write_characters
 LDA score
 STA tempa
 LDA score + &01
 STA tempx
 LDA #LO(map_passwords)
 STA indir
 LDA #HI(map_passwords)
 STA indir + &01
 LDA #&FF
 STA tempy
 LDA #&EE
 STA tempz
 LDY #&00
.chexs
 LDA (indir),Y
 EOR tempy
 STA tempy
 EOR tempz
 STA tempz
 INY
 BNE chexs
 INC indir
 LDA indir
 CMP #&40
 BCC chexs
 LDX #&00
.rocks_volum
 LDY #32
 LDA #&00
.rocks_shape
 ASL tempa
 ROL tempx
 ROL tempy
 ROL tempz
 ROL A
 CMP #10
 BCC rocks_slipy
 SBC #10
 INC tempa
.rocks_slipy
 DEY
 BNE rocks_shape
 PHA
 INX
 LDA tempa
 ORA tempx
 ORA tempy
 ORA tempz
 BNE rocks_volum
.rocks_words
 PLA
 CLC
 ADC #48
 JSR oswrch
 DEX
 BNE rocks_words
 JMP waits

.nonum                                 ;repton end screen
 LDX #LO(nofin)
 LDY #HI(nofin)
 LDA #rocks_retun - nofin
 JSR write_characters
.waits
 JSR get_colours_from_map
.rocks_press                           ;wait until space key pressed
 LDX #bbc_space_key
 JSR read_a_passed_key
 BPL rocks_press
 JMP rotate_all_screen_bytes

.barit
 EQUB &00
.barrs
 EQUB &00
.notes
 EQUB &00
.black
 EQUW music_bar_01
 EQUW music_bar_02
 EQUW music_bar_03
 EQUW music_bar_04
 EQUW music_bar_05
 EQUW music_bar_06
 EQUW music_bar_07
 EQUW music_bar_08

.play_repton_music                      ;music
 LDA barit                              ;secondary music control, enabled?
 BNE diabl                              ;no
 LDA tunes
 BNE rocks_silent
 LDA barrs                              ;get current music position
 ASL A
 TAX
 LDA black,X
 STA index
 LDA black + &01,X
 STA index + &01
 LDY notes
 LDA (index),Y
 JSR decode
 STA channel_02 + &04
 LDA notes
 CLC
 ADC #&10
 TAY
 LDA (index),Y
 JSR decode
 STA channel_03 + &04
 LDA channel_02 + &04
 CMP #&FF
 BEQ resto
 LDX #LO(channel_02)
 LDY #HI(channel_02)
 LDA #&07
 JSR osword
.resto
 LDA channel_03 + &04
 CMP #&FF
 BEQ rocks_silent
 LDX #LO(channel_03)
 LDY #HI(channel_03)
 LDA #&07
 JSR osword
.rocks_silent
 INC notes
 LDA notes
 CMP #&10
 BCC diabl
 LDA #&00
 STA notes
 INC barrs
 LDA barrs
 AND #&07
 STA barrs
.diabl
 RTS

.decode                                 ;decode the music data
 PHA
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 PLA
 AND #&0F
 TAY
 LDA octave_00,Y
 CMP #&FF
 BEQ diabl
 CPX #&00
 BEQ diabl
.addup
 CLC
 ADC #48
 DEX
 BNE addup
 RTS

.channel_02
 EQUW &12
 EQUW &02
 EQUW &00
 EQUW &01

.channel_03
 EQUW &13
 EQUW &02
 EQUW &00
 EQUW &01

.octave_00
 EQUB 49
 EQUB 45
 EQUB 41
 EQUB 37
 EQUB 33
 EQUB 29
 EQUB 25
 EQUB 21
 EQUB 17
 EQUB 13
 EQUB 9
 EQUB 5
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF

.final
 EQUW &0311
 EQUW &021F
 EQUB &05
 EQUS "REPTON 3 Redux"
 EQUW &071F
 EQUB &07
 EQUS "the story has finished..."
 EQUW &0111
 EQUW &091F
 EQUB 15
 EQUS "SCORE :"

.final_repton
 JSR setup_custom_mode
 JSR get_colours_from_map
 LDX #LO(final)
 LDY #HI(final)
 LDA #final_repton - final
 JSR write_characters
 LDA score
 STA tempa
 LDA score + &01
 STA tempx
 LDX #17
 LDY #15
 JSR decimal_convert
 LDX #100
 JSR wait_state
 JMP rotate_all_screen_bytes
