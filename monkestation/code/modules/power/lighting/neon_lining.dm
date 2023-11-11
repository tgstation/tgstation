///this is the physical stack item of the neon lining
/obj/item/stack/neon_lining
	name = "neon lining"
	desc = "a coil of neon lining"
	singular_name = "neon lining"

	icon = 'goon/icons/obj/decals/neon_lining.dmi'
	icon_state = "item_pink"

	max_amount = 40
	merge_type = /obj/item/stack/neon_lining

	w_class = WEIGHT_CLASS_TINY
	///the color we currently are set to in icon state we set it to item_[lining_color] and placement is [lining_color]{state}_{style}
	var/lining_color = "pink"


/obj/item/stack/neon_lining/twenty
	amount = 20

/obj/item/stack/neon_lining/attack_self(mob/user, modifiers)
	. = ..()
	var/static/list/choices = list(
		"pink" = image(icon = 'goon/icons/obj/decals/neon_lining.dmi', icon_state = "item_pink"),
		"yellow" = image(icon = 'goon/icons/obj/decals/neon_lining.dmi', icon_state = "item_yellow"),
		"blue" = image(icon = 'goon/icons/obj/decals/neon_lining.dmi', icon_state = "item_blue")
	)
	var/choice_response = show_radial_menu(user, src, choices, radius = 36, require_near = TRUE)
	if(!choice_response)
		return
	lining_color = choice_response
	update_appearance()

/obj/item/stack/neon_lining/update_icon_state()
	. = ..()
	icon_state = "item_[lining_color]"

/obj/item/stack/neon_lining/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isfloorturf(target))
		return

	if(!user.Adjacent(target))
		return

	var/facing_dir = user.dir

	var/obj/machinery/light/neon_lining/new_lining = new /obj/machinery/light/neon_lining(target)
	switch(facing_dir)
		if(NORTH)
			new_lining.rotation = 2
		if(SOUTH)
			new_lining.rotation = 0
		if(EAST)
			new_lining.rotation = 3
		else
			new_lining.rotation = 1
	to_chat(user, span_notice("You lay down some neon lining on the [target]."))
	new_lining.lining_color = lining_color
	new_lining.update_appearance()
	new_lining.rebuild_lining_string()
	use(1)

///the neon lighting object itself
/obj/machinery/light/neon_lining
	name = "neon lining"
	///we convert the name into [lining_color] [base_name]
	var/base_name = "neon lining"
	desc = "some neon lining tacked to the floor."

	icon = 'goon/icons/obj/decals/neon_lining.dmi'
	icon_state = "base2"

	power_consumption_rate = 5
	use_power = NO_POWER_USE
	on = TRUE
	no_low_power = TRUE
	removable_tube = FALSE
	status = LIGHT_OK
	overlay_icon = null

	bulb_inner_range = 0.5
	bulb_outer_range = 3
	bulb_falloff = LIGHTING_DEFAULT_FALLOFF_CURVE + 0.5

	///the current rotation of the neon lining used in icon_updates choices: 0, 1, 2, 3
	var/rotation = 0
	///the current color of the lining choices: pink, blue, yellow
	var/lining_color = "pink"
	///the pattern of the light
	var/lining_pattern = 0
	///the current shape of the lining
	var/lining_shape = 2
	///the current icon state of our combined shape as we have color permutations
	var/lining_icon_state = 1
	///the built string for use in icon updates
	var/built_lining_string = "pink2_1"

/obj/machinery/light/neon_lining/update_appearance(updates)
	. = ..()
	switch(lining_color)
		if("pink")
			bulb_colour = LIGHT_COLOR_PINK
			bulb_emergency_colour = LIGHT_COLOR_PINK
			nightshift_light_color = LIGHT_COLOR_PINK
		if("blue")
			bulb_colour = LIGHT_COLOR_BLUE
			bulb_emergency_colour = LIGHT_COLOR_BLUE
			nightshift_light_color = LIGHT_COLOR_BLUE
		if("yellow")
			bulb_colour = LIGHT_COLOR_DIM_YELLOW
			bulb_emergency_colour = LIGHT_COLOR_DIM_YELLOW
			nightshift_light_color = LIGHT_COLOR_DIM_YELLOW

/obj/machinery/light/neon_lining/update_icon_state()
	. = ..()
	icon_state = built_lining_string

/obj/machinery/light/neon_lining/update_overlays()
	. = ..()
	. += emissive_appearance(icon = src.icon, icon_state = built_lining_string, offset_spokesman = src)

/obj/machinery/light/neon_lining/proc/rebuild_lining_string()
	//we setting directions first because lazy

	if(lining_pattern > 3)
		if(ISODD(lining_pattern))
			lining_icon_state = (lining_pattern - 3) / 2
		else
			lining_icon_state = ((lining_pattern - 4) / 2) + 1
	else
		if (ISODD(lining_pattern))
			lining_icon_state = (lining_pattern + 1) / 2
		else
			lining_icon_state = (lining_pattern / 2) + 1

	if(ISODD(lining_pattern))
		switch(rotation)
			if(0)
				setDir(2)
			if(1)
				setDir(8)
			if(2)
				setDir(1)
			else
				setDir(4)
	else
		switch(rotation)
			if (0)
				setDir(6)
			if (1)
				setDir(9)
			if (2)
				setDir(10)
			else
				setDir(5)

	lining_shape = clamp(lining_shape, 1, 6)

	if(lining_shape == 1)
		built_lining_string = "[lining_color]1"
	else
		built_lining_string = "[lining_color][lining_shape]_[lining_icon_state]"
	update()

/obj/machinery/light/neon_lining/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(lining_shape > 0 && lining_shape < 6)
		lining_shape++
	else
		lining_shape = 1
	update_appearance()
	rebuild_lining_string()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/light/neon_lining/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(rotation >-1 && rotation <3)
		rotation++
	else
		rotation = 0
	update_appearance()
	rebuild_lining_string()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/light/neon_lining/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(lining_pattern > -1 && lining_pattern < 7)
		lining_pattern++
	else
		lining_pattern = 0
	update_appearance()
	rebuild_lining_string()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/light/neon_lining/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	new /obj/item/stack/neon_lining(get_turf(user))
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/light/neon_lining/break_light_tube(skip_sound_and_sparks = TRUE)
	return
