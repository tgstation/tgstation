/datum/element
	var/element_flags = NONE

/datum/element/proc/Attach(datum/target)
	if(type == /datum/element)
		return ELEMENT_INCOMPATIBLE
	if(element_flags & ELEMENT_DETACH)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/Detach)

/datum/element/proc/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/element/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	SSdcs.elements_by_type -= type
	return ..()

//DATUM PROCS

/datum/proc/AddElement(eletype, ...)
	var/datum/element/ele = SSdcs.GetElement(eletype)
	args[1] = src
	if(ele.Attach(arglist(args)) == ELEMENT_INCOMPATIBLE)
		CRASH("Incompatible [eletype] assigned to a [type]! args: [json_encode(args)]")

/datum/proc/RemoveElement(eletype)
	var/datum/element/ele = SSdcs.GetElement(eletype)
	ele.Detach(src)
