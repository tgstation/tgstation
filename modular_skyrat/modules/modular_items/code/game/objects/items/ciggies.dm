/obj/item/clothing/mask/holocigarette
	name = "Holocigarette"
	desc = "A cigarette created using holodeck technology. Want to smoke without all the downsides? Try Holocigarettes!"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigoff"
	throw_speed = 0.5
	inhand_icon_state = "cigoff"
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	// Note - these are in masks.dmi not in cigarette.dmi
	/// The icon state used when this is lit.
	var/icon_on = "cigon"
	/// The icon state used when this is extinguished.
	var/icon_off = "cigoff"
	var/lit = FALSE
	actions_types = list(/datum/action/item_action/toggle_lit)

/obj/item/clothing/mask/holocigarette/cigar
	name = "Bright Cosmos cigar"
	desc = "A fancy cigar created using holodeck technology. They look like they have a \"Bright Cosmos\" branding on their wrap."
	icon_state = "cigar2off"
	inhand_icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/datum/action/item_action/toggle_lit
    name = "Light"
    desc = "Light or extinguish the holocigarette"

/datum/action/item_action/toggle_lit/Trigger()
	var/obj/item/clothing/mask/holocigarette/smoked = target
	var/mob/living/carbon/smoker = owner
	if(smoked.lit == FALSE)
		smoked.icon_state = smoked.icon_on
		smoked.inhand_icon_state = smoked.icon_on
		smoked.lit = TRUE
		smoked.name = "lit [smoked.name]"
	else
		smoked.icon_state = smoked.icon_off
		smoked.inhand_icon_state = smoked.icon_off
		smoked.lit = FALSE
		smoked.name = copytext_char(smoked.name, 5) //5 == length_char("lit ") + 1
	smoked.update_icon()
	smoker.update_inv_wear_mask()
