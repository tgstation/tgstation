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

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		to_chat(user, "<span class='danger'>\The [src] beeps three times, it's screen displaying a \"DISK ERROR\" warning.</span>")
		return // No HDD, No HDD files list or no stored files. Something is very broken.

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "NtosMain")
		ui.set_autoupdate(TRUE)
		if(ui.open())
			ui.send_asset(get_asset_datum(/datum/asset/simple/headers))


/obj/item/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	data["device_theme"] = device_theme

	data["login"] = list()
	var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
	data["cardholder"] = FALSE
	if(cardholder)
		data["cardholder"] = TRUE
		var/obj/item/card/id/stored_card = cardholder.GetID()
		if(stored_card)
			var/stored_name = stored_card.registered_name
			var/stored_title = stored_card.assignment
			if(!stored_name)
				stored_name = "Unknown"
			if(!stored_title)
				stored_title = "Unknown"
			data["login"] = list(
				IDName = stored_name,
				IDJob = stored_title,
			)

	data["removable_media"] = list()
	if(all_components[MC_SDD])
		data["removable_media"] += "removable storage disk"
	var/obj/item/computer_hardware/ai_slot/intelliholder = all_components[MC_AI]
	if(intelliholder?.stored_card)
		data["removable_media"] += "intelliCard"
	var/obj/item/computer_hardware/card_slot/secondarycardholder = all_components[MC_CARD2]
	if(secondarycardholder?.stored_card)
		data["removable_media"] += "secondary RFID card"

	data["programs"] = list()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	for(var/datum/computer_file/program/P in hard_drive.stored_files)
		var/running = FALSE
		if(P in idle_threads)
			running = TRUE

		data["programs"] += list(list("name" = P.filename, "desc" = P.filedesc, "running" = running, "icon" = P.program_icon, "alert" = P.alert_pending))

	data["has_light"] = has_light
	data["light_on"] = light_on
	data["comp_light_color"] = comp_light_color
	return data


// Handles user's GUI input
/obj/item/modular_computer/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	switch(action)
		if("PC_exit")
			kill_program()
			return TRUE
		if("PC_shutdown")
			shutdown_computer()
			return TRUE
		if("PC_minimize")
			var/mob/user = usr
			if(!active_program || !all_components[MC_CPU])
				return

			idle_threads.Add(active_program)
			active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs

			active_program = null
			update_icon()
			if(user && istype(user))
				ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			if(hard_drive)
				P = hard_drive.find_file_by_name(prog)

			if(!istype(P) || P.program_state == PROGRAM_STATE_KILLED)
				return

			P.kill_program(forced = TRUE)
			to_chat(user, "<span class='notice'>Program [P.filename].[P.filetype] with PID [rand(100,999)] has been killed.</span>")

		if("PC_runprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			if(hard_drive)
				P = hard_drive.find_file_by_name(prog)

			if(!P || !istype(P)) // Program not found or it's not executable program.
				to_chat(user, "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning.</span>")
				return

			P.computer = src

			if(!P.is_supported_by_hardware(hardware_flag, 1, user))
				return

			// The program is already running. Resume it.
			if(P in idle_threads)
				P.program_state = PROGRAM_STATE_ACTIVE
				active_program = P
				P.alert_pending = FALSE
				idle_threads.Remove(P)
				update_icon()
				return

			var/obj/item/computer_hardware/processor_unit/PU = all_components[MC_CPU]

			if(idle_threads.len > PU.max_idle_programs)
				to_chat(user, "<span class='danger'>\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error.</span>")
				return

			if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
				to_chat(user, "<span class='danger'>\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning.</span>")
				return
			if(P.run_program(user))
				active_program = P
				P.alert_pending = FALSE
				update_icon()
			return 1

		if("PC_toggle_light")
			return toggle_flashlight()

		if("PC_light_color")
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color)
					return
				if(color_hex2num(new_color) < 200) //Colors too dark are rejected
					to_chat(user, "<span class='warning'>That color is too dark! Choose a lighter one.</span>")
					new_color = null
			return set_flashlight_color(new_color)

		if("PC_Eject_Disk")
			var/param = params["name"]
			var/mob/user = usr
			switch(param)
				if("removable storage disk")
					var/obj/item/computer_hardware/hard_drive/portable/portable_drive = all_components[MC_SDD]
					if(!portable_drive)
						return
					if(uninstall_component(portable_drive, usr))
						user.put_in_hands(portable_drive)
						playsound(src, 'sound/machines/card_slide.ogg', 50)
				if("intelliCard")
					var/obj/item/computer_hardware/ai_slot/intelliholder = all_components[MC_AI]
					if(!intelliholder)
						return
					if(intelliholder.try_eject(user))
						playsound(src, 'sound/machines/card_slide.ogg', 50)
				if("ID")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
					if(!cardholder)
						return
					cardholder.try_eject(user)
				if("secondary RFID card")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD2]
					if(!cardholder)
						return
					cardholder.try_eject(user)


		else
			return

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	return src
