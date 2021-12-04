import strutils, sugar, sequtils

proc part1(input: string): uint =
  let lines = input.strip().splitLines()
  let width = lines[0].len
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
  let gamma = counts.map(x => uint(x >= lines.len div 2)).foldl((a * 2) + b)
  # Bitwise complement of gamma, ensuring correct bit width is maintained
  let epsilon = (not gamma and uint((1 shl width) - 1))
  gamma * epsilon

const input = staticRead("../inputs/d03.txt")
echo "part 1: ", part1(input)
#echo "part 2: "
