/**
 * # BATFORM
 *
 * TG removed this, so we're re-adding it
 */
/datum/action/cooldown/spell/shapeshift/bat
	name = "Bat Form"
	desc = "Take on the shape of a space bat."
	invocation = "SQUEAAAAK!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	convert_damage = FALSE
	possible_shapes = list(/mob/living/basic/bat)
