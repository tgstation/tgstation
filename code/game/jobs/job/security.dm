/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security (H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/hos(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/armourrigvest(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/heads/hos(H), H.slot_belt)
//		H.equip_if_possible(new /obj/item/clothing/suit/armor/hos(H), H.slot_wear_suit)
//We're Bay12, not Goon.  We don't need armor 24/7
		H.equip_if_possible(new /obj/item/clothing/gloves/hos(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/gun/energy/gun(H), H.slot_s_store)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1



/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/warden(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/security(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest/warden(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/warden(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/gloves/red(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/device/flash(H), H.slot_l_store)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1



/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	alt_titles = list("Forensic Technician")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/det(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/det_suit(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/detective(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/head/det_hat(H), H.slot_head)
/*		var/obj/item/clothing/mask/cigarette/CIG = new /obj/item/clothing/mask/cigarette(H)
		CIG.light("")
		H.equip_if_possible(CIG, H.slot_wear_mask)	*/
		//Fuck that thing.  --SkyMarshal
		H.equip_if_possible(new /obj/item/clothing/gloves/detective(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/box/evidence(H.back), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/fcardholder(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/device/detective_scanner(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/dflask(H.back), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/zippo(H), H.slot_l_store)
//		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/candy_corn(H), H.slot_h_store)
//		No... just no. --SkyMarshal
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1



/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/security(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/security(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/gearharness(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/secsoft(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/clothing/gloves/red(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/flash(H), H.slot_l_store)
		var/datum/organ/external/O = H.organs[pick(H.organs)]
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(O)
		O.implant += L
		L.imp_in = H
		L.implanted = 1
		return 1
