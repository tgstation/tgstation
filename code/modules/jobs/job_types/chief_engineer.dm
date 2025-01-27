/datum/job/chief_engineer
	title = JOB_CHIEF_ENGINEER
	description = "Coordinate engineering, ensure equipment doesn't get stolen, \
		make sure the Supermatter doesn't blow up, maintain telecommunications."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_CAPTAIN)
	head_announce = list("Engineering")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CAPTAIN
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_ENGINEERING
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CHIEF_ENGINEER"

	outfit = /datum/outfit/job/ce
	plasmaman_outfit = /datum/outfit/plasmaman/chief_engineer
	departments_list = list(
		/datum/job_department/engineering,
		/datum/job_department/command,
		)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_ENG

	mind_traits = list(HEAD_OF_STAFF_MIND_TRAITS)
	liver_traits = list(TRAIT_ENGINEER_METABOLISM, TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	bounty_types = CIV_JOB_ENG

	family_heirlooms = list(/obj/item/clothing/head/utility/hardhat/white, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)

	mail_goodies = list(
		/obj/item/food/cracker = 25, //you know. for poly
		/obj/item/stack/sheet/mineral/diamond = 15,
		/obj/item/stack/sheet/mineral/uranium/five = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 15,
		/obj/item/stack/sheet/mineral/gold = 15,
		/obj/effect/spawner/random/engineering/tool_advanced = 3
	)
	rpg_title = "Head Crystallomancer"
	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS

	human_authority = JOB_AUTHORITY_HUMANS_ONLY

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/chief_engineer/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	spawned.add_mob_memory(/datum/memory/key/message_server_key, decrypt_key = GLOB.preset_station_message_server_key)

/datum/job/chief_engineer/get_captaincy_announcement(mob/living/captain)
	return "Due to staffing shortages, newly promoted Acting Captain [captain.real_name] on deck!"


/datum/outfit/job/ce
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/chief_engineer
	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	backpack_contents = list(
		/obj/item/melee/baton/telescopic/silver = 1,
		/obj/item/construction/rcd/ce = 1,
	)
	belt = /obj/item/storage/belt/utility/chief/full
	ears = /obj/item/radio/headset/heads/ce
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/utility/hardhat/welding/white/up
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_pocket = /obj/item/modular_computer/pda/heads/ce

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	messenger = /obj/item/storage/backpack/messenger/eng

	box = /obj/item/storage/box/survival/engineer
	chameleon_extras = /obj/item/stamp/head/ce
	skillchips = list(/obj/item/skillchip/job/engineer)
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/ce/mod
	name = "Chief Engineer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/advanced
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/color/yellow
	head = null
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/magboots/advance
	internals_slot = ITEM_SLOT_SUITSTORE
