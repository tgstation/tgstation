// Operates TGUI
/obj/item/device/modular_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	if(!enabled)
		if(ui)
			ui.close()
		return 0
	if(!use_power())
		if(ui)
			ui.close()
		return 0

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!screen_on && !issilicon(user))
		if(ui)
			ui.close()
		return 0

	// If we have an active program switch to it now.
	if(active_program)
		if(ui) // This is the main laptop screen. Since we are switching to program's UI close it for now.
			ui.close()
		active_program.ui_interact(user)
		return

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		user << "<span class='danger'>\The [src] beeps three times, it's screen displaying a \"DISK ERROR\" warning.</span>"
		return // No HDD, No HDD files list or no stored files. Something is very broken.

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)

		ui = new(user, src, ui_key, "computer_main", "NTOS Main menu", 400, 500, master_ui, state)
		ui.open()
		ui.set_autoupdate(state = 1)


/obj/item/device/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	data["programs"] = list()
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	for(var/datum/computer_file/program/P in hard_drive.stored_files)
		var/running = 0
		if(P in idle_threads)
			running = 1

		data["programs"] += list(list("name" = P.filename, "desc" = P.filedesc, "running" = running))

	return data


// Handles user's GUI input
/obj/item/device/modular_computer/ui_act(action, params)
	if(..())
		return
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	switch(action)
		if("PC_exit")
			kill_program()
			return 1
		if("PC_shutdown")
			shutdown_computer()
			return 1
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
			user << "<span class='notice'>Program [P.filename].[P.filetype] with PID [rand(100,999)] has been killed.</span>"

		if("PC_runprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			if(hard_drive)
				P = hard_drive.find_file_by_name(prog)

			if(!P || !istype(P)) // Program not found or it's not executable program.
				user << "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning.</span>"
				return

			P.computer = src

			if(!P.is_supported_by_hardware(hardware_flag, 1, user))
				return

			// The program is already running. Resume it.
			if(P in idle_threads)
				P.program_state = PROGRAM_STATE_ACTIVE
				active_program = P
				idle_threads.Remove(P)
				update_icon()
				return

			var/obj/item/weapon/computer_hardware/processor_unit/PU = all_components[MC_CPU]

			if(idle_threads.len > PU.max_idle_programs)
				user << "<span class='danger'>\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error.</span>"
				return

			if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
				user << "<span class='danger'>\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning.</span>"
				return
			if(P.run_program(user))
				active_program = P
				update_icon()
			return 1
		else
			return

/obj/item/device/modular_computer/ui_host()
	if(physical)
		return physical
	return src
