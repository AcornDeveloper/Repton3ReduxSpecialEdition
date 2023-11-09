; reptn

.repton_hopin                           ;repton sprites looking around
 EQUB 30
 EQUB 35
 EQUB 30
 EQUB 36

.ctrlk                                  ;direction keys
 EQUB 66                                ;x
 EQUB 97                                ;z
 EQUB 72                                ;:
 EQUB 104                               ;/

.store
 EQUB &00
 EQUB &00
 EQUB &00

.cover
 EQUB twoes-onnes
 EQUB three-twoes
 EQUB infom-three

.roads
 EQUB &FF
 EQUB &01
 EQUB &00
 EQUB &00
 EQUB &01
 EQUB &FF

.lists_lsb
 EQUB LO(onnes)
 EQUB LO(twoes)
 EQUB LO(three)
.lists_msb
 EQUB HI(onnes)
 EQUB HI(twoes)
 EQUB HI(three)

.onnes
 EQUB 37
 EQUB 37
 EQUB 37
 EQUB 37
 EQUB 37
 EQUB 38
 EQUB 38
 EQUB 39
 EQUB 39
 EQUB 40
 EQUB 40
 EQUB 40
 EQUB 40
 EQUB 40
 EQUB 39
 EQUB 39
 EQUB 38
 EQUB 38

.twoes
 EQUB 41
 EQUB 41
 EQUB 41
 EQUB 41
 EQUB 41
 EQUB 42
 EQUB 42
 EQUB 43
 EQUB 43
 EQUB 44
 EQUB 44
 EQUB 44
 EQUB 44
 EQUB 44
 EQUB 43
 EQUB 43
 EQUB 42
 EQUB 42

.three
 EQUB 45
 EQUB 45
 EQUB 45
 EQUB 45
 EQUB 46
 EQUB 46
 EQUB 46
 EQUB 46

.infom                                  ;translate map object number into an action vector
 EQUD &00000201
 EQUD &80000703
 EQUD &80808080
 EQUD &80808080
 EQUD &80808080
 EQUD &80808080
 EQUD &80070401
 EQUD &80800605
 EQUD &80808080
 EQUD &80808080
 EQUD &80808080
 EQUD &80808080

.reptn_shove
 EQUB 21
 EQUB 13
.reptn_pushs
 EQUB 25
 EQUB 9
.super
 EQUB 2
 EQUB -2

.repton_idler                           ;repton looking around
 DEC shift
 BNE update_rocks
 LDA #21                                ;reload shift counter
 STA shift
 LDA #code_space                        ;setup sprites to use, background frst
 STA paras + &00
 INC cosit                              ;index for repton look around sprites
 LDA cosit
 AND #&03
 TAX
 LDA repton_hopin,X                     ;next repton sprite for looking around
 STA paras + &01
 LDA #17                                ;screen x/y coordinates
 STA paras + &02
 STA paras + &03
 JSR sprite_mask_place                  ;mask repton foreground with background and place on screen
 JMP rock_maintenance

.right
 EQUB &FF
 EQUB &00
 EQUB &00
 EQUB &FF

.chanl
 EQUW &0101
 EQUW &0202

.repton_running
 LDA #19
 JSR osbyte
 LDA #&03                               ;repton moving
 STA sting
 LDA #&00
 STA kicks
.reads
 LDA perip                              ;using joysticks?
 BNE joysk                              ;yes
 LDY sting                              ;test the four repton direction keys in turn
 LDX ctrlk,Y
 JSR read_a_passed_key
 BMI repton_move_route
 JMP lockd

.joysk
 LDY sting
 LDX chanl,Y                            ;read adc channel
 LDA #128
 JSR osbyte
 TYA
 LDX sting
 EOR right,X
 CMP #&A0
 BCS repton_move_route
.lockd
 DEC sting                              ;movement direction
 BPL reads
 LDA mcode                              ;repton looking around
 BEQ repton_idler
 DEC mcode
.update_rocks
 JMP rock_maintenance

.repton_move_route                      ;look at which way repton wants to move
 LDY sting
 LDA reptx                              ;get repton x/y and add in the direction vectors
 CLC
 ADC adjux,Y                            ;x/y direction vectors
 TAX
 LDA repty
 CLC
 ADC adjuy,Y
 JSR get_map_byte                       ;get the map byte for the intended direction
 STA repton_move_to                     ;save map value in repton's path
 TAX                                    ;transfer to x to index by
 LDA infom,X                            ;can repton move there?
 BMI lockd                              ;no
 CMP #code_diamond                      ;is it a diamond?
 BNE earth                              ;no
 LDY sting                              ;get direction
 CPY #&02
 BCS lockd
 STX accum
 LDA reptn_shove,Y                      ;must be a rock
 STA paras + &01                        ;set up params for shoving it
 LDA #&11
 STA paras + &02
 LDA #&0F                               ;sprite masks
 STA paras + &03
 STA paras + &04
 LDA reptx                              ;get map byte behind the rock or egg
 CLC
 ADC super,Y
 TAX
 LDA repty
 JSR get_map_byte
 CMP #code_space                        ;is a space behind it?
 BNE lockd                              ;no so cannot push it there
 STA paras + &00                        ;store space
 STA repton_move_to                     ;repton now moving into a space
 JSR place_a_sprite                     ;place space in direction repton moving
 INC kicks
 LDY sting
 LDA reptx
 CLC
 ADC adjux,Y
 TAX
 LDY repty
 LDA #code_space                        ;now space out the map byte in direction repton moving
 JSR write_map_byte
 LDY sting
 LDA reptn_pushs,Y
 STA paras + &01
 LDA reptx
 CLC
 ADC super,Y
 TAX
 LDY repty
 LDA accum
 STA paras + &00
 JSR write_map_byte                     ;move it over either rock or egg
 JSR eor_a_sprite
 LDA #code_space                        ;put space in its place
 STA paras + &00
 JSR eor_a_sprite                       ;place space in direction of repton
 LDA #19                                ;slow down pushing rock/egg
 JSR osbyte

.earth                                  ;it's earth/space so can move through freely
 LDA #80
 STA mcode
 LDA #&00
 STA movie
.worth                                  ;repton movement loop x4
 LDA death                              ;is repton dead?
 BNE minit                              ;yes
 JSR rock_maintenance
 JSR hatch_monsters
 JSR repton_walks                       ;build repton buffer in travel direction
 JSR update_row_or_column               ;build screen buffer in travel direction
 JSR monsters_spirits_on_edges          ;place those that are in the scroll update area into the buffer
 JSR scroll_screen                      ;hardware scroll screen and transfer buffer to screen edges
 LDA #&11                               ;place repton at screen center from built buffer
 STA paras + &00
 STA paras + &01
 LDA sting                              ;direction of travel
 STA paras + &02
 LDA movie                              ;travel counter
 STA paras + &03
 JSR sprite_mask_screen                 ;sprite mask in the center
 INC movie                              ;move counter
 LDA movie
 CMP #&04                               ;four moves for one square distance up/down/left/right
 BCS reptn_slide                        ;finished
 JSR countdown
 JSR monster_spirit_movement
 JMP worth                              ;keep moving four units

.reptn_slide                            ;update when completed 4 moves
 JSR update_repton
 JSR repton_action
 LDA #&00
 STA kicks
.minit
 RTS

.repton_walks                           ;repton walking in the desired direction
 LDX #code_space                        ;from direction choose the background sprites
 LDY repton_move_to
 LDA sting
 BEQ reverse_values
 CMP #&03
 BEQ reverse_values
 STX paras + &01
 STY paras + &00
 JMP backgrounds_chosen
.reverse_values
 STX paras + &00
 STY paras + &01
.backgrounds_chosen
 LDA sting
 STA paras + &02
 JSR sprite_build_background            ;build two map character background in buffer
 LDX sting                              ;from the direction calculate what the next repton frame
 CPX #&03                               ;should be and for how long it should be used
 BCC frees
 DEX
.frees
 INC store,X
 LDA store,X
 CMP cover,X
 BNE skips
 LDA #&00
 STA store,X
.skips
 LDA lists_lsb,X
 STA tempa
 LDA lists_msb,X
 STA tempx
 LDY store,X
 LDA (tempa),Y
 STA reptn                              ;update repton frame
 STA paras + &00                        ;sprite to mask
 LDA sting
 STA paras + &01                        ;travel direction
 LDA movie
 STA paras + &02                        ;travel counter
 JMP sprite_mask_foreground             ;now mask sprite on background

.update_repton                          ;after walking four units do final update
 LDA #&00
 STA movie                              ;zeroise repton movement counter
 LDX reptx                              ;write space at previous repton position in map
 LDY repty
 LDA #code_space
 JSR write_map_byte
 LDX sting                              ;calculate new repton x/y position and update it
 LDA reptx
 CLC
 ADC adjux,X
 STA reptx
 LDA repty
 CLC
 ADC adjuy,X
 STA repty
 LDX reptx
 JSR get_map_byte                       ;get current map value of where repton has moved to
 STA accum                              ;save map byte at repton new location
 TAX
 LDA infom,X                            ;look at what to do with it
 CMP #&07                               ;picked death? (skull/fungus)
 BEQ initl                              ;yes
 LDX reptx
 LDY repty
 LDA #code_repton                       ;update repton to current position in map
 JMP write_map_byte

.repton_action                          ;get the action code for what needs to be done
 LDY accum                              ;at the current location map byte repton has moved onto
 LDA infom,Y
 ASL A
 TAX
 LDA reptn_addrs + &01,X
 PHA
 LDA reptn_addrs,X
 PHA
 TYA                                    ;map byte into a
.initl
 RTS                                    ;vector to action

.reptn_addrs
 EQUW remove_graphic     - &01          ;00 just remove graphic underneath repton
 EQUW remove_graphic     - &01          ;01
 EQUW picked_diamond     - &01          ;02
 EQUW picked_capsule     - &01          ;03
 EQUW picked_keys        - &01          ;04
 EQUW picked_transporter - &01          ;05
 EQUW picked_crown       - &01          ;06
 EQUW picked_death       - &01          ;07
 EQUW picked_time_bomb   - &01          ;08

.picked_capsule                         ;picked up a time capsule
 LDA #&09
 JSR make_sound
 JSR initialise_game_timer              ;reset timer for level
 JSR get_colours_from_map
 JMP remove_graphic_no_check            ;remove time capsule

.picked_keys                            ;picked up a key
 LDA #&02
 JSR make_sound
 JSR transform_safe_to_diamond          ;all safes transformed to diamonds
 JMP remove_graphic_no_check            ;remove key

.remove_graphic                         ;remove graphic underneath repton
 CMP #code_rock                         ;check which graphics not to remove and exit
 BEQ siton
 CMP #code_egg
 BEQ siton
 CMP #27
 BEQ siton
 CMP #47
 BEQ siton

.remove_graphic_no_check
 LDA #code_space                        ;background
 STA paras
 LDA reptn                              ;repton foreground
 STA paras + &01
 LDA #&11
 STA paras + &02
 STA paras + &03
 JMP sprite_mask_place

.picked_crown                           ;picked a crown
 LDA #&08
 JSR make_sound
 LDA score                              ;add 50 points
 CLC
 ADC #50
 STA score
 LDA score + &01
 ADC #&00
 STA score + &01
 INC tiara                              ;add 1 to number of crowns picked up
 JMP remove_graphic_no_check            ;remove crown

.picked_death
 INC death
.siton
 RTS

.picked_diamond
 LDA #&00
 JSR make_sound
 LDA score                              ;add 05 points
 CLC
 ADC #&05
 STA score
 LDA score + &01
 ADC #&00
 STA score + &01
 LDA #&04
 STA quart
 LDA diamn                              ;reduce total diamond quantity by one
 BNE decrement_lower
 DEC diamn + &01
.decrement_lower
 DEC diamn
 JMP remove_graphic_no_check            ;remove diamond graphic

.picked_time_bomb
 INC bomba
 RTS

.picked_transporter                     ;walked into a transporter
 JSR transporter_square_pattern         ;flood screen with squares
 LDX reptx                              ;remove repton from current location
 LDY repty
 LDA #code_space
 JSR write_map_byte
 LDA grids                              ;find out which transporter it is
 ASL A
 ASL A
 ASL A
 ASL A
 TAX                                    ;index into level transporter block of four
 LDY #&03
.looks
 LDA map_transporters + &00,X           ;get transporter x coordinate, -ve if inactive
 CMP reptx                              ;compare repton x against transporter x
 BNE reptn_nexts
 LDA map_transporters + &01,X
 CMP repty                              ;compare repton y against transporter y
 BEQ slots                              ;found a matching transporter
.reptn_nexts
 INX                                    ;move to next transporter slot
 INX
 INX
 INX
 DEY
 BPL looks                              ;find a match
.slots
 LDA map_transporters + &02,X           ;get destination x/y and store
 STA reptx
 STA copyx
 LDA map_transporters + &03,X
 STA repty
 STA copyy
 LDX reptx                              ;a=repty
 JSR get_map_byte                       ;get byte at the target
 CMP #code_space                        ;is it a space?
 BNE lefal                              ;anything other than blank space then die
 JSR expand_screen_shimmer              ;materialise repton in place
 JSR place_repton_mask                  ;final frame of repton masked on screen
 LDA #code_repton                       ;set repton at location
 LDX reptx
 LDY repty
 JMP write_map_byte

.lefal
 INC death
 JSR expand_screen_shimmer
 JSR place_repton_mask
 LDX #50
 JMP wait_state

.flagm
 EQUD &00
.prest
 EQUD &00
.flags
 EQUD &00
 EQUD &00
.reptn_press
 EQUD &00
 EQUD &00

.bangs                                  ;explosion sequence sprites
 EQUB 6
 EQUB 49
 EQUB 50
 EQUB 51
 EQUB 50
 EQUB 49
 EQUB 6

.repton_explodes                        ;repton explodes on the spot
 LDX #&06
.explode_repton
 TXA
 PHA
 LDA #code_space                        ;background
 STA paras
 LDA bangs,X
 STA paras + &01                        ;foreground
 LDA #&11                               ;set repton x,y
 STA paras + &02
 STA paras + &03
 JSR sprite_mask_place
 JSR effects
 PLA
 TAX
 DEX
 BPL explode_repton
 RTS

.bombs
 LDA #&08
 STA infom + 27
 RTS

.specy
 EQUW &0111
 EQUW &0B1F
 EQUB &04
 EQUS "SCREEN "
 EQUW &41F
 EQUB 22
 EQUS "Press       to CONTINUE"
 EQUW &0211
 EQUW &121F
 EQUB 4
.edits
 EQUB &00
 EQUW &A1F
 EQUB 22
 EQUS "SPACE"
 EQUW &311
 EQUW &A1F
 EQUB &08
 EQUS "EDITOR CODE"

.editor_codes
 JSR setup_custom_mode
 JSR get_colours_from_map
 LDA grids
 CLC
 ADC #65
 STA edits
 LDX #LO(specy)
 LDY #HI(specy)
 LDA #editor_codes - specy
 JSR write_characters
 LDA grids
 ASL A
 TAX
 LDA map_edits,X
 STA tempa
 LDA map_edits + &01,X
 STA tempx
 LDX #13
 LDY #10
 JMP decimal_convert
