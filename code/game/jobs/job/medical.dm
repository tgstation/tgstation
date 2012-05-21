/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/silver


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/cmo(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_med(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chief_medical_officer(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/heads/cmo(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/cmo(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/healthanalyzer(H), H.slot_r_store)
		return 1



/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	alt_titles = list("Virologist", "Surgeon", "Emergency Medical Technician")


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_med(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4)
			if(alt_titles == "Virologist")
				H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_vir(H), H.slot_back)
			else
				H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_med(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/medical(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/healthanalyzer(H), H.slot_r_store)
		return 1



//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_chem(H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chemist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/chemist(H), H.slot_wear_suit)
		return 1



/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_gen(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat/genetics(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		return 1


/*
/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/virologist(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/medical(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/mask/surgical(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/labcoat/virologist(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/device/flashlight/pen(H), H.slot_s_store)
		return 1
*/

