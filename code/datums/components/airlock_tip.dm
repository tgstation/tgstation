/**
 * The airlock_tip component makes it so an /obj/item that it is attached to can be used on an airlock/door to prop it on the top, so the next person
 * who walks through the door will have it fall on their head. The behavior for whether or not you're able to place the item on an airlock, as well as
 * the behavior that it takes when it falls are handled in the callbacks defined by the item.
 */

/datum/component/airlock_tip
	/// Used to prevent it from occuring twice in the same tick
	var/activated = FALSE
	/// The door we're rigged on
	var/obj/machinery/door/trapped_door
	/// The callback that runs when the user starts trying to plant the item on the door
	var/datum/callback/trap_start_callback
	/// The callback that runs when someone/something triggers the trap by walking through the door
	var/datum/callback/trap_trigger_callback
	/// How long it takes to successfully plant the trap
	var/time_to_plant = 3 SECONDS

/datum/component/airlock_tip/Initialize(time_to_plant = 3 SECONDS, trap_start_callback, trap_trigger_callback)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.trap_trigger_callback = trap_trigger_callback
	src.trap_start_callback = trap_start_callback
	src.time_to_plant = time_to_plant

/datum/component/airlock_tip/Destroy(force, silent)
	if(trapped_door)
		remove_plant()
	return ..()

/datum/component/airlock_tip/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(check_plant))

/datum/component/airlock_tip/UnregisterFromParent()
	if(trapped_door)
		remove_plant()

/// Check to see if you're actually attacking a door
/datum/component/airlock_tip/proc/check_plant(obj/item/our_item, atom/targeted_atom, mob/living/user, params)
	SIGNAL_HANDLER

	if(!istype(targeted_atom, /obj/machinery/door))
		return

	INVOKE_ASYNC(src, PROC_REF(try_plant), our_item, targeted_atom, user)
	return TRUE
	//if(targeted_door.GetComponent(/datum/component/)) // check for if something's already on it
	//if(!check_can_plant(targeted_atom, user))
		//return

/// Actually start the planting checks and do_after
/datum/component/airlock_tip/proc/try_plant(obj/item/our_item, obj/machinery/door/targeted_door, mob/living/user)
	if(trap_start_callback.Invoke(user, trapped_door) == COMPONENT_AIRLOCK_TIP_FAIL)
		return

	var/datum/callback/item_check = CALLBACK(src, PROC_REF(still_has_item), our_item, user)
	if(!do_after(user, time_to_plant, targeted_door, extra_checks = item_check))
		to_chat(user, span_danger("You fail to place [our_item] atop [targeted_door]."))
		return TRUE

	INVOKE_ASYNC(src, PROC_REF(plant), our_item, targeted_door, user)
	return TRUE

/// Returns false if the item is no longer in the user's possession
/datum/component/airlock_tip/proc/still_has_item(obj/item/our_item, mob/living/user)
	if(our_item in user)
		return TRUE

/// Actually put the item on the door
/datum/component/airlock_tip/proc/plant(obj/item/our_item, obj/machinery/door/targeted_door, mob/living/user)
	trapped_door = targeted_door

	var/turf/trapped_turf = get_turf(trapped_door)

	RegisterSignal(trapped_turf, COMSIG_ATOM_ENTERED, PROC_REF(check_trigger))
	our_item.forceMove(trapped_door)

/// Remove it from the door
/datum/component/airlock_tip/proc/remove_plant() // handle if the door gets deleted
	var/obj/item/our_item = parent
	if(trapped_door)
		var/turf/trapped_turf = get_turf(trapped_door)
		our_item.forceMove(get_turf(trapped_door))
		UnregisterSignal(trapped_turf, COMSIG_ATOM_ENTERED)
		trapped_door = null

/// Check to see if we're triggering from someone walking under us
/datum/component/airlock_tip/proc/check_trigger(turf/trapped_turf, atom/movable/victim, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!istype(trapped_turf) || !istype(victim))
		return

	INVOKE_ASYNC(src, PROC_REF(trigger_tip), victim)

/// Tip!
/datum/component/airlock_tip/proc/trigger_tip(atom/movable/victim)
	if(activated)
		return
	activated = TRUE
	trap_trigger_callback.Invoke(victim, trapped_door)
	remove_plant()
	activated = FALSE
