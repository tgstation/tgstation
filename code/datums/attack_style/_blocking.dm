/datum/status_effect/blocking
	id = "blocking"
	status_type = STATUS_EFFECT_REFRESH

	var/obj/item/blocking_with

/datum/status_effect/blocking/on_creation(mob/living/new_owner, obj/item/new_blocker)
	. = ..()
	if(!.)
		return
	if(!isnull(blocking_with))
		set_blocking_item(new_blocker)

/datum/status_effect/blocking/on_apply()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	return TRUE

/datum/status_effect/blocking/Destroy()
	if(blocking_with)
		clear_blocking_item()
	return ..()

/datum/status_effect/blocking/proc/set_blocking_item(obj/item/new_blocker)
	blocking_with = new_blocker
	RegisterSignals(blocking_with, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED), PROC_REF(stop_blocking))
	RegisterSignal(blocking_with, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_slot))

/datum/status_effect/blocking/proc/clear_blocking_item()
	UnregisterSignal(blocking_with, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
	))

	blocking_with = null

/datum/status_effect/blocking/proc/check_item_slot(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER

	if(slot & ITEM_SLOT_HANDS)
		return

	qdel(src)

/datum/status_effect/blocking/proc/stop_blocking(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/blocking/proc/on_damaged(mob/living/source, damage)
	SIGNAL_HANDLER
