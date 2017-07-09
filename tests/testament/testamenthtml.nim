import strutils

proc htmlQuote*(raw: string): string =
  if (raw.isNil):
    return nil
  result = raw
  result = result.replace("&", "&amp;")
  result = result.replace("\"", "&quot;")
  result = result.replace("'", "&apos;")
  result = result.replace("<", "&lt;")
  result = result.replace(">", "&gt;")

const
  html_begin_1* = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Testament Test Results</title>""" 
  html_begin_2* = """
</head>
<body>
    <div class="container">
        <h1>Testament Test Results <small>Nim Tester</small></h1>"""
  html_tablist_begin* = """
        <ul class="nav nav-tabs" role="tablist">"""
  html_tablistitem_format* = """
            <li role="presentation" class="$firstTabActiveClass">
                <a href="#tab-commit-$commitId-machine-$machineId" aria-controls="tab-commit-$commitId-machine-$machineId" role="tab" data-toggle="tab">
                    $branch#$hash@$machineName
                </a>
            </li>"""
  html_tablist_end* = """
        </ul>"""
  html_tabcontents_begin* = """
        <div class="tab-content">"""
  html_tabpage_begin_format* = """
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
  html_testresult_panel_format* = """
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
  html_testresult_output_format* = """
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
  html_testresult_no_output* = """
                            <p class="sr-only">No output details</p>"""
  html_tabpage_end* = """
                </div>
            </div>"""
  html_tabcontents_end* = """
        </div>"""
  html_end* = """
    </div>
</body>
</html>"""