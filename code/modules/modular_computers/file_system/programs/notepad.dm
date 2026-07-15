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
	circuit_comp_type = /obj/item/circuit_component/mod_program/notepad

	var/opened_file_uid
	var/opened_file_on_disk = FALSE
	var/opened_file_name = "Untitled"
	var/written_note = "Congratulations on your station upgrading to the new NtOS and Thinktronic based collaboration effort, \
		bringing you the best in electronics and software since 2467!\n\
		To help with navigation, we have provided the following definitions:\n\
		Fore - Toward front of ship\n\
		Aft - Toward back of ship\n\
		Port - Left side of ship\n\
		Starboard - Right side of ship\n\
		Quarter - Either sides of Aft\n\
		Bow - Either sides of Fore"

/datum/computer_file/program/notepad/proc/get_target_disk(opened_on_disk)
	if(opened_on_disk && computer?.inserted_disk)
		return computer.inserted_disk
	return null

/datum/computer_file/program/notepad/proc/find_text_file(uid, opened_on_disk, name)
	var/obj/item/disk/computer/target_disk = get_target_disk(opened_on_disk)
	var/datum/computer_file/data/text/file
	if(uid)
		file = computer.find_file_by_uid(uid, target_disk)
	if(!file && length(name))
		file = computer.find_file_by_full_name("[name].TXT", target_disk)
	return file

/datum/computer_file/program/notepad/proc/load_text_file(datum/computer_file/data/text/file)
	written_note = file.stored_text
	opened_file_uid = file.uid
	opened_file_on_disk = !!file.disk_host
	opened_file_name = file.filename

/datum/computer_file/program/notepad/proc/save_text_file(mob/user, name, extension, note, uid, opened_on_disk)
	var/obj/item/disk/computer/target_disk = get_target_disk(opened_on_disk)
	var/datum/computer_file/data/text/file = find_text_file(uid, opened_on_disk, name)
	if(file)
		file.stored_text = note
		file.calculate_size()
		load_text_file(file)
		return

	var/datum/computer_file/data/text/new_file = create_text_file(extension)
	new_file.filename = name
	new_file.stored_text = note
	new_file.calculate_size()
	var/file_stored = target_disk ? target_disk.add_file(new_file) : computer.store_file(new_file, user)
	if(!file_stored)
		to_chat(user, span_warning("Error occured while saving the file!"))
		qdel(new_file)
		return

	load_text_file(new_file)

/datum/computer_file/program/notepad/proc/create_text_file(extension)
	if(extension == "LOG")
		return new /datum/computer_file/data/text/logfile()
	return new /datum/computer_file/data/text()

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	switch(action)
		if("UpdateNote")
			written_note = params["newnote"]
			return TRUE
		if("SaveNote")
			written_note = params["newnote"] || written_note
			save_text_file(user, opened_file_name, null, written_note, opened_file_uid, opened_file_on_disk)
			return TRUE
		if("Save")
			written_note = params["note"] || written_note
			save_text_file(user, opened_file_name, null, written_note, opened_file_uid, opened_file_on_disk)
			return TRUE
		if("SaveAs")
			var/new_name = trim(params["name"], MAX_MESSAGE_LEN)
			var/extension = params["extension"]
			if(!length(new_name) || !filter_filename_pda(new_name))
				return
			written_note = params["note"] || written_note
			save_text_file(user, new_name, extension, written_note, params["uid"], opened_file_on_disk)
			return TRUE
		if("Open")
			var/datum/computer_file/data/text/file = find_text_file(params["uid"], params["onDisk"], params["name"])
			if(!file)
				return
			load_text_file(file)
			return TRUE

/datum/computer_file/program/notepad/ui_data(mob/user)
	var/list/data = list()

	data["note"] = written_note
	data["documentName"] = opened_file_name
	data["files"] = list()
	if(computer)
		for(var/datum/computer_file/file in computer.get_files(TRUE))
			if(!istype(file, /datum/computer_file/data/text))
				continue
			data["files"] += list(list(
				"uid" = file.uid,
				"name" = file.filename,
				"filetype" = file.filetype,
				"onDisk" = !!file.disk_host,
				"displayName" = "[file.filename].[file.filetype]",
			))

	return data

/obj/item/circuit_component/mod_program/notepad
	associated_program = /datum/computer_file/program/notepad
	///When the input is received, the written note will be set to its value.
	var/datum/port/input/set_text
	///The written note output, sent everytime notes are updated.
	var/datum/port/output/updated_text
	///Pinged whenever the text is updated
	var/datum/port/output/updated

/obj/item/circuit_component/mod_program/notepad/populate_ports()
	. = ..()
	set_text = add_input_port("Set Notes", PORT_TYPE_STRING)
	updated_text = add_output_port("Notes", PORT_TYPE_STRING)
	updated = add_output_port("Updated", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_program/notepad/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(associated_program, COMSIG_UI_ACT, PROC_REF(on_note_updated))

/obj/item/circuit_component/mod_program/notepad/unregister_shell()
	UnregisterSignal(associated_program, COMSIG_UI_ACT)
	return ..()

/obj/item/circuit_component/mod_program/notepad/proc/on_note_updated(datum/source, mob/user, action, list/params)
	SIGNAL_HANDLER
	if(action == "UpdateNote")
		updated_text.set_output(params["newnote"])
		updated.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/notepad/input_received(datum/port/port)
	var/datum/computer_file/program/notepad/pad = associated_program
	pad.written_note = set_text.value
	SStgui.update_uis(pad.computer)
	updated_text.set_output(pad.written_note)
	updated.set_output(COMPONENT_SIGNAL)
