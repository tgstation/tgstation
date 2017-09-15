GLOBAL_PROTECT(admin_verbs_mentor)
GLOBAL_LIST_INIT(admin_verbs_mentor, list(
	/client/proc/cmd_mentor_say,
	/client/proc/show_mentor_memo
	))

/proc/IsMentor()
	if(!usr || !usr.client)
		return FALSE
	return CkeyIsMentor(usr.ckey)

/proc/CkeyIsMentor(ckey)
	if(!GLOB.admin_datums[ckey])
		return FALSE
	var/datum/admins/admin_datum = GLOB.admin_datums[ckey]
	if(admin_datum.rank.name == "Mentor")
		return TRUE
	return FALSE