/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	idtype = /obj/item/weapon/card/id/rd
	req_admin_notify = 1
	access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway)
	minimal_access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway)
	minimal_player_age = 7

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/heads/rd

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/rd(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/under/rank/research_director(H), slot_w_uniform)
		//H.equip_or_collect(new /obj/item/device/pda/heads/rd(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/weapon/clipboard(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1



/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology)
	minimal_access = list(access_tox, access_tox_storage, access_research, access_xenobiology)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Plasma Researcher", "Xenobiologist", "Research Botanist")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/toxins

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.mind.role_alt_title == "Research Botanist")
			H.equip_or_collect(new /obj/item/device/radio/headset/headset_servsci(H), slot_ears)
		else
			H.equip_or_collect(new /obj/item/device/radio/headset/headset_sci(H), slot_ears)
		switch(H.mind.role_alt_title)
			if("Scientist")
				H.equip_or_collect(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
			if("Plasma Researcher")
				H.equip_or_collect(new /obj/item/clothing/under/rank/plasmares(H), slot_w_uniform)
			if("Xenobiologist")
				H.equip_or_collect(new /obj/item/clothing/under/rank/xenobio(H), slot_w_uniform)
			if("Anomalist")
				H.equip_or_collect(new /obj/item/clothing/under/rank/anomalist(H), slot_w_uniform)
			if("Xenoarcheologist")
				H.equip_or_collect(new /obj/item/clothing/under/rank/xenoarch(H), slot_w_uniform)
			if("Research Botanist")
				H.equip_or_collect(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
				H.equip_or_collect(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
				H.equip_or_collect(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/shoes/white(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/toxins(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat/science(H), slot_wear_suit)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1



/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/research
	access = list(access_robotics, access_tox, access_tox_storage, access_tech_storage, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/roboticist

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_sci(H), slot_ears)
		if(H.backbag == 2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.backbag == 3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		switch(H.mind.role_alt_title)
			if("Roboticist")
				H.equip_or_collect(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
			if("Mechatronic Engineer")
				H.equip_or_collect(new /obj/item/clothing/under/rank/mechatronic(H), slot_w_uniform)
			if("Biomechanical Engineer")
				H.equip_or_collect(new /obj/item/clothing/under/rank/biomechanical(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/roboticist(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_or_collect(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1
