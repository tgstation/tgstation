/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR].
/proc/emissive_appearance(icon, icon_state = "", atom/offset_spokesman, layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE, offset_const)
	// Note: alpha doesn't "do" anything, since it's overriden by the color set shortly after
	// Consider removing it someday? (I wonder if we made emissives blend right we could make alpha actually matter. dreams man, dreams)
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, offset_spokesman, EMISSIVE_PLANE, 255, appearance_flags | EMISSIVE_APPEARANCE_FLAGS, offset_const)
	appearance.color = GLOB.emissive_color
	return appearance

// This is a semi hot proc, so we micro it. saves maybe 150ms
// sorry :)
/proc/fast_emissive_blocker(atom/make_blocker)
	// Note: alpha doesn't "do" anything, since it's overriden by the color set shortly after
	// Consider removing it someday?
	var/mutable_appearance/blocker = new()
	blocker.icon = make_blocker.icon
	blocker.icon_state = make_blocker.icon_state
	// blocker.layer = FLOAT_LAYER // Implied, FLOAT_LAYER is default for appearances
	blocker.appearance_flags |= make_blocker.appearance_flags | EMISSIVE_APPEARANCE_FLAGS
	blocker.dir = make_blocker.dir
	blocker.color = GLOB.em_block_color

	// Note, we are ok with null turfs, that's not an error condition we'll just default to 0, the error would be
	// Not passing ANYTHING in, key difference
	SET_PLANE_EXPLICIT(blocker, EMISSIVE_PLANE, make_blocker)
	return blocker

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EM_BLOCK_COLOR].
/proc/emissive_blocker(icon, icon_state = "", atom/offset_spokesman, layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE, offset_const)
	// Note: alpha doesn't "do" anything, since it's overriden by the color set shortly after
	// Consider removing it someday?
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, offset_spokesman, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS, offset_const)
	appearance.color = GLOB.em_block_color
	return appearance
