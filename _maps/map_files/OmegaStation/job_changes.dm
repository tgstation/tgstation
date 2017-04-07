
//custom access for some jobs. pasted together from ministation.

#define JOB_MODIFICATION_MAP_NAME "OmegaStation"

/datum/job/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/weapon/storage/box/survival/radio

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
	access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_weapons, GLOB.access_forensics_lockers)
	minimal_access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_weapons, GLOB.access_forensics_lockers)

/datum/outfit/job/officer/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/weapon/storage/box/security/radio

/datum/job/detective/New()
	..()
	MAP_JOB_CHECK
	access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_weapons, GLOB.access_forensics_lockers)
	minimal_access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_weapons, GLOB.access_forensics_lockers)

/datum/outfit/job/detective/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/weapon/storage/box/security/radio

//Medbay

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	selection_color = "#ffffff"
	total_positions = 3
	spawn_positions = 3
	access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_surgery, GLOB.access_chemistry, GLOB.access_virology, GLOB.access_genetics)
	minimal_access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_surgery, GLOB.access_chemistry, GLOB.access_virology, GLOB.access_genetics)

//Engineering

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(GLOB.access_eva, GLOB.access_engine, GLOB.access_engine_equip, GLOB.access_tech_storage, GLOB.access_maint_tunnels, GLOB.access_external_airlocks, GLOB.access_construction, GLOB.access_atmospherics, GLOB.access_tcomsat)
	minimal_access = list(GLOB.access_eva, GLOB.access_engine, GLOB.access_engine_equip, GLOB.access_tech_storage, GLOB.access_maint_tunnels, GLOB.access_external_airlocks, GLOB.access_construction, GLOB.access_atmospherics, GLOB.access_tcomsat)

/datum/outfit/job/engineer/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/weapon/storage/box/engineer/radio

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
	access = list(GLOB.access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_mineral_storeroom, GLOB.access_tech_storage)
	minimal_access = list(GLOB.access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_mineral_storeroom, GLOB.access_tech_storage)

//Cargo

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(GLOB.access_maint_tunnels, GLOB.access_mailsorting, GLOB.access_cargo, GLOB.access_cargo_bot, GLOB.access_qm, GLOB.access_mining, GLOB.access_mining_station, GLOB.access_mineral_storeroom)
	minimal_access = list(GLOB.access_maint_tunnels, GLOB.access_mailsorting, GLOB.access_cargo, GLOB.access_cargo_bot, GLOB.access_qm, GLOB.access_mining, GLOB.access_mining_station, GLOB.access_mineral_storeroom)

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2
	access = list(GLOB.access_maint_tunnels, GLOB.access_mailsorting, GLOB.access_cargo, GLOB.access_cargo_bot, GLOB.access_qm, GLOB.access_mining, GLOB.access_mining_station, GLOB.access_mineral_storeroom)
	minimal_access = list(GLOB.access_maint_tunnels, GLOB.access_mailsorting, GLOB.access_cargo, GLOB.access_cargo_bot, GLOB.access_qm, GLOB.access_mining, GLOB.access_mining_station, GLOB.access_mineral_storeroom)

/datum/outfit/job/mining/New()
	..()
	box = /obj/item/weapon/storage/box/engineer/radio

//Service

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	access = list(GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_weapons)
	minimal_access = list(GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_weapons)

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	access = list(GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_weapons)
	minimal_access = list(GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_weapons)

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	access = list(GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_maint_tunnels)
	minimal_access = list(GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_maint_tunnels)
	// they get maint access because of all the hydro content in maint

/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	access = list(GLOB.access_janitor, GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_maint_tunnels)
	minimal_access = list(GLOB.access_janitor, GLOB.access_hydroponics, GLOB.access_bar, GLOB.access_kitchen, GLOB.access_morgue, GLOB.access_maint_tunnels)


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