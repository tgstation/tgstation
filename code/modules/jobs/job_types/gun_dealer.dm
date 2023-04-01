/obj/effect/landmark/start/gun_dealer
	name = "Gun Dealer"
	icon_state = "Gun Dealer"

/datum/job/gun_dealer
	title = JOB_GUN_DEALER
	description = "Sell guns, sell ammo, sell excuses for Security to arrest people."
	department_head = list("Quartermaster")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Quartermaster"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/gun_dealer
	plasmaman_outfit = /datum/outfit/plasmaman/cargo
	config_tag = "GUN_DEALER"
	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_GUN_DEALER
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(/obj/item/clipboard)

	mail_goodies = list(
		/obj/item/pizzabox = 10,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 4,
		/obj/item/stack/sheet/mineral/diamond = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/obj/item/clothing/under/rank/cargo/gun_dealer
	name = "gun dealer outfit"
	desc = "/advert raid"
	icon_state = "gunner"
	worn_icon_state = "gunner"

/obj/item/clothing/suit/gun_dealer
	name = "gun dealer coat"
	desc = "What're ya buyin'?"
	icon_state = "gunner"
	worn_icon_state = "gunner"

/obj/item/clothing/head/gun_dealer
	name = "gun dealer beret"
	desc = "Come back any time!"
	icon_state = "gunner"
	worn_icon_state = "gunner"

/datum/outfit/job/gun_dealer
	name = "Gun Dealer"
	jobtype = /datum/job/gun_dealer

	id_trim = /datum/id_trim/job/gun_dealer
	uniform = /obj/item/clothing/under/rank/cargo/gun_dealer
	suit = /obj/item/clothing/suit/gun_dealer
	head = /obj/item/clothing/head/gun_dealer
	belt = /obj/item/modular_computer/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival

/datum/id_trim/job/gun_dealer
	assignment = "Gun Dealer"
	trim_state = "trim_gundealer"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_CARGO_BROWN
	sechud_icon_state = SECHUD_GUN_DEALER
	extra_access = list(ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_CARGO, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_WEAPONS, ACCESS_ARMORY)
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/gun_dealer

