/datum/job/paramedic
	title = "Paramedic"
	department_head = list("Chief Medical Officer")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/paramedic
	plasmaman_outfit = /datum/outfit/plasmaman/paramedic

	bounty_types = CIV_JOB_MED
	departments = DEPARTMENT_MEDICAL
	display_order = JOB_DISPLAY_ORDER_PARAMEDIC
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	family_heirlooms = list(
		/obj/item/storage/firstaid/ancient/heirloom,
		)
	liver_traits = list(
		TRAIT_MEDICAL_METABOLISM,
		)

/datum/outfit/job/paramedic
	name = "Paramedic"
	jobtype = /datum/job/paramedic

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/paramedic
	uniform = /obj/item/clothing/under/rank/medical/paramedic
	suit =  /obj/item/clothing/suit/toggle/labcoat/paramedic
	suit_store = /obj/item/flashlight/pen/paramedic
	backpack_contents = list(
		/obj/item/roller = 1,
		)
	belt = /obj/item/storage/belt/medical/paramedic
	ears = /obj/item/radio/headset/headset_med
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	head = /obj/item/clothing/head/soft/paramedic
	shoes = /obj/item/clothing/shoes/sneakers/blue
	l_pocket = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
	pda_slot = ITEM_SLOT_LPOCKET
	skillchips = list(
		/obj/item/skillchip/quickercarry,
		)
