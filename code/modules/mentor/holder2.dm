GLOBAL_LIST_EMPTY(mentors)
GLOBAL_LIST_EMPTY(mentor_datums)

/datum/mentor
	var/client/owner
	var/active = TRUE
	var/mob/following

/datum/mentor/New(_ckey)
	. = ..()
	if(_ckey) //ckey is not connected, but is a mentor
		GLOB.mentor_datums[_ckey] = src
	else
		qdel(src)

/datum/mentor/Destroy()
	. = ..()
	disassociate()

/datum/mentor/proc/associate(client/C)
	if(istype(C))
		GLOB.mentors |= C
		owner = C
	GLOB.mentor_datums[C.ckey] = src

/datum/mentor/proc/disassociate()
	if(owner)
		GLOB.mentors -= owner
		GLOB.mentor_datums[owner.ckey] = src
		owner = null

/client/proc/dementor()
	var/mentor = GLOB.mentor_datums[ckey]
	GLOB.mentor_datums -= ckey
	qdel(mentor)
	return TRUE

/proc/check_mentor()
	if(usr && usr.client)
		var/mentor = GLOB.mentor_datums[usr.client.ckey]
		if(mentor || check_rights_for(usr.client, R_ADMIN))
			return TRUE
	return FALSE

/proc/check_mentor_other(var/client/C)
	if(C)
		var/mentor = GLOB.mentor_datums[C.ckey]
		if(C.holder && C.holder.rank)
			if(C.holder.rank.rights & R_ADMIN)
				return TRUE
		else if(mentor)
			return TRUE
	return FALSE