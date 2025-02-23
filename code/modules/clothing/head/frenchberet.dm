/obj/item/clothing/head/frenchberet
	name = "french beret"
	desc = "A quality beret, infused with the aroma of chain-smoking, wine-swilling Parisians. You feel less inclined to engage in military conflict, for some reason."
	icon_state = "beret"
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#972A2A"
	hair_mask = HAIR_MASK_HIDE_ABOVE_45_DEG_MEDIUM

/obj/item/clothing/head/frenchberet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("french_replacement.json", "french"), end_string = list(" Honh honh honh!"," Honh!"," Zut Alors!"), end_string_chance = 3, slots = ITEM_SLOT_HEAD)

/obj/item/clothing/head/frenchberet/equipped(mob/M, slot)
	. = ..()
	if (slot & ITEM_SLOT_HEAD)
		ADD_TRAIT(M, TRAIT_GARLIC_BREATH, type)
	else
		REMOVE_TRAIT(M, TRAIT_GARLIC_BREATH, type)

/obj/item/clothing/head/frenchberet/dropped(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_GARLIC_BREATH, type)
