/datum/component/pixel_shift
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Whether the mob is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = TRUE
	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = NONE
	/// The maximum amount of pixels allowed to move in the turf.
	var/maximum_pixel_shift = 16
	/// The amount of pixel shift required to make the parent passthroughable.
	var/passable_shift_threshold = 8

/datum/component/pixel_shift/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shift/RegisterWithParent()
	RegisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN, PROC_REF(pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_UP, PROC_REF(pixel_shift_up))
	RegisterSignals(parent, list(COMSIG_LIVING_RESET_PULL_OFFSETS, COMSIG_LIVING_SET_PULL_OFFSET, COMSIG_MOVABLE_MOVED), PROC_REF(unpixel_shift))
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(pre_move_check))
	RegisterSignal(parent, COMSIG_LIVING_CAN_ALLOW_THROUGH, PROC_REF(check_passable))

/datum/component/pixel_shift/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN)
	UnregisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
	UnregisterSignal(parent, COMSIG_LIVING_RESET_PULL_OFFSETS)
	UnregisterSignal(parent, COMSIG_LIVING_SET_PULL_OFFSET)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	UnregisterSignal(parent, COMSIG_LIVING_CAN_ALLOW_THROUGH)

/// Overrides Move to Pixel Shift.
/datum/component/pixel_shift/proc/pre_move_check(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	if(shifting)
		pixel_shift(source, direct)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/// Checks if the parent is considered passthroughable from a direction. Projectiles will ignore the check and hit.
/datum/component/pixel_shift/proc/check_passable(mob/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(!isprojectile(mover) && !mover.throwing && passthroughable & border_dir)
		return COMPONENT_LIVING_PASSABLE

/// Activates Pixel Shift on Keybind down. Only Pixel Shift movement will be allowed.
/datum/component/pixel_shift/proc/pixel_shift_down()
	SIGNAL_HANDLER
	shifting = TRUE
	return COMSIG_KB_ACTIVATED

/// Disables Pixel Shift on Keybind up. Allows to Move.
/datum/component/pixel_shift/proc/pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

/// Sets parent pixel offsets to default and deletes the component.
/datum/component/pixel_shift/proc/unpixel_shift()
	SIGNAL_HANDLER
	passthroughable = NONE
	if(is_shifted)
		var/mob/living/owner = parent
		owner.pixel_x = owner.body_position_pixel_x_offset + owner.base_pixel_x
		owner.pixel_y = owner.body_position_pixel_y_offset + owner.base_pixel_y
	qdel(src)

/// In-turf pixel movement which can allow things to pass through if the threshold is met.
/datum/component/pixel_shift/proc/pixel_shift(mob/source, direct)
	passthroughable = NONE
	var/mob/living/owner = parent
	switch(direct)
		if(NORTH)
			if(owner.pixel_y <= maximum_pixel_shift + owner.base_pixel_y)
				owner.pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(owner.pixel_x <= maximum_pixel_shift + owner.base_pixel_x)
				owner.pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(owner.pixel_y >= -maximum_pixel_shift + owner.base_pixel_y)
				owner.pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(owner.pixel_x >= -maximum_pixel_shift + owner.base_pixel_x)
				owner.pixel_x--
				is_shifted = TRUE

	// Yes, I know this sets it to true for everything if more than one is matched.
	// Movement doesn't check diagonals, and instead just checks EAST or WEST, depending on where you are for those.
	if(owner.pixel_y > passable_shift_threshold)
		passthroughable |= EAST | SOUTH | WEST
	else if(owner.pixel_y < -passable_shift_threshold)
		passthroughable |= NORTH | EAST | WEST
	if(owner.pixel_x > passable_shift_threshold)
		passthroughable |= NORTH | SOUTH | WEST
	else if(owner.pixel_x < -passable_shift_threshold)
		passthroughable |= NORTH | EAST | SOUTH
