//"Don't leave food on the floor, that's how we get ants"
/datum/component/decomposition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///How decomposed a specific food item is. Uses delta_time.
	var/decomposition_level = 0
	///Makes sure food only starts decomposing if a player's EVER picked it up before
	var/handled = FALSE
	///Used to stop food in someone's hand & in storage slots from decomposing.
	var/protected = FALSE

/datum/component/decomposition/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/handle_movement)
	RegisterSignal(parent, list(
        COMSIG_ITEM_PICKUP, //person picks up an item
        COMSIG_STORAGE_ENTERED), //Object enters a storage object (boxes, etc.)
        .proc/picked_up)
	RegisterSignal(parent, list(
        COMSIG_ITEM_DROPPED, //Object is dropped anywhere
        COMSIG_STORAGE_EXITED), //Object exits a storage object (boxes, etc)
        .proc/dropped)

/datum/component/decomposition/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/handle_movement)
	UnregisterSignal(parent, list(
        COMSIG_ITEM_PICKUP,
        COMSIG_STORAGE_ENTERED),
        .proc/picked_up)
	UnregisterSignal(parent, list(
        COMSIG_ITEM_DROPPED,
        COMSIG_STORAGE_EXITED),
        .proc/dropped)

/datum/component/decomposition/proc/handle_movement() // Assuming it is guaranteed to be food
	var/obj/item/food/food = parent
	var/atom/last_loc = food.loc

	var/clean = FALSE // Used to check if it's on a clean surface
	while(last_loc && !isarea(last_loc))
		if(HAS_TRAIT(food.loc, TRAIT_PROTECT_FOOD))
			clean = TRUE
			break
		last_loc = last_loc.loc

	if(!handled || clean || protected)
		// prevent decomposition
		STOP_PROCESSING(SSobj, src)
		return
	// do decomposition
	START_PROCESSING(SSobj, src)

/datum/component/decomposition/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/decomposition/proc/dropped()
	SIGNAL_HANDLER
	protected = FALSE
	handle_movement()

/datum/component/decomposition/proc/picked_up()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	protected = TRUE
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
