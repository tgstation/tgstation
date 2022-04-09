// Currently unused.
/datum/action/cooldown/spell/touch/mad_touch
	name = "Touch of Madness"
	desc = "A touch spell that drains your enemy's sanity."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

/datum/action/cooldown/spell/touch/mad_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(!ishuman(victim))
		return FALSE

	var/mob/living/carbon/human/human_victim = victim
	if(!human_victim.mind || IS_HERETIC(human_victim))
		return FALSE

	if(human_victim.can_block_magic(antimagic_flags))
		victim.visible_message(
			span_danger("The spell bounces off of [victim]!"),
			span_danger("The spell bounces off of you!"),
		)
		return FALSE

	to_chat(caster, span_warning("[human_victim.name] has been cursed!"))
	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return TRUE
