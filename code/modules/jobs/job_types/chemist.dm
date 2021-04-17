/datum/job/chemist
	title = "Chemist"
	department_head = list("Chief Medical Officer")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	exp_type = EXP_TYPE_CREW
	exp_requirements = 60

	outfit = /datum/outfit/job/chemist
	plasmaman_outfit = /datum/outfit/plasmaman/chemist

	bounty_types = CIV_JOB_CHEM
	departments = DEPARTMENT_MEDICAL
	display_order = JOB_DISPLAY_ORDER_CHEMIST
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	family_heirlooms = list(
		/obj/item/book/manual/wiki/chemistry,
		/obj/item/ph_booklet,
		)
	liver_traits = list(
		TRAIT_MEDICAL_METABOLISM,
		)

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	id_trim = /datum/id_trim/job/chemist
	uniform = /obj/item/clothing/under/rank/medical/chemist
	suit =  /obj/item/clothing/suit/toggle/labcoat/chemist
	belt = /obj/item/pda/chemist
	ears = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/reagent_containers/glass/bottle/random_buffer
	r_pocket = /obj/item/reagent_containers/dropper

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel/chem
	duffelbag = /obj/item/storage/backpack/duffelbag/chemistry

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
