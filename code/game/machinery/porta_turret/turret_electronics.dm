/obj/item/electronics/turret
	name = "turret electronics"
	req_access = list()
	custom_price = 5

	var/list/accesses = list()
	var/one_access = 0
	var/check_arrest = TRUE		//checks if it can shoot people under arrest
	var/check_weapons = FALSE	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/stun_all = FALSE		//if this is active, the turret shoots everything that isn't authorized
	var/check_anomalies = TRUE	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_mindshield = FALSE	//checks if it can shoot people without a mindshield implant

/obj/item/electronics/turret/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Has a <i>selection menu</i> for modifying access levels and initial settings.</span>")

/obj/item/electronics/turret/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
													datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "turret_electronics", name, 975, 420, master_ui, state)
		ui.open()

/obj/item/electronics/turret/ui_data()
	var/list/data = list()
	var/list/regions = list()

	for(var/i in 1 to 7)
		var/list/region = list()
		var/list/accesses = list()
		for(var/j in get_region_accesses(i))
			var/list/access = list()
			access["name"] = get_access_desc(j)
			access["id"] = j
			access["req"] = (j in src.accesses)
			accesses[++accesses.len] = access
		region["name"] = get_region_accesses_name(i)
		region["accesses"] = accesses
		regions[++regions.len] = region
	data["regions"] = regions
	data["oneAccess"] = one_access
	data["check_arrest"] = check_arrest
	data["check_weapons"] = check_weapons
	data["stun_all"] = stun_all
	data["check_anomalies"] = check_anomalies
	data["check_mindshield"] = check_mindshield

	return data

/obj/item/electronics/turret/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear")
			accesses = list()
			one_access = 0
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
		if("toggle_arrest")
			check_arrest = !check_arrest
			. = TRUE
		if("toggle_weapons")
			check_weapons = !check_weapons
			. = TRUE
		if("toggle_anomalies")
			check_anomalies = !check_anomalies
			. = TRUE
		if("toggle_loyal")
			check_mindshield = !check_mindshield
			. = TRUE
		if("toggle_auth")
			stun_all = !stun_all
			. = TRUE
. = TRUE