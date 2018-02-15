/datum/admins
		var/following = null

/datum/admins/associate(client/C)
	removeMentor(C.ckey) //safety to avoid multiple datums and other weird shit i cannot comprehend
	..()
	if(istype(C))
		C.mentor_datum_set(TRUE)

/datum/admins/disassociate()
	if(owner)
		owner.remove_mentor_verbs()
		owner.mentor_datum = null
	..()