/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/hos
	req_admin_notify = 1
	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_player_age = 14

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/heads/hos

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/security(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_sec(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/hos(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/head_of_security(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/heads/hos(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
//		H.equip_or_collect(new /obj/item/clothing/mask/gas(H), slot_wear_mask) //Grab one from the armory you donk
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses/sechud(H), slot_glasses)
		H.equip_or_collect(new /obj/item/weapon/gun/energy/gun(H), slot_s_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_l_store)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		var/datum/organ/external/affected = H.get_organ("head")
		affected.implants += L
		L.part = affected
		return 1



/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/security
	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels, access_morgue)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels)
	minimal_player_age = 7

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/warden

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/security(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_sec(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/warden(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/warden(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses/sechud(H), slot_glasses)
//		H.equip_or_collect(new /obj/item/clothing/mask/gas(H), slot_wear_mask) //Grab one from the armory you donk
		H.equip_or_collect(new /obj/item/device/flash(H), slot_l_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_l_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		var/datum/organ/external/affected = H.get_organ("head")
		affected.implants += L
		L.part = affected
		return 1



/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/security

	access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
	minimal_access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
	alt_titles = list("Forensic Technician")

	minimal_player_age = 7


	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/detective

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/det(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/detective(H), slot_belt)
/*		var/obj/item/clothing/mask/cigarette/CIG = new /obj/item/clothing/mask/cigarette(H)
		CIG.light("")
		H.equip_or_collect(CIG, slot_wear_mask)	*/
		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.mind.role_alt_title && H.mind.role_alt_title == "Forensic Technician")
			H.equip_or_collect(new /obj/item/clothing/suit/storage/forensics/blue(H), slot_wear_suit)
		else
			H.equip_or_collect(new /obj/item/clothing/suit/storage/det_suit(H), slot_wear_suit)
			H.equip_or_collect(new /obj/item/clothing/head/det_hat(H), slot_head)
		H.equip_or_collect(new /obj/item/weapon/lighter/zippo(H), slot_l_store)

		if(H.backbag == 1)//Why cant some of these things spawn in his office?
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/storage/box/evidence(H), slot_l_hand)
			H.equip_or_collect(new /obj/item/device/detective_scanner(H), slot_r_store)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/storage/box/evidence(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/device/detective_scanner(H), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		var/datum/organ/external/affected = H.get_organ("head")
		affected.implants += L
		L.part = affected
		H.dna.SetSEState(SOBERBLOCK,1)
		H.mutations += M_SOBER
		H.check_mutations = 1
		return 1



/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/security
	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels)
	minimal_player_age = 7

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/security

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/security(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_sec(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/security(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/security(H), slot_belt)
		H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_s_store)
		H.equip_or_collect(new /obj/item/device/flash(H), slot_l_store)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_l_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		var/datum/organ/external/affected = H.get_organ("head")
		affected.implants += L
		L.part = affected
		return 1
