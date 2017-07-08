/*
Chief Medical Officer
*/
/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO_JF
	department_head = list("Captain")
	department_flag = MEDSCI
	head_announce = list("Medical")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	req_admin_notify = 1
	minimal_player_age = 7

	outfit = /datum/outfit/job/cmo

	access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_heads, GLOB.access_mineral_storeroom,
			GLOB.access_chemistry, GLOB.access_virology, GLOB.access_cmo, GLOB.access_surgery, GLOB.access_RC_announce,
			GLOB.access_keycard_auth, GLOB.access_sec_doors, GLOB.access_maint_tunnels)
	minimal_access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_heads, GLOB.access_mineral_storeroom,
			GLOB.access_chemistry, GLOB.access_virology, GLOB.access_cmo, GLOB.access_surgery, GLOB.access_RC_announce,
			GLOB.access_keycard_auth, GLOB.access_sec_doors, GLOB.access_maint_tunnels)

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/cmo

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/cmo
	ears = /obj/item/device/radio/headset/heads/cmo
	uniform = /obj/item/clothing/under/rank/chief_medical_officer
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	l_hand = /obj/item/weapon/storage/firstaid/regular
	suit_store = /obj/item/device/flashlight/pen
	backpack_contents = list(/obj/item/weapon/melee/classic_baton/telescopic=1)

	backpack = /obj/item/weapon/storage/backpack/medic
	satchel = /obj/item/weapon/storage/backpack/satchel/med
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/med

/*
Medical Doctor
*/
/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/doctor

	access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_surgery, GLOB.access_chemistry, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_mineral_storeroom)
	minimal_access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_surgery, GLOB.access_cloning)

/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor

	belt = /obj/item/device/pda/medical
	ears = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat
	l_hand = /obj/item/weapon/storage/firstaid/regular
	suit_store = /obj/item/device/flashlight/pen

	backpack = /obj/item/weapon/storage/backpack/medic
	satchel = /obj/item/weapon/storage/backpack/satchel/med
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/med

/*
Chemist
*/
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/chemist

	access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_surgery, GLOB.access_chemistry, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_mineral_storeroom)
	minimal_access = list(GLOB.access_medical, GLOB.access_chemistry, GLOB.access_mineral_storeroom)

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	glasses = /obj/item/clothing/glasses/science
	belt = /obj/item/device/pda/chemist
	ears = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/chemist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/chemist
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack = /obj/item/weapon/storage/backpack/chemistry
	satchel = /obj/item/weapon/storage/backpack/satchel/chem
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/med

/*
Geneticist
*/
/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_head = list("Chief Medical Officer", "Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/geneticist

	access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_chemistry, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_robotics, GLOB.access_mineral_storeroom, GLOB.access_tech_storage)
	minimal_access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_research)

/datum/outfit/job/geneticist
	name = "Geneticist"
	jobtype = /datum/job/geneticist

	belt = /obj/item/device/pda/geneticist
	ears = /obj/item/device/radio/headset/headset_medsci
	uniform = /obj/item/clothing/under/rank/geneticist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/genetics
	suit_store =  /obj/item/device/flashlight/pen

	backpack = /obj/item/weapon/storage/backpack/genetics
	satchel = /obj/item/weapon/storage/backpack/satchel/gen
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/med

/*
Virologist
*/
/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/virologist

	access = list(GLOB.access_medical, GLOB.access_morgue, GLOB.access_surgery, GLOB.access_chemistry, GLOB.access_virology, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_mineral_storeroom)
	minimal_access = list(GLOB.access_medical, GLOB.access_virology, GLOB.access_mineral_storeroom)

/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist

	belt = /obj/item/device/pda/viro
	ears = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/virologist
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/virologist
	suit_store =  /obj/item/device/flashlight/pen

	backpack = /obj/item/weapon/storage/backpack/virology
	satchel = /obj/item/weapon/storage/backpack/satchel/vir
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/med
