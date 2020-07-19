#define JOB_MODIFICATION_MAP_NAME "PubbyStation"

/datum/job/hos/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_CREMATORIUM
	minimal_access += ACCESS_CREMATORIUM

/datum/job/warden/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_CREMATORIUM
	minimal_access += ACCESS_CREMATORIUM

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_CREMATORIUM
	minimal_access += ACCESS_CREMATORIUM

/datum/job/prisoner/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
