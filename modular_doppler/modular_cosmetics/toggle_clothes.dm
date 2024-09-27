/datum/component/toggle_clothes
	var/toggled = FALSE
	var/toggled_icon_state

/datum/component/toggle_clothes/Initialize(toggled_icon_state)
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	if(!toggled_icon_state)
		return COMPONENT_INCOMPATIBLE

	src.toggled_icon_state = toggled_icon_state

	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(clothing_toggle))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(handle_examine))

/datum/component/toggle_clothes/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("This item is toggleable! Alt Click to toggle!")

/datum/component/toggle_clothes/proc/clothing_toggle(obj/item/clothing/source, mob/living/clicker)
	SIGNAL_HANDLER

	toggled = !toggled
	source.icon_state = (toggled ? toggled_icon_state : initial(source.icon_state))
	to_chat(clicker, "You toggle \the [source]!")
	if(source.loc == clicker)
		clicker.update_clothing(source.slot_flags)
	source.update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS
