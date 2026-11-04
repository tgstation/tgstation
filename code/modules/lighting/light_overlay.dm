#define SHORT_CAST 2

/// Datum which handles visual part of overlay lighting
/// Split from the overlay_lighting component as to allow multiple visuals to exist side by side, or to have a light separate from atom vars/without casting turf lumens
/datum/light_overlay
	/// How far the light reaches, float.
	var/range = 1
	/// Transparency value.
	var/set_alpha = 0
	/// For light sources that can be turned on and off.
	var/overlay_lighting_flags = NONE

	/// Cache of the possible light overlays, according to size.
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

	/// Overlay effect to cut into the darkness and provide light.
	var/image/visible_mask
	/// The movable we are "owned" by
	var/atom/movable/parent
	/// Movable atom currently holding the light. Parent might be a flashlight, for example, but that might be held by a mob or something else.
	var/atom/movable/current_holder
	/// Movable atom the parent is attached to. For example, a flashlight into a helmet or gun. We'll need to track the thing the parent is attached to as if it were the parent itself.
	var/atom/movable/parent_attached_to
	/// Whether we're a directional light
	var/directional = FALSE
	/// Whether we're a beam light
	var/beam = FALSE
	/// A cone overlay for directional light, its alpha and color are dependent on the light
	var/image/cone
	/// Are we currently displaying light on our holder?
	var/currently_displaying = FALSE
	/// Current tracked direction for the directional cast behaviour
	var/current_direction
	/// Tracks current directional x offset so we don't update unnecessarily
	var/directional_offset_x
	/// Tracks current directional y offset so we don't update unnecessarily
	var/directional_offset_y
	/// Cast range for the directional cast (how far away the atom is moved)
	var/cast_range = 2

/datum/light_overlay/New(atom/movable/parent, is_directional, is_beam)
	. = ..()
	src.parent = parent
	visible_mask = image('icons/effects/light_overlays/light_32.dmi', icon_state = "light")
	SET_PLANE_EXPLICIT(visible_mask, O_LIGHTING_VISUAL_PLANE, parent)
	visible_mask.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	visible_mask.alpha = 0
	visible_mask.blend_mode = BLEND_ADD

	if(is_directional)
		directional = TRUE
		cone = image('icons/effects/light_overlays/light_cone.dmi', icon_state = "light")
		SET_PLANE_EXPLICIT(cone, O_LIGHTING_VISUAL_PLANE, parent)
		cone.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		cone.alpha = 110
		cone.blend_mode = BLEND_ADD
		cone.transform = cone.transform.Translate(-32, -32)
		set_direction(parent.dir)

	if(is_beam)
		beam = TRUE

	refresh_shared_signals()
	RegisterSignal(parent, COMSIG_ATOM_USED_IN_CRAFT, PROC_REF(on_parent_crafted))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_move))
	RegisterSignal(parent, COMSIG_ITEM_BEFORE_PICKUP_ANIMATION, PROC_REF(on_pickup_anim))
	check_holder()

/datum/light_overlay/Destroy(force)
	set_parent_attached_to(null)
	set_holder(null)
	if(overlay_lighting_flags & LIGHTING_ON)
		turn_off()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_USED_IN_CRAFT,
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_ITEM_BEFORE_PICKUP_ANIMATION,
		))
	visible_mask = null
	cone = null
	parent_attached_to = null
	return ..()

/// Called to change the value of parent_attached_to.
/datum/light_overlay/proc/set_parent_attached_to(atom/movable/new_parent_attached_to)
	if(new_parent_attached_to == parent_attached_to)
		return

	var/atom/movable/old_parent_attached_to = parent_attached_to
	parent_attached_to = new_parent_attached_to
	if(old_parent_attached_to && old_parent_attached_to != current_holder)
		UnregisterSignal(old_parent_attached_to, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))

	refresh_shared_signals()
	check_holder()

/// Called to change the value of current_holder.
/datum/light_overlay/proc/set_holder(atom/movable/new_holder)
	if(new_holder == current_holder)
		return

	var/atom/movable/old_holder = current_holder
	if(old_holder)
		if(old_holder != parent_attached_to)
			UnregisterSignal(old_holder, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
		if(directional)
			UnregisterSignal(old_holder, COMSIG_ATOM_DIR_CHANGE)
		hide_from_holder()

	current_holder = new_holder
	refresh_shared_signals()

	if(new_holder == null)
		SEND_SIGNAL(src, COMSIG_LIGHT_OVERLAY_UPDATE_HOLDER, old_holder, null)
		return

	show_to_holder()

	if(directional)
		RegisterSignal(new_holder, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_holder_dir_change))

	set_direction(new_holder.dir)
	SEND_SIGNAL(src, COMSIG_LIGHT_OVERLAY_UPDATE_HOLDER, old_holder, new_holder)

/// We have a habit of storing individual atoms under many names, which is really messy
/// We do need to DO this, but this lets us think about it less. Do this after any of the vars change or you unreg any relevant procs
/datum/light_overlay/proc/refresh_shared_signals()
	if(current_holder && !(overlay_lighting_flags & LIGHTING_ON))
		// Just to make things a bit more consistent
		UnregisterSignal(current_holder, COMSIG_MOVABLE_MOVED)

	if(parent)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved), override = TRUE)
	if(current_holder)
		RegisterSignal(current_holder, COMSIG_QDELETING, PROC_REF(on_movable_qdel), override = TRUE)
		if(overlay_lighting_flags & LIGHTING_ON)
			RegisterSignal(current_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved), override = TRUE)
	if(parent_attached_to)
		RegisterSignal(parent_attached_to, COMSIG_QDELETING, PROC_REF(on_movable_qdel), override = TRUE)
		RegisterSignal(parent_attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved), override = TRUE)

/// Used to determine the new valid current_holder from the parent's loc.
/datum/light_overlay/proc/check_holder()
	var/atom/movable/movable_parent = parent_attached_to || parent
	if(QDELETED(movable_parent))
		set_holder(null)
		return

	var/atom/inside = movable_parent.loc

	if(isnull(inside))
		set_holder(null)
		return

	if(isturf(inside))
		set_holder(movable_parent)
		return

	if(!isturf(inside.loc))
		set_holder(null)
		return

	// storage items block light, also don't be moving into a qdeleted item
	if(QDELETED(inside) || HAS_TRAIT(inside, TRAIT_BLOCKS_OVERLAY_LIGHT))
		set_holder(null)
	else
		set_holder(inside)

/datum/light_overlay/proc/on_movable_qdel(atom/movable/source, force)
	SIGNAL_HANDLER
	if(source == current_holder)
		set_holder(null)
	if(source == parent_attached_to)
		set_parent_attached_to(null)

/datum/light_overlay/proc/on_movable_moved(atom/movable/source, force)
	SIGNAL_HANDLER
	if(source == parent && (overlay_lighting_flags & LIGHTING_ATTACHED))
		set_parent_attached_to(ismovable(parent.loc) ? parent.loc : null)
	if(source == parent || source == parent_attached_to)
		check_holder()
	// For both parent and holder cases
	update_directional_light()

/datum/light_overlay/proc/on_z_move(atom/source)
	SIGNAL_HANDLER
	hide_from_holder()
	SET_PLANE_EXPLICIT(visible_mask, O_LIGHTING_VISUAL_PLANE, source)
	if(cone)
		SET_PLANE_EXPLICIT(cone, O_LIGHTING_VISUAL_PLANE, source)
	show_to_holder()

/// Called when current_holder changes loc.
/datum/light_overlay/proc/on_holder_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	set_direction(newdir)

/datum/light_overlay/proc/set_power(new_power)
	set_alpha = min(230, (abs(new_power) * 120) + 30)
	hide_from_holder()
	visible_mask.alpha = set_alpha
	visible_mask.blend_mode = new_power > 0 ? BLEND_ADD : BLEND_SUBTRACT
	if(directional)
		cone.alpha = min(120, (abs(new_power) * 60) + 15)
		cone.blend_mode = new_power > 0 ? BLEND_ADD : BLEND_SUBTRACT
	show_to_holder()

/datum/light_overlay/proc/set_color(new_color)
	hide_from_holder()
	visible_mask.color = new_color
	if(directional)
		cone.color = new_color
	show_to_holder()

/datum/light_overlay/proc/turn_on()
	if(overlay_lighting_flags & LIGHTING_ON)
		return FALSE
	overlay_lighting_flags |= LIGHTING_ON
	show_to_holder()
	if(current_holder && directional)
		cast_directional_light()
	refresh_shared_signals()
	return TRUE

/datum/light_overlay/proc/turn_off()
	if(!(overlay_lighting_flags & LIGHTING_ON))
		return FALSE
	hide_from_holder()
	overlay_lighting_flags &= ~LIGHTING_ON
	refresh_shared_signals()
	return TRUE

/datum/light_overlay/proc/set_light_render_source(new_render_source)
	hide_from_holder()
	visible_mask.render_source = new_render_source
	if(directional)
		var/new_cone_source = ""
		if(new_render_source)
			new_cone_source = "[new_render_source]_cone"
		cone.render_source = new_cone_source
	show_to_holder()

/datum/light_overlay/proc/set_range(new_range)
	if(range == new_range)
		return
	if(new_range == 0)
		turn_off()
	range = clamp(CEILING(new_range, 0.5), 1, 6)
	var/pixel_bounds = ((range - 1) * 64) + 32
	hide_from_holder()

	visible_mask.icon = light_overlays["[pixel_bounds]"]
	if(pixel_bounds == 32)
		visible_mask.transform = null
	else
		var/offset = (pixel_bounds - 32) * 0.5
		var/matrix/transform = new
		transform.Translate(-offset, -offset)
		visible_mask.transform = transform

	show_to_holder()
	if(directional)
		if(beam)
			cast_range = max(round(new_range * 0.5), 1)
		else
			cast_range = clamp(round(new_range * 0.5), 1, 3)
	update_directional_light()

/// Sets a new direction for the directional cast, then updates luminosity
/datum/light_overlay/proc/set_direction(newdir)
	if(!newdir)
		return
	if(current_direction == newdir)
		return
	current_direction = newdir
	update_directional_light(current_holder)

/datum/light_overlay/proc/update_directional_light()
	if(!isturf(current_holder?.loc) || !directional || !(overlay_lighting_flags & LIGHTING_ON))
		return
	cast_directional_light()

/// Here we append the behavior associated to changing power.
/datum/light_overlay/proc/cast_directional_light()
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

	hide_from_holder()

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

	show_to_holder()

/// Adds our overlays to our holder, assuming everything's setup proper
/datum/light_overlay/proc/show_to_holder()
	if(currently_displaying)
		return
	if(isnull(current_holder) || !(overlay_lighting_flags & LIGHTING_ON))
		currently_displaying = FALSE
		return
	current_holder.underlays += visible_mask
	if(directional)
		current_holder.underlays += cone
	currently_displaying = TRUE
	// These are very intentionally copies so recipients cannot
	// Accidentially brick lighting overlays by mutating them
	var/mutable_appearance/mask_clone = new (visible_mask)
	var/mutable_appearance/cone_clone = directional ? new /mutable_appearance(cone) : null
	SEND_SIGNAL(parent, COMSIG_ATOM_OVERLAY_LIGHT_APPLIED, mask_clone, cone_clone, current_holder)
	SEND_SIGNAL(current_holder, COMSIG_ATOM_HOLDER_OVERLAY_LIGHT_APPLIED, mask_clone, cone_clone, parent)

/// Removes our overlay from our holder, assuming everything's setup proper
/// MUST be called before modifying cone or visible_mask, or you will cause stuck lighting
/datum/light_overlay/proc/hide_from_holder()
	if(!currently_displaying)
		return
	if(isnull(current_holder) || !(overlay_lighting_flags & LIGHTING_ON))
		return
	current_holder.underlays -= visible_mask
	if(directional)
		current_holder.underlays -= cone
	currently_displaying = FALSE
	SEND_SIGNAL(parent, COMSIG_ATOM_OVERLAY_LIGHT_REMOVED, current_holder)
	SEND_SIGNAL(current_holder, COMSIG_ATOM_HOLDER_OVERLAY_LIGHT_REMOVED, parent)

/datum/light_overlay/proc/on_parent_crafted(datum/source, atom/movable/new_craft)
	SIGNAL_HANDLER

	if(!istype(new_craft))
		return

	UnregisterSignal(parent, COMSIG_ATOM_USED_IN_CRAFT)
	RegisterSignal(new_craft, COMSIG_ATOM_USED_IN_CRAFT, PROC_REF(on_parent_crafted))
	set_parent_attached_to(new_craft)

/// Avoids duplicate overlays (one from our NEXT holder, selected after the animation, one from the pickup animation)
/datum/light_overlay/proc/on_pickup_anim(atom/source)
	SIGNAL_HANDLER
	hide_from_holder()

#undef SHORT_CAST
