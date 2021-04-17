/datum/job/captain
	title = "Captain"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list("CentCom")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	selection_color = "#ccccff"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND

	outfit = /datum/outfit/job/captain
	plasmaman_outfit = /datum/outfit/plasmaman/captain

	departments = DEPARTMENT_COMMAND
	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	family_heirlooms = list(
		/obj/item/reagent_containers/food/drinks/flask/gold,
		)
	liver_traits = list(
		TRAIT_ROYAL_METABOLISM,
		)

/datum/job/captain/announce(mob/living/carbon/human/H, announce_captaincy = TRUE)
	..()
	if(announce_captaincy)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Captain [H.real_name] on deck!"))

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/captain
	uniform =  /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1,
		/obj/item/station_charter = 1,
		)
	belt = /obj/item/pda/captain
	ears = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/captain
	head = /obj/item/clothing/head/caphat
	shoes = /obj/item/clothing/shoes/sneakers/brown

	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain

	accessory = /obj/item/clothing/accessory/medal/gold/captain
	chameleon_extras = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/stamp/captain,
		)
	implants = list(/obj/item/implant/mindshield)
	skillchips = list(
		/obj/item/skillchip/disk_verifier,
		)

/datum/outfit/job/captain/hardsuit
	name = "Captain (Hardsuit)"

	suit = /obj/item/clothing/suit/space/hardsuit/swat/captain
	suit_store = /obj/item/tank/internals/oxygen
	mask = /obj/item/clothing/mask/gas/atmos/captain
