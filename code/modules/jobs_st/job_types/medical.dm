/*
Chief Medical Officer
*/
/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_head = list("Commanding Officer")
	department_flag = MEDJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commanding Officer"
	selection_color = "#ffddf0"
	req_admin_notify = 1
	minimal_player_age = 7

	outfit = /datum/outfit/job/cmo

	access = list(access_medical, access_morgue, access_genetics, access_heads, access_mineral_storeroom,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_heads, access_mineral_storeroom,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors)

/datum/outfit/job/cmo
	name = "Chief Medical Officer"

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
	satchel = /obj/item/weapon/storage/backpack/satchel_med
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/med

/datum/outfit/job/cmo/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	announce_head(H, list("Medical")) //tell underlings (medical radio) they have a head

/*
Medical Doctor
*/
/datum/job/doctor
	title = "Medical Officer"
	flag = MEDOFFICER
	department_head = list("Chief Medical Officer")
	department_flag = MEDJOBS
	faction = "Federation"
	total_positions = 5
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/doctor

	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)
	minimal_access = list(access_medical, access_morgue, access_surgery)

/datum/outfit/job/doctor
	name = "Medical Officer"

	belt = /obj/item/device/pda/medical
	ears = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat
	l_hand = /obj/item/weapon/storage/firstaid/regular
	suit_store = /obj/item/device/flashlight/pen

	backpack = /obj/item/weapon/storage/backpack/medic
	satchel = /obj/item/weapon/storage/backpack/satchel_med
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/med

/*
Nurse
*/
/datum/job/nurse
	title = "Nurse"
	flag = NURSE
	department_head = list("Chief Medical Officer")
	department_flag = MEDJOBS
	faction = "Federation"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/nurse

	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)
	minimal_access = list(access_medical, access_chemistry, access_mineral_storeroom)

/datum/outfit/job/nurse
	name = "Nurse"

	glasses = /obj/item/clothing/glasses/science
	belt = /obj/item/device/pda/chemist
	ears = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/chemist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/chemist

	backpack = /obj/item/weapon/storage/backpack/chemistry
	satchel = /obj/item/weapon/storage/backpack/satchel_chem
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/med

/*
Counsellor
*/
/datum/job/counsellor
	title = "Counsellor"
	flag = COUNSELLOR
	department_head = list("Chief Medical Officer")
	department_flag = MEDJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/counsellor

	access = list(access_medical, access_morgue, access_chemistry, access_virology, access_genetics, access_research, access_xenobiology, access_robotics, access_mineral_storeroom, access_tech_storage)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_research)

/datum/outfit/job/counsellor
	name = "Counsellor"

	belt = /obj/item/device/pda/geneticist
	ears = /obj/item/device/radio/headset/headset_medsci
	uniform = /obj/item/clothing/under/rank/geneticist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/genetics
	suit_store =  /obj/item/device/flashlight/pen

	backpack = /obj/item/weapon/storage/backpack/genetics
	satchel = /obj/item/weapon/storage/backpack/satchel_gen
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/med

