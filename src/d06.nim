import strutils, sequtils

proc main() =
  const input = staticRead("../inputs/d06.txt")
  var ages = input.strip().split(",").map(parseInt)
  for _ in 0..<80:
    var new = 0
    for x in ages.mitems:
      if x == 0:
        x = 6
        inc new
      else:
        dec x
    ages &= repeat(8, new)

  echo "part 1: ", ages.len
  #echo "part 2: "

when isMainModule:
  main()

