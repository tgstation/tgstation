/datum/artifact_fault/tesla_zap
	name = "Tesla Zap"
	trigger_chance = 12
	visible_message = "discharges a large amount of electricity."

/datum/artifact_fault/tesla_zap/on_trigger(datum/component/artifact/component)
	. = ..()
	tesla_zap(component.holder, rand(4, 7), ZAP_MOB_DAMAGE)
