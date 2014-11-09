/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/ce
	req_admin_notify = 1
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload)
	minimal_player_age = 7

	pdaslot=slot_l_store
	pdatype=/obj/item/device/pda/heads/ce


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/ce(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chief_engineer(H), slot_w_uniform)
		//H.equip_or_collect(new /obj/item/device/pda/heads/ce(H), slot_l_store)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/head/hardhat/white(H), slot_head)
		H.equip_or_collect(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/engineering
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")

	pdaslot=slot_l_store
	pdatype=/obj/item/device/pda/engineering


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_eng(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		switch(H.mind.role_alt_title)
			if("Station Engineer")
				H.equip_or_collect(new /obj/item/clothing/under/rank/engineer(H), slot_w_uniform)
			if("Maintenance Technician")
				H.equip_or_collect(new /obj/item/clothing/under/rank/maintenance_tech(H), slot_w_uniform)
			if("Electrician")
				H.equip_or_collect(new /obj/item/clothing/under/rank/electrician(H), slot_w_uniform)
			if("Engine Technician")
				H.equip_or_collect(new /obj/item/clothing/under/rank/engine_tech(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/orange(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/head/hardhat(H), slot_head)
		H.equip_or_collect(new /obj/item/device/t_scanner(H), slot_r_store)
		//H.equip_or_collect(new /obj/item/device/pda/engineering(H), slot_l_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/engineering
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction, access_engine_equip, access_external_airlocks)

	pdaslot=slot_l_store
	pdatype=/obj/item/device/pda/atmos


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_eng(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/atmospheric_technician(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/atmos(H), slot_l_store)
		H.equip_or_collect(new /obj/item/weapon/storage/belt/utility/atmostech(H), slot_belt)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
		return 1

/datum/job/mechanic
	title = "Mechanic"
	flag = MECHANIC
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the research director and the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/engineering
	access = list(access_eva, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_mechanic, access_tcomsat)
	minimal_access = list(access_maint_tunnels, access_emergency_storage, access_construction, access_engine_equip, access_external_airlocks, access_mechanic)
	alt_titles = list("Telecommunications Technician", "Spacepod Mechanic", "Greasemonkey")

	pdaslot=slot_l_store
	pdatype=/obj/item/device/pda/mechanic


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_engsci(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/mechanic(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/atmos(H), slot_l_store)
		H.equip_or_collect(new /obj/item/weapon/storage/belt/utility/complete(H), slot_belt)
		if(!(H.flags&DISABILITY_FLAG_NEARSIGHTED)) //Does this work?
			var/obj/item/clothing/glasses/welding/W = new (H)
			H.equip_or_collect(W, slot_glasses)
			W.toggle()
		else
			var/obj/item/clothing/head/welding/W = new (H)
			H.equip_or_collect(W, slot_head)
			W.toggle()
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
		return 1