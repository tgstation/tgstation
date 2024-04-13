/datum/job/botanist
	title = JOB_BOTANIST
	description = "Grow plants for the cook, for medicine, and for recreation."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 2
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BOTANIST"

	outfit = /datum/outfit/job/botanist
	plasmaman_outfit = /datum/outfit/plasmaman/botany

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BOTANIST
	bounty_types = CIV_JOB_GROW
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(
		/obj/item/cultivator,
		/obj/item/reagent_containers/cup/watering_can/wood,
		/obj/item/toy/plush/beeplushie,
		)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/bottle/mutagen = 20,
		/obj/item/reagent_containers/cup/bottle/saltpetre = 20,
		/obj/item/reagent_containers/cup/bottle/diethylamine = 20,
		/obj/item/gun/energy/floragun = 10,
		/obj/item/reagent_containers/cup/watering_can/advanced = 10,
		/obj/effect/spawner/random/food_or_drink/seed_rare = 5,// These are strong, rare seeds, so use sparingly.
		/obj/item/food/monkeycube/bee = 2
	)

	job_flags = STATION_JOB_FLAGS
	rpg_title = "Gardener"

/datum/outfit/job/botanist
	name = "Botanist"
	jobtype = /datum/job/botanist

	id_trim = /datum/id_trim/job/botanist
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	suit = /obj/item/clothing/suit/apron
	suit_store = /obj/item/plant_analyzer
	belt = /obj/item/modular_computer/pda/botanist
	ears = /obj/item/radio/headset/headset_srv
	gloves = /obj/item/clothing/gloves/botanic_leather

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel/hyd
	duffelbag = /obj/item/storage/backpack/duffelbag/hydroponics
	messenger = /obj/item/storage/backpack/messenger/hyd
