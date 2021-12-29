import strutils, sequtils, sugar, tables

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

proc part2(positions: (int, int)): int =
  ## Each turn creates 27 universes:
  ##
  ## │─ 1
  ## │   ├── 1
  ## │   │   ├── 1
  ## │   │   ├── 2
  ## │   │   └── 3
  ## │   ├── 2
  ## │   │   ├── 1
  ## │   │   ├── 2
  ## │   │   └── 3
  ## │   └── 3
  ## │       ├── 1
  ## │       ├── 2
  ## │       └── 3
  ## ├── 2
  ## │   ├── 1
  ## │   │   ├── 1
  ## │   │   ├── 2
  ## │   │   └── 3
  ## │   ├── 2
  ## │   │   ├── 1
  ## │   │   ├── 2
  ## │   │   └── 3
  ## │   └── 3
  ## │       ├── 1
  ## │       ├── 2
  ## │       └── 3
  ## └── 3
  ##     ├── 1
  ##     │   ├── 1
  ##     │   ├── 2
  ##     │   └── 3
  ##     ├── 2
  ##     │   ├── 1
  ##     │   ├── 2
  ##     │   └── 3
  ##     └── 3
  ##         ├── 1
  ##         ├── 2
  ##         └── 3
  ##
  ## Corresponding to the following path total (sum of the 3 die rolls) frequencies:
  ##
  ## Total │ Freq
  ## ------│------
  ##   3   │  1
  ##   4   │  3
  ##   5   │  6
  ##   6   │  7
  ##   7   │  6
  ##   8   │  3
  ##   9   │  1
  ##
  ## The full set of universes during a given turn can therefore be represented by
  ## the player states (positions and scores) and a frequency with which that
  ## state has occurred.
  type Universe = tuple[p1Pos, p2Pos, p1Score, p2Score: int]
  const rollTotalFreqs = [(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)]
  var
    p1Wins, p2Wins = 0
    universes: Table[Universe, int] = {(positions[0], positions[1], 0, 0): 1}.toTable

  func move(pos, score, rollTotal: int): (int, int) =
    let newPos = (pos + rollTotal - 1) mod 10 + 1
    (newPos, score + newPos)

  while universes.len > 0:
    var nextUniverses: Table[Universe, int]
    for u, n in universes.pairs():
      for (x, f1) in rollTotalFreqs:
        let (p1Pos, p1Score) = move(u.p1Pos, u.p1Score, x)
        let p1NewUniverses = n * f1
        if p1Score >= 21:
          # p1 wins -> don't explore further branches
          inc p1Wins, p1NewUniverses
        else:
          for (x, f2) in rollTotalFreqs:
            let (p2Pos, p2Score) = move(u.p2Pos, u.p2Score, x)
            let totalNewUniverses = p1NewUniverses * f2
            if p2Score >= 21:
              # p2 wins -> don't explore further branches
              inc p2Wins, totalNewUniverses
            else:
              # no winner yet -> explore further branches
              let u = (p1Pos, p2Pos, p1Score, p2Score)
              nextUniverses.mgetOrPut(u, 0) += totalNewUniverses
    universes = nextUniverses
  max(p1Wins, p2Wins)

proc main() =
  const input = staticRead("../inputs/d21.txt")
  const startingPositions = parseInput(input)
  echo "part 1: ", part1(startingPositions)
  echo "part 2: ", part2(startingPositions)

when isMainModule:
  when defined(testing):
    import unittest

    const exampleInput = staticRead("../inputs/d21.example.txt")
    const startingPositions = parseInput(exampleInput)

    test "part 1":
      check part1(startingPositions) == 739785

    test "part 2":
      check part2(startingPositions) == 444356092776315

  else:
    main()

