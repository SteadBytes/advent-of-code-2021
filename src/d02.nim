import sequtils, sugar, strutils

proc part1(input: string): int =
  let (x, y) =
    input
    .strip()
    .splitLines()
    .map(s => (let parts = s.split(maxsplit = 1); (parts[0], parseInt(parts[1]))))
    .foldl(
      (let
        (x, y) = a
        (d, n) = b
      case d:
        of "forward": (x + n, y)
        of "down": (x, y + n)
        of "up": (x, y - n)
        else: raise newException(ValueError, "Invalid direction: " & d)),
      (0, 0))
  x * y

const input = staticRead("../inputs/d02.txt")
echo "part 1: ", part1(input)
# echo "part 2: "
