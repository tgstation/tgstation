var/list/mentor_datums
/datum/mentors/var/following = null //Gross, but necessary as we loose all concept of who we're following otherwise
/client/proc/mentor_follow(var/mob/living/M)
	if(!check_rights(R_MENTOR))
		return

	if(isnull(M))
		return

	if(!istype(usr, /mob))
		return

	LAZYINITLIST(mentor_datums)
	if(!holder)
		var/datum/mentors/mentor = mentor_datums[usr.client.ckey]
		mentor.following = M

	usr.reset_perspective(M)
	src.verbs += /client/proc/mentor_unfollow

	to_chat(GLOB.admins, "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is now following <EM>[key_name(M)]</span>")
	to_chat(usr, "<span class='info'>Click the \"Stop Following\" button in the Mentor tab to stop following [key_name(M)].</span>")
	log_mentor("[key_name(usr)] began following [key_name(M)]")

/client/proc/mentor_unfollow()
	set category = "Mentor"
	set name = "Stop Following"
	set desc = "Stop following the followed."

	if(!check_rights(R_MENTOR))
		return

	usr.reset_perspective(null)
	src.verbs -= /client/proc/mentor_unfollow

	var/following = null
	if(!holder)
		var/datum/mentors/mentor = mentor_datums[usr.client.ckey]
		following = mentor.following


	to_chat(GLOB.admins, "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is no longer following <EM>[key_name(following)]</span>")
	log_mentor("[key_name(usr)] stopped following [key_name(following)]")

	following = null
