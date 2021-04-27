/datum/job/cargo_technician
	title = "Cargo Technician"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/cargo_tech
	plasmaman_outfit = /datum/outfit/plasmaman/cargo

	bounty_types = CIV_JOB_RANDOM
	departments = DEPARTMENT_CARGO
	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

	family_heirlooms = list(
		/obj/item/clipboard,
		)

	mail_goodies = list(
		/obj/item/pizzabox = 10,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 4,
		/obj/item/stack/sheet/mineral/diamond = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 1
	)

/datum/outfit/job/cargo_tech
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_technician

	id_trim = /datum/id_trim/job/cargo_technician
	uniform = /obj/item/clothing/under/rank/cargo/tech
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/cargo = 1,
		)
	belt = /obj/item/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo
	l_hand = /obj/item/export_scanner
