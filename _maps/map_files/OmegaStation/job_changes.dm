
//custom access for some jobs. pasted together from ministation.

#define JOB_MODIFICATION_MAP_NAME "OmegaStation"

/datum/job/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/survival/radio

/datum/job/assistant // Here so assistant appears on the top of the select job list.

//Command

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	supervisors = "Nanotrasen and Central Command"

/datum/job/hop/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the captain and Central Command"

/datum/job/hop/get_access()
	MAP_JOB_CHECK_BASE
	return get_all_accesses()

//Security

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)

/datum/outfit/job/officer/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/security/radio

/datum/job/detective/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)

/datum/outfit/job/detective/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/security/radio

//Medbay

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	selection_color = "#ffffff"
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)

//Engineering

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_TCOMSAT)
	minimal_access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_TCOMSAT)

/datum/outfit/job/engineer/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/engineer/radio

/datum/job/atmos/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

//Science

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)

//Cargo

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/datum/outfit/job/mining/New()
	..()
	box = /obj/item/storage/box/engineer/radio

//Service

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	// they get maint access because of all the hydro content in maint

/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_JANITOR, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_JANITOR, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)


//Civilian

/datum/job/clown/New()
	..()
	MAP_JOB_CHECK
	supervisors = "nobody but yourself" //Honk

MAP_REMOVE_JOB(hos)
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chemist)
