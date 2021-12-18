import strformat, sequtils, sugar, bitops, strutils

type
  PacketKind = enum
    Literal,
    Operator

  Packet = object
    version: int
    case typeId: PacketKind
    of Literal: value: int
    of Operator: discard
    children: seq[Packet]

  Stream = object
    data: seq[uint8]
    pos: int

proc `==`(p1, p2: Packet): bool =
  result = p1.typeId == p2.typeId
  if result:
    case p1.typeId:
      of Literal:
        result = p1.value == p2.value
      of Operator: discard # No specific fields to compare
  if result:
    result = p1.children == p2.children

# Adapted from https://github.com/nim-lang/Nim/blob/8ccde68f132be4dba330eb6ec50f4679e564efac/lib/std/private/decode_helpers.nim#L24
proc hexCharToInt(c: char): int {.inline.} =
  case c
  of '0'..'9': result = (ord(c) - ord('0'))
  of 'a'..'f': result = (ord(c) - ord('a') + 10)
  of 'A'..'F': result = (ord(c) - ord('A') + 10)
  else: raise newException(ValueError, &"invalid hex character: {c}")

func hexToBin(s: string): seq[uint8] =
  collect:
    for x in s.map(c => uint8(hexCharToInt(c))):
      for i in countdown(3, 0):
        x shr i and 0b1

proc scanInt(s: var Stream, n: int): int =
  ## Read `n` bits from a stream into an integer, advancing the stream position by `n`.
  result = s.data[s.pos..<s.pos+n].foldl(a shl 1 or int(b), 0)
  inc(s.pos, n)

proc parse(s: var Stream): Packet =
  result = Packet(
    version: s.scanInt(3),
    typeId: if s.scanInt(3) == 4: Literal else: Operator
  )

  if result.typeId == Literal:
    while true:
      let x = try:
        s.scanInt(5)
      except IndexDefect:
        raise newException(ValueError, "unexpect end of input stream")
      let number = x and 0b01111
      result.value = (result.value shl 4) or number
      if not x.testBit(4):
        return
  else:
    let lengthTypeId = s.scanInt(1)
    assert lengthTypeId == 0 or lengthTypeId == 1
    if lengthTypeId == 0:
      let nBits = s.scanInt(15)
      let endPos = s.pos + nBits
      while s.pos < endPos:
        result.children.add(s.parse())
    else:
      let nPackets = s.scanInt(11)
      for _ in 0..<nPackets:
        result.children.add(s.parse())

func part1(transmission: string): int =

  func versionSum(p: Packet): int =
    result = p.version
    for p2 in p.children:
      inc(result, versionSum(p2))

  var s = Stream(data: hexToBin(transmission.strip()))
  let packet = parse(s)
  versionSum(packet)

proc main() =
  const input = staticRead("../inputs/d16.txt")

  echo "part 1: ", part1(input)
  #echo "part 2: "

when isMainModule:
  when defined(testing):
    import unittest

    suite "BITS decoding":

      test "hexCharToInt":
        check hexCharToInt('0') == 0
        check hexCharToInt('F') == 15
        expect ValueError:
          discard hexCharToInt('G')

      test "hexToBin":
        check:
          hexToBin("D2FE28") == [
            1u8, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0,
            0, 0
          ]
          hexToBin("38006F45291200") == [
            0u8, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1,
            1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0,
            0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
          ]
          hexToBin("EE00D40C823060") == [
            1u8, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1,
            0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0,
            0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
          ]

      test "parse literal":
        var s = Stream(data: hexToBin("D2FE28"))
        check s.parse() == Packet(version: 6, typeId: Literal, value: 2021)

      test "parse operator length type ID 0":
        var s = Stream(data: hexToBin("38006F45291200"))
        check s.parse() == Packet(
          version: 1,
          typeId: Operator,
          children: @[
            Packet(version: 6, typeId: Literal, value: 10),
            Packet(version: 6, typeId: Literal, value: 20),
          ],
        )

      test "parse operator length type ID 1":
        var s = Stream(data: hexToBin("EE00D40C823060"))
        check s.parse() == Packet(
          version: 7,
          typeId: Operator,
          children: @[
            Packet(version: 6, typeId: Literal, value: 1),
            Packet(version: 6, typeId: Literal, value: 2),
            Packet(version: 6, typeId: Literal, value: 3),
          ],
        )

      test "parse invalid end of stream":
        var s = Stream(data: hexToBin("D2FEF8"))
        expect ValueError:
          discard s.parse()

    suite "part 1":

      test "examples":
        check part1("8A004A801A8002F478") == 16
        check part1("620080001611562C8802118E34") == 12
        check part1("C0015000016115A2E0802F182340") == 23
        check part1("A0016C880162017C3686B18A3D4780") == 31

  else:
    main()

