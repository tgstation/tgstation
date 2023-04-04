/datum/job/cargo_clerk
	title = JOB_CARGO_CLERK
	description = "Keep track of crates, containers, and packages,\
		make sure they're sent to the right recipients,\
		accept orders from the front desk."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the cargo department and the Quartermaster"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CARGO_CLERK"

	outfit = /datum/outfit/job/cargo_clerk
	plasmaman_outfit = /datum/outfit/plasmaman/cargo

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR
	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(/obj/item/clipboard)

	mail_goodies = list(
		/obj/item/pizzabox = 10,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 4,
		/obj/item/stack/sheet/mineral/diamond = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 1
	)
	rpg_title = "Junior Merchantman"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/cargo_clerk
	name = "Cargo Clerk"
	jobtype = /datum/job/cargo_clerk

	backpack_contents = list(
		/obj/item/clipboard = 1,
	)
	id_trim = /datum/id_trim/job/cargo_clerk
	uniform = /obj/item/clothing/under/suit/beige
	belt = /obj/item/modular_computer/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo
	l_hand = /obj/item/universal_scanner
