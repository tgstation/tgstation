/*
Assistant
*/
/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	var/list/subassist = list(access_maint_tunnels, access_medical, access_research, access_sec_doors, access_mailsorting)
	var/extra_access
	var/good_player = 1



/datum/job/assistant/equip_items(var/mob/living/carbon/human/H)
	extra_access = pick(subassist)
	subassist -= extra_access

	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)

	for(var/s in jobban_keylist)
		if(findtext(s,"[H.ckey]"))
			good_player = 0
			break

	if(good_player)
		switch(extra_access)
			if(access_maint_tunnels)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/yellow, slot_head)
			if(access_medical)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/mime, slot_head)
			if(access_research)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple, slot_head)
			if(access_sec_doors)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red, slot_head)
			if(access_mailsorting)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/orange, slot_head)
		access 			= list(extra_access)
		minimal_access 	= list(extra_access)

	else
		H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/black, slot_head) //shaaame
		subassist += extra_access

	good_player = 1
	for(var/access in subassist)
		return
	subassist = list(access_maint_tunnels, access_medical, access_research, access_sec_doors, access_mailsorting)

/datum/job/assistant/get_access()

	if(config.jobs_have_maint_access & ASSISTANTS_HAVE_MAINT_ACCESS) //Config has assistant maint access set
		. = ..()
		. |= list(access_maint_tunnels)
	else
		return ..()