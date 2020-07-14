GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say
	))
//client/proc/show_mentor_memo
GLOBAL_PROTECT(mentor_verbs)

/client/proc/add_mentor_verbs()
	if(mentor_datum || holder) //Both mentors and admins will get those verbs.
		verbs += GLOB.mentor_verbs

/client/proc/remove_mentor_verbs()
	verbs -= GLOB.mentor_verbs
