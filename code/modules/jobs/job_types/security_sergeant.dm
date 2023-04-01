/obj/effect/landmark/start/security_sergeant
	name = "Security Sergeant"
	icon_state = "Security Sergeant"

/datum/job/security_sergeant
	title = JOB_SECURITY_SERGEANT
	description = "Boss around the officers, brag about how cool your uniform is, charge people with the segway and the lance."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Security"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SECURITY_SERGEANT"

	outfit = /datum/outfit/job/security_sergeant
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_SERGEANT
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/security,
	)

	family_heirlooms = list( /obj/item/book/manual/wiki/security_space_law)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "Milita Sergeant"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/security_sergeant
	name = "Security Sergeant"
	jobtype = /datum/job/security_sergeant

	belt = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/security/officer/sergeant
	shoes = /obj/item/clothing/shoes/jackboots
	head =  /obj/item/clothing/head/helmet/sergeant
	suit = /obj/item/clothing/suit/armor/vest/sergeant
	l_hand = /obj/item/melee/baton/security/loaded/lance

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	implants = list(/obj/item/implant/mindshield)

	id_trim = /datum/id_trim/job/security_sergeant

/datum/id_trim/job/security_sergeant
	assignment = "Security Sergeant"
	trim_state = "trim_securitysergeant"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITYSERGEANT
	extra_access = list(ACCESS_MORGUE)
	minimal_access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_BRIG_ENTRANCE, ACCESS_MECH_SECURITY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM,
				ACCESS_MAINT_TUNNELS)
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOS, ACCESS_CHANGE_IDS)

/datum/id_trim/job/security_sergeant/New()
	. = ..()

	// Config check for if sec has maint access.
	if(CONFIG_GET(flag/security_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

/obj/item/clothing/under/rank/security/officer/sergeant
	name = "security sergeant uniform"
	icon_state = "sergeant"
	worn_icon_state = "sergeant"
	can_adjust = FALSE

/obj/item/clothing/suit/armor/vest/sergeant
	name = "security sergeant coat"
	desc = "An armored coat given to Security medics in their duty."
	icon_state = "sergeant"
	worn_icon_state = "sergeant"
	unique_reskin = null

/obj/item/clothing/head/helmet/sergeant
	name = "security sergeant helmet"
	desc = "A security sergeant helmet."
	icon_state = "sergeant"
	worn_icon_state = "sergeant"

