/// A list of movables that shouldn't be affected by the element, either because it'd look bad or barely perceptible
GLOBAL_LIST_INIT(immerse_ignored_movable, typecacheof(list(
	/obj/effect,
	/mob/dead,
	/obj/projectile,
)))

/// A visual element that makes movables entering the attached turfs look immersed into that turf.
/// May the gods forgive me for the bullshit you're about to witness
/datum/element/immerse
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// An association list of turfs that have this element attached and their affected contents.
	var/list/attached_turf_contents = list()

	/// A list of generated immersion masks based on object width, height and whever they're fully immersed underwater
	var/list/immersion_masks = list()
	/// An assoc list of instances of /atom/movable/immerse_mask used as abstract effect relays, because god is dead
	var/list/generated_visual_overlays = list()
	/// icon_state used as a mask by our turf
	var/mask_icon = "immerse"
	/// Alpha of the mask, to make the liquid partially transparent
	var/alpha = 180

/datum/element/immerse/Attach(turf/target, mask_icon = "immerse", alpha = 180)
	. = ..()
	if(!isturf(target) || !mask_icon)
		return ELEMENT_INCOMPATIBLE

	src.mask_icon = mask_icon
	src.alpha = alpha

	RegisterSignal(target, SIGNAL_ADDTRAIT(TRAIT_IMMERSE_STOPPED), PROC_REF(stop_immersion))
	RegisterSignal(target, SIGNAL_REMOVETRAIT(TRAIT_IMMERSE_STOPPED), PROC_REF(start_immersion))

	if(!HAS_TRAIT(target, TRAIT_IMMERSE_STOPPED))
		start_immersion(target)

/datum/element/immerse/Detach(turf/source)
	UnregisterSignal(source, list(SIGNAL_ADDTRAIT(TRAIT_IMMERSE_STOPPED), SIGNAL_REMOVETRAIT(TRAIT_IMMERSE_STOPPED)))
	if(!HAS_TRAIT(source, TRAIT_IMMERSE_STOPPED))
		stop_immersion(source)
	return ..()


/// Makes the element start affecting the turf and its contents. Called on Attach() or when TRAIT_IMMERSE_STOPPED is removed.
/datum/element/immerse/proc/start_immersion(turf/source)
	SIGNAL_HANDLER
	RegisterSignals(source, list(COMSIG_ATOM_ABSTRACT_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(on_init_or_entered))
	RegisterSignal(source, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(on_atom_exited))
	attached_turf_contents += source
	for(var/atom/movable/movable as anything in source)
		if(!(movable.flags_1 & INITIALIZED_1) || movable.invisibility >= INVISIBILITY_OBSERVER)
			continue
		on_init_or_entered(source, movable)

/// Stops the element from affecting on the turf and its contents. Called on Detach() or when TRAIT_IMMERSE_STOPPED is added.
/datum/element/immerse/proc/stop_immersion(turf/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_ATOM_ABSTRACT_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_ABSTRACT_EXITED))
	for(var/atom/movable/movable as anything in attached_turf_contents[source])
		remove_from_element(source, movable)
	attached_turf_contents -= source

/**
 * If the movable is within the right layers and planes, not in the list of movable types to ignore,
 * or already affected by the element for that matter, signals will be registered and,
 * unless the movable is flying, it'll appear as if immersed in that water.
 */
/datum/element/immerse/proc/on_init_or_entered(turf/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(QDELETED(movable))
		return
	if(HAS_TRAIT(movable, TRAIT_IMMERSED) || HAS_TRAIT(movable, TRAIT_WALLMOUNTED))
		return
	if(!ISINRANGE(PLANE_TO_TRUE(movable.plane), FLOOR_PLANE, GAME_PLANE))
		return

	// First, floor plane objects use TOPDOWN_LAYER, second this check shouldn't apply to them anyway.
	var/layer_to_check = IS_TOPDOWN_PLANE(source.plane) ? TOPDOWN_ABOVE_WATER_LAYER : ABOVE_ALL_MOB_LAYER
	if(movable.layer >= layer_to_check)
		return
	if(is_type_in_typecache(movable, GLOB.immerse_ignored_movable))
		return

	var/atom/movable/buckled = null
	if(isliving(movable))
		var/mob/living/living_mob = movable
		buckled = living_mob.buckled
		RegisterSignal(living_mob, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled))
		RegisterSignal(living_mob, COMSIG_LIVING_UPDATE_OFFSETS, PROC_REF(on_update_offsets))
		RegisterSignal(movable, COMSIG_LIVING_POST_UPDATE_TRANSFORM, PROC_REF(on_update_transform))

	RegisterSignal(movable, COMSIG_ATOM_SPIN_ANIMATION, PROC_REF(on_spin_animation))
	RegisterSignal(movable, COMSIG_QDELETING, PROC_REF(on_movable_qdel))
	try_immerse(movable, buckled)
	LAZYADD(attached_turf_contents[source], movable)
	ADD_TRAIT(movable, TRAIT_IMMERSED, ELEMENT_TRAIT(src))

/datum/element/immerse/proc/on_movable_qdel(atom/movable/source)
	SIGNAL_HANDLER
	remove_from_element(source.loc, source)

/**
 * Called by init_or_entered() and on_set_buckled().
 * This applies the overlay if neither the movable or whatever is buckled to (exclusive to living mobs) are flying
 * as well as movetype signals when the movable isn't buckled.
 */
/datum/element/immerse/proc/try_immerse(atom/movable/movable, atom/movable/buckled)
	var/atom/movable/to_check = buckled || movable
	if(!(to_check.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && !movable.throwing)
		add_immerse_overlay(movable)
	if(buckled)
		return
	RegisterSignal(movable, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_move_flag_enabled))
	RegisterSignal(movable, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_move_flag_disabled))
	RegisterSignal(movable, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_throw))
	RegisterSignal(movable, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_throw_landed))

/// Called by on_set_buckled() and remove_from_element().
/// This removes the filter and signals from the movable unless it doesn't have them.
/datum/element/immerse/proc/try_unimmerse(atom/movable/movable, atom/movable/buckled)
	var/atom/movable/to_check = buckled || movable
	if(!(to_check.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && !movable.throwing)
		remove_immerse_overlay(movable)
	if(buckled)
		return
	UnregisterSignal(movable, list(
		COMSIG_MOVETYPE_FLAG_ENABLED,
		COMSIG_MOVETYPE_FLAG_DISABLED,
		COMSIG_MOVABLE_POST_THROW,
		COMSIG_MOVABLE_THROW_LANDED
	))

/datum/element/immerse/proc/on_set_buckled(mob/living/source, atom/movable/new_buckled)
	SIGNAL_HANDLER
	try_unimmerse(source, source.buckled)
	try_immerse(source, new_buckled)

/// Removes the overlay from mob and bucklees is flying.
/datum/element/immerse/proc/on_move_flag_enabled(atom/movable/source, flag, old_movement_type)
	SIGNAL_HANDLER
	if(!(flag & MOVETYPES_NOT_TOUCHING_GROUND) || (old_movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || source.throwing)
		return
	remove_immerse_overlay(source)
	for(var/mob/living/buckled_mob as anything in source.buckled_mobs)
		remove_immerse_overlay(buckled_mob)

/// Works just like on_move_flag_enabled, except it only has to check that movable isn't flying
/datum/element/immerse/proc/on_throw(atom/movable/source)
	SIGNAL_HANDLER
	if(source.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return
	remove_immerse_overlay(source)
	for(var/mob/living/buckled_mob as anything in source.buckled_mobs)
		remove_immerse_overlay(buckled_mob)

/// Readds the overlay to the mob and bucklees if no longer flying.
/datum/element/immerse/proc/on_move_flag_disabled(atom/movable/source, flag, old_movement_type)
	SIGNAL_HANDLER
	if(!(flag & MOVETYPES_NOT_TOUCHING_GROUND) || (source.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || source.throwing)
		return
	add_immerse_overlay(source)
	for(var/mob/living/buckled_mob as anything in source.buckled_mobs)
		add_immerse_overlay(buckled_mob)

/// Works just like on_move_flag_disabled, except it only has to check that movable isn't flying
/datum/element/immerse/proc/on_throw_landed(atom/movable/source)
	SIGNAL_HANDLER
	if(source.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return
	add_immerse_overlay(source)
	for(var/mob/living/buckled_mob as anything in source.buckled_mobs)
		add_immerse_overlay(buckled_mob)

/// Called when a movable exits the turf. If its new location is not in the list of turfs with this element,
/// remove the movable from the element.
/datum/element/immerse/proc/on_atom_exited(turf/source, atom/movable/exited, direction)
	SIGNAL_HANDLER
	if(!attached_turf_contents[exited.loc])
		remove_from_element(source, exited)
		return
	LAZYREMOVE(attached_turf_contents[source], exited)
	LAZYADD(attached_turf_contents[exited.loc], exited)

//// Remove any signal, overlay, trait given to the movable and reference to it within the element.
/datum/element/immerse/proc/remove_from_element(turf/source, atom/movable/movable)
	var/atom/movable/buckled = null
	if(isliving(movable))
		var/mob/living/living_mob = movable
		buckled = living_mob.buckled

	try_unimmerse(movable, buckled)
	LAZYREMOVE(attached_turf_contents[source], movable)
	UnregisterSignal(movable, list(COMSIG_LIVING_SET_BUCKLED, COMSIG_QDELETING, COMSIG_LIVING_UPDATE_OFFSETS, COMSIG_ATOM_SPIN_ANIMATION, COMSIG_LIVING_POST_UPDATE_TRANSFORM))
	REMOVE_TRAIT(movable, TRAIT_IMMERSED, ELEMENT_TRAIT(src))

/// Generate a mask filter mutable to use as render_source for the alpha filter based on provided width, height and immersion state
/datum/element/immerse/proc/generate_immerse_mask(width, height, is_below_water)
	var/clean_height = height
	width = ceil(width / ICON_SIZE_X) * ICON_SIZE_X
	height = ceil(height / ICON_SIZE_Y) * ICON_SIZE_Y

	var/mask_key = "[width]-[height]-[is_below_water]"
	var/mutable_appearance/target_mask = immersion_masks[mask_key]
	if (target_mask)
		return target_mask

	if (width == ICON_SIZE_X && height == ICON_SIZE_Y)
		target_mask = mutable_appearance('icons/effects/effects.dmi', mask_icon, alpha = alpha)
		immersion_masks[mask_key] = target_mask
		return target_mask

	var/icon/column_icon = icon('icons/effects/effects.dmi', mask_icon)
	var/y_tiles = 1
	if (height != ICON_SIZE_Y)
		column_icon.Crop(1, 1, ICON_SIZE_X, ICON_SIZE_Y) // Use base icon and crop it out so animation frames respect dmi's delays
		y_tiles = ceil((height / ICON_SIZE_Y - 1) / 2) + 1
		column_icon.Scale(ICON_SIZE_X, y_tiles * ICON_SIZE_Y)
		var/icon/effect_icon = icon('icons/effects/effects.dmi', mask_icon)
		var/icon/fill_icon = icon('icons/effects/alphacolors.dmi', "white")
		for (var/y_tile in 1 to y_tiles - 1)
			column_icon.Blend(fill_icon, ICON_OVERLAY, 1, 1 + (y_tile - 1) * ICON_SIZE_Y)
		column_icon.Blend(effect_icon, ICON_OVERLAY, 1, 1 + (y_tiles - 1) * ICON_SIZE_Y)

	var/icon/immerse_icon = null
	if (width == ICON_SIZE_X)
		immerse_icon = column_icon
	else
		immerse_icon = icon('icons/effects/effects.dmi', mask_icon) // Use base icon and crop it out so animation frames respect dmi's delays
		immerse_icon.Crop(1, 1, ICON_SIZE_X, ICON_SIZE_Y)
		immerse_icon.Scale(ceil(width / ICON_SIZE_X) * ICON_SIZE_X, ceil(height / ICON_SIZE_Y) * ICON_SIZE_Y)
		for (var/x_tile in 1 to ceil(width / ICON_SIZE_X))
			immerse_icon.Blend(column_icon, ICON_OVERLAY, 1 + (x_tile - 1) * ICON_SIZE_X, 1)
	target_mask = mutable_appearance(immerse_icon)
	target_mask.alpha = alpha
	target_mask.pixel_y = -(y_tiles - 1) * ICON_SIZE_Y + floor((clean_height - ICON_SIZE_Y) / 2)
	immersion_masks[mask_key] = target_mask
	return target_mask

/datum/element/immerse/proc/add_immerse_overlay(atom/movable/movable)
	// This determines if the overlay should cover the entire surface of the object or not
	var/layer_to_check = IS_TOPDOWN_PLANE(movable.plane) ? TOPDOWN_WATER_LEVEL_LAYER : WATER_LEVEL_LAYER
	var/is_below_water = (movable.layer < layer_to_check) ? "underwater-" : ""
	// Tall mobs still only get covered to their feet, unless they're offset down
	var/mutable_appearance/immerse_mask = generate_immerse_mask(movable.get_cached_width(), max(ICON_SIZE_Y - movable.pixel_z, ICON_SIZE_Y), is_below_water)
	var/atom/movable/immerse_mask/effect_relay = generated_visual_overlays[movable]
	if (!effect_relay)
		effect_relay = new(movable)
		movable.vis_contents += effect_relay
		generated_visual_overlays[movable] = effect_relay
	var/mutable_appearance/mask_copy = new(immerse_mask)
	effect_relay.appearance = mask_copy
	effect_relay.render_target = "*immerse_[REF(movable)]"
	SEND_SIGNAL(movable, COMSIG_MOVABLE_EDIT_UNIQUE_IMMERSE_OVERLAY, effect_relay)
	// Should always render above any other filters that could be adding visuals
	movable.add_filter("immerse_mask", INFINITY, alpha_mask_filter(y = -floor((movable.get_cached_height() - ICON_SIZE_Y) / 2) - movable.pixel_z, render_source = effect_relay.render_target, flags = MASK_INVERSE))

/datum/element/immerse/proc/remove_immerse_overlay(atom/movable/movable, deleting = TRUE)
	movable.remove_filter("immerse_mask")
	if (!deleting)
		return
	var/atom/movable/immerse_mask/mask = generated_visual_overlays[movable]
	movable.vis_contents -= mask
	generated_visual_overlays -= movable
	QDEL_NULL(mask)

/// A band-aid to keep the (unique) visual overlay from scaling and rotating along with its owner. I'm sorry.
/datum/element/immerse/proc/on_update_transform(mob/living/source, resize, new_lying_angle, is_opposite_angle)
	SIGNAL_HANDLER
	var/matrix/new_transform = matrix()
	new_transform.Scale(1 / source.current_size)
	new_transform.Turn(-new_lying_angle)
	var/atom/movable/immerse_mask/effect_relay = generated_visual_overlays[source]
	var/mutable_appearance/relay_appearance = new(effect_relay.appearance)
	relay_appearance.transform = new_transform
	effect_relay.appearance = relay_appearance

/// Spin the overlay in the opposite direction so it doesn't look like it's spinning at all.
/datum/element/immerse/proc/on_spin_animation(atom/source, speed, loops, segments, segment)
	SIGNAL_HANDLER
	var/atom/movable/immerse_mask/immerse_mask = generated_visual_overlays[source]
	immerse_mask.do_spin_animation(speed, loops, segments, -segment)

/datum/element/immerse/proc/on_update_offsets(mob/living/source, new_x, new_y, new_w, new_z, animate)
	SIGNAL_HANDLER
	var/old_height = ceil(max(ICON_SIZE_Y - source.pixel_z, ICON_SIZE_Y) / ICON_SIZE_Y)
	var/new_height = ceil(max(ICON_SIZE_Y - new_z, ICON_SIZE_Y) / ICON_SIZE_Y)
	if (old_height != new_height)
		remove_immerse_overlay(source, FALSE)
		add_immerse_overlay(source)

	if (source.pixel_z == new_z)
		return

	if (animate)
		source.transition_filter("immerse_mask", list("y" = -floor((source.get_cached_height() - ICON_SIZE_Y) / 2) - new_z), time = UPDATE_TRANSFORM_ANIMATION_TIME)
	else
		source.modify_filter("immerse_mask", list("y" = -floor((source.get_cached_height() - ICON_SIZE_Y) / 2) - new_z))

/atom/movable/immerse_mask
	appearance_flags = RESET_TRANSFORM|RESET_COLOR|RESET_ALPHA|KEEP_APART
	vis_flags = VIS_HIDE
