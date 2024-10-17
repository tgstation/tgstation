///Special job, active during monkey day.
/datum/job/pun_pun
	title = JOB_PUN_PUN
	description = "Assist the service department by serving drinks and food and entertaining the crew."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = "the Bartender"
	spawn_type = /mob/living/carbon/human/species/monkey/punpun
	outfit = /datum/outfit/job/pun_pun
	config_tag = "PUN_PUN"
	random_spawns_possible = FALSE
	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_PUN_PUN
	departments_list = list(/datum/job_department/service)
	exclusive_mail_goodies = TRUE
	mail_goodies = list(
		/obj/item/food/grown/banana = 4,
		/obj/effect/spawner/random/entertainment/money_medium = 3,
		/obj/item/clothing/head/helmet/monkey_sentience = 1,
		/obj/item/book/granter/sign_language = 1,
		/obj/item/food/monkeycube = 1,
	)
	rpg_title = "Homunculus"
	allow_bureaucratic_error = FALSE
	job_flags = (STATION_JOB_FLAGS|STATION_TRAIT_JOB_FLAGS)&~JOB_ASSIGN_QUIRKS

/datum/job/pun_pun/get_spawn_mob(client/player_client, atom/spawn_point)
	if (!player_client)
		return
	var/mob/living/monky = new spawn_type(get_turf(spawn_point))
	if(!GLOB.the_one_and_only_punpun)
		GLOB.the_one_and_only_punpun = monky
	return monky

/datum/job/pun_pun/after_spawn(mob/living/carbon/human/monkey, client/player_client)
	. = ..()
	monkey.crewlike_monkify()

/datum/outfit/job/pun_pun
	name = "Pun Pun"
	jobtype = /datum/job/pun_pun

	id_trim = /datum/id_trim/job/pun_pun
	belt = /obj/item/modular_computer/pda/pun_pun
	uniform = /obj/item/clothing/under/suit/waiter
	backpack_contents = list(
		/obj/item/gun/ballistic/shotgun/monkey = 1,
		/obj/item/storage/box/beanbag = 1,
	)
	shoes = null //monkeys cannot equip shoes
