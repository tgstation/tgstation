/datum/job/roboticist
	title = "Roboticist"
	department_head = list("Research Director")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	bounty_types = CIV_JOB_ROBO

	outfit = /datum/outfit/job/roboticist
	plasmaman_outfit = /datum/outfit/plasmaman/robotics

	departments = DEPARTMENT_SCIENCE
	display_order = JOB_DISPLAY_ORDER_ROBOTICIST
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	family_heirlooms = list(
		/obj/item/toy/plush/pkplush,
	)

	mail_goodies = list(
		/obj/item/storage/box/flashes = 20,
		/obj/item/stack/sheet/iron/twenty = 15,
		/obj/item/modular_computer/tablet/preset/advanced = 5,
	)

/datum/job/roboticist/New()
	. = ..()
	family_heirlooms += subtypesof(/obj/item/toy/prize)

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	id_trim = /datum/id_trim/job/roboticist
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat/roboticist
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_sci
	l_pocket = /obj/item/pda/roboticist

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox
	duffelbag = /obj/item/storage/backpack/duffelbag/toxins

	pda_slot = ITEM_SLOT_LPOCKET
	skillchips = list(
		/obj/item/skillchip/job/roboticist,
		)
