/mob/living/silicon/robot/update_icons()
	icon = (module.cyborg_icon_override ? module.cyborg_icon_override : initial(icon))
	. = ..()
	update_dogborg_icons()

/mob/living/silicon/robot/proc/update_dogborg_icons()
	var/extra_overlay
	for(var/i in held_items)
		var/obj/item/O = i
		if(istype(O,/obj/item/gun/energy/laser/cyborg))
			extra_overlay = "laser"
			break
		if(istype(O,/obj/item/gun/energy/disabler/cyborg) || istype(O,/obj/item/gun/energy/e_gun/advtaser/cyborg))
			extra_overlay = "disabler"
			break

	if(extra_overlay)
		add_overlay(extra_overlay)

	if(stat == DEAD && module.has_snowflake_deadsprite)
		icon_state = "[module.cyborg_base_icon]-wreck"

	if(module.cyborg_pixel_offset)
		pixel_x = module.cyborg_pixel_offset

	if(module.cyborg_base_icon == "robot")
		icon = 'icons/mob/robots.dmi'
		pixel_x = initial(pixel_x)

	if(robot_resting)
		if(stat != DEAD && module.dogborg)
			switch(robot_resting)
				if(ROBOT_REST_NORMAL)
					icon_state = "[module.cyborg_base_icon]-rest"
				if(ROBOT_REST_SITTING)
					icon_state = "[module.cyborg_base_icon]-sit"
				if(ROBOT_REST_BELLY_UP)
					icon_state = "[module.cyborg_base_icon]-bellyup"
				else
					icon_state = "[module.cyborg_base_icon]"
			cut_overlays()
	else
		icon_state = "[module.cyborg_base_icon]"
	update_fire()
