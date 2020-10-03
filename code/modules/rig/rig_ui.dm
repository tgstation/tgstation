/obj/item/rig/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RIG", name)
		ui.open()

/obj/item/rig/control/ui_data()
	var/data = list()
	data["materials"] = list()

	return data

/obj/item/rig/control/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
