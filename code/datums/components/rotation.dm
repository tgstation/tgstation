/// If an object needs to be rotated with a wrench
#define ROTATION_REQUIRE_WRENCH (1<<0)
/// If ghosts can rotate an object (if the ghost config is enabled)
#define ROTATION_GHOSTS_ALLOWED (1<<1)
/// If an object will ignore anchored for rotation (used for chairs)
#define ROTATION_IGNORE_ANCHORED (1<<2)

/// Rotate an object clockwise
#define ROTATION_CLOCKWISE 1
/// Rotate an object counterclockwise
#define ROTATION_COUNTERCLOCKWISE 2
/// Rotate an object upside down
#define ROTATION_FLIP 3

/datum/component/simple_rotation
	/// Checks if user can rotate
	var/datum/callback/can_user_rotate
	/// Check if object can be rotated at all
	var/datum/callback/can_be_rotated
	/// Additional stuff to do after rotation
	var/datum/callback/after_rotation
	/// Rotation flags for special behavior 
	var/rotation_flags = NONE

/datum/component/simple_rotation/Initialize(rotation_flags = NONE, can_user_rotate, can_be_rotated, after_rotation)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.rotation_flags = rotation_flags
	src.can_user_rotate = can_user_rotate || CALLBACK(src,.proc/default_can_user_rotate)
	src.can_be_rotated = can_be_rotated || CALLBACK(src,.proc/default_can_be_rotated)
	src.after_rotation = after_rotation || CALLBACK(src,.proc/default_after_rotation)

/datum/component/simple_rotation/proc/add_signals()
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/RotateLeft)
	RegisterSignal(parent, COMSIG_CLICK_ALT_SECONDARY, .proc/RotateRight)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/ExamineMessage)

/datum/component/simple_rotation/proc/add_verbs()
	var/obj/rotated_obj = parent
	rotated_obj.verbs += /atom/movable/proc/simple_rotate_flip
	rotated_obj.verbs += /atom/movable/proc/simple_rotate_clockwise
	rotated_obj.verbs += /atom/movable/proc/simple_rotate_counterclockwise

/datum/component/simple_rotation/proc/remove_verbs()
	if(parent)
		var/obj/rotated_obj = parent
		rotated_obj.verbs -= /atom/movable/proc/simple_rotate_flip
		rotated_obj.verbs -= /atom/movable/proc/simple_rotate_clockwise
		rotated_obj.verbs -= /atom/movable/proc/simple_rotate_counterclockwise

/datum/component/simple_rotation/proc/remove_signals()
	UnregisterSignal(parent, list(COMSIG_CLICK_ALT, COMSIG_PARENT_EXAMINE, COMSIG_PARENT_ATTACKBY))

/datum/component/simple_rotation/RegisterWithParent()
	add_verbs()
	add_signals()
	. = ..()

/datum/component/simple_rotation/PostTransfer()
	//Because of the callbacks which we don't track cleanly we can't transfer this
	//item cleanly, better to let the new of the new item create a new rotation datum
	//instead (there's no real state worth transferring)
	return COMPONENT_NOTRANSFER

/datum/component/simple_rotation/UnregisterFromParent()
	remove_verbs()
	remove_signals()
	. = ..()

/datum/component/simple_rotation/Destroy()
	QDEL_NULL(can_user_rotate)
	QDEL_NULL(can_be_rotated)
	QDEL_NULL(after_rotation)
	//Signals + verbs removed via UnRegister
	. = ..()

/datum/component/simple_rotation/ClearFromParent()
	remove_verbs()
	return ..()

/datum/component/simple_rotation/proc/ExamineMessage(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Alt-click + RMB to rotate it clockwise. Alt-click + LMB to rotate it counterclockwise.")
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		examine_list += span_notice("This requires a wrench to be rotated.")

/datum/component/simple_rotation/proc/RotateRight(datum/source, mob/user)
	SIGNAL_HANDLER
	Rotate(user, ROTATION_CLOCKWISE)

/datum/component/simple_rotation/proc/RotateLeft(datum/source, mob/user)
	SIGNAL_HANDLER
	Rotate(user, ROTATION_COUNTERCLOCKWISE)

/datum/component/simple_rotation/proc/Rotate(mob/user, rotation_type)
	if(!can_be_rotated.Invoke(user, rotation_type) || !can_user_rotate.Invoke(user, rotation_type))
		// delete this message_admins logging
		// reminder!  DO NOT FORGET before PR is merged... 
		message_admins("[src] would not rotate properly and is being early returned")
		return

	var/obj/rotated_obj = parent
	var/rot_degree
	switch(rotation_type)
		if(ROTATION_CLOCKWISE)
			rot_degree = -90
		if(ROTATION_COUNTERCLOCKWISE)
			rot_degree = 90
		if(ROTATION_FLIP)
			rot_degree = 180
	rotated_obj.setDir(turn(rotated_obj.dir, rot_degree))
	after_rotation.Invoke(user, rotation_type)

/datum/component/simple_rotation/proc/default_can_user_rotate(mob/living/user, rotation_type)
	if(istype(user) && user.canUseTopic(parent, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return TRUE
	if(isobserver(user) && CONFIG_GET(flag/ghost_interaction) && (src.rotation_flags & ROTATION_GHOSTS_ALLOWED))
		return TRUE	
	return FALSE

/datum/component/simple_rotation/proc/default_can_be_rotated(mob/living/user, rotation_type)
	var/obj/rotated_obj = parent

	if(src.rotation_flags & ROTATION_REQUIRE_WRENCH)
		if(!istype(user))
			return FALSE
		var/obj/item/tool = user.get_active_held_item()
		if(!tool || tool.tool_behaviour != TOOL_WRENCH)
			rotated_obj.balloon_alert(user, "need a wrench")
			return FALSE
	if(src.rotation_flags & ROTATION_IGNORE_ANCHORED) // used to ignore chairs being anchored
		return TRUE
	if(rotated_obj.anchored)
		rotated_obj.balloon_alert(user, "need to unwrench")
		return FALSE
	return TRUE

/datum/component/simple_rotation/proc/default_after_rotation(mob/user, rotation_type)
	var/obj/rotated_obj = parent
	to_chat(user, span_notice("You [rotation_type == ROTATION_FLIP ? "flip" : "rotate"] [rotated_obj]."))
	rotated_obj.add_fingerprint(user)

/atom/movable/proc/simple_rotate_clockwise()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.Rotate(usr, ROTATION_CLOCKWISE)

/atom/movable/proc/simple_rotate_counterclockwise()
	set name = "Rotate Counter-Clockwise"
	set category = "Object"
	set src in oview(1)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.Rotate(usr, ROTATION_COUNTERCLOCKWISE)

/atom/movable/proc/simple_rotate_flip()
	set name = "Flip"
	set category = "Object"
	set src in oview(1)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.Rotate(usr, ROTATION_FLIP)
