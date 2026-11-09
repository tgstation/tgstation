
/datum/action/cooldown/spell/shapeshift/dragon
	name = "Dragon Form"
	desc = "Take on the shape a lesser ash drake."
	invocation = span_danger("<b>%CASTER</b> lets out a mighty roar!")
	invocation_self_message = span_danger("You let out a mighty roar!")
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	possible_shapes = list(/mob/living/simple_animal/hostile/megafauna/dragon/lesser)
