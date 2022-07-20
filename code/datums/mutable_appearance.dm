// Mutable appearances are an inbuilt byond datastructure. Read the documentation on them by hitting F1 in DM.
// Basically use them instead of images for overlays/underlays and when changing an object's appearance if you're doing so with any regularity.
// Unless you need the overlay/underlay to have a different direction than the base object. Then you have to use an image due to a bug.

// Mutable appearances are children of images, just so you know.

/mutable_appearance/New()
	..()
	plane = FLOAT_PLANE // No clue why this is 0 by default yet images are on FLOAT_PLANE
						// And yes this does have to be in the constructor, BYOND ignores it if you set it as a normal var

/// Helper similar to image()
/proc/mutable_appearance(icon, icon_state = "", layer = FLOAT_LAYER, atom/offset_spokesman, plane = FLOAT_PLANE, alpha = 255, appearance_flags = NONE, offset_const)
	if(plane != FLOAT_PLANE)
		// Essentially, we allow users that only want one static offset to pass one in
		if(!isnull(offset_const))
			plane = GET_NEW_PLANE(plane, offset_const)
		// That, or you need to pass in some non null object to reference
		else if(!isnull(offset_spokesman))
			// Note, we are ok with null turfs, that's not an error condition we'll just default to 0, the error would be
			// Not passing ANYTHING in, key difference
			var/turf/our_turf = get_turf(offset_spokesman)
			plane = MUTATE_PLANE(plane, our_turf)
		// otherwise if you're setting plane you better have the guts to back it up
		else
			stack_trace("No plane offset passed in as context for a non floating mutable appearance, ya done fucked up")
	var/mutable_appearance/MA = new()
	MA.icon = icon
	MA.icon_state = icon_state
	MA.layer = layer
	MA.plane = plane
	MA.alpha = alpha
	MA.appearance_flags |= appearance_flags
	return MA
