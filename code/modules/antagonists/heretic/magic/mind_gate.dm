/datum/action/cooldown/spell/pointed/mind_gate
	name = "Mind Gate"
	desc = "Deals you 20 brain damage and the target suffers a hallucination, \
			is left confused for 10 seconds, and suffers oxygen loss and brain damage."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mind_gate"

	sound = 'sound/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "Op' 'oY 'Mi'd"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to open your mind..."

/datum/action/cooldown/spell/pointed/mind_gate/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/mind_gate/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/mind_gate/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Your mind feels closed."))
		to_chat(owner, span_warning("Their mind doesn't swing open, but neither does yours."))
		return FALSE

	cast_on.adjust_confusion(10 SECONDS)
	cast_on.adjustOxyLoss(30)
	cast_on.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "Mind gate, cast by [owner]")
	cast_on.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Caused by mindgate")
	cast_on.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)

	var/mob/living/living_owner = owner
	living_owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 140)
