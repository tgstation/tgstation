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

	var/upper_text
	var/lower_text

/datum/computer_file/program/status/proc/SendSignal()
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = "message"))

	status_signal.data["msg1"] = reject_bad_text(upper_text || "", MAX_STATUS_LINE_LENGTH)
	status_signal.data["msg2"] = reject_bad_text(lower_text || "", MAX_STATUS_LINE_LENGTH)

	frequency.post_signal(computer, status_signal)

/datum/computer_file/program/status/proc/SetText(position, text)
	switch(position)
		if("upper")
			upper_text = text
		if("lower")
			lower_text = text

/datum/computer_file/program/status/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("stat_send")
			SendSignal()
		if("stat_update")
			SetText(params["position"], params["text"]) // i hate the player i hate the player

/datum/computer_file/program/status/ui_data(mob/user)
	var/list/data = get_header_data()

	data["upper"] = upper_text
	data["lower"] = lower_text

	return data
