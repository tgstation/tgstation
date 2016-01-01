 /**
  * NanoUI State: z_state
  *
  * Only checks that the Z-level of the user and src_object are the same.
 **/

/var/global/datum/nano_state/z_state/z_state = new()

/datum/nano_state/z_state/can_use_topic(atom/movable/src_object, mob/user)
	var/turf/turf_obj = get_turf(src_object)
	var/turf/turf_usr = get_turf(user)
	if(!turf_obj || !turf_usr || !(turf_obj.z == turf_usr.z))
		return NANO_CLOSE
	return NANO_INTERACTIVE
