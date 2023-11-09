# program to convert a screen dump in mode 5 into beebspriter format

from pathlib import *
from array import *

# use path library to create source and destination paths
path = Path("C:\Users\Matthew Atkinson\Archive\acorn bbc micro\source code\bbc repton 3 redux\repton 3 redux extras/")
source = path / "repton"
destination = path / "repton.bspr"

# set up byte array and read in dump file to the array
screen_data = bytearray(10240)
screen_index = 0
with open(source, "rb") as repton_dump:
  while (byte := repton_dump.read(1)):
    screen_data[screen_index] = ord(byte)
    screen_index +=1

# set up signed char character array, this array will grow as added to, initialise it
converted = array("b")
converted = ""

# two lists, character codes for encoding pixels and mask table for screen byte
character = ["A","A","A", "Q","E","B", "g","I","C", "w","M", "D"]
mask      = [0x88,0x44,0x22,0x11]

# now extract the byte corresponding to pixel x,y in the screen dump
bytes_read = 0

for pixel_y in range(0,256):
  for pixel_x in range(0,160):

# every three pixels start off with an "A"
    if (bytes_read % 3) == 0:
      converted += "A"

    pixel_byte = screen_data[((pixel_y >> 3) * 320 + ((pixel_x & 0xfffffc) << 1) + (pixel_y & 0x07))]

# mask the byte according to the x coordinate
    pixel_byte = pixel_byte & mask[pixel_x % 4]

# get remainder and invert to give right shift, note can give a right shift of 0
    pixel_byte = pixel_byte >> (((pixel_x % 4) ^ 0x03))

# from the shifted pixel byte calculate the colour 0-3
    match pixel_byte:
      case 0x00:
        colour = 1
      case 0x01:
        colour = 3
      case 0x10:
        colour = 2
      case 0x11:
        colour = 0

# index comprised of colour * 3 plus the modulus of the x coordinate to give the character
    converted += character[colour * 3 + (bytes_read % 3)]
    bytes_read += 1

# add trailing equals to complete last quartet
converted += "=="

# write out character array
with open(destination, "w") as repton_spriter:
  repton_spriter.write('<?xml version="1.0" encoding="utf-8"?>\n')
  repton_spriter.write('<SpriteSheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Mode="5">\n')
  repton_spriter.write('  <BackgroundColour>Transparent</BackgroundColour>\n')
  repton_spriter.write('  <DefaultPalette>\n')
  repton_spriter.write('    <Colour>Black</Colour>\n')
  repton_spriter.write('    <Colour>Red</Colour>\n')
  repton_spriter.write('    <Colour>Yellow</Colour>\n')
  repton_spriter.write('    <Colour>White</Colour>\n')
  repton_spriter.write('  </DefaultPalette>\n')
  repton_spriter.write('  <DefaultShowGridLines>true</DefaultShowGridLines>\n')
  repton_spriter.write('  <HorizontalBlockDividers>0</HorizontalBlockDividers>\n')
  repton_spriter.write('  <VerticalBlockDividers>0</VerticalBlockDividers>\n')
  repton_spriter.write('  <DefaultZoom>6</DefaultZoom>\n')
  repton_spriter.write('  <HasSetExportSettings>false</HasSetExportSettings>\n')
  repton_spriter.write('  <SpriteLayout>RowMajor</SpriteLayout>\n')
  repton_spriter.write('  <ShouldBreakSprites>false</ShouldBreakSprites>\n')
  repton_spriter.write('  <SubSpriteWidth>2</SubSpriteWidth>\n')
  repton_spriter.write('  <SubSpriteHeight>2</SubSpriteHeight>\n')
  repton_spriter.write('  <ShouldExportSeparateMask>false</ShouldExportSeparateMask>\n')
  repton_spriter.write('  <ShouldGenerateHeader>true</ShouldGenerateHeader>\n')
  repton_spriter.write('  <AssemblerSyntax>{n} = &amp;{v}</AssemblerSyntax>\n')
  repton_spriter.write('  <SpriteList>\n')
# insert sprite width and height in pixels
  repton_spriter.write('    <Sprite Name="test_sprite" Width="160" Height="256">\n')
  repton_spriter.write('      <Bitmap>')
  repton_spriter.write(converted)
  repton_spriter.write('</Bitmap>\n')
  repton_spriter.write('      <Palette>\n')
  repton_spriter.write('        <Colour>Black</Colour>\n')
  repton_spriter.write('        <Colour>Red</Colour>\n')
  repton_spriter.write('        <Colour>Yellow</Colour>\n')
  repton_spriter.write('        <Colour>White</Colour>\n')
  repton_spriter.write('      </Palette>\n')
  repton_spriter.write('    </Sprite>\n')
  repton_spriter.write('  </SpriteList>\n')
  repton_spriter.write('</SpriteSheet>\n')

# close both batch files
repton_dump.close()
repton_spriter.close()

print("Finished Conversion")
