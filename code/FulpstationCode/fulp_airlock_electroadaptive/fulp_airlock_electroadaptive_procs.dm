/obj/structure/windoor_assembly/proc/windoor_install_electroadaptive(obj/item/electroadaptive_pseudocircuit/W, mob/user)
	if(!W.adapt_circuit(user, 15))
		return

	W.play_tool_sound(src, 100)
	user.visible_message("<span class='notice'>[user] installs [W] into the airlock assembly.</span>", \
						"<span class='notice'>You start to install [W] into the airlock assembly...</span>")

	if(do_after(user, 40, target = src))
		if(!src || electronics )
			return

		to_chat(user, "<span class='notice'>You install [W].</span>")

		electronics = new /obj/item/electronics/airlock

		electronics.accesses = W.accesses //Port over pseudocircuit data
		electronics.one_access = W.one_access
		electronics.unres_sides = W.unres_sides



/obj/structure/door_assembly/proc/airlock_install_electroadaptive(obj/item/electroadaptive_pseudocircuit/W, mob/user)
	if(!W.adapt_circuit(user, 15))
		return

	W.play_tool_sound(src, 100)
	user.visible_message("<span class='notice'>[user] installs [W] into the airlock assembly.</span>", \
						"<span class='notice'>You start to install [W] into the airlock assembly...</span>")

	if(do_after(user, 40, target = src))
		if( state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS )
			return

		to_chat(user, "<span class='notice'>You install [W].</span>")
		state = AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER
		name = "near finished airlock assembly"
		electronics = new /obj/item/electronics/airlock

		electronics.accesses = W.accesses //Port over pseudocircuit data
		electronics.one_access = W.one_access
		electronics.unres_sides = W.unres_sides


/obj/item/electroadaptive_pseudocircuit/ui_static_data(mob/user)
	var/list/data = list()
	var/list/regions = list()
	for(var/i in 1 to 7)
		var/list/accesses = list()
		for(var/access in get_region_accesses(i))
			if (get_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = get_region_accesses_name(i),
			"regid" = i,
			"accesses" = accesses
		))

	data["regions"] = regions
	return data

/obj/item/electroadaptive_pseudocircuit/ui_data()
	var/list/data = list()
	data["accesses"] = accesses
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides

	return data

/obj/item/electroadaptive_pseudocircuit/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
			. = TRUE
		if("grant_all")
			accesses = get_all_accesses()
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
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses |= get_region_accesses(region)
			. = TRUE
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses -= get_region_accesses(region)
			. = TRUE


/obj/item/electroadaptive_pseudocircuit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
													datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airlock_electronics", name, 420, 485, master_ui, state)
		ui.open()

/obj/item/electroadaptive_pseudocircuit/proc/restock_circuit() //When the pseudocircuit recharges, attempts to produce an additional circuit
	if(!istype(loc, /mob/living/silicon/robot))
		return
	if(circuits > 4)
		return

	var/mob/living/silicon/robot/R = loc

	var/obj/item/stack/sheet/glass/cyborg/G = locate(/obj/item/stack/sheet/glass/cyborg) in R.module
	if(!G)
		return
	if(!G.source.use_charge(50))
		return

	var/obj/item/stack/sheet/metal/cyborg/M = locate(/obj/item/stack/sheet/metal/cyborg) in R.module
	if(!M)
		return
	if(!M.source.use_charge(50))
		return

	circuits = min(circuits + 1, 5)
	maptext = "[circuits]"

/obj/item/electroadaptive_pseudocircuit/proc/absorb_circuit(mob/user)
	if(circuits > 4)
		to_chat(user, "<span class='warning'>You cannot store any additional circuits!</span>")
		return FALSE

	circuits = min(circuits + 1, 5)
	maptext = "[circuits]"
	return TRUE
