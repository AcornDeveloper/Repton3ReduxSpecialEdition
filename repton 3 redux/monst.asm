; monst

.wait_quarter_screen                    ;flicker reducing routine
 LSR wait_flag                          ;c=0 exit else c=1 wait, zeroise flag
 BCC wait_quarter_screen_exit           ;wait not required so exit
 LDA paras + &02
 LSR A                                  ;divide by &08 to reduce from &00-&1f to &00-&03, top to bottom
 LSR A
 LSR A
.wait_for_beam
 CMP scan_line_area                     ;loop until out of quarter
 BEQ wait_for_beam
.wait_quarter_screen_exit
 RTS

.hatch_monsters                         ;check eggs to see if one can be hatched
 LDX #&03
.chick
 LDA anoth,X
 BMI next_monster                       ;monster not on
 BEQ next_monster                       ;monster active
 DEC anoth,X                            ;still cracked?
 BNE next_monster                       ;yes
 STX aloof                              ;now hatch the monster
 LDY ycoor,X
 LDA xcoor,X
 TAX
 LDA #code_space                        ;write space where cracked egg was
 JSR write_map_byte
 LDX aloof                              ;set up initial monster variables
 LDA #&28                               ;stay still for a while before pursuing repton
 STA bornm,X
 LDA xcoor,X
 STA tempa
 LDA ycoor,X
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 STA monsc,X
 STA direc,X
 JSR calculate_sprite_plot_mask
 BCS hatch_exit                         ;not on screen so exit
 LDX aloof
 LDA framc,X
 STA paras + &00
 JMP place_a_sprite                     ;monster is born
.next_monster
 DEX
 BPL chick
.hatch_exit
 RTS

.spirit_flags
 EQUD &00
 EQUD &00

.repton_monsters_and_spirits            ;initialise monsters and spirits
 LDX #&03
 LDY #&FF
.monster_eggs
 LDA #&03                               ;monster frame flip counter
 STA monsf,X
 LDA #code_monster                      ;monster sprite frame
 STA framc,X
 STY anoth,X                            ;monster off initially as is an egg first
 DEX
 BPL monster_eggs
 LDX #&07                               ;initialise spirit variables
.find_spirits
 STX aloof
 LDA #&FF                               ;set spirit to be inactive initially
 STA spirp,X
 LDA #&00
 STA spirc,X
 STA spirit_flags,X                     ;clear flags
 LDA #&01
 STA spird,X
 LDA #&03
 STA count,X
 LDA #&1F
 STA spirf,X
 JSR find_byte_in_map
 BCC whisk                              ;none left but still need to initialise
 TXA
 PHA
 LDX aloof
 STA spirx,X
 STY spiry,X
 LDA #&00
 STA spirp,X                            ;enable spirit
 PLA
 TAX
 LDA #code_space                        ;set map square to space
 JSR write_map_byte
 JSR adjust_spirits
.whisk
 LDX aloof
 DEX
 BPL find_spirits
 RTS

.eor_a_spirit
 LDA spirp,X
 BMI spirit_missing_exit

.eor_a_spirit_no_check                  ;entry here to remove regardless
 LDA spirf,X
 STA paras + &00
 LDA spirx,X
 STA tempa
 LDA spirc,X
 STA tempx
 LDA spiry,X
 STA tempy
 LDA spird,X
 STA tempz
 TXA
 PHA
 JSR calculate_sprite_plot_mask
 BCS spirit_not_on                      ;not on screen
 JSR wait_quarter_screen
 JSR eor_a_sprite
.spirit_not_on
 PLA
 TAX
.spirit_missing_exit
 RTS

.eor_a_monster                          ;x index into monster, c=1 wait
 LDA anoth,X                            ;monster on yet?
 BNE monster_missing_exit               ;no

.eor_a_monster_no_check                 ;entry here to remove regardless
 LDA framc,X
 STA paras + &00
 LDA xcoor,X
 STA tempa
 LDA monsc,X
 STA tempx
 LDA ycoor,X
 STA tempy
 LDA direc,X
 STA tempz
 TXA
 PHA
 JSR calculate_sprite_plot_mask
 BCS monster_missing                    ;not on screen
 JSR wait_quarter_screen
 JSR eor_a_sprite
.monster_missing
 PLA
 TAX
.monster_missing_exit
 RTS

.monster_stand_still
 INC wait_flag
 JSR eor_a_monster                      ;take monster off
 LDA #&03
 STA monsf,X
 EOR framc,X                            ;flip the animation frame
 STA framc,X
 JMP eor_a_monster                      ;put monster back on

.monster_frames                         ;standing still after hatching
 LDA #&03
 DEC monsf,X                            ;slow down frame flipping
 BNE put_monster_on
 STA monsf,X
 EOR framc,X                            ;flip the animation frame
 STA framc,X
.put_monster_on
 JMP eor_a_monster                      ;put monster back on

.monster_overlap                        ;check for overlapping monsters to avoid xor artifacts
 LDX #&03
.monster_overlap_loop
 CPX aloof                              ;ignore current monster
 BEQ monster_overlap_next
 LDA anoth,X                            ;monster present?
 BMI monster_overlap_next               ;no
 LDA monsc,X                            ;other monster moving?
 BNE monster_stay_put                   ;yes
 LDA xcoor,X
 CMP map_coordinate_x
 BNE monster_overlap_next
 LDA ycoor,X
 CMP map_coordinate_y
 BNE monster_overlap_next
.monster_stay_put
 SEC                                    ;stay still
 RTS
.monster_overlap_next
 DEX
 BPL monster_overlap_loop
.monster_overlap_clear
 CLC                                    ;clear to move
 RTS

.monster_allowed_to_move                ;x preserved
 INC monsc,X
 LDA monsc,X
 AND #&03
 STA monsc,X                            ;time to move on one?
 BNE monster_no_move                    ;no
 LDY direc,X                            ;move one square in the required direction
 LDA xcoor,X
 CLC
 ADC sprite_x_addin,Y
 STA xcoor,X
 LDA ycoor,X
 CLC
 ADC sprite_y_addin,Y
 STA ycoor,X
.monster_no_move
 RTS

.monster_spirit_movement                ;logic for monster movement
 LDX #&03
.monster_loop
 LDA anoth,X                            ;monster present?
 BMI monster_next                       ;no
 STX aloof
 BNE monster_stay_where_you_are         ;if just hatched then stay on spot
 LDA bornm,X                            ;still hatching?
 BEQ alive_chase                        ;no
 DEC bornm,X                            ;decrement hatch counter
 DEC monsf,X                            ;slow down frame flipping
 BNE monster_not_changed_frame
 JSR monster_stand_still
.monster_not_changed_frame
 JSR has_monster_caught_repton          ;check for repton walking into monster while just hatched
 JMP monster_next                       ;next monster
.alive_chase
 INC wait_flag
 JSR eor_a_monster                      ;take monster off
 LDA monsc,X                            ;monster moving through a square?
 BNE monster_allowed                    ;yes, don't change direction
 LDA randy                              ;provide some random direction
 AND #&01
 BNE slide
 TAY
 LDA reptx                              ;calculate movement direction to repton
 CMP xcoor,X
 BCS chock
 INY
 BNE chock
.slide
 LDY #&03
 LDA repty
 CMP ycoor,X
 BCS chock
 DEY
.chock
 STY direc,X                            ;save the desired direction
 LDA ycoor,X
 CLC
 ADC sprite_y_addin,Y
 STA map_coordinate_y                   ;save proposed y coordinate
 PHA
 LDA xcoor,X
 CLC
 ADC sprite_x_addin,Y
 STA map_coordinate_x                   ;save proposed x coordinate
 TAX
 PLA
 JSR get_map_byte                       ;get map character in proposed direction of travel
 PHA                                    ;save the map character
 JSR monster_overlap                    ;check for monsters colliding
 PLA                                    ;retrieve the map character
 LDX aloof                              ;restore x
 BCS monster_stay_where_you_are         ;c=1 overlap else c=0 okay
 CMP #code_earth1                       ;earth 1?
 BEQ monster_allowed                    ;yes
 CMP #code_earth2                       ;earth 2?
 BEQ monster_allowed                    ;yes
 CMP #code_space                        ;space?
 BEQ monster_allowed                    ;yes
 CMP #code_repton                       ;is it repton?
 BNE monster_stay_where_you_are         ;no
 INC death                              ;caught repton
.monster_allowed                        ;monster allowed to move
 JSR monster_allowed_to_move            ;x preserved
.monster_stay_where_you_are
 JSR monster_frames
 JSR has_monster_caught_repton          ;x preserved
.monster_next
 DEX
 BPL monster_loop

 LDX #&07                               ;logic for spirit movement
.move_spirit
 LDA spirp,X                            ;spirit active?
 BMI spirit_not_active                  ;no
 STX aloof
 INC wait_flag
 JSR eor_a_spirit
 LDA reptx                              ;is spirit x same as repton x?
 CMP spirx,X
 BNE spirit_repton_check                ;no
 LDA repty                              ;is spirit y same as repton y?
 CMP spiry,X
 BNE spirit_repton_check                ;no
 INC death
.spirit_repton_check
 LDA spirc,X                            ;finished moving a square?
 BNE spirit_flash                       ;no
 LDA spirit_flags,X                     ;spirit moving between squares when map/status/killed used?
 BPL spirit_okay_to_choose              ;no
 LDA #&00
 STA spirit_flags,X                     ;reset
 JMP spirit_flash
.spirit_okay_to_choose
 JSR spirit_sides                       ;update direction
 JSR spirit_front
 JSR spirit_front
.spirit_flash
 DEC count,X                            ;slow down frame flipping
 BNE no_sprit_frame_flip
 LDA #&03
 STA count,X
 LDA spirf,X                            ;flip the animation frame
 EOR #63
 STA spirf,X
.no_sprit_frame_flip
 INC spirc,X                            ;move in desired direction
 LDA spirc,X
 AND #&03
 STA spirc,X
 BNE spirit_place_on
 LDY spird,X
 LDA spirx,X
 CLC
 ADC sprite_x_addin,Y
 STA spirx,X
 LDA spiry,X
 CLC
 ADC sprite_y_addin,Y
 STA spiry,X
.spirit_place_on
 JSR eor_a_spirit
.spirit_not_active
 DEX
 BPL move_spirit
 RTS

.sprite_x_addin                         ;movement direction
 EQUB &01
 EQUB &FF

.sprite_y_addin
 EQUB &00
 EQUB &00
 EQUB &FF
 EQUB &01

.xdash
 EQUB &00
 EQUB &00

.ydash
 EQUB &FF
 EQUB &01
 EQUB &00
 EQUB &00

.sides
 EQUB &02
 EQUB &03
 EQUB &01
 EQUB &00

.spirit_sides
 LDA spirp,X
 BMI siout
 LDY spird,X
 LDA spiry,X
 CLC
 ADC ydash,Y
 STA pages + &01
 LDA spirx,X
 CLC
 ADC xdash,Y
 STA pages + &00
 TAX
 LDA pages + &01
 JSR get_map_byte
 LDX aloof
 CMP #code_space
 BEQ forwd
 CMP #code_earth1
 BEQ forwd
 CMP #code_earth2
 BEQ forwd
 CMP #code_cage
 BEQ spirit_hit_cage
 CMP #code_repton
 BNE siout
.deded
 INC death
 RTS

.forwd
 LDY spird,X
 LDA sides,Y
 STA spird,X
.siout
 RTS

.spirit_hit_cage
 DEC spirp,X                            ;spirit inactive
 LDX pages + &00
 LDY pages + &01
 LDA #code_diamond                      ;change to a diamond
 STA paras
 JSR write_map_byte
 LDA pages + &00
 STA tempa
 LDA pages + &01
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 JSR calculate_sprite_plot_mask
 BCS pling
 JSR place_a_sprite
.pling
 LDA #&03
 JMP make_sound

.spirit_front
 LDA spirp,X
 BMI front
 LDY spird,X
 LDA spiry,X
 CLC
 ADC sprite_y_addin,Y
 STA pages + &01
 LDA spirx,X
 CLC
 ADC sprite_x_addin,Y
 STA pages + &00
 TAX
 LDA pages + &01
 JSR get_map_byte
 LDX aloof
 CMP #code_earth1
 BEQ front
 CMP #code_earth2
 BEQ front
 CMP #code_space
 BEQ front
 CMP #code_cage
 BEQ spirit_hit_cage
 CMP #code_repton
 BNE chang
 JMP deded                              ;always
.chang
 LDY spird,X
 LDA insid,Y
 STA spird,X
.front
 RTS

.has_monster_caught_repton
 LDA reptx                              ;x test for monster catching repton
 EOR xcoor,X
 BNE not_caught
 LDA repty                              ;y test for monster catching repton
 EOR ycoor,X
 BNE not_caught
 INC death
.not_caught                             ;now check for monster killed by rock/egg/fungus
 LDY ycoor,X
 LDA xcoor,X
 TAX
 TYA
 JSR get_map_byte
 LDX aloof                              ;restore x
 CMP #code_rock                         ;is it rock?
 BEQ kilit                              ;yes
 CMP #code_egg                          ;is it an egg?
 BEQ kilit                              ;yes
 CMP #code_fungus                       ;is it fungus?
 BNE kilit_exit                         ;no
.kilit
 INC wait_flag
 JSR eor_a_monster                      ;remove the monster
 DEC anoth,X                            ;monster dead
 LDA #&05
 JSR make_sound
 DEC monst                              ;reduce number of monsters
 LDA score                              ;add in kill score
 CLC
 ADC #20
 STA score
 LDA score + &01
 ADC #&00
 STA score + &01
 LDX aloof
.kilit_exit
 RTS

.insid
 EQUB &03
 EQUB &02
 EQUB &00
 EQUB &01
