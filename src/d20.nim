import aoc
import strutils, sequtils, sugar, sets

func parseInput(s: string): (seq[bool], HashSet[Coord]) =
  ## Note: Assumes well-formed input
  let sections = s.strip().split("\n\n")
  assert sections.len == 2
  # First line -> image enhancement algorithm (exactly 512 chars)
  let algo = sections[0].strip().mapIt(it == '#')
  assert algo.len == 512
  # 2D grid -> input image
  let lines = sections[1].strip().splitLines()
  let inputPixels = collect:
    for y, l in lines:
      for x, c in l:
        if c == '#': {(x, y)}
  (algo, inputPixels)

const window = [
  (-1, -1), (0, -1), (1, -1),
  (-1, 0), (0, 0), (1, 0),
  (-1, 1), (0, 1), (1, 1),
]

func enhance(
  litPixels: HashSet[Coord],
  algo: seq[bool],
  default: bool
): HashSet[Coord] =
  # Bounds of the currently "explored" portion of the grid
  let
    xs = litPixels.mapIt(it.x)
    ys = litPixels.mapIt(it.y)
    xMin = xs.min
    xMax = xs.max
    yMin = ys.min
    yMax = ys.max
  for y in yMin-1..<yMax+2:
    for x in xMin-1..<xMax+2:
      let c = (x, y)
      let x =
        window.map(v => c + v).map(
          c2 => int(
            if xMin <= c2.x and c2.x <= xMax and yMin <= c2.y and c2.y <= yMax:
              # Within explored region -> use known value
              litPixels.contains(c2)
            else:
              # Outside explored region -> use default value for the rest of
              # the grid
              default
          )
        )
        .foldl((a * 2) + b)
      if algo[x]:
        result.incl(c)

func part1(algo: seq[bool], inPixels: HashSet[Coord]): int =
  ## If the pixel at index 0 of the enhancement algorithm is lit, *every* pixel
  ## in the infinite grid will be lit by the first round of enhancement:
  ## - All of these pixels begin unlit
  ## - The 3x3 window binary number for each such pixel will be 0
  ## - All pixels replaced with enhancement[0] on the first application
  ##
  ## To accomodate for this, `enhance` takes a `default` parameter to indicate
  ## the value to be used for pixels outside of the "explored" portion of the
  ## infinite grid.
  ##
  ## Note: This behaviour is _not_ demonstrated in the puzzle example input.
  let outPixels = (0..<2).foldl(enhance(a, algo, b > 0 and algo[0]), inPixels)
  outPixels.len

proc main() =
  const input = staticRead("../inputs/d20.txt")
  let (algo, inPixels) = parseInput(input)
  echo "part 1: ", part1(algo, inPixels)
  #echo "part 2: "

when isMainModule:
  when defined(testing):
    import unittest

    const exampleInput = staticRead("../inputs/d20.example.txt")
    let (algo, inPixels) = parseInput(exampleInput)
    test "part 1":
      assert part1(algo, inPixels) == 35

    # test "part 2":
    #   assert false

  else:
    main()

