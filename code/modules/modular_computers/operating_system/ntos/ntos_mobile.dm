/datum/operating_system/default/ntos/mobile
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

/datum/operating_system/default/ntos/mobile/install(mob/user)
	..()
	for(var/programs in pda_programs)
		var/datum/computer_file/program_type = new programs
		store_file(program_type)

/datum/operating_system/default/ntos/mobile/activate_program(mob/user, datum/computer_file/program/program)
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

/datum/operating_system/default/ntos/mobile/run_program(mob/user, datum/computer_file/program/program, open_ui = TRUE)
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
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/default/ntos/mobile, interact), user)
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
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/default/ntos/mobile, interact), user)
	hardware.update_appearance(UPDATE_ICON)
	return TRUE

/datum/operating_system/default/ntos/mobile/kill_program(datum/computer_file/program/program)
	..()
	var/mob/user = usr
	program.on_kill(user)
	if(program == get_active_thread(1))
		active_threads[1] = null
		if(!QDELETED(hardware) && hardware.enabled && user)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/default/ntos/mobile, interact), user)
	else if(program in idle_threads)
		idle_threads.Remove(program)
	else
		return FALSE

	if(program.program_flags & PROGRAM_REQUIRES_NTNET)
		var/obj/item/card/id/ID = hardware.stored_id?.GetID()
		program.generate_network_log("Connection closed -- Program ID: [program.filename] User:[ID ? "[ID.registered_name]" : "None"]")

	hardware.update_appearance(UPDATE_ICON)
	SEND_SIGNAL(program, COMSIG_COMPUTER_PROGRAM_KILL, user)

/datum/operating_system/default/ntos/mobile/interact(mob/user)
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

/datum/operating_system/default/ntos/mobile/ui_close(mob/user)
	. = ..()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	active_program?.ui_close(user)

/datum/operating_system/default/ntos/mobile/ui_close(mob/user)
	. = ..()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	active_program?.ui_close(user)

// Operates TGUI
/datum/operating_system/default/ntos/mobile/ui_interact(mob/user, datum/tgui/ui)
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
		interact(user)
	else if(active_program?.always_update_ui)
		active_program.ui_interact(user, ui)
