/datum/job/warden
	title = "Warden"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/warden
	plasmaman_outfit = /datum/outfit/plasmaman/warden

	bounty_types = CIV_JOB_SEC
	departments = DEPARTMENT_SECURITY
	display_order = JOB_DISPLAY_ORDER_WARDEN
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	family_heirlooms = list(
		/obj/item/book/manual/wiki/security_space_law,
		)
	liver_traits = list(
		TRAIT_LAW_ENFORCEMENT_METABOLISM,
		)
	mind_traits = list(
		TRAIT_DONUT_LOVER,
		)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 15,
		/obj/item/storage/box/handcuffs = 10,
		/obj/item/storage/box/teargas = 10,
		/obj/item/storage/box/flashbangs = 10,
		/obj/item/storage/box/rubbershot = 10,
		/obj/item/storage/box/lethalshot = 5
	)

/datum/outfit/job/warden
	name = "Warden"
	jobtype = /datum/job/warden

	id_trim = /datum/id_trim/job/warden
	uniform = /obj/item/clothing/under/rank/security/warden
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/melee/baton/loaded = 1,
		)
	belt = /obj/item/pda/warden
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/warden
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	implants = list(
		/obj/item/implant/mindshield,
		)
