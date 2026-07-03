/datum/job/explorer
	title = JOB_EXPLORER
	supervisors = JOB_QUARTERMASTER
	description = "Исследователь космоса и Врат"
	display_order = JOB_DISPLAY_ORDER_EXPLORER
	departments_list = list(
		/datum/job_department/cargo,
	)
	outfit = /datum/outfit/job/explorer
	faction = FACTION_STATION
	total_positions = 4
	spawn_positions = 3
	minimal_player_age = 18
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SUPPLY
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "EXPLORER"

	plasmaman_outfit = /datum/outfit/plasmaman/explorer

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR
	bounty_types = CIV_JOB_BASIC
	departments_list = list(
		/datum/job_department/cargo,
	)
	family_heirlooms = list(/obj/item/gps, /obj/item/multitool)
	mail_goodies = list(
		/obj/item/stack/spacecash/c500 = 3,
	)
	rpg_title = "Explorer"
	job_flags = STATION_JOB_FLAGS
