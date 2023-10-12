/datum/action/cooldown/spell/pointed/mind_gate
	name = "Mind Gate"
	desc = "Opens your mind, and theirs."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 10 SECONDS

	invocation = "Op' 'oY 'Mi'd"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to open your mind..."

/datum/action/cooldown/spell/pointed/mind_gate/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/mind_gate/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/mind_gate/cast(mob/living/carbon/human/cast_on, mob/living/carbon/human/owner)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Your mind feels closed."))
		to_chat(owner, span_warning("Their mind doesn't swing open, but neither does yours."))
		return FALSE

	cast_on.adjust_confusion(10 SECONDS)
	cast_on.cause_hallucination(\
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"Mind gate, cast by [owner]", \
		)
	cast_on.cause_hallucination( \
			/datum/hallucination/delusion/custom, \
			"Mind gate, cast by [owner]", \
			duration = 20 SECONDS, \
			affects_us = TRUE, \
			affects_others = TRUE, \
			skip_nearby = FALSE, \
			play_wabbajack = FALSE, \
			custom_icon_file = owner.icon, \
			custom_icon_state = owner.icon_state, \
		)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 140)
