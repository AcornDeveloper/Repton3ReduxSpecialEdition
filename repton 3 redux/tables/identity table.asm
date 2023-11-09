; identity table

.identity_table                         ;align table on a page boundary for speed
 FOR identity, 0, 255
  EQUB identity
 NEXT

; new assembly instructions can be synthesized
; all instructions use three bytes and four cycles with the identity table on a page boundary

MACRO _TYX     : LDX identity_table,Y   : ENDMACRO ;use only if a needs preserving as tya tax is one byte shorter
MACRO _TXY     : LDY identity_table,X   : ENDMACRO ;use only if a needs preserving as txa tay is one byte shorter
MACRO _AND_X   : AND identity_table,X   : ENDMACRO
MACRO _AND_Y   : AND identity_table,Y   : ENDMACRO
MACRO _ORA_X   : ORA identity_table,X   : ENDMACRO
MACRO _ORA_Y   : ORA identity_table,Y   : ENDMACRO
MACRO _EOR_X   : EOR identity_table,X   : ENDMACRO
MACRO _EOR_Y   : EOR identity_table,Y   : ENDMACRO
MACRO _ADC_X   : ADC identity_table,X   : ENDMACRO
MACRO _ADC_Y   : ADC identity_table,Y   : ENDMACRO
MACRO _SBC_X   : SBC identity_table,X   : ENDMACRO
MACRO _SBC_Y   : SBC identity_table,Y   : ENDMACRO
MACRO _CMP_X   : CMP identity_table,X   : ENDMACRO
MACRO _CMP_Y   : CMP identity_table,Y   : ENDMACRO
MACRO _BIT_I k : BIT identity_table + k : ENDMACRO
