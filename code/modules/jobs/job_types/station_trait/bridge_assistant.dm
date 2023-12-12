/datum/job/bridge_assistant
	title = JOB_BRIDGE_ASSISTANT
	description = "Watch over the Bridge, command its consoles, help the heads of staff, die in petty conflict."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD //not really a head but close enough
	department_head = list(JOB_CAPTAIN)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = SUPERVISOR_CAPTAIN
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BRIDGE_ASSISTANT"

	outfit = /datum/outfit/job/bridge_assistant
	plasmaman_outfit = /datum/outfit/plasmaman/bridge_assistant

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CIV

	mind_traits = list(TRAIT_NO_TWOHANDING)
	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIDGE_ASSISTANT
	departments_list = list(/datum/job_department/command)

	family_heirlooms = list(/obj/item/banner/command/mundane)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 1,
		/obj/item/pen/fountain = 1,
	)
	rpg_title = "Royal Guard"
	allow_bureaucratic_error = FALSE
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_CANNOT_OPEN_SLOTS | JOB_HIDE_WHEN_EMPTY | JOB_LATEJOIN_ONLY

/datum/job/bridge_assistant/get_roundstart_spawn_point()
	var/list/possible_turfs = list()
	for(var/turf/possible_turf as anything in GLOB.areas_by_type[/area/station/command/bridge])
		if(possible_turf.is_blocked_turf())
			continue
		possible_turfs += possible_turf
	if(length(possible_turfs))
		return pick(possible_turfs)
	return ..()

/datum/outfit/job/bridge_assistant
	name = "Bridge Assistant"
	jobtype = /datum/job/bridge_assistant

	id_trim = /datum/id_trim/job/bridge_assistant
	uniform = /obj/item/clothing/under/trek/command/next
	neck = /obj/item/clothing/neck/large_scarf/blue
	belt = /obj/item/storage/belt/utility/full/inducer
	ears = /obj/item/radio/headset/headset_com
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/fingerless
	head = /obj/item/clothing/head/soft/black
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/gun/energy/e_gun/mini
	r_pocket = /obj/item/assembly/flash/handheld
