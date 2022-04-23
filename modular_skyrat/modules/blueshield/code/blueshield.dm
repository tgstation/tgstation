/datum/job/blueshield
	title = JOB_BLUESHIELD
	description = "Protect heads of staff, get your fancy gun stolen, cry as the captain touches the supermatter."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NT_REP)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command and the Nanotrasen Consultant"
	selection_color = "#c6ffe0"
	minimal_player_age = 7
	exp_requirements = 2400
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_CMD

	outfit = /datum/outfit/job/blueshield
	plasmaman_outfit = /datum/outfit/plasmaman/blueshield
	display_order = JOB_DISPLAY_ORDER_BLUESHIELD
	bounty_types = CIV_JOB_SEC

	department_for_prefs = /datum/job_department/captain

	departments_list = list(
		/datum/job_department/central_command,
		/datum/job_department/command,
	)
	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	family_heirlooms = list(/obj/item/bedsheet/captain, /obj/item/clothing/head/beret/blueshield)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes/cigars/havana = 10,
		/obj/item/stack/spacecash/c500 = 3,
		/obj/item/disk/nuclear/fake/obvious = 2,
		/obj/item/clothing/head/collectable/captain = 4,
		/obj/projectile/bullet/b460 = 1
	)

	veteran_only = TRUE
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/security/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	id = /obj/item/card/id/advanced/centcom
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/headset_bs/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	backpack_contents = list(
		/obj/item/storage/box/gunset/blueshield = 1,
		/obj/item/melee/baton/security/loaded = 1,)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel/blueshield
	duffelbag = /obj/item/storage/backpack/duffel/blueshield
	head = /obj/item/clothing/head/beret/blueshield
	box = /obj/item/storage/box/survival/security
	belt = /obj/item/modular_computer/tablet/pda/security

	id_trim = /datum/id_trim/job/blueshield

/datum/outfit/plasmaman/blueshield
	name = "Blueshield Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman/blueshield
	uniform = /obj/item/clothing/under/plasmaman/blueshield

/obj/item/storage/box/gunset/blueshield
	name = "CMG-1 Gunset"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/ballistic/automatic/cmg/nomag
	spawnwithmagazine = FALSE

/obj/item/storage/box/gunset/blueshield/PopulateContents()
	. = ..()
	new /obj/item/gun/ballistic/automatic/cmg/nomag(src)
	new /obj/item/ammo_box/magazine/cmgm45(src)
	new /obj/item/ammo_box/magazine/cmgm45(src)
	new /obj/item/ammo_box/magazine/cmgm45/lethal(src)
	new /obj/item/ammo_box/magazine/cmgm45/lethal(src)
	new /obj/item/suppressor(src)

/obj/item/ammo_casing/energy/laser/hellfire/bs
	projectile_type = /obj/projectile/beam/laser/hellfire
	e_cost = 83 //Lets it squeeze out a few more shots
	select_name = "maim"

/obj/item/gun/energy/laser/hellgun/blueshield
	name = "\improper Allstar SC-3 PDW 'Hellfire'"
	desc = "A prototype energy carbine, despite NT's ban on hellfire weaponry due to negative press. \
            Allstar continued to work on it, compacting it into a small form-factor for personal defense. \
            As part of the Asset Retention Program created by Nanotrasen, Allstar's prototype began to be put into use."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	worn_icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_back.dmi'
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'
	icon_state = "hellfirepdw"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire/bs)
	company_flag = COMPANY_ALLSTAR
