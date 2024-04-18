/// AIs will attack this as a potential target if they see it
/datum/element/hostile_machine
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/hostile_machine/Attach(datum/target)
	. = ..()

	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

#ifdef UNIT_TESTS
	if(!GLOB.target_interested_atoms[target.type])
		stack_trace("Tried to make a hostile machine without updating ai targeting to include it, they must be synced")
#endif
	GLOB.hostile_machines += target

/datum/element/hostile_machine/Detach(datum/source)
	GLOB.hostile_machines -= source
	return ..()
