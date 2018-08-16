/datum/admins
		var/following = null

/datum/admins/associate(client/C)
	..()
	if(istype(C))
		C.mentor_datum_set(TRUE)

/datum/admins/disassociate()
	if(owner)
		owner.remove_mentor_verbs()
		owner.mentor_datum = null
	..()