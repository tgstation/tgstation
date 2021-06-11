//"Don't leave food on the floor, that's how we get ants"
/datum/component/decomposition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///How decomposed a specific food item is. Uses delta_time.
	var/decomposition_level = 0
	///Makes sure food only starts decomposing if a player's EVER picked it up before
	var/handled = FALSE
	///Used to stop food in someone's hand & in storage slots from decomposing.
	var/clean = FALSE

/datum/component/decomposition/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/handle_movement)
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/picked_up)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)

/datum/component/decomposition/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/handle_movement)
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/picked_up)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)

/datum/component/decomposition/proc/handle_movement() // Assuming it is guaranteed to be food
	var/obj/item/food/food = parent
	var/atom/last_loc = food.loc

	while(!isarea(last_loc))
		if(HAS_TRAIT(food.loc, TRAIT_PROTECT_FOOD))
			clean = TRUE
			break

	if(!handled || clean)
		// prevent decomposition
		return
	// do decomposition
	START_PROCESSING(SSobj, src)

/datum/component/decomposition/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
/*
/datum/component/decomposition/proc/storage_check()
	SIGNAL_HANDLER
	protect = TRUE
	STOP_PROCESSING(SSobj, src)
*/
/datum/component/decomposition/proc/dropped()
	SIGNAL_HANDLER
	clean = FALSE
	handle_movement()

/datum/component/decomposition/proc/picked_up()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	clean = TRUE
	if(!handled)
		handled = TRUE

// The act of decomposing itself
/datum/component/decomposition/process(delta_time)
	var/obj/item/food/decomp = parent //Lets us spawn things at decomp
	decomposition_level += delta_time //Things decompose in seconds.
	if(decomposition_level >= 10) //10 minutes 600
		new /obj/effect/decal/cleanable/ants(decomp.loc)
		new /obj/item/food/badrecipe/moldy(decomp.loc)
		decomp.visible_message("<span class='notice'>[decomp] gets overtaken by ants! Gross!</span>")
		qdel(decomp)
		return

/datum/component/decomposition/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	switch(decomposition_level)
		if (0 to 149)
			return
		if(150 to 299) // 2.5 minutes
			examine_list += "[parent] looks kinda stale."
		if(300 to 449) // 5 minutes
			examine_list += "[parent] is starting to look pretty gross."
		if(450 to 600) // 7.5 minutes
			examine_list += "[parent] looks barely edible."
