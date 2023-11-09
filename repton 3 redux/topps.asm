; topps

.xadin                                  ;table overlap
 EQUB &01
 EQUB &FF

.yadin
 EQUB &00
 EQUB &00
 EQUB &FF
 EQUB &01

.fungus_spread
 DEC slows                              ;delay at the start of each map to fungus spread
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
 CMP #code_fungus                       ;fungus already there?
 BEQ spore                              ;yes
 CMP #code_earth1                       ;earth type 1?
 BEQ can_spread_here                    ;yes
 CMP #code_earth2                       ;earth type 2?
 BEQ can_spread_here                    ;yes
 CMP #code_space
 BEQ can_spread_here
 CMP #code_repton                       ;is it repton?
 BEQ kill_repton                        ;yes, kill him
.spore
 DEC pages + &02
 BPL mushy
.fungy
 RTS

.can_spread_here                        ;found a space to spread into
 STA paras
 LDA #26
 LDX pages + &00
 LDY pages + &01
 JSR write_map_byte                     ;write fungus to the map
 LDA pages + &00
 STA tempa
 LDA pages + &01
 STA tempy
 LDA #&00
 STA tempx
 STA tempz
 JSR calculate_sprite_plot_mask         ;calculate if sprite on
 BCS fungy
 LDA #code_fungus
 STA paras
 JMP place_a_sprite

.kill_repton
 INC death
 RTS

.repton_x_coordinate                    ;      2
 LDA reptx                              ;      |
 ASL A                                  ; 1 ---+--- 0
 SEC                                    ;      |
 ROL A                                  ;      3
 STA paras + &01
 LDA movie
 CMP #&04
 BCS fungy
 LDX sting
 CPX #&02
 BCS fungy
 TXA
 BEQ topps_posit
 LDA paras + &01
 SEC
 SBC movie
 STA paras + &01
 RTS

.topps_posit
 LDA paras + &01
 ADC movie                              ;c=0
 STA paras + &01
 RTS

.repton_y_coordinate                    ;      2
 LDA repty                              ;      |
 ASL A                                  ; 1 ---+--- 0
 SEC                                    ;      |
 ROL A                                  ;      3
 STA paras + &02
 LDA movie
 CMP #&04
 BCS fungy
 LDX sting
 CPX #&02
 BCC fungy
 BNE upper
 LDA paras + &02
 SEC
 SBC movie
 STA paras + &02
 RTS

.upper
 LDA paras + &02
 CLC
 ADC movie
 STA paras + &02
 RTS

.monster_x_coordinate
 LDA tempa
 ASL A
 SEC
 ROL A
 STA tempa
 LDX tempz
 CPX #&02
 BCS fungy
 TXA
 BNE zeros
 LDA tempa
 ADC tempx                              ;c=0
 STA tempa
 RTS

.zeros
 LDA tempa
 SEC
 SBC tempx
 STA tempa
 RTS

.monster_y_coordinate
 LDA tempy
 ASL A
 SEC
 ROL A
 STA tempy
 LDY tempz
 CPY #&02
 BCC fungy
 BEQ douze
 LDA tempy
 CLC
 ADC tempx
 STA tempy
 RTS

.douze
 LDA tempy
 SBC tempx                              ;c=1
 STA tempy
 RTS

.calculate_sprite_plot_mask
 JSR repton_x_coordinate
 JSR repton_y_coordinate
 JSR monster_x_coordinate
 JSR monster_y_coordinate
 LDA paras + &01
 SEC
 SBC #&11
 STA paras + &01
 LDA tempa
 SEC
 SBC paras + &01
 CMP #35
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
 CMP #35
 BCS opens
 STA paras + &02
 STA indir + &01
 TAY
 LDA topps_masks,Y
 STA paras + &04
 CLC
.opens
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
 LDA #&01
 STA paras
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
 JSR place_a_sprite
 JMP transform_safe_to_diamond          ;keep looking
