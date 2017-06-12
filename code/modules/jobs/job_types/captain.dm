/*
Captain
*/
/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_head = list("Centcom")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	selection_color = "#ccccff"
	req_admin_notify = 1
	minimal_player_age = 14

	outfit = /datum/outfit/job/captain

	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Captain [H.real_name] on deck!"))

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain

	id = /obj/item/weapon/card/id/gold
	belt = /obj/item/device/pda/captain
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/device/radio/headset/heads/captain/alt
	gloves = /obj/item/clothing/gloves/color/captain
	uniform =  /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/caphat
	backpack_contents = list(/obj/item/weapon/melee/classic_baton/telescopic=1, /obj/item/weapon/station_charter=1)

	backpack = /obj/item/weapon/storage/backpack/captain
	satchel = /obj/item/weapon/storage/backpack/satchel/cap
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/captain

	implants = list(/obj/item/weapon/implant/mindshield)
	accessory = /obj/item/clothing/accessory/medal/gold/captain

/*
Head of Personnel
*/
/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_head = list("Captain")
	department_flag = CIVILIAN
	head_announce = list("Supply", "Service")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 10

	outfit = /datum/outfit/job/hop

	access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_court, GLOB.access_weapons,
			            GLOB.access_medical, GLOB.access_engine, GLOB.access_change_ids, GLOB.access_ai_upload, GLOB.access_eva, GLOB.access_heads,
			            GLOB.access_all_personal_lockers, GLOB.access_maint_tunnels, GLOB.access_bar, GLOB.access_janitor, GLOB.access_construction, GLOB.access_morgue,
			            GLOB.access_crematorium, GLOB.access_kitchen, GLOB.access_cargo, GLOB.access_cargo_bot, GLOB.access_mailsorting, GLOB.access_qm, GLOB.access_hydroponics, GLOB.access_lawyer,
			            GLOB.access_theatre, GLOB.access_chapel_office, GLOB.access_library, GLOB.access_research, GLOB.access_mining, GLOB.access_heads_vault, GLOB.access_mining_station,
			            GLOB.access_hop, GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_gateway, GLOB.access_mineral_storeroom)
	minimal_access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_court, GLOB.access_weapons,
			            GLOB.access_medical, GLOB.access_engine, GLOB.access_change_ids, GLOB.access_ai_upload, GLOB.access_eva, GLOB.access_heads,
			            GLOB.access_all_personal_lockers, GLOB.access_maint_tunnels, GLOB.access_bar, GLOB.access_janitor, GLOB.access_construction, GLOB.access_morgue,
			            GLOB.access_crematorium, GLOB.access_kitchen, GLOB.access_cargo, GLOB.access_cargo_bot, GLOB.access_mailsorting, GLOB.access_qm, GLOB.access_hydroponics, GLOB.access_lawyer,
			            GLOB.access_theatre, GLOB.access_chapel_office, GLOB.access_library, GLOB.access_research, GLOB.access_mining, GLOB.access_heads_vault, GLOB.access_mining_station,
			            GLOB.access_hop, GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_gateway, GLOB.access_mineral_storeroom)


/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/hop

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hopcap
	backpack_contents = list(/obj/item/weapon/storage/box/ids=1,\
		/obj/item/weapon/melee/classic_baton/telescopic=1, /obj/item/device/modular_computer/tablet/preset/advanced = 1)
