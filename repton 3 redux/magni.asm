; magni

.expand_screen_shimmer
 LDA #21                                ;reload repton idle counter
 STA shift
 LDX #&07                               ;zeroise spirit movement, makes for easier calculations
.zeroise_spirit_movement                ;when placing on in screen reveal
 LDA spirc,X                            ;check spirit counter
 BEQ already_in_square                  ;no need to alter spirit flag
 DEC spirit_flags,X                     ;set flag for spirit movement
 LDA #&00
 STA spirc,X                            ;clear movement counter
.already_in_square
 DEX
 BPL zeroise_spirit_movement
 LDX #&03                               ;monsters as per spirits
 LDA #&00
.zeroise_monster_movement
 STA monsc,X
 DEX
 BPL zeroise_monster_movement
 LDA #17
 STA pages + &00
 LDA #&01
 STA pages + &01
.magni_capit_transporter
 LDA pages + &00
 STA sidex
 STA sidey
 LDX #&03
 STX pages + &02
.magni_square_shimmer
 JSR expand_sides
 JSR trek_repton                        ;put repton on trek-esque style
 DEC pages + &02
 BPL magni_square_shimmer
 INC pages + &01
 INC pages + &01
 DEC pages + &00
 LDA pages + &00
 CMP #&02
 BCS magni_capit_transporter
 RTS

.map_coordinate_x
 EQUB &00
.map_coordinate_y
 EQUB &00

.expand_sides
 LDX pages + &01
.magni_lines
 TXA
 PHA
 LDA sidex
 LSR A
 LSR A
 STA tempa
 LDA reptx
 SEC
 SBC #&04
 CLC
 ADC tempa
 TAX
 LDA sidey
 LSR A
 LSR A
 STA tempa
 LDA repty
 SEC
 SBC #&04
 CLC
 ADC tempa
 STX map_coordinate_x                   ;save map coordinates for testing with monsters/spirits
 STA map_coordinate_y
 JSR get_map_byte
 STA paras + &00
 LDA sidex
 AND #&FC
 ORA #&01
 STA paras + &01
 LDA sidey
 AND #&FC
 ORA #&01
 STA paras + &02
 LDA sidex
 AND #&03
 TAX
 LDA tabbx,X
 STA paras + &03
 LDA sidey
 AND #&03
 TAY
 LDA tabbx,Y
 STA paras + &04
 JSR place_a_sprite                     ;place the map sprite on screen
 JSR monster_spirit_reveal              ;any monsters/spirits to plot?
 LDX pages + &02
 LDA sidex
 CLC
 ADC magni_xdire,X
 STA sidex
 LDA sidey
 CLC
 ADC magni_ydire,X
 STA sidey
 PLA
 TAX
 DEX
 BNE magni_lines
 RTS

.monster_spirit_reveal
 LDX #&03                               ;test if any monsters need to be plotted
.test_for_monsters
 LDA anoth,X                            ;monster on?
 BNE not_monster
 LDA xcoor,X
 CMP map_coordinate_x
 BNE not_monster
 LDA ycoor,X
 CMP map_coordinate_y
 BNE not_monster
 LDA framc,X                            ;monster animation sprite
 STA paras + &00
 TXA
 PHA
 JSR eor_a_sprite
 PLA
 TAX
.not_monster
 DEX
 BPL test_for_monsters
 LDX #&07                               ;test if any spirits need to be plotted
.test_for_spirits
 LDA spirp,X
 BMI not_spirit
 LDA spirx,X
 CMP map_coordinate_x
 BNE not_spirit
 LDA spiry,X
 CMP map_coordinate_y
 BNE not_spirit
 LDA spirf,X                            ;spirit animation sprite
 STA paras + &00
 TXA
 PHA
 JSR eor_a_sprite
 PLA
 TAX
.not_spirit
 DEX
 BPL test_for_spirits
 RTS

.magni_xdire
 EQUB &00
.magni_ydire
 EQUB &FF
 EQUB &00
 EQUB &01
 EQUB &00

.tabbx
 EQUB &08
 EQUB &04
 EQUB &02
 EQUB &01

.find_byte_in_map                       ;a = byte to find
 STA tempy
 LDX #23
.fresh_row
 LDY #27
 LDA times28_lsb,X
 STA tempa
 LDA times28_msb,X
 STA tempx
 LDA tempy                              ;byte to search for
.search_row
 CMP (tempa),Y
 BEQ grabs                              ;found byte so exit
 DEY
 BPL search_row
 DEX
 BPL fresh_row
 INX                                    ;x/y = 0
 INY
 CLC                                    ;not found so exit, c=0
 RTS

.grabs                                  ;found byte, return x,y coordinates, swap x/y
 TYA                                    ;x << y
 LDY identity_table,X                   ;y << x
 TAX
 SEC                                    ;found so exit, c=1
 RTS

.find_repton_in_map                     ;find repton, if not found store repton at 0,0
 LDA #code_repton
 JSR find_byte_in_map
 STX reptx                              ;store in repton x/y and copyx/y
 STX copyx
 STY repty
 STY copyy
 LDA #code_repton                       ;store repton in map at 0,0 or found coordinates
 JMP write_map_byte

.where                                  ;parameter block for unpack
 EQUW map_table
 EQUW &00
 EQUB 84

.map_address_list_lsb
 EQUB LO(map_address_start)
 EQUB LO(map_address_start + (map_compressed_size * &01))
 EQUB LO(map_address_start + (map_compressed_size * &02))
 EQUB LO(map_address_start + (map_compressed_size * &03))
 EQUB LO(map_address_start + (map_compressed_size * &04))
 EQUB LO(map_address_start + (map_compressed_size * &05))
 EQUB LO(map_address_start + (map_compressed_size * &06))
 EQUB LO(map_address_start + (map_compressed_size * &07))

.map_address_list_msb
 EQUB HI(map_address_start)
 EQUB HI(map_address_start + (map_compressed_size * &01))
 EQUB HI(map_address_start + (map_compressed_size * &02))
 EQUB HI(map_address_start + (map_compressed_size * &03))
 EQUB HI(map_address_start + (map_compressed_size * &04))
 EQUB HI(map_address_start + (map_compressed_size * &05))
 EQUB HI(map_address_start + (map_compressed_size * &06))
 EQUB HI(map_address_start + (map_compressed_size * &07))

.get_map_data_into_buffer               ;get address of map and unpack data to map buffer
 LDX grids                              ;current map number
 LDA map_address_list_lsb,X
 STA where + &02
 LDA map_address_list_msb,X
 STA where + &03
 LDX #LO(where)                         ;unpack map bytes
 LDY #HI(where)
 STX tempa
 STY tempx
 LDX #&04
 LDY #&04
.trans                                  ;transfer a block of four bytes
 LDA (tempa),Y
 STA pages,X
 DEY
 DEX
 BPL trans
.mishs
 LDY #&04
.quatr
 LDA (pages + &02),Y
 STA sorks,Y
 DEY
 BPL quatr
 INY
.relod
 LDA #&05
 STA pages + &05
.again
 LDX #&04
.rotat
 ROR sorks,X
 DEX
 BPL rotat
 ROR A
 DEC pages + &05
 BNE again
 LSR A
 LSR A
 LSR A
 STA works,Y
 INY
 CPY #&08
 BCC relod
 LDY #&07
.strch
 LDA works,Y
 STA (pages),Y
 DEY
 BPL strch
 LDA pages + &00
 CLC
 ADC #&08
 STA pages + &00
 BCC crate
 INC pages + &01
.crate
 LDA pages + &02
 CLC
 ADC #&05
 STA pages + &02
 BCC crabs
 INC pages + &03
.crabs
 DEC pages + &04
 BNE mishs
 RTS

; jingl

.jingle_notes                           ;note/length
 EQUB 96
 EQUB 10
 EQUB 108
 EQUB 5
 EQUB 96
 EQUB 10
 EQUB 96
 EQUB 10
 EQUB 108
 EQUB 5
 EQUB 96
 EQUB 10
 EQUB 100
 EQUB 5
 EQUB 108
 EQUB 5
 EQUB 100
 EQUB 5
 EQUB 88
 EQUB 10
 EQUB 96
 EQUB 5
 EQUB 100
 EQUB 5
 EQUB 96
 EQUB 5
 EQUB 80
 EQUB 10
.jingle_end

.jingle                                 ;play short jingle at game start
 LDA tunes                              ;exit to wait if music turned off
 BNE no_jingle
 LDA #((jingle_end - jingle_notes) / &02) - &01
 STA tempa
.jingle_loop
 LDA #&80                               ;read sound channel 2 space
 LDX #&F9
 JSR osbyte
 CPX #&04                               ;space in buffer?
 BCC jingle_loop
 LDA #((jingle_end - jingle_notes) / &02 ) - &01
 SBC tempa                              ;c=1
 ASL A                                  ;c=0
 TAX
 LDA jingle_notes,X
 ADC #24
 STA melody + &04
 LDA jingle_notes + &01,X
 LSR A
 STA melody + &06
 LDX #LO(melody)                        ;make the note
 LDY #HI(melody)
 LDA #&07
 JSR osword
 DEC tempa
 BPL jingle_loop
 RTS
.no_jingle
 LDX #100
 JMP wait_state

.melody
 EQUW &02
 EQUW &01
 EQUW &00
 EQUW &03

; chart

.messa_chart
 EQUW &111
 EQUW &C1F
 EQUB &01
 EQUS "SCREEN"
 EQUW &71F
 EQUB 30
 EQUS "Press       to PLAY"
 EQUW &211
 EQUW &D1F
 EQUB 30
 EQUS "SPACE"
 EQUW &131F
 EQUB &01
.pokes                                  ;map letter
 EQUB 32
.messa_chart_end

.display_map
 LDA grids                              ;convert map binary to ascii letter
 CLC
 ADC #65
 STA pokes
 JSR all_colours_to_black
 JSR setup_custom_mode
 LDA #24
 STA pages + &05
 LDA #25
 STA pages + &07
.relod_chart
 LDA #28
 STA pages + &04
 LDA #29
 STA pages + &06
.small
 LDA pages + &05
 ASL A
 TAY
 LDX pages + &04
 LDA pages + &05
 JSR get_map_byte
.mottl
 LDX pages + &04
 INX
 INX
 LDY pages + &05
 INY
 INY
 INY
 INY
 JSR write_map_graphic
 DEC pages + &04
 DEC pages + &06
 BPL small
 DEC pages + &05
 DEC pages + &07
 BPL relod_chart
 LDX #LO(messa_chart)                   ;surrounding text
 LDY #HI(messa_chart)
 LDA #messa_chart_end - messa_chart
 JSR write_characters
 JMP get_colours_from_map

.effects                                ;check timer and fill screen with blocks if
 LDA watch                              ;it's timed out
 ORA watch + &01
 BNE cords
 LDX #61
.effxs
 TXA
 PHA
 LDY #&29
 LDX #&00
.chart_loops
 TYA
 LDY randu,X
 ADC randu,X
 STA randu,X
 INX
 CPX #&04
 BCC chart_loops
 LDA randu + &01
 AND #31
 TAX
 LDA randu + &02
 AND #31
 TAY
 LDA #48
 JSR write_map_graphic
 PLA
 TAX
 DEX
 BPL effxs
.cords
 LDX #&08
 JMP wait_state

; topps

.xadin
 EQUB &01
 EQUB &FF
 EQUB &00
 EQUB &00

.yadin
 EQUB &00
 EQUB &00
 EQUB &FF
 EQUB &01

.fungus_spread
 DEC slows
 BNE fungy
 LDA #&04
 STA slows
 DEC twent
 BPL justr
 LDA #23
 STA twent
.justr
 LDX #27
 STX pages + &02
.mushy
 LDA twent
 LDX pages + &02
 JSR get_map_byte
 CMP #26
 BNE spore
 LDA randy
 AND #&03
 TAY
 LDA xadin,Y
 CLC
 ADC pages + &02
 STA pages + &00
 TAX
 LDA yadin,Y
 CLC
 ADC twent
 STA pages + &01
 JSR get_map_byte
 CMP #26
 BEQ spore
 CMP #&02
 BEQ can_spread_here
 CMP #&03
 BEQ can_spread_here
 CMP #code_space
 BEQ can_spread_here
 CMP #code_repton
 BEQ kill_repton                        ;grown onto repton
.spore
 DEC pages + &02
 BPL mushy
.fungy
 RTS

.can_spread_here                        ;found a place it can spread into
 STA paras + &00
 LDA #26
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
 JSR calculate_sprite_plot_mask         ;calculate if on screen
 BCS fungy                              ;spreading out of view
 LDA #&00
 STA wait_flag
 JSR wait_quarter_screen
 JSR eor_a_sprite                       ;remove what's there
 LDA #code_fungus
 STA paras + &00
 JMP eor_a_sprite                       ;place fungus

.kill_repton
 INC death
 RTS

.repton_x_coordinate                    ;calculate repton x fine coordinate
 LDA reptx                              ;x 4 + 1
 ASL A
 SEC
 ROL A
 LDX sting
 CPX #&02                               ;going up/down?
 BCS repton_x_exit                      ;yes, exit
 DEX                                    ;0?
 BMI topps_posit                        ;yes, c=0
 SEC
 SBC movie
 STA paras + &01
 RTS

.topps_posit
 ADC movie                              ;c=0, a=paras + &01
.repton_x_exit
 STA paras + &01
 RTS

.repton_y_coordinate                    ;calculate repton y fine coordinate
 LDA repty                              ;x 4 + 1
 ASL A
 SEC
 ROL A
 LDX sting
 CPX #&02                               ;going left/right?
 BCC repton_y_exit                      ;yes, exit
 BNE upper                              ;direction 01
 SBC movie                              ;c=1, a=paras + &02
 STA paras + &02
 RTS

.upper
 CLC                                    ;a=paras + &02
 ADC movie
.repton_y_exit
 STA paras + &02
 RTS

.sprite_x_coordinate                    ;calculate sprite x fine coordinate
 LDA tempa                              ;x 4 + 1
 ASL A
 SEC
 ROL A
 LDX tempz
 CPX #&02
 BCS exit_sprite_x_coordinate
 DEX                                    ;x=1?
 BPL zeros                              ;yes
 ADC tempx                              ;c=0, a=tempa
 STA tempa
 RTS

.zeros
 SEC
 SBC tempx
.exit_sprite_x_coordinate
 STA tempa
 RTS

.sprite_y_coordinate                    ;calculate sprite y fine coordinate
 LDA tempy                              ;x 4 + 1
 ASL A
 SEC
 ROL A
 LDY tempz
 CPY #&02
 BCC exit_sprite_y_coordinate
 BEQ douze                              ;c=1
 CLC
 ADC tempx
.exit_sprite_y_coordinate
 STA tempy
 RTS

.douze
 SBC tempx                              ;c=1, a=tempy
 STA tempy
 RTS

.topps_masks
 EQUB &01
 EQUB &03
 EQUB &07
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0F
 EQUB &0E
 EQUB &0C
 EQUB &08

.transform_safe_to_diamond
 LDA #code_safe                         ;find safe
 JSR find_byte_in_map
 BCC opens                              ;c=0 not found
 STX paras + &01
 STY paras + &02
 LDA #code_diamond
 STA paras + &00
 JSR write_map_byte
 LDA paras + &01
 STA tempa
 LDA paras + &02
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 JSR calculate_sprite_plot_mask
 BCS transform_safe_to_diamond          ;c=1 off screen
 JSR place_a_sprite                     ;place it on screen
 JMP transform_safe_to_diamond          ;keep looking

.calculate_sprite_plot_mask
 JSR repton_x_coordinate
 JSR repton_y_coordinate
 JSR sprite_x_coordinate
 JSR sprite_y_coordinate
 LDA paras + &01
 SEC
 SBC #&11
 STA paras + &01
 LDA tempa
 SEC
 SBC paras + &01
 CMP #&23
 BCS opens
 STA paras + &01
 STA indir
 TAX
 LDA topps_masks,X
 STA paras + &03
 LDA paras + &02
 SEC
 SBC #&11
 STA paras + &02
 LDA tempy
 SEC
 SBC paras + &02
 CMP #&23
 BCS opens
 STA paras + &02
 STA indir + &01
 TAY
 LDA topps_masks,Y
 STA paras + &04                        ;c=0
.opens
 RTS
