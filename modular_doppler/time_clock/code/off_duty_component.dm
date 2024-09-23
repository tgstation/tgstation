/datum/component/off_duty_timer
	///Is the ID that the component is attached to is able to clock back in?
	var/on_cooldown = FALSE
	///The stored ID trim of the user of the id
	var/datum/id_trim/job/stored_trim
	///Is the owner of card locked out of clocking back in until their ID is unlocked by the HoP?
	var/hop_locked = FALSE
	///What was the name of the job the person was working when they clocked out?
	var/stored_assignment = ""

/datum/component/off_duty_timer/Initialize(cooldown_timer = 0)
	. = ..()

	var/obj/item/card/id/attached_id = parent
	if(!attached_id)
		return COMPONENT_INCOMPATIBLE

	stored_trim = attached_id.trim
	stored_assignment = attached_id.assignment


	if(cooldown_timer)
		on_cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(remove_cooldown)), cooldown_timer)

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attempt_unlock))

/datum/component/off_duty_timer/Destroy(force)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	return ..()

///Sets the on_cooldown variable to false, making it so that the ID can clock back in.
/datum/component/off_duty_timer/proc/remove_cooldown()
	on_cooldown = FALSE

///Attempts an unlock if attacked by another ID. If the ID has HoP access, it will unlock and return TRUE
/datum/component/off_duty_timer/proc/attempt_unlock(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER
	if(!hop_locked)
		return FALSE

	var/obj/item/card/id/advanced/hop_id = attacking_item
	if(!hop_id)
		return FALSE

	if(!(ACCESS_HOP in hop_id.access))
		to_chat(user, span_warning("You lack the access to unlock [parent]"))
		return FALSE

	hop_locked = FALSE
	to_chat(user, span_notice("[parent] has been unlocked, the owner is now able to clock in."))
	log_admin("[parent] has been unlocked by [user] and is now able to be clocked back in.")

	return TRUE
