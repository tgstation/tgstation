/**
 * ## "Takes reagent appearance" Component
 *
 * Bit of a mouthful, but when applied to an item that can hold reagents (primarily reagent containers),
 * said item will take on an appearance based on the majority share reagent inside
 *
 * This is more than just "changing the color a bit" or "applies an overlay", this is
 * an entire icon / icon state / name change, making it look like a different item entirely
 *
 * This is done by cross-referencing the glass style datums. See [/datum/glass_style] for more information about that.
 *
 * An example usage is bartender mixed drinks - each reagent gets its own fancy drink sprite
 */
/datum/component/takes_reagent_appearance
	/// The type to compare against the glass_style's required_container_type. The parent's type by default.
	var/base_container_type
	/// Icon file when attached to the item
	var/icon_pre_change
	/// Icon state when attached to the item
	var/icon_state_pre_change
	/// Optional callback invoked when when the item's appearance is changed
	var/datum/callback/on_icon_changed
	/// Optional callback invoked when our item has its appearance reverted to default
	var/datum/callback/on_icon_reset

/datum/component/takes_reagent_appearance/Initialize(
	datum/callback/on_icon_changed,
	datum/callback/on_icon_reset,
	base_container_type,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent
	if(isnull(item_parent.reagents))
		return COMPONENT_INCOMPATIBLE

	icon_pre_change = item_parent.icon
	icon_state_pre_change = item_parent.base_icon_state || item_parent.icon_state

	src.on_icon_changed = on_icon_changed
	src.on_icon_reset = on_icon_reset

	src.base_container_type = base_container_type || parent.type

/datum/component/takes_reagent_appearance/Destroy()
	QDEL_NULL(on_icon_changed)
	QDEL_NULL(on_icon_reset)
	return ..()

/datum/component/takes_reagent_appearance/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(on_update_appearance))

/datum/component/takes_reagent_appearance/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_APPEARANCE)
	if(QDELING(parent))
		return

	var/obj/item/item_parent = parent
	item_parent.name = initial(item_parent.name)
	item_parent.desc = initial(item_parent.desc)
	item_parent.icon = icon_pre_change
	item_parent.icon_state = icon_state_pre_change
	on_icon_reset?.Invoke()
	item_parent.update_appearance()

/// Signal proc for [COMSIG_ATOM_UPDATE_APPEARANCE]
/// We hook into the update appearance proc to perform our own update based on our glass style
/// Preventing any further updates down the line on successes
/datum/component/takes_reagent_appearance/proc/on_update_appearance(datum/source, updates)
	SIGNAL_HANDLER

	. = NONE

	var/datum/glass_style/main_style = get_main_reagent_style()
	if(updates & UPDATE_NAME)
		. |= update_name(main_style)
	if(updates & UPDATE_DESC)
		. |= update_desc(main_style)
	if(updates & UPDATE_ICON)
		. |= update_icon(main_style)
	return .

/**
 * Performs the name update.
 *
 * * Returns [COMSIG_ATOM_NO_UPDATE_NAME] if one was complete
 * * Returns [NONE] if nothing happened
 * * Returns [NONE] if the name was reset to initial state
 */
/datum/component/takes_reagent_appearance/proc/update_name(datum/glass_style/style)
	var/obj/item/item_parent = parent
	if(isnull(style))
		// no style (reset)
		item_parent.name = initial(item_parent.name)
	else if(style.name)
		// style
		item_parent.name = style.name
		return COMSIG_ATOM_NO_UPDATE_NAME

	return NONE

/**
 * Performs the description update.
 *
 * * Returns [COMSIG_ATOM_NO_UPDATE_DESC] if one was complete
 * * Returns [NONE] if nothing happened
 * * Returns [NONE] if the description was reset to initial state
 */
/datum/component/takes_reagent_appearance/proc/update_desc(datum/glass_style/style)
	var/obj/item/item_parent = parent
	if(isnull(style))
		// no style (reset)
		item_parent.desc = initial(item_parent.desc)
	else if(style.desc)
		// style
		item_parent.desc = style.desc
		return COMSIG_ATOM_NO_UPDATE_DESC

	return NONE

/**
 * Performs the icon update.
 *
 * * Returns [COMSIG_ATOM_NO_UPDATE_ICON] if an icon or icon state ocurred
 * * Returns [NONE] if the icon or icon state was reset to base state
 */
/datum/component/takes_reagent_appearance/proc/update_icon(datum/glass_style/style)
	var/obj/item/item_parent = parent
	if(isnull(style))
		// no style (reset)
		item_parent.icon = icon_pre_change
		item_parent.icon_state = icon_state_pre_change
	else if(style.icon && style.icon_state)
		// style
		item_parent.icon = style.icon
		item_parent.icon_state = style.icon_state
		on_icon_changed?.InvokeAsync(style)
		return COMSIG_ATOM_NO_UPDATE_ICON_STATE

	// Reset gets invoked regardless, as further updates may "reset" the icon yet
	on_icon_reset?.InvokeAsync()
	return NONE

/**
 * Gets the correspinding style based on the parent's state and reagents within
 *
 * * Returns null if its reagents are empty
 * * Returns null if no majority reagent was found
 * * Otherwise returns a glass style datum
 */
/datum/component/takes_reagent_appearance/proc/get_main_reagent_style()
	RETURN_TYPE(/datum/glass_style)

	var/obj/item/item_parent = parent
	if(item_parent.reagents.total_volume <= 0)
		return null
	var/datum/reagent/main_reagent = item_parent.reagents.get_master_reagent()
	if(isnull(main_reagent))
		return null

	return GLOB.glass_style_singletons[base_container_type][main_reagent.type]
