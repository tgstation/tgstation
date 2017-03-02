/*
Research Director
*/
/datum/job/rd
	title = "Research Director"
	flag = RD
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

	access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_gateway, access_mineral_storeroom,
			            access_tech_storage, access_minisat, access_maint_tunnels, access_network)
	minimal_access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_gateway, access_mineral_storeroom,
			            access_tech_storage, access_minisat, access_maint_tunnels, access_network)

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

	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology, access_mineral_storeroom, access_tech_storage, access_genetics)
	minimal_access = list(access_tox, access_tox_storage, access_research, access_xenobiology, access_mineral_storeroom)

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

	access = list(access_robotics, access_tox, access_tox_storage, access_tech_storage, access_morgue, access_research, access_mineral_storeroom, access_xenobiology, access_genetics)
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_research, access_mineral_storeroom)

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
