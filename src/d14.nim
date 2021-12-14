import strutils, sequtils, tables, strscans

type Pair = (char, char)

func parseRule(s: string): (Pair, char) =
  let (ok, a, b, insert) = s.scanTuple("$c$c -> $c")
  assert ok
  ((a, b), insert)

func parseInput(s: string): (string, Table[Pair, char]) =
  let sections = s.strip().split("\n\n")
  assert sections.len == 2
  (sections[0], sections[1].splitLines().map(parseRule).toTable)

func step(pairCounts: CountTable[Pair], rules: Table[Pair, char]): CountTable[Pair] =
  for pair, n in pairCounts:
    if pair in rules:
      # AB -> C
      # Increment AC
      # Increment CB
      let insert = rules[pair]
      result.inc((pair[0], insert), n)
      result.inc((insert, pair[1]), n)

proc main() =
  const input = staticRead("../inputs/d14.txt")
  let (tmpl, rules) = parseInput(input)
  # As the final polymer string is not required, only the counts of each pair
  # of elements need to be maintained
  var pairCounts = zip(tmpl[0..^1], tmpl[1..^1]).toCountTable()
  for _ in 0..<10:
    pairCounts = step(pairCounts, rules)
  # Construct individual character counts from pair counts
  var counts: CountTable[char]
  for pair, n in pairCounts:
    counts.inc(pair[1], n)
  echo "part 1: ", counts.largest[1] - counts.smallest[1]
  #echo "part 2: "

when isMainModule:
  main()

