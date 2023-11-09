 MACRO create_mask_table                ;sprite mask table
 FOR j, 0, 255
  IF (j AND &11) > &00
    pixel_00 = &11
  ELSE
    pixel_00 = &00
  ENDIF
  IF (j AND &22) > &00
    pixel_01 = &22
  ELSE
    pixel_01 = &00
  ENDIF
  IF (j AND &44) > &00
    pixel_02 = &44
  ELSE
    pixel_02 = &00
  ENDIF
  IF (j AND &88) > &00
    pixel_03 = &88
  ELSE
    pixel_03 = &00
  ENDIF
  EQUB (pixel_00 + pixel_01 + pixel_02 + pixel_03) EOR &FF
 NEXT
 ENDMACRO

.mask_table
 create_mask_table