/obj/effect/landmark/start/blueshield
	name = "Blueshield"
	icon_state = "Blueshield"

/datum/job/blueshield
	title = JOB_BLUESHIELD
	description = "Protect heads of staff, get your fancy gun stolen, cry as the captain touches the supermatter."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NT_REP)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command and the Nanotrasen Consultant"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BLUESHIELD"

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	outfit = /datum/outfit/job/blueshield
	plasmaman_outfit = /datum/outfit/plasmaman/security
	display_order = JOB_DISPLAY_ORDER_BLUESHIELD
	bounty_types = CIV_JOB_SEC

	department_for_prefs = /datum/job_department/captain

	departments_list = list(
		/datum/job_department/command,
	)
	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	family_heirlooms = list(/obj/item/bedsheet/captain, /obj/item/clothing/head/helmet/blueshield)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes/cigars/havana = 10,
		/obj/item/stack/spacecash/c500 = 3,
		/obj/item/disk/nuclear/fake/obvious = 2,
		/obj/item/clothing/head/collectable/captain = 4,
	)
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	id = /obj/item/card/id/advanced/centcom

	belt = /obj/item/modular_computer/pda/clear
	ears = /obj/item/radio/headset/headset_com
	uniform = /obj/item/clothing/under/rank/security/officer/blueshield
	shoes = /obj/item/clothing/shoes/sneakers/black
	head =  /obj/item/clothing/head/helmet/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain
	box = /obj/item/storage/box/survival
	implants = list(/obj/item/implant/mindshield)

	id_trim = /datum/id_trim/job/blueshield

/datum/id_trim/job/blueshield
	assignment = "Blueshield"
	trim_state = "trim_blueshield"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_CENTCOM_BLUE
	sechud_icon_state = SECHUD_BLUESHIELD
	extra_access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_CARGO, ACCESS_GATEWAY)
	minimal_access = list(
		ACCESS_DETECTIVE, ACCESS_BRIG_ENTRANCE, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_ENGINEERING, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH,
		ACCESS_RC_ANNOUNCE, ACCESS_COMMAND, ACCESS_WEAPONS,
	)
	minimal_wildcard_access = list(ACCESS_CAPTAIN)
	template_access = list(ACCESS_CAPTAIN, ACCESS_CHANGE_IDS)
	job = /datum/job/blueshield

/obj/item/clothing/under/rank/security/officer/blueshield
	name = "blueshield uniform"
	icon_state = "blueshield"
	worn_icon_state = "blueshield"
	can_adjust = TRUE

/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield coat"
	desc = "An armored coat given to Blueshields in their duty."
	icon_state = "blueshield"
	worn_icon_state = "blueshield"
	unique_reskin = null

/obj/item/clothing/head/helmet/blueshield
	name = "blueshield beret"
	desc = "A blueshield beret."
	icon_state = "blueshield"
	worn_icon_state = "blueshield"
