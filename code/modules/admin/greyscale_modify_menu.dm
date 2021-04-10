/datum/greyscale_modify_menu
	var/atom/target
	var/client/user

	var/list/split_colors

	var/list/sprite_data

/datum/greyscale_modify_menu/New(atom/target, client/user)
	src.target = target
	src.user = user

	ReadColorsFromString(target.greyscale_colors)

	refresh_preview()

	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/ui_close)

/datum/greyscale_modify_menu/Destroy()
	target = null
	user = null
	return ..()

/datum/greyscale_modify_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/greyscale_modify_menu/ui_close()
	qdel(src)

/datum/greyscale_modify_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GreyscaleModifyMenu")
		ui.open()

/datum/greyscale_modify_menu/ui_data(mob/user)
	var/list/data = list()
	var/list/color_data = list()
	data["colors"] = color_data
	for(var/i in 1 to length(split_colors))
		color_data += list(list(
			"index" = i,
			"value" = split_colors[i]
		))

	data["sprites"] = sprite_data
	return data

/datum/greyscale_modify_menu/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("recolor")
			var/index = text2num(params["color_index"])
			split_colors[index] = lowertext(params["new_color"])
			refresh_preview()
		if("recolor_from_string")
			ReadColorsFromString(lowertext(params["color_string"]))
			refresh_preview()
		if("pick_color")
			var/group = params["color_index"]
			var/new_color = input(
				usr,
				"Choose color for greyscale color group [group]:",
				"Greyscale Modification Menu",
				split_colors[group]
			) as color|null
			if(new_color)
				split_colors[group] = new_color
				refresh_preview()
		if("apply")
			target.greyscale_colors = split_colors.Join()
			target.update_appearance()
		if("refresh_file")
			SSgreyscale.RefreshConfigsFromFile()
			refresh_preview()

/datum/greyscale_modify_menu/proc/ReadColorsFromString(colorString)
	var/list/raw_colors = splittext(colorString, "#")
	split_colors = list()
	for(var/i in 2 to length(raw_colors))
		split_colors += "#[raw_colors[i]]"

/datum/greyscale_modify_menu/proc/refresh_preview()
	var/list/data = SSgreyscale.configurations["[target.greyscale_config]"].GenerateDebug(split_colors)

	sprite_data = list()
	var/list/steps = list()
	sprite_data["steps"] = steps
	for(var/step in data["steps"])
		steps += list(list("layer"=icon2html(data["steps"][step], user, sourceonly=TRUE), "result"=icon2html(step, user, sourceonly=TRUE)))
