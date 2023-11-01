/datum/artifact_fault/whisper
	name = "Generic Whisper"
	trigger_chance = 30
	var/list/whispers = list()

/datum/artifact_fault/whisper/on_trigger(datum/component/artifact/component)
	if(!length(whispers))
		return

	for(var/mob/living/living in range(rand(7, 10), component.parent))
		to_chat(living, span_hear("[pick(whispers)]"))
