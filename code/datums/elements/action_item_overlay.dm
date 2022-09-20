/**
 * Apply to an action to allow it to take an item
 * and apply it as an overlay of the action button
 */
/datum/component/action_item_overlay
	/// Callback that dictates what item the component uses to apply as an overlay.
	/// If not supplied, it will use the action's target var.
	var/datum/callback/item_callback
	/// Cache of our item's appearance so we don't repeat un-necessary operations
	var/mutable_appearance/item_appearance_cached

/datum/component/action_item_overlay/Initialize(datum/callback/item_callback)
	if(!istype(parent, /datum/action))
		return COMPONENT_INCOMPATIBLE

	src.item_callback = item_callback

/datum/component/action_item_overlay/Destroy(force, silent)
	QDEL_NULL(item_callback)
	item_appearance_cached = null
	return ..()

/datum/component/action_item_overlay/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ACTION_OVERLAY_APPLY, .proc/on_overlays_applied)

/datum/component/action_item_overlay/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ACTION_OVERLAY_APPLY)

/// Signal proc for [COMSIG_ACTION_OVERLAY_APPLY], applies the item appearance if possible.
/datum/component/action_item_overlay/proc/on_overlays_applied(datum/action/source, atom/movable/screen/movable/action_button/current_button, force)
	SIGNAL_HANDLER

	var/obj/item/muse = item_callback?.Invoke() || current_button.linked_action.target
	if(!istype(muse))
		return

	if(item_appearance_cached)
		if(item_appearance_cached.icon == muse.icon && item_appearance_cached.icon_state == muse.icon_state && !force)
			return
		current_button.cut_overlay(item_appearance_cached)

	COMPILE_OVERLAYS(muse)
	var/mutable_appearance/muse_appearance = new(muse.appearance)
	muse_appearance.plane = FLOAT_PLANE
	muse_appearance.layer = FLOAT_LAYER
	muse_appearance.pixel_x = 0
	muse_appearance.pixel_y = 0

	current_button.add_overlay(muse_appearance)
	item_appearance_cached = muse_appearance
