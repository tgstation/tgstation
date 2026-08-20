/datum/operating_system/default/ntos/desktop
	name = "NTOS Desktop"
	description = "A streamlined version of NTOS designed for desktop modular computers."
	max_idle_programs = 2
	device_theme = PDA_THEME_NTOS

	var/alist/programs_metadata = alist()

/datum/operating_system/default/ntos/desktop/install(mob/user)
	. = ..()

/datum/operating_system/default/ntos/desktop/activate_program(mob/user, datum/computer_file/program/program)
	..()
	if(!program)
		return

	active_threads.Add(program)
	programs_metadata[program.filename] = list("x" = 10, "y" = 10, "width" = 575, "height" = 400)
	program.on_made_active_program(user)
	update_static_data_for_all_viewers()

/datum/operating_system/default/ntos/desktop/ui_data(mob/user)
	. = ..()
	for(var/list/program in .["programs"])
		program["metadata"] = programs_metadata[program["name"]]

/datum/operating_system/default/ntos/desktop/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PC_move_window")
			var/x = clamp(params["x"], 0, 1200)
			var/y = clamp(params["y"], 0, 800)
			var/name = params["name"]
			if(!name)
				return FALSE
			programs_metadata[name]["x"] = x
			programs_metadata[name]["y"] = y
		if("PC_resize_window")
			var/width = clamp(params["width"], 100, 1200)
			var/height = clamp(params["height"], 100, 800)
			var/name = params["name"]
			if(!name)
				return FALSE
			programs_metadata[name]["width"] = width
			programs_metadata[name]["height"] = height


/datum/operating_system/default/ntos/desktop/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosDesktop")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/operating_system/default/ntos/desktop/interact(mob/user)
	ui_interact(user)
