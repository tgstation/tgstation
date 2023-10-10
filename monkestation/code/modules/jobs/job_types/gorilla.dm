/datum/job/gorilla
	title = JOB_SPOOKTOBER_GORILLA
	description = "Film a monster movie. Battle godzilla. Get arrested for roaring at lizards."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_HEAD_OF_PERSONNEL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/gorilla
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/clothing/suit/hooded/gorilla)

	mail_goodies = list(
		/obj/item/food/grown/banana
	)

	rpg_title = "Dire Ape"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER

/datum/outfit/job/gorilla
	name = "Gorilla"
	jobtype = /datum/job/gorilla

	suit = /obj/item/clothing/suit/hooded/gorilla
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant

	backpack_contents = list(
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana
	)
