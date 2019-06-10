#define JOB_MODIFICATION_MAP_NAME "MetaStation"

/datum/job/geneticist/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_VIROLOGY
	minimal_access += ACCESS_VIROLOGY
