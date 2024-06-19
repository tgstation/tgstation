/*
Slimecrossing Armor
	Armor added by the slimecrossing system.
	Collected here for clarity.
*/

//Rebreather mask - Chilling Blue
/obj/item/clothing/mask/nobreath
	name = "rebreather mask"
	desc = "A transparent mask, resembling a conventional breath mask, but made of bluish slime. Seems to lack any air supply tube, though."
	icon_state = "slime"
	inhand_icon_state = "b_mask"
	body_parts_covered = NONE
	w_class = WEIGHT_CLASS_SMALL
	clothing_traits = list(TRAIT_NOBREATH)
	armor_type = /datum/armor/mask_nobreath
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE
	interaction_flags_mouse_drop = NEED_HANDS

/datum/armor/mask_nobreath
	bio = 50

/obj/item/clothing/mask/nobreath/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_MASK)
		user.failed_last_breath = FALSE
		user.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		user.apply_status_effect(/datum/status_effect/rebreathing)

/obj/item/clothing/mask/nobreath/dropped(mob/living/carbon/human/user)
	..()
	user.remove_status_effect(/datum/status_effect/rebreathing)

/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "prismglasses"
	actions_types = list(/datum/action/item_action/change_prism_colour, /datum/action/item_action/place_light_prism)
	var/glasses_color = COLOR_WHITE

/obj/item/clothing/glasses/prism_glasses/item_action_slot_check(slot)
	if(slot & ITEM_SLOT_EYES)
		return TRUE

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	max_integrity = 10

/obj/structure/light_prism/Initialize(mapload, newcolor)
	. = ..()
	if(newcolor)
		color = newcolor
		set_light_color(newcolor)
	set_light(5)

/obj/structure/light_prism/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_notice("You dispel [src]."))
	qdel(src)

/datum/action/item_action/change_prism_colour
	name = "Adjust Prismatic Lens"
	button_icon = 'icons/obj/science/slimecrossing.dmi'
	button_icon_state = "prismcolor"

/datum/action/item_action/change_prism_colour/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = input(owner, "Choose the lens color:", "Color change",glasses.glasses_color) as color|null
	if(!new_color)
		return
	glasses.glasses_color = new_color

/datum/action/item_action/place_light_prism
	name = "Fabricate Light Prism"
	button_icon = 'icons/obj/science/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/place_light_prism/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, span_warning("There isn't enough ambient energy to fabricate another light prism here."))
		return
	if(istype(glasses))
		if(!glasses.glasses_color)
			to_chat(owner, span_warning("The lens is oddly opaque..."))
			return
		to_chat(owner, span_notice("You channel nearby light into a glowing, ethereal prism."))
		new /obj/structure/light_prism(get_turf(owner), glasses.glasses_color)

/obj/item/clothing/head/peaceflower
	name = "heroine bud"
	desc = "An extremely addictive flower, full of peace magic."
	icon = 'icons/obj/science/slimecrossing.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "peaceflower"
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_HEAD
	clothing_traits = list(TRAIT_PACIFISM)
	body_parts_covered = NONE
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/clothing/head/peaceflower/proc/at_peace_check(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(src == carbon_user.head)
			to_chat(user, span_warning("You feel at peace. <b style='color:pink'>Why would you want anything else?</b>"))
			return TRUE
	return FALSE

/obj/item/clothing/head/peaceflower/attack_hand(mob/user, list/modifiers)
	if(at_peace_check(user))
		return
	return ..()

/obj/item/clothing/head/peaceflower/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(at_peace_check(user))
		return
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "adamantine armor"
	desc = "A full suit of adamantine plate armor. Impressively resistant to damage, but weighs about as much as you do."
	icon_state = "adamsuit"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = null
	flags_inv = NONE
	item_flags = IMMUTABLE_SLOW
	slowdown = 4
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/heavy/adamantine/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) && prob(hit_reflect_chance))
		return TRUE
	else
		return FALSE
