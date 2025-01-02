/mob/living/silicon/robot/update_icons()
	icon = (model.cyborg_icon_override ? model.cyborg_icon_override : initial(icon))
	. = ..()
	/// Let's give custom borgs the ability to have flavor panels for their model
	if(opened && (TRAIT_R_UNIQUEPANEL in model.model_features))
		if(wiresexposed)
			add_overlay("[model.cyborg_base_icon]_w")
		else if(cell)
			add_overlay("[model.cyborg_base_icon]_c")
		else
			add_overlay("[model.cyborg_base_icon]_cl")
	update_altborg_icons()

/mob/living/silicon/robot/proc/update_altborg_icons()
	if(robot_resting)
		if(stat != DEAD && can_rest())
			switch(robot_resting)
				if(ROBOT_REST_NORMAL)
					icon_state = "[model.cyborg_base_icon]-rest"
				else
					icon_state = "[model.cyborg_base_icon]"
			cut_overlays()
			if(hat)  // Don't forget your hat
				var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20)
				head_overlay.pixel_y += (hat_offset - 14)
				add_overlay(head_overlay)
	else
		icon_state = "[model.cyborg_base_icon]"
	if((TRAIT_R_UNIQUETIP in model.model_features) && (TRAIT_IMMOBILIZED in _status_traits))
		icon_state = "[model.cyborg_base_icon]-tipped"
		if(particles)
			dissipate()
		cut_overlays()
	if(stat == DEAD && (TRAIT_R_UNIQUEWRECK in model.model_features))
		icon_state = "[model.cyborg_base_icon]-wreck"
	update_appearance(UPDATE_OVERLAYS)
