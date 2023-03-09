/**
 * Apply to an action to allow it to take an item
 * and apply it as an overlay of the action button
 */
/datum/component/action_item_overlay
	/// Weakref to what item the component uses to apply as an overlay.
	var/datum/weakref/item_ref
	/// Callback that dictates what item the component uses to apply as an overlay.
	var/datum/callback/item_callback

	/// The appearance of the item we've applied
	var/mutable_appearance/item_appearance

/datum/component/action_item_overlay/Initialize(atom/movable/item, datum/callback/item_callback)
	if(!istype(parent, /datum/action))
		return COMPONENT_INCOMPATIBLE

	ASSERT(isnull(item) || istype(item))

	if(!item && !item_callback)
		stack_trace("[type] created without a reference item or an item callback - one or the other is required.")
		return COMPONENT_INCOMPATIBLE

	src.item_ref = WEAKREF(item)
	src.item_callback = item_callback

/datum/component/action_item_overlay/Destroy(force, silent)
	item_ref = null
	QDEL_NULL(item_callback)
	item_appearance = null
	return ..()

/datum/component/action_item_overlay/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ACTION_OVERLAY_APPLY, PROC_REF(on_overlays_applied))

	var/datum/action/parent_action = parent
	parent_action.build_all_button_icons(UPDATE_BUTTON_OVERLAY)

/datum/component/action_item_overlay/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ACTION_OVERLAY_APPLY)

	// If we're being unregistered / deleted but our parent is sticking around,
	// force an overlay update to get rid of our item appearance
	if(!QDELING(parent))
		var/datum/action/parent_action = parent
		parent_action.build_all_button_icons(UPDATE_BUTTON_OVERLAY)

/// Signal proc for [COMSIG_ACTION_OVERLAY_APPLY], applies the item appearance if possible.
/datum/component/action_item_overlay/proc/on_overlays_applied(datum/action/source, atom/movable/screen/movable/action_button/current_button, force)
	SIGNAL_HANDLER

	// We're in the middle of being removed / deleted, remove our associated overlay
	if(QDELING(src))
		if(item_appearance)
			current_button.cut_overlay(item_appearance)
			item_appearance = null
		return

	var/atom/movable/muse = item_callback?.Invoke() || item_ref?.resolve()
	if(!istype(muse))
		if(item_appearance) // New item does not exist but we have an old appearance
			current_button.cut_overlay(item_appearance)
			item_appearance = null
		return

	if(item_appearance)
		// For caching purposes, we will try not to update if we don't need to
		if(!force && item_appearance.icon == muse.icon && item_appearance.icon_state == muse.icon_state)
			return
		current_button.cut_overlay(item_appearance)

	var/mutable_appearance/muse_appearance = new(muse.appearance)
	muse_appearance.plane = FLOAT_PLANE
	muse_appearance.layer = FLOAT_LAYER
	muse_appearance.pixel_x = 0
	muse_appearance.pixel_y = 0

	current_button.add_overlay(muse_appearance)
	item_appearance = muse_appearance
