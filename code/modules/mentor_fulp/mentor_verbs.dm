GLOBAL_PROTECT(mentor_verbs)
GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say,
	/client/proc/show_mentor_memo
	))

/client/proc/add_mentor_verbs()
	if(mentor_datum)
		verbs += GLOB.mentor_verbs

/client/proc/remove_mentor_verbs()
	verbs -= GLOB.mentor_verbs
