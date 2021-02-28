/datum/job/head_of_personnel
	title = "Head of Personnel"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	head_announce = list(RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SERVICE)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SERVICE

	outfit = /datum/outfit/job/hop
	departments = DEPARTMENT_COMMAND | DEPARTMENT_SERVICE

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SRV
	bounty_types = CIV_JOB_RANDOM

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL

/datum/job/head_of_personnel/announce(mob/living/carbon/human/H, announce_captaincy = FALSE)
	..()
	if(announce_captaincy)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Due to staffing shortages, newly promoted Acting Captain [H.real_name] on deck!"))

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/head_of_personnel

	id = /obj/item/card/id/advanced/silver
	belt = /obj/item/pda/heads/hop
	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/civilian/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hopcap
	backpack_contents = list(/obj/item/storage/box/ids=1,\
		/obj/item/melee/classic_baton/telescopic=1, /obj/item/modular_computer/tablet/preset/advanced/command = 1)

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/hop)

	id_trim = /datum/id_trim/job/head_of_personnel

/datum/outfit/job/hop/pre_equip(mob/living/carbon/human/H)
	..()
	if(locate(/datum/holiday/ianbirthday) in SSevents.holidays)
		undershirt = /datum/sprite_accessory/undershirt/ian

