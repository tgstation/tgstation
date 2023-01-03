/// You can't use items on anyone other than yourself if you stand in a blacklisted room
/datum/component/shy_in_room
	can_transfer = TRUE
	/// Typecache of areas you can't stand
	var/list/blacklist
	/// Message shown when you are in a blacklisted room
	var/message = "%ROOM is too creepy to do that!"

/// _blacklist, and _message map to vars
/datum/component/shy_in_room/Initialize(blacklist, message)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.blacklist = blacklist
	if(message)
		src.message = message

/datum/component/shy_in_room/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(on_clickon))
	RegisterSignal(parent, COMSIG_LIVING_TRY_PULL, PROC_REF(on_try_pull))
	RegisterSignals(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK), PROC_REF(on_unarmed_attack))
	RegisterSignal(parent, COMSIG_TRY_STRIP, PROC_REF(on_try_strip))
	RegisterSignal(parent, COMSIG_TRY_ALT_ACTION, PROC_REF(on_try_alt_action))


/datum/component/shy_in_room/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_CLICKON,
		COMSIG_LIVING_TRY_PULL,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_HUMAN_EARLY_UNARMED_ATTACK,
		COMSIG_TRY_STRIP,
		COMSIG_TRY_ALT_ACTION,
	))

/datum/component/shy_in_room/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/shy_in_room/InheritComponent(datum/component/shy_in_room/friend, i_am_original, list/arguments)
	if(i_am_original)
		blacklist = friend.blacklist
		message = friend.message

/// Returns TRUE or FALSE if you are in a blacklisted area
/datum/component/shy_in_room/proc/is_shy(atom/target)
	var/mob/owner = parent
	if(!length(blacklist) || (target in owner.DirectAccess()))
		return

	var/area/room = get_area(owner)
	if(is_type_in_typecache(room, blacklist))
		to_chat(owner, span_warning("[replacetext(message, "%ROOM", room)]"))
		return TRUE

/datum/component/shy_in_room/proc/on_clickon(datum/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(modifiers[SHIFT_CLICK]) //let them examine their surroundings.
		return
	return is_shy(target) && COMSIG_MOB_CANCEL_CLICKON

/datum/component/shy_in_room/proc/on_try_pull(datum/source, atom/movable/target, force)
	SIGNAL_HANDLER
	return is_shy(target) && COMSIG_LIVING_CANCEL_PULL

/datum/component/shy_in_room/proc/on_unarmed_attack(datum/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	return is_shy(target) && COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/shy_in_room/proc/on_try_strip(datum/source, atom/target, obj/item/equipping)
	SIGNAL_HANDLER
	return is_shy(target) && COMPONENT_CANT_STRIP

/datum/component/shy_in_room/proc/on_try_alt_action(datum/source, atom/target)
	SIGNAL_HANDLER
	return is_shy(target) && COMPONENT_CANT_ALT_ACTION

