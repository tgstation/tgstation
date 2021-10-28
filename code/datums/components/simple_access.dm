/datum/component/simple_access
	var/list/access

/datum/component/simple_access/Initialize(list/new_access)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	access = new_access
	RegisterSignal(parent, COMSIG_MOB_TRIED_ACCESS, .proc/on_tried_access)

/datum/component/simple_access/proc/on_tried_access(datum/source)
	SIGNAL_HANDLER
	if(!isobj(source))
		return SOURCE_INCOMPATIBLE
	var/obj/locked_thing = source
	if(locked_thing.check_access_list(access))
		return ACCESS_ALLOWED
	else
		return ACCESS_DISALLOWED
