/datum/job/ghost
	title = JOB_SPOOKTOBER_GHOST
	description = "Spook the crew.  Get your bedsheet stolen and run around the station naked."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_CHAPLAIN
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/ghost
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/clothing/suit/costume/ghost_sheet)

	mail_goodies = list(
		/obj/item/clothing/suit/costume/ghost_sheet
	)

	rpg_title = "Spectre"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER

/datum/outfit/job/ghost
	name = "Ghost"
	jobtype = /datum/job/ghost

	suit = /obj/item/clothing/suit/costume/ghost_sheet
	shoes = null
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant

	backpack_contents = list()
