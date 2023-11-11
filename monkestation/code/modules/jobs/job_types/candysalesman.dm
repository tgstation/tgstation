/datum/job/candysalesman
	title = JOB_SPOOKTOBER_CANDYSALESMAN
	description = "Sell candy to the crew. Get high on your own supply. Subject people to unsafe working conditions."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_HEAD_OF_PERSONNEL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/candysalesman
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/cane)

	mail_goodies = list(
		/obj/item/storage/spooky
	)

	rpg_title = "Purveyor of Sweets"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER

/datum/outfit/job/candysalesman
	name = "Candy Salesman"
	jobtype = /datum/job/candysalesman

	head = /obj/item/clothing/head/wonka
	uniform = /obj/item/clothing/under/wonka
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant

	backpack_contents = list(
		/obj/item/cane,
		/obj/item/storage/pill_bottle/maintenance_pill/full,
		/obj/item/storage/spooky,
		/obj/item/storage/spooky,
		/obj/item/storage/spooky
	)
