/datum/job/worker
	title = JOB_WORKER
	description = "Amelelik yap, murettebatin istedigi yapi islerini yap, adiyaman tutun sarma ic, muhendislere racon kes."
	department_head = list(JOB_CHIEF_ENGINEER)
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	exp_requirements = 10
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/worker
	plasmaman_outfit = /datum/outfit/plasmaman/engineering

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_ENG

	liver_traits = list(TRAIT_ENGINEER_METABOLISM)

	bounty_types = CIV_JOB_ENG
	departments_list = list(
		/datum/job_department/engineering,
		)

	family_heirlooms = list(/obj/item/clothing/head/hardhat, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)

	mail_goodies = list(
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10,
		/obj/item/holosign_creator/engineering = 8,
		/obj/item/clothing/head/hardhat/red/upgraded = 1
	)
	rpg_title = "Amele"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/worker
	name = "Worker"
	jobtype = /datum/job/worker

	id_trim = /datum/id_trim/job/worker
	uniform = /obj/item/clothing/under/pants/jeans
	suit = /obj/item/clothing/suit/hazardvest
	backpack_contents = list(
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/plasteel/fifty = 1,
		/obj/item/stack/sheet/mineral/wood/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/reagent_containers/cup/soda_cans/cola = 1,
		)
	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_eng
	head = /obj/item/clothing/head/hardhat
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/modular_computer/tablet/pda/engineering
	r_pocket = /obj/item/storage/fancy/cigarettes/cigpack_mindbreaker

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/engineer/gloved
	name = "Station Engineer (Gloves)"

	gloves = /obj/item/clothing/gloves/color/yellow

/datum/outfit/job/engineer/mod
	name = "Station Engineer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/engineering
	head = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE
