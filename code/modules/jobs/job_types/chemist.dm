/datum/job/chemist
	title = JOB_CHEMIST
	description = "Supply the doctors with chemicals, make medicine, as well as \
		less likable substances in the comfort of a fully reinforced room."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = SUPERVISOR_CMO
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CHEMIST"

	outfit = /datum/outfit/job/chemist
	plasmaman_outfit = /datum/outfit/plasmaman/chemist

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHEMIST
	bounty_types = CIV_JOB_CHEM
	departments_list = list(
		/datum/job_department/medical,
	)

	family_heirlooms = list(/obj/item/book/manual/wiki/chemistry, /obj/item/ph_booklet)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/bottle/flash_powder = 15,
		/obj/item/reagent_containers/cup/bottle/exotic_stabilizer = 5,
		/obj/item/reagent_containers/cup/bottle/leadacetate = 5,
		/obj/item/paper/secretrecipe = 1
	)
	rpg_title = "Alchemist"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	id_trim = /datum/id_trim/job/chemist
	uniform = /obj/item/clothing/under/rank/medical/chemist
	suit = /obj/item/clothing/suit/toggle/labcoat/chemist
	belt = /obj/item/modular_computer/pda/chemist
	ears = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/reagent_containers/cup/bottle/random_buffer
	r_pocket = /obj/item/reagent_containers/dropper

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel/chem
	duffelbag = /obj/item/storage/backpack/duffelbag/chemistry
	messenger = /obj/item/storage/backpack/messenger/chem

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
