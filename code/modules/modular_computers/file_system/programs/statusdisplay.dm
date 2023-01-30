/datum/computer_file/program/status
	filename = "statusdisplay"
	filedesc = "Status Display"
	program_icon = "signal"
	program_icon_state = "generic"
	requires_ntnet = TRUE
	size = 1

	extended_desc = "An app used to change the message on the station status displays."
	tgui_id = "NtosStatus"

	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE

	var/upper_text = ""
	var/lower_text = ""

/**
 * Post status display radio packet.
 * Arguments:
 * * command - the status display command
 * * data1 - the data1 value, as defined by status displays
 * * data2 - the data2 value, as defined by status displays
 */
/datum/computer_file/program/status/proc/post_status(command, data1, data2)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	switch(command)
		if("message")
			status_signal.data["top_text"] = data1
			status_signal.data["bottom_text"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)

/**
 * Post a message to status displays
 * Arguments:
 * * upper - Top text
 * * lower - Bottom text
 */
/datum/computer_file/program/status/proc/post_message(upper, lower)
	post_status("message", upper, lower)
	log_game("[key_name(usr)] has changed the station status display message to \"[upper] [lower]\" [loc_name(usr)]")

/**
 * Post a picture to status displays
 * Arguments:
 * * picture - The picture name
 */
/datum/computer_file/program/status/proc/post_picture(picture)
	if (!(picture in GLOB.status_display_approved_pictures))
		return
	if(picture in GLOB.status_display_state_pictures)
		post_status(picture)
	else
		post_status("alert", picture)

	log_game("[key_name(usr)] has changed the station status display message to \"[picture]\" [loc_name(usr)]")

/datum/computer_file/program/status/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("setStatusMessage")
			upper_text = reject_bad_text(params["upperText"] || "", MAX_STATUS_LINE_LENGTH)
			lower_text = reject_bad_text(params["lowerText"] || "", MAX_STATUS_LINE_LENGTH)

			post_message(upper_text, lower_text)
		if("setStatusPicture")
			post_picture(params["picture"])

/datum/computer_file/program/status/ui_static_data(mob/user)
	var/list/data = list()
	data["maxStatusLineLength"] = MAX_STATUS_LINE_LENGTH

	return data

/datum/computer_file/program/status/ui_data(mob/user)
	var/list/data = get_header_data()

	data["upperText"] = upper_text
	data["lowerText"] = lower_text

	return data
