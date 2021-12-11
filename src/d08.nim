import strutils, sequtils, sugar, bitops, aoc

proc parseEntry(s: string): (seq[uint32], seq[uint32]) =
  let parts =
    s.split(" | ", maxsplit = 1)
    .map(
      s => s.split()
      .map(
        signal => signal.foldl(a or 1'u32 shl (ord(b) - ord('a')), 0b00000000'u32)
      )
    )
  assert parts.len == 2
  (parts[0], parts[1])

proc main() =
  const input = staticRead("../inputs/d08.txt")
  let entries = input.strip().splitLines().map(parseEntry)

  let uniqueOutputs = entries.map(
    e => e[1].filter(x => x.countSetBits in {2, 4, 3, 7}).len
  ).foldl(a + b)
  echo "part 1: ", uniqueOutputs

  var outputVals = newSeq[int](entries.len)
  for (patterns, outDigits) in entries:
    var pats: array[10, uint32]
    var fiveSegs, sixSegs: seq[(uint32, uint32)]
    for x in patterns:
      case x.countSetBits():
        of 2:
          pats[1] = x
        of 3:
          pats[7] = x
        of 4:
          pats[4] = x
        of 7:
          pats[8] = x
        of 5:
          fiveSegs.add((x, x))
        of 6:
          sixSegs.add((x, x))
        else:
          unreachable()

    # Sanity check all known patterns (unique number of digits) were found
    assert pats[1] != 0
    assert pats[7] != 0
    assert pats[4] != 0
    assert pats[8] != 0

    # 7 and 1 differ only in the top segment
    let segTop = pats[7] xor pats[1]
    # 2, 3, 4, 5 all share the middle segment
    let segMid = fiveSegs.foldl(a and b[1], pats[4])

    # Differentiate 0, 9, 6 - 0 has no middle segment and 9, 6 have 2, 1
    # segments in common with 1 respectively
    for x, m in sixSegs.items():
      if (m and segMid).countSetBits() == 0:
        assert pats[0] == 0
        pats[0] = x
      else:
        case (m and pats[1]).countSetBits():
          of 2:
            assert pats[9] == 0
            pats[9] = x
          of 1:
            assert pats[6] == 0
            pats[6] = x
          else:
            unreachable()
    assert pats[0] != 0
    assert pats[6] != 0
    assert pats[9] != 0

    # Remove top, middle and 1 from 2, 3, 5
    # Leaves 2, 5 with 2 unknown segments each and 3 with 1 unkown segment
    for x, m in fiveSegs.mitems():
      m.mask(bitand(not segTop, not segMid, not pats[1]))
      let setbits = m.countSetBits
      if setBits == 1:
        assert pats[3] == 0
        pats[3] = x
    assert pats[3] != 0

    # 5, 2 can now be differentiated using 4, having 1, 0 segments in common
    # respectively
    for x, m in fiveSegs.mitems():
      # 3 already determined
      if x == pats[3]:
        continue
      m.mask(pats[4])
      case m.countSetBits():
        of 1:
          assert pats[5] == 0
          pats[5] = x
        of 0:
          assert pats[2] == 0
          pats[2] = x
        else:
          unreachable()
    assert pats[5] != 0
    assert pats[2] != 0

    var outVal = 0
    for x in outDigits:
      for i, p in pats:
        if x == p:
          outVal = outVal * 10 + i
    outputVals.add(outVal)

  echo "part 2: ", outputVals.foldl(a + b)

when isMainModule:
  main()

