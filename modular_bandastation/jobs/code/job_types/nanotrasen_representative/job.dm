/datum/job/nanotrasen_representative
	title = JOB_NANOTRASEN_REPRESENTATIVE
	description = "Следите за работой глав, держите связь с Центральным Командованием, следите за выполнением задач смены"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Центральное Командование"
	minimal_player_age = 14
	exp_requirements = 1500
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "NANOTRASEN_REPRESENTATIVE"

	outfit = /datum/outfit/job/nanotrasen_representative

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(HEAD_OF_STAFF_MIND_TRAITS)
	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_REPRESENTATIVE
	departments_list = list(
		/datum/job_department/nanotrasen_representation,
		/datum/job_department/command,
	)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/lighter, /obj/item/reagent_containers/cup/glass/flask)

	mail_goodies = list(
		/obj/item/pen/fountain = 30,
		/obj/item/food/moonfish_caviar = 25,
		/obj/item/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne/cursed = 5,
	)
	exclusive_mail_goodies = TRUE

	rpg_title = "Diplomat"
	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS | JOB_ANTAG_PROTECTED
