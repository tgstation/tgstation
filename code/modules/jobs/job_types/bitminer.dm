/datum/job/bitminer
	title = JOB_BITMINER
	description = "Surf the virtual domain for gear and loot. Decrypt your rewards on station."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = SUPERVISOR_QM
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BITMINER"

	outfit = /datum/outfit/job/bitminer
	plasmaman_outfit = /datum/outfit/plasmaman/bitminer

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR
	display_order = JOB_DISPLAY_ORDER_BITMINER
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind)

	mail_goodies = list(
		/obj/item/food/cornchips = 1,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 1,
		/obj/item/food/cornchips/green = 1,
		/obj/item/food/cornchips/red = 1,
		/obj/item/food/cornchips/purple = 1,
		/obj/item/food/cornchips/blue = 1,
	)
	rpg_title = "Nerd"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/bitminer
	name = "Bitminer"
	jobtype = /datum/job/bitminer

	id_trim = /datum/id_trim/job/bitminer
	uniform = /obj/item/clothing/under/rank/cargo/bitminer
	belt = /obj/item/modular_computer/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo

