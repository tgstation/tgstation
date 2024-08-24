/datum/artifact_fault/explosion
	name = "Exploding Fault"
	trigger_chance = 3
	visible_message = "reaches a catastrophic overload, cracks forming at its surface!"

/datum/artifact_fault/explosion/on_trigger(datum/component/artifact/component)
	component.holder.Shake(duration = 5 SECONDS, shake_interval = 0.08 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(payload), component), 5 SECONDS)

/datum/artifact_fault/explosion/proc/payload(datum/component/artifact/component)
	explosion(component.holder, light_impact_range = 2, explosion_cause = src)
	qdel(component.holder)
