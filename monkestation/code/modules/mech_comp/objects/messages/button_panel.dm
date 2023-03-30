/obj/item/mcobject/messaging/button_panel
	name = "button panel component"
	desc = ""
	icon_state = "comp_buttpanel"
	///current list of active buttons
	var/list/active_buttons = list()

/obj/item/mcobject/messaging/button_panel/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("Add Button", add_button_signal)
	MC_ADD_CONFIG("Add Button", add_button)
	MC_ADD_CONFIG("Remove Button", remove_button)

/obj/item/mcobject/messaging/button_panel/update_desc(updates)
	. = ..()
	. += "Buttons:"
	for(var/name in active_buttons)
		. += "Label: [name] Signal: [active_buttons[name]]"

/obj/item/mcobject/messaging/button_panel/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!length(active_buttons))
		return
	var/selected_button = tgui_input_list(user, "Select a button", "Button Panel", active_buttons)
	if(!selected_button)
		return

	flick("comp_buttpanel1", src)
	fire(active_buttons[selected_button])
	log_message("triggered by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/button_panel/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isturf(target))
		return

	if(!user.dropItemToGround(src))
		return
	forceMove(target)

/obj/item/mcobject/messaging/button_panel/proc/add_button(mob/user, obj/item/tool)
	var/button_label = tgui_input_text(user, "Enter the Name of the button", "Button Panel")
	if(!button_label)
		return
	var/button_signal = tgui_input_text(user, "Enter the Signal of the button", "Button Panel")
	if(!button_signal)
		return
	if(button_label in active_buttons)
		say("ERROR: There is already a button with that name!")
		return
	active_buttons |= button_label
	active_buttons[button_label] = button_signal
	update_appearance()
	return TRUE

/obj/item/mcobject/messaging/button_panel/proc/remove_button(mob/user, obj/item/tool)
	if(!length(active_buttons))
		return
	var/button_to_remove = tgui_input_list(user, "Choose a button to remove", "Button Panel", active_buttons)
	if(!button_to_remove)
		return
	active_buttons[button_to_remove] = null
	active_buttons -= button_to_remove
	return TRUE

/obj/item/mcobject/messaging/button_panel/proc/add_button_signal(datum/mcmessage/input)
	if(length(active_buttons) >= 15)
		return

	///return the input as a list
	var/input_listed = params2list(input.cmd)
	///create holders for both the signal and label of the new button
	var/new_label = ""
	var/new_signal = ""
	///check if we return true of false at the end
	var/succeeded = FALSE

	for(var/list_partition in input_listed)
		if(length(list_partition) && length(input_listed[list_partition]))
			new_label = list_partition
			new_signal = input_listed[list_partition]
			if(new_label in active_buttons)
				continue
			active_buttons |= new_label
			active_buttons[new_label] = new_signal
			succeeded = TRUE
			update_appearance()
	return succeeded
