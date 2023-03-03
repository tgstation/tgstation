GLOBAL_LIST_EMPTY(access_keys)

/obj/item/access_key
	name = "access key ring"
	desc = "A key ring with a beeper, allowing the keys to change shape depending on which department it has access to."
	icon_state = "keyjanitor"
	icon = 'icons/obj/vehicles.dmi'
	w_class = WEIGHT_CLASS_TINY

	///The departmental access given to the key.
	var/list/department_access

/obj/item/access_key/Initialize(mapload)
	. = ..()
	GLOB.access_keys += src
	RegisterSignal(SSdcs, COMSIG_ON_DEPARTMENT_ACCESS, PROC_REF(department_access_given))

/obj/item/access_key/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_ON_DEPARTMENT_ACCESS)
	GLOB.access_keys -= src
	return ..()

/obj/item/access_key/examine(mob/user)
	. = ..()
	if(department_access)
		. += "It currently holds access to [department_access[1]]"

/obj/item/access_key/examine_more(mob/user)
	. = ..()
	. += span_notice("Access is given to the key through a Keycard Authentication Device.")
	. += span_notice("This access is limited to one Department at a time.")
/*
/obj/item/access_key/GetAccess()
	var/mob/user = loc
	if(!user)
		return
	user.balloon_alert_to_viewers("fumbles with keys...", "finding_key...")
	if(!do_after(user, 3 SECONDS, src))
		return
	var/access_list = list()
	for(var/department_type in department_access)
		access_list += SSid_access.accesses_by_region[department_type]
	return access_list
*/
/**
 * Called when a keycard authenticator sends region access
 * Stores it on the key to use for access
 * Args:
 * source - the keycard authenticator giving us the access
 * region_access - the list of access we're being sent.
 */
/obj/item/access_key/proc/department_access_given(obj/machinery/keycard_auth/source, list/region_access)
	SIGNAL_HANDLER
	department_access = region_access
	say("Access granted to [region_access[1]] area.")
