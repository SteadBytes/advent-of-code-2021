import os, strformat, parseopt, sugar, strutils, httpclient, net

const usage = """
USAGE:
    newday [FLAGS] <DAY>...

FLAGS:
    -h, --help    prints this message

ARGS:
    DAY    day number
"""

proc main() =
  var days: seq[int]
  for kind, key, value in getOpt():
    case kind
    of cmdEnd: doAssert(false) # not possible with getOpt
    of cmdArgument:
      try:
        days.add(parseInt(key))
      except ValueError:
        quit(&"Invalid day number '{key}'", 1)
    of cmdShortOption, cmdLongOption:
      # [FLAGS]
      case key:
        of "h", "help":
          echo usage
          return
        else:
          quit(&"Unknown option '{key}'\nTry 'newday --help' for more information.", 1)

  if days.len == 0:
    quit(usage, 1)

  for day in days:
    let inputPath = &"inputs/d{day:02}.txt"
    let modulePath = &"src/d{day:02}.nim"

    if fileExists modulePath:
      echo &"Skipping existing module: {modulePath}"
    else:
      modulePath.writeFile(&"import strutils\n\nconst input = staticRead(\"../{inputPath}\")\n\n#echo \"part 1: \"\n#echo \"part 2: \"")

    if fileExists(inputPath):
      echo &"Skipping existing input: {inputPath}"
    else:
      let url = &"https://adventofcode.com/2021/day/{day}/input"
      echo &"Downloading input: {url} -> {inputPath}"
      let client = newHttpClient()
      # TODO: Cookie/file as CLI parameter/env var?
      client.headers["cookie"] = readFile "cookie"
      let input = client.getContent(url)
      inputPath.writeFile(input)



if isMainModule:
  main()
