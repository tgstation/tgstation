/datum/job/steward
	title = JOB_STEWARD
	description = "Serve the crew,\
		pass food complaints to the Chef,\
		help Bartender solve bar fights."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the service department and Head of Personnel"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "STEWARD"

	outfit = /datum/outfit/job/steward
	plasmaman_outfit = /datum/outfit/plasmaman/bar

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BARTENDER
	bounty_types = CIV_JOB_DRINK
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/reagent_containers/cup/rag, /obj/item/clothing/neck/tie/blue)

	mail_goodies = list(
		/obj/item/storage/box/drinkingglasses = 30,
		/obj/item/reagent_containers/cup/glass/flask = 10,
		/obj/item/reagent_containers/spray/cleaner = 10,
		/obj/item/soap/nanotrasen = 10,
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Waiter"

/datum/outfit/job/steward
	name = "Steward"
	jobtype = /datum/job/steward

	id_trim = /datum/id_trim/job/steward
	uniform = /obj/item/clothing/under/suit/waiter
	backpack_contents = list(
		/obj/item/reagent_containers/spray/cleaner = 1,
		)
	belt = /obj/item/modular_computer/pda
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/bag/tray
