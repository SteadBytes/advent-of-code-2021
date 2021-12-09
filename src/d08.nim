import strutils, sequtils, sugar

proc main() =
  const input = staticRead("../inputs/d08.txt")
  let nUnique =
    input.strip()
    .splitLines()
    .map(
      l => l.split(" | ", maxsplit = 1)[1]
      .split()
      .filter(s => s.len in {2, 4, 3, 7})
      .len
    )
    .foldl(a + b)
  echo "part 1: ", nUnique
  #echo "part 2: "

when isMainModule:
  main()

