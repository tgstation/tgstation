/obj/item/dyespray
	name = "hair dye spray"
	desc = "A spray to dye your hair any gradients you'd like."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cosmetic.dmi'
	icon_state = "dyespray"

/obj/item/dyespray/attack_self(mob/user)
	dye(user, user)

/obj/item/dyespray/pre_attack(atom/target, mob/living/user, params)
	dye(target, user)
	return ..()

/**
 * Applies a gradient and a gradient color to a mob.
 *
 * Arguments:
 * * target - The mob who we will apply the gradient and gradient color to.
 */

/obj/item/dyespray/proc/dye(mob/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_target = target
	var/list/dyables = list("Hair", "Facial Hair")
	for(var/obj/item/organ/organ as anything in human_target.organs)
		if(!istype(organ.bodypart_overlay, /datum/bodypart_overlay/mutant))
			continue
		var/datum/bodypart_overlay/mutant/overlay = organ.bodypart_overlay
		if(overlay.dyable)
			dyables += list("External Bodyparts/Organs")
			break
	var/obj/item/bodypart/head/head =  human_target.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !(head.head_flags & HEAD_HAIR) || HAS_TRAIT(human_target, TRAIT_BALD))
		dyables -= "Hair"
	if(!head || !(head.head_flags & HEAD_FACIAL_HAIR) || HAS_TRAIT(human_target, TRAIT_SHAVED))
		dyables -= "Facial Hair"
	if(!length(dyables))
		if(target != user)
			to_chat(user, span_warning("[human_target] doesn't have anything that can be dyed."))
		else
			to_chat(user, span_warning("You have nothing to dye."))
		return
	var/what_to_dye = tgui_alert(user, "What do you want to dye?", "Character Preference", dyables)
	if(!what_to_dye || !user.can_perform_action(src, NEED_DEXTERITY))
		return

	if(what_to_dye == "External Bodyparts/Organs")
		dye_organ()
		return

	var/list/choices = what_to_dye == "Hair" ? SSaccessories.hair_gradients_list : SSaccessories.facial_hair_gradients_list
	var/new_grad_style = tgui_input_list(user, "Choose a color pattern", "Character Preference", choices)
	if(isnull(new_grad_style))
		return
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return

	var/new_grad_color = input(user, "Choose a secondary hair color:", "Character Preference",human_target.grad_color) as color|null
	if(!new_grad_color || !user.can_perform_action(src, NEED_DEXTERITY) || !user.CanReach(target))
		return

	to_chat(user, span_notice("You start applying the hair dye..."))
	if(!do_after(user, 3 SECONDS, target))
		return
	if(what_to_dye == "Hair")
		human_target.set_hair_gradient_style(new_grad_style, update = FALSE)
		human_target.set_hair_gradient_color(new_grad_color, update = TRUE)
	else
		human_target.set_facial_hair_gradient_style(new_grad_style, update = FALSE)
		human_target.set_facial_hair_gradient_color(new_grad_color, update = TRUE)
	playsound(src, 'sound/effects/spray.ogg', 10, vary = TRUE)

/obj/item/dyespray/proc/dye_organ(mob/living/carbon/human/target, mob/user)
	var/list/dyables = list()
	for(var/obj/item/organ/organ as anything in target.organs)
		if(!istype(organ.bodypart_overlay, /datum/bodypart_overlay/mutant))
			continue
		var/datum/bodypart_overlay/mutant/overlay = organ.bodypart_overlay
		if(overlay.dyable)
			dyables[organ.name] = organ
	if(!length(dyables))
		return
	var/what_to_dye = tgui_alert(user, "What do you want to dye?", "Character Preference", dyables)
	if(!what_to_dye || !user.can_perform_action(src, NEED_DEXTERITY))
		return

	var/obj/item/organ/selected = dyables[what_to_dye]
	if(QDELETED(selected) || !(selected in target.organs))
		return

	var/datum/bodypart_overlay/mutant/overlay = selected.bodypart_overlay
	if(overlay.dye_color)
		var/remove_dye = tgui_alert(user, "Do you want to un-dye [selected]?", "Character Preference", list("Yes", "No"))
		if(isnull(remove_dye) || !user.can_perform_action(src, NEED_DEXTERITY))
			return
		if(QDELETED(selected) || !(selected in target.organs))
			return
		if(remove_dye == "Yes")
			overlay.dye_color = null
			target.update_body_parts()
			return

	var/default_color = overlay.dye_color || overlay.draw_color
	var/new_color = input(user, "Choose a color for [selected]:", "Character Preference", default_color) as color|null
	if(isnull(new_color) || new_color == default_color || !user.can_perform_action(src, NEED_DEXTERITY))
		return
	if(QDELETED(selected) || !(selected in target.organs))
		return
	if(!do_after(user, 4.5 SECONDS, target))
		return
	if(QDELETED(selected) || !(selected in target.organs))
		return
	overlay.dye_color = new_color
	target.update_body_parts()
