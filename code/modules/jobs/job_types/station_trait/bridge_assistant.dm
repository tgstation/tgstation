/datum/job/bridge_assistant
	title = JOB_BRIDGE_ASSISTANT
	description = "Watch over the Bridge, command its consoles, and spend your days brewing coffee for higher-ups."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD //not really a head but close enough
	department_head = list(JOB_CAPTAIN)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = "the Captain, and in non-Bridge related situations the other heads"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BRIDGE_ASSISTANT"

	outfit = /datum/outfit/job/bridge_assistant
	plasmaman_outfit = /datum/outfit/plasmaman/bridge_assistant

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CIV

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
	job_flags = STATION_JOB_FLAGS | STATION_TRAIT_JOB_FLAGS
	human_authority = JOB_AUTHORITY_NON_HUMANS_ALLOWED

/datum/job/bridge_assistant/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/mob/living/carbon/bridgie = spawned
	if(istype(bridgie))
		bridgie.gain_trauma(/datum/brain_trauma/special/axedoration)

/datum/job/bridge_assistant/get_roundstart_spawn_point()
	var/list/chair_turfs = list()
	var/list/possible_turfs = list()
	var/area/bridge = GLOB.areas_by_type[/area/station/command/bridge]
	if(isnull(bridge))
		return ..() //if no bridge, spawn on the arrivals shuttle (but also what the fuck)
	for (var/list/zlevel_turfs as anything in bridge.get_zlevel_turf_lists())
		for (var/turf/possible_turf as anything in zlevel_turfs)
			if(possible_turf.is_blocked_turf())
				continue
			if(locate(/obj/structure/chair) in possible_turf)
				chair_turfs += possible_turf
				continue
			possible_turfs += possible_turf
	if(length(chair_turfs))
		return pick(chair_turfs) //prioritize turfs with a chair
	if(length(possible_turfs))
		return pick(possible_turfs) //if none, just pick a random turf in the bridge
	return ..() //if the bridge has no turfs, spawn on the arrivals shuttle

/datum/outfit/job/bridge_assistant
	name = "Bridge Assistant"
	jobtype = /datum/job/bridge_assistant

	id_trim = /datum/id_trim/job/bridge_assistant
	backpack_contents = list(
		/obj/item/modular_computer/pda/bridge_assistant = 1,
	)

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
