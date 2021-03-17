/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit", name)
		ui.open()

/obj/item/mod/control/ui_data()
	var/data = list()
	data["interface_break"] = interface_break
	data["malfunctioning"] = malfunctioning
	data["open"] = open
	data["active"] = active
	data["locked"] = locked
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
	for(var/obj/item/mod/module/thingy in modules)
		var/list/module_data = list(
			name = thingy.name,
			description = thingy.desc,
			selectable = thingy.selectable,
			active = thingy.active,
			idle_power = thingy.idle_power_use,
			active_power = thingy.active_power_use,
			ref = REF(thingy)
		)
		data["modules"] += list(module_data)

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
		if("update_access")
			update_access()
		if("activate")
			toggle_activate(usr)
		if("select")
			var/obj/item/mod/module/thingy = locate(params["ref"]) in modules
			thingy.active = !thingy.active
			if(thingy.selectable == MOD_USABLE && thingy.active)
				selected_module.active = FALSE
				selected_module = thingy
	return TRUE
