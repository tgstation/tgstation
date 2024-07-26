/datum/action/cooldown/spell/shapeshift/shed_human_form
	name = "Shed form"
	desc = "Shed your fragile form, become one with the arms, become one with the emperor. \
		Causes heavy amounts of brain damage and sanity loss to nearby mortals."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_ascend"

	school = SCHOOL_FORBIDDEN

	invocation = "REALITAS EXSERPAT!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	convert_damage = FALSE // Functionally meaningless on Armsy, we track how many segments it had instead
	possible_shapes = list(/mob/living/basic/heretic_summon/armsy)

	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage / sanity damage to.
	var/scare_radius = 9

/datum/action/cooldown/spell/shapeshift/shed_human_form/do_shapeshift(mob/living/caster)
	// When we transform into the worm, everyone nearby gets freaked out
	for(var/mob/living/carbon/human/nearby_human in view(scare_radius, caster))
		if(IS_HERETIC_OR_MONSTER(nearby_human) || nearby_human == caster)
			continue

		// 25% chance to cause a trauma
		if(prob(25))
			var/datum/brain_trauma/trauma = pick(subtypesof(BRAIN_TRAUMA_MILD) + subtypesof(BRAIN_TRAUMA_SEVERE))
			nearby_human.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)
		// And a negative moodlet
		nearby_human.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)

	return ..()

/datum/action/cooldown/spell/shapeshift/shed_human_form/do_unshapeshift(mob/living/basic/heretic_summon/armsy/caster)
	if(istype(caster))
		segment_length = caster.get_length() - 1 // Don't count the head

	return ..()

/datum/action/cooldown/spell/shapeshift/shed_human_form/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc, TRUE, segment_length)
