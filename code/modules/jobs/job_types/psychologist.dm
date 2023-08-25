/datum/job/psychologist
	title = JOB_PSYCHOLOGIST
	description = "Advocate sanity, self-esteem, and teamwork in a station \
		staffed with headcases."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel and the Chief Medical Officer"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "PSYCHOLOGIST"

	outfit = /datum/outfit/job/psychologist
	plasmaman_outfit = /datum/outfit/plasmaman/psychologist

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_PSYCHOLOGIST
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/mannitol = 30,
		/obj/item/storage/pill_bottle/happy = 5,
		/obj/item/gun/syringe = 1
	)
	rpg_title = "Snake Oil Salesman"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/psychologist
	name = "Psychologist"
	jobtype = /datum/job/psychologist

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/psychologist
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	backpack_contents = list(
		/obj/item/storage/pill_bottle/happinesspsych,
		/obj/item/storage/pill_bottle/lsdpsych,
		/obj/item/storage/pill_bottle/mannitol,
		/obj/item/storage/pill_bottle/paxpsych,
		/obj/item/storage/pill_bottle/psicodine,
		)
	belt = /obj/item/modular_computer/pda/psychologist
	ears = /obj/item/radio/headset/headset_srvmed
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/clipboard
	neck = /obj/item/clothing/neck/tie/black/tied
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	messenger = /obj/item/storage/backpack/messenger/med

	pda_slot = ITEM_SLOT_BELT
	skillchips = list(/obj/item/skillchip/job/psychology)
