/datum/operating_system/default/ntos
	name = "Nanotrasen Operating System"

	description = "A modern operating system developed by Nanotrasen for use on their modular computer systems."

	///Static list of default programs that come with ALL computers, here so computers don't have to repeat this.
	var/static/list/datum/computer_file/default_programs = list(
		/datum/computer_file/program/themeify,
		/datum/computer_file/program/ntnetdownload,
		/datum/computer_file/program/filemanager,
	)

	///Non-static list of programs the computer should receive on Initialize.
	var/list/datum/computer_file/starting_programs = list()

	///The theme, used for the main menu and file browser apps.
	var/device_theme = PDA_THEME_NTOS


/datum/operating_system/default/ntos/shutdown_os()
	..()
	for(var/datum/computer_file/program/idle as anything in idle_threads)
		kill_program(idle)

/datum/operating_system/default/ntos/install(mob/user)
	..()
	for(var/programs in default_programs + starting_programs)
		var/datum/computer_file/program_type = new programs
		store_file(program_type)

/**
 * store_file
 *
 * Adds an already initialized file to the computer, checking if one already exists.
 * Returns TRUE if successfully stored, FALSE otherwise.
 * user is optional: If set, the action was done by a mob/player
 */
/datum/operating_system/default/ntos/store_file(datum/computer_file/file_storing, mob/user)
	if(!file_storing || !istype(file_storing))
		return FALSE
	if(!can_store_file(file_storing))
		return FALSE

	// This file is already stored. Don't store it again.
	if(file_storing in hardware.stored_files)
		return FALSE

	file_storing.computer = hardware
	file_storing.os = hardware.os
	hardware.used_capacity += file_storing.size
	SEND_SIGNAL(file_storing, COMSIG_COMPUTER_FILE_STORE, hardware, user)
	SEND_SIGNAL(hardware, COMSIG_MODULAR_COMPUTER_FILE_STORE, file_storing, user)
	return TRUE

/**
 * remove_file
 *
 * Removes a given file from the computer, if possible.
 * Properly checking if the file even exists and is in the computer.
 * Returns TRUE if successfully completed, FALSE otherwise
 */
/datum/operating_system/default/ntos/remove_file(datum/computer_file/file_removing)
	if(!file_removing || !istype(file_removing))
		return FALSE
	if(!(file_removing in hardware.stored_files))
		return FALSE
	if(istype(file_removing, /datum/computer_file/program))
		var/datum/computer_file/program/program_file = file_removing
		kill_program(program_file)

	hardware.stored_files.Remove(file_removing)
	hardware.used_capacity -= file_removing.size
	SEND_SIGNAL(src, COMSIG_MODULAR_COMPUTER_FILE_DELETE, file_removing)
	SEND_SIGNAL(file_removing, COMSIG_COMPUTER_FILE_DELETE, src)
	qdel(file_removing)
	return TRUE

/**
 * can_store_file
 *
 * Checks if a computer can store a file, as computers can only store unique files.
 * returns TRUE if possible, FALSE otherwise.
 */
/datum/operating_system/default/ntos/can_store_file(datum/computer_file/file)
	if(!file || !istype(file))
		return FALSE
	if(file in hardware.stored_files)
		return FALSE
	if(find_file_by_name(file.filename))
		return FALSE
	// In the unlikely event someone manages to create that many files.
	// BYOND is acting weird with numbers above 999 in loops (infinite loop prevention)
	if(hardware.stored_files.len >= 999)
		return FALSE
	if((hardware.used_capacity + file.size) > hardware.max_capacity)
		return FALSE
	if(!file.can_store_file(src))
		return FALSE

	return TRUE

/**
 * find_file_by_name
 *
 * Will check all applications in a tablet for files and, if they have \
 * the same filename (disregarding extension), will return it.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/operating_system/default/ntos/find_file_by_name(filename, obj/item/disk/computer/target_disk)
	if(!istext(filename))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in hardware.stored_files)
			if(file.filename == filename)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.filename == filename)
				return file
	return null

/**
 * find_file_by_full_name
 *
 * Will check all applications in a tablet for files and, if they have \
 * the same filename AND extension, will return it.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/operating_system/default/ntos/find_file_by_full_name(full_path, obj/item/disk/computer/target_disk)
	if(!istext(full_path))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in hardware.stored_files)
			if("[file.filename].[file.filetype]" == full_path)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if("[file.filename].[file.filetype]" == full_path)
				return file
	return null

/**
 * find_file_by_uid
 *
 * Will check all files in this computer and returns the file with the matching uid.
 * A file's uid is always unique to them, so this proc is sometimes preferable over find_file_by_name.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/operating_system/default/ntos/find_file_by_uid(uid, obj/item/disk/computer/target_disk)
	if(!isnum(uid))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in hardware.stored_files)
			if(file.uid == uid)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.uid == uid)
				return file
	return null

/datum/operating_system/default/ntos/ui_state(mob/user)
	if(hardware.inserted_pai && (user == hardware.inserted_pai.pai))
		return GLOB.contained_state
	return ..()

/datum/operating_system/default/ntos/ui_assets(mob/user)
	var/list/data = list()
	data += get_asset_datum(/datum/asset/simple/headers)
	//TODO: ALL ACTIVE PROGRMAS SEND IT
	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(active_program)
		data += active_program.ui_assets(user)
	return data

/datum/operating_system/default/ntos/ui_static_data(mob/user)
	var/list/data = list()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(active_program)
		data += active_program.ui_static_data(user)
		return data

	data["show_imprint"] = istype(hardware, /obj/item/modular_computer/pda)
	return data

/datum/operating_system/default/ntos/ui_data(mob/user)
	var/list/data = hardware.get_header_data()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(active_program)
		data += active_program.ui_data(user)
		return data

	data["pai"] = hardware.inserted_pai
	data["has_light"] = hardware.has_light
	data["light_on"] = hardware.light_on
	data["comp_light_color"] = hardware.comp_light_color

	data["login"] = list(
		IDName = hardware.saved_identification || "Unknown",
		IDJob = hardware.saved_job || "Unknown",
	)

	data["proposed_login"] = list(
		IDInserted = hardware.stored_id ? TRUE : FALSE,
		IDName = hardware.stored_id?.registered_name,
		IDJob = hardware.stored_id?.assignment,
	)

	data["removable_media"] = list()
	if(hardware.inserted_disk)
		data["removable_media"] += "Eject Disk"
	var/datum/computer_file/program/ai_restorer/airestore_app = locate() in hardware.stored_files
	if(airestore_app?.stored_card)
		data["removable_media"] += "intelliCard"

	data["programs"] = list()
	for(var/datum/computer_file/program/program in hardware.stored_files)
		data["programs"] += list(list(
			"name" = program.filename,
			"desc" = program.filedesc,
			"header_program" = !!(program.program_flags & PROGRAM_HEADER),
			"running" = !!(program in idle_threads),
			"icon" = program.program_icon,
			"alert" = program.alert_pending,
		))

	data["alert_style"] = hardware.get_security_level_relevancy()
	data["alert_color"] = SSsecurity_level?.current_security_level?.announcement_color
	data["alert_name"] = SSsecurity_level?.current_security_level?.name_shortform

	return data

// Handles user's GUI input
/datum/operating_system/default/ntos/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(ishuman(usr) && !hardware.allow_chunky)
		var/mob/living/carbon/human/human_user = usr
		if(human_user.check_chunky_fingers())
			hardware.balloon_alert(human_user, "fingers are too big!")
			return TRUE

	switch(action)
		if("PC_exit")
			//you can't close apps in emergency mode.
			if(isnull(hardware.internal_cell) || hardware.internal_cell.charge)
				kill_program(get_active_thread(1))
			return TRUE
		if("PC_shutdown")
			hardware.shutdown_computer()
			return TRUE
		if("PC_minimize")
			if(!get_active_thread(1) || (!isnull(hardware.internal_cell) && !hardware.internal_cell.charge))
				return
			var/datum/computer_file/program/active_program = get_active_thread(1)
			active_program.background_program(usr)
			active_threads.Remove(active_program)
			idle_threads.Add(active_program)
			return TRUE

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/killed_program = find_file_by_name(prog)

			if(!istype(killed_program))
				return

			kill_program(killed_program)
			to_chat(usr, span_notice("Program [killed_program.filename].[killed_program.filetype] with PID [rand(100,999)] has been killed."))
			return TRUE

		if("PC_runprogram")
			run_program(usr, find_file_by_name(params["name"]))
			return TRUE

		if("PC_toggle_light")
			hardware.toggle_flashlight()
			return TRUE

		if("PC_light_color")
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = tgui_color_picker(user, "Choose a new color for [hardware]'s flashlight.", "Light Color",hardware.light_color)
				if(!new_color)
					return
				if(is_color_dark(new_color, 50) ) //Colors too dark are rejected
					to_chat(user, span_warning("That color is too dark! Choose a lighter one."))
					new_color = null
			hardware.set_flashlight_color(new_color)
			return TRUE

		if("PC_Eject_Disk")
			var/param = params["name"]
			var/mob/user = usr
			switch(param)
				if("Eject Disk")
					if(!hardware.inserted_disk)
						return

					if(!user || !hardware.Adjacent(user))
						hardware.inserted_disk.forceMove(hardware.drop_location())
					else
						user.put_in_hands(hardware.inserted_disk)
					hardware.inserted_disk = null
					playsound(hardware, 'sound/machines/card_slide.ogg', 50)
					return TRUE

				if("intelliCard")
					var/datum/computer_file/program/ai_restorer/airestore_app = locate() in hardware.stored_files
					if(!airestore_app)
						return

					if(airestore_app.try_eject(user))
						playsound(hardware, 'sound/machines/card_slide.ogg', 50)
						return TRUE

				if("ID")
					if(hardware.remove_id(user))
						playsound(hardware, 'sound/machines/card_slide.ogg', 50)
						return TRUE

		if("PC_Imprint_ID")
			hardware.imprint_id()
			hardware.UpdateDisplay()
			playsound(hardware, 'sound/machines/terminal/terminal_processing.ogg', 15, TRUE)

		if("PC_Pai_Interact")
			switch(params["option"])
				if("eject")
					if(!ishuman(usr))
						return
					hardware.remove_pai(usr)
				if("interact")
					hardware.inserted_pai.attack_self(usr)
			return TRUE

	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(active_program)
		return active_program.ui_act(action, params, ui, state)

/datum/operating_system/default/ntos/ui_host()
	if(hardware.physical)
		return hardware.physical
	return hardware
