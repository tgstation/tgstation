/// The controller for the ui in charge of all runtime greyscale configuration/debug.
/// If `Unlock()` is not called the menu is safe for players to use.
/datum/greyscale_modify_menu
	/// The "owner" object of this menu, is usually the greyscale object being edited but that can be changed for specific uses of this menu
	var/atom/target
	/// The client that opened this menu
	var/client/user

	/// A keyed list of allowed configs in the form niceName:typepath
	var/list/allowed_configs

	/// A callback to control what happens when the user presses apply. Used mainly for if you want the menu to be used outside of vv.
	var/datum/callback/apply_callback

	/// The current config being previewed
	var/datum/greyscale_config/config
	/// A list of colors currently selected
	var/list/split_colors

	/// Collection of data for tgui to use in displaying everything
	var/list/sprite_data
	/// The sprite dir currently being shown
	var/sprite_dir = SOUTH
	/// The sprite icon state currently being shown
	var/icon_state
	/// Whether the full preview should be generated, with this FALSE only the final sprite is shown instead of all steps.
	var/generate_full_preview = FALSE

	/// Whether the menu is in the middle of refreshing the preview
	var/refreshing = TRUE

	/// Whether the menu is currently locked down to prevent abuse from players. Currently is only unlocked when opened from vv.
	var/unlocked = FALSE

/datum/greyscale_modify_menu/New(atom/target, client/user, list/allowed_configs, datum/callback/apply_callback, starting_icon_state="", starting_config, starting_colors)
	src.target = target
	src.user = user
	src.apply_callback = apply_callback || CALLBACK(src, .proc/DefaultApply)
	icon_state = starting_icon_state

	var/current_config = "[starting_config]" || "[target?.greyscale_config]"
	config = SSgreyscale.configurations[current_config]
	if(!(current_config in allowed_configs))
		config = SSgreyscale.configurations["[allowed_configs[pick(allowed_configs)]]"]

	var/list/config_choices = list()
	for(var/config_string in allowed_configs)
		var/datum/greyscale_config/config = text2path("[config_string]")
		config_choices[initial(config.name)] = config_string
	src.allowed_configs = config_choices

	ReadColorsFromString(starting_colors || target?.greyscale_colors)

	if(target)
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
	data["greyscale_config"] = "[config.name]"

	var/list/color_data = list()
	data["colors"] = color_data
	for(var/i in 1 to config.expected_colors)
		color_data += list(list(
			"index" = i,
			"value" = split_colors[i]
		))

	data["generate_full_preview"] = generate_full_preview
	data["unlocked"] = unlocked
	data["refreshing"] = refreshing
	data["sprites_dir"] = dir2text(sprite_dir)
	data["icon_state"] = icon_state
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
			new_config = allowed_configs[new_config]
			new_config = SSgreyscale.configurations[new_config] || new_config
			if(!isnull(new_config) && config != new_config)
				config = new_config
				queue_refresh()

		if("load_config_from_string")
			if(!(params["config_string"] in allowed_configs))
				return
			var/datum/greyscale_config/new_config = SSgreyscale.configurations[params["config_string"]]
			if(!isnull(new_config) && config != new_config)
				config = new_config
				queue_refresh()

		if("toggle_full_preview")
			if(!generate_full_preview && !unlocked)
				return
			generate_full_preview = !generate_full_preview
			queue_refresh()

		if("recolor")
			var/index = text2num(params["color_index"])
			split_colors[index] = lowertext(params["new_color"])
			queue_refresh()

		if("recolor_from_string")
			ReadColorsFromString(lowertext(params["color_string"]))
			queue_refresh()

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
				queue_refresh()

		if("select_icon_state")
			var/new_icon_state = params["new_icon_state"]
			if(!config.icon_states[new_icon_state])
				return
			icon_state = new_icon_state
			queue_refresh()

		if("apply")
			apply_callback.Invoke(src)

		if("refresh_file")
			if(!unlocked)
				return
			if(length(GLOB.player_list) > 1)
				var/check = alert(
					user,
{"Other players are connected to the server, are you sure you want to refresh all greyscale configurations?\n
This is highly likely to cause a lag spike for a few seconds."},
					"Refresh Greyscale Configurations",
					"Yes",
					"Cancel"
				)
				if(check != "Yes")
					return
			SSgreyscale.RefreshConfigsFromFile()
			queue_refresh()

		if("change_dir")
			sprite_dir = text2dir(params["new_sprite_dir"])
			queue_refresh()

/datum/greyscale_modify_menu/proc/ReadColorsFromString(colorString)
	var/list/raw_colors = splittext(colorString, "#")
	split_colors = list()
	for(var/i in 2 to length(raw_colors))
		split_colors += "#[raw_colors[i]]"

/datum/greyscale_modify_menu/proc/queue_refresh()
	refreshing = TRUE
	addtimer(CALLBACK(src, .proc/refresh_preview), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/greyscale_modify_menu/proc/refresh_preview()
	for(var/i in length(split_colors) + 1 to config.expected_colors)
		split_colors += rgb(100, 100, 100)
	var/list/used_colors = split_colors.Copy(1, config.expected_colors+1)

	sprite_data = list()

	var/list/generated_icon_states = list()
	for(var/state in config.icon_states)
		generated_icon_states += state // We don't want the values from this keyed list
	sprite_data["icon_states"] = generated_icon_states

	if(!(icon_state in generated_icon_states))
		icon_state = target.icon_state
		if(!(icon_state in generated_icon_states))
			icon_state = pick(generated_icon_states)

	var/image/finished
	if(!generate_full_preview)
		finished = image(config.GenerateBundle(used_colors), icon_state=icon_state)
	else
		var/list/data = config.GenerateDebug(used_colors.Join())
		finished = image(data["icon"], icon_state=icon_state)
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
	refreshing = FALSE

/datum/greyscale_modify_menu/proc/Unlock()
	allowed_configs = SSgreyscale.configurations
	unlocked = TRUE

/datum/greyscale_modify_menu/proc/DefaultApply()
	target.set_greyscale(split_colors, config.type)
