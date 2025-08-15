// Drone overlays and visuals

/mob/living/basic/drone/proc/apply_overlay(cache_index)
	if((. = drone_overlays[cache_index]))
		add_overlay(.)


/mob/living/basic/drone/proc/remove_overlay(cache_index)
	var/overlay = drone_overlays[cache_index]
	if(overlay)
		cut_overlay(overlay)
		drone_overlays[cache_index] = null

/mob/living/basic/drone/update_clothing(slot_flags)
	if(slot_flags & ITEM_SLOT_HEAD)
		update_worn_head()
	if(slot_flags & ITEM_SLOT_MASK)
		update_worn_mask()
	if(slot_flags & ITEM_SLOT_HANDS)
		update_held_items()
	if(slot_flags & (ITEM_SLOT_HANDS|ITEM_SLOT_DEX_STORAGE))
		update_inv_internal_storage()

/mob/living/basic/drone/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used?.hud_shown)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage


/mob/living/basic/drone/update_worn_head(update_obscured = TRUE)
	remove_overlay(DRONE_HEAD_LAYER)

	if(head)
		if(client && hud_used?.hud_shown)
			head.screen_loc = ui_drone_head
			client.screen += head
		var/used_head_icon = 'icons/mob/clothing/head/utility.dmi'
		if(istype(head, /obj/item/clothing/mask))
			used_head_icon = 'icons/mob/clothing/mask.dmi'
		var/mutable_appearance/head_overlay = head.build_worn_icon(default_layer = DRONE_HEAD_LAYER, default_icon_file = used_head_icon)
		head_overlay.pixel_z -= 15

		drone_overlays[DRONE_HEAD_LAYER] = head_overlay

	apply_overlay(DRONE_HEAD_LAYER)

/mob/living/basic/drone/update_worn_mask(update_obscured = TRUE)
	update_worn_head()

/mob/living/basic/drone/regenerate_icons()
	// Drones only have 4 slots, which in this specific instance
	// is a small blessing.
	update_held_items()
	update_worn_head()
	update_inv_internal_storage()

/**
 * Prompt for user to pick [/mob/living/basic/drone/var/visualAppearance]
 *
 * Does nothing if there is no user
 *
 * Called on [/mob/proc/Login]
 */
/mob/living/basic/drone/proc/pickVisualAppearance()
	picked = FALSE
	var/list/drone_icons = list(
		"Maintenance Drone" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[MAINTDRONE]_grey"),
		"Repair Drone" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = REPAIRDRONE),
		"Scout Drone" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = SCOUTDRONE)
		)
	var/picked_icon = show_radial_menu(src, src, drone_icons, custom_check = CALLBACK(src, PROC_REF(check_menu)), radius = 38, require_near = TRUE)
	switch(picked_icon)
		if("Maintenance Drone")
			visualAppearance = MAINTDRONE
			var/list/drone_colors = list(
				"blue" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[visualAppearance]_blue"),
				"green" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[visualAppearance]_green"),
				"grey" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[visualAppearance]_grey"),
				"orange" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[visualAppearance]_orange"),
				"pink" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[visualAppearance]_pink"),
				"red" = image(icon = 'icons/mob/silicon/drone.dmi', icon_state = "[visualAppearance]_red")
				)
			var/picked_color = show_radial_menu(src, src, drone_colors, custom_check = CALLBACK(src, PROC_REF(check_menu)), radius = 38, require_near = TRUE)
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
/mob/living/basic/drone/proc/check_menu()
	if(!istype(src))
		return FALSE
	if(incapacitated)
		return FALSE
	return TRUE

/mob/living/basic/drone/proc/getItemPixelShiftY()
	switch(visualAppearance)
		if(MAINTDRONE)
			. = 0
		if(REPAIRDRONE,SCOUTDRONE,CLOCKDRONE)
			. = -6
