#define JOB_MODIFICATION_MAP_NAME "PubbyStation"

/datum/job/hos/New()
	..()
	MAP_JOB_CHECK
	access += GLOB.access_crematorium
	minimal_access += GLOB.access_crematorium

/datum/job/warden/New()
	..()
	MAP_JOB_CHECK
	access += GLOB.access_crematorium
	minimal_access += GLOB.access_crematorium

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	access += GLOB.access_crematorium
	minimal_access += GLOB.access_crematorium

MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)