GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)
GLOBAL_LIST_EMPTY(mentors)
GLOBAL_PROTECT(mentors)

GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say,
	/client/proc/mentor_requests,
	/client/proc/toggle_mentor_states,
))
