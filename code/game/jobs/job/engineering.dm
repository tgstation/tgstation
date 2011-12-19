/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/ce(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/heads/ce(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat/white(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/full(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), H.slot_gloves)
		return 1



/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/engineer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/belt/utility/full(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/t_scanner(H), H.slot_r_store)
		return 1



/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), H.slot_l_hand)
		return 1



/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 1

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/engineering(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), H.slot_l_hand)
		return 1