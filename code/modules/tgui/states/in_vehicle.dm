/**
 * tgui state: in_vehicle_state
 *
 * Checks that the user is inside a vehicle.
 */

GLOBAL_DATUM_INIT(in_vehicle_state, /datum/ui_state/in_vehicle_state, new)

/datum/ui_state/in_vehicle_state/can_use_topic(atom/src_object, mob/user)
	if(!istype(user.loc, /obj/vehicle))
		return UI_CLOSE
	return UI_INTERACTIVE
