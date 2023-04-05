/datum/job/nurse
	title = JOB_NURSE
	description = "Assist the doctors and other medical personnel. \
		Put on bandages, administer medication, and try not to accidentally kill anyone."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the medical department and Chief Medical Officer"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "NURSE"

	outfit = /datum/outfit/job/nurse
	plasmaman_outfit = /datum/outfit/plasmaman/medical

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_NURSE
	bounty_types = CIV_JOB_MED
	departments_list = list(
		/datum/job_department/medical,
		)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/reagent_containers/syringe, /obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/food/lollipop = 6,
		/obj/item/reagent_containers/syringe/multiver = 6,
		/obj/item/storage/pill_bottle/epinephrine = 6,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 6,
		/obj/effect/spawner/random/medical/organs = 5,
		/obj/effect/spawner/random/medical/memeorgans = 1,
	)
	rpg_title = "Low Cleric"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS


/datum/outfit/job/nurse
	name = "Nurse"
	jobtype = /datum/job/nurse

	id_trim = /datum/id_trim/job/nurse
	uniform = /obj/item/clothing/under/rank/medical/doctor/nurse
	belt = /obj/item/modular_computer/pda/medical
	ears = /obj/item/radio/headset/headset_med
	head = /obj/item/clothing/head/costume/nursehat
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_hand = /obj/item/storage/medkit/regular

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe
	box = /obj/item/storage/box/survival/medical
	skillchips = list(/obj/item/skillchip/entrails_reader)
