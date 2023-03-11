/datum/action/cooldown/spell/touch/star_touch
	name = "Star Touch"
	desc = "Marks someone with a star mark or puts someone with a star mark to sleep for 6 seconds."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_touch"

	sound = 'sound/items/welder.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS
	invocation = "ST'R 'N'RG'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE

	hand_path = /obj/item/melee/touch_attack/star_touch
	/// Creates a field to stop people with a star mark.
	var/obj/effect/cosmic_field/cosmic_field

/datum/action/cooldown/spell/touch/star_touch/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/star_touch/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of you!"),
	)

/datum/action/cooldown/spell/touch/star_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/victim, mob/living/carbon/caster)
	if(victim.has_status_effect(/datum/status_effect/star_mark))
		victim.apply_effect(6 SECONDS, effecttype = EFFECT_UNCONSCIOUS)
		victim.remove_status_effect(/datum/status_effect/star_mark)
	else
		victim.apply_status_effect(/datum/status_effect/star_mark)
	cosmic_field = new(get_turf(caster))
	return TRUE

/obj/item/melee/touch_attack/star_touch
	name = "Star Touch"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes people with a star mark to sleep for 6 seconds, and causes people without a star mark to get one."
	icon_state = "star"
	inhand_icon_state = "star"

/obj/item/melee/touch_attack/star_touch/ignition_effect(atom/to_light, mob/user)
	. = span_notice("[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with cosmic energies. Fucking badass!")
	remove_hand_with_no_refund(user)
