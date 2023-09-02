/datum/job/geneticist
	title = JOB_GENETICIST
	description = "Alter genomes, turn monkeys into humans (and vice-versa), and make DNA backups."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = SUPERVISOR_RD
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "GENETICIST"

	outfit = /datum/outfit/job/geneticist
	plasmaman_outfit = /datum/outfit/plasmaman/genetics
	departments_list = list(
		/datum/job_department/science,
		)

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_GENETICIST
	bounty_types = CIV_JOB_SCI

	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 10
	)

	family_heirlooms = list(/obj/item/clothing/under/shorts/purple)
	rpg_title = "Genemancer"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/geneticist
	name = "Geneticist"
	jobtype = /datum/job/geneticist

	id_trim = /datum/id_trim/job/geneticist
	uniform = /obj/item/clothing/under/rank/rnd/geneticist
	suit = /obj/item/clothing/suit/toggle/labcoat/genetics
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/modular_computer/pda/geneticist
	ears = /obj/item/radio/headset/headset_sci
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/sequence_scanner

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel/gen
	duffelbag = /obj/item/storage/backpack/duffelbag/genetics
