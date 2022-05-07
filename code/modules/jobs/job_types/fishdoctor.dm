/datum/job/fishdoctor
	title = JOB_FISHDOCTOR
	description = "Catch fish, breed fish, eat fish."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/fishdoctor
	plasmaman_outfit = /datum/outfit/plasmaman/viro

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_FISHDOCTOR
	bounty_types = CIV_JOB_FISH
	departments_list = list(
		/datum/job_department/medical,
		)

	family_heirlooms = list(/obj/item/fishing_rod)

	mail_goodies = list(
		/obj/item/fish_feed = 10,
	)
	rpg_title = "Fishologist"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/fishdoctor
	name = "Fish Doctor"
	jobtype = /datum/job/fishdoctor

	id_trim = /datum/id_trim/job/fishdoctor
	uniform = /obj/item/clothing/under/rank/medical/scrubs/green
	suit = /obj/item/clothing/suit/apron/waders
	suit_store = /obj/item/knife/hunting
	belt = /obj/item/modular_computer/tablet/pda/fish
	ears = /obj/item/radio/headset/headset_med
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/workboots
	l_hand = /obj/item/fishing_rod

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel/vir
	duffelbag = /obj/item/storage/backpack/duffelbag/virology

	box = /obj/item/storage/box/survival/medical
