/datum/job/head_of_security
	title = JOB_HEAD_OF_SECURITY
	description = "Coordinate security personnel, ensure they are not corrupt, \
		make sure every department is protected."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list(JOB_CAPTAIN)
	head_announce = list(RADIO_CHANNEL_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CAPTAIN
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SECURITY
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "HEAD_OF_SECURITY"

	outfit = /datum/outfit/job/hos
	plasmaman_outfit = /datum/outfit/plasmaman/head_of_security
	departments_list = list(
		/datum/job_department/security,
		/datum/job_department/command,
		)

	mind_traits = list(HEAD_OF_STAFF_MIND_TRAITS, SECURITY_MIND_TRAITS)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM, TRAIT_ROYAL_METABOLISM)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_SECURITY
	bounty_types = CIV_JOB_SEC

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law)
	rpg_title = "Guard Leader"
	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS | JOB_ANTAG_PROTECTED

	human_authority = JOB_AUTHORITY_HUMANS_ONLY

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/head_of_security/get_captaincy_announcement(mob/living/captain)
	return "Due to staffing shortages, newly promoted Acting Captain [captain.real_name] on deck!"


/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/head_of_security

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/head_of_security
	uniform = /obj/item/clothing/under/rank/security/head_of_security
	suit = /obj/item/clothing/suit/armor/hos/trenchcoat
	suit_store = /obj/item/gun/energy/e_gun
	backpack_contents = list(
		/obj/item/evidencebag = 1,
		/obj/item/melee/baton/security/loaded/hos = 1,
		)
	belt = /obj/item/modular_computer/pda/heads/hos
	ears = /obj/item/radio/headset/heads/hos/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/black/security
	head = /obj/item/clothing/head/hats/hos/beret
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	messenger = /obj/item/storage/backpack/messenger/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/stamp/head/hos,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/hos/mod
	name = "Head of Security (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/safeguard
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
