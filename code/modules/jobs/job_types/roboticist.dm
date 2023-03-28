/datum/job/roboticist
	title = JOB_ROBOTICIST
	description = "Build and repair the AI and cyborgs, create mechs."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = SUPERVISOR_RD
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	bounty_types = CIV_JOB_ROBO
	config_tag = "ROBOTICIST"

	outfit = /datum/outfit/job/roboticist
	plasmaman_outfit = /datum/outfit/plasmaman/robotics
	departments_list = list(
		/datum/job_department/science,
		)

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST

	mail_goodies = list(
		/obj/item/storage/box/flashes = 20,
		/obj/item/stack/sheet/iron/twenty = 15,
		/obj/item/modular_computer/laptop = 5
	)

	family_heirlooms = list(/obj/item/toy/plush/pkplush)
	rpg_title = "Necromancer"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/job/roboticist/New()
	. = ..()
	family_heirlooms += subtypesof(/obj/item/toy/mecha)

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	id_trim = /datum/id_trim/job/roboticist
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat/roboticist
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_sci
	l_pocket = /obj/item/modular_computer/pda/roboticist

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_LPOCKET
	skillchips = list(/obj/item/skillchip/job/roboticist)

/datum/outfit/job/roboticist/mod
	name = "Roboticist (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/standard
	suit = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE
