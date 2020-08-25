
/////////////////
//DRONE VISUALS//
/////////////////
//Drone overlays
//Drone visuals


/mob/living/simple_animal/drone/proc/apply_overlay(cache_index)
	if((. = drone_overlays[cache_index]))
		add_overlay(.)


/mob/living/simple_animal/drone/proc/remove_overlay(cache_index)
	var/I = drone_overlays[cache_index]
	if(I)
		cut_overlay(I)
		drone_overlays[cache_index] = null


/mob/living/simple_animal/drone/update_inv_hands()
	remove_overlay(DRONE_HANDS_LAYER)
	var/list/hands_overlays = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	var/y_shift = getItemPixelShiftY()

	if(r_hand)
		var/mutable_appearance/r_hand_overlay = r_hand.build_worn_icon(default_layer = DRONE_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		if(y_shift)
			r_hand_overlay.pixel_y += y_shift

		hands_overlays += r_hand_overlay

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)
		var/mutable_appearance/l_hand_overlay = l_hand.build_worn_icon(default_layer = DRONE_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		if(y_shift)
			l_hand_overlay.pixel_y += y_shift

		hands_overlays += l_hand_overlay

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand


	if(hands_overlays.len)
		drone_overlays[DRONE_HANDS_LAYER] = hands_overlays
	apply_overlay(DRONE_HANDS_LAYER)


/mob/living/simple_animal/drone/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage


/mob/living/simple_animal/drone/update_inv_head()
	remove_overlay(DRONE_HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			head.screen_loc = ui_drone_head
			client.screen += head
		var/used_head_icon = 'icons/mob/clothing/head.dmi'
		if(istype(head, /obj/item/clothing/mask))
			used_head_icon = 'icons/mob/clothing/mask.dmi'
		var/mutable_appearance/head_overlay = head.build_worn_icon(default_layer = DRONE_HEAD_LAYER, default_icon_file = used_head_icon)
		head_overlay.pixel_y -= 15

		drone_overlays[DRONE_HEAD_LAYER] = head_overlay

	apply_overlay(DRONE_HEAD_LAYER)

/mob/living/simple_animal/drone/update_inv_wear_mask()
	update_inv_head()

/mob/living/simple_animal/drone/regenerate_icons()
	// Drones only have 4 slots, which in this specific instance
	// is a small blessing.
	update_inv_hands()
	update_inv_head()
	update_inv_internal_storage()

/**
  * Prompt for usr to pick [/mob/living/simple_animal/drone/var/visualAppearance]
  *
  * Does nothing if there is no usr
  *
  * Called on [/mob/proc/Login]
  */
/mob/living/simple_animal/drone/proc/pickVisualAppearance()
	picked = FALSE
	var/list/drone_icons = list(
		"Maintenance Drone" = image(icon = 'icons/mob/drone.dmi', icon_state = "[MAINTDRONE]_grey"),
		"Repair Drone" = image(icon = 'icons/mob/drone.dmi', icon_state = REPAIRDRONE),
		"Scout Drone" = image(icon = 'icons/mob/drone.dmi', icon_state = SCOUTDRONE)
		)
	var/picked_icon = show_radial_menu(src, src, drone_icons, custom_check = CALLBACK(src, .proc/check_menu), radius = 38, require_near = TRUE)
	switch(picked_icon)
		if("Maintenance Drone")
			visualAppearance = MAINTDRONE
			var/list/drone_colors = list(
				"blue" = image(icon = 'icons/mob/drone.dmi', icon_state = "[visualAppearance]_blue"),
				"green" = image(icon = 'icons/mob/drone.dmi', icon_state = "[visualAppearance]_green"),
				"grey" = image(icon = 'icons/mob/drone.dmi', icon_state = "[visualAppearance]_grey"),
				"orange" = image(icon = 'icons/mob/drone.dmi', icon_state = "[visualAppearance]_orange"),
				"pink" = image(icon = 'icons/mob/drone.dmi', icon_state = "[visualAppearance]_pink"),
				"red" = image(icon = 'icons/mob/drone.dmi', icon_state = "[visualAppearance]_red")
				)
			var/picked_color = show_radial_menu(src, src, drone_colors, custom_check = CALLBACK(src, .proc/check_menu), radius = 38, require_near = TRUE)
			if(picked_color)
				icon_state = "[visualAppearance]_[picked_color]"
				icon_living = "[visualAppearance]_[picked_color]"
			else
				icon_state = "[visualAppearance]_grey"
				icon_living = "[visualAppearance]_grey"
		if("Repair Drone")
			visualAppearance = REPAIRDRONE
			icon_state = visualAppearance
			icon_living = visualAppearance
		if("Scout Drone")
			visualAppearance = SCOUTDRONE
			icon_state = visualAppearance
			icon_living = visualAppearance
		else
			visualAppearance = MAINTDRONE
			icon_state = "[visualAppearance]_grey"
			icon_living = "[visualAppearance]_grey"
	icon_dead = "[visualAppearance]_dead"
	picked = TRUE

/**
  * check_menu: Checks if we are allowed to interact with a radial menu
  */
/mob/living/simple_animal/drone/proc/check_menu()
	if(!istype(src))
		return FALSE
	if(incapacitated())
		return FALSE
	return TRUE

/mob/living/simple_animal/drone/proc/getItemPixelShiftY()
	switch(visualAppearance)
		if(MAINTDRONE)
			. = 0
		if(REPAIRDRONE,SCOUTDRONE,CLOCKDRONE)
			. = -6
