/datum/job/chief_medical_officer
	title = "Chief Medical Officer"
	department_head = list("Captain")
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	head_announce = list(RADIO_CHANNEL_MEDICAL)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MEDICAL

	outfit = /datum/outfit/job/cmo
	plasmaman_outfit = /datum/outfit/plasmaman/chief_medical_officer

	bounty_types = CIV_JOB_MED
	departments = DEPARTMENT_MEDICAL | DEPARTMENT_COMMAND
	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_MED

	family_heirlooms = list(
		/obj/item/storage/firstaid/ancient/heirloom,
	)

	liver_traits = list(
		TRAIT_MEDICAL_METABOLISM,
		TRAIT_ROYAL_METABOLISM,
	)

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/organ_spawner = 10,
		/obj/effect/spawner/lootdrop/memeorgans = 8,
		/obj/effect/spawner/lootdrop/space/fancytool/advmedicalonly = 4,
		/obj/effect/spawner/lootdrop/space/fancytool/raremedicalonly = 1,
	)

/datum/job/chief_medical_officer/announce(mob/living/carbon/human/H, announce_captaincy = FALSE)
	..()
	if(announce_captaincy)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Due to staffing shortages, newly promoted Acting Captain [H.real_name] on deck!"))

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/chief_medical_officer

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/chief_medical_officer
	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	suit_store = /obj/item/flashlight/pen/paramedic
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1,
		/obj/item/modular_computer/tablet/preset/advanced/command = 1,
		)
	belt = /obj/item/pda/heads/cmo
	ears = /obj/item/radio/headset/heads/cmo
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_pocket = /obj/item/pinpointer/crew
	l_hand = /obj/item/storage/firstaid/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(
		/obj/item/gun/syringe,
		/obj/item/stamp/cmo,
		)
	skillchips = list(
		/obj/item/skillchip/entrails_reader,
		)

/datum/outfit/job/cmo/hardsuit
	name = "Chief Medical Officer (Hardsuit)"

	suit = /obj/item/clothing/suit/space/hardsuit/medical
	suit_store = /obj/item/tank/internals/oxygen
	mask = /obj/item/clothing/mask/breath/medical
	r_pocket = /obj/item/flashlight/pen/paramedic
