/datum/greyscale_modify_menu
	var/atom/target
	var/client/user

	var/list/allowed_configs

	var/datum/callback/apply_callback

	var/datum/greyscale_config/config
	var/list/split_colors

	var/list/sprite_data
	var/sprite_dir = SOUTH
	var/generate_full_preview = FALSE

	var/unlocked = FALSE

/datum/greyscale_modify_menu/New(atom/target, client/user, list/allowed_configs, datum/callback/apply_callback)
	src.target = target
	src.user = user
	src.allowed_configs = allowed_configs
	src.apply_callback = apply_callback || CALLBACK(src, .proc/DefaultApply)

	var/current_config = "[target?.greyscale_config]"
	config = SSgreyscale.configurations[current_config]
	if(!(current_config in allowed_configs))
		config = SSgreyscale.configurations["[pick(allowed_configs)]"]

	if(target)
		ReadColorsFromString(target.greyscale_colors)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/ui_close)

	refresh_preview()

/datum/greyscale_modify_menu/Destroy()
	target = null
	user = null
	return ..()

/datum/greyscale_modify_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/greyscale_modify_menu/ui_close()
	qdel(src)

/datum/greyscale_modify_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GreyscaleModifyMenu")
		ui.open()

/datum/greyscale_modify_menu/ui_data(mob/user)
	var/list/data = list()
	data["greyscale_config"] = "[config.type]"

	var/list/color_data = list()
	data["colors"] = color_data
	for(var/i in 1 to config.expected_colors)
		color_data += list(list(
			"index" = i,
			"value" = split_colors[i]
		))

	data["generate_full_preview"] = generate_full_preview
	data["full_preview_allowed"] = unlocked
	data["sprites_dir"] = dir2text(sprite_dir)
	data["sprites"] = sprite_data
	return data

/datum/greyscale_modify_menu/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select_config")
			var/datum/greyscale_config/new_config = input(
				usr,
				"Choose a new greyscale configuration to use",
				"Greyscale Modification Menu",
				"[config.type]"
			) as anything in allowed_configs
			new_config = SSgreyscale.configurations[new_config]
			if(!isnull(new_config) && config != new_config)
				config = new_config
				refresh_preview()

		if("load_config_from_string")
			if(!(params["config_string"] in allowed_configs))
				return
			var/datum/greyscale_config/new_config = SSgreyscale.configurations[params["config_string"]]
			if(!isnull(new_config) && config != new_config)
				config = new_config
				refresh_preview()

		if("toggle_full_preview")
			if(!generate_full_preview && !unlocked)
				return
			generate_full_preview = !generate_full_preview
			refresh_preview()

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
			apply_callback.Invoke(src)

		if("refresh_file")
			if(!unlocked)
				return
			if(length(GLOB.player_list) > 1)
				var/check = alert(
					user,
					{"Other players are connected to the server, are you sure you want to refresh all greyscale configurations?
					This is highly likely to cause a lag spike for a few seconds."},
					"Refresh Greyscale Configurations",
					"Yes",
					"Cancel"
				)
				if(check != "Yes")
					return
			SSgreyscale.RefreshConfigsFromFile()
			refresh_preview()

		if("change_dir")
			sprite_dir = text2dir(params["new_sprite_dir"])
			refresh_preview()

/datum/greyscale_modify_menu/proc/ReadColorsFromString(colorString)
	var/list/raw_colors = splittext(colorString, "#")
	split_colors = list()
	for(var/i in 2 to length(raw_colors))
		split_colors += "#[raw_colors[i]]"

/datum/greyscale_modify_menu/proc/refresh_preview()
	for(var/i in length(split_colors) + 1 to config.expected_colors)
		split_colors += rgb(100, 100, 100)
	var/list/used_colors = split_colors.Copy(1, config.expected_colors+1)

	sprite_data = list()
	var/image/finished
	if(!generate_full_preview)
		finished = config.Generate(used_colors.Join())
	else
		var/list/data = config.GenerateDebug(used_colors.Join())
		finished = image(data["icon"])
		var/list/steps = list()
		sprite_data["steps"] = steps
		for(var/step in data["steps"])
			CHECK_TICK
			var/image/layer = image(data["steps"][step])
			var/image/result = image(step)
			steps += list(
				list(
					"layer"=icon2html(layer, user, dir=sprite_dir, sourceonly=TRUE),
					"result"=icon2html(result, user, dir=sprite_dir, sourceonly=TRUE)
				)
			)
	sprite_data["finished"] = icon2html(finished, user, dir=sprite_dir, sourceonly=TRUE)

/datum/greyscale_modify_menu/proc/Unlock()
	allowed_configs = SSgreyscale.configurations
	unlocked = TRUE

/datum/greyscale_modify_menu/proc/DefaultApply()
	target.set_greyscale_config(config.type, update=FALSE)
	target.greyscale_colors = "" // We do this to force an update, in some cases it will think nothing changed when it should be refreshing
	target.set_greyscale_colors(split_colors)
