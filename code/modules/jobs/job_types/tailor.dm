/datum/job/tailor
	title = JOB_TAILOR
	description = "Make clothes, fix clothes, produce cloth, take measurements, fit clothes."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/tailor
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_TAILOR
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/service,
		)
	rpg_title = "Clothier"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS


/datum/outfit/job/tailor
	name = "Tailor"
	jobtype = /datum/job/tailor

	id_trim = /datum/id_trim/job/tailor
	uniform = /obj/item/clothing/under/rank/civilian/tailor
	belt = /obj/item/pda
	ears = /obj/item/radio/headset/headset_srv
	neck = /obj/item/clothing/neck/measuring_tape
	l_hand = /obj/item/scissors
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/regular/tailor
