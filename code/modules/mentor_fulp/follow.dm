/client/proc/mentor_follow(mob/living/M)
	if(!is_mentor())
		return
	if(isnull(M))
		return
	if(!ismob(usr))
		return
	mentor_datum.following = M
	usr.reset_perspective(M)
	verbs += /client/proc/mentor_unfollow
	to_chat(GLOB.admins, "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is now following <EM>[key_name(M)]</span>")
	to_chat(usr, "<span class='info'>Click the \"Stop Following\" button in the Mentor tab to stop following [key_name(M)].</span>")
	log_mentor("[key_name(usr)] began following [key_name(M)]")

/client/proc/mentor_unfollow()
	set category = "Mentor"
	set name = "Stop Following"
	set desc = "Stop following the followed."

	if(!is_mentor())
		return
	usr.reset_perspective()
	verbs -= /client/proc/mentor_unfollow
	to_chat(GLOB.admins, "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is no longer following <EM>[key_name(mentor_datum.following)]</span>")
	log_mentor("[key_name(usr)] stopped following [key_name(mentor_datum.following)]")
	mentor_datum.following = null
