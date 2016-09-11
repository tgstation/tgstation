//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev && rotate_on_lying)
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
		add_overlay(I)

/mob/living/carbon/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null


/mob/living/carbon/regenerate_icons()
	if(notransform)
		return 1
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_fire()


/mob/living/carbon/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if (handcuffed)
		drop_r_hand()
		return
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand
			if(observers && observers.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += r_hand
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break


		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state

		var/image/standing = r_hand.build_worn_icon(state = t_state, default_layer = R_HAND_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		overlays_standing[R_HAND_LAYER] = standing

	apply_overlay(R_HAND_LAYER)

/mob/living/carbon/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(handcuffed)
		drop_l_hand()
		return
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand
			if(observers && observers.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += l_hand
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state

		var/image/standing = l_hand.build_worn_icon(state = t_state, default_layer = L_HAND_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		overlays_standing[L_HAND_LAYER] = standing

	apply_overlay(L_HAND_LAYER)

/mob/living/carbon/update_fire(var/fire_icon = "Generic_mob_burning")
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"= fire_icon, "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)



/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/image/standing	= image("icon"='icons/mob/dam_mob.dmi', "icon_state"="blank", "layer"=-DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER]	= standing

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.dmg_overlay_type)
			if(BP.brutestate)
				standing.overlays	+= "[BP.dmg_overlay_type]_[BP.body_zone]_[BP.brutestate]0"	//we're adding icon_states of the base image as overlays
			if(BP.burnstate)
				standing.overlays	+= "[BP.dmg_overlay_type]_[BP.body_zone]_0[BP.burnstate]"

	apply_overlay(DAMAGE_LAYER)


/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart("head")) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[slot_wear_mask])
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_wear_mask]
		inv.update_icon()

	if(wear_mask)
		if(!(head && (head.flags_inv & HIDEMASK)))
			var/image/standing = wear_mask.build_worn_icon(state = wear_mask.icon_state, default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/mask.dmi')
			overlays_standing[FACEMASK_LAYER] = standing
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)


/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used && hud_used.inv_slots[slot_back])
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_back]
		inv.update_icon()

	if(back)
		var/image/standing = back.build_worn_icon(state = back.icon_state, default_layer = BACK_LAYER, default_icon_file = 'icons/mob/back.dmi')
		overlays_standing[BACK_LAYER] = standing
		update_hud_back(back)
	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart("head")) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[slot_back])
		var/obj/screen/inventory/inv = hud_used.inv_slots[slot_head]
		inv.update_icon()

	if(head)
		var/image/standing = head.build_worn_icon(state = head.icon_state, default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/head.dmi')
		overlays_standing[HEAD_LAYER] = standing
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER] = image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
		apply_overlay(HANDCUFF_LAYER)


//mob HUD updates for items in our inventory

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hud_handcuffed()
	if(hud_used)
		var/obj/screen/inventory/R = hud_used.inv_slots[slot_r_hand]
		if(R)
			R.update_icon()
		var/obj/screen/inventory/L = hud_used.inv_slots[slot_l_hand]
		if(L)
			L.update_icon()

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return



//Overlays for the worn overlay so you can overlay while you overlay
//eg: ammo counters, primed grenade flashing, etc.
/obj/item/proc/worn_overlays(isinhands = FALSE)
	. = list()


/mob/living/carbon/update_body()
	update_body_parts()

/mob/living/carbon/proc/update_body_parts()
	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return

	remove_overlay(BODYPARTS_LAYER)

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(!BP.no_update)
			BP.update_limb()

	//LOAD ICONS
	if(limb_icon_cache[icon_render_key])
		load_limb_from_cache()
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		var/image/temp = BP.get_limb_icon()
		if(temp)
			new_limbs += temp
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()



/////////////////////
// Limb Icon Cache //
/////////////////////
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- skin_tone (if applicable)
	- gender
	- limbs (stores as the limb name and whether it is removed/fine, organic/robotic)
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste
	See RemieRichards on irc.rizon.net #coderbus
*/

var/global/list/limb_icon_cache = list()

/mob/living/carbon
	var/icon_render_key = ""


//produces a key based on the mob's limbs

/mob/living/carbon/proc/generate_icon_render_key()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.animal_origin)
			. += "-[BP.animal_origin]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"

	if(disabilities & HUSK)
		. += "-husk"


//change the mob's icon to the one matching its key
/mob/living/carbon/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()
