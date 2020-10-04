/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MOD", name)
		ui.open()

/obj/item/mod/control/ui_data()
	var/data = list()
	data["materials"] = list()

	return data

/obj/item/mod/control/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("h")
			locked = !locked
			to_chat(wearer, "<span class='notice'>The suit has been [locked ? "unlocked" : "locked"].</span>")
