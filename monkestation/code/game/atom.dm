/atom/proc/rad_act(intensity)
	return
/**
* Respond to our atom being checked by a virus extrapolator
*
* Default behaviour is to send COMSIG_ATOM_EXTRAPOLATOR_ACT and return FALSE
*/
/atom/proc/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	SEND_SIGNAL(src,COMSIG_ATOM_EXTRAPOLATOR_ACT, user, E, scan)
	return FALSE
