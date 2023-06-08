GLOBAL_DATUM(dukeman, /mob/living/carbon/human/species/monkey/dukeman)

/mob/living/carbon/human/species/monkey/dukeman
	name = "Ook"
	unique_name = FALSE
	use_random_name = FALSE
	ai_controller = /datum/ai_controller/monkey/dukeman

/mob/living/carbon/human/species/monkey/dukeman/Initialize(mapload)
	var/name_to_use = name

	. = ..()

	if(!GLOB.dukeman && mapload)
		GLOB.dukeman = src

	fully_replace_character_name(name, name_to_use)

	equip_to_slot_or_del(new /obj/item/clothing/mask/ookmask(src), ITEM_SLOT_MASK)

/mob/living/carbon/human/species/monkey/dukeman/Destroy()
	if(GLOB.dukeman == src)
		GLOB.dukeman = null

	return ..()
