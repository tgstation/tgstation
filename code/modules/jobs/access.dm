
//returns TRUE if this mob has sufficient access to use this object
/obj/proc/allowed(mob/accessor)
	if(SEND_SIGNAL(src, COMSIG_OBJ_ALLOWED, accessor) & COMPONENT_OBJ_ALLOW)
		return TRUE
	//check if it doesn't require any access at all
	if(check_access(null))
		return TRUE
	if(issilicon(accessor))
		if(ispAI(accessor))
			return FALSE
		return TRUE //AI can do whatever it wants
	if(isAdminGhostAI(accessor))
		//Access can't stop the abuse
		return TRUE
	//If the mob has the simple_access component with the requried access, we let them in.
	else if(SEND_SIGNAL(accessor, COMSIG_MOB_TRIED_ACCESS, src) & ACCESS_ALLOWED)
		return TRUE
	//If the mob is holding a valid ID, we let them in. get_active_held_item() is on the mob level, so no need to copypasta everywhere.
	else if(check_access(accessor.get_active_held_item()))
		return TRUE
	//if they are wearing a card that has access, that works
	else if(ishuman(accessor))
		var/mob/living/carbon/human/human_accessor = accessor
		if(check_access(human_accessor.wear_id))
			return TRUE
	//if they have a hacky abstract animal ID with the required access, let them in i guess...
	else if(isanimal(accessor))
		var/mob/living/simple_animal/animal = accessor
		if(check_access(animal.access_card))
			return TRUE
	return FALSE

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/item/proc/RemoveID()
	return null

/obj/item/proc/InsertID()
	return FALSE

/obj/proc/text2access(access_text)
	. = list()
	if(!access_text)
		return
	var/list/split = splittext(access_text,";")
	for(var/x in split)
		var/n = text2num(x)
		if(n)
			. += n

//Call this before using req_access or req_one_access directly
/obj/proc/gen_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!req_access)
		req_access = list()
		for(var/a in text2access(req_access_txt))
			req_access += a
	if(!req_one_access)
		req_one_access = list()
		for(var/b in text2access(req_one_access_txt))
			req_one_access += b

// Check if an item has access to this object
/obj/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : null)

/obj/proc/check_access_list(list/access_list)
	gen_access()

	if(!islist(req_access)) //something's very wrong
		return TRUE

	if(!req_access.len && !length(req_one_access))
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

/*
 * Checks if this packet can access this device
 *
 * Normally just checks the access list however you can override it for
 * hacking proposes or if wires are cut
 *
 * Arguments:
 * * passkey - passkey from the datum/netdata packet
 */
/obj/proc/check_access_ntnet(list/passkey)
	return check_access_list(passkey)

/// Returns the SecHUD job icon state for whatever this object's ID card is, if it has one.
/obj/item/proc/get_sechud_job_icon_state()
	var/obj/item/card/id/id_card = GetID()

	return id_card?.get_trim_sechud_icon_state() || SECHUD_NO_ID
