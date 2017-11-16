#
#
#            Nim Tester
#        (c) Copyright 2017 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## HTML generator for the tester.

import cgi, backend, strutils, json, os, tables, times

import "testamenthtml.templ"

proc generateTestResultPanelPartial(outfile: File, testResultRow: JsonNode,
  onlyFailing = false) =
  let
    trId = htmlQuote(
      testResultRow["category"].str &
      "_" &
      testResultRow["name"].str
      ).multiReplace({".": "_", " ": "_", ":": "_"})
    name = testResultRow["name"].str.htmlQuote()
    category = testResultRow["category"].str.htmlQuote()
    target = testResultRow["target"].str.htmlQuote()
    action = testResultRow["action"].str.htmlQuote()
    result = htmlQuote testResultRow["result"].str
    expected = testResultRow["expected"].str
    gotten = testResultRow["given"].str
    timestamp = htmlQuote testResultRow["timestamp"].str
  var
    panelCtxClass, textCtxClass, bgCtxClass: string
    resultSign, resultDescription: string
  case result
  of "reSuccess":
    if onlyFailing:
      return
    panelCtxClass = "success"
    textCtxClass = "success"
    bgCtxClass = "success"
    resultSign = "ok"
    resultDescription = "PASS"
  of "reIgnored":
    if onlyFailing:
      return
    panelCtxClass = "info"
    textCtxClass = "info"
    bgCtxClass = "info"
    resultSign = "question"
    resultDescription = "SKIP"
  else:
    panelCtxClass = "danger"
    textCtxClass = "danger"
    bgCtxClass = "danger"
    resultSign = "exclamation"
    resultDescription = "FAIL"

  outfile.generateHtmlTestresultPanelBegin(
    trId, name, target, category, action, resultDescription,
    timestamp, result, resultSign, panelCtxClass, textCtxClass, bgCtxClass
  )
  if expected.isNilOrWhitespace() and gotten.isNilOrWhitespace():
    outfile.generateHtmlTestresultOutputNone()
  else:
    outfile.generateHtmlTestresultOutputDetails(
      expected.strip().htmlQuote,
      gotten.strip().htmlQuote
    )
  outfile.generateHtmlTestresultPanelEnd()

type
  AllTests = object
    data: JSonNode
    totalCount, successCount, ignoredCount, failedCount: int
    successPercentage, ignoredPercentage, failedPercentage: BiggestFloat

proc allTestResults(): AllTests =
  result.data = newJArray()
  for file in os.walkFiles("testresults"/"*.json"):
    var data: JsonNode
    try: data = parseFile(file)
    except JsonParsingError:
      echo "[ERROR] JSON parsing error: ", getCurrentExceptionMsg()
      continue
    if data.kind != JArray:
      echo "[ERROR] ignoring json file that is not an array: ", file
    else:
      for elem in data:
        result.data.add elem
        let state = elem["result"].str
        if state.contains("reSuccess"): inc result.successCount
        elif state.contains("reIgnored"): inc result.ignoredCount
  result.totalCount = result.data.len
  result.successPercentage = 100 *
    (result.successCount.toBiggestFloat / result.totalCount.toBiggestFloat)
  result.ignoredPercentage = 100 *
    (result.ignoredCount.toBiggestFloat / result.totalCount.toBiggestFloat)
  result.failedCount = result.totalCount -
    result.successCount - result.ignoredCount
  result.failedPercentage = 100 *
    (result.failedCount.toBiggestFloat / result.totalCount.toBiggestFloat)

proc generateTestResultsPanelGroupPartial(outfile: File, allResults: JsonNode,
  onlyFailing = false) =
  for testresultRow in allResults:
    generateTestResultPanelPartial(outfile, testresultRow, onlyFailing)

proc generateAllTestsContent(outfile: File, allResults: AllTests,
  onlyFailing = false) =
  if allResults.data.len < 1: return # Nothing to do if there is no data.
  # Only results from one test run means that test run environment info is the
  # same for all tests
  let
    firstRow = allResults.data[0]
    commit = htmlQuote firstRow["commit"].str
    branch = htmlQuote firstRow["branch"].str
    machine = htmlQuote firstRow["machine"].str
    os = htmlQuote firstRow["os"].str
    cpu = htmlQuote firstRow["cpu"].str

  outfile.generateHtmlAllTestsBegin(
    machine, commit, branch, os, cpu,
    allResults.totalCount,
    allResults.successCount,
    formatBiggestFloat(allResults.successPercentage, ffDecimal, 2) & "%",
    allResults.ignoredCount,
    formatBiggestFloat(allResults.ignoredPercentage, ffDecimal, 2) & "%",
    allResults.failedCount,
    formatBiggestFloat(allResults.failedPercentage, ffDecimal, 2) & "%",
    onlyFailing
  )
  generateTestResultsPanelGroupPartial(outfile, allResults.data, onlyFailing)
  outfile.generateHtmlAllTestsEnd()

proc generateHtml*(filename: string, onlyFailing: bool) =
  let
    currentTime = getTime().getLocalTime()
    timestring = htmlQuote format(currentTime, "yyyy-MM-dd HH:mm:ss 'UTC'zzz")
  var outfile = open(filename, fmWrite)

  outfile.generateHtmlBegin()

  generateAllTestsContent(outfile, allTestResults(), onlyFailing)

  outfile.generateHtmlEnd(timestring)

  outfile.flushFile()
  close(outfile)
