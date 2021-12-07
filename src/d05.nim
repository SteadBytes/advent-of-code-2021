import strutils, sequtils, sugar, parseutils, strscans, math, tables

proc main() =
  const input = staticRead("../inputs/d05.txt")

  var p1Cnt, p2Cnt: CountTable[(int, int)]
  for l in input.strip().splitLines():
    let (ok, x1, y1, x2, y2) = l.scanTuple("$i,$i -> $i,$i")
    assert ok
    let xDir = sgn(x2 - x1)
    let yDir = sgn(y2 - y1)
    # increment counter for each point along the line
    for i in 0..max(abs(x1 - x2), abs(y1 - y2)):
      let x = x1 + i * xDir
      let y = y1 + i * yDir
      # filter out diagonal lines for part 1
      if x1 == x2 or y1 == y2:
        p1Cnt.inc((x, y))
      p2Cnt.inc((x, y))

  echo "part 1: ", p1Cnt.keys.countIt(p1Cnt[it] >= 2)
  echo "part 2: ", p2Cnt.keys.countIt(p2Cnt[it] >= 2)

when isMainModule:
  main()

