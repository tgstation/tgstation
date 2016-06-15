/*
Executive Officer, aka Number One
*/
/datum/job/coo
	title = "Chief of Operations"
	flag = COO
	department_head = list("Commanding Officer")
	department_flag = OPSJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commanding Officer"
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 10

	outfit = /datum/outfit/job/coo

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


/datum/outfit/job/coo
	name = "Chief of Operations"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hopcap
	backpack_contents = list(/obj/item/weapon/storage/box/ids=1,\
		/obj/item/weapon/melee/classic_baton/telescopic=1)

/*
Helmsman
*/
/datum/job/helmsman
	title = "Helmsman"
	flag = HELMSMAN
	department_head = list("Chief of Operations")
	department_flag = OPSJOBS
	faction = "Federation"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief of Operations, any Bridge Officers"
	selection_color = "#dddddd"
	access = list(access_heads)
	access = list(access_heads)
	outfit = /datum/outfit/job/helmsman

/datum/outfit/job/helmsman
	name = "Helmsman"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown

/*
QM
*/
/datum/job/qm
	title = "Quartermaster"
	flag = QM
	department_head = list("Chief of Operations")
	department_flag = OPSJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief of Operations, any Bridge Officers"
	selection_color = "#dddddd"
	access = list(access_heads)
	access = list(access_heads)
	outfit = /datum/outfit/job/qm

/datum/outfit/job/qm
	name = "Quartermaster"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown

/*
COMMS
*/
/datum/job/commsofficer
	title = "Comms Officer"
	flag = COMMSOFFICER
	department_head = list("Chief of Operations")
	department_flag = OPSJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief of Operations, any Bridge Officers"
	selection_color = "#dddddd"
	access = list(access_heads)
	access = list(access_heads)
	outfit = /datum/outfit/job/commsofficer

/datum/outfit/job/commsofficer
	name = "Comms Officer"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown

/*
DM
*/
/datum/job/dutyofficer
	title = "Duty Officer"
	flag = DUTYOFFICER
	department_head = list("Chief of Operations")
	department_flag = OPSJOBS
	faction = "Federation"
	total_positions = 10
	spawn_positions = 10
	supervisors = "the Chief of Operations"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/dutyofficer

/datum/outfit/job/dutyofficer
	name = "Duty Officer"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown
