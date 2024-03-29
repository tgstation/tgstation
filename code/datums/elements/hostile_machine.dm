/// AIs will attack this as a potential target if they see it
/datum/element/hostile_machine
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/hostile_machine/Attach(datum/target)
	. = ..()

	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	GLOB.hostile_machines += target

/datum/element/hostile_machine/Detach(datum/source)
	GLOB.hostile_machines -= source
	return ..()
