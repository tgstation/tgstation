/*
Research Director
*/
/datum/job/rd
	title = "Research Director"
	flag = RD_JF
	department_head = list("Captain")
	department_flag = MEDSCI
	head_announce = list("Science")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	req_admin_notify = 1
	minimal_player_age = 7

	outfit = /datum/outfit/job/rd

	access = list(GLOB.access_rd, GLOB.access_heads, GLOB.access_tox, GLOB.access_genetics, GLOB.access_morgue,
			            GLOB.access_tox_storage, GLOB.access_teleporter, GLOB.access_sec_doors,
			            GLOB.access_research, GLOB.access_robotics, GLOB.access_xenobiology, GLOB.access_ai_upload,
			            GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_gateway, GLOB.access_mineral_storeroom,
			            GLOB.access_tech_storage, GLOB.access_minisat, GLOB.access_maint_tunnels, GLOB.access_network)
	minimal_access = list(GLOB.access_rd, GLOB.access_heads, GLOB.access_tox, GLOB.access_genetics, GLOB.access_morgue,
			            GLOB.access_tox_storage, GLOB.access_teleporter, GLOB.access_sec_doors,
			            GLOB.access_research, GLOB.access_robotics, GLOB.access_xenobiology, GLOB.access_ai_upload,
			            GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_gateway, GLOB.access_mineral_storeroom,
			            GLOB.access_tech_storage, GLOB.access_minisat, GLOB.access_maint_tunnels, GLOB.access_network)

/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/rd

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/rd
	ears = /obj/item/device/radio/headset/heads/rd
	uniform = /obj/item/clothing/under/rank/research_director
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/toggle/labcoat
	l_hand = /obj/item/weapon/clipboard
	l_pocket = /obj/item/device/laser_pointer
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack_contents = list(/obj/item/weapon/melee/classic_baton/telescopic=1,/obj/item/device/modular_computer/tablet/preset/advanced=1)

	backpack = /obj/item/weapon/storage/backpack/science
	satchel = /obj/item/weapon/storage/backpack/satchel/tox

/datum/outfit/job/rd/rig
	name = "Research Director (Hardsuit)"

	l_hand = null
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/rd
	suit_store = /obj/item/weapon/tank/internals/oxygen
	internals_slot = slot_s_store

/*
Scientist
*/
/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"

	outfit = /datum/outfit/job/scientist

	access = list(GLOB.access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_mineral_storeroom, GLOB.access_tech_storage, GLOB.access_genetics)
	minimal_access = list(GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_mineral_storeroom)

/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	belt = /obj/item/device/pda/toxins
	ears = /obj/item/device/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/scientist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit = /obj/item/clothing/suit/toggle/labcoat/science

	backpack = /obj/item/weapon/storage/backpack/science
	satchel = /obj/item/weapon/storage/backpack/satchel/tox
	accessory = /obj/item/clothing/accessory/pocketprotector/full

/*
Roboticist
*/
/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"

	outfit = /datum/outfit/job/roboticist

	access = list(GLOB.access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_tech_storage, GLOB.access_morgue, GLOB.access_research, GLOB.access_mineral_storeroom, GLOB.access_xenobiology, GLOB.access_genetics)
	minimal_access = list(GLOB.access_robotics, GLOB.access_tech_storage, GLOB.access_morgue, GLOB.access_research, GLOB.access_mineral_storeroom)

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	belt = /obj/item/weapon/storage/belt/utility/full
	l_pocket = /obj/item/device/pda/roboticist
	ears = /obj/item/device/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat

	backpack = /obj/item/weapon/storage/backpack/science
	satchel = /obj/item/weapon/storage/backpack/satchel/tox

	pda_slot = slot_l_store
