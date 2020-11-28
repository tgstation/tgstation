/datum/sprite_accessory/frills
	key = "frills"
	generic = "Frills"
	default_color = DEFAULT_SECONDARY
	relevent_layers = list(BODY_ADJ_LAYER)

/datum/sprite_accessory/frills/is_hidden(mob/living/carbon/human/H, obj/item/bodypart/HD)
	if(H.head && (H.head.flags_inv & HIDEEARS) || !HD || HD.status == BODYPART_ROBOTIC)
		return TRUE
	return FALSE

/datum/sprite_accessory/frills/divinity
	name = "Divinity"
	icon_state = "divinity"
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/frills.dmi'

/datum/sprite_accessory/frills/horns
	name = "Horns"
	icon_state = "horns"
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/frills.dmi'

/datum/sprite_accessory/frills/hornsdouble
	name = "Horns Double"
	icon_state = "hornsdouble"
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/frills.dmi'

/datum/sprite_accessory/frills/big
	name = "Big"
	icon_state = "big"
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/frills.dmi'

/datum/sprite_accessory/frills/cobrahood
	name = "Cobra Hood"
	icon_state = "cobrahood"
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/frills.dmi'
	color_src = USE_MATRIXED_COLORS

/datum/sprite_accessory/frills/cobrahoodears
	name = "Cobra Hood (Ears)"
	icon_state = "cobraears"
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/frills.dmi'
	color_src = USE_MATRIXED_COLORS
