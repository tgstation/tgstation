/datum/artifact_fault/whisper
	name = "Wispering Fault"
	trigger_chance = 30
	var/list/whispers = list()

/datum/artifact_fault/whisper/on_trigger(datum/component/artifact/component)
	if(!length(whispers))
		return

	var/center_turf = get_turf(component.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/living in range(rand(7, 10), center_turf))
		to_chat(living, span_hear("[pick(whispers)]"))
