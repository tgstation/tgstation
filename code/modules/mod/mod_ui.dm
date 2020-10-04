/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODSuit", name)
		ui.open()

/obj/item/mod/control/ui_data()
	var/data = list()
	data["interface_break"] = interface_break
	data["malfuction"] = malfunctioning
	data["open"] = open
	data["active"] = active
	data["locked"] = locked
	data["wearer_name"] = wearer ? wearer.get_id_name("Unknown") : "None"
	data["wearer_job"] = wearer ? wearer.get_assignment("Unknown","Unknown",FALSE) : "None"
	data["ai"] = AI
	data["cell"] = cell
	data["charge"] = cell ? round(cell.percent(), 1) : 0
	data["modules"] = LAZYLEN(modules) ? modules : null

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
