/datum/component/simple_rotation
	/// Additional stuff to do after rotation
	var/datum/callback/post_rotation
	/// Rotation flags for special behavior
	var/rotation_flags = NONE

/**
 * Adds the ability to rotate an object by Alt-click or using Right-click verbs.
 *
 * args:
 * * rotation_flags (optional) Bitflags that determine behavior for rotation (defined at the top of this file)
 * * post_rotation (optional) Callback proc that is used after the object is rotated (sound effects, balloon alerts, etc.)
 **/
/datum/component/simple_rotation/Initialize(rotation_flags = NONE, post_rotation)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/source = parent
	source.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	src.rotation_flags = rotation_flags
	src.post_rotation = post_rotation || CALLBACK(src, PROC_REF(default_post_rotation))

/datum/component/simple_rotation/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(rotate_left))
	RegisterSignal(parent, COMSIG_CLICK_ALT_SECONDARY, PROC_REF(rotate_right))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(ExamineMessage))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
	return ..()

/datum/component/simple_rotation/PostTransfer(datum/new_parent)
	//Because of the callbacks which we don't track cleanly we can't transfer this
	//item cleanly, better to let the new of the new item create a new rotation datum
	//instead (there's no real state worth transferring)
	return COMPONENT_NOTRANSFER

/datum/component/simple_rotation/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CLICK_ALT,
		COMSIG_CLICK_ALT_SECONDARY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
	))
	return ..()

/datum/component/simple_rotation/Destroy()
	post_rotation = null
	return ..()

/datum/component/simple_rotation/proc/ExamineMessage(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		examine_list += span_notice("This requires a wrench to be rotated.")

/datum/component/simple_rotation/proc/rotate_right(datum/source, mob/user)
	SIGNAL_HANDLER
	rotate(user, ROTATION_CLOCKWISE)
	return CLICK_ACTION_SUCCESS

/datum/component/simple_rotation/proc/rotate_left(datum/source, mob/user)
	SIGNAL_HANDLER
	rotate(user, ROTATION_COUNTERCLOCKWISE)
	return CLICK_ACTION_SUCCESS

/datum/component/simple_rotation/proc/rotate(mob/user, degrees)
	if(QDELETED(user))
		CRASH("[src] is being rotated [user ? "with a qdeleting" : "without a"] user")
	if(!istype(user))
		CRASH("[src] is being rotated without a user of the wrong type: [user.type]")
	if(!isnum(degrees))
		CRASH("[src] is being rotated without providing the amount of degrees needed")

	if(!can_be_rotated(user, degrees) || !can_user_rotate(user, degrees))
		return

	var/obj/rotated_obj = parent
	rotated_obj.setDir(turn(rotated_obj.dir, degrees))
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		playsound(rotated_obj, 'sound/items/tools/ratchet.ogg', 50, TRUE)

	post_rotation.Invoke(user, degrees)

/datum/component/simple_rotation/proc/can_user_rotate(mob/user, degrees)
	if(isliving(user) && user.can_perform_action(parent, NEED_DEXTERITY))
		return TRUE
	if((rotation_flags & ROTATION_GHOSTS_ALLOWED) && isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE

/datum/component/simple_rotation/proc/can_be_rotated(mob/user, degrees, silent=FALSE)
	var/obj/rotated_obj = parent
	if(!rotated_obj.Adjacent(user))
		silent = TRUE

	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		if(!isliving(user))
			return FALSE
		var/obj/item/tool = user.get_active_held_item()
		if(!tool || tool.tool_behaviour != TOOL_WRENCH)
			if(!silent)
				rotated_obj.balloon_alert(user, "need a wrench!")
			return FALSE
	if(!(rotation_flags & ROTATION_IGNORE_ANCHORED) && rotated_obj.anchored)
		if(istype(rotated_obj, /obj/structure/window) && !silent)
			rotated_obj.balloon_alert(user, "need to unscrew!")
		else if(!silent)
			rotated_obj.balloon_alert(user, "need to unwrench!")
		return FALSE

	if(rotation_flags & ROTATION_NEEDS_ROOM)
		var/target_dir = turn(rotated_obj.dir, degrees)
		var/obj/structure/window/rotated_window = rotated_obj
		var/fulltile = istype(rotated_window) ? rotated_window.fulltile : FALSE
		if(!valid_build_direction(rotated_obj.loc, target_dir, is_fulltile = fulltile))
			if(!silent)
				rotated_obj.balloon_alert(user, "can't rotate in that direction!")
			return FALSE

	if(rotation_flags & ROTATION_NEEDS_UNBLOCKED)
		var/turf/rotate_turf = get_turf(rotated_obj)
		if(rotate_turf.is_blocked_turf(source_atom = rotated_obj))
			if(!silent)
				rotated_obj.balloon_alert(user, "rotation is blocked!")
			return FALSE
	return TRUE

/datum/component/simple_rotation/proc/default_post_rotation(mob/user, degrees)
	return

// maybe we don't need the item context proc but instead the hand one? since we don't need to check held_item
/datum/component/simple_rotation/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	var/rotation_screentip = FALSE

	if(can_be_rotated(user, ROTATION_CLOCKWISE, silent=TRUE))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Rotate left"
		rotation_screentip = TRUE
	if(can_be_rotated(user, ROTATION_COUNTERCLOCKWISE, silent=TRUE))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Rotate right"
		rotation_screentip = TRUE

	if(rotation_screentip)
		return CONTEXTUAL_SCREENTIP_SET

	return NONE
