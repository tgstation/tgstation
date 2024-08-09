/// Applies and maintains overlays for /datum/element/split_visibility'd atoms
/// This allows us to apply conditions, nick nacks, and animations to splitvis'd walls without massively bloating their DMIs (and thus leading to client performance issues)
/// Want to draw a cute animation on your wall but only if the SOUTH wall is exposed? this is how you do it (see also: hilbert doors)
/// Accepts an overlay to use, and a list of the directions to apply it in (see the icon_smoothing.dm defines for this list, which allow for angles to be specified seperately)
/// If the direction is blocked, the overlay won't draw. it'll also use as a dir the direction it's being drawn in
/// If the overlay has no plane/layer of its own, we'll give it ones that will at the least draw above wall splits, ensuring it actually renders
/datum/component/split_overlay
	/// We draw this normally, in the splitvis form
	var/mutable_appearance/standard
	/// This is drawn hidden (IE: onto a separate plane and onto the wall itself to avoid seeing it through the void with mesons)
	var/mutable_appearance/hidden
	/// And then this one just exists to make sure we render right at z borders, drawing to ourselves if there is nothing around us
	var/mutable_appearance/non_offset_standard
	var/list/dirs_to_apply

/datum/component/split_overlay/Initialize(mutable_appearance/overlay, list/dirs_to_apply)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	// Needs to use bitmask smoothing or we won't have anything to apply onto
	var/atom/parent_atom = parent
	if(!(parent_atom.smoothing_flags & (SMOOTH_BITMASK|SMOOTH_BITMASK_CARDINALS)))
		CRASH("We tried to splitvis [parent.type] without bitmask smoothing. What?")

	// Ensure the overlay won't accidentially inherit stuff from the floor it's potentially applied to
	overlay.appearance_flags |= TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	// If no plane/layer is passed in then we default to a pair that will ensure this draws above splitvis stuff
	if(overlay.plane == FLOAT_PLANE)
		SET_PLANE_EXPLICIT(overlay, GAME_PLANE, parent_atom)
	if(overlay.layer == FLOAT_LAYER)
		overlay.layer = ON_WALL_LAYER

	// We do this to ensure the MAs, when overlayed onto turfs, retain the direction they're set to, rather then inheriting from the turf
	standard = make_mutable_appearance_directional(overlay)
	// Build a hidden overlay, for drawing to ourselves (if we're butted up against another splitvis smoothed wall)
	var/mutable_appearance/hidden = new(standard)
	SET_PLANE_EXPLICIT(hidden, HIDDEN_WALL_PLANE, parent_atom)
	src.hidden = hidden
	// We keep a non offset version of the standard overlay to make sure we work if there's nothing in a particular direction
	non_offset_standard = new /mutable_appearance(standard)

	src.dirs_to_apply = dirs_to_apply

	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(on_movable_junction_change))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))
		var/turf/our_turf = get_turf(parent_atom)
		add_split_overlay(our_turf, parent_atom.smoothing_junction)
	else
		RegisterSignal(parent, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(on_turf_junction_change))
		add_split_overlay(parent_atom, parent_atom.smoothing_junction)

/datum/component/split_overlay/UnregisterFromParent()
	. = ..()
	var/atom/atom_parent = parent
	remove_split_overlay(parent, atom_parent.smoothing_junction)
	UnregisterSignal(parent, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	if(ismovable(parent))
		UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	return ..()

/datum/component/split_overlay/proc/add_split_overlay(turf/target_turf, junction)
	apply_split_overlay(target_turf, junction, add_to_turfs = TRUE)

/datum/component/split_overlay/proc/remove_split_overlay(turf/target_turf, junction)
	apply_split_overlay(target_turf, junction, add_to_turfs = FALSE)

/// Applies our overlays, taking the turf to act from, current smoothing junction, and if we should add or remove our overlays
/datum/component/split_overlay/proc/apply_split_overlay(turf/apply_to, working_junction, add_to_turfs = TRUE)
	for(var/apply_in in dirs_to_apply)
		if(working_junction & apply_in)
			continue
		// We ensure all our overlays have their dirs set to the direction this is being applied in (so they can look different if they'd like)
		var/draw_in = reverse_ndir(apply_in)
		standard.dir = draw_in
		non_offset_standard.dir = draw_in
		hidden.dir = draw_in
		// Offset the standard overlay to match the dir we're working with here
		standard.pixel_x = -DIR_TO_PIXEL_X(apply_in)
		standard.pixel_y = -DIR_TO_PIXEL_Y(apply_in)

		// Get the turf below us (not guarenteed to return anything, if it doesn't we'll apply to ourselves)
		var/turf/below = get_step(apply_to, draw_in)

		if(add_to_turfs)
			// If there's no turf below, apply non offset to ourselves (so it's still drawn)
			if(!below)
				apply_to.add_overlay(non_offset_standard)
			// If the turf below is using splitvis, then we'll just draw to ourselves (to avoid seeing through walls and shit)
			else if(HAS_TRAIT(below, TRAIT_CONTAINS_SPLITVIS))
				// Using hidden so it's not seeable through walls
				apply_to.add_overlay(hidden)
			// Otherwise we'll draw to them, offset slightly
			else
				below.add_overlay(standard)
			continue
		// Remove our overlay from the turf below, to ensure it gets properly cleared out
		if(below)
			below.cut_overlay(standard)
		// Clear from us too, just to be safe
		apply_to.cut_overlay(hidden)
		// If there's nothing below us, clear the non offset version too
		if(!below)
			apply_to.cut_overlay(non_offset_standard)

/datum/component/split_overlay/proc/on_turf_junction_change(turf/source, new_junction)
	SIGNAL_HANDLER
	remove_split_overlay(source, source.smoothing_junction)
	add_split_overlay(source, new_junction)

/datum/component/split_overlay/proc/on_movable_junction_change(atom/movable/source, new_junction)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		remove_split_overlay(source.loc, source.smoothing_junction)
		add_split_overlay(source.loc, new_junction)

/datum/component/split_overlay/proc/on_move(atom/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		remove_split_overlay(old_loc, source.smoothing_junction) // We trust that junction changing from us moving will create the new visuals. just gotta cover the old

/// If the parent move z levels, then we need to regenerate our overlays (since they have set plane values)
/datum/component/split_overlay/proc/on_z_change(atom/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(same_z_layer)
		return
	SET_PLANE_EXPLICIT(standard, PLANE_TO_TRUE(standard.plane), new_turf)
	SET_PLANE_EXPLICIT(non_offset_standard, PLANE_TO_TRUE(non_offset_standard.plane), new_turf)
	SET_PLANE_EXPLICIT(hidden, PLANE_TO_TRUE(hidden.plane), new_turf)
	// Called after Moved() so we don't need to handle removing from the old
	remove_split_overlay(source, source.smoothing_junction)
	add_split_overlay(source, source.smoothing_junction)
