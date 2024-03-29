/// Creates a digital effect around the target
/atom/proc/create_digital_aura()
	var/list/overlays = get_digital_overlays()
	if(!length(overlays))
		return

	add_overlay(overlays)
	alpha = 210
	set_light(2, l_color = LIGHT_COLOR_BUBBLEGUM, l_on = TRUE)
	update_appearance()

/// Removes the digital effect around the target
/atom/proc/remove_digital_aura()
	var/list/overlays = get_digital_overlays()
	if(!length(overlays))
		return

	cut_overlay(overlays)
	alpha = 255
	set_light(0, l_color = null, l_on = FALSE)
	update_appearance()

/// Returns a list of overlays to be used for the digital effect
/atom/proc/get_digital_overlays()
	var/base_icon
	var/dimensions = get_icon_dimensions(icon)
	if(!length(dimensions))
		return

	switch(dimensions["width"])
		if(32)
			base_icon = 'icons/effects/bitrunning.dmi'
		if(48)
			base_icon = 'icons/effects/bitrunning_48.dmi'
		if(64)
			base_icon = 'icons/effects/bitrunning_64.dmi'

	var/mutable_appearance/redshift = mutable_appearance(base_icon, "redshift")
	redshift.blend_mode = BLEND_MULTIPLY

	var/mutable_appearance/glitch_effect = mutable_appearance(base_icon, "glitch", MUTATIONS_LAYER, alpha = 150)

	return list(glitch_effect, redshift)
