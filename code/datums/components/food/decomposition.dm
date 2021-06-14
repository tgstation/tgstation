//"Don't leave food on the floor, that's how we get ants"

#define DECOMPOSITION_TIME 10 MINUTES

/datum/component/decomposition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///Makes sure food only starts decomposing if a player's EVER picked it up before
	var/handled = FALSE
	///Used to stop food in someone's hand & in storage slots from decomposing.
	var/protected = FALSE
	// Used to stop the timer & check for the examine proc
	var/timerid
	// Used so the timer won't reset.
	var/time_remaining = DECOMPOSITION_TIME

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
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine) // Self-explanitory

/datum/component/decomposition/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PICKUP,
		COMSIG_STORAGE_ENTERED,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_DROPPED,
		COMSIG_STORAGE_EXITED,
		COMSIG_PARENT_EXAMINE))

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
		if(active_timers)
			time_remaining = timeleft(timerid)
		deltimer(timerid)
		return
	// do decomposition
	timerid = addtimer(CALLBACK(src, .proc/decompose), time_remaining, TIMER_STOPPABLE, TIMER_UNIQUE) //Was told to use this instead of processing I guess

/datum/component/decomposition/Destroy()
	deltimer(timerid) //Just in case
	return ..()

/datum/component/decomposition/proc/dropped()
	SIGNAL_HANDLER
	protected = FALSE
	handle_movement()

/datum/component/decomposition/proc/picked_up()
	SIGNAL_HANDLER
	if(active_timers)
		time_remaining = timeleft(timerid)
	deltimer(timerid)
	protected = TRUE
	if(!handled)
		handled = TRUE

/datum/component/decomposition/proc/decompose()
	var/obj/item/food/decomp = parent //Lets us spawn things at decomp
	new /obj/effect/decal/cleanable/ants(decomp.loc)
	new /obj/item/food/badrecipe/moldy(decomp.loc)
	decomp.visible_message("<span class='notice'>[decomp] gets overtaken by ants! Gross!</span>")
	qdel(decomp)
	return

/datum/component/decomposition/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(active_timers)
		switch(timeleft(timerid)) // Deciseconds used so there's no gaps between examine times.
			if(3001 to 4500) // 7.5 to 5 Minutes
				examine_list += "[parent] looks kinda stale."
			if(1501 to 3000) // 5 to 2.5 Minutes
				examine_list += "[parent] is starting to look pretty gross."
			if(1 to 1500) // 2.5 Minutes to 1 Decisecond
				examine_list += "[parent] looks barely edible."
	else
		switch(time_remaining)
			if(3001 to 4500) // 7.5 to 5 Minutes
				examine_list += "[parent] looks kinda stale."
			if(1501 to 3000) // 5 to 2.5 Minutes
				examine_list += "[parent] is starting to look pretty gross."
			if(1 to 1500) // 2.5 Minutes to 1 Decisecond
				examine_list += "[parent] looks barely edible."


#undef DECOMPOSITION_TIME
