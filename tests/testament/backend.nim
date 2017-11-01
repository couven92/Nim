#
#
#              The Nim Tester
#        (c) Copyright 2017 Andreas Rumpf
#
#    Look at license.txt for more info.
#    All rights reserved.

import strutils, os, osproc, json, times

type
  MachineId* = distinct string
  CommitId = distinct string

proc `$`*(id: MachineId): string {.borrow.}
proc `$`(id: CommitId): string {.borrow.}

var
  thisMachine: MachineId
  thisCommit: CommitId
  thisBranch: string
  thisTestRunId*: string

{.experimental.}
proc `()`(cmd: string{lit}): string = cmd.execProcess.string.strip

proc getMachine*(): MachineId =
  var name = "hostname"()
  if name.len == 0:
    name = when defined(posix): getenv"HOSTNAME".string
           else: getenv"COMPUTERNAME".string
  if name.len == 0:
    quit "cannot determine the machine name"

  result = MachineId(name)

proc getCommit(): CommitId =
  const commLen = "commit ".len
  let hash = "git log -n 1"()[commLen..commLen+10]
  thisBranch = "git symbolic-ref --short HEAD"()
  if hash.len == 0 or thisBranch.len == 0: quit "cannot determine git HEAD"
  result = CommitId(hash)

var
  results: File
  currentCategory: string
  entries: int

proc writeTestResult*(name, category, target,
                      action, result, expected, given: string,
                      timestamp: Time) =
  createDir("testresults")
  if currentCategory != category:
    if currentCategory.len > 0:
      results.writeLine("]")
      close(results)
    currentCategory = category
    let filename = "testresults" / category.addFileExt"json"
    if fileExists(filename):
      results = open(filename, fmReadWriteExisting)
      const bracketCloseLen = "]\n".len()
      if results.getFileSize() > bracketCloseLen:
        results.setFilePos(-bracketCloseLen, fspEnd) # Overwrite the ] at the end of the file
        results.writeLine(",")
      else:
        results.writeLine("[")
    else:
      results = open(filename, fmWrite)
      results.writeLine("[")
    entries = 0

  let jentry = %*{"name": name, "category": category, "target": target,
    "action": action, "result": result, "expected": expected, "given": given,
    "machine": thisMachine.string, "commit": thisCommit.string, "branch": thisBranch,
    "os": hostOS, "cpu": hostCPU, "timestamp": $timestamp,
    "testrun": thisTestRunId}
  if entries > 0:
    results.writeLine(",")
  results.write($jentry)
  inc entries

proc open*() =
  thisMachine = getMachine()
  thisCommit = getCommit()

proc close*() =
  if currentCategory.len > 0:
    results.writeLine("]")
    close(results)
