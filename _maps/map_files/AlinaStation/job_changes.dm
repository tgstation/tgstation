//custom access for some jobs. pasted together from ministation.

#define JOB_MODIFICATION_MAP_NAME "AlinaStation"

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
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE)

/datum/outfit/job/officer/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/security/radio

/datum/job/detective/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)

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
	access = list(ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_MORGUE)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_MORGUE)

//Engineering

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TCOMSAT)
	minimal_access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TCOMSAT)

/datum/outfit/job/engineer/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/engineer/radio

//Science

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE)
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_MORGUE)

//Cargo

/datum/job/qm/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/datum/outfit/job/mining/New()
	..()
	box = /obj/item/storage/box/engineer/radio

//Service

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_WEAPONS)

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_HYDROPONICS)
	minimal_access = list(ACCESS_HYDROPONICS)

/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1
	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)


//Civilian

/datum/job/clown/New()
	..()
	MAP_JOB_CHECK
	supervisors = "nobody but yourself" //Honk

MAP_REMOVE_JOB(hos)
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(librarian)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(atmos)