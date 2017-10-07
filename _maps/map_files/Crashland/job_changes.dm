#define JOB_MODIFICATION_MAP_NAME "Lavaland Crashdown"

// Maximum complement of 14:
// 1 Captain
// 1 QM
// 1 CE
// 1 CMO
// 1 HOS
// 5 Shaft Miners
// 2 Engineers
// 1 Medic
// 1 Scientist

// Command
/datum/job/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the captain"

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	supervisors = "your survival instinct"

MAP_REMOVE_JOB(hop)

// Service
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(clown)
MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(janitor)
MAP_REMOVE_JOB(assistant)

/datum/outfit/job/clown/post_equip()
	// prevents runtimes caused when NPC clowns try to set their job
	MAP_JOB_CHECK_BASE

// Supply
MAP_REMOVE_JOB(cargo_tech)

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the quartermaster and the captain"
	spawn_positions = 5
	total_positions = 5

/datum/outfit/job/mining/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/survival_mining

// Engineering
/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 2
	total_positions = 2

MAP_REMOVE_JOB(atmos)

// Medical
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1

// Research
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(roboticist)

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1

// Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(officer)

// Silicon
MAP_REMOVE_JOB(ai)
MAP_REMOVE_JOB(cyborg)
