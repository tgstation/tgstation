/// An abstract mob used for tracking which subsystem caused a runtime.
/mob/abstract/subsystem_tracker

// This needs to do its thing as soon as possible. We do not care about this thing being tracked as an atom,
// because they will exist *before* SSatoms.
/mob/abstract/subsystem_tracker/New(datum/controller/subsystem/subsystem)
	if(!istype(subsystem))
		CRASH("Tried to create subsystem tracker without reference to a valid subssyet")
	name = "[subsystem.name] ([subsystem.type])"
