/obj/structure/shipping_container/MouseDrop_T(obj/structure/closet/crate/dropping, mob/user, params)
	. = ..()
	if(!istype(dropping))
		return
	if(!do_after(user, 3 SECONDS, dropping))
		return
	dropping.forceMove(src)
	balloon_alert_to_viewers("crate loaded")

/obj/structure/shipping_container/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShippingContainer", name)
		ui.open()

/obj/structure/shipping_container/ui_data(mob/user)
	var/list/data = list()
	data["crates"] = list()
	for(var/obj/structure/closet/crate/crates as anything in contents)
		var/list/crate_data = list(
			name = crates.name,
			ref = REF(crates)
		)
		data["crates"] += list(crate_data)
	return data

/obj/structure/shipping_container/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/structure/closet/crate/crate = locate(params["ref"]) in contents
	if(!istype(crate) || crate.loc != src)
		return

	switch(action)
		if("remove")
			crate.forceMove(usr.loc) //drop it at the user because otherwise the container will hide it
			return TRUE
