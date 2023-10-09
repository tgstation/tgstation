/client
	var/datum/ui_module/basic_offsets/offset_editor

/datum/ui_module/basic_offsets
	var/mob/living/basic/target

/datum/ui_module/basic_offsets/proc/open_ui(mob/user, mob/living/basic/_target)
	if(!_target)
		return
	target = _target
	ui_interact(user)

/datum/ui_module/basic_offsets/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BasicOffsetEditor", "Offset Editor")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/basic_offsets/ui_data(mob/user)
	var/list/data = list()

	var/list/offsets = list()

	offsets += list(list(
		"name" = "Right X Offset",
		"north" = target.r_x_shift[1],
		"south" = target.r_x_shift[2],
		"east" = target.r_x_shift[3],
		"west" = target.r_x_shift[4],
	))

	offsets += list(list(
		"name" = "Left X Offset",
		"north" = target.l_x_shift[1],
		"south" = target.l_x_shift[2],
		"east" = target.l_x_shift[3],
		"west" = target.l_x_shift[4],
	))

	offsets += list(list(
		"name" = "Right Y Offset",
		"north" = target.r_y_shift[1],
		"south" = target.r_y_shift[2],
		"east" = target.r_y_shift[3],
		"west" = target.r_y_shift[4],
	))

	offsets += list(list(
		"name" = "Left Y Offset",
		"north" = target.l_y_shift[1],
		"south" = target.l_y_shift[2],
		"east" = target.l_y_shift[3],
		"west" = target.l_y_shift[4],
	))

	offsets += list(list(
		"name" = "Head Y Offset",
		"north" = target.head_y_shift[1],
		"south" = target.head_y_shift[2],
		"east" = target.head_y_shift[3],
		"west" = target.head_y_shift[4],
	))

	offsets += list(list(
		"name" = "Head X Offset",
		"north" = target.head_x_shift[1],
		"south" = target.head_x_shift[2],
		"east" = target.head_x_shift[3],
		"west" = target.head_x_shift[4],
	))

	data["offsets"] = offsets

	return data

/datum/ui_module/basic_offsets/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("offset")
			var/value = text2num(params["offset"])
			var/dir_to_number
			switch(params["direction"])
				if("north")
					dir_to_number = 1
				if("south")
					dir_to_number = 2
				if("east")
					dir_to_number = 3
				if("west")
					dir_to_number = 4
			switch(params["name"])
				if("Head X Offset")
					target.head_x_shift[dir_to_number] = value
				if("Right X Offset")
					target.r_x_shift[dir_to_number] = value
				if("Left X Offset")
					target.l_x_shift[dir_to_number] = value
				if("Head Y Offset")
					target.head_y_shift[dir_to_number] = value
				if("Right Y Offset")
					target.r_y_shift[dir_to_number] = value
				if("Left Y Offset")
					target.l_y_shift[dir_to_number] = value
			target.regenerate_icons()
		else
			return FALSE

/datum/ui_module/basic_offsets/ui_state()
	return GLOB.always_state
