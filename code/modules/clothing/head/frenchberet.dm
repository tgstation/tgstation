/obj/item/clothing/head/beret/frenchberet
	name = "french beret"
	desc = "A quality beret, infused with the aroma of chain-smoking, wine-swilling Parisians. You feel less inclined to engage in military conflict, for some reason."
	flags_1 = NO_NEW_GAGS_PREVIEW_1

/obj/item/clothing/head/beret/frenchberet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("french_replacement.json", "french"), end_string = list(" Honh honh honh!"," Honh!"," Zut Alors!"), end_string_chance = 3, slots = ITEM_SLOT_HEAD)

/obj/item/clothing/head/beret/frenchberet/equipped(mob/user, slot, initial)
	. = ..()
	if (slot & ITEM_SLOT_HEAD)
		ADD_TRAIT(user, TRAIT_GARLIC_BREATH, type)
	else
		REMOVE_TRAIT(user, TRAIT_GARLIC_BREATH, type)

/obj/item/clothing/head/beret/frenchberet/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GARLIC_BREATH, type)
