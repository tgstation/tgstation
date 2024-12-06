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
