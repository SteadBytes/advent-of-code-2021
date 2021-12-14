import strutils, sequtils, tables, strscans

type
  Pair = (char, char)
  Rules = Table[Pair, char]

func parseRule(s: string): (Pair, char) =
  let (ok, a, b, insert) = s.scanTuple("$c$c -> $c")
  assert ok
  ((a, b), insert)

func parseInput(s: string): (string, Table[Pair, char]) =
  let sections = s.strip().split("\n\n")
  assert sections.len == 2
  (sections[0], sections[1].splitLines().map(parseRule).toTable)

func step(pairCounts: CountTable[Pair], rules: Rules): CountTable[Pair] =
  for pair, n in pairCounts:
    if pair in rules:
      # AB -> C
      # Increment AC
      # Increment CB
      let insert = rules[pair]
      result.inc((pair[0], insert), n)
      result.inc((insert, pair[1]), n)

func insertionProcess(
  pairCounts: CountTable[Pair],
  rules: Rules,
  rounds: int
): int =
  var pairCounts = pairCounts
  for _ in 0..<rounds:
    pairCounts = step(pairCounts, rules)
  # Construct individual character counts from pair counts
  var counts: CountTable[char]
  for pair, n in pairCounts:
    counts.inc(pair[1], n)
  counts.largest[1] - counts.smallest[1]

proc main() =
  const input = staticRead("../inputs/d14.txt")
  let (tmpl, rules) = parseInput(input)
  # As the final polymer string is not required, only the counts of each pair
  # of elements need to be maintained
  let pairCounts = zip(tmpl[0..^1], tmpl[1..^1]).toCountTable()
  echo "part 1: ", insertionProcess(pairCounts, rules, 10)
  echo "part 2: ", insertionProcess(pairCounts, rules, 40)


when isMainModule:
  main()

