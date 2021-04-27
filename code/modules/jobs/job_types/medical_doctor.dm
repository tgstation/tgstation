/datum/job/doctor
	title = "Medical Doctor"
	department_head = list("Chief Medical Officer")
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/doctor
	plasmaman_outfit = /datum/outfit/plasmaman/medical

	bounty_types = CIV_JOB_MED
	departments = DEPARTMENT_MEDICAL
	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	family_heirlooms = list(
		/obj/item/storage/firstaid/ancient/heirloom,
	)
		
	liver_traits = list(
		TRAIT_MEDICAL_METABOLISM,
	)

	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/advanced = 6,
		/datum/reagent/toxin/formaldehyde = 6,
		/obj/effect/spawner/lootdrop/organ_spawner = 5,
		/obj/effect/spawner/lootdrop/memeorgans = 1,
	)

/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor

	id_trim = /datum/id_trim/job/medical_doctor
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit =  /obj/item/clothing/suit/toggle/labcoat
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/pda/medical
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_hand = /obj/item/storage/firstaid/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
	skillchips = list(
		/obj/item/skillchip/entrails_reader,
		)
