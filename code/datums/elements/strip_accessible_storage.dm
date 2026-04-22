/datum/element/strip_accessible_storage

/datum/element/strip_accessible_storage/Attach(obj/item/target)
	. = ..()
	if(!isitem(target) || isnull(target.atom_storage))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_GET_STRIPPABLE_ALT_ACTIONS, PROC_REF(get_strippable_alternate_actions))
	RegisterSignal(target, COMSIG_ITEM_STRIPPABLE_ALT_ACTION, PROC_REF(do_strippable_action))
	ADD_TRAIT(target, TRAIT_SKIP_BASIC_REACH_CHECK, ELEMENT_TRAIT(type))

/datum/element/strip_accessible_storage/Detach(obj/item/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_GET_STRIPPABLE_ALT_ACTIONS)
	UnregisterSignal(source, COMSIG_ITEM_STRIPPABLE_ALT_ACTION)
	REMOVE_TRAIT(source, TRAIT_SKIP_BASIC_REACH_CHECK, ELEMENT_TRAIT(type))
	source.atom_storage.close_all_non_wearers()

/datum/element/strip_accessible_storage/proc/get_strippable_alternate_actions(obj/item/source, atom/owner, mob/user, list/alt_actions)
	SIGNAL_HANDLER
	if(!can_access_storage(source, owner, user))
		return
	alt_actions += "access_storage"

/datum/element/strip_accessible_storage/proc/do_strippable_action(obj/item/source, atom/owner, mob/living/user, action_key)
	SIGNAL_HANDLER
	if(action_key != "access_storage")
		return NONE
	if(!isliving(user))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(attempt_access), source, owner, user)
	return COMPONENT_ALT_ACTION_DONE

/datum/element/strip_accessible_storage/proc/can_access_storage(obj/item/source, atom/owner, mob/living/user)
	if(QDELETED(source) || QDELETED(owner) || QDELETED(user))
		return FALSE
	if(source.atom_storage.locked)
		return FALSE
	if(!(user.mobility_flags & MOBILITY_STORAGE))
		return FALSE
	if(source.atom_storage.quickdraw)
		return FALSE
	return TRUE

/datum/element/strip_accessible_storage/proc/attempt_access(obj/item/source, atom/owner, mob/living/user)
	owner.visible_message(
		span_warning("[user] tries to open [owner]'s [source]..."),
		span_userdanger("[user] is trying to open your [source]!"),
		blind_message = span_hear("You hear rustling."),
		ignored_mobs = user,
	)
	if(!do_after(user, source.strip_delay + 1 SECONDS, owner, extra_checks = CALLBACK(src, PROC_REF(can_access_storage), source, owner, user) ))
		return
	source.atom_storage.open_storage(user)
