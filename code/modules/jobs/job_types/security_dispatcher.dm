/datum/job/security_dispatcher
	title = JOB_SECURITY_DISPATCHER
	description = "Relay distress calls from radio to Security and dispatch designated officers. \
		Monitor crime scenes with sensors and cameras and report situational details."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOS
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SECURITY_DISPATCHER"

	outfit = /datum/outfit/job/security_dispatcher
	plasmaman_outfit = /datum/outfit/plasmaman/warden

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_DISPATCHER
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/radio/off)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 15,
		/obj/item/food/donut/matcha = 15,
		/obj/item/radio/off = 10,
		/obj/item/storage/fancy/cigarettes = 10,
		/obj/item/clothing/glasses/meson = 5,
		/obj/item/megaphone/sec = 1,
	)
	rpg_title = "Watchman"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT

/datum/outfit/job/security_dispatcher
	name = "Security Dispatcher"
	jobtype = /datum/job/security_dispatcher

	id_trim = /datum/id_trim/job/security_dispatcher
	uniform = /obj/item/clothing/under/rank/security/dispatcher
	suit = /obj/item/clothing/suit/armor/vest/secjacket/dispatcher
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/pda/security_dispatcher
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft/sec
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	messenger = /obj/item/storage/backpack/messenger/sec

	box = /obj/item/storage/box/survival/security
	implants = list(/obj/item/implant/mindshield)
