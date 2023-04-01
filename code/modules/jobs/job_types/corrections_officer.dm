/obj/effect/landmark/start/corrections_officer
	name = "Corrections Officer"
	icon_state = "Corrections Officer"

/datum/job/corrections_officer
	title = JOB_CORRECTIONS_OFFICER
	description = "Guard the permabrig, stand around looking imposing, get fired for beating the prisoners."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("The Warden and Head of Security")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Security and the Warden"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CORRECTIONS_OFFICER"

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	outfit = /datum/outfit/job/corrections_officer
	plasmaman_outfit = /datum/outfit/plasmaman/security
	display_order = JOB_DISPLAY_ORDER_CORRECTIONS_OFFICER
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
	rpg_title = "Bailiff"
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/soft/sec, /obj/item/clothing/mask/whistle)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/id_trim/job/corrections_officer
	assignment = "Corrections Officer"
	trim_state = "trim_corrections_officer"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_CORRECTIONS_OFFICER
	extra_access = list()
	minimal_access = list(ACCESS_SECURITY, ACCESS_BRIG_ENTRANCE, ACCESS_BRIG, ACCESS_COURT,
				ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOS, ACCESS_CHANGE_IDS)
	job = /datum/job/corrections_officer

/datum/outfit/job/corrections_officer
	name = "Corrections Officer"
	jobtype = /datum/job/corrections_officer

	belt = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/security/officer/corrections_officer
	shoes = /obj/item/clothing/shoes/jackboots
	head =  /obj/item/clothing/head/costume/ushanka
	suit = /obj/item/clothing/suit/armor/vest/corrections_officer

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/departmental/prison = 1,
	)
	implants = list(/obj/item/implant/mindshield)

	id_trim = /datum/id_trim/job/corrections_officer

/obj/item/clothing/under/rank/security/officer/corrections_officer
	name = "corrections officer uniform"
	icon_state = "corrections_officer"
	worn_icon_state = "corrections_officer"
	can_adjust = FALSE

/obj/item/clothing/suit/armor/vest/corrections_officer
	name = "corrections officer coat"
	desc = "An armored coat given to Corrections Officers in their duty."
	icon_state = "corrections_officer"
	worn_icon_state = "corrections_officer"
	unique_reskin = null

