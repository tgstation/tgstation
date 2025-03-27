///For switchable lights, is it on and currently emitting light?
#define LIGHTING_ON (1<<0)
///Is the parent attached to something else, its loc? Then we need to keep an eye of this.
#define LIGHTING_ATTACHED (1<<1)

#define GET_PARENT (parent_attached_to || parent)

#define SHORT_CAST 2

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
	///How far the light reaches, float.
	var/range = 1
	///Ceiling of range, integer without decimal entries.
	var/lumcount_range = 0
	///How much this light affects the dynamic_lumcount of turfs.
	var/lum_power = 0.5
	///Transparency value.
	var/set_alpha = 0
	///For light sources that can be turned on and off.
	var/overlay_lighting_flags = NONE

	///Cache of the possible light overlays, according to size.
	var/static/list/light_overlays = list(
		"32" = 'icons/effects/light_overlays/light_32.dmi',
		"64" = 'icons/effects/light_overlays/light_64.dmi',
		"96" = 'icons/effects/light_overlays/light_96.dmi',
		"128" = 'icons/effects/light_overlays/light_128.dmi',
		"160" = 'icons/effects/light_overlays/light_160.dmi',
		"192" = 'icons/effects/light_overlays/light_192.dmi',
		"224" = 'icons/effects/light_overlays/light_224.dmi',
		"256" = 'icons/effects/light_overlays/light_256.dmi',
		"288" = 'icons/effects/light_overlays/light_288.dmi',
		"320" = 'icons/effects/light_overlays/light_320.dmi',
		"352" = 'icons/effects/light_overlays/light_352.dmi',
		)

	///Overlay effect to cut into the darkness and provide light.
	var/image/visible_mask
	///Lazy list to track the turfs being affected by our light, to determine their visibility.
	var/list/turf/affected_turfs
	///Movable atom currently holding the light. Parent might be a flashlight, for example, but that might be held by a mob or something else.
	var/atom/movable/current_holder
	///Movable atom the parent is attached to. For example, a flashlight into a helmet or gun. We'll need to track the thing the parent is attached to as if it were the parent itself.
	var/atom/movable/parent_attached_to
	///Whether we're a directional light
	var/directional = FALSE
	///Whether we're a beam light
	var/beam = FALSE
	///A cone overlay for directional light, its alpha and color are dependent on the light
	var/image/cone
	///Current tracked direction for the directional cast behaviour
	var/current_direction
	///Tracks current directional x offset so we don't update unnecessarily
	var/directional_offset_x
	///Tracks current directional y offset so we don't update unnecessarily
	var/directional_offset_y
	///Cast range for the directional cast (how far away the atom is moved)
	var/cast_range = 2

/datum/component/overlay_lighting/Initialize(_range, _power, _color, starts_on, is_directional, is_beam, force)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/movable_parent = parent
	if(!force && movable_parent.light_system != OVERLAY_LIGHT && movable_parent.light_system != OVERLAY_LIGHT_DIRECTIONAL && movable_parent.light_system != OVERLAY_LIGHT_BEAM)
		stack_trace("[type] added to [parent], with [movable_parent.light_system] value for the light_system var. Use [OVERLAY_LIGHT], [OVERLAY_LIGHT_DIRECTIONAL] or [OVERLAY_LIGHT_BEAM] instead.")
		return COMPONENT_INCOMPATIBLE

	. = ..()

	visible_mask = image('icons/effects/light_overlays/light_32.dmi', icon_state = "light")
	SET_PLANE_EXPLICIT(visible_mask, O_LIGHTING_VISUAL_PLANE, movable_parent)
	visible_mask.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	visible_mask.alpha = 0
	visible_mask.blend_mode = BLEND_ADD
	if(is_directional)
		directional = TRUE
		cone = image('icons/effects/light_overlays/light_cone.dmi', icon_state = "light")
		SET_PLANE_EXPLICIT(cone, O_LIGHTING_VISUAL_PLANE, movable_parent)
		cone.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		cone.alpha = 110
		cone.blend_mode = BLEND_ADD
		cone.transform = cone.transform.Translate(-32, -32)
		set_direction(movable_parent.dir)
	if(is_beam)
		beam = TRUE
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


/datum/component/overlay_lighting/RegisterWithParent()
	. = ..()
	if(directional)
		RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_parent_dir_change))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_RANGE, PROC_REF(set_range))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_POWER, PROC_REF(set_power))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_COLOR, PROC_REF(set_color))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_ON, PROC_REF(on_toggle))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_FLAGS, PROC_REF(on_light_flags_change))
	RegisterSignal(parent, COMSIG_ATOM_USED_IN_CRAFT, PROC_REF(on_parent_crafted))
	RegisterSignal(parent, COMSIG_LIGHT_EATER_QUEUE, PROC_REF(on_light_eater))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_move))
	var/atom/movable/movable_parent = parent
	if(movable_parent.light_flags & LIGHT_ATTACHED)
		overlay_lighting_flags |= LIGHTING_ATTACHED
		set_parent_attached_to(ismovable(movable_parent.loc) ? movable_parent.loc : null)
	check_holder()
	if(movable_parent.light_on)
		turn_on()


/datum/component/overlay_lighting/UnregisterFromParent()
	overlay_lighting_flags &= ~LIGHTING_ATTACHED
	set_parent_attached_to(null)
	set_holder(null)
	clean_old_turfs()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_ATOM_UPDATE_LIGHT_RANGE,
		COMSIG_ATOM_UPDATE_LIGHT_POWER,
		COMSIG_ATOM_UPDATE_LIGHT_COLOR,
		COMSIG_ATOM_UPDATE_LIGHT_ON,
		COMSIG_ATOM_UPDATE_LIGHT_FLAGS,
		COMSIG_ATOM_USED_IN_CRAFT,
		COMSIG_LIGHT_EATER_QUEUE,
		))
	if(directional)
		UnregisterSignal(parent, COMSIG_ATOM_DIR_CHANGE)
	if(overlay_lighting_flags & LIGHTING_ON)
		turn_off()
	return ..()


/datum/component/overlay_lighting/Destroy()
	set_parent_attached_to(null)
	set_holder(null)
	clean_old_turfs()
	visible_mask = null
	cone = null
	parent_attached_to = null
	return ..()


///Clears the affected_turfs lazylist, removing from its contents the effects of being near the light.
/datum/component/overlay_lighting/proc/clean_old_turfs()
	for(var/turf/lit_turf as anything in affected_turfs)
		lit_turf.dynamic_lumcount -= lum_power
	affected_turfs = null


///Populates the affected_turfs lazylist, adding to its contents the effects of being near the light.
/datum/component/overlay_lighting/proc/get_new_turfs()
	if(!current_holder)
		return
	. = list()
	for(var/turf/lit_turf in view(lumcount_range, get_turf(current_holder)))
		lit_turf.dynamic_lumcount += lum_power
		. += lit_turf
	if(length(.))
		affected_turfs = .


///Clears the old affected turfs and populates the new ones.
/datum/component/overlay_lighting/proc/make_luminosity_update()
	clean_old_turfs()
	if(!isturf(current_holder?.loc))
		return
	if(directional)
		cast_directional_light()
	get_new_turfs()


///Adds the luminosity and source for the affected movable atoms to keep track of their visibility.
/datum/component/overlay_lighting/proc/add_dynamic_lumi()
	LAZYSET(current_holder.affected_dynamic_lights, src, lumcount_range + 1)
	current_holder.underlays += visible_mask
	current_holder.update_dynamic_luminosity()
	if(directional)
		current_holder.underlays += cone

///Removes the luminosity and source for the affected movable atoms to keep track of their visibility.
/datum/component/overlay_lighting/proc/remove_dynamic_lumi()
	LAZYREMOVE(current_holder.affected_dynamic_lights, src)
	current_holder.underlays -= visible_mask
	current_holder.update_dynamic_luminosity()
	if(directional)
		current_holder.underlays -= cone

///Called to change the value of parent_attached_to.
/datum/component/overlay_lighting/proc/set_parent_attached_to(atom/movable/new_parent_attached_to)
	if(new_parent_attached_to == parent_attached_to)
		return

	. = parent_attached_to
	parent_attached_to = new_parent_attached_to
	if(.)
		var/atom/movable/old_parent_attached_to = .
		UnregisterSignal(old_parent_attached_to, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_LIGHT_EATER_QUEUE))
		if(old_parent_attached_to == current_holder)
			RegisterSignal(old_parent_attached_to, COMSIG_QDELETING, PROC_REF(on_holder_qdel))
			RegisterSignal(old_parent_attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
			RegisterSignal(old_parent_attached_to, COMSIG_LIGHT_EATER_QUEUE, PROC_REF(on_light_eater))
	if(parent_attached_to)
		if(parent_attached_to == current_holder)
			UnregisterSignal(current_holder, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_LIGHT_EATER_QUEUE))
		RegisterSignal(parent_attached_to, COMSIG_QDELETING, PROC_REF(on_parent_attached_to_qdel))
		RegisterSignal(parent_attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_attached_to_moved))
		RegisterSignal(parent_attached_to, COMSIG_LIGHT_EATER_QUEUE, PROC_REF(on_light_eater))
	check_holder()


///Called to change the value of current_holder.
/datum/component/overlay_lighting/proc/set_holder(atom/movable/new_holder)
	if(new_holder == current_holder)
		return
	if(current_holder)
		if(current_holder != parent && current_holder != parent_attached_to)
			UnregisterSignal(current_holder, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_LIGHT_EATER_QUEUE))
			if(directional)
				UnregisterSignal(current_holder, COMSIG_ATOM_DIR_CHANGE)
		if(overlay_lighting_flags & LIGHTING_ON)
			remove_dynamic_lumi()
	current_holder = new_holder
	if(new_holder == null)
		clean_old_turfs()
		return
	if(new_holder != parent && new_holder != parent_attached_to)
		RegisterSignal(new_holder, COMSIG_QDELETING, PROC_REF(on_holder_qdel))
		RegisterSignal(new_holder, COMSIG_LIGHT_EATER_QUEUE, PROC_REF(on_light_eater))
		if(overlay_lighting_flags & LIGHTING_ON)
			RegisterSignal(new_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
		if(directional)
			RegisterSignal(new_holder, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_holder_dir_change))
	if(directional && current_direction != new_holder.dir)
		current_direction = new_holder.dir
	if(overlay_lighting_flags & LIGHTING_ON)
		add_dynamic_lumi()
		make_luminosity_update()


///Used to determine the new valid current_holder from the parent's loc.
/datum/component/overlay_lighting/proc/check_holder()
	var/atom/movable/movable_parent = GET_PARENT
	if(QDELETED(movable_parent))
		set_holder(null)
		return
	if(isturf(movable_parent.loc))
		set_holder(movable_parent)
		return
	var/atom/inside = movable_parent.loc //Parent's loc
	if(isnull(inside))
		set_holder(null)
		return
	if(isturf(inside.loc))
		// storage items block light, also don't be moving into a qdeleted item
		if(QDELETED(inside) || istype(inside, /obj/item/storage))
			set_holder(null)
		else
			set_holder(inside)
		return
	set_holder(null)


///Called when the current_holder is qdeleted, to remove the light effect.
/datum/component/overlay_lighting/proc/on_holder_qdel(atom/movable/source, force)
	SIGNAL_HANDLER
	if(QDELETED(current_holder))
		set_holder(null)
		return
	UnregisterSignal(current_holder, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	if(directional)
		UnregisterSignal(current_holder, COMSIG_ATOM_DIR_CHANGE)
	set_holder(null)


///Called when current_holder changes loc.
/datum/component/overlay_lighting/proc/on_holder_moved(atom/movable/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	if(!(overlay_lighting_flags & LIGHTING_ON))
		return
	make_luminosity_update()


///Called when parent changes loc.
/datum/component/overlay_lighting/proc/on_parent_moved(atom/movable/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(overlay_lighting_flags & LIGHTING_ATTACHED)
		set_parent_attached_to(ismovable(movable_parent.loc) ? movable_parent.loc : null)
	check_holder()
	if(!(overlay_lighting_flags & LIGHTING_ON) || !current_holder)
		return
	make_luminosity_update()

/datum/component/overlay_lighting/proc/on_z_move(atom/source)
	SIGNAL_HANDLER
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays -= visible_mask
		current_holder.underlays -= cone
	SET_PLANE_EXPLICIT(visible_mask, O_LIGHTING_VISUAL_PLANE, source)
	if(cone)
		SET_PLANE_EXPLICIT(cone, O_LIGHTING_VISUAL_PLANE, source)
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += visible_mask
		current_holder.underlays += cone

///Called when the current_holder is qdeleted, to remove the light effect.
/datum/component/overlay_lighting/proc/on_parent_attached_to_qdel(atom/movable/source, force)
	SIGNAL_HANDLER
	UnregisterSignal(parent_attached_to, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	if(directional)
		UnregisterSignal(parent_attached_to, COMSIG_ATOM_DIR_CHANGE)
	if(parent_attached_to == current_holder)
		set_holder(null)
	set_parent_attached_to(null)


///Called when parent_attached_to changes loc.
/datum/component/overlay_lighting/proc/on_parent_attached_to_moved(atom/movable/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	check_holder()
	if(!(overlay_lighting_flags & LIGHTING_ON) || !current_holder)
		return
	make_luminosity_update()


///Changes the range which the light reaches. 0 means no light, 6 is the maximum value.
/datum/component/overlay_lighting/proc/set_range(atom/source, old_range)
	SIGNAL_HANDLER
	var/new_range = source.light_range
	if(range == new_range)
		return
	if(new_range == 0)
		turn_off()
	range = clamp(CEILING(new_range, 0.5), 1, 6)
	var/pixel_bounds = ((range - 1) * 64) + 32
	lumcount_range = CEILING(range, 1)
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays -= visible_mask
	visible_mask.icon = light_overlays["[pixel_bounds]"]
	if(pixel_bounds == 32)
		if(!directional) // it's important that we make it to the end of this function if we are a directional light
			visible_mask.transform = null
			return
	else
		var/offset = (pixel_bounds - 32) * 0.5
		var/matrix/transform = new
		transform.Translate(-offset, -offset)
		visible_mask.transform = transform
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += visible_mask
	if(directional)
		if(beam)
			cast_range = max(round(new_range * 0.5), 1)
		else
			cast_range = clamp(round(new_range * 0.5), 1, 3)
	if(overlay_lighting_flags & LIGHTING_ON)
		make_luminosity_update()


///Changes the intensity/brightness of the light by altering the visual object's alpha.
/datum/component/overlay_lighting/proc/set_power(atom/source, old_power)
	SIGNAL_HANDLER
	var/new_power = source.light_power
	set_lum_power(new_power >= 0 ? 0.5 : -0.5)
	set_alpha = min(230, (abs(new_power) * 120) + 30)
	visible_mask.blend_mode = new_power > 0 ? BLEND_ADD : BLEND_SUBTRACT
	if(directional)
		cone.blend_mode = new_power > 0 ? BLEND_ADD : BLEND_SUBTRACT
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays -= visible_mask
	visible_mask.alpha = set_alpha
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += visible_mask
	if(!directional)
		return
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays -= cone
	cone.alpha = min(120, (abs(new_power) * 60) + 15)
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += cone


///Changes the light's color, pretty straightforward.
/datum/component/overlay_lighting/proc/set_color(atom/source, old_color)
	SIGNAL_HANDLER
	var/new_color = source.light_color
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays -= visible_mask
	visible_mask.color = new_color
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += visible_mask
	if(!directional)
		return
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays -= cone
	cone.color = new_color
	if(current_holder && overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += cone


///Toggles the light on and off.
/datum/component/overlay_lighting/proc/on_toggle(atom/source, old_value)
	SIGNAL_HANDLER
	var/new_value = source.light_on
	if(new_value) //Truthy value input, turn on.
		turn_on()
		return
	turn_off() //Falsey value, turn off.


///Triggered right after the parent light flags change.
/datum/component/overlay_lighting/proc/on_light_flags_change(atom/source, old_flags)
	SIGNAL_HANDLER
	var/new_flags = source.light_flags
	var/atom/movable/movable_parent = parent
	if(!((new_flags ^ old_flags) & LIGHT_ATTACHED))
		return

	if(new_flags & LIGHT_ATTACHED) // Gained the [LIGHT_ATTACHED] property
		overlay_lighting_flags |= LIGHTING_ATTACHED
		if(ismovable(movable_parent.loc))
			set_parent_attached_to(movable_parent.loc)
	else // Lost the [LIGHT_ATTACHED] property
		overlay_lighting_flags &= ~LIGHTING_ATTACHED
		set_parent_attached_to(null)


///Toggles the light on.
/datum/component/overlay_lighting/proc/turn_on()
	if(overlay_lighting_flags & LIGHTING_ON)
		return
	overlay_lighting_flags |= LIGHTING_ON
	if(current_holder)
		add_dynamic_lumi()
		if(directional)
			cast_directional_light()
	if(current_holder && current_holder != parent && current_holder != parent_attached_to)
		RegisterSignal(current_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	get_new_turfs()


///Toggles the light off.
/datum/component/overlay_lighting/proc/turn_off()
	if(!(overlay_lighting_flags & LIGHTING_ON))
		return
	if(current_holder)
		remove_dynamic_lumi()
	overlay_lighting_flags &= ~LIGHTING_ON
	if(current_holder && current_holder != parent && current_holder != parent_attached_to)
		UnregisterSignal(current_holder, COMSIG_MOVABLE_MOVED)
	clean_old_turfs()


///Here we append the behavior associated to changing lum_power.
/datum/component/overlay_lighting/proc/set_lum_power(new_lum_power)
	if(lum_power == new_lum_power)
		return
	. = lum_power
	lum_power = new_lum_power
	var/difference = . - lum_power
	for(var/turf/lit_turf as anything in affected_turfs)
		lit_turf.dynamic_lumcount -= difference

///Here we append the behavior associated to changing lum_power.
/datum/component/overlay_lighting/proc/cast_directional_light()
	var/final_distance = cast_range
	//Lower the distance by 1 if we're not looking at a cardinal direction, and we're not a short cast
	if(final_distance > SHORT_CAST && !(ALL_CARDINALS & current_direction))
		final_distance -= 1
	var/turf/scanning = get_turf(current_holder)
	for(var/i in 1 to final_distance)
		var/turf/next_turf = get_step(scanning, current_direction)
		if(isnull(next_turf) || IS_OPAQUE_TURF(next_turf))
			final_distance = i
			break
		scanning = next_turf

	current_holder.underlays -= visible_mask

	var/translate_x = -((range - 1) * 32)
	var/translate_y = translate_x
	var/scale_x = 1
	var/scale_y = 1
	switch(current_direction)
		if(NORTH)
			translate_y += 32 * final_distance
			if(beam && range > 1)
				scale_x = 1 / (range - (range/5))
		if(SOUTH)
			translate_y += -32 * final_distance
			if(beam && range > 1)
				scale_x = 1 / (range - (range/5))
		if(EAST)
			translate_x += 32 * final_distance
			if(beam && range > 1)
				scale_y = 1 / (range - (range/5))
		if(WEST)
			translate_x += -32 * final_distance
			if(beam && range > 1)
				scale_y = 1 / (range - (range/5))

	if((directional_offset_x != translate_x) || (directional_offset_y != translate_y))
		directional_offset_x = translate_x
		directional_offset_y = translate_y
		var/matrix/transform = matrix()
		if(beam && range > 1)
			transform.Scale(scale_x, scale_y)
		transform.Translate(translate_x, translate_y)
		visible_mask.transform = transform
	if(overlay_lighting_flags & LIGHTING_ON)
		current_holder.underlays += visible_mask

///Called when current_holder changes loc.
/datum/component/overlay_lighting/proc/on_holder_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	set_direction(newdir)

///Called when parent changes loc.
/datum/component/overlay_lighting/proc/on_parent_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	set_direction(newdir)

///Sets a new direction for the directional cast, then updates luminosity
/datum/component/overlay_lighting/proc/set_direction(newdir)
	if(!newdir)
		return
	if(current_direction == newdir)
		return
	current_direction = newdir
	if(overlay_lighting_flags & LIGHTING_ON)
		make_luminosity_update()

/datum/component/overlay_lighting/proc/on_parent_crafted(datum/source, atom/movable/new_craft)
	SIGNAL_HANDLER

	if(!istype(new_craft))
		return

	UnregisterSignal(parent, COMSIG_ATOM_USED_IN_CRAFT)
	RegisterSignal(new_craft, COMSIG_ATOM_USED_IN_CRAFT, PROC_REF(on_parent_crafted))
	set_parent_attached_to(new_craft)

/// Handles putting the source for overlay lights into the light eater queue since we aren't tracked by [/atom/var/light_sources]
/datum/component/overlay_lighting/proc/on_light_eater(datum/source, list/light_queue, datum/light_eater)
	SIGNAL_HANDLER
	light_queue[parent] = TRUE
	return NONE

#undef LIGHTING_ON
#undef LIGHTING_ATTACHED
#undef GET_PARENT
#undef SHORT_CAST
