#define JOB_MODIFICATION_MAP_NAME "Donutstation"

/datum/job/geneticist/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_MEDICAL
	minimal_access += ACCESS_MEDICAL
