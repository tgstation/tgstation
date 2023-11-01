/datum/artifact_fault/explosion
	name = "Explode"
	trigger_chance = 3
	visible_message = "just explodes!"


/datum/artifact_fault/explosion/on_trigger(datum/component/artifact/component)
	explosion(component.holder, light_impact_range = 2, explosion_cause = src)
	qdel(component.holder)
