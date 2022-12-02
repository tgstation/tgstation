// Operates TGUI
/datum/modular_computer_host/ui_interact(mob/user, datum/tgui/ui)
	if(!powered_on)
		if(ui)
			ui.close()
		return
	if(!use_power())
		if(ui)
			ui.close()
		return

	if(!user.can_read(src, READING_CHECK_LITERACY))
		return

	// TODO
/*	if(ishuman(user) && !allow_chunky)
		var/mob/living/carbon/human/human_user = user
		if(human_user.check_chunky_fingers())
			physical.balloon_alert(human_user, "fingers are too big!")
			return*/

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!powered_on && !issilicon(user))
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

/datum/modular_computer_host/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()

	data["show_imprint"] = istype(src, /obj/item/modular_computer/pda)

	return data

/datum/modular_computer_host/ui_data(mob/user)
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
	data["light_on"] = physical.light_on
	data["comp_light_color"] = comp_light_color
	data["pai"] = inserted_pai
	return data


// Handles user's GUI input
/datum/modular_computer_host/ui_act(action, params)
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
			//return toggle_flashlight()

		if("PC_light_color")
			/*var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color)
					return
				if(is_color_dark(new_color, 50) ) //Colors too dark are rejected
					to_chat(user, span_warning("That color is too dark! Choose a lighter one."))
					new_color = null
			return set_flashlight_color(new_color)*/

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
					if(remove_card())
						playsound(src, 'sound/machines/card_slide.ogg', 50)
						return TRUE

		if("PC_Imprint_ID")
			saved_identification = computer_id_slot.registered_name
			saved_job = computer_id_slot.assignment
			//UpdateDisplay()
			playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)

		if("PC_Pai_Interact")
			switch(params["option"])
				if("eject")
					usr.put_in_hands(inserted_pai)
					to_chat(usr, span_notice("You remove [inserted_pai] from the [physical.name]."))
					inserted_pai = null
				if("interact")
					inserted_pai.attack_self(usr)
			return UI_UPDATE
		else
			return

/datum/modular_computer_host/ui_host()
	return physical


///Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/datum/modular_computer_host/proc/get_header_data()
	var/list/data = list()

	data["PC_device_theme"] = device_theme
	data["PC_showbatteryicon"] = !!internal_cell

	if(internal_cell)
		switch(internal_cell.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(internal_cell.percent())]%"
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"

	switch(get_ntnet_status())
		if(NTNET_NO_SIGNAL)
			data["PC_ntneticon"] = "sig_none.gif"
		if(NTNET_LOW_SIGNAL)
			data["PC_ntneticon"] = "sig_low.gif"
		if(NTNET_GOOD_SIGNAL)
			data["PC_ntneticon"] = "sig_high.gif"
		if(NTNET_ETHERNET_SIGNAL)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(length(idle_threads))
		var/list/program_headers = list()
		for(var/datum/computer_file/program/idle_programs as anything in idle_threads)
			if(!idle_programs.ui_header)
				continue
			program_headers.Add(list(list("icon" = idle_programs.ui_header)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = station_time_timestamp()
	data["PC_stationdate"] = "[time2text(world.realtime, "DDD, Month DD")], [CURRENT_STATION_YEAR]"
	data["PC_showexitprogram"] = !!active_program // Hides "Exit Program" button on mainscreen
	return data
