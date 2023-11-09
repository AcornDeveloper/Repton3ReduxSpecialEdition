; music

 octave_02=&00
 octave_03=&10
 octave_04=&20
 b=0
 a_dash=1
 a=2
 g_dash=3
 g=4
 f_dash=5
 f=6
 e=7
 d_dash=8
 d=9
 c_dash=10
 c=11

.wait_flag                              ;flicker reducing variables
 EQUB &00                               ;here in main ram as used on interrupt

.scan_line_area
 EQUB &00

.music_bar_01
.music_bar_05
 EQUB c OR octave_04
 EQUB &FF
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB c OR octave_04
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB e OR octave_04
 EQUB f OR octave_04
 EQUB g OR octave_04
 EQUB &FF
 EQUB g OR octave_04
 EQUB &FF
 EQUB c OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF
 EQUB g OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF
 EQUB c OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF
 EQUB g OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF

.music_bar_02
.music_bar_06
 EQUB &FF
 EQUB &FF
 EQUB f_dash OR octave_04
 EQUB g OR octave_04
 EQUB a OR octave_04
 EQUB g OR octave_04
 EQUB f_dash OR octave_04
 EQUB g OR octave_04
 EQUB a OR octave_04
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB d OR octave_02
 EQUB &FF
 EQUB d OR octave_03
 EQUB &FF
 EQUB a OR octave_02
 EQUB &FF
 EQUB d OR octave_03
 EQUB &FF
 EQUB d OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF
 EQUB b OR octave_02
 EQUB &FF
 EQUB a OR octave_02
 EQUB &FF

.music_bar_03
 EQUB &FF
 EQUB &FF
 EQUB b OR octave_04
 EQUB a OR octave_04
 EQUB g OR octave_04
 EQUB a OR octave_04
 EQUB g OR octave_04
 EQUB f OR octave_04
 EQUB e OR octave_04
 EQUB f OR octave_04
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB c OR octave_04
 EQUB d OR octave_04
 EQUB g OR octave_02
 EQUB &FF
 EQUB g OR octave_03
 EQUB &FF
 EQUB d OR octave_02
 EQUB &FF
 EQUB g OR octave_03
 EQUB &FF
 EQUB g OR octave_02
 EQUB &FF
 EQUB g OR octave_03
 EQUB &FF
 EQUB d OR octave_02
 EQUB &FF
 EQUB g OR octave_03
 EQUB &FF

.music_bar_04
 EQUB g OR octave_03
 EQUB a OR octave_03
 EQUB c OR octave_04
 EQUB d OR octave_04
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB c OR octave_04
 EQUB a OR octave_03
 EQUB c OR octave_04
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB &FF
 EQUB c OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF
 EQUB g OR octave_02
 EQUB &FF
 EQUB c OR octave_03
 EQUB &FF
 EQUB c OR octave_02
 EQUB &FF
 EQUB g OR octave_02
 EQUB &FF
 EQUB a OR octave_02
 EQUB &FF
 EQUB b OR octave_02
 EQUB &FF

.music_bar_07
 EQUB g OR octave_04
 EQUB b OR octave_04
 EQUB f OR octave_04
 EQUB a OR octave_04
 EQUB e OR octave_04
 EQUB g OR octave_04
 EQUB d OR octave_04
 EQUB f OR octave_04
 EQUB c OR octave_04
 EQUB e OR octave_04
 EQUB b OR octave_03
 EQUB d OR octave_04
 EQUB a OR octave_03
 EQUB c OR octave_04
 EQUB g OR octave_03
 EQUB b OR octave_03
 EQUB g OR octave_02
 EQUB &FF
 EQUB g OR octave_03
 EQUB &FF
 EQUB d OR octave_02
 EQUB e OR octave_02
 EQUB f OR octave_02
 EQUB g OR octave_02
 EQUB f OR octave_02
 EQUB &FF
 EQUB f OR octave_03
 EQUB &FF
 EQUB d OR octave_02
 EQUB e OR octave_02
 EQUB f OR octave_02
 EQUB d OR octave_02

.music_bar_08
 EQUB e OR octave_04
 EQUB d OR octave_04
 EQUB c OR octave_04
 EQUB d OR octave_04
 EQUB g OR octave_03
 EQUB a OR octave_03
 EQUB c OR octave_04
 EQUB d OR octave_04
 EQUB c OR octave_04
 EQUB &FF
 EQUB b OR octave_03
 EQUB c OR octave_04
 EQUB d OR octave_04
 EQUB b OR octave_03
 EQUB a OR octave_03
 EQUB g OR octave_03
 EQUB e OR octave_02
 EQUB &FF
 EQUB e OR octave_03
 EQUB &FF
 EQUB d OR octave_02
 EQUB &FF
 EQUB d OR octave_03
 EQUB &FF
 EQUB c OR octave_02
 EQUB &FF
 EQUB g OR octave_02
 EQUB a OR octave_02
 EQUB b OR octave_02
 EQUB g OR octave_02
 EQUB f OR octave_02
 EQUB e OR octave_02
