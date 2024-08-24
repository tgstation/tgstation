/datum/artifact_fault/speech
	name = "Talkative Fault"
	trigger_chance = 30
	var/list/speech = list("Hello there.","I see you.","I know what you've done.")

/datum/artifact_fault/speech/on_trigger(datum/component/artifact/component)
	if(!length(speech))
		return

	var/center_turf = get_turf(component.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/living in range(rand(7, 10), center_turf))
		if(prob(50))
			living.say("; [pick(speech)]")
		else
			living.say("[pick(speech)]")
