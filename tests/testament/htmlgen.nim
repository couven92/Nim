#
#
#            Nim Tester
#        (c) Copyright 2015 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## HTML generator for the tester.

import db_sqlite, cgi, backend, strutils, json, jquery, bootstrap

proc htmlQuote(raw: string): string =
  if (raw.isNil):
    return nil
  result = raw
  result = result.replace("&", "&amp;")
  result = result.replace("\"", "&quot;")
  result = result.replace("'", "&apos;")
  result = result.replace("<", "&lt;")
  result = result.replace(">", "&gt;")

const
  html_begin_1 = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Testament Test Results</title>""" 
  html_begin_2 = """
</head>
<body>
    <div class="container">
        <h1>Testament Test Results <small>Nim Tester</small></h1>"""
  html_tablist_begin = """
        <ul class="nav nav-tabs" role="tablist">"""
  html_tablistitem_format = """
            <li role="presentation" class="$firstTabActiveClass">
                <a href="#tab-commit-$commitId-machine-$machineId" aria-controls="tab-commit-$commitId-machine-$machineId" role="tab" data-toggle="tab">
                    $branch#$hash@$machineName
                </a>
            </li>"""
  html_tablist_end = """
        </ul>"""
  html_tabcontents_begin = """
        <div class="tab-content">"""
  html_tabpage_begin_format = """
            <div id="tab-commit-$commitId-machine-$machineId" class="tab-pane fade$firstTabActiveClass" role="tabpanel">
                <h2>$branch#$hash@$machineName</h2>
                <dl class="dl-horizontal">
                    <dt>Branch</dt>
                    <dd>$branch</dd>
                    <dt>Commit Hash</dt>
                    <dd><code>$hash</code></dd>
                    <dt>Machine Name</dt>
                    <dd>$machineName</dd>
                    <dt>OS</dt>
                    <dd>$os</dd>
                    <dt title="CPU Architecture">CPU</dt>
                    <dd>$cpu</dd>
                    <dt>All Tests</dt>
                    <dd>
                        <span class="glyphicon glyphicon-th-list"></span>
                        $totalCount
                    </dd>
                    <dt>Successful Tests</dt>
                    <dd>
                        <span class="glyphicon glyphicon-ok-sign"></span>
                        $successCount ($successPercentage)
                    </dd>
                    <dt>Skipped Tests</dt>
                    <dd>
                        <span class="glyphicon glyphicon-question-sign"></span>
                        $ignoredCount ($ignoredPercentage)
                    </dd>
                    <dt>Failed Tests</dt>
                    <dd>
                        <span class="glyphicon glyphicon-exclamation-sign"></span>
                        $failedCount ($failedPercentage)
                    </dd>
                </dl>
                <div class="panel-group">"""
  html_testresult_panel_format = """
                    <div id="panel-testResult-$trId" class="panel panel-$panelCtxClass">
                        <div class="panel-heading" style="cursor:pointer" data-toggle="collapse" data-target="#panel-body-testResult-$trId" aria-controls="panel-body-testResult-$trId" aria-expanded="false">
                            <div class="row">
                                <h4 class="col-xs-3 col-sm-1 panel-title">
                                    <span class="glyphicon glyphicon-$resultSign-sign"></span>
                                    <strong>$resultDescription</strong>
                                </h4>
                                <h4 class="col-xs-1 panel-title"><span class="badge">$target</span></h4>
                                <h4 class="col-xs-5 col-sm-7 panel-title" title="$name"><code class="text-$textCtxClass">$name</code></h4>
                                <h4 class="col-xs-3 col-sm-3 panel-title text-right"><span class="badge">$category</span></h4>
                            </div>
                        </div>
                        <div id="panel-body-testResult-$trId" class="panel-body collapse bg-$bgCtxClass">
                            <dl class="dl-horizontal">
                                <dt>Name</dt>
                                <dd><code class="text-$textCtxClass">$name</code></dd>
                                <dt>Category</dt>
                                <dd><span class="badge">$category</span></dd>
                                <dt>Timestamp</dt>
                                <dd>$timestamp</dd>
                                <dt>Nim Action</dt>
                                <dd><code class="text-$textCtxClass">$action</code></dd>
                                <dt>Nim Backend Target</dt>
                                <dd><span class="badge">$target</span></dd>
                                <dt>Code</dt>
                                <dd><code class="text-$textCtxClass">$result</code></dd>
                            </dl>
                            $outputDetails
                        </div>
                    </div>"""
  html_testresult_output_format = """
                            <div class="table-responsive">
                                <table class="table table-condensed">
                                    <thead>
                                        <tr>
                                            <th>Expected</th>
                                            <th>Actual</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><pre>$expected</pre></td>
                                            <td><pre>$gotten</pre></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>"""
  html_testresult_no_output = """
                            <p class="sr-only">No output details</p>"""
  html_tabpage_end = """
                </div>
            </div>"""
  html_tabcontents_end = """
        </div>"""
  html_end = """
    </div>
</body>
</html>"""

proc generateHtmlBegin(outfile: File) =
  outfile.writeLine(html_begin_1)
  for part in jquery_script_tag:
    outfile.write(part)
  for part in bootstrap_script_tag:
    outfile.write(part)
  for part in glyphicons_halflings_regular_style_tag:
    outfile.write(part)
  for part in bootstrap_style_tag:
    outfile.write(part)
  for part in bootstrap_theme_style_tag:
    outfile.write(part)
  outfile.writeLine(html_begin_2)

proc generateTestRunTabListItemPartial(outfile: File, testRunRow: Row, firstRow = false) =
  let
    firstTabActiveClass = if firstRow: "active"
                          else: ""
    commitId = testRunRow[0]
    hash = htmlQuote(testRunRow[1])
    branch = htmlQuote(testRunRow[2])
    machineId = testRunRow[3]
    machineName = htmlQuote(testRunRow[4])

  outfile.writeLine(html_tablistitem_format % [
      "firstTabActiveClass", firstTabActiveClass,
      "commitId", commitId,
      "machineId", machineId,
      "branch", branch,
      "hash", hash,
      "machineName", machineName
    ])

proc generateTestResultPanelPartial(outfile: File, testResultRow: Row, onlyFailing = false) =
  let
    trId = testResultRow[0]
    name = testResultRow[1].htmlQuote()
    category = testResultRow[2].htmlQuote()
    target = testResultRow[3].htmlQuote()
    action = testResultRow[4].htmlQuote()
    result = testResultRow[5]
    expected = testResultRow[6]
    gotten = testResultRow[7]
    timestamp = testResultRow[8]
  var panelCtxClass, textCtxClass, bgCtxClass, resultSign, resultDescription: string
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

  let outputDetails = if expected.isNilOrWhitespace() and gotten.isNilOrWhitespace():
                        html_testresult_no_output
                      else:
                        html_testresult_output_format % [
                          "expected", expected.strip().htmlQuote,
                          "gotten", gotten.strip().htmlQuote
                        ]
  outfile.writeLine(html_testresult_panel_format % [
      "trId", trId,
      "name", name,
      "category", category,
      "target", target,
      "action", action,
      "result", result.htmlQuote(),
      "timestamp", timestamp,
      "outputDetails", outputDetails,
      "panelCtxClass", panelCtxClass,
      "textCtxClass", textCtxClass,
      "bgCtxClass", bgCtxClass,
      "resultSign", resultSign,
      "resultDescription", resultDescription
  ])

proc generateTestResultsPanelGroupParial(outfile: File, db: DbConn, commitid, machineid: string, onlyFailing = false) =
  const testResultsSelect = sql"""
SELECT [tr].[id]
  , [tr].[name]
  , [tr].[category]
  , [tr].[target]
  , [tr].[action]
  , [tr].[result]
  , [tr].[expected]
  , [tr].[given]
  , [tr].[created]
FROM [TestResult] AS [tr]
WHERE [tr].[commit] = ?
  AND [tr].[machine] = ?"""
  for testresultRow in db.rows(testResultsSelect, commitid, machineid):
    generateTestResultPanelPartial(outfile, testresultRow, onlyFailing)

proc generateTestRunTabContentPartial(outfile: File, db: DbConn, testRunRow: Row, onlyFailing = false, firstRow = false) =
  let
    firstTabActiveClass = if firstRow: " in active"
                          else: ""
    commitId = testRunRow[0]
    hash = htmlQuote(testRunRow[1])
    branch = htmlQuote(testRunRow[2])
    machineId = testRunRow[3]
    machineName = htmlQuote(testRunRow[4])
    os = htmlQuote(testRunRow[5])
    cpu = htmlQuote(testRunRow[6])

  const
    totalClause = """
SELECT COUNT(*)
FROM [TestResult] AS [tr]
WHERE [tr].[commit] = ?
  AND [tr].[machine] = ?"""
    successClause = totalClause & "\L" & """
  AND [tr].[result] LIKE 'reSuccess'"""
    ignoredClause = totalClause & "\L" & """
  AND [tr].[result] LIKE 'reIgnored'"""
  let
    totalCount = db.getValue(sql(totalClause), commitId, machineId).parseBiggestInt()
    successCount = db.getValue(sql(successClause), commitId, machineId).parseBiggestInt()
    successPercentage = 100 * (successCount.toBiggestFloat() / totalCount.toBiggestFloat())
    ignoredCount = db.getValue(sql(ignoredClause), commitId, machineId).parseBiggestInt()
    ignoredPercentage = 100 * (ignoredCount.toBiggestFloat() / totalCount.toBiggestFloat())
    failedCount = totalCount - successCount - ignoredCount
    failedPercentage = 100 * (failedCount.toBiggestFloat() / totalCount.toBiggestFloat())

  outfile.writeLine(html_tabpage_begin_format % [
      "firstTabActiveClass", firstTabActiveClass,
      "commitId", commitId,
      "machineId", machineId,
      "branch", branch,
      "hash", hash,
      "machineName", machineName,
      "os", os,
      "cpu", cpu,
      "totalCount", $totalCount,
      "successCount", $successCount,
      "successPercentage", formatBiggestFloat(successPercentage, ffDecimal, 2) & "%",
      "ignoredCount", $ignoredCount,
      "ignoredPercentage", formatBiggestFloat(ignoredPercentage, ffDecimal, 2) & "%",
      "failedCount", $failedCount,
      "failedPercentage", formatBiggestFloat(failedPercentage, ffDecimal, 2) & "%",
    ])

  generateTestResultsPanelGroupParial(outfile, db, commitId, machineId, onlyFailing)
  
  outfile.writeLine(html_tabpage_end)

proc generateTestRunsHtmlPartial(outfile: File, db: DbConn, onlyFailing = false) =
  const testrunSelect = sql"""
SELECT [c].[id] AS [CommitId]
  , [c].[hash] as [Hash]
  , [c].[branch] As [Branch]
  , [m].[id] AS [MachineId]
  , [m].[name] AS [MachineName]
  , [m].[os] AS [OS]
  , [m].[cpu] AS [CPU]
FROM [Commit] AS [c], [Machine] AS [m]
WHERE (
    SELECT COUNT(*)
    FROM [TestResult] AS [tr]
    WHERE [tr].[commit] = [c].[id]
      AND [tr].[machine] = [m].[id]
  ) > 0
ORDER BY [c].[id] DESC
"""
  # Iterating the results twice, get entire result set in one go
  var testRunRowSeq = db.getAllRows(testrunSelect)

  outfile.writeLine(html_tablist_begin)
  var firstRow = true
  for testRunRow in testRunRowSeq:
    generateTestRunTabListItemPartial(outfile, testRunRow, firstRow)
    if firstRow:
      firstRow = false
  outfile.writeLine(html_tablist_end)

  outfile.writeLine(html_tabcontents_begin)
  firstRow = true
  for testRunRow in testRunRowSeq:
    generateTestRunTabContentPartial(outfile, db, testRunRow, onlyFailing, firstRow)
    if firstRow:
      firstRow = false
  outfile.writeLine(html_tabcontents_end)

proc generateHtml*(filename: string, commit: int; onlyFailing: bool) =
  var db = open(connection="testament.db", user="testament", password="",
                database="testament")
  var outfile = open(filename, fmWrite)

  outfile.generateHtmlBegin()

  generateTestRunsHtmlPartial(outfile, db, onlyFailing)

  outfile.writeLine(html_end)
  
  outfile.flushFile()
  close(outfile)
  close(db)

proc getCommit(db: DbConn, c: int): string =
  var commit = c
  for thisCommit in db.rows(sql"select id from [Commit] order by id desc"):
    if commit == 0: result = thisCommit[0]
    inc commit

proc generateJson*(filename: string, commit: int) =
  const
    selRow = """select count(*),
                           sum(result = 'reSuccess'),
                           sum(result = 'reIgnored')
                from TestResult
                where [commit] = ? and machine = ?
                order by category"""
    selDiff = """select A.category || '/' || A.target || '/' || A.name,
                        A.result,
                        B.result
                from TestResult A
                inner join TestResult B
                on A.name = B.name and A.category = B.category
                where A.[commit] = ? and B.[commit] = ? and A.machine = ?
                   and A.result != B.result"""
    selResults = """select
                      category || '/' || target || '/' || name,
                      category, target, action, result, expected, given
                    from TestResult
                    where [commit] = ?"""
  var db = open(connection="testament.db", user="testament", password="",
                database="testament")
  let lastCommit = db.getCommit(commit)
  if lastCommit.isNil:
    quit "cannot determine commit " & $commit

  let previousCommit = db.getCommit(commit-1)

  var outfile = open(filename, fmWrite)

  let machine = $backend.getMachine(db)
  let data = db.getRow(sql(selRow), lastCommit, machine)

  outfile.writeLine("""{"total": $#, "passed": $#, "skipped": $#""" % data)

  let results = newJArray()
  for row in db.rows(sql(selResults), lastCommit):
    var obj = newJObject()
    obj["name"] = %row[0]
    obj["category"] = %row[1]
    obj["target"] = %row[2]
    obj["action"] = %row[3]
    obj["result"] = %row[4]
    obj["expected"] = %row[5]
    obj["given"] = %row[6]
    results.add(obj)
  outfile.writeLine(""", "results": """)
  outfile.write(results.pretty)

  if not previousCommit.isNil:
    let diff = newJArray()

    for row in db.rows(sql(selDiff), previousCommit, lastCommit, machine):
      var obj = newJObject()
      obj["name"] = %row[0]
      obj["old"] = %row[1]
      obj["new"] = %row[2]
      diff.add obj
    outfile.writeLine(""", "diff": """)
    outfile.writeLine(diff.pretty)

  outfile.writeLine "}"
  close(db)
  close(outfile)

