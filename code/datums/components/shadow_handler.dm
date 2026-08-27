/// Handles casting a shadow on some lower z-level
/datum/component/shadow_handler
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/**
	 * List of transparent turfs beneath the parent
	 * In order from highest to lowest
	 *
	 * When the parent moves, this entire list is recalculated for the new turf
	 * The list will never be empty, if it's empty we're casting no shadows
	 */
	VAR_PRIVATE/list/turf/tracked_transparent_turfs = list()
	/// Turf below the lowest tracked turf, it's the turf that actually gets the shadow
	VAR_PRIVATE/turf/cast_turf
	/// The actual shadow effect that we manipulate
	VAR_PRIVATE/obj/effect/abstract/shadow/shadow

	/// List of icons that are applied to the shadow as a mask, to change its shape according to the parent
	VAR_PRIVATE/list/icon/shadow_masks

	/// Base alpha for use in calculating shadow from light strength
	VAR_PRIVATE/base_alpha = 255
	/// Multiplier applied to blur intensity
	var/blur_factor = 2.0
	/// Multiplier applied to alpha of shadow
	var/alpha_factor = 1.0
	/// Multiplier applied to how much of the shadow is diminished by same-level lighting
	var/above_factor = 0.5

/datum/component/shadow_handler/Initialize(turf/start_turf, list/icon/shadow_masks)
	if(!ismovable(parent) || !SSmapping.max_plane_offset) // we shouldn't even be TRYING to make this component on non-multi-z maps
		return COMPONENT_INCOMPATIBLE

	setup_transparent_turf_stack(start_turf)
	if(!length(tracked_transparent_turfs) || isnull(cast_turf))
		return COMPONENT_REDUNDANT

	src.shadow_masks = shadow_masks
	shadow = new(cast_turf)
	update_shadow_appearance()

	// Register a bunch of signals that say
	// "hey we need to update the shadow's appearance copy"
	RegisterSignals(parent, list(
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_CARBON_APPLY_OVERLAY,
		COMSIG_CARBON_REMOVE_OVERLAY,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
	), PROC_REF(update_shadow_appearance))

	RegisterSignals(parent, list(
		COMSIG_MOVABLE_MOVED,
	), PROC_REF(refresh_transparent_turf_stack))

/datum/component/shadow_handler/Destroy()
	clear_transparent_turf_stack()
	QDEL_NULL(shadow)
	return ..()

/datum/component/shadow_handler/InheritComponent(datum/component/new_comp, i_am_original, turf/new_start_turf, list/icon/new_shadow_masks)
	for(var/i in 1 to length(shadow_masks))
		shadow.remove_filter("shadowmask[i]")

	shadow_masks = new_shadow_masks
	update_shadow_appearance()

/// Sets up the tracked_transparent_turfs list as well as finds the cast turf
/datum/component/shadow_handler/proc/setup_transparent_turf_stack(turf/start_turf)
	var/turf/next_turf = start_turf
	while(istransparentturf(next_turf))
		register_transparent_signals(next_turf)
		tracked_transparent_turfs += next_turf
		next_turf = get_step_multiz(next_turf, DOWN)

	if(!length(tracked_transparent_turfs))
		return

	var/turf/cast_on = get_step_multiz(tracked_transparent_turfs[length(tracked_transparent_turfs)], DOWN)
	if(isopenturf(cast_on))
		cast_turf = cast_on
		register_cast_signals(cast_on)
		var/atom/movable/lighting_object/to_update = cast_turf.lighting_object
		if(to_update && !to_update.needs_update)
			SSlighting.objects_queue += cast_turf.lighting_object
			to_update.needs_update = TRUE

/// Clears the list, then rebuilds the list of transparent turfs beneath the parent, and moves the shadow if necessary
/datum/component/shadow_handler/proc/refresh_transparent_turf_stack(...)
	SIGNAL_HANDLER

	var/atom/movable/parent_movable = parent
	clear_transparent_turf_stack()
	setup_transparent_turf_stack(parent_movable.loc)
	if(!length(tracked_transparent_turfs) || isnull(cast_turf))
		qdel(src)
		return

	shadow.forceMove(cast_turf)

/// Clears all tracked turfs, including the cast turf
/datum/component/shadow_handler/proc/clear_transparent_turf_stack()
	if(!isnull(cast_turf))
		var/atom/movable/lighting_object/to_update = cast_turf.lighting_object
		if(to_update && !to_update.needs_update)
			SSlighting.objects_queue += cast_turf.lighting_object
			to_update.needs_update = TRUE
		unregister_cast_signals(cast_turf)
		cast_turf = null

	for(var/turf/old_turf as anything in tracked_transparent_turfs)
		unregister_transparent_signals(old_turf)
	tracked_transparent_turfs.Cut()

/// Register relevant signals for turfs that we're projecting a shadow through
/datum/component/shadow_handler/proc/register_transparent_signals(turf/registering)
	RegisterSignal(registering, SIGNAL_REMOVETRAIT(TURF_Z_TRANSPARENT_TRAIT), PROC_REF(refresh_transparent_turf_stack))
	RegisterSignal(registering, COMSIG_LIGHTING_OBJECT_UPDATE, PROC_REF(update_shadow_alpha))

/// Unregister relevant signals for turfs that we're projecting a shadow through
/datum/component/shadow_handler/proc/unregister_transparent_signals(turf/unregistering)
	UnregisterSignal(unregistering, list(
		SIGNAL_REMOVETRAIT(TURF_Z_TRANSPARENT_TRAIT),
		COMSIG_LIGHTING_OBJECT_UPDATE,
	))

/// Register relevant signals for the turf that we're casting a shadow on
/datum/component/shadow_handler/proc/register_cast_signals(turf/registering)
	RegisterSignals(registering, list(COMSIG_TURF_CHANGE, SIGNAL_ADDTRAIT(TURF_Z_TRANSPARENT_TRAIT)), PROC_REF(refresh_transparent_turf_stack))
	RegisterSignal(registering, COMSIG_LIGHTING_OBJECT_UPDATE, PROC_REF(mask_shadow))

/// Unregister relevant signals for the turf that we're casting a shadow on
/datum/component/shadow_handler/proc/unregister_cast_signals(turf/unregistering)
	UnregisterSignal(unregistering, list(
		COMSIG_LIGHTING_OBJECT_UPDATE,
		COMSIG_TURF_CHANGE,
		SIGNAL_ADDTRAIT(TURF_Z_TRANSPARENT_TRAIT),
	))

/// Handles updating the appearance of the shadow clone to the parent's current appearance
/datum/component/shadow_handler/proc/update_shadow_appearance(...)
	SIGNAL_HANDLER

	var/z_diff = tracked_transparent_turfs[1].z - cast_turf.z
	if(!(SEND_SIGNAL(parent, COMSIG_SHADOW_UPDATED, shadow) & CUSTOM_SHADOW_APPEARANCE))
		var/mutable_appearance/copy_appearance = new(parent)
		shadow.appearance = strip_appearance_underlays(copy_appearance)
	shadow.name = "shadow of [parent]" // primarily for VV
	shadow.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	shadow.color = COLOR_BLACK
	shadow.add_filter("shadowblur", 2, gauss_blur_filter(blur_factor * z_diff))
	for(var/i in 1 to length(shadow_masks))
		shadow.add_filter("shadowmask[i]", 1, alpha_mask_filter(y = -z_diff, icon = shadow_masks[i], flags = MASK_INVERSE))
	if(shadow.layer >= TOPDOWN_LAYER)
		shadow.layer = ABOVE_NORMAL_TURF_LAYER
	SET_PLANE_IMPLICIT(shadow, SHADOW_PLANE)
	base_alpha = shadow.alpha
	update_shadow_alpha()

/// When tracked turf lighting changes we need to update the shadow's alpha
/datum/component/shadow_handler/proc/update_shadow_alpha(...)
	SIGNAL_HANDLER

	shadow.alpha = base_alpha * alpha_factor * tracked_transparent_turfs[1].get_lumcount()

/// Masks the lighting overlay of the turf onto the shadow mask plane
/// to have lighting on lower z-levels ward off the shadow effect
/datum/component/shadow_handler/proc/mask_shadow(turf/source, list/overlays_to_fill)
	SIGNAL_HANDLER

	if(length(overlays_to_fill))
		return // melbert todo : make this not conflict with itself in a less silly way

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/sw_corner = source.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/se_corner = source.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/nw_corner = source.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/ne_corner = source.lighting_corner_NE || dummy_lighting_corner

	var/sw_below = 1 - (above_factor * sw_corner.get_ratio_above())
	var/se_below = 1 - (above_factor * se_corner.get_ratio_above())
	var/nw_below = 1 - (above_factor * nw_corner.get_ratio_above())
	var/ne_below = 1 - (above_factor * ne_corner.get_ratio_above())

	var/mutable_appearance/dark_overlay = mutable_appearance(
		icon = LIGHTING_ICON,
		icon_state = null,
		offset_spokesman = source,
		plane = SHADOW_MASK_PLANE,
		appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM,
	)
	dark_overlay.color = list(
		00, 00, 00, sw_below,
		00, 00, 00, se_below,
		00, 00, 00, nw_below,
		00, 00, 00, ne_below,
		00, 00, 00, 00
	)
	overlays_to_fill += dark_overlay

/// Dummy object just for shadow mirroring
/obj/effect/abstract/shadow
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	density = FALSE
