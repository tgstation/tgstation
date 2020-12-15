/**
 * An element that enables and disables movetype bitflags as movetype traits are added and removed.
 * It also handles the +2/-2 pixel y anim loop typical of mobs possessing the FLYING or FLOATING movetypes.
 * This element is necessary for the TRAIT_MOVE_ traits to work correctly. So make sure to include it when
 * manipulating those traits on non-living movables.
 */
/datum/element/movetype_handler
	element_flags = ELEMENT_DETACH

	var/list/attached_atoms = list()
	var/list/paused_floating_anim_atoms = list()

/datum/element/movetype_handler/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(attached_atoms[target]) //Already attached.
		return

	var/atom/movable/AM = target
	RegisterSignal(AM, GLOB.movement_type_trait_add_signals, .proc/on_movement_type_trait_gain)
	RegisterSignal(AM, GLOB.movement_type_trait_remove_signals, .proc/on_movement_type_trait_loss)
	RegisterSignal(AM, SIGNAL_ADDTRAIT(TRAIT_NO_FLOATING_ANIM), .proc/on_no_floating_anim_trait_gain)
	RegisterSignal(AM, SIGNAL_REMOVETRAIT(TRAIT_NO_FLOATING_ANIM), .proc/on_no_floating_anim_trait_loss)
	RegisterSignal(AM, COMSIG_PAUSE_FLOATING_ANIM, .proc/pause_floating_anim)
	attached_atoms[AM] = TRUE

	if(AM.movement_type & (FLOATING|FLYING) && !HAS_TRAIT(AM, TRAIT_NO_FLOATING_ANIM))
		float(AM)

/datum/element/movetype_handler/Detach(datum/source)
	UnregisterSignal(source, list(
		GLOB.movement_type_trait_add_signals,
		GLOB.movement_type_trait_remove_signals,
		SIGNAL_ADDTRAIT(TRAIT_NO_FLOATING_ANIM),
		SIGNAL_REMOVETRAIT(TRAIT_NO_FLOATING_ANIM),
		COMSIG_PAUSE_FLOATING_ANIM
	))
	attached_atoms -= source
	paused_floating_anim_atoms -= source
	stop_floating(source)
	return ..()

/// Called when a movement type trait is added to the movable. Enables the relative bitflag.
/datum/element/movetype_handler/proc/on_movement_type_trait_gain(atom/movable/source, trait)
	SIGNAL_HANDLER
	var/flag = GLOB.movement_type_trait_to_flag[trait]
	if(source.movement_type & flag)
		return
	if(!(source.movement_type & (FLOATING|FLYING)) && (trait == TRAIT_MOVE_FLYING || trait == TRAIT_MOVE_FLOATING) && !paused_floating_anim_atoms[source] && !HAS_TRAIT(source, TRAIT_NO_FLOATING_ANIM))
		float(source)
	source.movement_type |= flag
	SEND_SIGNAL(source, COMSIG_MOVETYPE_FLAG_ENABLED, flag)

/// Called when a movement type trait is removed from the movable. Disables the relative bitflag if it wasn't there in the compile-time bitfield.
/datum/element/movetype_handler/proc/on_movement_type_trait_loss(atom/movable/source, trait)
	SIGNAL_HANDLER
	var/flag = GLOB.movement_type_trait_to_flag[trait]
	if(initial(source.movement_type) & flag)
		return
	source.movement_type &= ~flag
	if((trait == TRAIT_MOVE_FLYING || trait == TRAIT_MOVE_FLOATING) && !(source.movement_type & (FLOATING|FLYING)))
		stop_floating(source)
	SEND_SIGNAL(source, COMSIG_MOVETYPE_FLAG_DISABLED, flag)

/// Called when the TRAIT_NO_FLOATING_ANIM trait is added to the movable. Stops it from bobbing up and down.
/datum/element/movetype_handler/proc/on_no_floating_anim_trait_gain(atom/movable/source, trait)
	SIGNAL_HANDLER
	stop_floating(source)

/// Called when the TRAIT_NO_FLOATING_ANIM trait is removed from the mob. Restarts the bobbing animation.
/datum/element/movetype_handler/proc/on_no_floating_anim_trait_loss(atom/movable/source, trait)
	SIGNAL_HANDLER
	if(source.movement_type & (FLOATING|FLYING) && !paused_floating_anim_atoms[source])
		float(source)

///Pauses the floating animation for the duration of the timer... plus [tickrate - (world.time + timer) % tickrate] to be precise.
/datum/element/movetype_handler/proc/pause_floating_anim(atom/movable/source, timer)
	SIGNAL_HANDLER
	if(paused_floating_anim_atoms[source] < world.time + timer)
		stop_floating(source)
		if(!length(paused_floating_anim_atoms))
			START_PROCESSING(SSdcs, src) //1 second tickrate.
		paused_floating_anim_atoms[source] = world.time + timer

/datum/element/movetype_handler/process()
	for(var/a in paused_floating_anim_atoms)
		var/atom/movable/AM = a
		if(!AM)
			paused_floating_anim_atoms -= AM
		else if(paused_floating_anim_atoms[AM] < world.time)
			if(AM.movement_type & (FLOATING|FLYING) && !HAS_TRAIT(AM, TRAIT_NO_FLOATING_ANIM))
				float(AM)
			paused_floating_anim_atoms -= AM
	if(!length(paused_floating_anim_atoms))
		STOP_PROCESSING(SSdcs, src)

///Floats the movable up and down.
/datum/element/movetype_handler/proc/float(atom/movable/AM)
	animate(AM, pixel_y = 2, time = 10, loop = -1, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_y = -2, time = 10, loop = -1, flags = ANIMATION_RELATIVE)

/// Stops the above.
/datum/element/movetype_handler/proc/stop_floating(atom/movable/AM)
	var/final_pixel_y = AM.base_pixel_y
	if(isliving(AM)) //Living mobs also have a 'body_position_pixel_y_offset' variable that has to be taken into account here.
		var/mob/living/L = AM
		final_pixel_y += L.body_position_pixel_y_offset
	animate(src, pixel_y = final_pixel_y, time = 1 SECONDS)
