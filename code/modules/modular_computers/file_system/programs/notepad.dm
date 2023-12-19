/datum/computer_file/program/notepad
	filename = "notepad"
	filedesc = "Notepad"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "generic"
	extended_desc = "Jot down your work-safe thoughts and what not."
	size = 2
	tgui_id = "NtosNotepad"
	program_icon = "book"
	can_run_on_flags = PROGRAM_ALL

	var/written_note = "Congratulations on your station upgrading to the new NtOS and Thinktronic based collaboration effort, \
		bringing you the best in electronics and software since 2467!\n\
		To help with navigation, we have provided the following definitions:\n\
		Fore - Toward front of ship\n\
		Aft - Toward back of ship\n\
		Port - Left side of ship\n\
		Starboard - Right side of ship\n\
		Quarter - Either sides of Aft\n\
		Bow - Either sides of Fore"

	///When the input is received, the written note will be set to its value.
	var/datum/port/input/set_text
	///Send out the written note
	var/datum/port/input/send
	///The written note output
	var/datum/port/output/sent_text

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui)
	switch(action)
		if("UpdateNote")
			written_note = params["newnote"]
			return TRUE

/datum/computer_file/program/notepad/ui_data(mob/user)
	var/list/data = list()

	data["note"] = written_note

	return data

/datum/computer_file/program/notepad/populate_modular_ports(obj/item/circuit_component/comp)
	. = ..()
	set_text = comp.add_input_port("Set Notes", PORT_TYPE_STRING)
	send = comp.add_input_port("Send Notes", PORT_TYPE_SIGNAL)
	sent_text = comp.add_output_port("Sent Notes", PORT_TYPE_STRING)

/datum/computer_file/program/notepad/depopulate_modular_ports(obj/item/circuit_component/comp)
	. = ..()
	set_text = comp.remove_input_port(set_text)
	send = comp.remove_input_port(send)
	sent_text = comp.remove_output_port(sent_text)

/datum/computer_file/program/notepad/on_input_received(datum/port/port)
	if(COMPONENT_TRIGGERED_BY(set_text, port))
		written_note = set_text.value
		SStgui.update_uis(computer)
	if(COMPONENT_TRIGGERED_BY(send, port))
		sent_text.set_output(written_note)
