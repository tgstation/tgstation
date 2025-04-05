
/// Pony grounded moodlets.
/datum/mood_event/pony_grounded
	description = "Being in space is rough for me. I feel more secure standing on this grounding surface!"
	mood_change = 2

/datum/mood_event/mirror_neuron
	description = "Someone just got hurt, fuck! God, I can feel it!"
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/mirror_neuron/add_effects(mob/wounded_individual)
	description = "\The [wounded_individual.name] just got hurt, fuck! God, I can feel it!"
