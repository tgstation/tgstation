#define JOB_MODIFICATION_MAP_NAME "MiniStation"

/datum/job/assistant // Here so assistant appears on the top of the select job list.

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/hop/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1


/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/detective/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/cyborg/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/ai/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1


//Removed

MAP_REMOVE_JOB(hydro)

MAP_REMOVE_JOB(qm)

MAP_REMOVE_JOB(mining)

MAP_REMOVE_JOB(curator)

MAP_REMOVE_JOB(librarian)

MAP_REMOVE_JOB(lawyer)

MAP_REMOVE_JOB(chaplain)

MAP_REMOVE_JOB(chief_engineer)

MAP_REMOVE_JOB(atmos)

MAP_REMOVE_JOB(cmo)

MAP_REMOVE_JOB(geneticist)

MAP_REMOVE_JOB(virologist)

MAP_REMOVE_JOB(rd)

MAP_REMOVE_JOB(roboticist)

MAP_REMOVE_JOB(hos)

MAP_REMOVE_JOB(warden)

MAP_REMOVE_JOB(paramedic)

