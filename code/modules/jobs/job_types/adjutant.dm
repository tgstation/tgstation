/datum/job/adjutant
	title = JOB_ADJUTANT
	description = "Be the ultimate sidekick to the command team, follow them around assisting, \
		fetch their coffee, and nod approvingly at their decisions (even if they're terrible). \
		Watch computers at bridge with the Captain."
	department_head = list(JOB_CAPTAIN)
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "department heads and the Captain"
	minimal_player_age = 7
	exp_requirements = 60 //Play one round, we hope you at least know how to talk
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_COMMAND
	config_tag = "ADJUTANT"

	outfit = /datum/outfit/job/adjutant
	plasmaman_outfit = /datum/outfit/plasmaman/adjutant

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CIV

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_ADJUTANT
	department_for_prefs = /datum/job_department/command
	departments_list = list(
		/datum/job_department/command,
	)

	family_heirlooms = list(/obj/item/radio/headset/headset_com, /obj/item/pen/fountain)

	mail_goodies = list(
		/obj/item/paper_bin = 20,
		/obj/item/clipboard = 20,
		/obj/item/storage/briefcase = 20,
		/obj/item/folder/biscuit/unsealed/confidential = 10,
		/obj/item/stamp/denied = 10,
		/obj/item/stamp = 10,
		/obj/item/paper/paperslip/corporate = 5,
		/obj/item/pen/fountain = 5,
		/obj/item/reagent_containers/cup/glass/mug/nanotrasen = 5,
		/obj/item/clothing/accessory/medal/conduct = 1,
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS
	rpg_title = "Commander's Squire"


/datum/outfit/job/adjutant
	name = "Adjutant"
	jobtype = /datum/job/adjutant

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/adjutant
	uniform = /obj/item/clothing/under/rank/adjutant
	belt = /obj/item/modular_computer/pda/heads
	ears = /obj/item/radio/headset/headset_com
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/soft/blue
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/clipboard

	implants = list(/obj/item/implant/mindshield)
