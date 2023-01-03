
# Template file for your new element

See _element.dm for detailed explanations

```dm
/datum/element/myelement
	element_flags = ELEMENT_BESPOKE | ELEMENT_COMPLEX_DETACH | ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_NOTAREALFLAG    // code/__DEFINES/dcs/flags.dm
	//argument_hash_start_idx = 2                                                                                  // Use with ELEMENT_BESPOKE
	var/list/myvar = list()

/datum/element/myelement/Attach(datum/target)
	if(!ismovable(target))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, myproc)
	to_chat(target, "Hey, you're in your element.")

/datum/element/myelement/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	to_chat(source, "You feel way out of your element.")

/datum/element/myelement/proc/myproc(datum/source)
	SIGNAL_HANDLER
	playsound(source, 'sound/effects/gong.ogg', 50, TRUE)
```
