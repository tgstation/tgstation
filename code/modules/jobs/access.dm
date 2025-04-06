/**
 * Returns TRUE if this mob has sufficient access to use this object
 *
 * * accessor - mob trying to access this object, !!CAN BE NULL!! because of telekiesis because we're in hell
 */
/atom/movable/proc/allowed(mob/accessor)
	var/result_bitflags = SEND_SIGNAL(src, COMSIG_OBJ_ALLOWED, accessor)
	if(result_bitflags & COMPONENT_OBJ_ALLOW)
		return TRUE
	if(result_bitflags & COMPONENT_OBJ_DISALLOW) // override all other checks
		return FALSE
	if(isnull(accessor)) //likely a TK user.
		return FALSE
	if(isAdminGhostAI(accessor))
		//Access can't stop the abuse
		return TRUE
	//If the mob has the simple_access component with the requried access, we let them in.
	var/attempted_access = SEND_SIGNAL(accessor, COMSIG_MOB_TRIED_ACCESS, src)
	if(attempted_access & ACCESS_ALLOWED)
		return TRUE
	if(attempted_access & ACCESS_DISALLOWED)
		return FALSE
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(HAS_SILICON_ACCESS(accessor))
		if(ispAI(accessor))
			return FALSE
		if(!(ROLE_SYNDICATE in accessor.faction))
			if((ACCESS_SYNDICATE in req_access) || (ACCESS_SYNDICATE_LEADER in req_access) || (ACCESS_SYNDICATE in req_one_access) || (ACCESS_SYNDICATE_LEADER in req_one_access))
				return FALSE
			if(onSyndieBase() && loc != accessor)
				return FALSE
		return TRUE //AI can do whatever it wants
	//If the mob is holding a valid ID, we let them in. get_active_held_item() is on the mob level, so no need to copypasta everywhere.
	else if(check_access(accessor.get_active_held_item()) || check_access(accessor.get_inactive_held_item()))
		return TRUE
	else if(ishuman(accessor))
		var/mob/living/carbon/human/human_accessor = accessor
		if(check_access(human_accessor.wear_id))
			return TRUE
	//if they have a hacky abstract animal ID with the required access, let them in i guess...
	else if(isanimal(accessor))
		var/mob/living/simple_animal/animal = accessor
		if(check_access(animal.access_card))
			return TRUE
	else if(isbrain(accessor))
		var/obj/item/mmi/brain_mmi = get(accessor.loc, /obj/item/mmi)
		if(brain_mmi && ismecha(brain_mmi.loc))
			var/obj/vehicle/sealed/mecha/big_stompy_robot = brain_mmi.loc
			return check_access_list(big_stompy_robot.accesses)
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

/obj/item/proc/RemoveID()
	return null

/obj/item/proc/InsertID()
	return FALSE
