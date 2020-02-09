

/obj/structure/door_assembly/proc/airlock_install_electroadaptive(obj/item/electroadaptive_pseudocircuit/W, mob/user)
	if(!W.adapt_circuit(user, 15))
		return

	W.play_tool_sound(src, 100)
	user.visible_message("<span class='notice'>[user] installs [W] into the airlock assembly.</span>", \
						"<span class='notice'>You start to install [W] into the airlock assembly...</span>")

	if(do_after(user, 40, target = src))
		if( state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS )
			return

		to_chat(user, "<span class='notice'>You install the [W].</span>")
		state = AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER
		name = "near finished airlock assembly"
		electronics = new /obj/item/electronics/airlock

		electronics.accesses = W.accesses //Copy over pseudocircuit data
		electronics.one_access = W.one_access
		electronics.unres_sides = W.unres_sides


/obj/item/electroadaptive_pseudocircuit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
													datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airlock_electronics", name, 975, 420, master_ui, state)
		ui.open()

/obj/item/electroadaptive_pseudocircuit/ui_data()
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
	data["unres_direction"] = unres_sides

	return data

/obj/item/electroadaptive_pseudocircuit/ui_act(action, params)
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
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
			. = TRUE
