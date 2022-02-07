/datum/job/chief_medical_officer
	title = JOB_CHIEF_MEDICAL_OFFICER
	description = "Coordinate doctors and other medbay employees, ensure they \
		know how to save lives, check for injuries on the crew monitor."
	department_head = list(JOB_CAPTAIN)
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	head_announce = list(RADIO_CHANNEL_MEDICAL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_MEDICAL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/cmo
	plasmaman_outfit = /datum/outfit/plasmaman/chief_medical_officer
	departments_list = list(
		/datum/job_department/medical,
		/datum/job_department/command,
		)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM, TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	bounty_types = CIV_JOB_MED

	mail_goodies = list(
		/obj/effect/spawner/random/medical/organs = 10,
		/obj/effect/spawner/random/medical/memeorgans = 8,
		/obj/effect/spawner/random/medical/surgery_tool_advanced = 4,
		/obj/effect/spawner/random/medical/surgery_tool_alien = 1
	)
	family_heirlooms = list(/obj/item/storage/firstaid/ancient/heirloom)
	rpg_title = "High Cleric"
	job_type_flags = JOB_STATION_JOB | JOB_HEAD_JOB
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_BOLD_SELECT_TEXT | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/chief_medical_officer/get_captaincy_announcement(mob/living/captain)
	return "Due to staffing shortages, newly promoted Acting Captain [captain.real_name] on deck!"


/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/chief_medical_officer

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/chief_medical_officer
	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	suit_store = /obj/item/flashlight/pen/paramedic
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/modular_computer/tablet/preset/advanced/command = 1,
		)
	belt = /obj/item/pda/heads/cmo
	ears = /obj/item/radio/headset/heads/cmo
	shoes = /obj/item/clothing/shoes/sneakers/blue
	l_pocket = /obj/item/pinpointer/crew
	l_hand = /obj/item/storage/firstaid/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(
		/obj/item/gun/syringe,
		/obj/item/stamp/cmo,
		)
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/outfit/job/cmo/mod
	name = "Chief Medical Officer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/rescue
	suit = null
	mask = /obj/item/clothing/mask/breath/medical
	r_pocket = /obj/item/flashlight/pen/paramedic
	internals_slot = ITEM_SLOT_SUITSTORE
