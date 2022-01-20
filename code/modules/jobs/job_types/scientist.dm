/datum/job/scientist
	title = JOB_SCIENTIST
	description = "Do experiments, perform research, feed the slimes, make bombs."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/scientist
	plasmaman_outfit = /datum/outfit/plasmaman/science

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_SCIENTIST
	bounty_types = CIV_JOB_SCI
	departments_list = list(
		/datum/job_department/science,
		)

	family_heirlooms = list(/obj/item/toy/plush/slimeplushie)

	mail_goodies = list(
		/obj/item/raw_anomaly_core/random = 10,
		/obj/item/disk/tech_disk/spaceloot = 2,
		/obj/item/camera_bug = 1
	)
	rpg_title = "Thaumaturgist"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS


/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	id_trim = /datum/id_trim/job/scientist
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/science = 1,
		)
	belt = /obj/item/pda/science
	ears = /obj/item/radio/headset/headset_sci
	shoes = /obj/item/clothing/shoes/sneakers/white

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/outfit/job/scientist/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(0.4))
		neck = /obj/item/clothing/neck/tie/horrible

/datum/outfit/job/scientist/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/neck/tie/horrible
