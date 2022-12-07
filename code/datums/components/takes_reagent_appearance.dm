/datum/component/takes_reagent_appearance
	var/icon_pre_change
	var/icon_state_pre_change
	var/datum/callback/on_icon_changed
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

/datum/component/takes_reagent_appearance/proc/on_update_name(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	var/datum/glass_style/main_style = get_main_reagent_style()
	if(isnull(main_style))
		item_parent.name = initial(item_parent.name)
	else if(main_style.name)
		item_parent.name = main_style.name
	else
		return

	return COMSIG_ATOM_NO_UPDATE_NAME

/datum/component/takes_reagent_appearance/proc/on_update_desc(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	var/datum/glass_style/main_style = get_main_reagent_style()
	if(isnull(main_style))
		item_parent.desc = initial(item_parent.desc)
	else if(main_style.desc)
		item_parent.desc = main_style.desc
	else
		return

	return COMSIG_ATOM_NO_UPDATE_DESC

/datum/component/takes_reagent_appearance/proc/on_update_state(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	var/datum/glass_style/main_style = get_main_reagent_style()

	if(isnull(main_style))
		item_parent.icon = icon_pre_change
		item_parent.icon_state = icon_state_pre_change
		on_icon_reset?.Invoke()
	else
		if(main_style.icon)
			item_parent.icon = main_style.icon
		if(main_style.icon_state)
			item_parent.icon_state = main_style.icon_state
		on_icon_changed?.Invoke(main_style)

	return COMSIG_ATOM_NO_UPDATE_ICON_STATE

/datum/component/takes_reagent_appearance/proc/get_main_reagent_style()
	var/obj/item/item_parent = parent
	if(item_parent.reagents.total_volume <= 0)
		return null
	var/datum/reagent/main_reagent = item_parent.reagents.get_master_reagent()
	if(isnull(main_reagent))
		return null

	return GLOB.glass_style_singletons[parent.type][main_reagent.type]
