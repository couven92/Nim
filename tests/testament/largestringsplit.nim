## Strings embedded as constants in the testament Nim Tester tool
## prove to be more than 65,536 bytes in size and must therefore
## be split.

proc largeStringSplit*(s: string): seq[string] {.compileTime.} =
  ## Splits a string value into a sequence of substrings where
  ## each sub string is no more than 32,768 bytes in size.
  ##
  ## Retuns an empty sequence if `s` is empty. The last element in
  ## the sequence might be shorter than 32,768 characters.
  result = @[]
  var startIdx = 0
  while (startIdx < s.len) and (s.len - startIdx) > int16.high:
    let newStartIdx = startIdx + int16.high
    result.add(s[startIdx .. newStartIdx])
    startIdx = newStartIdx + 1
  let last = s[startIdx .. (s.len - 1)]
  if last.len > 0:
    result.add(last)
