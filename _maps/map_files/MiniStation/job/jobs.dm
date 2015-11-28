/*
	In this file we modify the job datums when the ministation.dm file is included/ticked.
	Since we will be overriden by the job datums, we have to modify the variables in the constructor.
*/


/datum/job/New()
	..()
	supervisors = "the captain and the head of personnel"

/datum/job/assistant // Here so assistant appears on the top of the select job list.

// Command

/datum/job/captain/New()
	..()
	supervisors = "Nanotrasen and Central Command"

/datum/job/hop/New()
	..()
	supervisors = "the captain and Central Command"

/datum/job/hop/get_access()
	return get_all_accesses()

// Cargo

/datum/job/cargo_tech/New()
	..()
	total_positions = 2
	spawn_positions = 2

/datum/job/mining/New()
	..()
	total_positions = 1
	spawn_positions = 1

// Engineering

/datum/job/engineer/New()
	..()
	total_positions = 3
	spawn_positions = 3
	access += access_eva 	//list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics, access_tcomsat)

/datum/job/atmos/New()
	total_positions = 1
	spawn_positions = 1
	access += access_eva

// Medical

/datum/job/doctor/New()
	..()
	total_positions = 3
	spawn_positions = 3

/datum/job/chemist/New()
	..()
	total_positions = 1
	spawn_positions = 1

/datum/job/geneticist/New()
	..()
	total_positions = 1
	spawn_positions = 1

/datum/job/virologist/New()
	..()
	total_positions = 1
	spawn_positions = 1

// Science

/datum/job/scientist/New()
	..()
	total_positions = 3
	spawn_positions = 3

/datum/job/roboticist/New()
	return 0
	total_positions = 1
	spawn_positions = 1
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology)
	minimal_access = list(access_tox, access_tox_storage, access_research, access_xenobiology, access_robotics)

// Security

/datum/job/detective/New()
	..()
	supervisors = "no one but yourself"
	access = list(access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court, access_engine)
	minimal_access = list(access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)

/datum/job/officer/New()
	..()
	total_positions = 4
	spawn_positions = 4
	access = list(access_security, access_sec_doors, access_brig, access_court)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court)

// Service

/datum/job/cook/New()	//Basically just bartenders who can't open carry
	total_positions = 1
	spawn_positions = 1

/datum/job/hydro/New()
	total_positions = 1
	spawn_positions = 1

// Silicons

/datum/job/mommi/New()
	total_positions = 2
	spawn_positions = 2