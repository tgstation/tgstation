/**
 * TO DO LIST
 *
 * Make all borgs slaved to the Human AI
 * Add a way to block the Human AI from leaving the SAT (maybe something similar to free golems when on-station)
 * Add a way for the Human AI to have consoles, either by replacing its surroundings (maybe with modular maps) or some form of drop-pod for computers.
 * Add some default lawset for them on a piece of paper that they are told to follow, and cyborgs are given.
 * Lobby icon for station trait
 * Custom PDA sprite
 * Give robotic voicebox by default
 * More interactions with their liver trait
 */

/datum/job/human_ai
	title = JOB_HUMAN_AI
	description = "Assist the crew, open airlocks, coordinate your cyborgs."
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON //not really a head but close enough
	department_head = list(JOB_CAPTAIN)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = "the Captain"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "HUMAN_AI"

	outfit = /datum/outfit/job/human_ai
	plasmaman_outfit = /datum/outfit/plasmaman/human_ai

	paycheck = null
	paycheck_department = null

	liver_traits = list(TRAIT_HUMAN_AI_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_AI
	departments_list = list(
		/datum/job_department/silicon,
	)

	family_heirlooms = list(/obj/item/food/burger/roburger)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 1,
		/obj/item/pen/fountain = 1,
	)
	rpg_title = "Omnissiah"
	random_spawns_possible = FALSE
	allow_bureaucratic_error = FALSE
	job_flags = STATION_JOB_FLAGS | STATION_TRAIT_JOB_FLAGS
	ignore_human_authority = TRUE //we can safely assume NT doesn't care what species AIs are made of, much less if they can't even afford an AI.

/datum/job/human_ai/get_roundstart_spawn_point()
	return get_latejoin_spawn_point()

/datum/job/human_ai/get_latejoin_spawn_point()
	for(var/obj/structure/ai_core/latejoin_inactive/inactive_core as anything in GLOB.latejoin_ai_cores)
		if(!inactive_core.is_available())
			continue
		GLOB.latejoin_ai_cores -= inactive_core
		inactive_core.available = FALSE
		. = inactive_core.loc
		qdel(inactive_core)
		return
	var/list/primary_spawn_points = list() // Ideal locations.
	var/list/secondary_spawn_points = list() // Fallback locations.
	for(var/obj/effect/landmark/start/ai/spawn_point in GLOB.landmarks_list)
		if(spawn_point.used)
			secondary_spawn_points += list(spawn_point)
			continue
		if(spawn_point.primary_ai)
			primary_spawn_points = list(spawn_point)
			break // Bingo.
		primary_spawn_points += spawn_point
	var/obj/effect/landmark/start/ai/chosen_spawn_point
	if(length(primary_spawn_points))
		chosen_spawn_point = pick(primary_spawn_points)
	else if(length(secondary_spawn_points))
		chosen_spawn_point = pick(secondary_spawn_points)
	else
		CRASH("Failed to find any AI spawn points.")
	chosen_spawn_point.used = TRUE
	return chosen_spawn_point

/datum/job/human_ai/special_check_latejoin(client/C)
	for(var/obj/structure/ai_core/latejoin_inactive/latejoin_core as anything in GLOB.latejoin_ai_cores)
		if(latejoin_core.is_available())
			return TRUE
	return FALSE

/datum/job/human_ai/announce_job(mob/living/joining_mob)
	. = ..()
	if(SSticker.HasRoundStarted())
		minor_announce("Due to a research mishaps, [joining_mob] has been sent to be your replacement AI at [AREACOORD(joining_mob)]. Please treat them with respect.")

/datum/job/human_ai/get_radio_information()
	return "<b>Prefix your message with :b to speak with cyborgs.</b>"

/datum/outfit/job/human_ai
	name = "Human AI"
	jobtype = /datum/job/human_ai

	id = /obj/item/card/id/advanced/robotic
	id_trim = /datum/id_trim/job/human_ai
	backpack_contents = list(
		/obj/item/door_remote/omni = 1,
	)
	implants = list(
		/obj/item/implant/teleport_blocker,
	)

	uniform = /obj/item/clothing/under/color/grey
	belt = /obj/item/modular_computer/pda/human_ai
	ears = /obj/item/radio/headset/silicon/human_ai
	glasses = /obj/item/clothing/glasses/sunglasses

	suit = /obj/item/clothing/suit/costume/cardborg
	head = /obj/item/clothing/head/costume/cardborg

	l_pocket = /obj/item/laser_pointer/infinite //to punish borgs, this works through the camera console.
	r_pocket = /obj/item/assembly/flash/handheld

/datum/outfit/job/human_ai/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	equipped.faction += list(FACTION_SILICON, FACTION_TURRET)
