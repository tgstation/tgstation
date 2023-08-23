/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit", name)
		ui.open()

/obj/item/mod/control/ui_data(mob/user)
	var/data = list()
	// Suit information
	var/suit_status = list(
		"core_name" = core?.name,
		"cell_charge_current" = get_charge(),
		"cell_charge_max" = get_max_charge(),
		"active" = active,
		"ai_name" = ai_assistant?.name,
		"has_pai" = ispAI(ai_assistant),
		"is_ai" = ai_assistant && ai_assistant == user,
		"link_id" = mod_link.id,
		"link_call" = mod_link.get_other()?.id,
		// Wires
		"open" = open,
		"seconds_electrified" = seconds_electrified,
		"malfunctioning" = malfunctioning,
		"locked" = locked,
		"interface_break" = interface_break,
		// Modules
		"complexity" = complexity,
	)
	data["suit_status"] = suit_status
	// User information
	var/user_status = list(
		"user_name" = wearer ? (wearer.get_authentification_name("Unknown") || "Unknown") : "",
		"user_assignment" = wearer ? wearer.get_assignment("Unknown", "Unknown", FALSE) : "",
	)
	data["user_status"] = user_status
	// Module information
	var/module_custom_status = list()
	var/module_info = list()
	for(var/obj/item/mod/module/module as anything in modules)
		module_custom_status += module.add_ui_data()
		module_info += list(list(
			"module_name" = module.name,
			"description" = module.desc,
			"module_type" = module.module_type,
			"module_active" = module.active,
			"pinned" = module.pinned_to[REF(user)],
			"idle_power" = module.idle_power_cost,
			"active_power" = module.active_power_cost,
			"use_power" = module.use_power_cost,
			"module_complexity" = module.complexity,
			"cooldown_time" = module.cooldown_time,
			"cooldown" = round(COOLDOWN_TIMELEFT(module, cooldown_timer), 1 SECONDS),
			"id" = module.tgui_id,
			"ref" = REF(module),
			"configuration_data" = module.get_configuration()
		))
	data["module_custom_status"] = module_custom_status
	data["module_info"] = module_info
	return data

/obj/item/mod/control/ui_static_data(mob/user)
	var/data = list()
	data["ui_theme"] = ui_theme
	data["control"] = name
	data["complexity_max"] = complexity_max
	data["helmet"] = helmet?.name
	data["chestplate"] = chestplate?.name
	data["gauntlets"] = gauntlets?.name
	data["boots"] = boots?.name
	return data

/obj/item/mod/control/ui_state(mob/user)
	if(user == ai_assistant)
		return GLOB.contained_state
	return ..()

/obj/item/mod/control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(malfunctioning && prob(75))
		balloon_alert(usr, "button malfunctions!")
		return
	switch(action)
		if("lock")
			locked = !locked
			balloon_alert(usr, "[locked ? "locked" : "unlocked"]!")
		if("call")
			if(!mod_link.link_call)
				call_link(usr, mod_link)
			else
				mod_link.end_call()
		if("activate")
			toggle_activate(usr)
		if("select")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			if(!module)
				return
			module.on_select()
		if("configure")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			if(!module)
				return
			module.configure_edit(params["key"], params["value"])
		if("pin")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			if(!module)
				return
			module.pin(usr)
		if("eject_pai")
			if (!ishuman(usr))
				return
			remove_pai(usr)
	return TRUE
