; setup

.perip
 EQUB &00

.title
 EQUW &81F
 EQUB 9
 EQUW &311
 EQUS "Repton 3 Redux"
 EQUW &21F
 EQUB 10
 EQUS "Written by Matthew Atkinson"

.setup
 EQUW &311
 EQUW &31F
 EQUB 29
 EQUS "(c) Superior Software Ltd /"
 EQUW &11F
 EQUB 30
 EQUS "Superior Interactive, 1986-2023"
 EQUW &111
 EQUW &91F
 EQUB 12
 EQUS "Sound :"
 EQUW &91F
 EQUB 14
 EQUS "Music :"
 EQUW &31F
 EQUB 16
 EQUS "View status :"
 EQUW &61F
 EQUB 18
 EQUS "Controls :"
 EQUW &B1F
 EQUB 20
 EQUS "Map :"
 EQUW &71F
 EQUB 22
 EQUS "Restart :"
 EQUW &11F
 EQUB 24
 EQUS "Press"
 EQUW &E1F
 EQUB 24
 EQUS "to LOAD MAP FILE"
 EQUW &11F
 EQUB 25
 EQUS "Press"
 EQUW &E1F
 EQUB 25
 EQUS "to ENTER PASSWORD"

.section_start
 EQUW &111
 EQUW &11F
 EQUB 26
 EQUS "Press"
 EQUW &E1F
 EQUB 26
 EQUS "to RESPAWN"
 EQUW &11F
 EQUB 27
 EQUS "Press"
 EQUW &E1F
 EQUB 27
 EQUS "to PLAY GAME"
 EQUW &211
 EQUW &1A1F
 EQUB 12
 EQUS "(Q/S)"
 EQUW &1A1F
 EQUB 14
 EQUS "(W/D)"
 EQUW &111F
 EQUB 16
 EQUS "Return"
 EQUW &1A1F
 EQUB 18
 EQUS "(J/K)"
 EQUW &111F
 EQUB 20
 EQUS "M/Y"
 EQUW &111F
 EQUB 22
 EQUS "Shift-R"
 EQUW &71F
 EQUB 24
 EQUS "L"
 EQUW &71F
 EQUB 25
 EQUS "P"
 EQUW &71F
 EQUB 26
 EQUS "ESCAPE"
 EQUW &71F
 EQUB 27
 EQUS "SPACE"
.section_end

.general_setup
 JSR setup_custom_mode
 LDA #&00
 STA grids
 STA tiara
 STA score
 STA score + &01
 LDA #&03                               ;number of repton lives
 STA lives
 LDA #&FF
 STA slows
 JSR all_colours_to_black
 LDX #LO(title)                         ;title text
 LDY #HI(title)
 LDA #setup - title
 JSR write_characters
 LDX #LO(setup)                         ;section text
 LDY #HI(setup)
 LDA #section_start - setup
 JSR write_characters
 JSR print_repton_sign
 LDX #LO(section_start)
 LDY #HI(section_start)
 LDA #section_end - section_start
 JSR write_characters
 JSR switch_on
 JSR get_colours_from_map
.loops
 JSR read_start_screen_keyboard         ;read all keys for the start screen
 JSR flip_keys
 JSR switch_update
 JSR select
 JSR test_space_key
 TYA
 BMI loops                              ;exit a=vector code
 RTS

.datas
 EQUS "On  "
 EQUS "Off "
.types
 EQUS "KeyboardJoystick"
.swtch
 EQUW &111F
 EQUB 12
 EQUS "***"
 EQUW &111F
 EQUB 18
.shows
 EQUS "********"

.switch_update
 LDA #19
 JSR osbyte
.switch_on
 LDA #12
 STA swtch + &02
 LDA gates
 ASL A
 ASL A
 TAX
 LDY #&00
.sound
 LDA datas,X
 STA swtch + &03,Y
 INX
 INY
 CPY #&03
 BCC sound
 LDA perip
 ASL A
 ASL A
 ASL A
 TAX
 LDY #&00
.finish_it
 LDA types,X
 STA shows,Y
 INX
 INY
 CPY #&08
 BCC finish_it
 JSR switch_common
 LDA #14
 STA swtch + &02
 LDA tunes
 ASL A
 ASL A
 TAX
 LDY #&00
.music
 LDA datas,X
 STA swtch + &03,Y
 INX
 INY
 CPY #&03
 BCC music

.switch_common
 LDX #LO(swtch)
 LDY #HI(swtch)
 LDA #switch_update-swtch
 JMP write_characters

.all_colours_to_black                   ;blank all colours
 LDA #19
 JSR osbyte
 LDX #&03
.colour_off
 LDA #19
 JSR oswrch
 TXA
 JSR oswrch
 LDA #&00
 JSR oswrch
 JSR oswrch
 JSR oswrch
 JSR oswrch
 DEX
 BPL colour_off
 RTS

.flip_keys                              ;test keys for options
 JSR test_sound
 JSR test_music                         ;roll into routine below

.select                                 ;select peripheral
 LDA combined_bbc_k_key                 ;if k and j pressed exit
 AND combined_bbc_j_key
 BMI test_sound_exit
 LDX perip
 BEQ test_perip_j
 BIT combined_bbc_k_key
 BMI flip_perip
 RTS
.test_perip_j
 BIT combined_bbc_j_key
 BPL test_sound_exit
.flip_perip                             ;flip peripheral
 LDA perip
 EOR #&01
 STA perip
 RTS

.test_sound
 LDA test_sound_q                       ;if q and s pressed exit
 AND combined_bbc_s_key
 BMI test_sound_exit
 LDX gates                              ;get sound flag
 BEQ test_sound_q
 BIT combined_bbc_s_key
 BMI flip_sound
 RTS
.test_sound_q
 BIT combined_bbc_q_key
 BPL test_sound_exit
.flip_sound
 LDA gates
 EOR #&01
 STA gates                              ;sound on/off
.test_sound_exit
 RTS

.test_music                             ;try music keys
 LDA combined_bbc_w_key                 ;if w and d pressed exit
 AND combined_bbc_d_key
 BMI test_sound_exit
 BIT combined_bbc_w_key
 BMI music_off
 BIT combined_bbc_d_key
 BPL test_sound_exit
.music_on
 LDA #&01
 STA tunes
 RTS

.music_off
 LDA #&00
 STA tunes
 RTS

.rotate_all_screen_bytes                ;fade screen out alternate pages left/right
 LDY #&08
.setup_another
 TYA
 PHA
 LDA #19
 JSR osbyte
 LDX #&00
 LDA #HI(lomem)
 STA rotate_left + &02
 CLC
 ADC #&01
 STA rotate_right + &02
.rotate_left
 ASL lomem,X
.rotate_right
 LSR lomem,X
 DEX
 BNE rotate_left
 INC rotate_left  + &02                 ;next two rows
 INC rotate_left  + &02
 INC rotate_right + &02
 INC rotate_right + &02
 BPL rotate_left
 PLA
 TAY
 DEY
 BNE setup_another
 RTS
