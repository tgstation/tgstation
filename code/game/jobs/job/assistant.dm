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
	clothing = "Random"
	alt_clothing = list("Grey","Red","Blue","Brown","Yellow","Black","Orange")

/datum/job/assistant/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Random")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/random(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Grey")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Red")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Blue")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/blue(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Brown")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/brown(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Yellow")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/yellow(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Black")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), slot_w_uniform)
	else if(H.mind.role_alt_clothing && H.mind.role_alt_clothing == "Orange")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/random(H), slot_w_uniform)

/datum/job/assistant/get_access()
	if(config.jobs_have_maint_access & ASSISTANTS_HAVE_MAINT_ACCESS) //Config has assistant maint access set
		. = ..()
		. |= list(access_maint_tunnels)
	else
		return ..()