; extra

; addresses
 repton_dummy_address                   = &1000

 INCLUDE "tables\identity table.asm"

.title_sprite                           ;storage for main sprite
 INCBIN  "binary\repton_logo.bin"
 INCLUDE "reptn.asm"
 INCLUDE "sprit.asm"
 INCLUDE "monst.asm"

.extended_squeze                        ;storage for new small map characters
 INCBIN  "repton small maps\common.bin"

.write_map_graphic                      ;a=map character
 ASL A
 ASL A
 ASL A
 ROL tempz
 CLC
 ADC map_file_in_use                    ;pointer to character set
 STA tempy
 LDA tempz                              ;mask off high bits
 AND #&01
 ADC map_file_in_use + &01
 STA tempz
 TXA
 ASL A
 ASL A
 ASL A
 ROL tempx
 CLC
 ADC start
 STA tempa
 LDA tempx
 AND #&01
 ADC start + &01
 STA tempx
 TYA
 CLC
 ADC tempx
 BPL wraps
 SEC                                    ;bring into range
 SBC #HI(screen_size)
.wraps
 STA tempx
 LDY #&07                               ;store a full character to screen
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 DEY
 LDA (tempy),Y
 STA (tempa),Y
 RTS

.read_map_flip_keys                     ;flip small map character sets
 LDX #bbc_y_key                         ;read y key
 JSR read_a_passed_key
 BPL no_pressed_y_key
 LDX #&07                               ;test if current/new character sets are the same
.test_first_map_character               ;by looking at first small character
 LDA squeze,X
 CMP extended_squeze,X
 BNE different_character_sets           ;different so swap
 DEX
 BPL test_first_map_character
 RTS                                    ;same character sets so exit

.no_pressed_y_key                       ;clear debounce flag
 LSR combined_bbc_y_key
.exit_character_swap
 RTS

.combined_bbc_y_key
 EQUB &00

.different_character_sets               ;swap the sets over
 LDA combined_bbc_y_key                 ;previously pressed?
 BNE exit_character_swap                ;yes
 INC combined_bbc_y_key                 ;set y key pressed
 LDA map_file_index                     ;flip pointers
 EOR #&02
 STA map_file_index
 TAX
 LDA squeze_pointers,X                  ;current small character set address
 STA map_file_in_use
 LDA squeze_pointers + &01,X
 STA map_file_in_use + &01
 JMP display_map                        ;write out map

.print_repton_sign                      ;repton title graphic
 LDX #&00
.title_rows
 FOR rows, &00, &06
  LDA title_sprite + rows * &100,X
  STA lomem + &100 + rows * &100,X
 NEXT
 DEX
 BNE title_rows
 RTS

.repton_sprite_addresses                ;holds the addresses of the sprites for an edge row/column
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites
 EQUW map_sprites

.initialise_edges
 LDA #&00
 STA lenth
 LDX sting
 LDA reptx
 CLC
 ADC squax,X
 STA cornx
 LDA repty
 CLC
 ADC squay,X
 STA corny
 LDA movie
 CMP #&02
 BCC initialise_edges_exit
 LDA cornx
 CLC
 ADC adjux,X
 STA cornx
 LDA corny
 CLC
 ADC adjuy,X
 STA corny
.initialise_edges_exit
 RTS

.squax                                  ;table overlap
 EQUB 4
 EQUB -4

.squay
 EQUB -5
 EQUB -5
 EQUB -4
 EQUB 4

.adjux                                  ;table overlap
 EQUB &01
 EQUB &FF

.adjuy
 EQUB &00
 EQUB &00
 EQUB &FF
 EQUB &01

.direx                                  ;table overlap
 EQUB &00
 EQUB &00

.direy
 EQUB &01
 EQUB &01
 EQUB &00
 EQUB &00

.movie_direx                            ;table overlap
 EQUB &00
 EQUB &FF

.movie_direy
 EQUB &00
 EQUB &00
 EQUB &FF
 EQUB &00

.move_edge_x                            ;offsets to edges from repton x
 EQUB 18
 EQUB -17
 EQUB &00
 EQUB &00

.move_edge_y                            ;offsets to edges from repton y
 EQUB -17
 EQUB 18
 EQUB &00
 EQUB &00

.repton_row_transfer                    ;transfer the buffer to a screen row address, paras + &06/&07
 LDX paras + &06
 LDY #&00
 CLC                                    ;for addition later
.repton_start_page                      ;transfer first part of page
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256,Y
 STA (paras + &06),Y
 INY
 TXA
 ADC #&08                               ;c=0
 TAX
 BNE repton_start_page                  ;continue until end of screen page
 TYA                                    ;full page done?
 BEQ repton_row_transfer_end            ;yes
 TAX
 LDY #&00
 STY paras + &06
 CLC                                    ;for addition later
 INC paras + &07
 BPL repton_end_page                    ;no
 LDA #HI(lomem)                         ;wrap around
 STA paras + &07
.repton_end_page                        ;remainder of page
 LDA scroll_buffer_256 + &00,X          ;store buffer from start of wrap around page, y = 0
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &01,X
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &02,X
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &03,X
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &04,X
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &05,X
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &06,X
 STA (paras + &06),Y
 INY
 LDA scroll_buffer_256 + &07,X
 STA (paras + &06),Y
 INY
 TXA
 ADC #&08                               ;c=0
 TAX
 BNE repton_end_page                    ;continue to end of scroll buffer
.repton_row_transfer_end
 PLP                                    ;restore irq status
 RTS

.repton_column_transfer                 ;transfer a column from buffer to screen, paras + &06/&07
 FOR y, 0, 31
  LDY #&00
  FOR x, 0, 7
   LDA scroll_buffer_256 + x + y * 8
   STA (paras + &06),Y
   INY
  NEXT
  INC paras + &07                       ;next row down
  BPL repton_screen                     ;bring into range if required
  LDA #HI(lomem)
  STA paras + &07
 .repton_screen
 NEXT
 PLP                                    ;restore irq status
 RTS

.update_row_or_column                   ;populate repton scroll buffer with map tile addresses
 JSR initialise_edges                   ;initial calculation for map x/y in direction of travel
.all_edge_tiles
 LDX sting                              ;get coordinate map byte
 LDA cornx
 CLC
 ADC direx,X
 STA cornx
 LDA corny
 CLC
 ADC direy,X
 STA corny
 LDX cornx
 JSR get_map_byte                       ;get map byte at x/y
 LDX #&00
 STX paras + &00                        ;multiply by sprite size of &80
 LSR A
 ROR paras
 CLC
 ADC #HI(map_sprites)                   ;add in table address
 STA paras + &01                        ;paras +&00/&01 now has the sprite address
 LDA sting
 ASL A
 ASL A
 ORA movie                              ;counter for repton steps 0-3 x 4 for index
 TAX
 LDA map_sprite_scroll_offset,X         ;guaranteed bottom 7 bits clear
 CLC                                    ;add in direction offset
 ADC paras + &00                        ;no need to add to high byte as sprite size 128 and on a page boundary
 STA paras
 LDA lenth                              ;put sprite address into address table
 ASL A
 TAX
 LDA paras + &00
 STA repton_sprite_addresses,X
 LDA paras + &01
 STA repton_sprite_addresses + &01,X
 INC lenth
 LDA lenth
 CMP #&09
 BCC all_edge_tiles                     ;update for nine pieces of screen tile
 LDA sting
 AND #&02
 TAX
 LDA sides_update + &01,X
 PHA
 LDA sides_update,X
 PHA
 RTS                                    ;vector to routine to transfer sprite data to buffer

.map_sprite_scroll_offset               ;      2
 EQUD &08001810                         ;      |
 EQUD &10180008                         ; 1 ---+--- 0
 EQUD &40600020                         ;      |
 EQUD &20006040                         ;      3

.sides_update
 EQUW repton_going_left_right - &01     ;0/1
 EQUW repton_going_up_down    - &01     ;2/3

MACRO transfer_block_of_eight offset
FOR j, 0, 7
 LDA (paras + &04),Y
 STA scroll_buffer_256 + j + offset,X
 INY
NEXT
ENDMACRO

MACRO transfer_block_of_eight_no_x offset
FOR j, 0, 7
 LDA (paras + &04),Y
 STA scroll_buffer_256 + j + offset
 INY
NEXT
ENDMACRO

MACRO repton_load_sprite_address which_two
 LDA repton_sprite_addresses + which_two * &02
 STA paras + &04
 LDA repton_sprite_addresses + which_two * &02 + &01
 STA paras + &05
ENDMACRO

.repton_going_left_right                ;direction 0/1 build in buffer
 LDY #&40                               ;top two squares
 repton_load_sprite_address &00
 transfer_block_of_eight_no_x &00
 LDY #&60
 transfer_block_of_eight_no_x &08
 repton_load_sprite_address &01
 LDX #&10
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &02
 LDX #&30
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &03
 LDX #&50
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &04
 LDX #&70
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &05
 LDX #&90
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &06
 LDX #&B0
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &07
 LDX #&D0
 JSR transfer_map_vertical_strip
 repton_load_sprite_address &08
 LDY #&00                               ;bottom two squares
 transfer_block_of_eight_no_x &F0
 LDY #&20
 transfer_block_of_eight_no_x &F8
 RTS

.repton_going_up_down                   ;direction 2/3 build in buffer
 LDY #&10                               ;left/right two squares
 repton_load_sprite_address &00         ;get address of sprite block start from table
 transfer_block_of_eight_no_x &00
 transfer_block_of_eight_no_x &08
 LDX #&10
 repton_load_sprite_address &01
 JSR transfer_map_horizontal_strip
 LDX #&30
 repton_load_sprite_address &02
 JSR transfer_map_horizontal_strip
 LDX #&50
 repton_load_sprite_address &03
 JSR transfer_map_horizontal_strip
 LDX #&70
 repton_load_sprite_address &04
 JSR transfer_map_horizontal_strip
 LDX #&90
 repton_load_sprite_address &05
 JSR transfer_map_horizontal_strip
 LDX #&B0
 repton_load_sprite_address &06
 JSR transfer_map_horizontal_strip
 LDX #&D0
 repton_load_sprite_address &07
 JSR transfer_map_horizontal_strip
 LDY #&00                               ;left/right two squares
 repton_load_sprite_address &08
 transfer_block_of_eight_no_x &F0
 transfer_block_of_eight_no_x &F8
 RTS

MACRO add_24_to_y
 TYA                                    ;add 24 for next sprite column
 CLC
 ADC #&18
 TAY
ENDMACRO

.transfer_map_vertical_strip            ;full height sprite strip to buffer
 LDY #&00
 transfer_block_of_eight &00
 add_24_to_y
 transfer_block_of_eight &08
 add_24_to_y
 transfer_block_of_eight &10
 add_24_to_y
 transfer_block_of_eight &18
 RTS

MACRO transfer_block_of_thirty_two
FOR j, 0, 31
 LDA (paras + &04),Y
 STA scroll_buffer_256 + j,X
 INY
NEXT
ENDMACRO

.transfer_map_horizontal_strip          ;full width sprite strip to buffer
 LDY #&00                               ;y = offset into sprite data
 transfer_block_of_thirty_two
 RTS

.place_repton_mask                      ;place repton on screen at center
 LDA #&FF                               ;set up some game variables as part of this
 STA sting                              ;used for initial placing of repton at start of game,
 STA twent                              ;after transporting and return from map/status screens
 STA bomba
 LDA #&00
 STA movie
 LDA #&80
 STA infom + 27
 LDX reptx                              ;write repton to the map
 LDY repty
 LDA #code_repton
 JSR write_map_byte
 LDA #code_space                        ;setup sprites to use, space for background
 STA paras + &00                        ;repton for background
 LDA #code_repton
 STA paras + &01
 LDA #&11                               ;screen coordinates
 STA paras + &02
 STA paras + &03                        ;roll into routine below

.sprite_mask_place                      ;mask complete sprite on screen, foregound completely over background
 LDA start                              ;used for placing repton on screen
 SEC                                    ;paras + &00/&01 background/foreground sprite number
 SBC #LO(map_sprite_offset)             ;paras + &02/&03 screen coordinates x,y 0/31, 0/31
 STA indir                              ;paras + &07/&08 screen address
 LDA start + &01
 SBC #HI(map_sprite_offset)
 STA indir + &01
 LDA paras + &02
 ASL A
 ASL A
 ASL A
 ROL paras + &08
 CLC
 ADC indir
 STA paras + &07
 LDA paras + &08
 AND #&01
 ADC indir + &01
 STA paras + &08
 LDA paras + &03
 CLC
 ADC paras + &08
 BPL sprite_thats
 SEC
 SBC #HI(screen_size)
.sprite_thats
 STA paras + &08
 LDX paras + &00                        ;paras + &00 = sprite background number, get address from table
 LDA sprites_address_lsb,X              ;paras + &01 = sprite foreground number, get address from table
 STA paras + &03                        ;paras + &03/&04 background sprite address
 LDA sprites_address_msb,X              ;paras + &05/&06 foreground sprite address
 STA paras + &04
 LDX paras + &01
 LDA sprites_address_lsb,X
 STA paras + &05
 LDA sprites_address_msb,X
 STA paras + &06
 LDY #&7F                               ;transfer background sprite to buffer
.create_full_graphic                    ;and with mask from foreground sprite
 LDA (paras + &05),Y                    ;then ora with foreground sprite
 TAX
 LDA (paras + &03),Y
 AND mask_table,X
_ORA_X                                  ;perform a or x from identity table, slightly faster
 STA sprite_128,Y
 DEY
 BPL create_full_graphic                ;buffer now contains background/foregound sprite
 LDA #&00
 STA paras + &05                        ;now transfer buffer to screen one row, eight cells at a time
 LDA #HI(sprite_128)                    ;checking for screen wrap-around
 STA paras + &06                        ;buffer must be page aligned
 LDX #&04                               ;row counter
.transfer_four_lines
 TXA
 PHA
 LDX #&04
.transfer_four_characters
 LDY #&07
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
 DEY
 LDA (paras + &05),Y
 STA (paras + &07),Y
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
 BPL no_wrap_around_inner
 LDA #HI(lomem)
.no_wrap_around_inner
 STA paras + &08
 DEX
 BNE transfer_four_characters
 LDA paras + &07
 CLC
 ADC #&E0                               ;add &e0 to screen address, wrap around if necessary
 STA paras + &07
 LDA paras + &08
 ADC #&00
 BPL no_wrap_around_outer
 LDA #HI(lomem)
.no_wrap_around_outer
 STA paras + &08
 PLA
 TAX
 DEX
 BNE transfer_four_lines
 RTS

.sprite_build_background                ;build sliding background in buffer
 LDX paras + &00                        ;paras + &00/&01 background sprite numbers
 LDA sprites_address_lsb,X              ;paras + &02     direction of travel 0-3
 STA paras + &03
 LDA sprites_address_msb,X              ;paras + &03/&04 background sprite address
 STA paras + &04                        ;paras + &05/&06 background sprite address
 LDX paras + &01                        ;      2
 LDA sprites_address_lsb,X              ;      |
 STA paras + &05                        ; 1 ---+--- 0
 LDA sprites_address_msb,X              ;      |
 STA paras + &06                        ;      3
 LDA paras + &02
 CMP #&02
 BCS build_up_down
 LDX #&00                               ;build left/right
 LDY #&00                               ;transfer two background sprites to buffer consecutively
 LDA #&04
.build_left_right_another
 PHA
 LDA #&20
.build_left_right_transfer
 PHA
 LDA (paras + &03),Y                    ;first background sprite
 STA sprite_256,X
 LDA (paras + &05),Y                    ;second background sprite
 STA sprite_256 + &20,X
 INX
 INY
 PLA
 SEC
 SBC #&01
 BNE build_left_right_transfer          ;build a row
 TXA                                    ;push x on by &20 bytes for next row
 CLC
 ADC #&20                               ;c=0 from comparison
 TAX
 PLA
 SEC
 SBC #&01
 BNE build_left_right_another
 RTS

.build_up_down                          ;transfer two background sprites to buffer one after the other
 LDY #&7F
.build_up_down_transfer
 LDA (paras + &03),Y
 STA sprite_256,Y
 LDA (paras + &05),Y
 STA sprite_256 + &80,Y
 DEY
 BPL build_up_down_transfer
 RTS

.sprite_mask_foreground                 ;mask sprite onto buffer
 LDA paras + &01                        ;paras + &00 foreground sprite number
 indirect_jump buffer_mask_fill         ;paras + &01 direction of travel 0-3, paras + &02 counter into travel 0-3

.buffer_mask_fill
 EQUW fill_in_00 - &01
 EQUW fill_in_01 - &01
 EQUW fill_in_02 - &01
 EQUW fill_in_03 - &01

.times_08                               ;00 right
 EQUB &08
 EQUB &10
 EQUB &18
 EQUB &20
.reverse_08                             ;01 left
 EQUB &18
 EQUB &10
 EQUB &08
 EQUB &00
.reverse_32                             ;02 up
 EQUB &60
 EQUB &40
 EQUB &20
 EQUB &00
.times_32                               ;03 down
 EQUB &20
 EQUB &40
 EQUB &60
 EQUB &80

.fill_in_00                             ;00 - right
 LDX paras + &02                        ;counter into travel
 LDA times_08,X                         ;add 8
 STA paras + &05
 LDA #HI(sprite_256)
 STA paras + &06
.place_zero
 LDX paras + &00                        ;sprite to mask
 LDA sprites_address_lsb,X              ;get sprite address
 STA paras + &03
 LDA sprites_address_msb,X
 STA paras + &04
 LDX #&04
.another_line
 TXA
 PHA
 LDY #&1F                               ;mask sprite onto buffer
.create_sprite_buffer_line
 LDA (paras + &03),Y
 TAX
 LDA (paras + &05),Y
 AND mask_table,X
_ORA_X                                  ;perform a or x from identity table, slightly faster
 STA (paras + &05),Y
 DEY
 BPL create_sprite_buffer_line
 LDA paras + &03                        ;add 32 to sprite address
 CLC
 ADC #&20
 STA paras + &03
 LDA paras + &05                        ;add 64 to buffer address
 CLC
 ADC #&40
 STA paras + &05
 PLA
 TAX
 DEX
 BNE another_line
 RTS

.fill_in_01                             ;01 - left
 LDX paras + &02                        ;counter into travel
 LDA reverse_08,X                       ;calculate offset into buffer
 STA paras + &05
 LDA #HI(sprite_256)
 STA paras + &06
 JMP place_zero

.fill_in_02                             ;02 - up
 LDX paras + &02                        ;counter into travel
 LDA reverse_32,X                       ;calculate offset into buffer
 STA paras + &05
 LDA #HI(sprite_256)
 STA paras + &06
.place_two
 LDX paras + &00                        ;sprite to mask
 LDA sprites_address_lsb,X              ;get sprite address
 STA paras + &03
 LDA sprites_address_msb,X
 STA paras + &04
 LDY #&7F                               ;mask sprite onto buffer
.create_sprite_buffer
 LDA (paras + &03),Y
 TAX
 LDA (paras + &05),Y
 AND mask_table,X
_ORA_X                                  ;perform a or x from identity table, slightly faster
 STA (paras + &05),Y
 DEY
 BPL create_sprite_buffer
 RTS

.fill_in_03                             ;03 - down
 LDX paras + &02                        ;counter into travel
 LDA times_32,X                         ;add 32
 STA paras + &05
 LDA #HI(sprite_256)
 STA paras + &06
 JMP place_two

.sprite_screen_adjust                   ;adjust screen start address to erase previous position
 EQUW -&08
 EQUW &00
 EQUW &00
 EQUW -&100

.sprite_buffer_offset
 EQUB &00                               ;00 right
 EQUB &08
 EQUB &10
 EQUB &18

 EQUB &18                               ;01 left
 EQUB &10
 EQUB &08
 EQUB &00

 EQUB &60                               ;02 up
 EQUB &40
 EQUB &20
 EQUB &00

 EQUB &00                               ;03 down
 EQUB &20
 EQUB &40
 EQUB &60

.sprite_mask_screen                     ;place sprite on screen from that built up in buffer
 LDA start                              ;paras + &00 sprite x 0/31
 SEC                                    ;paras + &01 sprite y 0/31
 SBC #LO(map_sprite_offset)             ;paras + &02 direction of travel
 STA indir                              ;paras + &03 travel counter
 LDA start + &01
 SBC #HI(map_sprite_offset)
 STA indir + &01
 LDA paras + &00
 ASL A
 ASL A
 ASL A
 ROL paras + &08
 CLC
 ADC indir
 STA paras + &07
 LDA paras + &08
 AND #&01
 ADC indir + &01
 STA paras + &08
 LDA paras + &01
 CLC
 ADC paras + &08
 STA paras + &08                        ;screen address calculated
 LDA paras + &02                        ;now adjust the screen address according
 ASL A                                  ;to the direction of travel
 TAX
 LDA paras + &07
 CLC
 ADC sprite_screen_adjust,X
 STA paras + &07
 LDA paras + &08
 ADC sprite_screen_adjust + &01,X
 BPL mask_thats
 SEC                                    ;wrap around screen
 SBC #HI(screen_size)
.mask_thats
 CMP #HI(lomem)
 BCS in_low_range
 ADC #&20                               ;c=0 bring into range
.in_low_range
 STA paras + &08                        ;paras + &07/&08 screen address
 LDA paras + &02                        ;direction of travel
 ASL A
 ASL A
 ADC paras + &03                        ;c=0 travel counter
 TAX                                    ;index into sprite buffer offset
 LDA sprite_buffer_offset,X             ;paras + &05/&06 sprite address
 STA paras + &05
 LDA #HI(sprite_256)
 STA paras + &06
 LDA paras + &02
 CMP #&02
 BCC left_or_right
 LDA #&05                               ;row counter plus one for erasure
.sprite_row
 PHA
 LDX #&04                               ;column counter
.sprite_column
 LDY #&00                               ;transfer one cell of buffer to screen
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
 LDA paras + &07                        ;add 8 to screen address
 CLC
 ADC #&08
 STA paras + &07
 BCC no_carry_for_cell
 INC paras + &08
 BPL no_carry_for_cell
 LDA #HI(lomem)                         ;wrap around screen
 STA paras + &08
.no_carry_for_cell
 LDA paras + &05                        ;next buffer cell
 CLC
 ADC #&08
 STA paras + &05
 DEX
 BNE sprite_column                      ;do four columns
 LDA paras + &07                        ;move onto next screen row
 CLC
 ADC #&E0
 STA paras + &07
 LDA paras + &08
 ADC #&00
 BPL no_sprite_wrap_01
 SEC                                    ;wrap around screen
 SBC #HI(screen_size)
.no_sprite_wrap_01
 STA paras + &08
 PLA
 SEC
 SBC #&01
 BNE sprite_row                         ;do five rows
 RTS

.left_or_right
 LDA #&04                               ;row counter plus one for erasure
.sprite_row_horizontal
 PHA
 LDX #&05                               ;column counter
.sprite_column_horizontal
 LDY #&00                               ;transfer one cell of buffer to screen
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
 LDA paras + &07                        ;add 8 to screen address
 CLC
 ADC #&08
 STA paras + &07
 BCC no_carry_for_cell_horizontal
 INC paras + &08
 BPL no_carry_for_cell_horizontal
 LDA #HI(lomem)                         ;wrap around screen
 STA paras + &08
.no_carry_for_cell_horizontal
 LDA paras + &05                        ;next buffer cell
 CLC
 ADC #&08
 STA paras + &05
 DEX
 BNE sprite_column_horizontal           ;do five columns
 LDA paras + &05
 CLC
 ADC #&18
 STA paras + &05
 LDA paras + &07                        ;move onto next screen row
 CLC
 ADC #&D8
 STA paras + &07
 LDA paras + &08
 ADC #&00
 BPL no_sprite_wrap_02
 SEC                                    ;wrap around screen
 SBC #HI(screen_size)
.no_sprite_wrap_02
 STA paras + &08
 PLA
 SEC
 SBC #&01
 BNE sprite_row_horizontal              ;do four rows
 RTS

.monsters_spirits_on_edges              ;eor partial monsters/spirits when scrolling
 LDX #&03                               ;check monsters
.test_monsters
 LDA anoth,X                            ;monster on?
 BNE leave_monster_alone                ;no
 LDA framc,X
 STA paras + &00                        ;paras + &00 = sprite frame
 LDA xcoor,X
 STA tempa                              ;tempa = sprite x
 LDA monsc,X
 STA tempx                              ;tempx = sprite movement counter
 LDA ycoor,X
 STA tempy                              ;tempy = sprite y
 LDA direc,X
 STA tempz                              ;tempz = sprite direction
 TXA
 PHA
 JSR update_repton_coordinates          ;calculate the fine coordinates
 JSR sprite_x_coordinate
 JSR sprite_y_coordinate
 JSR check_repton_edge_direction
 BCS leave_monster_alone_pull_x         ;nothing to add in for direction of travel
 JSR eor_sprite_in_buffer
.leave_monster_alone_pull_x
 PLA
 TAX
.leave_monster_alone
 DEX
 BPL test_monsters
 LDX #&07                               ;check spirits
.test_spirits
 LDA spirp,X                            ;spirit on?
 BMI leave_spirit_alone                 ;no
 LDA spirf,X
 STA paras + &00                        ;paras + &00 = sprite frame
 LDA spirx,X
 STA tempa                              ;tempa = sprite x
 LDA spirc,X
 STA tempx                              ;tempx = sprite movement counter
 LDA spiry,X
 STA tempy                              ;tempy = sprite y
 LDA spird,X
 STA tempz                              ;tempz = sprite direction
 TXA
 PHA
 JSR update_repton_coordinates          ;calculate the fine coordinates
 JSR sprite_x_coordinate
 JSR sprite_y_coordinate
 JSR check_repton_edge_direction
 BCS leave_spirit_alone_pull_x          ;nothing to add in for direction of travel
 JSR eor_sprite_in_buffer
.leave_spirit_alone_pull_x
 PLA
 TAX
.leave_spirit_alone
 DEX
 BPL test_spirits
 RTS

.check_repton_edge_direction            ;check screen edge in repton's move direction for an overlap
 LDA sting                              ;repton's direction
 indirect_jump edge_check

.edge_check
 EQUW direction_00 - &01
 EQUW direction_01 - &01
 EQUW direction_02 - &01
 EQUW direction_03 - &01

.direction_00
 LDA tempa                              ;paras + &01/&02 = new repton x/y
 SEC                                    ;tempa = sprite x
 SBC paras + &01                        ;tempy = sprite y
 CMP #&12
 BCS not_on_edge
 SBC #&12 - &05                         ;c=0
 CMP #&04
 BCS not_on_edge
 EOR #&03
.direction_00_y
 STA sprite_part                        ;sprite part 0-3
 LDA tempy                              ;sprite y - repton y
 SEC
 SBC paras + &02
 TAX                                    ;save result
 BCS y_relative_positive
 EOR #&FF
 ADC #&01                               ;c=0
.y_relative_positive
 CMP #19                                ;out of y range?
 BCS not_on_edge                        ;yes
 TXA
 ADC #&11                               ;correct to buffer coordinates. c=0
 STA sprite_buffer_adjust
 CLC
.not_on_edge
 RTS                                    ;c=0/1 part sprite on edge or not

.direction_01
 LDA paras + &01                        ;paras + &01/&02 = new repton x/y
 SEC                                    ;tempa = sprite x
 SBC tempa                              ;tempy = sprite y
 CMP #&12
 BCS not_on_edge
 SBC #&12 - &05                         ;c=0
 CMP #&04
 BCS not_on_edge
 BCC direction_00_y                     ;always

.direction_02
 LDA paras + &02
 SEC
 SBC tempy
 CMP #&12
 BCS not_on_edge
 SBC #&12 - &05                         ;c=0
 CMP #&04
 BCS not_on_edge
.direction_00_x
 STA sprite_part                        ;sprite part 0-3
 LDA tempa
 SEC
 SBC paras + &01
 TAX
 BCS x_relative_positive
 EOR #&FF
 ADC #&01                               ;c=0
.x_relative_positive
 CMP #19                                ;out of x range?
 BCS not_on_edge                        ;yes
 TXA
 ADC #&11                               ;correct to buffer coordinates, c=0
 STA sprite_buffer_adjust
 CLC
 RTS

.direction_03
 LDA tempy
 SEC
 SBC paras + &02
 CMP #&12
 BCS not_on_edge
 SBC #&12 - &05
 CMP #&04
 BCS not_on_edge
 EOR #&03                               ;sprite part 0-3
 BCC direction_00_x                     ;always

.update_repton_coordinates              ;calculate coordinates as if repton had moved one cell
 LDA reptx                              ;save repton x/y and movement counter
 PHA
 LDA repty
 PHA
 LDA movie
 PHA
 CLC                                    ;one space on for new sprite window
 ADC #&01
 STA movie
 CMP #&04
 BCC repton_between_squares
 LDX sting                              ;calculate new repton x/y position and update
 LDA reptx                              ;then zeroise movement counter
 CLC                                    ;moved on one square
 ADC adjux,X
 STA reptx
 LDA repty
 CLC
 ADC adjuy,X
 STA repty
 LDA #&00
 STA movie
.repton_between_squares
 JSR repton_x_coordinate                ;calculate the fine coordinates
 JSR repton_y_coordinate
 PLA                                    ;restore repton x/y and movement counter
 STA movie
 PLA
 STA repty
 PLA
 STA reptx
 RTS

.eor_sprite_in_buffer
 LDA sting                              ;repton direction
 AND #&02
 ASL A
 ADC sprite_part                        ;sprite part &00 - &03, c=0
 TAX
 LDA sprite_offset,X                    ;get sprite offset either x &08 or x &20
 LDX paras + &00                        ;paras = sprite number, get address from table
 ORA sprites_address_lsb,X              ;paras + &05/&06 sprite address
 STA paras + &05                        ;lsb either &00 or &80 so ora not adc
 LDA sprites_address_msb,X
 STA paras + &06
 LDA #&00
 STA paras + &08                        ;clear msb
 LDA sprite_buffer_adjust               ;sprite adjust position * &08 into scroll buffer
 ASL A                                  ;result can be greater than &100 hence two bytes
 ASL A
 ASL A
 ROL paras + &08
 CLC
 ADC #LO(scroll_buffer_256 - &08 * &03) ;paras + &07/&08 scroll buffer address
 STA paras + &07
 LDA #HI(scroll_buffer_256 - &08 * &03)
 ADC paras + &08
 STA paras + &08
 LDX #&04
.eor_sprite_loop
 LDA paras + &08
 CMP #HI(scroll_buffer_256)             ;in buffer area?
 BNE sprite_cell_not_in_buffer          ;no, onto next cell
 LDY #&00                               ;eor a sprite cell with the buffer
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
.sprite_cell_not_in_buffer
 LDY sting
 LDA paras + &05                        ;address is on &80 boundary, so c=1 only on loop exit
 CLC                                    ;for second half sprites only
 ADC sprite_direction,Y
 STA paras + &05
 LDA paras + &07                        ;add &08, to buffer address, c=0
 ADC #&08
 STA paras + &07
 LDA paras + &08
 ADC #&00
 STA paras + &08
 DEX
 BNE eor_sprite_loop
 RTS

.sprite_direction
 EQUD &08082020

.sprite_offset
 EQUD &18100800                         ;x&08 table
 EQUD &60402000                         ;x&20 table

 ALIGN &100

.map_table                              ;map unpacked and used here             |
 SKIP &300                              ;                                       |
                                        ;                                       |
.scroll_buffer_256                      ;row/column buffer                      | keep all these buffers
 SKIP &100                              ;                                       | on page boundaries
                                        ;                                       |
.sprite_256                             ;sprite buffer for masking operations   |
 SKIP &100                              ;                                       |

.repton3_end
