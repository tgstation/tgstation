var/list/icon_states_cache = list()

//has to be on living instead of carbon because of drones
/mob/living/proc/update_inv_slot_image(imageslot, suffix, imagelayer, fallback=null, main_state=null)
	var/obj/item/I = imageslot
	var/image/image_overlay


	if(!icon_states_cache[I.icon])
		icon_states_cache[I.icon] = icon_states(I.icon, 2)

	if(!fallback)
		fallback = I.item_state

	if(!main_state)
		main_state = I.icon_state

	var/target_icon = I.icon
	var/target_icon_state = main_state + suffix

	if(!(target_icon_state in icon_states_cache[I.icon]))
		target_icon_state = fallback + suffix
		if(I.item_state_icon)
			target_icon = I.item_state_icon
		if(!icon_states_cache[target_icon])
			icon_states_cache[target_icon] = icon_states(target_icon, 2)
		if(!(target_icon_state in icon_states_cache[target_icon]))
			return

	if(imagelayer)
		image_overlay = image("icon"=target_icon, "icon_state"="[target_icon_state]", "layer"=-imagelayer)
	else
		image_overlay = image("icon"=target_icon, "icon_state"="[target_icon_state]")

	return image_overlay
