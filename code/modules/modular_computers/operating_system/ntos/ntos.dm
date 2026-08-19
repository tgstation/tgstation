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


/datum/operating_system/default/ntos/New(obj/item/modular_computer/computer)
	. = ..()
	filesystem = new /datum/driver/filesystem/ntfs(computer)

/datum/operating_system/default/ntos/shutdown_os()
	..()
	for(var/datum/computer_file/program/idle as anything in idle_threads)
		kill_program(idle)

/datum/operating_system/default/ntos/install(mob/user)
	..()
	for(var/programs in default_programs + starting_programs)
		var/datum/computer_file/program_type = new programs
		filesystem.store_file(program_type)

/datum/operating_system/default/ntos/run_program(mob/user, datum/computer_file/program/program)
	..()

	// Program not found or it's not executable program.
	if(isnull(program) || !istype(program))
		if(user)
			to_chat(user, span_danger("\The [hardware]'s screen shows \"I/O ERROR - Unable to run program\" warning."))
		return FALSE

	if(program.computer != hardware)
		CRASH("tried to open program that does not belong to this computer")

	if(program in active_threads)
		return FALSE

	// The program is already running. Resume it.
	if(program in idle_threads)
		activate_program(user, program)
		program.alert_pending = FALSE
		idle_threads.Remove(program)
		hardware.update_appearance(UPDATE_ICON)
		return TRUE

	if(!program.is_supported_by_hardware(hardware.hardware_flag, loud = TRUE, user = user))
		return FALSE

	if(idle_threads.len > max_idle_programs)
		if(user)
			to_chat(user, span_danger("\The [hardware] displays a \"Maximal CPU load reached. Unable to run another program.\" error."))
		return FALSE

	if(program.program_flags & PROGRAM_REQUIRES_NTNET && !hardware.get_ntnet_status()) // The program requires NTNet connection, but we are not connected to NTNet.
		if(user)
			to_chat(user, span_danger("\The [hardware]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning."))
		return FALSE

	if(!program.on_start(user))
		return FALSE

	activate_program(user, program)
	program.alert_pending = FALSE
	hardware.update_appearance(UPDATE_ICON)
	return TRUE

/datum/operating_system/default/ntos/kill_program(datum/computer_file/program/program)
	..()
	var/mob/user = usr
	program.on_kill(user)
	if(program in active_threads)
		active_threads.Remove(program)
	else if(program in idle_threads)
		idle_threads.Remove(program)
	else
		return FALSE

	if(program.program_flags & PROGRAM_REQUIRES_NTNET)
		var/obj/item/card/id/ID = hardware.stored_id?.GetID()
		program.generate_network_log("Connection closed -- Program ID: [program.filename] User:[ID ? "[ID.registered_name]" : "None"]")

	hardware.update_appearance(UPDATE_ICON)
	SEND_SIGNAL(program, COMSIG_COMPUTER_PROGRAM_KILL, user)

/datum/operating_system/default/ntos/ui_state(mob/user)
	if(hardware.inserted_pai && (user == hardware.inserted_pai.pai))
		return GLOB.contained_state
	return ..()

/datum/operating_system/default/ntos/ui_assets(mob/user)
	var/list/data = list()
	data += get_asset_datum(/datum/asset/simple/headers)
	for(var/datum/computer_file/program/active_program in active_threads)
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

/datum/operating_system/default/ntos/ui_interact(mob/user, datum/tgui/ui)
	if(!hardware.enabled || !user.can_read(hardware, READING_CHECK_LITERACY))
		ui?.close()
		return

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!hardware.screen_on && !issilicon(user))
		ui?.close()
		return

	// EXTRA annoying, huh!
	if(hardware.honkvirus_amount > 0)
		hardware.honkvirus_amount--
		playsound(hardware, 'sound/items/bikehorn.ogg', 30, TRUE)

/datum/operating_system/default/ntos/ui_data(mob/user)
	var/list/data = hardware.get_header_data()
	for(var/datum/computer_file/program/active_program in active_threads)
		data += active_program.ui_data(user)

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
			"tgui_id" = program.tgui_id,
			"name" = program.filename,
			"desc" = program.filedesc,
			"header_program" = !!(program.program_flags & PROGRAM_HEADER),
			"active" = !!(program in active_threads),
			"idle" = !!(program in idle_threads),
			"icon" = program.program_icon,
			"alert" = program.alert_pending,
		))

	data["alert_style"] = hardware.get_security_level_relevancy()
	data["alert_color"] = SSsecurity_level?.current_security_level?.announcement_color
	data["alert_name"] = SSsecurity_level?.current_security_level?.name_shortform

	return data

/datum/operating_system/default/ntos/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	//TODO: MOVE TO THE COMPUTER CODE. OS CANT CHECK YOUR FINGERS
	if(ishuman(user) && !hardware.allow_chunky)
		var/mob/living/carbon/human/human_user = user
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
			active_program.background_program(user)
			active_threads.Remove(active_program)
			idle_threads.Add(active_program)
			return TRUE

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/killed_program = filesystem.find_file_by_name(prog)

			if(!istype(killed_program))
				return

			kill_program(killed_program)
			to_chat(user, span_notice("Program [killed_program.filename].[killed_program.filetype] with PID [rand(100,999)] has been killed."))
			return TRUE

		if("PC_runprogram")
			run_program(user, filesystem.find_file_by_name(params["name"]))
			return TRUE

		if("PC_toggle_light")
			hardware.toggle_flashlight()
			return TRUE

		if("PC_light_color")
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
					if(!ishuman(user))
						return
					hardware.remove_pai(user)
				if("interact")
					hardware.inserted_pai.attack_self(user)
			return TRUE

	for(var/datum/computer_file/program/active_program in active_threads)
		. |= active_program.ui_act(action, params, ui, state)

/datum/operating_system/default/ntos/ui_host()
	if(hardware.physical)
		return hardware.physical
	return hardware
