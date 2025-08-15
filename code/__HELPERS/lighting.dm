#define TOPDOWN_TO_EMISSIVE_LAYER(layer) LERP(FLOOR_EMISSIVE_START_LAYER, FLOOR_EMISSIVE_END_LAYER, (layer - (TOPDOWN_LAYER + 1)) / TOPDOWN_LAYER_COUNT)

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR].
/proc/emissive_appearance(icon, icon_state = "", atom/offset_spokesman, layer, alpha = 255, appearance_flags = NONE, offset_const, effect_type = EMISSIVE_BLOOM)
	if (isnull(layer))
		if(IS_TOPDOWN_PLANE(offset_spokesman.plane))
			layer = TOPDOWN_TO_EMISSIVE_LAYER(offset_spokesman.layer)
		else
			layer = FLOAT_LAYER
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, offset_spokesman, EMISSIVE_PLANE, 255, appearance_flags | EMISSIVE_APPEARANCE_FLAGS, offset_const)
	if(alpha == 255)
		switch(effect_type)
			if(EMISSIVE_NO_BLOOM)
				appearance.color = GLOB.emissive_color_no_bloom
			if (EMISSIVE_BLOOM)
				appearance.color = GLOB.emissive_color
			if (EMISSIVE_SPECULAR)
				appearance.color = GLOB.specular_color
	else
		var/alpha_ratio = alpha/255
		switch(effect_type)
			if(EMISSIVE_NO_BLOOM)
				appearance.color = _EMISSIVE_COLOR_NO_BLOOM(alpha_ratio)
			if (EMISSIVE_BLOOM)
				appearance.color = _EMISSIVE_COLOR(alpha_ratio)
			if (EMISSIVE_SPECULAR)
				appearance.color = _SPECULAR_COLOR(alpha_ratio)

	//Test to make sure emissives with broken or missing icon states are created
	if(PERFORM_ALL_TESTS(focus_only/invalid_emissives))
		if(icon_state && !icon_exists(icon, icon_state))
			stack_trace("An emissive appearance was added with non-existant icon_state \"[icon_state]\" in [icon]!")

	return appearance

// This is a semi hot proc, so we micro it. saves maybe 150ms
// sorry :)
/proc/fast_emissive_blocker(atom/make_blocker)
	var/mutable_appearance/blocker = new()
	blocker.icon = make_blocker.icon
	blocker.icon_state = make_blocker.icon_state
	// blocker.layer = FLOAT_LAYER // Implied, FLOAT_LAYER is default for appearances
	// If we keep this on a FLOAT_LAYER on a topdown object it'll render ontop of everything
	// So we need to force it to render at a saner layer
	if(IS_TOPDOWN_PLANE(make_blocker.plane))
		blocker.layer = TOPDOWN_TO_EMISSIVE_LAYER(make_blocker.layer)
	blocker.appearance_flags |= make_blocker.appearance_flags | EMISSIVE_APPEARANCE_FLAGS
	blocker.dir = make_blocker.dir
	if(make_blocker.alpha == 255)
		blocker.color = GLOB.em_block_color
	else
		var/alpha_ratio = make_blocker.alpha/255
		blocker.color = _EM_BLOCK_COLOR(alpha_ratio)

	// Note, we are ok with null turfs, that's not an error condition we'll just default to 0, the error would be
	// Not passing ANYTHING in, key difference
	SET_PLANE_EXPLICIT(blocker, EMISSIVE_PLANE, make_blocker)
	return blocker

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EM_BLOCK_COLOR].
/proc/emissive_blocker(icon, icon_state = "", atom/offset_spokesman, layer, alpha = 255, appearance_flags = NONE, offset_const)
	if (isnull(layer))
		if(IS_TOPDOWN_PLANE(offset_spokesman.plane))
			layer = TOPDOWN_TO_EMISSIVE_LAYER(offset_spokesman.layer)
		else
			layer = FLOAT_LAYER
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, offset_spokesman, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS, offset_const)
	if(alpha == 255)
		appearance.color = GLOB.em_block_color
	else
		var/alpha_ratio = alpha/255
		appearance.color = _EM_BLOCK_COLOR(alpha_ratio)
	return appearance

/// Takes a non area atom and a threshold
/// Makes it block emissive with any pixels with more alpha then that threshold, with the rest allowing the light to pass
/// Returns a list of objects, automatically added to your vis_contents, that apply this effect
/// QDEL them when appropriate
/proc/partially_block_emissives(atom/make_blocker, alpha_to_leave)
	var/static/uid = 0
	uid++
	if(!make_blocker.render_target)
		make_blocker.render_target = "partial_emissive_block_[uid]"

	// First, we cut away a constant amount
	var/cut_away = (alpha_to_leave - 1) / 255
	var/atom/movable/render_step/color/alpha_threshold_down = new(null, make_blocker, list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,-cut_away))
	alpha_threshold_down.render_target = "*emissive_block_alpha_down_[uid]"
	// Then we multiply what remains by the amount we took away
	var/atom/movable/render_step/color/alpha_threshold_up = new(null, alpha_threshold_down, list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,alpha_to_leave, 0,0,0,0))
	alpha_threshold_up.render_target = "*emissive_block_alpha_up_[uid]"
	// Now we just feed that into an emissive blocker
	var/atom/movable/render_step/emissive_blocker/em_block = new(null, alpha_threshold_up)
	var/list/hand_back = list()
	hand_back += alpha_threshold_down
	hand_back += alpha_threshold_up
	hand_back += em_block
	// Cast to movable so we can use vis_contents. will work for turfs, but not for areas
	var/atom/movable/vis_cast = make_blocker
	vis_cast.vis_contents += hand_back
	return hand_back

#undef TOPDOWN_TO_EMISSIVE_LAYER
