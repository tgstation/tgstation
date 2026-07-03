// Currently unused
/datum/action/cooldown/spell/touch/mad_touch
	name = "Касание безумия"
	desc = "Заклинание касания, лишающее врага рассудка и сбивающее его с ног."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE_MOON

/datum/action/cooldown/spell/touch/mad_touch/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/human_cast_on = cast_on
	if(!human_cast_on.mind || !human_cast_on.mob_mood || IS_HERETIC_OR_MONSTER(human_cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/mad_touch/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("Заклинание отскакивает от [victim]!"),
		span_danger("Заклинание отскакивает от вас!"),
	)

/datum/action/cooldown/spell/touch/mad_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/victim, mob/living/carbon/caster)
	to_chat(caster, span_warning("[capitalize(victim.declent_ru(NOMINATIVE))] подвергается проклятию!"))
	victim.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return TRUE
