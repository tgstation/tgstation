/// Will redirect touching the turf it is on with your hand to the attack_hand of the parent object.
/datum/component/redirect_attack_hand_from_turf
	VAR_PRIVATE
		/// If TRUE, will connect to the turf it *appears* to be on.
		adjust_for_pixel_shift

		/// If set, hovering over the turf you're on will show these screentips with an empty hand.
		/// Takes lmb_text and rmb_text.
		list/screentip_texts

		/// A custom callback to determine whether a user's clicks will be redirected or not (mob/user)
		datum/callback/interact_check

		turf/current_turf


/datum/component/redirect_attack_hand_from_turf/Initialize(
	adjust_for_pixel_shift = TRUE,
	list/screentip_texts = null,
	datum/callback/interact_check = null
)
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.adjust_for_pixel_shift = adjust_for_pixel_shift
	src.screentip_texts = screentip_texts
	src.interact_check = interact_check

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	connect_to_new_turf()

/datum/component/redirect_attack_hand_from_turf/Destroy(force)
	disconnect_from_old_turf()
	return ..()

/datum/component/redirect_attack_hand_from_turf/proc/find_turf()
	PRIVATE_PROC(TRUE)

	var/atom/movable/movable_parent = parent

	if (!isturf(movable_parent.loc))
		return null

	return adjust_for_pixel_shift ? get_turf_pixel(movable_parent) : movable_parent.loc

/datum/component/redirect_attack_hand_from_turf/proc/on_moved(atom/movable/source)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	disconnect_from_old_turf()
	connect_to_new_turf()

/datum/component/redirect_attack_hand_from_turf/proc/check_blacklisted_turf(turf/next_turf)
	PRIVATE_PROC(TRUE)
	return locate(/obj/structure/falsewall) in next_turf

/datum/component/redirect_attack_hand_from_turf/proc/connect_to_new_turf()
	PRIVATE_PROC(TRUE)

	var/turf/next_turf = find_turf()

	if (isnull(next_turf))
		return

	if (check_blacklisted_turf(next_turf))
		return

	current_turf = next_turf

	RegisterSignals(current_turf, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_ATTACK_ROBOT,
		COMSIG_ATOM_ATTACK_ROBOT_SECONDARY,
	), PROC_REF(on_attack_hand))

	if (!isnull(screentip_texts))
		current_turf.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
		RegisterSignal(current_turf, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/component/redirect_attack_hand_from_turf/proc/disconnect_from_old_turf()
	PRIVATE_PROC(TRUE)

	if (isnull(current_turf))
		return

	UnregisterSignal(current_turf, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_ATTACK_ROBOT,
		COMSIG_ATOM_ATTACK_ROBOT_SECONDARY,
	))

/datum/component/redirect_attack_hand_from_turf/proc/on_attack_hand(turf/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	var/atom/movable/movable_parent = parent
	if (!movable_parent.can_interact(user))
		return NONE
	
	if (!isnull(interact_check) && !interact_check.Invoke(user))
		return NONE

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, UnarmedAttack), parent, proximity_flag = TRUE, modifiers = modifiers)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/redirect_attack_hand_from_turf/proc/on_requesting_context_from_item(
	datum/source,
	list/context,
	obj/item/held_item,
	mob/user,
)
	PRIVATE_PROC(TRUE)
	SIGNAL_HANDLER

	if (!isliving(user))
		return NONE

	if (!isnull(held_item))
		return NONE
	
	if (!isnull(interact_check) && !interact_check.Invoke(user))
		return NONE

	if (!isnull(screentip_texts["lmb_text"]))
		context[SCREENTIP_CONTEXT_LMB] = screentip_texts["lmb_text"]

	if (!isnull(screentip_texts["rmb_text"]))
		context[SCREENTIP_CONTEXT_RMB] = screentip_texts["rmb_text"]

	return CONTEXTUAL_SCREENTIP_SET
