/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	inhand_icon_state = "m_mask"
	body_parts_covered = 0
	clothing_flags = MASKINTERNALS
	visor_flags = MASKINTERNALS
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/mask_breath
	actions_types = list(/datum/action/item_action/adjust)
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING

/datum/armor/mask_breath
	bio = 50

/obj/item/clothing/mask/breath/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is wrapping \the [src]'s tube around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/mask/breath/click_alt(mob/user)
	adjust_visor(user)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/breath/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to adjust it.")

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	inhand_icon_state = "m_mask"
	armor_type = /datum/armor/breath_medical
	equip_delay_other = 1 SECONDS

/datum/armor/breath_medical
	bio = 90

/obj/item/clothing/mask/breath/muzzle
	name = "surgery mask"
	desc = "To silence those pesky patients before putting them under."
	icon_state = "breathmuzzle"
	inhand_icon_state = "breathmuzzle"
	lefthand_file = 'icons/mob/inhands/clothing/masks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/masks_righthand.dmi'
	body_parts_covered = NONE
	flags_cover = NONE
	armor_type = /datum/armor/breath_muzzle
	equip_delay_other = 2.5 SECONDS // my sprite has 4 straps, a-la a head harness. takes a while to equip, longer than a muzzle

/obj/item/clothing/mask/breath/muzzle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/muffles_speech)

/obj/item/clothing/mask/breath/muzzle/attack_paw(mob/user, list/modifiers)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(src == carbon_user.wear_mask)
			to_chat(user, span_warning("You need help taking this off!"))
			return
	return ..()

/obj/item/clothing/mask/breath/muzzle/examine_tags(mob/user)
	. = ..()
	.["surgical"] = "Does not block surgery on covered bodyparts."

/datum/armor/breath_muzzle
	bio = 100
