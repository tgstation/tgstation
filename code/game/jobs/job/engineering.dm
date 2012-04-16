/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/silver


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/ce(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/heads/ce(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat/white(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/full(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), H.slot_gloves)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H.back), H.slot_in_backpack)
		return 1



/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/engineer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/full(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/t_scanner(H), H.slot_r_store)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H.back), H.slot_in_backpack)
		return 1



/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/atmostech/(H), H.slot_l_hand)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/engineer(H.back), H.slot_in_backpack)
		return 1



/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the chief engineer and research director"
	selection_color = "#fff5cc"

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_rob(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), H.slot_l_hand)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H), H.slot_r_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H.back), H.slot_in_backpack)
		return 1