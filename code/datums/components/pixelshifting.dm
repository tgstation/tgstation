#define SHIFTING_PARENT 1
#define SHIFTING_ITEMS 2

/datum/component/pixel_shift
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//what type of shifting parent is doing, or if they aren't shifting at all
	var/shifting = FALSE
	//the maximum amount we/an item can move
	var/maximum_pixel_shift = 16
	//If we are shifted
	var/is_shifted = FALSE
	//Allows atoms entering Parent's turf to pass through freely from given directions
	var/passthroughable = NONE
	//Amount of shifting necessary to make the parent passthroughable
	var/passthrough_threshold = 8

/datum/component/pixel_shift/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shift/RegisterWithParent()
	RegisterSignal(parent, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN, PROC_REF(item_pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP, PROC_REF(item_pixel_shift_up))
	RegisterSignal(parent, COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN, PROC_REF(pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_LIVING_PIXEL_SHIFT_UP, PROC_REF(pixel_shift_up))
	RegisterSignals(parent, list(COMSIG_LIVING_RESET_PULL_OFFSETS, COMSIG_LIVING_SET_PULL_OFFSET, COMSIG_MOVABLE_MOVED), PROC_REF(unpixel_shift))
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(pre_move_check))
	RegisterSignal(parent, COMSIG_LIVING_CAN_ALLOW_THROUGH, PROC_REF(check_passable))

/datum/component/pixel_shift/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN,
		COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP,
		COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN,
		COMSIG_KB_LIVING_PIXEL_SHIFT_UP,
		COMSIG_MOB_CLIENT_PRE_LIVING_MOVE,
		COMSIG_LIVING_RESET_PULL_OFFSETS,
		COMSIG_LIVING_SET_PULL_OFFSET,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_CAN_ALLOW_THROUGH,
	))

//locks our movement when holding our keybinds
/datum/component/pixel_shift/proc/pre_move_check(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	if(shifting)
		pixel_shift(source, direct)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

//Procs for shifting items

/datum/component/pixel_shift/proc/item_pixel_shift_down()
	SIGNAL_HANDLER
	shifting = SHIFTING_ITEMS
	return COMSIG_KB_ACTIVATED

/datum/component/pixel_shift/proc/item_pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

//Procs for shifting mobs

/datum/component/pixel_shift/proc/pixel_shift_down()
	SIGNAL_HANDLER
	shifting = SHIFTING_PARENT
	return COMSIG_KB_ACTIVATED

/datum/component/pixel_shift/proc/pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

/// Checks if the parent is considered passthroughable from a direction. Projectiles will ignore the check and hit.
/datum/component/pixel_shift/proc/check_passable(mob/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(!isprojectile(mover) && !mover.throwing && (passthroughable & border_dir))
		return COMPONENT_LIVING_PASSABLE

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
	switch(shifting)
		if(SHIFTING_ITEMS)
			var/atom/pulled_atom = source.pulling
			if(!isitem(pulled_atom))
				return
			var/obj/item/pulled_item = pulled_atom
			switch(direct)
				if(NORTH)
					if(pulled_item.pixel_y <= maximum_pixel_shift + pulled_item.base_pixel_y)
						pulled_item.pixel_y++
				if(EAST)
					if(pulled_item.pixel_x <= maximum_pixel_shift + pulled_item.base_pixel_x)
						pulled_item.pixel_x++
				if(SOUTH)
					if(pulled_item.pixel_y >= -maximum_pixel_shift + pulled_item.base_pixel_y)
						pulled_item.pixel_y--
				if(WEST)
					if(pulled_item.pixel_x >= -maximum_pixel_shift + pulled_item.base_pixel_x)
						pulled_item.pixel_x--
		if(SHIFTING_PARENT)
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
	if(owner.pixel_y > passthrough_threshold)
		passthroughable |= EAST | SOUTH | WEST
	else if(owner.pixel_y < -passthrough_threshold)
		passthroughable |= NORTH | EAST | WEST
	if(owner.pixel_x > passthrough_threshold)
		passthroughable |= NORTH | SOUTH | WEST
	else if(owner.pixel_x < -passthrough_threshold)
		passthroughable |= NORTH | EAST | SOUTH

#undef SHIFTING_PARENT
#undef SHIFTING_ITEMS
