/**
 * Gravedigger element. Allows for graves to be dug from certain tiles
 */
/datum/element/gravedigger
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// A list of turf types that can be used to dig a grave.
	var/static/list/turfs_to_consider = typecacheof(list(
		/turf/open/misc/asteroid,
		/turf/open/misc/dirt,
		/turf/open/misc/grass,
		/turf/open/misc/basalt,
		/turf/open/misc/ashplanet,
		/turf/open/misc/snow,
		/turf/open/misc/sandy_dirt,
	))

/datum/element/gravedigger/Attach(datum/target)
	. = ..()

	if(!isitem(target)) //Must be an item to use toolspeed variable.
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(dig_checks))

/datum/element/gravedigger/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY)

/datum/element/gravedigger/proc/dig_checks(datum/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(interacting_with, turfs_to_consider))
		return NONE

	if(locate(/obj/structure/closet/crate/grave) in interacting_with)
		user.balloon_alert(user, "grave already present!")
		return ITEM_INTERACT_BLOCKING

	user.balloon_alert(user, "digging grave...")
	playsound(interacting_with, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	INVOKE_ASYNC(src, PROC_REF(perform_digging), user, interacting_with, source)
	return ITEM_INTERACT_BLOCKING

/datum/element/gravedigger/proc/perform_digging(mob/user, atom/dig_area, obj/item/our_tool)
	if(our_tool.use_tool(dig_area, user, 10 SECONDS))
		new /obj/structure/closet/crate/grave/fresh(dig_area) //We don't get_turf for the location since this is guaranteed to be a turf at this point.
