/**
 * Returns TRUE if this mob has sufficient access to use this object
 *
 * * accessor - mob trying to access this object, !!CAN BE NULL!! because of telekiesis because we're in hell
 */
/atom/movable/proc/allowed(mob/accessor)
	//check if it doesn't require any access at all, or the user is an Adminghost
	if(check_access(null) || isAdminGhostAI(accessor))
		return TRUE
	if(isnull(accessor)) //likely a TK user, and we checked for free access above.
		return FALSE

	//If the mob has the simple_access component with the requried access, we let them in.
	var/attempted_access = SEND_SIGNAL(accessor, COMSIG_MOB_TRIED_ACCESS, src)
	if(attempted_access & ACCESS_ALLOWED)
		return TRUE
	if(attempted_access & ACCESS_DISALLOWED)
		return FALSE

	var/list/player_access = accessor.get_access()

	//now let's check access we got from the signal.
	if(check_access_list(player_access))
		return TRUE

	if(HAS_SILICON_ACCESS(accessor))
		if(!(accessor.has_faction(ROLE_SYNDICATE)))
			if((ACCESS_SYNDICATE in req_access) || (ACCESS_SYNDICATE_LEADER in req_access) || (ACCESS_SYNDICATE in req_one_access) || (ACCESS_SYNDICATE_LEADER in req_one_access))
				return FALSE
			if(onSyndieBase() && loc != accessor)
				return FALSE
		return TRUE //AI can do whatever it wants
	return FALSE

// Check if an item has access to this object
/atom/movable/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : null)

/atom/movable/proc/check_access_list(list/access_list)
	if(!length(req_access) && !length(req_one_access))
		return TRUE

	if(!length(access_list) || !islist(access_list))
		return FALSE

	for(var/req in req_access)
		if(!(req in access_list)) //doesn't have this access
			return FALSE

	if(length(req_one_access))
		for(var/req in req_one_access)
			if(req in access_list) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/item/proc/remove_id()
	return null

/obj/item/proc/insert_id()
	return FALSE
