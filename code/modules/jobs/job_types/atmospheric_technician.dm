/datum/job/atmospheric_technician
	title = JOB_ATMOSPHERIC_TECHNICIAN
	description = "Ensure the air is breathable on the station, fill oxygen tanks, fight fires, purify the air."
	department_head = list(JOB_CHIEF_ENGINEER)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 2
	supervisors = SUPERVISOR_CE
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "ATMOSPHERIC_TECHNICIAN"

	outfit = /datum/outfit/job/atmos
	plasmaman_outfit = /datum/outfit/plasmaman/atmospherics

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_ENG

	liver_traits = list(TRAIT_ENGINEER_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN
	bounty_types = CIV_JOB_ATMOS
	departments_list = list(
		/datum/job_department/engineering,
		)

	family_heirlooms = list(/obj/item/lighter, /obj/item/lighter/greyscale, /obj/item/storage/box/matches)

	mail_goodies = list(
		/obj/item/rpd_upgrade/unwrench = 30,
		/obj/item/grenade/gas_crystal/crystal_foam = 10,
		/obj/item/grenade/gas_crystal/proto_nitrate_crystal = 10,
		/obj/item/grenade/gas_crystal/healium_crystal = 10,
		/obj/item/grenade/gas_crystal/nitrous_oxide_crystal = 5,
	)

	job_flags = STATION_JOB_FLAGS
	rpg_title = "Aeromancer"

/datum/outfit/job/atmos
	name = "Atmospheric Technician"
	jobtype = /datum/job/atmospheric_technician

	id_trim = /datum/id_trim/job/atmospheric_technician
	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	suit = /obj/item/clothing/suit/atmos_overalls
	belt = /obj/item/storage/belt/utility/atmostech
	ears = /obj/item/radio/headset/headset_eng
	l_pocket = /obj/item/modular_computer/pda/atmos
	r_pocket = /obj/item/analyzer

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	messenger = /obj/item/storage/backpack/messenger/eng

	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/atmos/mod
	name = "Atmospheric Technician (MODsuit)"

	suit = null
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/atmospheric
	mask = /obj/item/clothing/mask/gas/atmos
	internals_slot = ITEM_SLOT_SUITSTORE
