/datum/artifact_fault/speech
	name = "Generic Speech"
	trigger_chance = 30
	var/list/speech = list()

/datum/artifact_fault/speech/on_trigger(datum/component/artifact/component)
	if(!length(speech))
		return

	for(var/mob/living/living in range(rand(7, 10), component.parent))
		if(prob(50))
			living.say("; [pick(speech)]")
		else
			living.say("[pick(speech)]")
