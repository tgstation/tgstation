#define ACCESS_PERSEUS_ENFORCER 561
#define ACCESS_PERSEUS_COMMANDER 562
#define PERSEUS_ENFORCER (1<<11)
#define PERSEUS_COMMANDER (1<<12)

/datum/job/perseus_enforcer
	title = "Perseus Security Enforcer"
	flag = PERSEUS_ENFORCER
	department_head = list("Perseus Security Commander")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "Perseus Security Commander"
	selection_color = "#5677ad"
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/perseus
	access = list()
	minimal_access = list()
	whitelisted = 1
	override_station_procedures = 1
	antagonist_immune = 1


/obj/effect/landmark/start/penforcer
	name = "Perseus Security Enforcer"
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/datum/job/perseus_enforcer/pre_setup(mob/user,joined_late)
	return Create_Mycenae()

/datum/job/perseus_enforcer/is_whitelisted(client/C)
	if(istype(C))
		var/whitelistvalue = is_pwhitelisted(C.ckey)
		if(text2num(copytext(whitelistvalue,1,2)))
			return 1
	return 0

/datum/job/perseus_commander
	title = "Perseus Security Commander"
	flag = PERSEUS_COMMANDER
	department_head = list("CentCom")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials"
	selection_color = "#5677ad"
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/perseus/commander
	access = list()
	minimal_access = list()
	whitelisted = 1
	override_station_procedures = 1
	antagonist_immune = 1

/obj/effect/landmark/start/pcommander
	name = "Perseus Security Commander"
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/datum/job/perseus_commander/pre_setup(mob/user,joined_late)
	return Create_Mycenae()

/datum/job/perseus_commander/is_whitelisted(client/C)
	if(istype(C))
		var/whitelistvalue = is_pwhitelisted(C.ckey)
		if(text2num(copytext(whitelistvalue,1,2)) == 2)
			return 1
	return 0