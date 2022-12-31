/**
 * # Render over, Keep hitbox element!
 *
 * Non bespoke element (1 in existence) that makes structures render over mobs, but still allow you to attack the mob's hitbox!
 * Used in plastic flaps, and directional windows!
 */
/datum/element/render_over_keep_hitbox
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 1
	var/use_position_layering = FALSE

/datum/element/render_over_keep_hitbox/Attach(datum/target, use_position_layering)
	. = ..()
	if(!isstructure(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/structure/obj_target = target

	src.use_position_layering = use_position_layering
	RegisterSignal(obj_target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_overlay))
	RegisterSignal(obj_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_changed_z_level))
	if(use_position_layering)
		RegisterSignal(obj_target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_changed_dir))
	obj_target.alpha = 0
	obj_target.layer = 0
	gen_overlay(obj_target)

/datum/element/render_over_keep_hitbox/Detach(obj/structure/target, ...)
	UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, COMSIG_ATOM_DIR_CHANGE)
	target.alpha = initial(target.alpha)
	target.layer = initial(target.layer)
	target.pixel_y = 0
	target.pixel_z = 0
	SSvis_overlays.remove_vis_overlay(target, target.managed_vis_overlays)
	return ..()

/datum/element/render_over_keep_hitbox/proc/update_overlay(obj/structure/target, list/new_overlays)
	gen_overlay(target)

/datum/element/render_over_keep_hitbox/proc/on_changed_z_level(obj/structure/target, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER

	if(same_z_layer)
		return
	SSvis_overlays.remove_vis_overlay(target, target.managed_vis_overlays)
	gen_overlay(target)

/datum/element/render_over_keep_hitbox/proc/on_changed_dir(obj/structure/target, old_dir, new_dir)
	SSvis_overlays.remove_vis_overlay(target, target.managed_vis_overlays)
	gen_directional_overlay(target, new_dir)

/datum/element/render_over_keep_hitbox/proc/gen_overlay(obj/structure/target)
	if(use_position_layering)
		gen_directional_overlay(target, target.dir)
	else
		gen_square_overlay(target)

// OK, so, this makes windows render properly.
// We're using side_map to handle layering for us
// So things decides layering based on (simplifying)
// Plane
// Position (x and y + pixel_x/y, NOT the position of pixels on the sprite) blocked out in chunks of 32x32 because we're using tile movement
// Layer
// What we're doing here is shifting south windows DOWN onto the tile below them both visually and positionally
// Then shifting them back up ONLY visually, so they layer as if they were below us
// And since windows draw above mobs, this just WORKS
// More details in the proc itself
/datum/element/render_over_keep_hitbox/proc/gen_square_overlay(obj/structure/target)
	var/turf/our_turf = get_turf(target)
	// This version uses layer to ensure we draw above mobs
	SSvis_overlays.add_vis_overlay(
		target,
		target.icon,
		target.icon_state,
		ABOVE_MOB_LAYER,
		MUTATE_PLANE(GAME_PLANE, our_turf),
		target.dir,
		add_appearance_flags = RESET_ALPHA
	)

/datum/element/render_over_keep_hitbox/proc/gen_directional_overlay(obj/structure/target, direction)
	var/turf/our_turf = get_turf(target)
	//you see mobs under it, but you hit them like they are above it
	var/offset = 0
	var/layer = 0
	// If we're to the north, offset our structure up
	// But if we're to the south, offset our overlay down
	// We want north things to draw over things above them, but not below them
	// So we move their position up, and set their layer to the max
	// This way they render over things on their tile, above them
	// For south things, we move them down, and set their layer to draw below things on their tile
	if(direction & NORTH)
		// Ima be honest I have no idea why this works, but it can't be 32 otherwise it'll draw over both top and bottom
		// I think it has to do with the offsetting of the parent. not sure.
		offset = 12
		layer = HIGHEST_GAME_LAYER
		// Offset physically up so we render under things on our tile, and above things above us
		target.pixel_y = 32
		target.pixel_z = -32
	else
		offset = -32
		layer = ON_WALL_LAYER
		target.pixel_y = 0
		target.pixel_z = 0

	// This one offsets physical but not visual position to do the same
	SSvis_overlays.add_vis_overlay(
		target,
		target.icon,
		target.icon_state,
		layer,
		MUTATE_PLANE(GAME_PLANE, our_turf),
		target.dir,
		add_appearance_flags = RESET_ALPHA,
		pixel_y = offset,
		pixel_z = -offset
	)

