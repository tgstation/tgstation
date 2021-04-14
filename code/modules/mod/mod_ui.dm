/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit", name)
		ui.open()

/obj/item/mod/control/ui_data()
	var/data = list()
	data["ui_theme"] = theme.ui_theme
	data["interface_break"] = interface_break
	data["malfunctioning"] = malfunctioning
	data["open"] = open
	data["active"] = active
	data["locked"] = locked
	data["complexity"] = complexity
	data["complexity_max"] = complexity_max
	data["selected_module"] = selected_module?.name
	data["wearer_name"] = wearer ? wearer.get_authentification_name("Unknown") : "No Occupant"
	data["wearer_job"] = wearer ? wearer.get_assignment("Unknown","Unknown",FALSE) : "No Job"
	data["ai"] = AI?.name
	data["cell"] = cell?.name
	data["charge"] = cell ? round(cell.percent(), 1) : 0
	data["helmet"] = helmet?.name
	data["chestplate"] = chestplate?.name
	data["gauntlets"] = gauntlets?.name
	data["boots"] = boots?.name
	data["modules"] = list()
	for(var/obj/item/mod/module/module in modules)
		var/list/module_data = list(
			name = module.name,
			description = module.desc,
			module_type = module.module_type,
			active = module.active,
			idle_power = module.idle_power_cost,
			active_power = module.active_power_cost,
			use_power = module.use_power_cost,
			module_complexity = module.complexity,
			id = module.tgui_id,
			ref = REF(module)
		)
		data["modules"] += list(module_data)
	//now we add all the data for different info modules
	data["radcount"] = wearer ? wearer.radiation : 0
	return data

/obj/item/mod/control/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!allowed(usr) && locked)
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("lock")
			locked = !locked
			to_chat(usr, "<span class='notice'>The suit has been [locked ? "unlocked" : "locked"].</span>")
		if("activate")
			toggle_activate(usr)
		if("select")
			var/obj/item/mod/module/thingy = locate(params["ref"]) in modules
			thingy.on_select()
	return TRUE
