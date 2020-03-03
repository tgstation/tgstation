#define JOB_MODIFICATION_MAP_NAME "MiniStation"

/datum/job/prisoner/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4 //Other maps' brigs are too small for four, but Box's will be empty otherwise; hopefully should flesh out other maps's brig in time so they can all be set to a cap of four prisoners
	spawn_positions = 4
