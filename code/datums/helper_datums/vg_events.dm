/**
 * /vg/ Events System
 *
 * Intended to replace the hook system.
 * Eventually. :V
 */

// Buggy bullshit requires shitty workarounds
#define INVOKE_EVENT(event,args) if(istype(event)) event.Invoke(args)

/**
 * Event dispatcher
 */
/event
	var/list/handlers=list() // List of [\ref, Function]

/event/proc/Add(var/objectRef,var/procName)
	var/key="\ref[objectRef]:[procName]"
	handlers[key]=list("o"=objectRef,"p"=procName)
	return key

/event/proc/Remove(var/key)
	handlers.Remove(handlers[key])

/event/proc/Invoke(var/list/args)
	if(handlers.len==0)
		return
	for(var/key in handlers)
		var/list/handler=handlers[key]
		if(!handler)
			continue

		var/objRef = handler["o"]
		var/procName = handler["p"]

		if(objRef == null)
			handlers.Remove(handler)
			continue
		call(objRef,procName)(args)