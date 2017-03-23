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
	minor_announce("Captain [H.real_name] on deck!")

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
	backpack_contents = list(/obj/item/weapon/melee/classic_baton/telescopic=1, /obj/item/station_charter=1)

	backpack = /obj/item/weapon/storage/backpack/captain
	satchel = /obj/item/weapon/storage/backpack/satchel/cap
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/captain

	implants = list(/obj/item/weapon/implant/mindshield)


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

	access = list(access_security, access_sec_doors, access_court, access_weapons,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_mineral_storeroom)
	minimal_access = list(access_security, access_sec_doors, access_court, access_weapons,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_mineral_storeroom)


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
