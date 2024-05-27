/client
	///If this is set, this person is a Mentor.
	var/datum/mentors/mentor_datum

/client/New()
	. = ..()
	mentor_datum_set()

// Overwrites /client/Topic to return for mentor client procs
/client/Topic(href, href_list, hsrc)
	if(mentor_client_procs(href_list))
		return
	return ..()

/client/proc/mentor_client_procs(href_list)
	if(href_list["mentor_msg"])
		cmd_mentor_pm(href_list["mentor_msg"],null)
		return TRUE

	/// Mentor Follow
	if(href_list["mentor_follow"])
		var/mob/living/followed_guy = locate(href_list["mentor_follow"])

		if(istype(followed_guy))
			mentor_follow(followed_guy)
		return TRUE


/client/proc/mentor_datum_set(admin)
	mentor_datum = GLOB.mentor_datums[ckey]
	/// Admin with no mentor datum? let's fix that
	if(!mentor_datum && check_rights_for(src, R_ADMIN,0))
		new /datum/mentors(ckey)
	if(mentor_datum)
		GLOB.mentors |= src
		mentor_datum.owner = src
		add_mentor_verbs()
		var/list/cdatums = list()
		for(var/coder in world.file2list("[global.config.directory]/contributors.txt"))
			cdatums += ckey(coder)
		if(ckey in cdatums)
			mentor_datum.is_contributor = TRUE

///Verifies if the client is considered a Mentor, AKA has a Mentor datum or is an Admin.
/client/proc/is_mentor()
	if(mentor_datum || check_rights_for(src, R_ADMIN, 0))
		return TRUE

/proc/dementor(client/owner)
	if(owner.is_mentor())
		owner.mentor_datum.not_active = TRUE

/proc/rementor(client/owner)
	if(owner.is_mentor())
		owner.mentor_datum.not_active = FALSE


