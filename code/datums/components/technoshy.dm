/// You can't use machines when they've been touched within the last [unused_duration], unless it was by a mob in [whitelist]
/datum/component/technoshy
	can_transfer = TRUE
	/// How long in deciseconds the machine can be untouched for
	var/unused_duration = (2 MINUTES)
	/// Typecache of allowed last_users
	var/list/whitelist
	/// Message presented if the machine was used too recently
	var/message = "The %TARGET is way too fresh dude. Since we're like, <b>super</b> retro, we gotta wait for it to exit the mainstream."

/datum/component/technoshy/Initialize(unused_duration, message, whitelist)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(unused_duration)
		src.unused_duration = unused_duration
	if(message)
		src.message = message
	if(!whitelist)
		whitelist = typecacheof(parent.type)
	src.whitelist = whitelist

/datum/component/technoshy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TRY_USE_MACHINE, PROC_REF(on_try_use_machine))
	RegisterSignal(parent, COMSIG_TRY_WIRES_INTERACT, PROC_REF(on_try_wires_interact))

/datum/component/technoshy/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_TRY_USE_MACHINE, COMSIG_TRY_WIRES_INTERACT))

/datum/component/technoshy/PostTransfer(datum/new_parent)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/technoshy/InheritComponent(datum/component/technoshy/friend, i_am_original, list/arguments)
	if(i_am_original)
		whitelist = friend.whitelist
		message = friend.message

/datum/component/technoshy/proc/is_not_touched(datum/source, obj/machinery/machine)
	var/time_since = world.time - machine.last_used_time
	if(time_since < unused_duration && !isnull(machine.last_user_mobtype) && !is_type_in_typecache(machine.last_user_mobtype, whitelist))
		to_chat(source, span_warning("[replacetext(message, "%TARGET", machine)]"))
		return TRUE

/datum/component/technoshy/proc/on_try_use_machine(datum/source, obj/machinery/machine)
	SIGNAL_HANDLER
	if(is_not_touched(source, machine))
		return COMPONENT_CANT_USE_MACHINE_INTERACT | COMPONENT_CANT_USE_MACHINE_TOOLS

/datum/component/technoshy/proc/on_try_wires_interact(datum/source, atom/machine)
	SIGNAL_HANDLER
	if(!ismachinery(machine))
		return
	else if(is_not_touched(source, machine))
		return COMPONENT_CANT_INTERACT_WIRES

