/// You can't use machines unless they are in a whitelist
/datum/component/technointrovert
	can_transfer = TRUE
	/// Typecache of allowed machinery
	var/list/whitelist
	/// Message presented when
	var/message = "That %TARGET is strange! Let's avoid it."

/datum/component/technointrovert/Initialize(whitelist, message)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.whitelist = whitelist
	if(message)
		src.message = message

/datum/component/technointrovert/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TRY_USE_MACHINE, .proc/on_try_use_machine)
	RegisterSignal(parent, COMSIG_TRY_WIRES_INTERACT, .proc/on_try_wires_interact)

/datum/component/technointrovert/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_TRY_USE_MACHINE, COMSIG_TRY_WIRES_INTERACT))

/datum/component/technointrovert/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/technointrovert/InheritComponent(datum/component/technointrovert/friend, i_am_original, list/arguments)
	if(i_am_original)
		whitelist = friend.whitelist
		message = friend.message

/datum/component/technointrovert/proc/is_in_whitelist(datum/source, obj/machinery/machine)
	if(!is_type_in_typecache(machine, whitelist))
		to_chat(source, span_warning("[replacetext(message, "%TARGET", machine)]"))
		return FALSE
	return TRUE

/datum/component/technointrovert/proc/on_try_use_machine(datum/source, obj/machinery/machine)
	SIGNAL_HANDLER
	if(!is_in_whitelist(source, machine))
		return COMPONENT_CANT_USE_MACHINE_INTERACT | COMPONENT_CANT_USE_MACHINE_TOOLS

/datum/component/technointrovert/proc/on_try_wires_interact(datum/source, atom/machine)
	SIGNAL_HANDLER
	if(ismachinery(machine) && !is_in_whitelist(source, machine))
		return COMPONENT_CANT_INTERACT_WIRES
