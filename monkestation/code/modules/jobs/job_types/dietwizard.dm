/datum/job/dietwizard
	title = JOB_SPOOKTOBER_WIZARD
	description = "Amaze the crew! Get murdered because there are actual wizards out there.  Have your costume confiscated as contraband."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_HEAD_OF_PERSONNEL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/dietwizard
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/staff, /obj/item/clothing/head/wizard/fake)

	mail_goodies = list(
		/obj/item/staff,
		/obj/item/storage/box/snappops,
		/obj/item/grenade/smokebomb
	)

	rpg_title = "Hedge Mage"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER

/datum/outfit/job/dietwizard
	name = "Diet Wizard"
	jobtype = /datum/job/dietwizard

	head = /obj/item/clothing/head/wizard/fake
	suit = /obj/item/clothing/suit/wizrobe/fake
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant
	shoes = /obj/item/clothing/shoes/sandal
	l_hand = /obj/item/staff

	backpack_contents = list(/obj/item/storage/box/snappops, /obj/item/storage/box/snappops, /obj/item/grenade/smokebomb, /obj/item/grenade/smokebomb)
