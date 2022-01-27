//"Don't leave food on the floor, that's how we get ants"

#define DECOMPOSITION_TIME 10 MINUTES
#define DECOMPOSITION_TIME_RAW 5 MINUTES
#define DECOMPOSITION_TIME_GROSS 7 MINUTES

#define DECOMP_EXAM_NORMAL 0
#define DECOMP_EXAM_GROSS 1
#define DECOMP_EXAM_RAW 2

/datum/component/decomposition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Makes sure maploaded food only starts decomposing if a player's EVER picked it up before
	var/handled = TRUE
	/// Used to stop food in someone's hand & in storage slots from decomposing.
	var/protected = FALSE
	/// Used to stop the timer & check for the examine proc
	var/timerid
	/// Used so the timer won't reset.
	var/time_remaining = DECOMPOSITION_TIME
	/// Used to give raw/gross food lower timers
	var/decomp_flags
	/// Use for determining what kind of item the food decomposes into.
	var/decomp_result
	/// Does our food attract ants?
	var/produce_ants = TRUE
	/// Used for examining
	var/examine_type = DECOMP_EXAM_NORMAL

/datum/component/decomposition/Initialize(mapload, decomp_req_handle, decomp_flags = NONE, decomp_result, ant_attracting = TRUE)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.decomp_flags = decomp_flags
	src.decomp_result = decomp_result
	if(mapload || decomp_req_handle)
		handled = FALSE
	if(!ant_attracting)
		produce_ants = FALSE

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/handle_movement)
	RegisterSignal(parent, list(
		COMSIG_ITEM_PICKUP, //person picks up an item
		COMSIG_STORAGE_ENTERED), //Object enters a storage object (boxes, etc.)
		.proc/picked_up)
	RegisterSignal(parent, list(
		COMSIG_ITEM_DROPPED, //Object is dropped anywhere
		COMSIG_STORAGE_EXITED), //Object exits a storage object (boxes, etc)
		.proc/dropped)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

	if(decomp_flags & RAW) // Raw food overrides gross
		time_remaining = DECOMPOSITION_TIME_RAW
		examine_type = DECOMP_EXAM_RAW
	else if(decomp_flags & GROSS)
		time_remaining = DECOMPOSITION_TIME_GROSS
		examine_type = DECOMP_EXAM_GROSS

	handle_movement()


/datum/component/decomposition/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PICKUP,
		COMSIG_STORAGE_ENTERED,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_DROPPED,
		COMSIG_STORAGE_EXITED,
		COMSIG_PARENT_EXAMINE))

/datum/component/decomposition/proc/handle_movement()
	SIGNAL_HANDLER
	if(!handled) // If maploaded, has someone touched this previously?
		return
	var/obj/food = parent // Doesn't HAVE to be food, that's just what it's intended for

	var/turf/open/open_turf = food.loc

	if(!istype(open_turf)) //Are we actually in an open turf?
		remove_timer()
		return

	for(var/atom/movable/content as anything in open_turf.contents)
		if(GLOB.typecache_elevated_structures[content.type])
			remove_timer()
			return

	// If all other checks fail, then begin decomposition.
	timerid = addtimer(CALLBACK(src, .proc/decompose), time_remaining, TIMER_STOPPABLE | TIMER_UNIQUE)

/datum/component/decomposition/Destroy()
	remove_timer()
	return ..()

/datum/component/decomposition/proc/remove_timer()
	if(active_timers) // Makes sure there's an active timer to delete.
		time_remaining = timeleft(timerid)
		deltimer(timerid)

/datum/component/decomposition/proc/dropped()
	SIGNAL_HANDLER
	protected = FALSE
	handle_movement()

/datum/component/decomposition/proc/picked_up()
	SIGNAL_HANDLER
	remove_timer()
	protected = TRUE
	if(!handled)
		handled = TRUE

/datum/component/decomposition/proc/decompose()
	var/obj/decomp = parent //Lets us spawn things at decomp
	if(produce_ants)
		new /obj/effect/decal/cleanable/ants(decomp.loc)
	new decomp_result(decomp.loc)
	decomp.visible_message("<span class='notice'>[decomp] gets overtaken by mold and ants! Gross!</span>")
	qdel(decomp)
	return

/datum/component/decomposition/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/time_d = 0
	if(active_timers) // Is the timer currently applied to this?
		time_d = timeleft(timerid)
	else
		time_d = time_remaining
	switch(examine_type)
		if(DECOMP_EXAM_NORMAL)// All other types
			switch(time_d) // Deciseconds used so there's no gaps between examine times.
				if(3001 to 4500) // 7.5 to 5 Minutes left
					examine_list += "[parent] looks kinda stale."
				if(1501 to 3000) // 5 to 2.5 Minutes left
					examine_list += "[parent] is starting to look pretty gross."
				if(1 to 1500) // 2.5 Minutes to 1 Decisecond left
					examine_list += "[parent] looks barely edible."
		if(DECOMP_EXAM_GROSS) // Gross food
			switch(time_d)
				if(2101 to 3150) // 5.25 to 3.5 Minutes
					examine_list += "[parent] looks kinda stale."
				if(1050 to 2100) // 3.5 to 1.75 Minutes left
					examine_list += "[parent] is starting to look pretty gross."
				if(1 to 1051) // 1.75 Minutes to 1 Decisecond left
					examine_list += "[parent] looks barely edible."
		if(DECOMP_EXAM_RAW) // Raw food
			switch(time_d)
				if(1501 to 2250) // 3.75 to 2.5 Minutes left
					examine_list += "[parent] looks kinda stale."
				if(751 to 1500) // 2.5 to 1.25 Minutes left
					examine_list += "[parent] is starting to look pretty gross."
				if(1 to 750) // 1.25 Minutes to 1 Decisecond left
					examine_list += "[parent] looks barely edible."

#undef DECOMPOSITION_TIME
#undef DECOMPOSITION_TIME_GROSS
#undef DECOMPOSITION_TIME_RAW

#undef DECOMP_EXAM_NORMAL
#undef DECOMP_EXAM_GROSS
#undef DECOMP_EXAM_RAW
