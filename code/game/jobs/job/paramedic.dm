/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/medical
	access = list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks)
	minimal_access=list(access_paramedic, access_medical, access_sec_doors, access_maint_tunnels, access_external_airlocks)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/medical

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_med(H), slot_ears)
		if(H.backbag == 2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/medic (H), slot_back)
		if(H.backbag == 3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/medical/paramedic(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/mask/cigarette(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/head/soft/paramedic(H), slot_head)
		H.equip_or_collect(new /obj/item/device/flashlight/pen(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/device/healthanalyzer(H), slot_l_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/device/healthanalyzer(H.back), slot_in_backpack)
		return 1
