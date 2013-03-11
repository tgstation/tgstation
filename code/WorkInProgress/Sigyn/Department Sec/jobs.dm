var/list/sec_departments = list("engineering", "supply", "medical", "science")

/datum/job/officer/proc/assign_sec_to_department(var/mob/living/carbon/human/H)
	if(!sec_departments.len)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
	else
		var/department = pick(sec_departments)
		sec_departments -= department
		var/access = null
		var/destination = null
		switch(department)
			if("supply")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/cargo(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/supply(H), slot_ears)
				access = list(access_mailsorting, access_mining)
				destination = /area/security/checkpoint/supply
			if("engineering")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/engine(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/engi(H), slot_ears)
				access = list(access_construction, access_engine)
				destination = /area/security/checkpoint/engineering
			if("medical")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/med(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/med(H), slot_ears)
				access = list(access_medical)
				destination = /area/security/checkpoint/medical
			if("science")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/science(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec/department/sci(H), slot_ears)
				access = list(access_research)
				destination = /area/security/checkpoint/science

		if(destination)
			var/teleport = 0
			if(!ticker || ticker.current_state <= GAME_STATE_SETTING_UP)
				teleport = 1
			spawn(10)
				if(H)
					if(teleport)
						var/turf/T
						var/safety = 0
						while(safety < 25)
							T = pick(get_area_turfs(destination))
							if(!H.Move(T))
								safety += 1
								continue
							else
								break
					H << "<b>You have been assigned to [department]!</b>"
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
		assign_sec_to_department(H)
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
		return 1

/obj/item/device/radio/headset/headset_sec/department/New()
	wires = new(src)
	secure_radio_connections = new

	if(radio_controller)
		initialize()
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

/obj/item/clothing/under/rank/security/cargo/New()
	var/obj/item/clothing/tie/armband/cargo/A		= new /obj/item/clothing/tie/armband/cargo
	hastie = A

/obj/item/clothing/under/rank/security/engine/New()
	var/obj/item/clothing/tie/armband/engine/A		= new /obj/item/clothing/tie/armband/engine
	hastie = A

/obj/item/clothing/under/rank/security/science/New()
	var/obj/item/clothing/tie/armband/science/A		= new /obj/item/clothing/tie/armband/science
	hastie = A

/obj/item/clothing/under/rank/security/med/New()
	var/obj/item/clothing/tie/armband/medgreen/A	= new /obj/item/clothing/tie/armband/medgreen
	hastie = A