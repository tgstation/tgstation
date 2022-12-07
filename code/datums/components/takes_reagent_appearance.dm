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

/datum/component/takes_reagent_appearance/Destroy()
	QDEL_NULL(on_icon_changed)
	QDEL_NULL(on_icon_reset)
	return ..()

/datum/component/takes_reagent_appearance/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_NAME, PROC_REF(on_update_name))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_DESC, PROC_REF(on_update_desc))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_state))

/datum/component/takes_reagent_appearance/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_UPDATE_NAME, COMSIG_ATOM_UPDATE_DESC, COMSIG_ATOM_UPDATE_ICON_STATE))

	var/obj/item/item_parent = parent
	item_parent.name = initial(item_parent.name)
	item_parent.desc = initial(item_parent.desc)
	item_parent.icon = icon_pre_change
	item_parent.icon_state = icon_state_pre_change
	on_icon_reset?.Invoke()

/// Signal proc for [COMSIG_ATOM_UPDATE_NAME] to update the name to our style
/datum/component/takes_reagent_appearance/proc/on_update_name(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	var/datum/glass_style/main_style = get_main_reagent_style()
	if(isnull(main_style))
		// no style (reset)
		item_parent.name = initial(item_parent.name)
	else if(main_style.name)
		// style
		item_parent.name = main_style.name
	else
		// style but no name
		return

	// We did everything thank you
	return COMSIG_ATOM_NO_UPDATE_NAME

/// Signal proc for [COMSIG_ATOM_UPDATE_DESC] to update the description to our style
/datum/component/takes_reagent_appearance/proc/on_update_desc(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	var/datum/glass_style/main_style = get_main_reagent_style()
	if(isnull(main_style))
		// no style (reset)
		item_parent.desc = initial(item_parent.desc)
	else if(main_style.desc)
		// style
		item_parent.desc = main_style.desc
	else
		// style but no desc
		return

	// We did everything thank you
	return COMSIG_ATOM_NO_UPDATE_DESC

/// Signal proc for [COMSIG_ATOM_UPDATE_ICON_STATE] to update the icon and icon state to our style
/datum/component/takes_reagent_appearance/proc/on_update_state(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	var/datum/glass_style/main_style = get_main_reagent_style()

	if(isnull(main_style))
		// no style (reset)
		item_parent.icon = icon_pre_change
		item_parent.icon_state = icon_state_pre_change
		on_icon_reset?.Invoke()
	else
		// style
		if(main_style.icon)
			item_parent.icon = main_style.icon
		if(main_style.icon_state)
			item_parent.icon_state = main_style.icon_state
		on_icon_changed?.Invoke(main_style)

	// We did everything thank you
	return COMSIG_ATOM_NO_UPDATE_ICON_STATE

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

	return GLOB.glass_style_singletons[parent.type][main_reagent.type]
