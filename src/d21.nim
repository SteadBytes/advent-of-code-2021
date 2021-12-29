import strutils, sequtils, sugar

func parseInput(s: string): (int, int) =
  let positions = s.strip().splitLines().map(l => l.split(": ")[1].parseInt)
  assert positions.len == 2
  assert positions.all(x => x in (1..10))
  (positions[0], positions[1])

func deterministicDie(): iterator(): int =
  return iterator(): int =
    var x = 1
    while true:
      yield x
      inc x
      if x == 101:
        x = 1

proc part1(positions: (int, int)): int =
  var
    (p1Pos, p2Pos) = positions
    p1Score, p2Score = 0
    rolls = 0
  let
    d = deterministicDie()
    roll3 = proc(): int =
      result = d() + d() + d()
      inc rolls, 3
  while true:
    p1Pos = (p1Pos + roll3() - 1) mod 10 + 1
    inc p1Score, p1Pos
    if p1Score >= 1000:
      return p2Score * rolls
    p2Pos = (p2Pos + roll3() - 1) mod 10 + 1
    inc p2Score, p2Pos
    if p2Score >= 1000:
      return p1Score * rolls

proc main() =
  const input = staticRead("../inputs/d21.txt")
  const startingPositions = parseInput(input)
  echo "part 1: ", part1(startingPositions)
  #echo "part 2: "

when isMainModule:
  when defined(testing):
    import unittest

    const exampleInput = staticRead("../inputs/d21.example.txt")
    const startingPositions = parseInput(exampleInput)

    test "part 1":
      check part1(startingPositions) == 739785

    test "part 2":
      assert false

  else:
    main()

