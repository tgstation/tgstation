/datum/job/research_director
	title = "Research Director"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	head_announce = list("Science")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_type_department = EXP_TYPE_SCIENCE
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/rd
	plasmaman_outfit = /datum/outfit/plasmaman/research_director
	departments = DEPARTMENT_SCIENCE | DEPARTMENT_COMMAND

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR
	bounty_types = CIV_JOB_SCI

	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 30,
		/obj/item/circuitboard/machine/sleeper/party = 3,
		/obj/item/borg/upgrade/ai = 2
	)

	family_heirlooms = list(/obj/item/toy/plush/slimeplushie)

/datum/job/research_director/announce(mob/living/carbon/human/H, announce_captaincy = FALSE)
	..()
	if(announce_captaincy)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Due to staffing shortages, newly promoted Acting Captain [H.real_name] on deck!"))

/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/research_director

	id = /obj/item/card/id/advanced/silver
	belt = /obj/item/pda/heads/rd
	ears = /obj/item/radio/headset/heads/rd
	uniform = /obj/item/clothing/under/rank/rnd/research_director
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/toggle/labcoat
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/laser_pointer
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1, /obj/item/modular_computer/tablet/preset/advanced/command=1)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox
	duffelbag = /obj/item/storage/backpack/duffelbag/toxins

	skillchips = list(/obj/item/skillchip/job/research_director)

	chameleon_extras = /obj/item/stamp/rd

	id_trim = /datum/id_trim/job/research_director

/datum/outfit/job/rd/rig
	name = "Research Director (Hardsuit)"

	l_hand = null
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/rd
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
