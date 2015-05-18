/obj/item/device/remote_button
	name = "remote button"
	desc = "A nondescript button used in remotes fitting the RC26 standard."

	icon = 'icons/obj/remote_buttons.dmi'
	icon_state = ""
	var/base_state = ""

	var/datum/context_click/remote_control/controller
	var/obj/item/holder

	var/image/button_icon

	w_class = 1

	var/depression_time = 5 //0.5 seconds between clicks

/obj/item/device/remote_button/New()
	..()
	base_state = icon_state
	button_icon = image(src.icon)

/obj/item/device/remote_button/update_icon(button_id = 0)
	if(holder)
		holder.overlays -= button_icon

	if(holder && loc == holder && button_id)
		var/icon_type = controller.get_icon_type(button_id)
		var/list/pixel_dis = controller.get_pixel_displacement(button_id)
		button_icon.icon_state = "[base_state][icon_type]"
		button_icon.pixel_x = pixel_dis["pixel_x"]
		button_icon.pixel_y = pixel_dis["pixel_y"]
		holder.overlays += button_icon
	else
		button_icon.icon_state = base_state
		button_icon.pixel_x = 0
		button_icon.pixel_y = 0


/obj/item/device/remote_button/proc/on_remote_attach(var/obj/item/new_holder, var/datum/context_click/remote_control/new_controller, button_id)
	controller = new_controller
	holder = new_holder
	loc = new_holder
	update_icon(button_id)

/obj/item/device/remote_button/proc/on_remote_remove()
	update_icon()
	controller = null
	holder = null

/obj/item/device/remote_button/proc/on_press(mob/user)
	return
