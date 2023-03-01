/obj/item/modular_computer/interact(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

// Operates TGUI
/obj/item/modular_computer/ui_interact(mob/user, datum/tgui/ui)
	if(!enabled || !user.can_read(src, READING_CHECK_LITERACY) || !use_power())
		if(ui)
			ui.close()
		return

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!screen_on && !issilicon(user))
		if(ui)
			ui.close()
		return

	if(honkvirus_amount > 0) // EXTRA annoying, huh!
		honkvirus_amount--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(active_program)
			ui = new(user, src, active_program.tgui_id, active_program.filedesc)
		else
			ui = new(user, src, "NtosMain")
		ui.open()
		return

	var/old_open_ui = ui.interface
	if(active_program)
		ui.interface = active_program.tgui_id
		ui.title = active_program.filedesc
	else
		ui.interface = "NtosMain"
	//opened a new UI
	if(old_open_ui != ui.interface)
		update_static_data(user, ui)
		ui.send_assets()

/obj/item/modular_computer/ui_assets(mob/user)
	var/list/data = list()
	data += get_asset_datum(/datum/asset/simple/headers)
	if(active_program)
		data += active_program.ui_assets(user)
	return data

/obj/item/modular_computer/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	if(active_program)
		data += active_program.ui_static_data(user)
		return data

	data["show_imprint"] = istype(src, /obj/item/modular_computer/pda)

	return data

/obj/item/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	if(active_program)
		data += active_program.ui_data(user)
		return data

	data["login"] = list(
		IDName = saved_identification || "Unknown",
		IDJob = saved_job || "Unknown",
	)

	data["proposed_login"] = list(
		IDName = computer_id_slot?.registered_name,
		IDJob = computer_id_slot?.assignment,
	)

	data["removable_media"] = list()
	if(inserted_disk)
		data["removable_media"] += "Eject Disk"
	var/datum/computer_file/program/ai_restorer/airestore_app = locate() in stored_files
	if(airestore_app?.stored_card)
		data["removable_media"] += "intelliCard"

	data["programs"] = list()
	for(var/datum/computer_file/program/program in stored_files)
		data["programs"] += list(list(
			"name" = program.filename,
			"desc" = program.filedesc,
			"header_program" = program.header_program,
			"running" = !!(program in idle_threads),
			"icon" = program.program_icon,
			"alert" = program.alert_pending,
		))

	data["has_light"] = has_light
	data["light_on"] = light_on
	data["comp_light_color"] = comp_light_color
	data["pai"] = inserted_pai
	return data

// Handles user's GUI input
/obj/item/modular_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(ishuman(usr) && !allow_chunky) //in /datum/computer_file/program/ui_act() too
		var/mob/living/carbon/human/human_user = usr
		if(human_user.check_chunky_fingers())
			balloon_alert(human_user, "fingers are too big!")
			return TRUE

	if(active_program)
		active_program.ui_act(action, params, ui, state)

	switch(action)
		if("PC_exit")
			kill_program()
			return TRUE
		if("PC_shutdown")
			shutdown_computer()
			return TRUE
		if("PC_minimize")
			if(!active_program)
				return
			//header programs can't be minimized.
			if(active_program.header_program)
				kill_program()
				return TRUE

			idle_threads.Add(active_program)
			active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs

			active_program = null
			update_appearance()

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/killed_program = find_file_by_name(prog)

			if(!istype(killed_program) || killed_program.program_state == PROGRAM_STATE_KILLED)
				return

			killed_program.kill_program(forced = TRUE)
			to_chat(usr, span_notice("Program [killed_program.filename].[killed_program.filetype] with PID [rand(100,999)] has been killed."))

		if("PC_runprogram")
			open_program(usr, find_file_by_name(params["name"]))

		if("PC_toggle_light")
			return toggle_flashlight()

		if("PC_light_color")
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color)
					return
				if(is_color_dark(new_color, 50) ) //Colors too dark are rejected
					to_chat(user, span_warning("That color is too dark! Choose a lighter one."))
					new_color = null
			return set_flashlight_color(new_color)

		if("PC_Eject_Disk")
			var/param = params["name"]
			var/mob/user = usr
			switch(param)
				if("Eject Disk")
					if(!inserted_disk)
						return

					user.put_in_hands(inserted_disk)
					inserted_disk = null
					playsound(src, 'sound/machines/card_slide.ogg', 50)
					return TRUE

				if("intelliCard")
					var/datum/computer_file/program/ai_restorer/airestore_app = locate() in stored_files
					if(!airestore_app)
						return

					if(airestore_app.try_eject(user))
						playsound(src, 'sound/machines/card_slide.ogg', 50)
						return TRUE

				if("ID")
					if(RemoveID(user))
						playsound(src, 'sound/machines/card_slide.ogg', 50)
						return TRUE

		if("PC_Imprint_ID")
			saved_identification = computer_id_slot.registered_name
			saved_job = computer_id_slot.assignment
			UpdateDisplay()
			playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)

		if("PC_Pai_Interact")
			switch(params["option"])
				if("eject")
					usr.put_in_hands(inserted_pai)
					to_chat(usr, span_notice("You remove [inserted_pai] from the [name]."))
					inserted_pai = null
					update_appearance(UPDATE_ICON)
				if("interact")
					inserted_pai.attack_self(usr)
			return UI_UPDATE

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	return src
