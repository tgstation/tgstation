/**
 * # Render over, Keep hitbox element!
 *
 * Makes atoms render over mobs, but still allow you to attack the mob's hitbox!
 * Used in plastic flaps, and directional windows!
 * If you want to use position layering, you can toggle that with an arg. It's recomended for directional objects (thindows)
 * We accept an optional bitfield of directions to consider "high" (Stuff that renders on the top end of a turf)
 * Also accept the layer our clickcatching object should use. Anything below this won't be clickable through
 */
/datum/element/render_over_keep_hitbox
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The layer to use for our hitbox, typically quite low
	/// IIIII do not know how well this works, sidemap do be kinda fuckin us over
	var/hitbox_layer = 0
	/// If we should act as if the source object is directional or not
	var/use_position_layering = FALSE
	/// If we ARE acting directional, what directions count as "UP" for purposes of layering
	var/high_directions = NONE

/datum/element/render_over_keep_hitbox/Attach(datum/target, hitbox_layer = 0, use_position_layering = FALSE, high_directions = NORTH)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	var/atom/movable/atom_target = target
	atom_target.appearance_flags |= KEEP_TOGETHER

	src.hitbox_layer = hitbox_layer
	src.use_position_layering = use_position_layering
	src.high_directions = high_directions
	// the update_overlays hook only exists because the vis_contents helper clears on update_icon
	// If it weren't for that, we could get away with totally ignoring it :(
	RegisterSignal(atom_target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_overlay))
	RegisterSignal(atom_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_changed_z_level))
	if(use_position_layering)
		// Even though it's being render relayed to nothing, the target will still cause position rendering issues
		// This avoids that by banishing it to the background layer
		atom_target.layer = BACKGROUND_LAYER
		RegisterSignal(atom_target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_changed_dir))
	atom_target.update_appearance()

/datum/element/render_over_keep_hitbox/Detach(atom/movable/target, ...)
	UnregisterSignal(target, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_ATOM_DIR_CHANGE, COMSIG_ATOM_UPDATE_OVERLAYS))
	SSvis_overlays.remove_vis_overlay(target, target.managed_vis_overlays)
	if(use_position_layering)
		target.layer = initial(target.layer)
	return ..()

/datum/element/render_over_keep_hitbox/proc/update_overlay(atom/movable/target, list/new_overlays)
	gen_overlay(target)

/datum/element/render_over_keep_hitbox/proc/on_changed_z_level(atom/movable/target, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER

	if(same_z_layer)
		return
	SSvis_overlays.remove_vis_overlay(target, target.managed_vis_overlays)
	gen_overlay(target)

/datum/element/render_over_keep_hitbox/proc/on_changed_dir(atom/movable/target, old_dir, new_dir)
	SIGNAL_HANDLER
	SSvis_overlays.remove_vis_overlay(target, target.managed_vis_overlays)
	gen_directional_overlay(target, new_dir)

/datum/element/render_over_keep_hitbox/proc/gen_overlay(atom/movable/target)
	if(use_position_layering)
		gen_directional_overlay(target, target.dir)
	else
		gen_square_overlay(target)

/datum/element/render_over_keep_hitbox/proc/gen_square_overlay(atom/movable/target)
	var/turf/our_turf = get_turf(target)
	if(!target.render_target || target.render_target[1] != "*")
		target.render_target = "*[REF(target)]"

	// This one offsets physical but not visual position to do the same
	var/atom/movable/visible = SSvis_overlays.add_vis_overlay(
		target,
		plane = MUTATE_PLANE(GAME_PLANE, target),
		add_appearance_flags = KEEP_APART,
		unique = TRUE
	)
	visible.render_source = target.render_target
	visible.vis_flags |= VIS_INHERIT_LAYER
	var/atom/movable/click_catch = SSvis_overlays.add_vis_overlay(
		target,
		layer = hitbox_layer,
		plane = MUTATE_PLANE(GAME_PLANE, our_turf),
		add_appearance_flags = KEEP_APART,
		unique = TRUE
	)
	click_catch.render_source = target.render_target
	click_catch.alpha = 0
	click_catch.mouse_opacity = MOUSE_OPACITY_ICON
	click_catch.vis_flags |= VIS_INHERIT_ID

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
/datum/element/render_over_keep_hitbox/proc/gen_directional_overlay(atom/movable/target, direction)
	var/turf/our_turf = get_turf(target)
	//you see mobs under it, but you hit them like they are above it
	var/click_offset = 0
	var/layer = 0
	// If we're to the north, offset our structure up
	// But if we're to the south, offset our overlay down
	// We want north things to draw over things above them, but not below them
	click_offset = 32
	if(direction & high_directions)
		// Low layer so we render below anyone on our turf
		layer = ON_WALL_LAYER
	else
		// High layer so we render above anyone on our turf
		layer = HIGHEST_GAME_LAYER

	// We're gonna disable our own rendering, and rely on the two vis_contents lads to do it for us
	if(!target.render_target || target.render_target[1] != "*")
		target.render_target = "*[REF(target)]"

	// This one offsets physical but not visual position to do the same
	var/atom/movable/visible = SSvis_overlays.add_vis_overlay(
		target,
		layer = layer,
		plane = MUTATE_PLANE(GAME_PLANE, our_turf),
		add_appearance_flags = KEEP_APART,
		unique = TRUE
	)
	visible.render_source = target.render_target
	var/atom/movable/click_catch = SSvis_overlays.add_vis_overlay(
		target,
		layer = hitbox_layer,
		plane = MUTATE_PLANE(GAME_PLANE, our_turf),
		add_appearance_flags = KEEP_APART,
		pixel_y = click_offset,
		pixel_z = -click_offset,
		unique = TRUE
	)
	click_catch.render_source = target.render_target
	click_catch.alpha = 0
	// Make it clickable, and direct all clicks to the source object
	click_catch.mouse_opacity = MOUSE_OPACITY_ICON
	click_catch.vis_flags |= VIS_INHERIT_ID



