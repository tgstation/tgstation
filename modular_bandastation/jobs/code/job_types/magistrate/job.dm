/datum/job/magistrate
	title  = JOB_MAGISTRATE
	description = "Вершите правосудие на станции, поддерживайте соблюдение закона."
	head_announce = list(RADIO_CHANNEL_JUSTICE)
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Центральное командование"
	minimal_player_age = 14
	exp_requirements = 1500
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_JUSTICE
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "MAGISTRATE"

	outfit = /datum/outfit/job/magistrate

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MAGISTRATE
	departments_list = list(
		/datum/job_department/justice,
		/datum/job_department/command,
	)
	family_heirlooms = list(/obj/item/gavelhammer, /obj/item/book/manual/wiki/security_space_law)
	rpg_title = "Justiciar"
	job_tone = "objection"
	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS | JOB_ANTAG_PROTECTED

