/datum/job/science_student
	title = JOB_SCIENCE_STUDENT
	description = "Be involved in experiments, help Scientists perform research,\
		get feed to the slimes."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 3
	supervisors = "the science department and Research Director"
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SCIENCE_STUDENT"

	outfit = /datum/outfit/job/science_student
	plasmaman_outfit = /datum/outfit/plasmaman/science

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_BALLMER_SCIENTIST)

	display_order = JOB_DISPLAY_ORDER_SCIENCE_STUDENT
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
	rpg_title = "Junior Thaumaturgist"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	job_tone = "boom"


/datum/outfit/job/science_student
	name = "Science Student"
	jobtype = /datum/job/science_student

	id_trim = /datum/id_trim/job/science_student
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/pda/science
	ears = /obj/item/radio/headset/headset_sci
	shoes = /obj/item/clothing/shoes/sneakers/white

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science
