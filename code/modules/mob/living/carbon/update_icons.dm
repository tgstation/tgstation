//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev)
		changed++
		ntransform.TurnTo(lying_prev,lying)
		if(lying == 0) //Lying to standing
			final_pixel_y = get_standard_pixel_y_offset()
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = get_standard_pixel_y_offset()
				final_pixel_y = get_standard_pixel_y_offset(lying)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

		lying_prev = lying	//so we don't try to animate until there's been another change.
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, dir = final_dir, easing = EASE_IN|EASE_OUT)
		floating = 0  // If we were without gravity, the bouncing animation got stopped, so we make sure we restart it in next life().


/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/proc/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

/mob/living/carbon/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if (handcuffed)
		drop_r_hand()
		return
	if(r_hand)
		r_hand.screen_loc = ui_rhand
		if(client && hud_used)
			client.screen += r_hand
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		overlays_standing[R_HAND_LAYER] = image("icon" = r_hand.righthand_file, "icon_state"="[t_state]", "layer"=-R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)

/mob/living/carbon/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if (handcuffed)
		drop_l_hand()
		return
	if(l_hand)
		l_hand.screen_loc = ui_lhand
		if(client && hud_used)
			client.screen += l_hand
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		overlays_standing[L_HAND_LAYER] = image("icon" = l_hand.lefthand_file, "icon_state"="[t_state]", "layer"=-L_HAND_LAYER)

	apply_overlay(L_HAND_LAYER)

/mob/living/carbon/update_fire(var/fire_icon = "Generic_mob_burning")
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"= fire_icon, "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)

/mob/living/carbon/update_hud()
	if(client)
		client.screen |= contents
		return 1

/mob/living/carbon/regenerate_icons()
	if(notransform)
		return 1
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_fire()

/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)
	if(istype(wear_mask, /obj/item/clothing/mask))
		var/image/standing
		if(wear_mask.alternate_worn_icon)
			standing = image("icon"=wear_mask.alternate_worn_icon, "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/mask.dmi', "icon_state"="[wear_mask.icon_state]", "layer"=-FACEMASK_LAYER)

		overlays_standing[FACEMASK_LAYER]	= standing

		if(wear_mask.blood_DNA && (wear_mask.body_parts_covered & HEAD))
			standing.overlays += image("icon"='icons/effects/blood.dmi', "icon_state"="maskblood")
		return wear_mask

/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)
	if(back)
		var/image/standing
		if(back.alternate_worn_icon)
			standing = image("icon"=back.alternate_worn_icon, "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/back.dmi', "icon_state"="[back.icon_state]", "layer"=-BACK_LAYER)

		overlays_standing[BACK_LAYER] = standing
		return back


/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)
	if(head)
		var/image/standing
		if(head.alternate_worn_icon)
			standing = image("icon"=head.alternate_worn_icon, "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
		if(!standing)
			standing = image("icon"='icons/mob/head.dmi', "icon_state"="[head.icon_state]", "layer"=-HEAD_LAYER)
		standing.color = head.color // For now, this is here solely for kitty ears, but everything should do this eventually
		standing.alpha = head.alpha

		overlays_standing[HEAD_LAYER] = standing

		if(head.blood_DNA)
			standing.overlays	+= image("icon"='icons/effects/blood.dmi', "icon_state"="helmetblood")
		return head

/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()	//TODO: should be handled elsewhere
		if(hud_used)	//hud handcuff icons
			var/obj/screen/inventory/R = hud_used.r_hand_hud_object
			var/obj/screen/inventory/L = hud_used.l_hand_hud_object
			R.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="markus")
			L.overlays += image("icon"='icons/mob/screen_gen.dmi', "icon_state"="gabrielle")
		return 1
	else
		if(hud_used)
			var/obj/screen/inventory/R = hud_used.r_hand_hud_object
			var/obj/screen/inventory/L = hud_used.l_hand_hud_object
			R.overlays = null
			L.overlays = null


