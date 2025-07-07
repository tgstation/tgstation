/datum/action/cooldown/spell/shapeshift/polar_bear
	name = "Polar Bear Form"
	desc = "Take on the shape of a polar bear."
	invocation = span_danger("<b>%CASTER</b> lets out a mighty roar!")
	invocation_self_message = span_danger("You let out a mighty roar!")
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	possible_shapes = list(/mob/living/simple_animal/hostile/asteroid/polarbear/lesser)
