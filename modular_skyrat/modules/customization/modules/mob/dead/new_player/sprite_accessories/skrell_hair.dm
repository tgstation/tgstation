/datum/sprite_accessory/skrell_hair
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/skrell_hair.dmi'
	generic = "Skrell Headtails"
	key = "skrell_hair"
	color_src = USE_ONE_COLOR
	relevent_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/skrell_hair/is_hidden(mob/living/carbon/human/H, obj/item/bodypart/HD)
	if(H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)))
		return TRUE
	return FALSE

/datum/sprite_accessory/skrell_hair/long
	name = "Female"
	icon_state = "long"

/datum/sprite_accessory/skrell_hair/short
	name = "Male"
	icon_state = "short"
