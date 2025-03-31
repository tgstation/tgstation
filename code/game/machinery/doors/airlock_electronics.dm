/obj/item/electronics/airlock
	name = "airlock electronics"
	req_access = list(ACCESS_MAINT_TUNNELS)
	/// A list of all granted accesses
	var/list/accesses = list()
	/// If the airlock should require ALL or only ONE of the listed accesses
	var/one_access = 0
	/// Checks to see if this airlock has an unrestricted helper (will set to TRUE if present).
	var/unres_sensor = FALSE
	/// Unrestricted sides, or sides of the airlock that will open regardless of access
	var/unres_sides = NONE
	///what name are we passing to the finished airlock
	var/passed_name
	///what string are we passing to the finished airlock as the cycle ID
	var/passed_cycle_id
	/// A holder of the electronics, in case of them working as an integrated part
	var/holder
	/// Whether this airlock can have an integrated circuit inside of it or not
	var/shell = FALSE

/obj/item/electronics/airlock/examine(mob/user)
	. = ..()
	. += span_notice("Has a neat <i>selection menu</i> for modifying airlock access levels.")

/**
 * Create a copy of the electronics
 * Arguments
 * * [location][atom]- the location to create the new copy in
 */
/obj/item/electronics/airlock/proc/create_copy(atom/location)
	//create a copy
	var/obj/item/electronics/airlock/new_electronics = new(location)
	//copy all params
	new_electronics.accesses = accesses.Copy()
	new_electronics.one_access = one_access
	new_electronics.unres_sides = unres_sides
	new_electronics.passed_name = passed_name
	new_electronics.passed_cycle_id = passed_cycle_id
	new_electronics.shell = shell
	//return copy
	return new_electronics


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
	data["passedName"] = passed_name
	data["passedCycleId"] = passed_cycle_id
	data["shell"] = shell
	return data

///shared by rcd & airlock electronics
/obj/item/electronics/airlock/proc/do_action(action, params)
	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
		if("grant_all")
			accesses = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
		if("one_access")
			one_access = !one_access
		if("set")
			var/access = params["access"]
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
		if("set_shell")
			shell = !!params["on"]
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
		if("grant_region")
			var/region = params["region"]
			if(isnull(region))
				return
			accesses |= SSid_access.get_region_access_list(list(region))
		if("deny_region")
			var/region = params["region"]
			if(isnull(region))
				return
			accesses -= SSid_access.get_region_access_list(list(region))
		if("passedName")
			var/new_name = trim("[params["passedName"]]", 30)
			passed_name = new_name
		if("passedCycleId")
			var/new_cycle_id = trim(params["passedCycleId"], 30)
			passed_cycle_id = new_cycle_id

/obj/item/electronics/airlock/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	do_action(action, params)
	return TRUE

/obj/item/electronics/airlock/ui_host()
	if(holder)
		return holder
	return src
