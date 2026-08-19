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
		active_threads.Cut()
		active_threads.Add(program)
	program.on_made_active_program(user)

/datum/operating_system/default/ntos/mobile/interact(mob/user)
	ui_interact(user)

/datum/operating_system/default/ntos/mobile/ui_close(mob/user)
	. = ..()
	var/datum/computer_file/program/active_program = get_active_thread(1)
	active_program?.ui_close(user)

/datum/operating_system/default/ntos/mobile/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosMobile")
		ui.open()
		ui.set_autoupdate(FALSE)
	update_static_data_for_all_viewers()
