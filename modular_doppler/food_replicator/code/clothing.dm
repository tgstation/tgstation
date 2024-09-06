/obj/item/clothing/under/colonial
	name = "colonial outfit"
	desc = "Fancy white satin shirt and a pair of cotton-blend pants with a black synthleather belt."
	icon = 'modular_doppler/food_replicator/icons/clothing.dmi'
	worn_icon = 'modular_doppler/food_replicator/icons/clothing_worn.dmi'
//	worn_icon_digi = 'modular_doppler/food_replicator/icons/clothing_digi.dmi'
	icon_state = "under_colonial"
/*
/obj/item/clothing/under/colonial/mob_can_equip(mob/living/equipper, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if(is_species(equipper, /datum/species/teshari))
		to_chat(equipper, span_warning("[src] is far too big for you!"))
		return FALSE

	return ..()
*/
/obj/item/clothing/shoes/jackboots/colonial
	name = "colonial half-boots"
	desc = "Good old laceless boots, with a sturdy plastic toe to, theoretically, keep your toes uncrushed."
	icon = 'modular_doppler/food_replicator/icons/clothing.dmi'
	worn_icon = 'modular_doppler/food_replicator/icons/clothing_worn.dmi'
//	worn_icon_digi = 'modular_doppler/food_replicator/icons/clothing_digi.dmi'
	icon_state = "boots_colonial"
/*
/obj/item/clothing/shoes/jackboots/colonial/mob_can_equip(mob/living/equipper, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if(is_species(equipper, /datum/species/teshari))
		to_chat(equipper, span_warning("[src] is far too big for you!"))
		return FALSE

	return ..()
*/
/obj/item/clothing/neck/cloak/colonial
	name = "colonial cloak"
	desc = "A cloak made from heavy tarpaulin. Nigh wind- and waterproof thanks to its design."
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'modular_doppler/food_replicator/icons/clothing.dmi'
	worn_icon = 'modular_doppler/food_replicator/icons/clothing_worn.dmi'
//	worn_icon_digi = 'modular_doppler/food_replicator/icons/clothing_digi.dmi'
	icon_state = "cloak_colonial"
	allowed = /obj/item/clothing/suit/jacket/leather::allowed // these are special and can be worn in the suit slot, so we need this var to be defined
/*
/obj/item/clothing/neck/cloak/colonial/mob_can_equip(mob/living/equipper, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if(is_species(equipper, /datum/species/teshari))
		to_chat(equipper, span_warning("[src] is far too big for you!"))
		return FALSE

	return ..()
*/
/obj/item/clothing/head/hats/colonial
	name = "colonial cap"
	desc = "A puffy cap made out of tarpaulin covered by some textile. It is sturdy and comfortable, and seems to retain its form very well."
	icon = 'modular_doppler/food_replicator/icons/clothing.dmi'
	worn_icon = 'modular_doppler/food_replicator/icons/clothing_worn.dmi'
//	worn_icon_digi = 'modular_doppler/food_replicator/icons/clothing_digi.dmi'
	icon_state = "cap_colonial"
	inhand_icon_state = null
//	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON
/*
/obj/item/clothing/head/hats/colonial/mob_can_equip(mob/living/equipper, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if(is_species(equipper, /datum/species/teshari))
		to_chat(equipper, span_warning("[src] is far too big for you!"))
		return FALSE

	return ..()
*/
