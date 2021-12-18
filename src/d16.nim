import strformat, sequtils, sugar, bitops, strutils

type
  PacketKind = enum
    Literal,
    Operator

  Op = enum
    Sum,
    Product,
    Min,
    Max,
    Gt,
    Lt,
    Eq

  Packet = object
    version: int
    case typeId: PacketKind
    of Literal: value: int
    of Operator:
      op: Op
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
      of Operator:
        result = p1.op == p2.op
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

func toOp(typeId: int): Op =
  case typeId:
    of 0: Sum
    of 1: Product
    of 2: Min
    of 3: Max
    of 5: Gt
    of 6: Lt
    of 7: Eq
    else: raise newException(ValueError, &"invalid typeID: {typeId}")


proc parse(s: var Stream): Packet =
  let version = s.scanInt(3)
  let typeId = s.scanInt(3)
  result = Packet(
    version: version,
    typeId: if typeId == 4: Literal else: Operator
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
    # TODO: Handle invalid typeID values?
    result.op = typeId.toOp()
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

func part2(transmission: string): int =

  func eval(p: Packet): int =
    case p.typeId:
      of Literal: return p.value
      of Operator:
        case p.op:
          of Sum: return p.children.map(eval).foldl(a + b)
          of Product: return p.children.map(eval).foldl(a * b)
          of Min: return p.children.map(eval).min()
          of Max: return p.children.map(eval).max()
          of Gt:
            assert p.children.len == 2
            return int(eval(p.children[0]) > eval(p.children[1]))
          of Lt:
            assert p.children.len == 2
            return int(eval(p.children[0]) < eval(p.children[1]))
          of Eq:
            assert p.children.len == 2
            return int(eval(p.children[0]) == eval(p.children[1]))

  var s = Stream(data: hexToBin(transmission.strip()))
  let packet = parse(s)
  eval(packet)

proc main() =
  const input = staticRead("../inputs/d16.txt")

  echo "part 1: ", part1(input)
  echo "part 2: ", part2(input)

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

      test "parse Lt operator length type ID 0":
        var s = Stream(data: hexToBin("38006F45291200"))
        check s.parse() == Packet(
          version: 1,
          typeId: Operator,
          op: Lt,
          children: @[
            Packet(version: 6, typeId: Literal, value: 10),
            Packet(version: 6, typeId: Literal, value: 20),
          ],
        )

      test "parse Max operator length type ID 1":
        var s = Stream(data: hexToBin("EE00D40C823060"))
        check s.parse() == Packet(
          version: 7,
          typeId: Operator,
          op: Max,
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

    suite "part 2":

      test "examples":
        check part2("C200B40A82") == 3
        check part2("04005AC33890") == 54
        check part2("880086C3E88112") == 7
        check part2("CE00C43D881120") == 9
        check part2("D8005AC2A8F0") == 1
        check part2("F600BC2D8F") == 0
        check part2("9C005AC2F8F0") == 0
        check part2("9C0141080250320F1802104A08") == 1

  else:
    main()

