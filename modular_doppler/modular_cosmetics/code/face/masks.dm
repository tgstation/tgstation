/obj/item/clothing/mask/neck_gaiter
	name = "neck gaiter"
	desc = "A cloth for covering your neck, and usually part of your face too, but that part's optional. Has a small respirator to be used with internals."
	actions_types = list(/datum/action/item_action/adjust)
	alternate_worn_layer = UNDER_UNIFORM_LAYER
	icon_state = "gaiter"
	icon = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/face.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/GAGS/icons/mob/face.dmi'
	supported_bodyshapes = null
	bodyshape_icon_files = null
	inhand_icon_state = "balaclava"
	greyscale_config = /datum/greyscale_config/neck_gaiter
	greyscale_config_worn = /datum/greyscale_config/neck_gaiter/worn
	greyscale_colors = "#666666"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|MASKINTERNALS
	w_class = WEIGHT_CLASS_SMALL
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	flags_1 = IS_PLAYER_COLORABLE_1
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING

/obj/item/clothing/mask/neck_gaiter/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/mask/neck_gaiter/click_alt(mob/user)
	adjust_visor(user)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/neck_gaiter/click_alt_secondary(mob/user)
	alternate_worn_layer = (alternate_worn_layer == initial(alternate_worn_layer) ? NONE : initial(alternate_worn_layer))
	user.update_clothing(ITEM_SLOT_MASK)
	balloon_alert(user, "wearing [alternate_worn_layer == initial(alternate_worn_layer) ? "below" : "above"] suits")

/obj/item/clothing/mask/neck_gaiter/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be worn above or below your suit. Alt-Right-click to toggle.")
	. += span_notice("Alt-click [src] to adjust it.")

/obj/item/clothing/mask/neck_gaiter/cybersun
	name = "advanced neck gaiter"
	desc = "A glistening neck accessory, colored in a black pinstripe texture. The material is an attempt to imitate 'heatsilk' technology, but it is barely any <b>laser-reflective</b>. Has a small respirator to be used with internals."
	unique_death = 'modular_doppler/modular_sounds/sound/machines/hacked.ogg'
	greyscale_colors = "#333333"
	var/hit_reflect_chance = 5 // don't count on it, operative

/obj/item/clothing/mask/neck_gaiter/cybersun/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_HEAD))
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/mask/gas/respirator
	name = "half mask respirator"
	desc = "A half mask respirator that's really just a standard gas mask with the glass taken off."
	icon_state = "respirator"
	icon = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/face.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/GAGS/icons/mob/face.dmi'
	supported_bodyshapes = null
	bodyshape_icon_files = null
	inhand_icon_state = "sechailer"
	greyscale_config = /datum/greyscale_config/respirator
	greyscale_config_worn = /datum/greyscale_config/respirator/worn
	greyscale_colors = "#666666"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|MASKINTERNALS
	w_class = WEIGHT_CLASS_SMALL
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	flags_1 = IS_PLAYER_COLORABLE_1
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING

/obj/item/clothing/mask/gas/mantis
	name = "composite gas mask"
	desc = "This old-fashioned gas mask was primarily useful for climate-adjustment and keeping unwanted gasses and particulates out of whoever it's on."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/masks.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/masks.dmi'
	icon_state = "psychomalice"
	w_class = WEIGHT_CLASS_SMALL
	tint = 0
	supported_bodyshapes = null
	bodyshape_icon_files = null
	flags_inv = HIDEEARS|HIDEEYES|HIDESNOUT|HIDEFACIALHAIR
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES | PEPPERPROOF
	visor_flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES | PEPPERPROOF
	clothing_flags = VOICEBOX_DISABLED | MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT | GAS_FILTERING
	interaction_flags_click = NEED_DEXTERITY
	/// Whether or not the mask is currently being layered over (or under!) hair. FALSE/null means the mask is layered over the hair (this is how it starts off).
	var/wear_hair_over

/obj/item/clothing/mask/gas/mantis/item_ctrl_click(mob/user)
	if(!isliving(user))
		return CLICK_ACTION_BLOCKING
	if(user.get_active_held_item() != src)
		to_chat(user, span_warning("You must hold the [src] in your hand to do this!"))
		return CLICK_ACTION_BLOCKING
	voice_filter = voice_filter ? null : initial(voice_filter)
	to_chat(user, span_notice("Mask voice muffling [voice_filter ? "enabled" : "disabled"]."))
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/gas/mantis/Initialize(mapload)
	. = ..()
	register_context()
	if(wear_hair_over)
		alternate_worn_layer = BACK_LAYER

/obj/item/clothing/mask/gas/mantis/click_alt_secondary(mob/user)
	adjust_mask(user)

//this moves the mask above or below the hair layer
/obj/item/clothing/mask/gas/mantis/proc/adjust_mask(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(!user.incapacitated)
		var/is_worn = user.wear_mask == src
		wear_hair_over = !wear_hair_over
		if(wear_hair_over)
			alternate_worn_layer = BACK_LAYER
			to_chat(user, "You [is_worn ? "" : "will "]sweep your hair over the mask.")
		else
			alternate_worn_layer = initial(alternate_worn_layer)
			to_chat(user, "You [is_worn ? "" : "will "]sweep your hair under the mask.")

		user.update_worn_mask()

/obj/item/clothing/mask/gas/mantis/dropped(mob/living/carbon/human/user)
	var/prev_alternate_worn_layer = alternate_worn_layer
	. = ..()
	alternate_worn_layer = prev_alternate_worn_layer

/obj/item/clothing/mask/gas/nightlight
	name = "\improper half-face rebreather"
	desc = "A close-fitting respirator designed by Forestfel Intersystem Industries, this rebreather is commonly in use by those with sensitive faces, or a tight budget."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/masks.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/masks.dmi'
	icon_state = "fir36"
	actions_types = list(/datum/action/item_action/adjust)
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS //same flags as actual sec hailer gas mask
	flags_inv = HIDEFACE | HIDESNOUT
	flags_cover = NONE
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACE | HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	tint = 0
	supported_bodyshapes = null
	bodyshape_icon_files = null
	interaction_flags_click = NEED_DEXTERITY

/obj/item/clothing/mask/gas/nightlight/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/mask/gas/nightlight/click_alt(mob/user)
	adjust_visor(user)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/gas/nightlight/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to adjust it.")
