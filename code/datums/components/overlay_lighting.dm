/**
 * Movable atom overlay-based lighting component.
 *
 * * Component works by applying a visual object to the parent target.
 *
 * * The component tracks the parent's loc to determine the current_holder.
 * * The current_holder is either the parent or its loc, whichever is on a turf. If none, then the current_holder is null and the light is not visible.
 *
 * * Lighting works at its base by applying a dark overlay and "cutting" said darkness with light, adding (possibly colored) transparency.
 * * This component uses the visible_mask visual object to apply said light mask on the darkness.
 *
 * * The main limitation of this system is that it uses a limited number of pre-baked geometrical shapes, but for most uses it does the job.
 *
 * * Another limitation is for big lights: you only see the light if you see the object emiting it.
 * * For small objects this is good (you can't see them behind a wall), but for big ones this quickly becomes prety clumsy.
*/
/datum/component/overlay_lighting
	/// Ceiling of range, integer without decimal entries.
	var/lumcount_range = 0
	/// How much this light affects the dynamic_lumcount of turfs.
	var/lum_power = 0.5
	/// Datum that actually creates the overlay we manage
	var/datum/light_overlay/light
	/// The turf we are currently displaying light on, if any
	var/turf/luminosity_turf

/datum/component/overlay_lighting/Initialize(_range, _power, _color, starts_on, is_directional, is_beam, force)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/movable_parent = parent
	if(!force && !IS_OVERLAY_LIGHT_SYSTEM(movable_parent.light_system))
		stack_trace("[type] added to [parent], with [movable_parent.light_system] value for the light_system var. Use [OVERLAY_LIGHT], [OVERLAY_LIGHT_DIRECTIONAL] or [OVERLAY_LIGHT_BEAM] instead.")
		return COMPONENT_INCOMPATIBLE

	. = ..()

	light = new(parent, is_directional, is_beam)
	RegisterSignal(light, COMSIG_LIGHT_OVERLAY_UPDATE_HOLDER, PROC_REF(on_holder_changed))

	if(!isnull(_range))
		movable_parent.set_light_range(_range)
	set_range(parent, movable_parent.light_range)
	if(!isnull(_power))
		movable_parent.set_light_power(_power)
	set_power(parent, movable_parent.light_power)
	if(!isnull(_color))
		movable_parent.set_light_color(_color)
	set_color(parent, movable_parent.light_color)
	if(!isnull(starts_on))
		movable_parent.set_light_on(starts_on)
	set_light_render_source(parent, "")

/datum/component/overlay_lighting/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_RANGE, PROC_REF(set_range))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_POWER, PROC_REF(set_power))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_COLOR, PROC_REF(set_color))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_ON, PROC_REF(on_toggle))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_FLAGS, PROC_REF(on_light_flags_change))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_RENDER_SOURCE, PROC_REF(set_light_render_source))
	RegisterSignal(parent, COMSIG_LIGHT_EATER_QUEUE, PROC_REF(on_light_eater))
	var/atom/movable/movable_parent = parent
	if(movable_parent.light_flags & LIGHT_ATTACHED)
		light.overlay_lighting_flags |= LIGHTING_ATTACHED
		light.set_parent_attached_to(ismovable(movable_parent.loc) ? movable_parent.loc : null)
	if(movable_parent.light_on)
		turn_on()

/datum/component/overlay_lighting/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_UPDATE_LIGHT_RANGE,
		COMSIG_ATOM_UPDATE_LIGHT_POWER,
		COMSIG_ATOM_UPDATE_LIGHT_COLOR,
		COMSIG_ATOM_UPDATE_LIGHT_ON,
		COMSIG_ATOM_UPDATE_LIGHT_FLAGS,
		COMSIG_ATOM_UPDATE_LIGHT_RENDER_SOURCE,
		COMSIG_LIGHT_EATER_QUEUE,
		))
	return ..()

/datum/component/overlay_lighting/Destroy()
	QDEL_NULL(light)
	return ..()

/// Clears ourselves from spatial grid's dynlights lists
/datum/component/overlay_lighting/proc/clean_old_cells()
	if (isnull(luminosity_turf))
		return
	for (var/datum/spatial_grid_cell/grid_cell as anything in SSspatial_grid.get_cells_in_range(luminosity_turf, lumcount_range))
		GRID_CELL_REMOVE(grid_cell.dynamic_light_sources, src)

/// Populates the affected_turfs lazylist, adding to its contents the effects of being near the light.
/datum/component/overlay_lighting/proc/register_new_cells()
	var/atom/movable/current_holder = light.current_holder
	if(!current_holder || !isturf(current_holder.loc) || !(light.overlay_lighting_flags & LIGHTING_ON))
		return
	luminosity_turf = get_turf(current_holder)
	if (isnull(luminosity_turf))
		return
	for (var/datum/spatial_grid_cell/grid_cell as anything in SSspatial_grid.get_cells_in_range(luminosity_turf, lumcount_range))
		GRID_CELL_ASSOC_SET(grid_cell.dynamic_light_sources, src, lum_power)

/// Clears the old affected cells and populates the new ones.
/datum/component/overlay_lighting/proc/update_luminosity_cells()
	if(get_turf(light.current_holder) == luminosity_turf)
		return
	if(luminosity_turf)
		clean_old_cells()
	register_new_cells(light.current_holder)

/// Adds the luminosity and source for the affected movable atoms to keep track of their visibility.
/datum/component/overlay_lighting/proc/add_dynamic_lumi(atom/movable/relevant_holder)
	if(!(light.overlay_lighting_flags & LIGHTING_ON) || isnull(relevant_holder))
		return
	LAZYSET(relevant_holder.affected_dynamic_lights, src, lumcount_range + 1)
	relevant_holder.update_dynamic_luminosity()

/// Removes the luminosity and source for the affected movable atoms to keep track of their visibility.
/datum/component/overlay_lighting/proc/remove_dynamic_lumi(atom/movable/relevant_holder)
	if(isnull(relevant_holder))
		return
	LAZYREMOVE(relevant_holder.affected_dynamic_lights, src)
	relevant_holder.update_dynamic_luminosity()

/datum/component/overlay_lighting/proc/on_holder_changed(datum/source, atom/old_holder, atom/new_holder)
	SIGNAL_HANDLER
	if(old_holder)
		UnregisterSignal(old_holder, COMSIG_MOVABLE_MOVED)
		if (old_holder != parent)
			UnregisterSignal(old_holder, COMSIG_LIGHT_EATER_QUEUE)
		remove_dynamic_lumi(old_holder)
	update_luminosity_cells()

	if(new_holder == null)
		return

	if(new_holder != parent)
		RegisterSignal(new_holder, COMSIG_LIGHT_EATER_QUEUE, PROC_REF(on_light_eater))
	if(light.overlay_lighting_flags & LIGHTING_ON)
		RegisterSignal(new_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	add_dynamic_lumi(new_holder)

/// Called when current_holder changes loc.
/datum/component/overlay_lighting/proc/on_holder_moved(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	update_luminosity_cells()

///Changes the range which the light reaches. 0 means no light, 6 is the maximum value.
/datum/component/overlay_lighting/proc/set_range(atom/source, old_range)
	SIGNAL_HANDLER
	light.set_range(source.light_range)
	lumcount_range = ceil(light.range)
	update_luminosity_cells()

/// Changes the intensity/brightness of the light by altering the visual object's alpha.
/datum/component/overlay_lighting/proc/set_power(atom/source, old_power)
	SIGNAL_HANDLER
	light.set_power(source.light_power)
	lum_power = source.light_power >= 0 ? 0.5 : -0.5
	clean_old_cells()
	register_new_cells()

/// Changes the light's color, pretty straightforward.
/datum/component/overlay_lighting/proc/set_color(atom/source, old_color)
	SIGNAL_HANDLER
	light.set_color(source.light_color)

/// Toggles the light on and off.
/datum/component/overlay_lighting/proc/on_toggle(atom/source, old_value)
	SIGNAL_HANDLER
	var/new_value = source.light_on
	if(new_value)
		turn_on()
	else
		turn_off()

/// Triggered right after the parent light flags change.
/datum/component/overlay_lighting/proc/on_light_flags_change(atom/source, old_flags)
	SIGNAL_HANDLER
	var/new_flags = source.light_flags
	var/atom/movable/movable_parent = parent
	if(!((new_flags ^ old_flags) & LIGHT_ATTACHED))
		return

	if(new_flags & LIGHT_ATTACHED) // Gained the [LIGHT_ATTACHED] property
		light.overlay_lighting_flags |= LIGHTING_ATTACHED
		if(ismovable(movable_parent.loc))
			light.set_parent_attached_to(movable_parent.loc)
	else // Lost the [LIGHT_ATTACHED] property
		light.overlay_lighting_flags &= ~LIGHTING_ATTACHED
		light.set_parent_attached_to(null)

/// Changes the light's color, pretty straightforward.
/datum/component/overlay_lighting/proc/set_light_render_source(atom/source, old_render_source)
	SIGNAL_HANDLER
	light.set_light_render_source(source.light_render_source)

/// Toggles the light on.
/datum/component/overlay_lighting/proc/turn_on()
	if(!light.turn_on() || !light.current_holder)
		return
	add_dynamic_lumi(light.current_holder)
	RegisterSignal(light.current_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	update_luminosity_cells()

/// Toggles the light off.
/datum/component/overlay_lighting/proc/turn_off()
	if(!light.turn_off())
		return

	if(!light.current_holder)
		if(luminosity_turf)
			clean_old_cells()
		return

	remove_dynamic_lumi(light.current_holder)
	UnregisterSignal(light.current_holder, COMSIG_MOVABLE_MOVED)
	update_luminosity_cells()

/// Handles putting the source for overlay lights into the light eater queue since we aren't tracked by [/atom/var/light_sources]
/datum/component/overlay_lighting/proc/on_light_eater(datum/source, list/light_queue, datum/light_eater)
	SIGNAL_HANDLER
	light_queue[parent] = TRUE
	return NONE
