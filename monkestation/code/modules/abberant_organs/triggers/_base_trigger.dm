/datum/organ_trigger
	var/name = "Generic Trigger"
	var/desc = "Generic trigger description."

	var/datum/weakref/host
	var/obj/item/organ/parent

	var/complexity_cost = 0
	var/trigger_cost = 0
	var/trigger_flags = NONE

/datum/organ_trigger/New(atom/parent)
	. = ..()
	src.parent = parent
	RegisterSignal(parent, COMSIG_ABBERANT_HOST_SET, PROC_REF(set_host))
	RegisterSignal(parent, COMSIG_ABBERANT_HOST_CLEARED, PROC_REF(remove_host))

/datum/organ_trigger/proc/trigger()
	SIGNAL_HANDLER

	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(parent, COMSIG_ABBERANT_TRIGGER, trigger_cost)

/datum/organ_trigger/proc/set_host(atom/parent, atom/movable/incoming)
	SIGNAL_HANDLER

	SHOULD_CALL_PARENT(TRUE)
	host = WEAKREF(incoming)

/datum/organ_trigger/proc/remove_host()
	SIGNAL_HANDLER

	SHOULD_CALL_PARENT(TRUE)
	host = null
