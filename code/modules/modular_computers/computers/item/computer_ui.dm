/obj/item/modular_computer/attack_self(mob/user)
	. = ..()
	ui_interact(user)

// Operates TGUI
/obj/item/modular_computer/ui_interact(mob/user, datum/tgui/ui)
	if(!enabled)
		if(ui)
			ui.close()
		return
	if(!use_power())
		if(ui)
			ui.close()
		return

	if(!user.can_read(src, READING_CHECK_LITERACY))
		return

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!screen_on && !issilicon(user))
		if(ui)
			ui.close()
		return

	// If we have an active program switch to it now.
	if(active_program)
		if(ui) // This is the main laptop screen. Since we are switching to program's UI close it for now.
			ui.close()
		active_program.ui_interact(user)
		return

	if(honkvirus_amount > 0) // EXTRA annoying, huh!
		honkvirus_amount--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "NtosMain")
		ui.set_autoupdate(TRUE)
		if(ui.open())
			ui.send_asset(get_asset_datum(/datum/asset/simple/headers))

/obj/item/modular_computer/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()

	data["show_imprint"] = istype(src, /obj/item/modular_computer/pda)

	return data

/obj/item/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	data["device_theme"] = device_theme

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
	for(var/datum/computer_file/program/program as anything in stored_files)
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
/obj/item/modular_computer/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(ishuman(usr) && !allow_chunky) //in /datum/computer_file/program/ui_act() too
		var/mob/living/carbon/human/human_user = usr
		if(human_user.check_chunky_fingers())
			balloon_alert(human_user, "fingers are too big!")
			return TRUE

	switch(action)
		if("PC_exit")
			kill_program()
			return TRUE
		if("PC_shutdown")
			shutdown_computer()
			return TRUE
		if("PC_minimize")
			var/mob/user = usr
			if(!active_program)
				return

			idle_threads.Add(active_program)
			active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs

			active_program = null
			update_appearance()
			if(user && istype(user))
				ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			P = find_file_by_name(prog)

			if(!istype(P) || P.program_state == PROGRAM_STATE_KILLED)
				return

			P.kill_program(forced = TRUE)
			to_chat(user, span_notice("Program [P.filename].[P.filetype] with PID [rand(100,999)] has been killed."))

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
					if(RemoveID())
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
		else
			return

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	return src
