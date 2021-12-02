/area
	luminosity = 1
	///The mutable appearance we underlay to show light
	var/mutable_appearance/lighting_effect = null
	///Whether this area has a currently active base lighting, bool
	var/area_has_base_lighting = FALSE
	///alpha 0-255 of lighting_effect and thus baselighting intensity
	var/base_lighting_alpha = 0
	///The colour of the light acting on this area
	var/base_lighting_color = COLOR_WHITE

/area/proc/set_base_lighting(new_base_lighting_color = -1, new_alpha = -1)
	if(base_lighting_alpha == new_alpha && base_lighting_color == new_base_lighting_color)
		return FALSE
	if(new_alpha != -1)
		base_lighting_alpha = new_alpha
	if(new_base_lighting_color != -1)
		base_lighting_color = new_base_lighting_color
	update_base_lighting()
	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("base_lighting_color")
			set_base_lighting(new_base_lighting_color = var_value)
			return TRUE
		if("base_lighting_alpha")
			set_base_lighting(new_alpha = var_value)
			return TRUE
		if("static_lighting")
			if(!static_lighting)
				create_area_lighting_objects()
			else
				remove_area_lighting_objects()

	return ..()

/area/proc/update_base_lighting()
	if(!area_has_base_lighting && (!base_lighting_alpha || !base_lighting_color))
		return

	if(!area_has_base_lighting)
		add_base_lighting()
		return
	remove_base_lighting()
	if(base_lighting_alpha && base_lighting_color)
		add_base_lighting()

/area/proc/remove_base_lighting()
	for(var/turf/T in src)
		T.cut_overlay(lighting_effect)
	QDEL_NULL(lighting_effect)
	area_has_base_lighting = FALSE

/area/proc/add_base_lighting()
	lighting_effect = mutable_appearance('icons/effects/alphacolors.dmi', "white")
	lighting_effect.plane = LIGHTING_PLANE
	lighting_effect.layer = LIGHTING_PRIMARY_LAYER
	lighting_effect.blend_mode = BLEND_ADD
	lighting_effect.alpha = base_lighting_alpha
	lighting_effect.color = base_lighting_color
	lighting_effect.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR
	for(var/turf/T in src)
		T.add_overlay(lighting_effect)
		T.luminosity = 1
	area_has_base_lighting = TRUE
