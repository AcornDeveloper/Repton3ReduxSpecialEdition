;de-compressor for zx02 files https://github.com/dmsc/zx02
;code used https://github.com/dmsc/zx02/blob/main/6502/zx02-optim.asm
;decompress zx02 data (6502 optimized format), optimised for speed and size

 zero_page_block                        = &90
 offset                                 = zero_page_block + &00
 rle_source                             = zero_page_block + &02
 rle_destination                        = zero_page_block + &04
 bitr                                   = zero_page_block + &06
 pointer                                = zero_page_block + &07

.rle_initial
 EQUW &00
 EQUW lomem
 EQUW map_file_start
 EQUB &80

.full_decompress                        ;set up parameter block
 LDX #&07
.initialisation
 LDA rle_initial - &01,X
 STA offset - &01,X
 DEX
 BNE initialisation
 LDY #&00
.decode_literal
 JSR get_elias
.decompress_00
 LDA (rle_source),Y
 INC rle_source
 BNE increase_low_only
 INC rle_source + &01
.increase_low_only
 STA (rle_destination),Y
 INC rle_destination
 BNE no_inc_destination_high
 INC rle_destination + &01
.no_inc_destination_high
 DEX
 BNE decompress_00
 ASL bitr
 BCS dzx0s_new_offset
 JSR get_elias
.dzx0s_copy
 LDA rle_destination
 SBC offset                             ;c=0 from get_elias
 STA pointer
 LDA rle_destination + &01
 SBC offset + &01
 STA pointer + &01
.decompress_01
 LDA (pointer),Y
 INC pointer
 BNE decompress_02
 INC pointer + &01
.decompress_02
 STA (rle_destination),Y
 INC rle_destination
 BNE decompress_03
 INC rle_destination + &01
.decompress_03
 DEX
 BNE decompress_01
 ASL bitr
 BCC decode_literal
.dzx0s_new_offset
 STY offset + &01
 LDA (rle_source),Y                     ;get low part of offset, a literal 7 bits
 INC rle_source
 BNE no_inc_high_source_00
 INC rle_source + &01
.no_inc_high_source_00
 LSR A                                  ;divide by 2
 BCC offset_okay
 CMP #&7F
 BEQ rle_exit
 STA offset + &01
 LDA (rle_source),Y                     ;read new bit from stream
 INC rle_source
 BNE offset_okay
 INC rle_source + &01
.offset_okay
 STA offset
 JSR get_elias
 INX
 BCC dzx0s_copy
.get_elias                              ;read an elias-gamma interlaced code
 LDX #&01                               ;initialize return value to 1
 BNE elias_start                        ;always

.elias_get                              ;read next data bit to result
 TXA
 ASL bitr
 ROL A
 TAX
.elias_start
 ASL bitr                               ;get one bit
 BNE elias_skip1
 LDA (rle_source),Y                     ;read new bit from stream
 INC rle_source
 BNE no_inc_high_source_02
 INC rle_source + &01
.no_inc_high_source_02
 ROL A
 STA bitr
.elias_skip1
 BCS elias_get
.rle_exit                               ;got ending bit, stop reading
 RTS
