; edits

; constants
 map_file_length                        = &2620
 map_characters_length                  = &180
 repton_time                            = &1388

.cyphr
 EQUW &211
 EQUW &81F
 EQUB &07
 EQUS "ENTER  PASSWORD"
 EQUW &111
 EQUW &141F
 EQUB 12
 EQUS "!"
 EQUW &A1F
 EQUB 12
 EQUS "! "
 EQUW &311
.fails
 EQUW &211
 EQUW &41F
 EQUB 16
 EQUS "Password not recognised"
.catch
 EQUW &111
 EQUW &B1F
 EQUB 16
 EQUS "Screen "
 EQUW &211
.latch
 EQUS " "

.repton_password
 LDA #124
 JSR osbyte
 JSR all_colours_to_black
 JSR setup_custom_mode
 LDX #LO(cyphr)
 LDY #HI(cyphr)
 LDA #fails - cyphr
 JSR write_characters
 JSR get_colours_from_map
 LDA #21                                ;clear keyboard buffer
 LDX #&00
 JSR osbyte
 LDX #LO(input)                         ;input text
 LDY #HI(input)
 LDA #&00
 JSR osword
 LDA #&07
 STA tempa
.huite
 LDX #&00
 LDA tempa
 ASL A
 ASL A
 ASL A
 TAY
 LDA pages
 CMP #&0D
 BEQ norec
.quiet
 LDA map_passwords,Y
 CMP #&0D
 BEQ strin
 EOR pages,X
 BNE norec
 INY
 INX
 CPX #&08
 BCC quiet
.norec                                  ;password not recognised, exit with c=0
 DEC tempa
 BPL huite
 LDX #LO(fails)
 LDY #HI(fails)
 LDA #catch - fails
 JSR write_characters
 LDX #100
 JSR wait_state
 CLC
 RTS

.strin                                  ;password recognised, exit with c=1
 LDA pages,X
 CMP #&0D
 BNE norec
 LDA tempa
 STA grids
 CLC
 ADC #65
 STA latch
 LDX #LO(catch)
 LDY #HI(catch)
 LDA #repton_password - catch
 JSR write_characters
 SEC
 RTS

.wait_state                             ;x = delay .02 seconds
 TXA
 PHA
 LDA #19
 JSR osbyte
 PLA
 TAX
 DEX
 BNE wait_state
 RTS

.times28_lsb                            ;map data at map_table + &2A0
 EQUB LO(map_table)
 EQUB LO(map_table + 28 * &01)
 EQUB LO(map_table + 28 * &02)
 EQUB LO(map_table + 28 * &03)
 EQUB LO(map_table + 28 * &04)
 EQUB LO(map_table + 28 * &05)
 EQUB LO(map_table + 28 * &06)
 EQUB LO(map_table + 28 * &07)
 EQUB LO(map_table + 28 * &08)
 EQUB LO(map_table + 28 * &09)
 EQUB LO(map_table + 28 * &0A)
 EQUB LO(map_table + 28 * &0B)
 EQUB LO(map_table + 28 * &0C)
 EQUB LO(map_table + 28 * &0D)
 EQUB LO(map_table + 28 * &0E)
 EQUB LO(map_table + 28 * &0F)
 EQUB LO(map_table + 28 * &10)
 EQUB LO(map_table + 28 * &11)
 EQUB LO(map_table + 28 * &12)
 EQUB LO(map_table + 28 * &13)
 EQUB LO(map_table + 28 * &14)
 EQUB LO(map_table + 28 * &15)
 EQUB LO(map_table + 28 * &16)
 EQUB LO(map_table + 28 * &17)

.times28_msb
 EQUB HI(map_table)
 EQUB HI(map_table + 28 * &01)
 EQUB HI(map_table + 28 * &02)
 EQUB HI(map_table + 28 * &03)
 EQUB HI(map_table + 28 * &04)
 EQUB HI(map_table + 28 * &05)
 EQUB HI(map_table + 28 * &06)
 EQUB HI(map_table + 28 * &07)
 EQUB HI(map_table + 28 * &08)
 EQUB HI(map_table + 28 * &09)
 EQUB HI(map_table + 28 * &0A)
 EQUB HI(map_table + 28 * &0B)
 EQUB HI(map_table + 28 * &0C)
 EQUB HI(map_table + 28 * &0D)
 EQUB HI(map_table + 28 * &0E)
 EQUB HI(map_table + 28 * &0F)
 EQUB HI(map_table + 28 * &10)
 EQUB HI(map_table + 28 * &11)
 EQUB HI(map_table + 28 * &12)
 EQUB HI(map_table + 28 * &13)
 EQUB HI(map_table + 28 * &14)
 EQUB HI(map_table + 28 * &15)
 EQUB HI(map_table + 28 * &16)
 EQUB HI(map_table + 28 * &17)

.input
 EQUW pages
 EQUB 7
 EQUB 32
 EQUB 122

.get_map_byte                           ;get map byte a,x
 CMP #24                                ;exit if out of range
 BCS bites
 CPX #28
 BCS bites
 TAY
 LDA times28_lsb,Y
 STA tempa
 LDA times28_msb,Y
 STA tempx
 TXA                                    ;x > y
 TAY
 LDA (tempa),Y                          ;get map character
 RTS
.bites
 LDA #code_wall                         ;return with wall character
 RTS

.write_map_byte                         ;write map byte a,x,y
 CPY #24                                ;exit if out of range
 BCS tight
 CPX #28
 BCS tight
 STX tempy
 LDX times28_lsb,Y
 STX tempa
 LDX times28_msb,Y
 STX tempx
 LDY tempy                              ;x > y    
 STA (tempa),Y
.tight
 RTS

; scroll

.check_screen_address                   ;check screen address in range, a = start + &01
 BMI overflow                           ;>= &80
 CMP #HI(lomem)                         ;< &60?
 BCS check_screen_address_exit          ;no
 LDA #HI(himem) - &01                   ;wrap around to page below himem - &8000
 STA start + &01
 RTS
.overflow
 LDA #HI(lomem)                         ;start of video memory
 STA start + &01
.check_screen_address_exit
 RTS

.scroll_bytes_lsb                       ;      2
 EQUB LO(&08)                           ;      |
 EQUB LO(-&08)                          ; 1 ---+--- 0
 EQUB LO(-&100)                         ;      |
 EQUB LO(&100)                          ;      3

.scroll_bytes_msb
 EQUB HI(&08)
 EQUB HI(-&08)
 EQUB HI(-&100)
 EQUB HI(&100)

.scroll_update_address_lsb              ;point to screen address to update column/row with table overlap
 EQUB &F8                               ;0

.scroll_update_address_msb
 EQUB &00                               ;0
 EQUB &00                               ;1
 EQUB &00                               ;2
 EQUB &1F                               ;3

.scroll_screen
 LDA sting                              ;save vector offset
 TAX
 ASL A                                  ;c=0
 PHA
 LDA start + &00                        ;update video address according to direction of travel
 ADC scroll_bytes_lsb,X                 ;c=0
 STA start + &00
 LDA start + &01
 ADC scroll_bytes_msb,X
 STA start + &01                        ;n flag entry to routine
 JSR check_screen_address               ;start + &00/&01 = new screen address incl wrap around, x preserved
 LDA start + &00                        ;calculate address for screen update according to direction of travel
 CLC
 ADC scroll_update_address_lsb,X
 STA paras + &06                        ;paras + &06/&07 screen address to update from
 LDA start + &01
 ADC scroll_update_address_msb,X
 BPL repton_not_adjust
 SEC
 SBC #HI(screen_size)
.repton_not_adjust
 STA paras + &07                        ;paras + &06 /+ &07 screen address for column, row update
 LDA start + &01                        ;calculate 6845 screen address and place on stack
 STA tempa                              ;every cycle saved counts
 LSR A
 LSR A
 LSR A
 PHA                                    ;high address
 LDA start
 LSR tempa
 ROR A
 LSR tempa
 ROR A
 LSR tempa
 ROR A
 PHA                                    ;low address
 LDA #19                                ;wait for frame sync
 JSR osbyte
 LDX #&0D                               ;update 6845 screen address from stack
 STX sheila
 PLA                                    ;pull low address
 STA sheila + &01
 DEX
 STX sheila                             ;x=&0C
 PLA                                    ;pull high address
 STA sheila + &01
 PLA                                    ;vector offset
 TAX
 PHP                                    ;disable interrupts
 SEI
 LDA update_edge_part + &01,X
 PHA
 LDA update_edge_part,X
 PHA
 RTS                                    ;vector to update screen from buffer routine in direction of travel

.update_edge_part                       ;transfer buffer to screen memory
 EQUW repton_column_transfer - &01
 EQUW repton_column_transfer - &01
 EQUW repton_row_transfer    - &01
 EQUW repton_row_transfer    - &01

.setup_interrupt_and_event              ;patch in event and irq2 vector
 PHP
 SEI
 LDA #LO(repton_event)
 STA eventv + &00
 LDA #HI(repton_event)
 STA eventv + &01
 LDA #LO(repton_screen_interrupt)
 STA irq2v + &00
 LDA #HI(repton_screen_interrupt)
 STA irq2v + &01
 LDA #&00
 STA wait_flag                          ;clear wait flag
 PLP                                    ;restore irq status
 LDA #14                                ;enable event
 LDX #&04
 JMP osbyte

.apple
 EQUB &03
.timer
 EQUB &10

.random_numbers                         ;random number routine
 LDY #&29
 LDX #&FC
 CLC
.scroll_loops
 TYA
 LDY rand_plus,X
 ADC rand_plus,X
 STA rand_plus,X
 INX
 BNE scroll_loops
 RTS

.repton_event                           ;frame sync event
 PHP
 PHA   
 DEC apple                              ;counter to execute repton game timer
 BNE repton_interrupt_start             ;once every 0.06 seconds
 LDA #&03
 STA apple
 LDA death                              ;repton dead?
 BNE repton_interrupt_start             ;yes, check needed to distinguish between time out and killed
 LDA watch + &00                        ;by something other
 BNE decrement_lsb                      ;decrement repton game timer
 DEC watch + &01
.decrement_lsb
 DEC watch + &00
 LDA watch + &00
 ORA watch + &01
 BNE repton_interrupt_start             ;timer still active?
 INC death                              ;no, kill repton
.repton_interrupt_start
 LDA #&00
 STA scan_line_area                     ;reset area raster beam in
 LDA #user_via_aux_timer_1_continuous   ;auxillary register set for timer 1 continuous
 STA user_via_aux_reg
 LDA #LO(repton_time)
 STA user_via_timer_1_counter_lo        ;clear interrupt
 LDA #HI(repton_time)
 STA user_via_timer_1_counter_hi
 LDA #user_via_ier_timer_1              ;enable user via timer 1 interrupt
 STA user_via_ier_reg
 PLA
 PLP
 RTS

.repton_screen_interrupt
 BIT user_via_ifr_reg                   ;bit 7 is set if interrupt was from user 6522
 BPL exit_repton_screen_interrupt       ;only source of user via interrupts is timer 1
 LDA interrupt_accumulator              ;save all registers
 PHA
 TXA
 PHA
 TYA
 PHA
 LDA user_via_timer_1_counter_lo        ;clear interrupt
 LDA scan_line_area                     ;check on all but first pass
 BEQ no_music_yet                       ;not first pass
 DEC timer                              ;no check for music every time
 BNE no_music_yet                       ;no music yet
 LDA #&0E                               ;reload delay timer
 STA timer
 JSR play_repton_music                  ;play repton music
.no_music_yet                           ;exit
 INC scan_line_area                     ;increment the area number
 LDA scan_line_area
 CMP #&03                               ;switch off?
 BNE not_time_to_switch_off             ;no
 LDA #user_via_aux_clear                ;disable user via timer interrupt
 STA user_via_aux_reg
.not_time_to_switch_off
 PLA
 TAY
 PLA
 TAX
 PLA
 STA interrupt_accumulator
.exit_repton_screen_interrupt
 RTI

.datac
 EQUW map_table
 EQUW -672

.get_number_of_characters
 LDX #&04
.scrol_getit
 LDA datac - &01,X
 STA tempa - &01,X
 DEX
 BNE scrol_getit
 TXA
 LDY #&20
.alzer
 STA field - &01,Y
 STA fielh - &01,Y
 DEY
 BNE alzer
.trace
 LDA (tempa),Y
 CMP #32
 BCS notin
 TAX
 INC field,X
 BNE notin
 INC fielh,X
.notin
 INY
 BNE posit
 INC tempx
.posit
 INC tempy
 BNE trace
 INC tempz
 BNE trace
 RTS

.catalogues                             ;osfile parameter block to catalogue file
 EQUW diary
 EQUD &00
 EQUD &00
 EQUD &00
 EQUD &00

.loads                                  ;osfile parameter block to load file
 EQUW diary
 EQUD &31E0
 EQUD &00
 EQUD &00
 EQUD &00
.block
 EQUW diary
 EQUB 12
 EQUB 32
 EQUB 126
.futhr
 EQUD &00
 EQUD &00
.files
 EQUW &211
 EQUW &81F
 EQUB 7
 EQUS "ENTER  FILENAME"
 EQUW &111
 EQUW &171F
 EQUB 12
 EQUS "!"
 EQUW &71F
 EQUB 12
 EQUS "! "
 EQUW &311

.load_repton_map
 JSR all_colours_to_black
 JSR setup_custom_mode
 LDA #124
 JSR osbyte
 LDX #LO(files)
 LDY #HI(files)
 LDA #load_repton_map - files
 JSR write_characters
 JSR get_colours_from_map
 LDA #21                                ;clear keyboard buffer
 LDX #&00
 JSR osbyte
 LDX #LO(block)
 LDY #HI(block)
 LDA #&00
 JSR osword
 JSR alternate
 LDX #LO(loads)
 LDY #HI(loads)
 LDA #&FF
 JSR osfile                             ;load file at &31e0
 JSR rotate_all_screen_bytes
 JSR all_colours_to_black
 LDX #LO(catalogues)
 LDY #HI(catalogues)
 LDA #&05                               ;now read catalogue info to determine if compressed or umcompressed
 JSR osfile
 LDX catalogues + &0A
 LDY catalogues + &0B
 CPX #LO(map_file_length)
 BNE compressed_file
 CPY #HI(map_file_length)
 BEQ standard_map_file                  ;standard map file so leave it and set standard map characters
.compressed_file
 TXA
 SEC
 SBC #LO(map_characters_length)
 STA indir                              ;file transfer counter
 TYA
 SBC #HI(map_characters_length)         ;x/y = file length minus &180, map characters length
 STA indir + &01
 LDA #LO(map_file_start + map_characters_length)
 STA tempa
 LDA #HI(map_file_start + map_characters_length)
 STA tempx
 LDA #LO(lomem)                         ;destination address to un compress data
 STA tempy
 LDA #HI(lomem)
 STA tempz
 LDY #&00                               ;transfer compressed data to lomem
.transfer_compressed_map
 LDA (tempa),Y
 STA (tempy),Y
 INY
 BNE no_inc_high
 INC tempx                              ;next page for source/destination
 INC tempz
.no_inc_high
 LDA indir
 BNE counter_low
 DEC indir + &01
.counter_low
 DEC indir
 LDA indir
 ORA indir + &01
 BNE transfer_compressed_map
 LDX #&7F                               ;transfer &180 of small map characters from start of compressed file
.transfer_page_of
 LDA map_file_start,X
 STA extended_squeze,X
 LDA map_file_start + &80,X
 STA extended_squeze + &80,X
 LDA map_file_start + &100,X
 STA extended_squeze + &100,X
 DEX
 BPL transfer_page_of
 LDA #LO(extended_squeze)               ;point at extended character set
 STA map_file_in_use
 LDA #HI(extended_squeze)
 STA map_file_in_use + &01
 LDA #&02
 STA map_file_index
 JMP full_decompress                    ;now decompress map file from swr to main rams

.standard_map_file
 LDA #&00
 STA map_file_index                     ;point at default character set
 LDA #LO(squeze)
 STA map_file_in_use
 LDA #HI(squeze)
 STA map_file_in_use + &01
 RTS

.alternate
 LDA diary
 CMP #&0D
 BEQ made_a_mistake
 LDA diary
 CMP #32
 BNE cards
 LDX #&00
.shove
 LDA diary + &01,X
 STA diary,X
 INX
 CPX #12
 BCC shove
 BCS alternate
.cards
 LDA diary
 CMP #ascii_colon
 BNE nodri
 LDA diary + &02
 CMP #ascii_full_stop
 BNE made_a_mistake
 LDA diary + &01
 JSR select_drive
 LDX #&00
.shufl
 LDA diary + &03,X
 STA diary,X
 INX
 CPX #12
 BCC shufl
.nodri
 RTS

.drive
 EQUS "DRIVE *", &0D

.select_drive
 STA drive + &06
 LDX #LO(drive)
 LDY #HI(drive)
 JMP oscli

.mistake
 EQUB &00
 EQUB &07
 EQUS "Syntax error"
 EQUB &00

.made_a_mistake
 LDX #made_a_mistake - mistake
.pushs
 LDA mistake,X
 STA stack,X
 DEX
 BPL pushs
 BRK
