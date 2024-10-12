// Recovered crew should be an opt-out antag preference, but it's not supported by antag code
// Instead of completely rewriting the code and dding a lot of complexity, I will just set it to enabled by default for everyone
/datum/preferences/proc/enable_recovered_crew_preference()
	be_special += ROLE_RECOVERED_CREW
