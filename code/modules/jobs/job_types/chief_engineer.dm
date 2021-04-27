/datum/job/chief_engineer
	title = "Chief Engineer"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	head_announce = list("Engineering")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_ENGINEERING

	outfit = /datum/outfit/job/ce
	plasmaman_outfit = /datum/outfit/plasmaman/chief_engineer

	bounty_types = CIV_JOB_ENG
	departments = DEPARTMENT_ENGINEERING | DEPARTMENT_COMMAND
	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_ENG

	family_heirlooms = list(
		/obj/item/clothing/head/hardhat/white,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
	)
		
	liver_traits = list(
		TRAIT_ENGINEER_METABOLISM,
		TRAIT_ROYAL_METABOLISM,
	)

	mail_goodies = list(
		/obj/item/food/cracker = 25, //you know. for poly
		/obj/item/stack/sheet/mineral/diamond = 15,
		/obj/item/stack/sheet/mineral/uranium/five = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 15,
		/obj/item/stack/sheet/mineral/gold = 15,
		/obj/effect/spawner/lootdrop/space/fancytool/engineonly = 3,
	)

/datum/job/chief_engineer/announce(mob/living/carbon/human/H, announce_captaincy = FALSE)
	..()
	if(announce_captaincy)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Due to staffing shortages, newly promoted Acting Captain [H.real_name] on deck!"))

/datum/outfit/job/ce
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/chief_engineer
	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1,
		/obj/item/modular_computer/tablet/preset/advanced/command/engineering = 1,
		)
	belt = /obj/item/storage/belt/utility/chief/full
	ears = /obj/item/radio/headset/heads/ce
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hardhat/white
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_pocket = /obj/item/pda/heads/ce

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

	box = /obj/item/storage/box/survival/engineer
	chameleon_extras = /obj/item/stamp/ce
	skillchips = list(
		/obj/item/skillchip/job/engineer,
		)
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/ce/rig
	name = "Chief Engineer (Hardsuit)"

	suit = /obj/item/clothing/suit/space/hardsuit/engine/elite
	suit_store = /obj/item/tank/internals/oxygen
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/color/yellow
	head = null
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/magboots/advance
	internals_slot = ITEM_SLOT_SUITSTORE
