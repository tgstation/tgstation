var/list/sec_departments = list("engineering", "supply", "medical", "science")

proc/assign_sec_to_department(var/mob/living/carbon/human/H)
	if(sec_departments.len)
		var/department = pick(sec_departments)
		sec_departments -= department
		var/access = null
		var/destination = null
		switch(department)
			if("supply")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/supply(H), slot_ears)
				access = list(access_cargo, access_mining)
				destination = /area/quartermaster/storage
			if("engineering")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/engi(H), slot_ears)
				access = list(access_construction, access_engine)
				destination = /area/engine/break_room
			if("medical")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/med(H), slot_ears)
				access = list(access_medical)
				destination = /area/medical/medbay
			if("science")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/sci(H), slot_ears)
				access = list(access_research)
				destination = /area/medical/research
			else
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)


		if(destination)
			spawn(15)
				if(H)
					H.loc = pick(get_area_turfs(destination))
					H << "<b>You have been assigned to [department]!</b>"
					if(locate(/obj/item/weapon/card/id, H))
						var/obj/item/weapon/card/id/I = locate(/obj/item/weapon/card/id, H)
						if(I)
							I.access |= access


/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	selection_color = "#ffeeee"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(H), slot_back)
		if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_sec(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/security(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_s_store)
		H.equip_to_slot_or_del(new /obj/item/device/flash(H), slot_l_store)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_l_hand)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		assign_sec_to_department(H)
		return 1

/obj/item/device/radio/headset/headset_sec/department/New()
	recalculateChannels()

/obj/item/device/radio/headset/headset_sec/department/engi
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_sec/department/supply
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/headset_sec/department/med
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sec/department/sci
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_sci