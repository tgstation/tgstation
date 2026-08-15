/datum/operating_system/sosix/ntos/mobile
	name = "NTOS Mobile"
	description = "A streamlined version of NTOS designed for mobile modular computers."
	max_idle_programs = 2
	device_theme = PDA_THEME_NTOS

	///Static list of default PDA apps to install on Initialize.
	var/static/list/datum/computer_file/pda_programs = list(
		/datum/computer_file/program/messenger,
		/datum/computer_file/program/nt_pay,
		/datum/computer_file/program/notepad,
		/datum/computer_file/program/crew_manifest,
	)

/datum/operating_system/sosix/ntos/mobile/install(mob/user)
	..()
	for(var/programs in pda_programs)
		var/datum/computer_file/program_type = new programs
		store_file(program_type)

/datum/operating_system/sosix/ntos/mobile/activate_program(mob/user, datum/computer_file/program/program)
	..()
	if(!program)
		return
	if(active_threads.len == 0)
		active_threads.Add(program)
	else
		if(active_threads[1])
			active_threads[1]?.background_program()
			idle_threads.Add(active_threads[1])
		active_threads[1] = program
	program.on_made_active_program(user)

/datum/operating_system/sosix/ntos/mobile/run_program(mob/user, datum/computer_file/program/program, open_ui = TRUE)
	..()

	if(isnull(program) || !istype(program)) // Program not found or it's not executable program.
		if(user)
			to_chat(user, span_danger("\The [hardware]'s screen shows \"I/O ERROR - Unable to run program\" warning."))
		return FALSE
	if(program.computer != hardware)
		CRASH("tried to open program that does not belong to this computer")

	// The program is already running. Resume it.
	if(program in idle_threads)
		activate_program(user, program)
		program.alert_pending = FALSE
		idle_threads.Remove(program)
		if(open_ui)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/sosix/ntos/mobile, user_interact), user)
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
	if(open_ui)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/sosix/ntos/mobile, user_interact), user)
	hardware.update_appearance(UPDATE_ICON)
	return TRUE

/datum/operating_system/sosix/ntos/mobile/kill_program(datum/computer_file/program/program)
	..()
	var/mob/user = usr
	program.on_kill(user)
	if(program == get_active_thread(1))
		active_threads[1] = null
		if(!QDELETED(hardware) && hardware.enabled && user)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/sosix/ntos/mobile, user_interact), user)
	else if(program in idle_threads)
		idle_threads.Remove(program)
	else
		return FALSE

	if(program.program_flags & PROGRAM_REQUIRES_NTNET)
		var/obj/item/card/id/ID = hardware.stored_id?.GetID()
		program.generate_network_log("Connection closed -- Program ID: [program.filename] User:[ID ? "[ID.registered_name]" : "None"]")

	hardware.update_appearance(UPDATE_ICON)
	SEND_SIGNAL(program, COMSIG_COMPUTER_PROGRAM_KILL, user)


/datum/operating_system/sosix/ntos/mobile/ui_state(mob/user)
	if(hardware.inserted_pai && (user == hardware.inserted_pai.pai))
		return GLOB.contained_state
	return ..()

// Operates TGUI
/datum/operating_system/sosix/ntos/mobile/ui_interact(mob/user, datum/tgui/ui)
	if(!hardware.enabled || !user.can_read(hardware, READING_CHECK_LITERACY))
		ui?.close()
		return

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!hardware.screen_on && !issilicon(user))
		ui?.close()
		return

	if(hardware.honkvirus_amount > 0) // EXTRA annoying, huh!
		hardware.honkvirus_amount--
		playsound(hardware, 'sound/items/bikehorn.ogg', 30, TRUE)

	ui = SStgui.try_update_ui(user, src, ui)
	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(!ui)
		user_interact(user)
	else if(active_program?.always_update_ui)
		active_program.ui_interact(user, ui)

/datum/operating_system/sosix/ntos/mobile/ui_assets(mob/user)
	var/list/data = list()
	data += get_asset_datum(/datum/asset/simple/headers)
	//TODO: ALL ACTIVE PROGRMAS SEND IT
	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(active_program)
		data += active_program.ui_assets(user)
	return data

/datum/operating_system/sosix/ntos/mobile/ui_static_data(mob/user)
	var/list/data = list()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	if(active_program)
		data += active_program.ui_static_data(user)
		return data

	data["show_imprint"] = istype(hardware, /obj/item/modular_computer/pda)
	return data

/datum/operating_system/sosix/ntos/mobile/ui_data(mob/user)
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
/datum/operating_system/sosix/ntos/mobile/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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

/datum/operating_system/sosix/ntos/mobile/ui_host()
	if(hardware.physical)
		return hardware.physical
	return hardware

/datum/operating_system/sosix/ntos/mobile/ui_close(mob/user)
	. = ..()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	active_program?.ui_close(user)

/datum/operating_system/sosix/ntos/mobile/user_interact(mob/user)
	if(user)
		var/datum/tgui/active_ui = SStgui.get_open_ui(user, src)
		if(!active_ui)
			var/datum/computer_file/program/active_program = get_active_thread(1)
			if(active_program)
				active_ui = new(user, src, active_program.tgui_id, active_program.filedesc)
				active_program.ui_interact(user, active_ui)
			else
				active_ui = new(user, src, "NtosMain")
			return active_ui.open()

	var/datum/computer_file/program/active_program = get_active_thread(1)
	for (var/datum/tgui/window as anything in open_uis)
		if(active_program)
			window.interface = active_program.tgui_id
			window.title = active_program.filedesc
			active_program.ui_interact(window.user, window)
		else
			window.interface = "NtosMain"
		window.send_assets()
	update_static_data_for_all_viewers()
