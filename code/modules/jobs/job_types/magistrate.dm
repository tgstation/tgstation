/obj/effect/landmark/start/magistrate
	name = "Magistrate"
	icon_state = "Magistrate"

/datum/job/magistrate
	title = JOB_MAGISTRATE
	description = "Rule on court cases, interpret the law, slam your gavel and shout ORDER, ORDER!"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Space Law")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the rule of Space Law, past case precedent, and Justice."
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "MAGISTRATE"

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	outfit = /datum/outfit/job/magistrate
	plasmaman_outfit = /datum/outfit/plasmaman/security
	display_order = JOB_DISPLAY_ORDER_MAGISTRATE
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(
		/datum/job_department/security,
	)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/effect/spawner/random/contraband/prison = 5, //Gives them something fun to hold over the prisoners, or hide from them.
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "Judge"
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/gavelhammer, /obj/item/gavelblock)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/id_trim/job/magistrate
	assignment = "Magistrate"
	trim_state = "trim_magistrate"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_MAGISTRATE
	extra_access = list()
	minimal_access = list(ACCESS_SECURITY, ACCESS_BRIG_ENTRANCE, ACCESS_BRIG, ACCESS_COURT,
				ACCESS_MAINT_TUNNELS)
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/magistrate

/datum/outfit/job/magistrate
	name = "Magistrate"
	jobtype = /datum/job/magistrate

	belt = /obj/item/modular_computer/pda
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/sneakers/black
	head =  /obj/item/clothing/head/costume/powdered_wig
	suit = /obj/item/clothing/suit/costume/judgerobe
	l_hand = /obj/item/gavelhammer
	r_hand = /obj/item/gavelblock
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival

	id_trim = /datum/id_trim/job/magistrate
