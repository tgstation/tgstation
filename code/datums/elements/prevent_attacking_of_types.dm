/// This hostile will not be able to attack a given typecache, and will receive
/// a balloon alert when it tries to.
/datum/element/prevent_attacking_of_types
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// The typecache of things this hostile can't attack
	var/list/typecache

	/// The message to send to the hostile mob when they try to attack something they can't
	var/alert_message

/datum/element/prevent_attacking_of_types/Attach(datum/target, list/typecache, alert_message)
	. = ..()

	if (!isanimal_or_basicmob(target))
		return ELEMENT_INCOMPATIBLE

	src.alert_message = alert_message
	src.typecache = typecache

	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attacking_target))

/datum/element/prevent_attacking_of_types/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	return ..()

/datum/element/prevent_attacking_of_types/proc/on_pre_attacking_target(mob/source, atom/target)
	SIGNAL_HANDLER

	if (!typecache[target.type])
		return

	target.balloon_alert(source, alert_message)

	return COMPONENT_HOSTILE_NO_ATTACK


