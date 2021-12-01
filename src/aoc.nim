import strutils, sequtils, sugar

proc readIntLines*(path: string): seq[int] = 
  for l in path.lines:
    result.add(parseInt(l))
