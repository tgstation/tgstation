#define JOB_MODIFICATION_MAP_NAME "BirdStation"

//Removed jobs
/datum/job/atmos/map_check()
	return FALSE

/datum/job/chief_engineer/map_check()
	return FALSE

/datum/job/qm/map_check()
	return FALSE

/datum/job/cmo/map_check()
	return FALSE

/datum/job/chemist/map_check()
	return FALSE

/datum/job/geneticist/map_check()
	return FALSE

/datum/job/virologist/map_check()
	return FALSE

/datum/job/rd/map_check()
	return FALSE

/datum/job/roboticist/map_check()
	return FALSE

/datum/job/chaplain/map_check()
	return FALSE

/datum/job/warden/map_check()
	return FALSE

/datum/job/lawyer/map_check()
	return FALSE

//Job changes

/datum/job/New()
	..()
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/New()
	box = /obj/item/weapon/storage/box/birdsurv

/datum/job/assistant // Here so assistant appears on the top of the select job list.

//Access Changes + Flavo(u)r
//Command

/datum/job/captain/New()
	..()
	supervisors = "Nanotrasen and Central Command"

/datum/job/hop/New()
	..()
	supervisors = "the captain and Central Command"

/datum/job/hop/get_access()
	return get_all_accesses()

//Security

/datum/job/hos/New()
	..()

/datum/outfit/job/hos/New()
	box = /obj/item/weapon/storage/box/birdsec

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4
	access += list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)
	minimal_access += list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)

/datum/outfit/job/officer/New()
	box = /obj/item/weapon/storage/box/birdsec

/datum/job/detective/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)
	minimal_access += list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_FORENSICS_LOCKERS)

/datum/outfit/job/detective/New()
	box = /obj/item/weapon/storage/box/birdsec

//Medbay

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	selection_color = "#ffffff"
	total_positions = 6
	spawn_positions = 6
	access += list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)
	minimal_access += list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)

//Engineering

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4
	access += list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_TCOMSAT)
	minimal_access += list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_TCOMSAT)

/datum/outfit/job/engineer/New()
	box = /obj/item/weapon/storage/box/birdeng

//Science

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 5
	spawn_positions = 5
	access += list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY)
	minimal_access += list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY)

//Cargo

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access += list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access += list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

//Service

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access += list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access += list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access += list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	// they get maint access because of all the hydro content in maint

/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	access += list(ACCESS_JANITOR, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access += list(ACCESS_JANITOR, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)

//Civilian

/datum/job/clown/New()
	..()
	supervisors = "nobody but yourself" //Honk

