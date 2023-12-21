/datum/artifact_fault/ignite
	name = "Combust"
	trigger_chance = 9
	visible_message = "starts rapidly heating up while covering everything around it in something that seems to be oil."

/datum/artifact_fault/ignite/on_trigger(datum/component/artifact/component)
	for(var/mob/living/living in range(rand(3, 5), component.parent))
		living.adjust_fire_stacks(10)
		living.ignite_mob()
