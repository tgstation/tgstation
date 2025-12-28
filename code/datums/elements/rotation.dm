/datum/element/simple_rotation
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Rotation flags for special behavior
	var/rotation_flags

/**
 * Adds the ability to rotate an object by Alt-click or using Right-click verbs.
 *
 * args:
 * * rotation_flags (optional) Bitflags that determine behavior for rotation (defined at the top of this file)
 * * post_rotation (optional) Callback proc that is used after the object is rotated (sound effects, balloon alerts, etc.)
 **/
/datum/element/simple_rotation/Attach(datum/target, rotation_flags = NONE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/movable/source = target
	source.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	src.rotation_flags = rotation_flags

	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(rotate_left))
	RegisterSignal(target, COMSIG_CLICK_ALT_SECONDARY, PROC_REF(rotate_right))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(ExamineMessage))
	RegisterSignal(target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/element/simple_rotation/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_CLICK_ALT,
		COMSIG_CLICK_ALT_SECONDARY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
	))
	return ..()

/datum/element/simple_rotation/proc/ExamineMessage(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		examine_list += span_notice("This requires a wrench to be rotated.")

/datum/element/simple_rotation/proc/rotate_right(datum/source, mob/user)
	SIGNAL_HANDLER
	rotate(user, source, ROTATION_CLOCKWISE)
	return CLICK_ACTION_SUCCESS

/datum/element/simple_rotation/proc/rotate_left(datum/source, mob/user)
	SIGNAL_HANDLER
	rotate(user, source, ROTATION_COUNTERCLOCKWISE)
	return CLICK_ACTION_SUCCESS

/datum/element/simple_rotation/proc/rotate(mob/user, obj/object_to_rotate, degrees)
	if(QDELETED(user))
		CRASH("[src] is being rotated [user ? "with a qdeleting" : "without a"] user")
	if(!istype(user))
		CRASH("[src] is being rotated without a user of the wrong type: [user.type]")
	if(!isnum(degrees))
		CRASH("[src] is being rotated without providing the amount of degrees needed")

	if(!can_be_rotated(user, object_to_rotate, degrees) || !can_user_rotate(user, object_to_rotate, degrees))
		return

	object_to_rotate.setDir(turn(object_to_rotate.dir, degrees))
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		playsound(object_to_rotate, 'sound/items/tools/ratchet.ogg', 50, TRUE)

	object_to_rotate.post_rotation(user, degrees)

/datum/element/simple_rotation/proc/can_user_rotate(mob/user, obj/object_to_rotate, degrees)
	if(isliving(user) && user.can_perform_action(object_to_rotate, NEED_DEXTERITY))
		return TRUE
	if((rotation_flags & ROTATION_GHOSTS_ALLOWED) && isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE

/datum/element/simple_rotation/proc/can_be_rotated(mob/user, obj/object_to_rotate, degrees, silent = FALSE)
	if(!object_to_rotate.Adjacent(user))
		silent = TRUE

	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		if(!isliving(user))
			return FALSE
		var/obj/item/tool = user.get_active_held_item()
		if(!tool || tool.tool_behaviour != TOOL_WRENCH)
			if(!silent)
				object_to_rotate.balloon_alert(user, "need a wrench!")
			return FALSE

	if(!(rotation_flags & ROTATION_IGNORE_ANCHORED) && object_to_rotate.anchored)
		if(istype(object_to_rotate, /obj/structure/window) && !silent)
			object_to_rotate.balloon_alert(user, "need to unscrew!")
		else if(!silent)
			object_to_rotate.balloon_alert(user, "need to unwrench!")
		return FALSE

	if(rotation_flags & ROTATION_NEEDS_ROOM)
		var/target_dir = turn(object_to_rotate.dir, degrees)
		var/obj/structure/window/window_to_rotate = object_to_rotate
		var/fulltile = istype(window_to_rotate) ? window_to_rotate.fulltile : FALSE
		if(!valid_build_direction(object_to_rotate.loc, target_dir, is_fulltile = fulltile))
			if(!silent)
				object_to_rotate.balloon_alert(user, "can't rotate in that direction!")
			return FALSE

	if(rotation_flags & ROTATION_NEEDS_UNBLOCKED)
		var/turf/rotate_turf = get_turf(object_to_rotate)
		if(rotate_turf.is_blocked_turf(source_atom = object_to_rotate))
			if(!silent)
				object_to_rotate.balloon_alert(user, "rotation is blocked!")
			return FALSE

	return TRUE

// maybe we don't need the item context proc but instead the hand one? since we don't need to check held_item
/datum/element/simple_rotation/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	var/rotation_screentip = FALSE

	if(can_be_rotated(user, source, ROTATION_CLOCKWISE, silent=TRUE))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Rotate left"
		rotation_screentip = TRUE
	if(can_be_rotated(user, source, ROTATION_COUNTERCLOCKWISE, silent=TRUE))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Rotate right"
		rotation_screentip = TRUE

	if(rotation_screentip)
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/// Calld on the atom after it has been successfully rotated
/atom/movable/proc/post_rotation(mob/user, degrees)
	return
