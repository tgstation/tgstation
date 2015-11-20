/datum/processSchedulerView
	var/datum/html_interface/interface

/datum/processSchedulerView/New()

	var/const/head = "<link href='./common.css' rel='stylesheet' type='text/css'>"

	src.interface = new/datum/html_interface(src, "Process Scheduler Detail", 800, 600, head)

	html_machines += src


/datum/processSchedulerView/Topic(href, href_list)
	if(!check_rights(R_DEBUG)) return

	if (!href_list["action"])
		return

	switch (href_list["action"])
		if ("kill")
			var/toKill = href_list["name"]
			processScheduler.killProcess(toKill)
			src.refreshTable()
		if ("enable")
			var/toEnable = href_list["name"]
			processScheduler.enableProcess(toEnable)
			src.refreshTable()
		if ("disable")
			var/toDisable = href_list["name"]
			processScheduler.disableProcess(toDisable)
			src.refreshTable()
		if ("refresh")
			src.refreshTable()
			//src.interface.updateContent()

/datum/processSchedulerView/proc/getProcessTable()
	var/text = "<table><thead><tr><td>Name</td><td colspan=2>Avg(s)</td><td colspan=2>Last(s)</td><td colspan=2>Highest(s)</td><td colspan=2>Tickcount</td><td colspan=2>Tickrate</td><td>State</td><td>Action</td></tr></thead><tbody>"
	// and the context of each
	for (var/list/data in processScheduler.getStatusData())
		text += "<tr>"
		text += "<td>[data["name"]]</td>"
		text += "<td colspan=2>[num2text(data["averageRunTime"]/10,3)]</td>"
		text += "<td colspan=2>[num2text(data["lastRunTime"]/10,3)]</td>"
		text += "<td colspan=2>[num2text(data["highestRunTime"]/10,3)]</td>"
		text += "<td colspan=2>[num2text(data["ticks"],4)]</td>"
		text += "<td colspan=2>[data["schedule"]]</td>"
		text += "<td>[data["status"]]</td>"
		text += "<td><a href=\"?src=\ref[src];action=kill;name=[data["name"]]\">Kill</a>"
		if (data["disabled"])
			text += "<a href=\"?src=\ref[src];action=enable;name=[data["name"]]\">Enable</a>"
		else
			text += "<a href=\"?src=\ref[src];action=disable;name=[data["name"]]\">Disable</a>"
		text += "</td>"
		text += "</tr>"

	text += "</tbody></table>"

	return text



/datum/processSchedulerView/proc/refreshTable()
	var/text = src.getProcessTable()
	src.interface.updateContent("processTable", text)



/**
 * getContext
 * Outputs an interface showing stats for all processes.
 */


/datum/processSchedulerView/proc/getContext()

	var/text = {"
	<h2>Process Scheduler</h2>
	<a href='?src=\ref[src];action=refresh'>Refresh</a>
	<h3>The process scheduler controls [processScheduler.getProcessCount()] loops.<h3>"}

	text += "<div class='statusDisplay'>"

	text += "<div id=\"processTable\">"
	text += src.getProcessTable()
	text += "</div></div></body></html>"

	src.interface.updateLayout("<div id=\"content\"></div>")
	src.interface.updateContent("content", text)


/client/proc/getSchedulerContext()

	set name = "Process Scheduler Debug"
	set category = "Debug"

	var/datum/processSchedulerView/processView = new /datum/processSchedulerView
	processView.getContext()
	processView.interface.show(usr)

