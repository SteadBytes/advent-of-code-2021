import strutils, sugar, sequtils, math, bitops

# TODO: Is it faster to parse each line into a uint and then use bitwise
# operations rather than char comparisons (both in `rates` and `rating`)?

proc rates(lines: seq[string], width: int): (uint, uint) =
  ## Calculate gamm and eplison rates
  var counts = newSeq[int](width)
  for l in lines:
    # sanity check
    assert l.len == width
    for i, c in l.pairs:
      counts[i] += (
        case c:
        of '0': 0
        of '1': 1
        else: raise newException(ValueError,
            "Invalid binary string in input: " & l)
      )
  let gamma = counts.map(x => uint(x * 2 >= lines.len)).foldl((a * 2) + b)
  # Bitwise complement of gamma, ensuring correct bit width is maintained
  let epsilon = uint((2 ^ width)-1) xor gamma
  (gamma, epsilon)

proc part1(input: string): uint =
  let lines = input.strip().splitLines()
  let width = lines[0].len
  let (gamma, epsilon) = rates(lines, width)
  gamma * epsilon

type Rating = enum
  rOxygen
  rC02

proc rating(binStrings: seq[string], rType: Rating): uint =
  let width = binStrings[0].len
  var candidates = binStrings
  var i = 0
  while candidates.len > 1:
    # Note: gamma/epsilon just represent the most/least common bit in each
    # position and hence can be re-used from part 1
    let (gamma, epsilon) = rates(candidates, width)
    let bits =
      case rType:
        of rOxygen: gamma
        of rC02: epsilon
    candidates = candidates.filterIt(
      if testBit(bits, width-i-1):
        it[i] == '1'
      else:
        it[i] == '0'
    )
    inc i
  uint(parseBinInt(candidates[0]))

proc part2(input: string): uint =
  let lines = input.strip().splitLines()
  rating(lines, rOxygen) * rating(lines, rC02)

proc main() =
  const input = staticRead("../inputs/d03.txt")
  echo "part 1: ", part1(input)
  echo "part 2: ", part2(input)

when isMainModule:
  main()

