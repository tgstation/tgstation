/client/Topic/proc/HippieMentorMessage()
	if(config.mentors_mobname_only)
		var/mob/M = locate(href_list["mentor_msg"])
		cmd_mentor_pm(M,null)
	else
		cmd_mentor_pm(href_list["mentor_msg"],null)

/client/Topic/proc/HippieMentorFollow()
	var/mob/living/M = locate(href_list["mentor_follow"])

	if(istype(M))
		mentor_follow(M)
