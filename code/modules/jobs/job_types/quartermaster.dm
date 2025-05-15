/datum/job/quartermaster
	title = JOB_QUARTERMASTER
	description = "Coordinate cargo technicians and shaft miners, assist with \
		economical purchasing."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_CAPTAIN)
	head_announce = list(RADIO_CHANNEL_SUPPLY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	minimal_player_age = 7
	supervisors = SUPERVISOR_CAPTAIN
	exp_required_type_department = EXP_TYPE_SUPPLY
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "QUARTERMASTER"

	outfit = /datum/outfit/job/quartermaster
	plasmaman_outfit = /datum/outfit/plasmaman/cargo

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CAR

	mind_traits = list(HEAD_OF_STAFF_MIND_TRAITS)
	liver_traits = list(TRAIT_ROYAL_METABOLISM) // finally upgraded

	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/cargo,
		/datum/job_department/command,
		)
	family_heirlooms = list(/obj/item/stamp, /obj/item/stamp/denied)
	mail_goodies = list(
		/obj/item/circuitboard/machine/emitter = 3
	)
	rpg_title = "Steward"
	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS
	voice_of_god_power = 1.4 //Command staff has authority
	human_authority = JOB_AUTHORITY_NON_HUMANS_ALLOWED

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/quartermaster
	backpack_contents = list(
		/obj/item/melee/baton/telescopic/bronze = 1,
	)
	id_trim = /datum/id_trim/job/quartermaster
	id = /obj/item/card/id/advanced/silver
	uniform = /obj/item/clothing/under/rank/cargo/qm
	belt = /obj/item/modular_computer/pda/heads/quartermaster
	suit = /obj/item/clothing/suit/jacket/quartermaster
	ears = /obj/item/radio/headset/heads/qm
	glasses = /obj/item/clothing/glasses/sunglasses
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/clipboard

	chameleon_extras = /obj/item/stamp/head/qm
