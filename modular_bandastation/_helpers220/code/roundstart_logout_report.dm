/datum/roundstart_logout_report_entry
	var/name
	var/ckey
	var/job
	var/status
	var/is_antag

/datum/roundstart_logout_report_entry/New(name, ckey, job, status, is_antag = FALSE)
	src.name = name
	src.ckey = ckey
	src.job = job
	src.status = status
	src.is_antag = is_antag

/datum/roundstart_logout_report_builder
	var/list/datum/roundstart_logout_report_entry/entries = list()

/datum/roundstart_logout_report_builder/Destroy()
	QDEL_LIST(entries)
	return ..()

/datum/roundstart_logout_report_builder/proc/add_entry(name, ckey, job, status, is_antag)
	var/datum/roundstart_logout_report_entry/entry = new(name, ckey, job, status, is_antag)
	entries += entry
	return entry

/datum/roundstart_logout_report_builder/proc/to_nested_list()
	var/list/output = list()
	for(var/datum/roundstart_logout_report_entry/entry in entries)
		output += list(list(
			"name" = entry.name,
			"ckey" = entry.ckey,
			"job" = entry.job,
			"status" = entry.status,
			"is_antag" = entry.is_antag,
		))
	return output

/datum/roundstart_logout_report_builder/proc/to_formatted_text()
	var/list/msg = list("[span_boldnotice("Roundstart logout report")]\n\n")
	for(var/datum/roundstart_logout_report_entry/entry in entries)
		var/status_text = entry.status
		switch(entry.status)
			if("disconnected")
				status_text = "<font color='#ffcc00'><b>Disconnected</b></font>"
			if("afk")
				status_text = "<font color='#ffcc00'><b>Connected, Inactive</b></font>"
			if("suicide")
				status_text = span_bolddanger("Suicide")
			if("dying")
				status_text = "Dying"
			if("dead")
				status_text = "Dead"
			if("ghosted")
				status_text = span_bolddanger("Ghosted")

		msg += "<b>[entry.name]</b> ([entry.ckey]), the [entry.job] ([status_text])\n"

	msg += "[span_boldnotice("Roundstart logout reported at: [DisplayTimeText(GLOB.logout_timer_set)]")]\n"
	return msg.Join()
