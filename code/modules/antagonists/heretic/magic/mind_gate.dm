/datum/action/cooldown/spell/pointed/mind_gate
	name = "Mind Gate"
	desc = "Deals you 20 brain damage and the target suffers a hallucination, \
			is left confused for 10 seconds, and suffers oxygen loss and brain damage. \
			It also blinds, mutes and deafens your target, if their sanity is low enough, they will be knocked down as well."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mind_gate"

	sound = 'sound/effects/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "Op'n y'r m'd."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to open your mind..."
	antimagic_flags = MAGIC_RESISTANCE_MOON

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

	var/mob/living/living_owner = owner
	living_owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 20, 140)

	cast_on.adjust_confusion(10 SECONDS)
	cast_on.adjust_oxy_loss(30)
	cast_on.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "Mind gate, cast by [owner]")
	cast_on.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Caused by mindgate")
	cast_on.adjust_organ_loss(ORGAN_SLOT_BRAIN, 30)

	/// The duration of these effects are based on sanity, mainly for flavor but also to make it a weaker alpha strike
	var/maximum_duration = 15 SECONDS
	var/mind_gate_duration = ((SANITY_MAXIMUM - cast_on.mob_mood.sanity) / (SANITY_MAXIMUM - SANITY_INSANE)) * maximum_duration  + 1 SECONDS
	to_chat(cast_on, span_warning("Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!"))
	cast_on.adjust_temp_blindness(mind_gate_duration)
	cast_on.set_eye_blur_if_lower(mind_gate_duration + 1 SECONDS)

	cast_on.sound_damage(0, mind_gate_duration)

	cast_on.adjust_silence(mind_gate_duration)
	cast_on.add_mood_event("moon_smile", /datum/mood_event/moon_smile)

	// Only knocksdown if the target has a low enough sanity
	if(cast_on.mob_mood.sanity < 40)
		cast_on.AdjustKnockdown(2 SECONDS)
	//Lowers sanity
	cast_on.mob_mood.adjust_sanity(-20)

	//If our moon heretic has their level 3 passive, we channel the amulet effect
	var/datum/status_effect/heretic_passive/moon/our_passive = living_owner.has_status_effect(/datum/status_effect/heretic_passive/moon)
	if(our_passive?.amulet)
		our_passive.amulet.channel_amulet(owner, cast_on)

	return TRUE
