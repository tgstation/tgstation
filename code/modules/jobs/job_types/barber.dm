/datum/job/barber
	title = JOB_BARBER
	description = "Cut hair, give back massages, listen to complaints from customers about their day."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/barber
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BARBER
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/service,
		)
	rpg_title = "Barber Surgeon"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS


/datum/outfit/job/barber
	name = "Barber"
	jobtype = /datum/job/barber

	id_trim = /datum/id_trim/job/barber
	uniform = /obj/item/clothing/under/rank/civilian/barber
	belt = /obj/item/pda
	ears = /obj/item/radio/headset/headset_srv
	l_hand = /obj/item/scissors
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret/black
