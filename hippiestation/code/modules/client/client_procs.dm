/client/proc/hippie_mentor_datum_set()
	mentor_datum = GLOB.mentor_datums[ckey]
	if(mentor_datum)
		GLOB.mentors |= src
		mentor_datum.owner = src
		add_mentor_verbs()
		mentor_memo_output("Show")

/client/proc/is_mentor()
	if(mentor_datum)
		return TRUE

/*/client/Topic/proc/HippieMentorMessage()
	if(config.mentors_mobname_only)
		var/mob/M = locate(href_list["mentor_msg"])
		cmd_mentor_pm(M,null)
	else
		cmd_mentor_pm(href_list["mentor_msg"],null)

/client/Topic/proc/HippieMentorFollow()
	var/mob/living/M = locate(href_list["mentor_follow"])

	if(istype(M))
		mentor_follow(M)
*/