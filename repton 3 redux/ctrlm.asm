; ctrlm

; constants
 bbc_space_key                          = 98    ;make inkey value positive and subtract 1
 bbc_m_key                              = 101
 bbc_return_key                         = 73
 bbc_escape                             = 112
 bbc_shift_key                          = 00
 bbc_q_key                              = 16
 bbc_s_key                              = 81
 bbc_w_key                              = 33
 bbc_d_key                              = 50
 bbc_j_key                              = 69
 bbc_k_key                              = 70
 bbc_p_key                              = 55
 bbc_l_key                              = 86
 bbc_r_key                              = 51
 bbc_y_key                              = 68

MACRO read_a_key key_value              ;quick in-line read of a single key
 PHP                                    ;faster version of osbyte 129
 SEI
 LDA #&7F                               ;set port a for input on bit 7 others outputs
 STA system_via_ddr_a
 LDA #&03                               ;stop keyboard auto-scan
 STA system_via_orb_irb
 LDY #key_value                         ;read the key
 STY system_via_ora_ira_no_hand
 LDY system_via_ora_ira_no_hand         ;n flag = key pressed
 LDA #&0B                               ;select auto scan of keyboard
 STA system_via_orb_irb
 PLP                                    ;restore irq status
 TYA                                    ;restore n flag
ENDMACRO

.read_a_passed_key                      ;x=key number
 PHP                                    ;faster version of osbyte 129
 SEI
 LDA #&7F                               ;set port a for input on bit 7 others outputs
 STA system_via_ddr_a
 LDA #&03                               ;stop keyboard auto-scan
 STA system_via_orb_irb
 STX system_via_ora_ira_no_hand
 LDX system_via_ora_ira_no_hand         ;n flag = key pressed
 LDA #&0B                               ;select auto scan of keyboard
 STA system_via_orb_irb
 PLP                                    ;restore irq status
 TXA                                    ;restore n flag
 RTS

.combined_block_start

.combined_bbc_q_key                     EQUB &00
.combined_bbc_s_key                     EQUB &00
.combined_bbc_w_key                     EQUB &00
.combined_bbc_d_key                     EQUB &00
.combined_bbc_j_key                     EQUB &00
.combined_bbc_k_key                     EQUB &00
.combined_bbc_p_key                     EQUB &00
.combined_bbc_l_key                     EQUB &00
.combined_bbc_space_key                 EQUB &00

.bbc_key_values
 EQUB bbc_q_key        << &01
 EQUB bbc_s_key        << &01
 EQUB bbc_w_key        << &01
 EQUB bbc_d_key        << &01
 EQUB bbc_j_key        << &01
 EQUB bbc_k_key        << &01
 EQUB bbc_p_key        << &01
 EQUB bbc_l_key        << &01
 EQUB bbc_space_key    << &01
.bbc_key_values_end

.read_start_screen_keyboard
 LDY #&FF                               ;key reset, y=&ff
 PHP
 SEI
 LDA #&7F                               ;set port a for input on bit 7 others outputs
 STA system_via_ddr_a
 LDA #&03                               ;stop keyboard auto-scan
 STA system_via_orb_irb
 LDX #bbc_key_values_end - bbc_key_values - &01
.bbc_read_keys
 LDA bbc_key_values,X                   ;bit 0 = debounce into carry
 LSR A
 STA system_via_ora_ira_no_hand
 LDA system_via_ora_ira_no_hand
 BPL clear_key
 LDA combined_block_start,X
 BCS no_bbc_debounce                    ;c=1 do not debounce key
 BMI clear_key                          ;if pressed last time clear bit 7
 ASL A                                  ;check bit 6
 BMI debounce_end                       ;debounce
.no_bbc_debounce
 TYA
 STA combined_block_start,X             ;set key pressed flag and debounce flag
 DEX
 BPL bbc_read_keys
 LDA #&0B                               ;select auto scan of keyboard
 STA system_via_orb_irb
 PLP                                    ;restore irq status
 RTS

.clear_key
 LSR combined_block_start,X             ;key not pressed, second pass clears debounce flag
.debounce_end
 DEX
 BPL bbc_read_keys
 LDA #&0B                               ;select auto scan of keyboard
 STA system_via_orb_irb
 PLP                                    ;restore irq status
 RTS

.brkv_store
 EQUW &00

.mastr                                  ;main game start
 LDX #LO(flexi)
 LDY #HI(flexi)
 LDA #flexi_end - flexi
 JSR write_characters
 JSR disc_directory
 JSR decode_passwords
 LDA brkv                               ;store brk vector
 STA brkv_store + &01
 LDA brkv + &01
 STA brkv_store + &01
 LDA #LO(patch_brk_vector)              ;patch brk vector
 STA brkv
 LDA #HI(patch_brk_vector)
 STA brkv + &01
 JSR write_vector_patch                 ;roll into routine below

.master_control
 JSR select_swr_ram_slot                ;page in sideways ram slot
 INC barit
 LDA #178                               ;enable keyboard
 LDX #&FF
 LDY #&00
 STY userp                              ;clear password used flag
 JSR osbyte
 JSR setup_custom_mode
 JSR setup_interrupt_and_event
 JSR general_setup                      ;exit a=vector code
 indirect_jump addrs                    ;vector to routine

.addrs                                  ;actions
 EQUW enter_map_name - &01
 EQUW enter_password - &01
 EQUW play_game      - &01

.enter_map_name                         ;load a map file from disc
 JSR rotate_all_screen_bytes
 JSR load_repton_map
 JSR decode_passwords
 JSR disc_directory
 JMP master_control

.password_entered                       ;clear screen and return
 JSR rotate_all_screen_bytes
 JMP master_control

.enter_password
 JSR rotate_all_screen_bytes
 JSR repton_password
 BCC password_entered                   ;invalid password used, go back to main screen
 INC userp                              ;password used flag

.play_game
 JSR jingle
 LDA #178                               ;disable keyboard
 LDX #&00
 LDY #&00
 JSR osbyte
 JSR rotate_all_screen_bytes
 JSR setup_custom_mode
 JSR setup_interrupt_and_event
 JSR get_map_data_into_buffer
 JSR get_colours_from_map
 JSR number_of_diamonds_and_monsters
 JSR repton_monsters_and_spirits        ;initialise monsters and spirits
 JSR find_repton_in_map
 JSR expand_screen_shimmer              ;materialise repton in place
 JSR place_repton_mask                  ;final frame of repton masked on screen

.next_screen
 LDA #&FF
 STA slows
 LDA tiara
 STA crown

.start_game
 JSR initialise_game_timer
 LDA #&00
 STA death                              ;repton is alive
.games
 LDA #&00
 STA barit
 JSR random_numbers
 JSR read_start_screen_keyboard
 JSR display_repton_map                 ;if repton dead then no check for status/map/escape
 JSR status_screen
 JSR escape_kill_repton
 JSR repton_running
 JSR monster_spirit_movement
 JSR rock_maintenance
 JSR test_sound
 JSR test_music
 JSR fungus_spread
 JSR hatch_monsters
 JSR reset_repton
 JSR countdown
 LDA death                              ;repton alive?
 BEQ alive                              ;yes
 JMP repton_out_of_time

.alive
 LDA diamn + &00                        ;check all diamonds/monsters
 ORA diamn + &01
 ORA monst
 BNE games                              ;still diamonds/monsters to collect/kill
 LDA tiara
 CMP crown                              ;collected enough crowns?
 BEQ games                              ;no
 JSR bombs
 LDA bomba
 BMI games
 INC barit
 JSR get_colours_from_map
 JSR rotate_all_screen_bytes
 LDA grids
 ASL A
 TAX
 LDA map_edits,X
 ORA map_edits + &01,X
 BEQ fedup
 JSR editor_codes
.keep_waiting_for_space
 JSR read_start_screen_keyboard
 BIT combined_bbc_space_key
 BPL keep_waiting_for_space
 JSR rotate_all_screen_bytes
.fedup
 INC grids                              ;next screen
 LDA grids
 CMP #&08                               ;finished all eight?
 BCS finished_all_screens               ;yes
 JSR get_map_data_into_buffer
 JSR number_of_diamonds_and_monsters
 JSR repton_monsters_and_spirits        ;initialise monsters and spirits
 JSR find_repton_in_map
 JSR initialise_game_timer
 JSR stars_repton
 JMP next_screen

.finished_all_screens                   ;finished all screens, so congratulate
 JSR congratulations_finished
 JMP master_control

.reset_repton                           ;abandon current game?
 LDX #bbc_r_key
 JSR read_a_passed_key
 BPL reset_repton_exit
 LDX #bbc_shift_key
 JSR read_a_passed_key
 BPL reset_repton_exit
 JSR rotate_all_screen_bytes            ;exit game
 PLA                                    ;pop return address off stack
 PLA
 JMP master_control

.reset_repton_exit
 RTS

.display_repton_map
 LDX #bbc_m_key
 JSR read_a_passed_key                  ;pressed 'm'?
 BPL function_exit                      ;no
 LDA #13
 LDX #&04
 JSR osbyte
 INC barit
.display_repton_map_inner
 JSR rotate_all_screen_bytes            ;clear screen and show map
 JSR display_map
.paces                                  ;wait for pressed space key/map flip key y
 JSR read_map_flip_keys
 LDA #code_space                        ;alternate space/repton on map
 JSR print_repton
 LDX #10
 JSR wait_state
 JSR read_map_flip_keys
 JSR read_space_key
 BMI exit_map
 LDA #code_repton
 JSR print_repton
 LDX #10
 JSR wait_state
 JSR read_map_flip_keys
 JSR read_space_key
 BPL paces
.exit_map
 JSR rotate_all_screen_bytes
 JSR expand_screen_shimmer
 JSR place_repton_mask
 JMP setup_interrupt_and_event

.read_space_key
 LDX #bbc_space_key
 JMP read_a_passed_key

.print_repton
 LDX reptx
 INX
 INX
 LDY repty
 INY
 INY
 INY
 INY
 JMP write_map_graphic
.function_exit
 RTS

.status_screen                          ;display status screen
 LDX #bbc_return_key
 JSR read_a_passed_key                  ;return key pressed to enter screen?
 BPL function_exit                      ;no
.stars_repton
 LDA #13                                ;disable frame sync event
 LDX #&04
 JSR osbyte
 INC barit                              ;stop the music
 JSR rotate_all_screen_bytes
 JSR repton_game_status
.status_loop
 LDX #bbc_m_key
 JSR read_a_passed_key                  ;pressed 'm'?
 BMI display_repton_map_inner
 LDX #bbc_r_key                         ;can exit game in status screen
 JSR read_a_passed_key                  ;shift/r
 BPL go_read_space_key
 LDX #bbc_shift_key
 JSR read_a_passed_key
 BPL go_read_space_key
 JSR rotate_all_screen_bytes            ;exit game
 PLA                                    ;pop return address off stack
 PLA
 JMP master_control
 
.go_read_space_key
 LDX #bbc_space_key
 JSR read_a_passed_key
 BPL status_loop
 JSR rotate_all_screen_bytes
 JSR expand_screen_shimmer
 JSR place_repton_mask
 JMP setup_interrupt_and_event

.out_of_time
 EQUW &211
 EQUW &A1F
 EQUB 15
 EQUS "Out of time."
.out_of_time_end

.repton_out_of_time
 INC barit
 LDA #&07
 JSR make_sound
 JSR get_colours_from_map
 JSR repton_explodes
 JSR rotate_all_screen_bytes
 JSR setup_custom_mode
 JSR get_colours_from_map
 LDA watch                              ;timer at zero?
 ORA watch + &01
 BNE sandy                              ;no
 LDX #LO(out_of_time)                   ;"out of time" message
 LDY #HI(out_of_time)
 LDA #out_of_time_end - out_of_time
 JSR write_characters
 LDX #100                               ;wait two seconds
 JSR wait_state
.sandy
 DEC lives                              ;repton lost a life, all gone?
 BEQ trifl                              ;yes
 LDA #code_repton
 JSR find_byte_in_map                   ;find repton in map and set to space
 BCC noval                              ;not found
 LDA #code_space
 JSR write_map_byte
.noval
 LDX copyx                              ;copy coordinates
 STX reptx
 LDY copyy
 STY repty
 LDA #code_repton                       ;now write repton back into the map
 JSR write_map_byte
 JSR initialise_game_timer
 JSR stars_repton
 JMP start_game

.trifl
 JSR final_repton
 JMP master_control

.ctrlm_mtake
 EQUB &07
 EQUB 31
.mtakx
 EQUB &00
 EQUB 17
 EQUW &211
.sweep
 EQUD &00
 EQUD &00
 EQUD &00
 EQUD &00
 EQUD &00
 EQUD &00

.patch_brk_vector
 LDX #&00
.messa_ctrlm
 LDA stack + &02,X
 STA sweep,X
 BEQ error
 INX
 CPX #24
 BCC messa_ctrlm
.error
 STX tempx
 LDA #&20
 SEC
 SBC tempx
 LSR A
 STA mtakx
 LDX #patch_brk_vector - ctrlm_mtake
 LDY #&00
.ctrlm_notes
 LDA ctrlm_mtake,Y
 BEQ delay
 JSR oswrch
 INY
 DEX
 BPL ctrlm_notes
.delay
 LDX #150
 JSR wait_state
 JSR rotate_all_screen_bytes
 JMP master_control

.flexi                                  ;turn cursor off
 EQUB 23
 EQUB &01
 EQUD &00
 EQUD &00
.flexi_end

.decode_passwords                       ;decode all the map passwords
 LDA #&00
 STA tempa
 LDX #63
.eor_byte
 LDA map_passwords,X
 EOR tempa
 STA map_passwords,X
 INC tempa
 DEX
 BPL eor_byte
.ctrlm_exits
 RTS

.crown
 EQUB &00

; adjus

.spirit_y_adjust
 EQUD &000100FF

.spirit_x_adjust
 EQUD &FF000100

.paths
 EQUD &02010300

.adjust_spirits
 LDX aloof
 LDA spirx,X
 STA xxadj
 LDA spiry,X
 STA yyadj
 LDY #&03
.reptn_looks
 STY accum
 LDA xxadj
 CLC
 ADC spirit_x_adjust,Y                  ;calculate x coordinate
 TAX
 LDA yyadj
 CLC
 ADC spirit_y_adjust,Y                  ;calculate y coordinate
 JSR get_map_byte
 LDY accum
 CMP #31
 BEQ freds
 CMP #code_space
 BEQ freds
 CMP #&02
 BEQ freds
 CMP #&03
 BEQ freds
 LDX aloof
 LDA paths,Y
 STA spird,X
.freds
 DEY
 BPL reptn_looks
 RTS
