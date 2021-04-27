/datum/job/station_engineer
	title = "Station Engineer"
	department_head = list("Chief Engineer")
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/engineer
	plasmaman_outfit = /datum/outfit/plasmaman/engineering

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	bounty_types = CIV_JOB_ENG
	departments = DEPARTMENT_ENGINEERING
	display_order = JOB_DISPLAY_ORDER_STATION_ENGINEER

	family_heirlooms = list(
		/obj/item/clothing/head/hardhat,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		)
	liver_traits = list(
		TRAIT_ENGINEER_METABOLISM,
		)

	mail_goodies = list(
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10,
		/obj/item/holosign_creator/engineering = 8,
		/obj/item/clothing/head/hardhat/red/upgraded = 1
	)

/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/station_engineer

	id_trim = /datum/id_trim/job/station_engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/advanced/engineering = 1,
		)
	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_eng
	head = /obj/item/clothing/head/hardhat
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/pda/engineering
	r_pocket = /obj/item/t_scanner

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET
	skillchips = list(
		/obj/item/skillchip/job/engineer,
		)

/datum/outfit/job/engineer/gloved
	name = "Station Engineer (Gloves)"

	gloves = /obj/item/clothing/gloves/color/yellow

/datum/outfit/job/engineer/gloved/rig
	name = "Station Engineer (Hardsuit)"

	suit = /obj/item/clothing/suit/space/hardsuit/engine
	suit_store = /obj/item/tank/internals/oxygen
	head = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/engineer/gloved/gunner
	id_trim = /datum/id_trim/job/station_engineer/gunner

/datum/outfit/job/engineer/gloved/rig/gunner
	id_trim = /datum/id_trim/job/station_engineer/gunner
