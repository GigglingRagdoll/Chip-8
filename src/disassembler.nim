import os
from strutils import toHex

proc disassemble(path: string): seq[int] =
  ## Disassembles Chip-8 binaries
  ## Possibly other types of binaries that follows similar formatting
  var
    byte = 0 # value of each byte stored here
    i = 0 # will be used to keep track of high and low bytes
    tmp: int # stores high and low bytes
    f: File
    opcodes: seq[int] = @[] # each opcode stored here

  try: # return empty seq if file cannot be opened
    f = open(path)
  except:
    return opcodes

  while true: # read characters until eof
    try:
      byte = int(readChar(f))

    except:
      return opcodes

    if i mod 2 == 0:
      tmp = 0 # reset the bytes
      tmp = tmp or (byte shl 8) # place value in high byte

    else:
      tmp = tmp or byte # place value in low byte
      opcodes.add(tmp) # append result to opcodes

    i = (i + 1) mod 2 # add 1 to Z2

proc decode(opcode: int): string =
  ## Takes a Chip-8 opcode and returns the disassembled instruction
  
  # may be less efficient but it makes writing the rest of this much easier
  let address = "0x" & toHex(opcode and 0x0fff, 3) # 12 bit address
  let x = toHex((opcode and 0x0f00) shr 8, 1) # destination general register index
  let y = toHex((opcode and 0x00f0) shr 4, 1) # source general register index
  let byte = "0x" & toHex(opcode and 0x00ff, 2) # lower byte of opcode
  let nibble = "0x" & toHex(opcode and 0x000f, 1) # lower 4 bits of low byte

  result = case opcode:
    of 0x0000..0x0fff:
      case opcode and 0x00ff:
        of 0xe0:
          "CLS"
        of 0xee:
          "RET"
        else:
          "SYS " & address
    of 0x1000..0x1fff:
      "JP " & address
    of 0x2000..0x2fff:
      "CALL " & address
    of 0x3000..0x3fff:
      "SE V" & x & ", " & byte
    of 0x4000..0x4fff:
      "SNE V" & x & ", " & byte
    of 0x5000..0x5fff:
      case opcode and 0x000f:
        of 0:
          "SE V" & x & ", V" & y
        else:
          "INVALID"
    of 0x6000..0x6fff:
      "LD V" & x & ", " & byte
    of 0x7000..0x7fff:
      "ADD V" & x & ", " & byte
    of 0x8000..0x8fff:
      case opcode and 0x000f:
        of 0x0:
          "LD V" & x & ", V" & y
        of 0x1:
          "OR V" & x & ", V" & y
        of 0x2:
          "AND V" & x & ", V" & y
        of 0x3:
          "XOR V" & x & ", V" & y
        of 0x4:
          "ADD V" & x & ", V" & y
        of 0x5:
          "SUB V" & x & ", V" & y
        of 0x6:
          "SHR V" & x & "{, V}" & y
        of 0x7:
          "SUBN V" & x & ", V" & y
        of 0xe:
          "SHL V" & x & "{, V}" & y
        else:
          "INVALID"
    of 0x9000..0x9fff:
      case opcode and 0x000f:
        of 0x0:
          "SNE V" & x & ", V" & y
        else:
          "INVALID"
    of 0xa000..0xafff:
      "LD I, " & address
    of 0xb000..0xbfff:
      "JP V0, " & address
    of 0xc000..0xcfff:
      "RND V" & x & ", " & byte
    of 0xd000..0xdfff:
      "DRW V" & x & ", V" & y & ", " & nibble
    of 0xe000..0xefff:
      case opcode and 0x00ff:
        of 0x9e:
          "SKP V" & x
        of 0xa1:
          "SKNP V" & x
        else:
          "INVALID"
    of 0xf000..0xffff:
      case opcode and 0x00ff:
        of 0x07:
          "LD V" & x & ", DT"
        of 0x0a:
          "LD V" & x & ", K"
        of 0x15:
          "LD DT, V" & x
        of 0x18:
          "LD ST, V" & x
        of 0x1e:
          "ADD I, V" & x
        of 0x29:
          "LD F, V" & x
        of 0x33:
          "LD B, V" & x
        of 0x55:
          "LD [I], V" & x
        of 0x65:
          "LD V" & x & ", [I]"
        else:
          "INVALID"
    else:
      "INVALID"

when isMainModule:
  if paramCount() < 1:
    quit "Please provide a file to disassemble."

  var 
    filepath = paramStr(1)
    address: string

  for i, opcode in disassemble(filepath):
    address = toHex(i + 0x200, 3) # Chip-8 programs usually start at 0x200
    echo address & "\t" & toHex(opcode, 4), "\t", decode(opcode)

