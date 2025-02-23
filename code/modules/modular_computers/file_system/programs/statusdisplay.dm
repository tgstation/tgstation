/datum/computer_file/program/status
	filename = "statusdisplay"
	filedesc = "Status Display"
	program_icon = "signal"
	program_open_overlay = "generic"
	size = 1
	circuit_comp_type = /obj/item/circuit_component/mod_program/status

	extended_desc = "An app used to change the message on the station status displays."
	tgui_id = "NtosStatus"

	can_run_on_flags = PROGRAM_ALL
	program_flags = PROGRAM_REQUIRES_NTNET
	detomatix_resistance = DETOMATIX_RESIST_MAJOR

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
/datum/computer_file/program/status/proc/post_message(upper, lower, log_usr = key_name(usr))
	post_status("message", upper, lower)
	log_game("[log_usr] has changed the station status display message to \"[upper] [lower]\" [loc_name(usr)]")

/**
 * Post a picture to status displays
 * Arguments:
 * * picture - The picture name
 */
/datum/computer_file/program/status/proc/post_picture(picture, log_usr = key_name(usr))
	if (!(picture in GLOB.status_display_approved_pictures))
		return
	if(picture in GLOB.status_display_state_pictures)
		post_status(picture)
	else
		if(picture == "currentalert") // You cannot set Code Blue display during Code Red and similiar
			post_status("alert", SSsecurity_level?.current_security_level?.status_display_icon_state || "greenalert")
		else
			post_status("alert", picture)

	log_game("[log_usr] has changed the station status display message to \"[picture]\" [loc_name(usr)]")

/datum/computer_file/program/status/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
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
	var/list/data = list()

	data["upperText"] = upper_text
	data["lowerText"] = lower_text

	return data


/obj/item/circuit_component/mod_program/status
	associated_program = /datum/computer_file/program/status
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	///When the trigger is signaled, this will be the upper text of status displays.
	var/datum/port/input/upper_text
	///When the trigger is signaled, this will be the bottom text.
	var/datum/port/input/bottom_text
	///A list port that, when signaled, will set the status image to one of its values
	var/datum/port/input/status_display_pics

/obj/item/circuit_component/mod_program/status/populate_ports()
	. = ..()
	upper_text = add_input_port("Upper text", PORT_TYPE_STRING)
	bottom_text = add_input_port("Bottom text", PORT_TYPE_STRING)

/obj/item/circuit_component/mod_program/status/populate_options()
	status_display_pics = add_option_port("Set Status Display Picture", GLOB.status_display_approved_pictures, trigger = PROC_REF(set_picture))

/obj/item/circuit_component/mod_program/status/proc/set_picture(datum/port/port)
	var/datum/computer_file/program/status/status = associated_program
	INVOKE_ASYNC(status, TYPE_PROC_REF(/datum/computer_file/program/status, post_picture), status_display_pics.value, parent.get_creator())

/obj/item/circuit_component/mod_program/status/input_received(datum/port/port)
	var/datum/computer_file/program/status/status = associated_program
	INVOKE_ASYNC(status, TYPE_PROC_REF(/datum/computer_file/program/status, post_message), upper_text.value, bottom_text.value, parent.get_creator())
