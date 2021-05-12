//"Don't leave food on the floor, that's how we get ants"
/datum/component/decomposition
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///How decomposed a specific food item is. Uses delta_time.
	var/decomposition_level = 0
	//If an item is inside of a storage slot.
	var/is_stored = FALSE

/datum/component/decomposition/Initialize()
	.=..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/datum/component/creamed/RegisterWithParent()
	RegisterSignal(parent, list(
		COMSIG_ITEM_DROPPED, //If a person drops the object
		COMSIG_ITEM_EJECTED_FROM_CLOSET, //Checks if an object has been ejected from a lcoker/crate
		COMSIG_STORAGE_EXITED), //Checks if a storage object has been dumped
		 .proc/table_check)
	RegisterSignal(parent, list(
		COMSIG_ITEM_PICKUP, //person picks up an item
		COMSIG_TRY_STORAGE_HIDE_ALL), //Object has been put into a closed locker/crate
		.proc/picked_up)
	RegisterSignal(parent, COMSIG_STORAGE_ENTERED, .proc/storage_check) //Checks if you put it in storage
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/creamed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EJECTED_FROM_CLOSET,
		COMSIG_STORAGE_EXITED),
		 .proc/table_check)
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PICKUP,
		COMSIG_TRY_STORAGE_HIDE_ALL),
		.proc/picked_up)
	UnregisterSignal(parent, COMSIG_STORAGE_ENTERED, .proc/storage_check)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/decomposition/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/decomposition/proc/storage_check()
	SIGNAL_HANDLER
	is_stored = TRUE
	STOP_PROCESSING(SSobj, src)

/datum/component/decomposition/proc/table_check(obj/item/food/decomp)
	SIGNAL_HANDLER
	if(locate(/obj/structure/table) in decomp.loc || is_stored) //Space ants can't climb tables
		is_stored = FALSE //Made false here so storage dumping will still be affected.
		return
	START_PROCESSING(SSobj, src)

/datum/component/decomposition/proc/picked_up()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)

/datum/component/decomposition/process(delta_time, obj/item/food/decomp)
	decomposition_level += delta_time 
	if(decomposition_level >= 600) //10 minutes
		new /obj/item/food/badrecipe/moldy(parent.loc)
		qdel(parent)
		return
	if(decomposition_level == 300) //5 minutes
		new /obj/effect/decal/cleanable/ants(parent.loc)

/datum/component/decomposition/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	switch(decomposition_level)
		if (0 to 149)
			return
		if(150 to 299)
			examine_list += "[parent] looks kinda stale."
		if(300 to 449)
			examine_list += "[parent] is starting to look pretty gross."
		if(450 to 600)
			examine_list += "[parent] looks barely edible."
