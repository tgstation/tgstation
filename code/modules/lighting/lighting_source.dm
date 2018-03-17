// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/top_atom        // The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/source_atom     // The atom that we belong to.

	var/turf/source_turf     // The turf under the above.
	var/turf/pixel_turf      // The turf the top_atom appears to over.
	var/light_power    		 // Intensity of the emitter light.
	var/light_range     	 // The range of the emitted light.
	var/light_color    		 // The colour of the light, string, decomposed by parse_light_color()
	var/directional	  		 // The angle that the light is pointing, for directional lighting

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	var/list/datum/lighting_corner/effect_str     // List used to store how much we're affecting corners.
	var/list/turf/affecting_turfs

	var/applied = FALSE // Whether we have applied our light yet or not.

	var/needs_update = LIGHTING_NO_UPDATE    // Whether we are queued for an update.


/datum/light_source/New(var/atom/owner, var/atom/top)
	source_atom = owner // Set our new owner.
	LAZYADD(source_atom.light_sources, src)
	top_atom = top
	if (top_atom != source_atom)
		LAZYADD(top_atom.light_sources, src)

	source_turf = top_atom
	pixel_turf = get_turf_pixel(top_atom) || source_turf

	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	parse_light_color()

	update()

	return ..()

/datum/light_source/Destroy(force)
	remove_lum()
	if (source_atom)
		LAZYREMOVE(source_atom.light_sources, src)

	if (top_atom)
		LAZYREMOVE(top_atom.light_sources, src)

	if (needs_update)
		GLOB.lighting_update_lights -= src

	. = ..()

// Yes this doesn't align correctly on anything other than 4 width tabs.
// If you want it to go switch everybody to elastic tab stops.
// Actually that'd be great if you could!
#define EFFECT_UPDATE(level)                \
	if (needs_update == LIGHTING_NO_UPDATE) \
		GLOB.lighting_update_lights += src; \
	if (needs_update < level)               \
		needs_update            = level;    \


// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/light_source/proc/update(var/atom/new_top_atom)
	// This top atom is different.
	if (new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom && top_atom.light_sources) // Remove ourselves from the light sources of that top atom.
			LAZYREMOVE(top_atom.light_sources, src)

		top_atom = new_top_atom

		if (top_atom != source_atom)
			LAZYADD(top_atom.light_sources, src) // Add ourselves to the light sources of our new top atom.

	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

// Will force an update without checking if it's actually needed.
/datum/light_source/proc/force_update()
	EFFECT_UPDATE(LIGHTING_FORCE_UPDATE)

// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/light_source/proc/vis_update()
	EFFECT_UPDATE(LIGHTING_VIS_UPDATE)

// Decompile the hexadecimal colour into lumcounts of each perspective.
/datum/light_source/proc/parse_light_color()
	if (light_color)
		lum_r = GetRedPart   (light_color) / 255
		lum_g = GetGreenPart (light_color) / 255
		lum_b = GetBluePart  (light_color) / 255
	else
		lum_r = 1
		lum_g = 1
		lum_b = 1

// Macro that applies light to a new corner.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.
#define LUM_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 + LIGHTING_HEIGHT) / max(1, light_range)))
#define X_FALLOFF(C, T) CLAMP01((abs(C.y - T.y) + 2) * 0.12) // For North-South directional lighting so that it forms a "cone" of light
#define Y_FALLOFF(C, T) CLAMP01((abs(C.x - T.x) + 2) * 0.12) // East/West
#define ANG_FALLOFF(C, T, E) CLAMP01((1.5 - getline_distance(T, E, C)) * (2 + sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2)) * 0.12) // For angles

#define APPLY_CORNER(C)                      \
	if(isnull(directional))						 \
		. = LUM_FALLOFF(C, pixel_turf);      \
	else									 \
		if(directional == 0 || directional == 180)			\
			. = X_FALLOFF(C, pixel_turf); 	 \
		else if(directional == 90 || directional == 270)	\
			. = Y_FALLOFF(C, pixel_turf);	 \
		else								 \
			. = ANG_FALLOFF(C, pixel_turf, get_turf_in_angle(directional, pixel_turf, CEILING(light_range, 1)));	\
	. *= light_power;                        \
	var/OLD = effect_str[C];                 \
                                             \
	effect_str[C] = .;                       \
                                             \
	C.update_lumcount                        \
	(                                        \
		(. * lum_r) - (OLD * applied_lum_r), \
		(. * lum_g) - (OLD * applied_lum_g), \
		(. * lum_b) - (OLD * applied_lum_b)  \
	);

#define REMOVE_CORNER(C)                     \
	. = -effect_str[C];                      \
	C.update_lumcount                        \
	(                                        \
		. * applied_lum_r,                   \
		. * applied_lum_g,                   \
		. * applied_lum_b                    \
	);

// This is the define used to calculate falloff.

/datum/light_source/proc/remove_lum()
	applied = FALSE
	var/thing
	for (thing in affecting_turfs)
		var/turf/T = thing
		LAZYREMOVE(T.affecting_lights, src)

	affecting_turfs = null

	var/datum/lighting_corner/C
	for (thing in effect_str)
		C = thing
		REMOVE_CORNER(C)

		LAZYREMOVE(C.affecting, src)

	effect_str = null

/datum/light_source/proc/recalc_corner(var/datum/lighting_corner/C)
	LAZYINITLIST(effect_str)
	if (effect_str[C]) // Already have one.
		REMOVE_CORNER(C)
		effect_str[C] = 0
	APPLY_CORNER(C)
	UNSETEMPTY(effect_str)

/datum/light_source/proc/update_corners()
	var/update = FALSE

	if (!source_atom || QDELETED(source_atom))
		qdel(src)
		return

	if (source_atom.light_power != light_power)
		light_power = source_atom.light_power
		update = TRUE

	if (source_atom.light_range != light_range)
		light_range = source_atom.light_range
		update = TRUE

	if (!top_atom)
		top_atom = source_atom
		update = TRUE

	if(!isnull(directional) && ismob(source_atom.loc) && directional != dir2angle(source_atom.loc.dir))
		var/obj/item/device/flashlight/directional/D = source_atom //If directionality is expanded other flashlights should be made a child of this anyway
		if(get_turf(source_atom) != source_turf)      // We moved, reset light direction to our current direction
			D.pointing = null
			source_atom.dir = source_atom.loc.dir
			directional = dir2angle(source_atom.dir)
		else if(isnull(D.pointing))					  // We turned without moving or pointing the light
			source_atom.dir = source_atom.loc.dir
			directional = dir2angle(source_atom.dir)
		update = TRUE

	if (!light_range || !light_power)
		qdel(src)
		return

	if (isturf(top_atom))
		if (source_turf != top_atom)
			source_turf = top_atom
			pixel_turf = source_turf
			update = TRUE
	else if (top_atom.loc != source_turf)
		source_turf = top_atom.loc
		pixel_turf = get_turf_pixel(top_atom)
		update = TRUE
	else
		var/P = get_turf_pixel(top_atom)
		if (P != pixel_turf)
			pixel_turf = P
			update = TRUE

	if (!isturf(source_turf))
		if (applied)
			remove_lum()
		return

	if (light_range && light_power && !applied)
		update = TRUE

	if (source_atom.light_color != light_color)
		light_color = source_atom.light_color
		parse_light_color()
		update = TRUE

	else if (applied_lum_r != lum_r || applied_lum_g != lum_g || applied_lum_b != lum_b)
		update = TRUE

	if (update)
		needs_update = LIGHTING_CHECK_UPDATE
		applied = TRUE
	else if (needs_update == LIGHTING_CHECK_UPDATE)
		return //nothing's changed

	var/list/datum/lighting_corner/corners = list()
	var/list/turf/turfs                    = list()
	var/thing
	var/datum/lighting_corner/C
	var/turf/T
	if (source_turf)
		if(!isnull(directional)) // If the light has a direction, which is provided as an angle
			var/tempTurf = get_turf_in_angle(directional, source_turf, CEILING(light_range, 1))
			if (directional % 90 == 0)                                 // Cardinal Lighting
				for(T in getline(source_turf,tempTurf))
					if(T != source_turf)
						turfs += T
						for (thing in T.get_corners())
							C = thing
							corners[C] = 0
						if(T.has_opaque_atom)
							break
			else                                                       // Angular lighting
				var/spread = 10
				var/set_angle
				for(var/i in 1 to 4)
					if(i % 2 == 0)
						set_angle = directional - spread
						spread += 10
					else
						set_angle = directional + spread
					tempTurf = get_turf_in_angle(set_angle, source_turf, CEILING(light_range, 1))
					for(T in getline(source_turf,tempTurf))
						if(T != source_turf && !(T in turfs))
							turfs += T
							for (thing in T.get_corners())
								C = thing
								corners[C] = 0
							if(T.has_opaque_atom)
								break
		else
			var/oldlum = source_turf.luminosity // Standard 360-degree lighting
			source_turf.luminosity = CEILING(light_range, 1)
			for(T in view(CEILING(light_range, 1), source_turf))
				for (thing in T.get_corners())
					C = thing
					corners[C] = 0
				turfs += T
			source_turf.luminosity = oldlum

	LAZYINITLIST(affecting_turfs)
	var/list/L = turfs - affecting_turfs // New turfs, add us to the affecting lights of them.
	affecting_turfs += L
	for (thing in L)
		T = thing
		LAZYADD(T.affecting_lights, src)

	L = affecting_turfs - turfs // Now-gone turfs, remove us from the affecting lights.
	affecting_turfs -= L
	for (thing in L)
		T = thing
		LAZYREMOVE(T.affecting_lights, src)

	LAZYINITLIST(effect_str)
	if (needs_update == LIGHTING_VIS_UPDATE)
		for (thing in  corners - effect_str) // New corners
			C = thing
			LAZYADD(C.affecting, src)
			if (!C.active)
				effect_str[C] = 0
				continue
			APPLY_CORNER(C)
	else
		L = corners - effect_str
		for (thing in L) // New corners
			C = thing
			LAZYADD(C.affecting, src)
			if (!C.active)
				effect_str[C] = 0
				continue
			APPLY_CORNER(C)


		for (thing in corners - L) // Existing corners
			C = thing
			if (!C.active)
				effect_str[C] = 0
				continue
			APPLY_CORNER(C)


	L = effect_str - corners
	for (thing in L) // Old, now gone, corners.
		C = thing
		REMOVE_CORNER(C)
		LAZYREMOVE(C.affecting, src)
	effect_str -= L

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(effect_str)
	UNSETEMPTY(affecting_turfs)

#undef EFFECT_UPDATE
#undef LUM_FALLOFF
#undef REMOVE_CORNER
#undef APPLY_CORNER
#undef X_FALLOFF
#undef Y_FALLOFF
#undef ANG_FALLOFF