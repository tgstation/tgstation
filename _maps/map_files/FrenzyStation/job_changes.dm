#define JOB_MODIFICATION_MAP_NAME "NSS Frenzy"

// Command
/datum/job/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the captain and the head of personnel"

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	supervisors = "Nanotrasen and Central Command"

/datum/job/hop/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the captain and Central Command"

// Service
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(clown)
MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)

/datum/outfit/job/clown/post_equip()
	// prevents runtimes caused when NPC clowns try to set their job
	MAP_JOB_CHECK_BASE

/datum/outfit/job/chaplain/New()
	..()
	MAP_JOB_CHECK
	backpack_contents[/obj/item/soapstone] = 1

// Supply
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(cargo_tech)

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	title = "Supply Technician"
	total_positions = 2
	spawn_positions = 3

/datum/outfit/job/mining/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/survival_mining

// Engineering
/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	title = "Ship Engineer"
	supervisors = initial(supervisors)
	spawn_positions = 2
	total_positions = 2

/datum/job/atmos/New()
	..()
	MAP_JOB_CHECK
	title = "Life Support Technician"
	supervisors = initial(supervisors)
	spawn_positions = 0
	total_positions = 1

// Medical
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 2

// Research
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(roboticist)

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 2

// Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	supervisors = initial(supervisors)
	spawn_positions = 1
	total_positions = 2

// Silicon
MAP_REMOVE_JOB(cyborg)
