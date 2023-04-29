/datum/job/fisherman
	title = JOB_FISHERMAN
	description = "Catch fish in medical."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CMO
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "FISHERMAN"

	outfit = /datum/outfit/job/fisherman
	plasmaman_outfit = /datum/outfit/plasmaman/viro

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_VIROLOGIST
	bounty_types = CIV_JOB_VIRO
	departments_list = list(
		/datum/job_department/medical,
		)

	family_heirlooms = list(/obj/item/reagent_containers/syringe)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 10,
		/obj/item/reagent_containers/cup/bottle/synaptizine = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/uranium = 5,
	)
	rpg_title = "Plague Doctor"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/fisherman
	name = "Fisherman"
	jobtype = /datum/job/fisherman

	id_trim = /datum/id_trim/job/fisherman
	uniform = /obj/item/clothing/under/misc/overalls
	belt = /obj/item/modular_computer/pda/viro
	ears = /obj/item/radio/headset/headset_med
	head = /obj/item/clothing/head/soft
	shoes = /obj/item/clothing/shoes/workboots

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
