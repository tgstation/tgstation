/datum/processSchedulerView

/datum/processSchedulerView/Topic(href, href_list)
	if (!href_list["action"])
		return

	switch (href_list["action"])
		if ("kill")
			var/toKill = href_list["name"]
			processScheduler.killProcess(toKill)
			refreshProcessTable()
		if ("enable")
			var/toEnable = href_list["name"]
			processScheduler.enableProcess(toEnable)
			refreshProcessTable()
		if ("disable")
			var/toDisable = href_list["name"]
			processScheduler.disableProcess(toDisable)
			refreshProcessTable()
		if ("refresh")
			refreshProcessTable()

/datum/processSchedulerView/proc/refreshProcessTable()
	windowCall("handleRefresh", getProcessTable())

/datum/processSchedulerView/proc/windowCall(var/function, var/data = null)
	usr << output(data, "processSchedulerContext.browser:[function]")

/datum/processSchedulerView/proc/getProcessTable()
	var/text = "<table class=\"table table-striped\"><thead><tr><td>Name</td><td>Avg(s)</td><td>Last(s)</td><td>Highest(s)</td><td>Tickcount</td><td>Tickrate</td><td>State</td><td>Action</td></tr></thead><tbody>"
	// and the context of each
	for (var/list/data in processScheduler.getStatusData())
		text += "<tr>"
		text += "<td>[data["name"]]</td>"
		text += "<td>[num2text(data["averageRunTime"]/10,3)]</td>"
		text += "<td>[num2text(data["lastRunTime"]/10,3)]</td>"
		text += "<td>[num2text(data["highestRunTime"]/10,3)]</td>"
		text += "<td>[num2text(data["ticks"],4)]</td>"
		text += "<td>[data["schedule"]]</td>"
		text += "<td>[data["status"]]</td>"
		text += "<td><button class=\"btn kill-btn\" data-process-name=\"[data["name"]]\" id=\"kill-[data["name"]]\">Kill</button>"
		if (data["disabled"])
			text += "<button class=\"btn enable-btn\" data-process-name=\"[data["name"]]\" id=\"enable-[data["name"]]\">Enable</button>"
		else
			text += "<button class=\"btn disable-btn\" data-process-name=\"[data["name"]]\" id=\"disable-[data["name"]]\">Disable</button>"
		text += "</td>"
		text += "</tr>"

	text += "</tbody></table>"
	return text

/**
 * getContext
 * Outputs an interface showing stats for all processes.
 */
/datum/processSchedulerView/proc/getContext()
	bootstrap_browse()
	usr << browse('processScheduler.js', "file=processScheduler.js;display=0")

	var/text = {"<html><head>
	<title>Process Scheduler Detail</title>
	<script type="text/javascript">var ref = '\ref[src]';</script>
	[bootstrap_includes()]
	<script type="text/javascript" src="processScheduler.js"></script>
	</head>
	<body>
	<h2>Process Scheduler</h2>
	<div class="btn-group">
	<button id="btn-refresh" class="btn">Refresh</button>
	</div>

	<h3>The process scheduler controls [processScheduler.getProcessCount()] loops.<h3>"}

	text += "<div id=\"processTable\">"
	text += getProcessTable()
	text += "</div></body></html>"

	usr << browse(text, "window=processSchedulerContext;size=800x600")

/datum/processSchedulerView/proc/bootstrap_browse()
	usr << browse('bower_components/jquery/dist/jquery.min.js', "file=jquery.min.js;display=0")
	usr << browse('bower_components/bootstrap2.3.2/bootstrap/js/bootstrap.min.js', "file=bootstrap.min.js;display=0")
	usr << browse('bower_components/bootstrap2.3.2/bootstrap/css/bootstrap.min.css', "file=bootstrap.min.css;display=0")
	usr << browse('bower_components/bootstrap2.3.2/bootstrap/img/glyphicons-halflings-white.png', "file=glyphicons-halflings-white.png;display=0")
	usr << browse('bower_components/bootstrap2.3.2/bootstrap/img/glyphicons-halflings.png', "file=glyphicons-halflings.png;display=0")
	usr << browse('bower_components/json2/json2.js', "file=json2.js;display=0")

/datum/processSchedulerView/proc/bootstrap_includes()
	return {"
	<link rel="stylesheet" href="bootstrap.min.css" />
	<script type="text/javascript" src="json2.js"></script>
	<script type="text/javascript" src="jquery.min.js"></script>
	<script type="text/javascript" src="bootstrap.js"></script>
	"}
