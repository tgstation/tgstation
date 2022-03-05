/datum/job/rd/New()	//hippie start, re-add cloning
	. = ..()
	access += ACCESS_GENETICS
	minimal_access += ACCESS_GENETICS
