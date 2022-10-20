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

	if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS) && !allow_chunky)
		to_chat(user, span_warning("Your fingers are too big to use this right now!"))
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

	data["show_imprint"] = istype(src, /obj/item/modular_computer/tablet)

	return data

/obj/item/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	data["device_theme"] = device_theme
	data["login"] = list()

	var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
	data["cardholder"] = !!cardholder

	if(cardholder)
		var/stored_name = saved_identification
		var/stored_title = saved_job
		if(!stored_name)
			stored_name = "Unknown"
		if(!stored_title)
			stored_title = "Unknown"
		data["login"] = list(
			IDName = saved_identification,
			IDJob = saved_job,
		)
		data["proposed_login"] = list(
			IDName = cardholder.current_identification,
			IDJob = cardholder.current_job,
		)

	data["removable_media"] = list()
	if(inserted_disk)
		data["removable_media"] += "Eject Disk"
	var/datum/computer_file/program/ai_restorer/airestore_app = locate() in stored_files
	if(airestore_app?.stored_card)
		data["removable_media"] += "intelliCard"
	var/obj/item/computer_hardware/card_slot/secondarycardholder = all_components[MC_CARD2]
	if(secondarycardholder?.stored_card)
		data["removable_media"] += "secondary RFID card"

	data["programs"] = list()
	for(var/datum/computer_file/program/P in stored_files)
		var/running = FALSE
		if(P in idle_threads)
			running = TRUE

		data["programs"] += list(list(
			"name" = P.filename,
			"desc" = P.filedesc,
			"running" = running,
			"icon" = P.program_icon,
			"alert" = P.alert_pending,
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
				if("intelliCard")
					var/datum/computer_file/program/ai_restorer/airestore_app = locate() in stored_files
					if(!airestore_app)
						return
					if(airestore_app.try_eject(user))
						playsound(src, 'sound/machines/card_slide.ogg', 50)
				if("ID")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
					if(!cardholder)
						return
					if(cardholder.try_eject(user))
						playsound(src, 'sound/machines/card_slide.ogg', 50)
				if("secondary RFID card")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD2]
					if(!cardholder)
						return
					if(cardholder.try_eject(user))
						playsound(src, 'sound/machines/card_slide.ogg', 50)
		if("PC_Imprint_ID")
			var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
			if(!cardholder)
				return

			saved_identification = cardholder.current_identification
			saved_job = cardholder.current_job

			UpdateDisplay()

			playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
		if("PC_Pai_Interact")
			switch(params["option"])
				if("eject")
					usr.put_in_hands(inserted_pai)
					to_chat(usr, span_notice("You remove [inserted_pai] from the [name]."))
					inserted_pai = null
				if("interact")
					inserted_pai.attack_self(usr)
			return UI_UPDATE
		else
			return

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	return src
