/datum/job/bitrunner
	title = JOB_BITRUNNER
	description = "Surf the virtual domain for gear and loot. Decrypt your rewards on station."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = SUPERVISOR_QM
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BITRUNNER"
	outfit = /datum/outfit/job/bitrunner
	plasmaman_outfit = /datum/outfit/plasmaman/bitrunner
	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR
	display_order = JOB_DISPLAY_ORDER_BITRUNNER
	bounty_types = CIV_JOB_BITRUN
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
	rpg_title = "Recluse"
	job_flags = STATION_JOB_FLAGS

/datum/outfit/job/bitrunner
	name = "Bitrunner"
	jobtype = /datum/job/bitrunner

	id_trim = /datum/id_trim/job/bitrunner
	uniform = /obj/item/clothing/under/rank/cargo/bitrunner
	belt = /obj/item/modular_computer/pda/bitrunner
	ears = /obj/item/radio/headset/headset_cargo
