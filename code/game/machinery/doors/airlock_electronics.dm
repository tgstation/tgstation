/obj/item/electronics/airlock
	name = "airlock electronics"
	req_access = list(ACCESS_MAINT_TUNNELS)
	custom_price = 50

	var/list/accesses = list()
	var/one_access = 0
	var/unres_sides = 0 //unrestricted sides, or sides of the airlock that will open regardless of access

/obj/item/electronics/airlock/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Has a neat <i>selection menu</i> for modifying airlock access levels.</span>"

/obj/item/electronics/airlock/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
													datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airlock_electronics", name, 420, 485, master_ui, state)
		ui.open()

/obj/item/electronics/airlock/ui_data()
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

/obj/item/electronics/airlock/ui_act(action, params)
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

/obj/item/stack/circuit_stack
	name = "polycircuit aggregate"
	desc = "A dense, overdesigned cluster of electronics which attempted to function as a multipurpose circuit electronic. Circuits can be removed from it... if you don't bleed out in the process."
	icon_state = "circuit_mess"
	item_state = "rods"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 8
	var/circuit_type = /obj/item/electronics/airlock
	var/chosen_circuit = "airlock"

/obj/item/stack/circuit_stack/attack_self(mob/user)// Prevents the menu, and tells you how to use it.
	to_chat(user, "<span class='warning'>You can't use the [src] by itself, you'll have to try and remove one of these circuits by hand... carefully.</span>")

/obj/item/stack/circuit_stack/attack_hand(mob/user)
	var/mob/living/carbon/human/H = user
	if(user.get_inactive_held_item() == src)
		chosen_circuit = input("What type of circuit would you like to remove?", "Choose a Circuit Type", chosen_circuit) in list("airlock","firelock","fire alarm","air alarm","APC")
		switch(chosen_circuit)
			if("airlock")
				circuit_type = /obj/item/electronics/airlock
			if("firelock")
				circuit_type = /obj/item/electronics/firelock
			if("fire alarm")
				circuit_type = /obj/item/electronics/firealarm
			if("air alarm")
				circuit_type = /obj/item/electronics/airalarm
			if("APC")
				circuit_type = /obj/item/electronics/apc
		if(zero_amount())
			return
		to_chat(user, "<span class='notice'>You spot your circuit, and carefully attempt to remove it from the [src], hold still!</span>")
		if(do_after(user, 30, 1, user, 1))
			if(!src || QDELETED(src))//Sanity Check.
				return
			var/returned_circuit = new circuit_type(src)
			user.put_in_hands(returned_circuit)
			use(1)
			if(!amount)
				to_chat(user, "<span class='notice'>You navigate the sharp edges of circuitry and remove the last board.</span>")
			else
				to_chat(user, "<span class='notice'>You navigate the sharp edges of circuitry and remove a single board from the [src]</span>")
		else
			H.apply_damage(15, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			to_chat(user, "<span class='warning'>You give yourself a wicked cut on the [src]'s many sharp corners and edges!</span>")
	else
		..()

/obj/item/stack/circuit_stack/full
	amount = 8
