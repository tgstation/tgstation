/datum/job/quartermaster
	title = "Quartermaster"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"
	exp_type_department = EXP_TYPE_SUPPLY // This is so the jobs menu can work properly

	outfit = /datum/outfit/job/quartermaster
	plasmaman_outfit = /datum/outfit/plasmaman/cargo

	bounty_types = CIV_JOB_RANDOM
	departments = DEPARTMENT_CARGO
	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	liver_traits = list(
		TRAIT_PRETENDER_ROYAL_METABOLISM,
		)

/datum/job/quartermaster/announce(mob/living/carbon/human/H, announce_captaincy = FALSE)
	..()
	if(announce_captaincy)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Due to extreme staffing shortages, newly promoted Acting Captain [H.real_name] on deck!"))

	family_heirlooms = list(
		/obj/item/stamp,
		/obj/item/stamp/denied,
		)

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/quartermaster

	id_trim = /datum/id_trim/job/quartermaster
	uniform = /obj/item/clothing/under/rank/cargo/qm
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/cargo = 1,
		)
	belt = /obj/item/pda/quartermaster
	ears = /obj/item/radio/headset/headset_cargo
	glasses = /obj/item/clothing/glasses/sunglasses
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_hand = /obj/item/clipboard

	chameleon_extras = /obj/item/stamp/qm
