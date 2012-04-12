/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/captain(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/captain(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/caphat(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/storage/id_kit(H), H.slot_in_backpack)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		world << "<b>[H.real_name] is the captain!</b>"
		return 1



/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/heads/hop(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/helmet(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/id_kit(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/clothing/gloves/blue(H), H.slot_gloves)
		return 1
