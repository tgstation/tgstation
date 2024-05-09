/**
 * Gravedigger component. Allows for graves to be dug from certain tiles
 */
/datum/component/gravedigger
	/// How long it takes to dig a grave
	var/dig_time = 8 SECONDS
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

/datum/component/gravedigger/Initialize(
	dig_time = 8 SECONDS,
)

	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.dig_time = dig_time

/datum/component/gravedigger/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(dig_checks))

/datum/component/gravedigger/proc/dig_checks(datum/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(interacting_with, turfs_to_consider))
		return NONE

	if(locate(/obj/structure/closet/crate/grave) in interacting_with)
		user.balloon_alert(user, "grave already present!")
		return ITEM_INTERACT_BLOCKING

	user.balloon_alert(user, "digging grave...")
	playsound(interacting_with, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	INVOKE_ASYNC(src, PROC_REF(perform_digging), user, interacting_with)
	return ITEM_INTERACT_BLOCKING

/datum/component/gravedigger/proc/perform_digging(mob/user, atom/dig_area)
	if(do_after(user, dig_time, dig_area))
		new /obj/structure/closet/crate/grave/fresh(dig_area) //We don't get_turf for the location since this is guaranteed to be a turf at this point.
		playsound(dig_area, 'sound/effects/shovel_dig.ogg', 50, TRUE)
