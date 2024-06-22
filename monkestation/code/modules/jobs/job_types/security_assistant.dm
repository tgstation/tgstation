/datum/job/security_assistant
	title = JOB_SECURITY_ASSISTANT
	description = "Fine people for trivial things. Be a glorified hall monitor."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the Head of Security, the Warden, and any proper security officers"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SECURITY_ASSISTANT"

	outfit = /datum/outfit/job/security_assistant
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_ASSISTANT
	bounty_types = CIV_JOB_SEC
	departments_list = list(/datum/job_department/security)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5
	)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	alt_titles = list(
		"Security Assistant",
		"Deputy",
		"Hall Monitor",
		"Assistant Officer",
		"Professional Snitch"
	)

/datum/outfit/job/security_assistant
	name = "Security Assistant"
	jobtype = /datum/job/security_assistant

	id_trim = /datum/id_trim/job/security_assistant
	uniform = /obj/item/clothing/under/rank/security/officer/grey
	backpack_contents = list(
		/obj/item/restraints/handcuffs/cable/zipties = 1,
		/obj/item/reagent_containers/spray/pepper = 1
	)
	belt = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_sec
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/citationinator
	r_pocket = /obj/item/assembly/flash/handheld
	glasses = /obj/item/clothing/glasses/hud/security
	gloves = /obj/item/clothing/gloves/tackler/dolphin

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security

	implants = list(/obj/item/implant/mindshield) // i think this is stupid but this was apparently agreed upon ~lucy

/datum/id_trim/job/security_assistant
	assignment = "Security Assistant"
	trim_state = "trim_secass"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITY_ASSISTANT
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_SECURITY,
		ACCESS_PERMABRIG
	)
	extra_access = list(
		ACCESS_MAINT_TUNNELS
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS
	)
	job = /datum/job/security_assistant
