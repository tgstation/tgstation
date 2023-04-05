/datum/job/test_subject
	title = JOB_TEST_SUBJECT
	description = "Be involved in experiments, \
		get your brain put into a mech, \
		get feed to the slimes."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the science department and Research Director"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "TEST_SUBJECT"
	difficulty = JOB_VERY_EASY

	outfit = /datum/outfit/job/test_subject
	plasmaman_outfit = /datum/outfit/plasmaman/science

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_BALLMER_SCIENTIST)

	display_order = JOB_DISPLAY_ORDER_TEST_SUBJECT
	bounty_types = CIV_JOB_SCI
	departments_list = list(
		/datum/job_department/science,
		)

	family_heirlooms = list(/obj/item/toy/plush/slimeplushie)

	mail_goodies = list(
		/obj/item/raw_anomaly_core/random = 10,
		/obj/item/disk/design_disk/bepis = 2,
		/obj/item/camera_bug = 1
	)
	rpg_title = "Thaumaturgist Subject"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/test_subject
	name = "Test Subject"
	jobtype = /datum/job/test_subject

	id_trim = /datum/id_trim/job/test_subject
	uniform = /obj/item/clothing/under/rank/rnd/test_subject
	belt = /obj/item/modular_computer/pda/science
	ears = /obj/item/radio/headset/headset_sci
	shoes = /obj/item/clothing/shoes/sneakers/white

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science
