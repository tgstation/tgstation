/obj/item/electronics/airlock
	name = "airlock electronics"
	req_access = list(ACCESS_MAINT_TUNNELS)
	/// A list of all granted accesses
	var/list/accesses = list()
	/// If the airlock should require ALL or only ONE of the listed accesses
	var/one_access = 0
	/// Unrestricted sides, or sides of the airlock that will open regardless of access
	var/unres_sides = 0
	/// A holder of the electronics, in case of them working as an integrated part
	var/holder

/obj/item/electronics/airlock/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Has a neat <i>selection menu</i> for modifying airlock access levels.</span>"

/obj/item/electronics/airlock/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/electronics/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics", name)
		ui.open()

/obj/item/electronics/airlock/ui_static_data(mob/user)
	var/list/data = list()

	var/list/regions = list()
	var/list/tgui_region_data = SSid_access.all_region_access_tgui
	for(var/region in SSid_access.station_regions)
		regions += tgui_region_data[region]

	data["regions"] = regions
	return data

/obj/item/electronics/airlock/ui_data()
	var/list/data = list()
	data["accesses"] = accesses
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides
	return data

/obj/item/electronics/airlock/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
			. = TRUE
		if("grant_all")
			accesses = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
			. = TRUE
		if("one_access")
			one_access = !one_access
			. = TRUE
		if("set")
			var/access = text2num(params["access"])
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
			. = TRUE
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
			. = TRUE
		if("grant_region")
			var/region = params["region"]
			if(isnull(region))
				return
			accesses |= SSid_access.get_region_access_list(list(region))
			. = TRUE
		if("deny_region")
			var/region = params["region"]
			if(isnull(region))
				return
			accesses -= SSid_access.get_region_access_list(list(region))
			. = TRUE

/obj/item/electronics/airlock/ui_host()
	if(holder)
		return holder
	return src
