/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	clothing_flags = CLOTHING_MOD_OVERSLOTTING
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_icon_state = "greyscale_gloves"
	lefthand_file = 'icons/mob/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/gloves_righthand.dmi'
	greyscale_colors = null
	greyscale_config_inhand_left = /datum/greyscale_config/gloves_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/gloves_inhand_right
	siemens_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	drop_sound = 'sound/items/handling/glove_drop.ogg'
	pickup_sound = 'sound/items/handling/glove_pick_up.ogg'
	attack_verb_continuous = list("challenges")
	attack_verb_simple = list("challenge")
	strip_delay = 20
	equip_delay_other = 40
	article = "a pair of"

	// Path variable. If defined, will produced the type through interaction with wirecutters.
	var/cut_type = null
	/// Used for handling bloody gloves leaving behind bloodstains on objects. Will be decremented whenever a bloodstain is left behind, and be incremented when the gloves become bloody.
	var/transfer_blood = 0

/obj/item/clothing/gloves/apply_fantasy_bonuses(bonus)
	. = ..()
	siemens_coefficient = modify_fantasy_variable("siemens_coefficient", siemens_coefficient, -bonus / 10)

/obj/item/clothing/gloves/remove_fantasy_bonuses(bonus)
	siemens_coefficient = reset_fantasy_variable("siemens_coefficient", siemens_coefficient)
	return ..()

/obj/item/clothing/gloves/wash(clean_types)
	. = ..()
	if((clean_types & CLEAN_TYPE_BLOOD) && transfer_blood > 0)
		transfer_blood = 0
		. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/obj/item/clothing/gloves/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("\the [src] are forcing [user]'s hands around [user.p_their()] neck! It looks like the gloves are possessed!"))
	return OXYLOSS

/obj/item/clothing/gloves/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedgloves")

/obj/item/clothing/gloves/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if (isinhands)
		return
	var/blood_overlay = get_blood_overlay("glove")
	if (blood_overlay)
		. += blood_overlay

/obj/item/clothing/gloves/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_gloves()

/obj/item/clothing/gloves/proc/can_cut_with(obj/item/tool)
	if(!cut_type)
		return FALSE
	if(icon_state != initial(icon_state))
		return FALSE // We don't want to cut dyed gloves.
	return TRUE

/obj/item/clothing/gloves/attackby(obj/item/tool, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return
	if(tool.tool_behaviour != TOOL_WIRECUTTER && !tool.get_sharpness())
		return
	if (!can_cut_with(tool))
		return
	balloon_alert(user, "cutting off fingertips...")

	if(!do_after(user, 3 SECONDS, target=src, extra_checks = CALLBACK(src, PROC_REF(can_cut_with), tool)))
		return
	balloon_alert(user, "cut fingertips off")
	qdel(src)
	user.put_in_hands(new cut_type)
	return TRUE
