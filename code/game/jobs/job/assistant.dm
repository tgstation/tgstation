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

/datum/job/assistant/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)

	var/random_uniform = pick(/obj/item/clothing/under/color/black,
							/obj/item/clothing/under/color/blue,
							/obj/item/clothing/under/color/green,
							/obj/item/clothing/under/color/grey,
							/obj/item/clothing/under/color/pink,
							/obj/item/clothing/under/color/red,
							/obj/item/clothing/under/color/yellow,
							/obj/item/clothing/under/color/lightblue,
							/obj/item/clothing/under/color/aqua,
							/obj/item/clothing/under/color/purple,
							/obj/item/clothing/under/color/lightgreen,
							/obj/item/clothing/under/color/lightblue,
							/obj/item/clothing/under/color/lightbrown,
							/obj/item/clothing/under/color/brown,
							/obj/item/clothing/under/color/yellowgreen,
							/obj/item/clothing/under/color/darkblue,
							/obj/item/clothing/under/color/maroon,
							/obj/item/clothing/under/color/lightred)

	H.equip_to_slot_or_del(new random_uniform(H), slot_w_uniform)

/datum/job/assistant/get_access()
	if(config.jobs_have_maint_access & ASSISTANTS_HAVE_MAINT_ACCESS) //Config has assistant maint access set
		. = ..()
		. |= list(access_maint_tunnels)
	else
		return ..()