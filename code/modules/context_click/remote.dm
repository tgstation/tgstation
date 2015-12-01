/*/////////////////////
Remotes are devices that hold buttons (/obj/item/device/remote_button) in their slots, under the buttons list var as (slot_id = button)
Remotes have procs for adding (add_button()) or removing buttons (remove_button()) to specific slots of the remote - only if buttons are set to be removable
Remotes have procs for when attack_self() is called to handle which button is pressed, calling the button's on_press()
*//////////////////////

/datum/context_click/remote_control
	var/list/buttons = list()	//assoc list - button id (set by remote) = button atom
	var/list/removable_buttons = list()	//plain list of button ids that can be taken out

	var/list/pressed = list() //list of recently pressed buttons - stops spam


//////////////////////////
/*    BUTTON CONTROL    */
//////////////////////////

//Sets the value of a button
/datum/context_click/remote_control/proc/add_button(var/obj/item/device/remote_button/button, button_id)
	if(!button || !istype(button) || !(button_id in buttons) || (buttons[button_id])) //we can't attach to that slot, or that slot is full
		return 0

	if(!can_attach_button(button, button_id))
		return 0

	buttons[button_id] = button
	button.on_remote_attach(holder, src, button_id)
	return 1

//Placeholder for filtering specific buttons on specific remote datums
/datum/context_click/remote_control/proc/can_attach_button(var/obj/item/device/remote_button/button, button_id)
	return 1

//Removes a button - returns the button removed
//Override lets you take out even unremovables
/datum/context_click/remote_control/proc/remove_button(var/button_id, var/override = 0)
	if(!(button_id in buttons))
		return 0

	if(!(button_id in removable_buttons) && !override)
		return

	var/obj/item/device/remote_button/old_button = buttons[button_id]
	if(!old_button)
		return 0

	buttons[button_id] = null
	old_button.on_remote_remove()
	return old_button

//Actually gives the button
/datum/context_click/remote_control/proc/get_button_by_id(button_id)
	if(button_id && (button_id in buttons))
		return buttons[button_id]

//Gives the pixel_x and pixel_y for a button by ud
//Returns a list of the format list("pixel_x" = a number, "pixel_y" = a number)
/datum/context_click/remote_control/proc/get_pixel_displacement(button_id)
	return list("pixel_x" = 0, "pixel_y" = 0)

//Returns the icon standard for the button in this id
//Think of this as the shape identifier - the button has to be a certain shape for every slot
/datum/context_click/remote_control/proc/get_icon_type(button_id)
	return

///////////////
////ACTIONS////
///////////////

/datum/context_click/remote_control/action(obj/item/used_item, mob/user, params)
	if(used_item)

		if(isscrewdriver(used_item)) //Button removal - click a valid button with a screwdriver to pop it out
			var/button_id = return_clicked_id_by_params(params)
			if(get_button_by_id(button_id))
				var/obj/item/device/remote_button/removed = remove_button(button_id)
				if(removed)
					to_chat(user, "You pop out \the [removed].")
					user.put_in_hands(removed)
				else
					to_chat(user, "The button doesn't seem to be removable.")
				return 1

		if(istype(used_item, /obj/item/device/remote_button))
			if(add_button(used_item, return_clicked_id_by_params(params) )) //attempt to plug the button on
				user.drop_item(used_item, holder)
				to_chat(user, "You click \the [used_item] into \the [holder].")
				return 1

	var/button_id = return_clicked_id_by_params(params)
	return press_button(button_id, user)


/////////PRESSING////////////
//Attempts to push a button

/datum/context_click/remote_control/proc/press_button(button_id, mob/user)
	if(button_id in pressed)
		return 0

	var/obj/item/device/remote_button/button = get_button_by_id(button_id)
	if(button)
		button.on_press(user)


		if(button.depression_time) //slows down button spam
			pressed |= button_id
			spawn(button.depression_time)
				pressed -= button_id

		return 1
	return 0
