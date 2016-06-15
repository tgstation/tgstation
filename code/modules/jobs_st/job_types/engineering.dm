/*
Chief Engineer
*/
/datum/job/ceo
	title = "Chief Engineering Officer"
	flag = CEO
	department_head = list("Commanding Officer")
	department_flag = ENGJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commanding Officer, the ship"
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	minimal_player_age = 7

	outfit = /datum/outfit/job/ceo

	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors, access_minisat,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_mineral_storeroom)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors, access_minisat,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_mineral_storeroom)

/datum/outfit/job/ceo
	name = "Chief Engineering Officer"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/weapon/storage/belt/utility/full
	l_pocket = /obj/item/device/pda/heads/ce
	ears = /obj/item/device/radio/headset/heads/ce
	uniform = /obj/item/clothing/under/rank/chief_engineer
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hardhat/white
	gloves = /obj/item/clothing/gloves/color/black/ce
	backpack_contents = list(/obj/item/weapon/melee/classic_baton/telescopic=1)

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/engineering
	box = /obj/item/weapon/storage/box/engineer
	pda_slot = slot_l_store

/datum/outfit/job/ceo/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	announce_head(H, list("Engineering"))

/*
Ass Engineer
*/
/datum/job/assceo
	title = "Assistant Chief Engineer"
	flag = ENGINEER
	department_head = list("Chief Engineering Officer")
	department_flag = ENGJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Engineering Officer"
	selection_color = "#fff5cc"

	outfit = /datum/outfit/job/assceo

	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
									access_external_airlocks, access_construction, access_atmospherics, access_tcomsat)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
									access_external_airlocks, access_construction, access_tcomsat)

/datum/outfit/job/assceo
	name = "Assistant chief Engineer"

	belt = /obj/item/weapon/storage/belt/utility/full
	l_pocket = /obj/item/device/pda/engineering
	ears = /obj/item/device/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	r_pocket = /obj/item/device/t_scanner

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/engineering
	box = /obj/item/weapon/storage/box/engineer
	pda_slot = slot_l_store

/*
Engineer
*/
/datum/job/engineer
	title = "Engineer"
	flag = ENGINEER
	department_head = list("Chief Engineering Officer")
	department_flag = ENGJOBS
	faction = "Federation"
	total_positions = 25
	spawn_positions = 25
	supervisors = "the Chief Engineering Officer"
	selection_color = "#fff5cc"

	outfit = /datum/outfit/job/engineer

	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
									access_external_airlocks, access_construction, access_atmospherics, access_tcomsat)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
									access_external_airlocks, access_construction, access_tcomsat)

/datum/outfit/job/engineer
	name = "Engineer"

	belt = /obj/item/weapon/storage/belt/utility/full
	l_pocket = /obj/item/device/pda/engineering
	ears = /obj/item/device/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	r_pocket = /obj/item/device/t_scanner

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/engineering
	box = /obj/item/weapon/storage/box/engineer
	pda_slot = slot_l_store

/*
Transporter Technician
*/
/datum/job/transportech
	title = "Transporter Technician"
	flag = TRANSPORTECH
	department_head = list("Chief Engineering Officer")
	department_flag = ENGJOBS
	faction = "Federation"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the Chief Engineering Officer"
	selection_color = "#fff5cc"

	outfit = /datum/outfit/job/transportech

	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
									access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction)

/datum/outfit/job/transportech
	name = "Transporter Technician"

	belt = /obj/item/weapon/storage/belt/utility/atmostech
	l_pocket = /obj/item/device/pda/atmos
	ears = /obj/item/device/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	r_pocket = /obj/item/device/analyzer

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/engineering
	box = /obj/item/weapon/storage/box/engineer
	pda_slot = slot_l_store

/*
Holodeck Technician
*/
/datum/job/holotech
	title = "Holodeck Technician"
	flag = HOLOTECH
	department_head = list("Chief Engineering Officer")
	department_flag = ENGJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Engineering Officer"
	selection_color = "#fff5cc"

	outfit = /datum/outfit/job/transportech

	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
									access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction)

/datum/outfit/job/transportech
	name = "Transporter Technician"

	belt = /obj/item/weapon/storage/belt/utility/atmostech
	l_pocket = /obj/item/device/pda/atmos
	ears = /obj/item/device/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	r_pocket = /obj/item/device/analyzer

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/engineering
	box = /obj/item/weapon/storage/box/engineer
	pda_slot = slot_l_store