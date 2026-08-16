/datum/operating_system/default/ntos/desktop
	name = "NTOS Desktop"
	description = "A streamlined version of NTOS designed for desktop modular computers."
	max_idle_programs = 2
	device_theme = PDA_THEME_NTOS

/datum/operating_system/default/ntos/desktop/install(mob/user)
	. = ..()

/datum/operating_system/default/ntos/desktop/activate_program(mob/user, datum/computer_file/program/program)
	..()
	if(!program)
		return

	active_threads.Add(program)
	program.on_made_active_program(user)

/datum/operating_system/default/ntos/desktop/run_program(mob/user, datum/computer_file/program/program, open_ui = TRUE)
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
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/default/ntos/desktop, interact), user)
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
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/default/ntos/desktop, interact), user)
	hardware.update_appearance(UPDATE_ICON)
	return TRUE

/datum/operating_system/default/ntos/desktop/kill_program(datum/computer_file/program/program)
	..()
	var/mob/user = usr
	program.on_kill(user)
	if(program in active_threads)
		active_threads.Remove(program)
		if(!QDELETED(hardware) && hardware.enabled && user)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/operating_system/default/ntos/desktop, interact), user)
	else if(program in idle_threads)
		idle_threads.Remove(program)
	else
		return FALSE

	if(program.program_flags & PROGRAM_REQUIRES_NTNET)
		var/obj/item/card/id/ID = hardware.stored_id?.GetID()
		program.generate_network_log("Connection closed -- Program ID: [program.filename] User:[ID ? "[ID.registered_name]" : "None"]")

	hardware.update_appearance(UPDATE_ICON)
	SEND_SIGNAL(program, COMSIG_COMPUTER_PROGRAM_KILL, user)

/datum/operating_system/default/ntos/desktop/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosDesktop")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/operating_system/default/ntos/desktop/interact(mob/user)
	ui_interact(user)
