/// You can't use machines unless they are in a whitelist
/datum/component/technointrovert
	can_transfer = TRUE
	/// Typecache of allowed machinery
	var/list/whitelist
	/// Message presented when
	var/message = "That %TARGET is strange! Let's avoid it."

/datum/component/technointrovert/Initialize(_whitelist, _message)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	whitelist = _whitelist
	if(_message)
		message = _message

/datum/component/technointrovert/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CAN_USE_MACHINE, .proc/is_in_friend_group)

/datum/component/technointrovert/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CAN_USE_MACHINE)

/datum/component/technointrovert/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/technointrovert/InheritComponent(datum/component/technointrovert/friend, i_am_original, list/arguments)
	if(i_am_original)
		whitelist = friend.whitelist
		message = friend.message

/datum/component/technointrovert/proc/is_in_friend_group(datum/source, obj/machinery/machine)
	if(!is_type_in_typecache(machine, whitelist))
		to_chat(source, "<span class='warning'>[replacetext(message, "%TARGET", machine)]</span>")
		return COMPONENT_CANT_USE_MACHINE

