/datum/artifact_fault/ignite
	name = "Combustion Fault"
	trigger_chance = 9
	visible_message = "starts rapidly heating up while covering everything around it in something that seems to be oil."

/datum/artifact_fault/ignite/on_trigger(datum/component/artifact/component)
	var/center_turf = get_turf(component.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/living in range(rand(3, 5), center_turf))
		living.adjust_fire_stacks(10)
		living.ignite_mob()
