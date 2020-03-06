#define JOB_MODIFICATION_MAP_NAME "BoxStation"

/datum/job/prisoner/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4 //Other maps' brigs are too small for four, but Box's will be relatively empty otherwise; hopefully should be able to flesh out other maps's brigs in time so they can all be set to a cap of four prisoners
	spawn_positions = 4
