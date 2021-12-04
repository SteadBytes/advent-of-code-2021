import sequtils, sugar, strutils

proc parseInput(input: string): seq[(string, int)] =
    input
    .strip()
    .splitLines()
    .map(s => (let parts = s.split(maxsplit = 1); (parts[0], parseInt(parts[1]))))

proc part1(instructions: seq[(string, int)]): int =
    let (x, y) =
        instructions
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

proc part2(instructions: seq[(string, int)]): int =
    let (x, y, _) =
        instructions
        .foldl(
          (let
            (x, y, aim) = a
            (d, n) = b
        case d:
            of "forward": (x + n, y + aim * n, aim)
            of "down": (x, y, aim + n)
            of "up": (x, y, aim - n)
            else: raise newException(ValueError, "Invalid direction: " & d)),
          (0, 0, 0))
    x * y

const input = staticRead("../inputs/d02.txt")
let instructions = parseInput(input)
echo "part 1: ", part1(instructions)
echo "part 2: ", part2(instructions)
