/datum/artifact_fault/bioscramble
	name = "Bioscrambling Fault"
	trigger_chance = 33
	visible_message = "corrupts nearby biological life!"

/datum/artifact_fault/bioscramble/on_trigger(datum/component/artifact/component)
	var/list/mobs = list()
	var/mob/living/carbon/poor_soul

	var/center_turf = get_turf(component.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/carbon/mob in range(rand(3, 4), center_turf))
		for(var/i in 1 to 3)
			mob.bioscramble(component.holder)
