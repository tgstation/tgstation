/datum/job/cargo_technician
	title = JOB_CARGO_TECHNICIAN
	description = "Distribute supplies to the departments that ordered them, \
		collect empty crates, load and unload the supply shuttle, \
		ship bounty cubes, mine ores, run bitrunning domains."
	faction = FACTION_STATION
	// Lowpop: absorbs Shaft Miner and Bitrunner.
	total_positions = 11
	spawn_positions = 9
	supervisors = SUPERVISOR_QM
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CARGO_TECHNICIAN"

	outfit = /datum/outfit/job/cargo_tech
	plasmaman_outfit = /datum/outfit/plasmaman/cargo

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR

	mind_traits = list(TRAIT_DETECT_STORM)

	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(/obj/item/clipboard)

	mail_goodies = list(
		/obj/item/pizzabox = 10,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 4,
		/obj/item/stack/sheet/mineral/diamond = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 1,
		/obj/item/gun/ballistic/automatic/wt550 = 1,
	)
	rpg_title = "Merchantman"
	job_flags = STATION_JOB_FLAGS
	tgui_icon = FA_ICON_BOX


/datum/outfit/job/cargo_tech
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_technician

	// Lowpop: mining gear from Shaft Miner.
	backpack_contents = list(
		/obj/item/boxcutter = 1,
		/obj/item/universal_scanner = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/knife/combat/survival = 1,
		/obj/item/mining_voucher = 1,
		/obj/item/stack/candela_beacon/thirty = 1,
		/obj/item/t_scanner/adv_mining_scanner/lesser = 1,
	)
	id_trim = /datum/id_trim/job/cargo_technician
	uniform = /obj/item/clothing/under/rank/cargo/tech
	belt = /obj/item/modular_computer/pda/crew/cargo
	suit = /obj/item/clothing/suit/toggle/cargo_tech
	ears = /obj/item/radio/headset/headset_cargo/mining
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots/mining
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/storage/bag/ore //causes issues if spawned in backpack

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag/explorer
	messenger = /obj/item/storage/backpack/messenger/explorer

	box = /obj/item/storage/box/survival/mining
	skillchips = list(/obj/item/skillchip/job/miner)

	wintercoat = /obj/item/clothing/suit/hooded/wintercoat/cargo

/datum/outfit/job/cargo_tech/mod
	name = "Cargo Technician (MODsuit)"

	back = /obj/item/mod/control/pre_equipped/loader
	suit = null
