; master build assembler
;
; repton1 - game loader
; repton2 - game code
; repton3 - game code
; repton4 - game code

; constants
 repton1_limit = &0D00
 repton2_limit = &31E0
 repton3_limit = &C000
 repton4_limit = &6000

; addresses

 mode_5_start                           = &5800
 repton3_loaded_at                      = &2000
 repton3_relocated_to                   = &8000
 swr_address                            = &8000
 first_swr_ram                          = &8000

 screen_size                            = &2000

 INCLUDE "operating system.asm"         ;data files for main assembly
 INCLUDE "page zero.asm"                ;all declarations in here to prevent duplication

 ; envelope data
MACRO envelope n, t, pi1, p12, pi3, pn1, pn2, pn3, aa, ad, as, ar, ala, ald
 EQUB n
 EQUB t
 EQUB pi1
 EQUB p12
 EQUB pi3
 EQUB pn1
 EQUB pn2
 EQUB pn3
 EQUB aa
 EQUB ad
 EQUB as
 EQUB ar
 EQUB ala
 EQUB ald
ENDMACRO

MACRO indirect_jump address_table
 ASL A
 TAX
 LDA address_table + &01,X
 PHA
 LDA address_table,X
 PHA
 RTS
ENDMACRO

 CPU 0                                  ;6502 processor

 ORG   &0A00
 CLEAR &0A00, &0CFF
 GUARD &0D00

.repton1                                ;repton loader
 EQUS "bbc b/b+ master 128/master compact repton 3 redux © superior software ltd / superior interactive 1986-2023 "
 EQUS "version 1.0 assembled on "
 EQUS TIME$

.repton1_execute
 JSR find_swr_ram_slot                  ;find a bank of ram
 JSR setup_screen                       ;mode 5, turn cursor and colours off
 JSR set_up_envelopes                   ;initialise envelopes
 LDA #ascii_03                          ;load repton3
 JSR load_named_repton
 JSR select_swr_ram_slot                ;page in swr
 LDX #&40                               ;transfer to swr
 LDY #&00
.transfer_repton3_00
 LDA repton3_loaded_at,Y
.transfer_repton3_01
 STA repton3_relocated_to,Y
 DEY
 BNE transfer_repton3_00
 INC transfer_repton3_00 + &02
 INC transfer_repton3_01 + &02
 DEX
 BNE transfer_repton3_00
 LDA #ascii_04                          ;load repton4
 JSR load_named_repton
 LDA #ascii_02                          ;load repton2
 JSR load_named_repton
 JSR initialise_page_zero               ;initial game variables
 JSR repton_misc                        ;odds and sods
 LDX #&FF                               ;flatten stack for game
 TXS
 JMP mastr                              ;execute main code

.load_named_repton
 STA repton_name + &06
 LDX #refresh_block_end - refresh_block - &01
.refresh_file
 LDA refresh_block,X
 STA load_repton_file,X
 DEX
 BPL refresh_file
 TXA                                    ;x=&ff
 LDX #LO(load_repton_file)
 LDY #HI(load_repton_file)
 JMP osfile

.load_repton_file
 EQUW repton_name
 EQUD &00
 EQUD &FF
 EQUD &00
 EQUD &00
.repton_name
 EQUS "repton0", &0D

.refresh_block
 EQUW repton_name
 EQUD &00
 EQUD &FF
 EQUD &00
 EQUD &00
.refresh_block_end

.set_up_envelopes                       ;sound envelopes
 LDY envelope_index
 LDX envelope_data_address_start,Y      ;set up x/y address of envelope data
 INY
 LDA envelope_data_address_start,Y
 INY
 STY envelope_index
 TAY
 LDA #&08                               ;define an envelope
 JSR osword
 DEC envelope_counter
 BNE set_up_envelopes
 RTS

.envelope_counter
 EQUB (envelope_data_address_end - envelope_data_address_start) DIV 2
.envelope_index
 EQUB &00
.envelope_data_address_start
 EQUW env_01
 EQUW env_02
 EQUW env_03
 EQUW env_04
.envelope_data_address_end

.env_01
 envelope 1, 1, 0, 0, 0, 0, 0, 0, 126, -1, 0, -1, 126, 0
.env_02
 envelope 2, 3, 0, 0, 0, 1, 1, 1, 90, -20, -20, -2, 90, 0
.env_03
 envelope 3, 2, 1, 1, 0, 5, 10, 40, 30, -10, -10, -15, 127, 0
.env_04
 envelope 4, 131, 0, 0, 0, 25, 2, -2, 110, 0, -4, -8, 110, 80

.initialise_page_zero                   ;zeroise some page zero, prvioulsy done in basic
 LDX #&14
 LDA #&00
.initial_repton
 STA tempa,X
 DEX
 BPL initial_repton
 RTS

.setup_screen
 LDA #&90                               ;turn interlace on
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #&00                               ;clear screen ram before mode change
 TAX
.clear_screen_page
 STA mode_5_start,X
 DEX
 BNE clear_screen_page
 INC clear_screen_page + &02
 BPL clear_screen_page
 LDX #&00
.vdu_bytes
 LDA vdu_codes,X
 JSR oswrch
 INX
 CPX #vdu_codes_end - vdu_codes
 BNE vdu_bytes
 RTS

.vdu_codes
 EQUB 22                                ;set mode 5
 EQUB 5
 EQUB 23                                ;turn cursor off
 EQUB 1
 EQUD &00
 EQUD &00
 EQUB 19                                ;change logical colours 0-3 to black
 EQUB &00
 EQUD &00
 EQUB 19
 EQUB &01
 EQUD &00
 EQUB 19
 EQUB &02
 EQUD &00
 EQUB 19
 EQUB &03
 EQUD &00
.vdu_codes_end

.repton_misc
 LDA #181                               ;rs423 off
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #&09                               ;flashing colour 0
 LDX #&00
 LDY #&00
 JSR osbyte                             ;flashing colour 1
 LDA #&0A
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #&04                               ;disable cursor editing
 LDX #&02
 LDY #&00
 JSR osbyte
 LDA #&10                               ;two adc channels only
 LDX #&02
 LDY #&00
 JMP osbyte

.find_swr_ram_slot                      ;find swr slot to use
 LDX #&0E
.swr_loop
 STX bbc_romsel
 STX bbc_master_romsel
 STX bbc_solidisk_romsel
 JSR check_for_copyright_string
 BCS next_slot                          ;c=1 in use
 LDA first_swr_ram                      ;preserve the ram contents
 INC first_swr_ram
 CMP first_swr_ram
 STA first_swr_ram                      ;retore ram contents
 BEQ next_slot
 LDY #swr_test_end - swr_self_write_test - &01
.transfer_test
 LDA swr_self_write_test,Y
 STA first_swr_ram,Y
 DEY
 BPL transfer_test
 JSR first_swr_ram                      ;z = result
 BNE found_swr_slot
.next_slot
 DEX
 BPL swr_loop
 LDA paged_rom                          ;restore basic
 STA bbc_romsel
 STA bbc_master_romsel
 STA bbc_solidisk_romsel

 BRK
 EQUB &FF
 EQUS "No available Sideways RAM bank could be found.", &00

.found_swr_slot
 STX found_a_slot
 RTS

.swr_self_write_test                    ;try to increment memory
 INC first_swr_ram + (swr_test_location - swr_self_write_test)
 LDA first_swr_ram + (swr_test_location - swr_self_write_test)
 RTS                                    ;z = 1 no change z = 0 can use

.swr_test_location
 EQUB &00
.swr_test_end

.check_for_copyright_string             ;check if being used either rom/arm
 LDY swr_address + &07                  ;copyright offset pointer
 LDA swr_address + &01,Y                ;start of "(C)"
 CMP #ascii_left_bracket                ;"("
 BEQ in_use
 LDA swr_address + &02,Y
 CMP #ascii_upper_c                     ;"C"
 BEQ in_use
 LDA swr_address + &03,Y
 CMP #ascii_right_bracket               ;")"
 BEQ in_use
 CLC                                    ;c=0, free of copyright start to string
 RTS
.in_use
 SEC                                    ;c=1, slot in use
 RTS

.found_a_slot
 EQUB &00

.select_swr_ram_slot                    ;select swr
 PHP
 SEI
 LDA found_a_slot
 STA paged_rom
 STA bbc_romsel
 STA bbc_master_romsel
 STA bbc_solidisk_romsel
 PLP                                    ;restore irq status
 RTS

.repton1_end
 SAVE "repton1", repton1, repton1_end, repton1_execute

 ORG   &1200
 CLEAR &1200, &31DF
 GUARD &31E0

.repton2
 INCBIN  "binary\chara.bin"             ;character data must be loaded at &1200
.squeze                                 ;repton map default small characters, must be on a page boundary
 INCBIN  "repton small maps\common.bin" ;default character set

.map_file_index                         ;pointer to character set
 EQUB &00
.map_file_in_use                        ;current map characters
 EQUW squeze
.squeze_pointers
 EQUW squeze                            ;default character set
 EQUW extended_squeze                   ;extended character set

 INCLUDE "ctrlm.asm"
 INCLUDE "sqeze.asm"
 INCLUDE "setup.asm"
 INCLUDE "edits.asm"
 INCLUDE "score.asm"
 INCLUDE "suqra.asm"
 INCLUDE "magni.asm"
 INCLUDE "rocks.asm"
.repton2_first_end

 ORG   &31E0                            ;load uncompressed prelude
 CLEAR &31E0, &57FF
 INCBIN "repton maps\reptonmaps\prelude.bin"

.repton2_end
 SAVE "repton2", repton2, repton2_end

 ORG   &8000
 CLEAR &8000, &BFFF
 GUARD &C000

.repton3
 INCLUDE "extra.asm"

 SAVE "repton3", repton3, repton3_end, repton3, repton3_loaded_at

 ORG   &5800
 CLEAR &5800, &5FFF
 GUARD &6000

.repton4

.sprite_128                             ;sprite storage for masking, also sprite 48, page aligned
 SKIP &80

 INCBIN  "binary\explodes.bin"          ;repton explosion graphics 49/50/51 sprite number 0 starts at &4000
 INCLUDE "tables\mask table.asm"

.sprites_address_lsb                    ;look up table for sprite address
 FOR j, 0, 63
  EQUB LO(map_sprites + j * 128)
 NEXT

.sprites_address_msb
 FOR j, 0, 63
  EQUB HI(map_sprites + j * 128)
 NEXT

 INCLUDE "repton maps\rle uncompress.asm"
 INCLUDE "music.asm"

.repton4_end
 SAVE "repton4", repton4, lomem, repton4

;                                       <--- save three original map files to disc - start
 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\common.bin"
 INCBIN "repton maps\reptonmapscompressed\prelude.bin"
 SAVE "prelude", &31E0, (&31E0 + 5285 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\common.bin"
 INCBIN "repton maps\reptonmapscompressed\toccata.bin"
 SAVE "toccata", &31E0, (&31E0 + 4962 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\common.bin"
 INCBIN "repton maps\reptonmapscompressed\finale.bin"
 SAVE "finale",  &31E0, (&31E0 + 5497 + &180), &0000
;                                       <--- save three original map files to disc - end
;                                       <--- save atwifs map files to disc - start
 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\africa.bin"
 INCBIN "repton maps\reptonmapscompressed\africa.bin"
 SAVE "africa",  &31E0, (&31E0 + 6273 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\america.bin"
 INCBIN "repton maps\reptonmapscompressed\america.bin"
 SAVE "america", &31E0, (&31E0 + 5764 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\arctic.bin"
 INCBIN "repton maps\reptonmapscompressed\arctic.bin"
 SAVE "arctic",  &31E0, (&31E0 + 5399 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\oceans.bin"
 INCBIN "repton maps\reptonmapscompressed\oceans.bin"
 SAVE "oceans",  &31E0, (&31E0 + 5913 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\orient.bin"
 INCBIN "repton maps\reptonmapscompressed\orient.bin"
 SAVE "orient",  &31E0, (&31E0 + 5856 + &180), &0000
;                                       <--- save atwifs map files to disc - end
;                                       <--- save life of repton map files to disc - start
 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\baby.bin"
 INCBIN "repton maps\reptonmapscompressed\baby.bin"
 SAVE "baby",    &31E0, (&31E0 + 5567 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\school.bin"
 INCBIN "repton maps\reptonmapscompressed\school.bin"
 SAVE "school",  &31E0, (&31E0 + 5958 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\teenage.bin"
 INCBIN "repton maps\reptonmapscompressed\teenage.bin"
 SAVE "teenage", &31E0, (&31E0 + 6272 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\work.bin"
 INCBIN "repton maps\reptonmapscompressed\work.bin"
 SAVE "work",    &31E0, (&31E0 + 5985 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\oap.bin"
 INCBIN "repton maps\reptonmapscompressed\oap.bin"
 SAVE "oap",     &31E0, (&31E0 + 6146 + &180), &0000
;                                       <--- save life of repton map files to disc - end
;                                       <--- save repton thru time map files to disc - start
 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\prehist.bin"
 INCBIN "repton maps\reptonmapscompressed\prehist.bin"
 SAVE "prehist", &31E0, (&31E0 + 6810 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\egypt.bin"
 INCBIN "repton maps\reptonmapscompressed\egypt.bin"
 SAVE "egypt",   &31E0, (&31E0 + 6398 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\victori.bin"
 INCBIN "repton maps\reptonmapscompressed\victori.bin"
 SAVE "victori", &31E0, (&31E0 + 6114 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\now.bin"
 INCBIN "repton maps\reptonmapscompressed\now.bin"
 SAVE "now",     &31E0, (&31E0 + 6178 + &180), &0000

 ORG   &31E0
 CLEAR &31E0, &5800
 INCBIN "repton small maps\future.bin"
 INCBIN "repton maps\reptonmapscompressed\future.bin"
 SAVE "future",  &31E0, (&31E0 + 6073 + &180), &0000
;                                       <--- save repton thru time map files to disc - end

 PUTTEXT "documents/credits.txt"   , "credits" , &0000, &0000
 PUTTEXT "documents/readme.txt"    , "readme"  , &0000, &0000
 PUTTEXT "documents/version.txt"   , "version" , &0000, &0000
 PUTTEXT "documents/licence.txt"   , "licence" , &0000, &0000
 PUTTEXT "documents/passwords.txt" , "passwrd" , &0000, &0000

 total_free_space = (repton1_limit - repton1_end) + (repton2_limit - repton2_first_end) + (repton3_limit - repton3_end) + (repton4_limit - repton4_end)

 PRINT "           >      <      |      ><"
 PRINT " repton1  ", ~repton1, " ",  ~repton1_end,  " " , ~repton1_limit, " " , ~repton1_limit - repton1_end
 PRINT " repton2  ", ~repton2, "" ,  ~repton2_end,  ""  , ~repton2_limit, ""  , ~repton2_limit - repton2_first_end
 PRINT " repton3  ", ~repton3, "" ,  ~repton3_end,  ""  , ~repton3_limit, ""  , ~repton3_limit - repton3_end
 PRINT " repton4  ", ~repton4, "" ,  ~repton4_end,  ""  , ~repton4_limit, ""  , ~repton4_limit - repton4_end

 PRINT "                               ",  ~total_free_space
