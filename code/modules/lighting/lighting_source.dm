// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	///The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/top_atom
	///The atom that we belong to.
	var/atom/source_atom

	///The turf under the source atom.
	var/turf/source_turf
	/// How much to x shift our light by when displaying it
	var/offset_x = 0
	/// How much to y shift our light by when displaying it
	var/offset_y = 0
	/// How much larger our light sheet should be, based off offset_x and y
	/// We clamp to at least 1, so if offset_x is 0.1, then this'll be 1
	var/visual_offset

	///Intensity of the emitter light.
	var/light_power
	/// The range of the emitted light.
	var/light_range
	/// The colour of the light, string, decomposed by parse_light_color()
	var/light_color
	/// The height of the light. The larger this is, the dimmer we'll start
	var/light_height

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	/// What direction our angled light is pointed
	var/light_dir = NONE
	/// How many degrees of a circle should our light show. 360 is all of it, 180 is half, etc
	var/light_angle = 360

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	/// List used to store how much we're affecting corners.
	var/list/datum/lighting_corner/effect_str

	/// Whether we have applied our light yet or not.
	var/applied = FALSE
	/// whether we are to be added to SSlighting's sources_queue list for an update
	var/needs_update = LIGHTING_NO_UPDATE


/datum/light_source/New(atom/owner, atom/top)
	source_atom = owner // Set our new owner.
	add_to_light_sources(source_atom)
	top_atom = top
	if (top_atom != source_atom)
		add_to_light_sources(top_atom)

	source_turf = top_atom

	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	PARSE_LIGHT_COLOR(src)

	update()
	if(GLOB.light_debug_enabled)
		source_atom.debug()

/datum/light_source/Destroy(force)
	remove_lum()
	if (source_atom)
		remove_from_light_sources(source_atom)

	if (top_atom)
		remove_from_light_sources(top_atom)

	if (needs_update)
		SSlighting.sources_queue -= src
		SSlighting.current_sources -= src

	top_atom = null
	source_atom = null
	source_turf = null

	return ..()

///add this light source to new_atom_host's light_sources list. updating movement registrations as needed
/datum/light_source/proc/add_to_light_sources(atom/new_atom_host)
	if(QDELETED(new_atom_host))
		return FALSE

	LAZYADD(new_atom_host.light_sources, src)
	//yes, we register the signal to the top atom too, this is intentional and ensures contained lighting updates properly
	if(ismovable(new_atom_host))
		RegisterSignal(new_atom_host, COMSIG_MOVABLE_MOVED, PROC_REF(update_host_lights))
	RegisterSignal(new_atom_host, COMSIG_TURF_NO_LONGER_BLOCK_LIGHT, PROC_REF(force_update))
	return TRUE

///remove this light source from old_atom_host's light_sources list, unsetting movement registrations
/datum/light_source/proc/remove_from_light_sources(atom/old_atom_host)
	if(QDELETED(old_atom_host))
		return FALSE

	LAZYREMOVE(old_atom_host.light_sources, src)
	if(ismovable(old_atom_host))
		UnregisterSignal(old_atom_host, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(old_atom_host, COMSIG_TURF_NO_LONGER_BLOCK_LIGHT)
	return TRUE

// Yes this doesn't align correctly on anything other than 4 width tabs.
// If you want it to go switch everybody to elastic tab stops.
// Actually that'd be great if you could!
#define EFFECT_UPDATE(level)                  \
	if (needs_update == LIGHTING_NO_UPDATE) { \
		SSlighting.sources_queue += src;      \
	}                                         \
	if (needs_update < level) {               \
		needs_update = level;                 \
	}

///signal handler for when our host atom moves and we need to update our effects
/datum/light_source/proc/update_host_lights(atom/movable/host)
	SIGNAL_HANDLER
	if(QDELETED(host))
		return

	// If the host is our owner, we want to call their update so they can decide who the top atom should be
	if(host == source_atom)
		host.update_light()
		return

	// Otherwise, our top atom just moved, so we trigger a normal rebuild
	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

/// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/light_source/proc/update(atom/new_top_atom)
	// This top atom is different.
	if (new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom && top_atom.light_sources) // Remove ourselves from the light sources of that top atom.
			remove_from_light_sources(top_atom)

		top_atom = new_top_atom

		if (top_atom != source_atom)
			add_to_light_sources(top_atom)

	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

// Will force an update without checking if it's actually needed.
/datum/light_source/proc/force_update()
	EFFECT_UPDATE(LIGHTING_FORCE_UPDATE)

// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/light_source/proc/vis_update()
	EFFECT_UPDATE(LIGHTING_VIS_UPDATE)

// This exists so we can cache the vars used in this macro, and save MASSIVE time :)
// Most of this is saving off datum var accesses, tho some of it does actually cache computation
// You will NEED to call this before you call APPLY_CORNER
#define SETUP_CORNERS_CACHE(lighting_source)                                                               \
	var/_turf_x = lighting_source.source_turf.x;                                                            \
	var/_turf_y = lighting_source.source_turf.y;                                                            \
	var/_turf_z = lighting_source.source_turf.z;                                                            \
	var/list/_sheet = get_sheet();                                                                         \
	var/list/_multiz_sheet = list();                                                                       \
	if(!!GET_LOWEST_STACK_OFFSET(source_turf.z)) {                                                         \
		_multiz_sheet = get_sheet(multiz = TRUE);                                                          \
	}                                                                                                      \
	var/_range_offset = CEILING(lighting_source.light_range, 1) + 0.5 + 1 + lighting_source.visual_offset; \
	var/_multiz_offset = SSmapping.max_plane_offset + 1;                                                   \
	var/_light_power = lighting_source.light_power;                                                        \
	var/_applied_lum_r = lighting_source.applied_lum_r;                                                    \
	var/_applied_lum_g = lighting_source.applied_lum_g;                                                    \
	var/_applied_lum_b = lighting_source.applied_lum_b;                                                    \
	var/_lum_r = lighting_source.lum_r;                                                                    \
	var/_lum_g = lighting_source.lum_g;                                                                    \
	var/_lum_b = lighting_source.lum_b;

#define SETUP_CORNERS_REMOVAL_CACHE(lighting_source)    \
	var/_applied_lum_r = lighting_source.applied_lum_r; \
	var/_applied_lum_g = lighting_source.applied_lum_g; \
	var/_applied_lum_b = lighting_source.applied_lum_b;

// Read out of our sources light sheet, a map of offsets -> the luminosity to use
#define LUM_FALLOFF(C) _sheet[C.x - _turf_x + _range_offset][C.y  - _turf_y + _range_offset]
#define LUM_FALLOFF_MULTIZ(C) _multiz_sheet[C.z - _turf_z + _multiz_offset][C.x - _turf_x + _range_offset][C.y - _turf_y + _range_offset]

// Macro that applies light to a new corner.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.
#define APPLY_CORNER(C)                          \
	if(C.z == _turf_z) {                         \
		. = LUM_FALLOFF(C);                      \
	}                                            \
	else {                                       \
		. = LUM_FALLOFF_MULTIZ(C)                \
	}                                            \
	. *= _light_power;                           \
	var/OLD = effect_str[C];                     \
	                                             \
	C.update_lumcount                            \
	(                                            \
		(. * _lum_r) - (OLD * _applied_lum_r),   \
		(. * _lum_g) - (OLD * _applied_lum_g),   \
		(. * _lum_b) - (OLD * _applied_lum_b)    \
	);

#define REMOVE_CORNER(C)                         \
	. = -effect_str[C];                          \
	C.update_lumcount                            \
	(                                            \
		. * _applied_lum_r,                      \
		. * _applied_lum_g,                      \
		. * _applied_lum_b                       \
	);

/// Returns a list of lists, indexed with ints, that can be read to get the lighting multiplier at any one point
/// If the requested sheet is multiz, this will be 3 lists deep, first handling z level then x and y
/// otherwise it's just two, x then y
/datum/light_source/proc/get_sheet(multiz = FALSE)
	var/list/static/key_to_sheet = list()
	var/range = max(1, light_range);
	var/key = "[range]-[visual_offset]-[offset_x]-[offset_y]-[light_dir]-[light_angle]-[light_height]-[multiz]"
	var/list/hand_back = key_to_sheet[key]
	if(!hand_back)
		if(multiz)
			hand_back = generate_sheet_multiz(range, visual_offset, offset_x, offset_y, light_dir, light_angle, light_height)
		else
			hand_back = generate_sheet(range, visual_offset, offset_x, offset_y, light_dir, light_angle, light_height)
		key_to_sheet[key] = hand_back
	return hand_back

/// Returns a list of lists that encodes the light falloff of our source
/// Takes anything that impacts our generation as input
/// This function should be "pure", no side effects or reads from the source object
/datum/light_source/proc/generate_sheet(range, visual_offset, x_offset, y_offset, center_dir, angle, height, z_level = 0)
	var/list/encode = list()
	// How far away the turfs we get are, and how many there are are often not the same calculation
	// So we need to include the visual offset, so we can ensure our sheet is large enough to accept all the distance differences
	var/bound_range = CEILING(range, 1) + visual_offset

	// Corners are placed at 0.5 offsets
	// We need our coords to reflect that (though x_offsets that change the basis for how things are calculated are fine too)
	for(var/x in (-(bound_range) + x_offset - 0.5) to (bound_range + x_offset + 0.5))
		var/list/row = list()
		for(var/y in (-(bound_range) + y_offset - 0.5) to (bound_range + y_offset + 0.5))
			row += falloff_at_coord(x, y, z_level, range, center_dir, angle, height)
		encode += list(row)
	return encode

/// Returns a THREE dimensional list of lists that encodes the lighting falloff of our source
/// Takes anything that impacts our generation as input
/// This function should be "pure", no side effects or reads from the passed object
/datum/light_source/proc/generate_sheet_multiz(range, visual_offset, x_offset, y_offset, center_dir, angle, height)
	var/list/encode = list()
	var/z_range = SSmapping.max_plane_offset // Let's just be safe yeah?
	for(var/z in -z_range to z_range)
		var/list/sheet = generate_sheet(range, visual_offset, x_offset, y_offset, center_dir, angle, height, z)
		encode += list(sheet)
	return encode

/// Takes x y and z offsets from the source as input, alongside our source's range
/// Returns a value between 0 and 1, 0 being dark on that tile, 1 being fully lit
/datum/light_source/proc/falloff_at_coord(x, y, z, range, center_dir, angle, height)
	var/range_divisor = max(1, range)

	// You may notice we use squares here even though there are three components
	// Because z diffs are so functionally small, cubes and cube roots are too aggressive
	// The larger the distance is, the less bright our light will be
	var/multiplier = 1 - CLAMP01(sqrt(x ** 2 + y ** 2 + z ** 2 + height) / range_divisor)
	if(angle >= 360 || angle <= 0)
		return multiplier

	// Turn our positional offset into an angle
	var/coord_angle = delta_to_angle(x, y)
	// Get the difference between the angle we want, and the angle we have
	var/center_angle = dir2angle(center_dir)
	var/angle_delta = abs(center_angle - coord_angle)
	// Now we have to normalize the angle delta to be between 0 and 180, instead of 0 and 360
	// This ensures removing say, 15 degrees removes it from both sides, rather then just one
	// Turns an unfurling fan into a pair of scissors
	if(angle_delta > 180)
		angle_delta = 180 - (angle_delta - 180)
	// We allow angle deltas to a certian amount, angle / 2
	// If we pass that, then it starts effecting the visuals
	// Oh and we'll scale it so 30 degrees is the "0" point, where things become fully dark
	// This could be variable, it just isn't yet yaknow?
	return max(multiplier * (1 - max(angle_delta - (angle / 2), 0) / 30), 0)

/// Dumps the content of a lighting sheet to chat, for debugging
/datum/light_source/proc/print_sheet()
	var/list/sheet = get_sheet()
	var/list/output = list()
	var/multiz_depth = 1
	// If we have a list 3 layers down we're multiz
	if(length(sheet[1][1]))
		multiz_depth = length(sheet)
	var/column_seperator = ""
	for(var/i in 1 to length(sheet))
		column_seperator += "----"
	output += column_seperator
	for(var/i in 1 to multiz_depth)
		for(var/list/column in sheet)
			var/list/print_column = list()
			for(var/row in column)
				print_column += round(row, 0.1)
			output += print_column.Join(", ")
		output += column_seperator
	to_chat(usr, "\n[output.Join("\n")]")

/// Debug proc, for when lighting sheets fuck up
/// Accepts the sheet (2 or 3 (multiz) dimensional list of lighting values at some offset)
/// alongside x and y delta values and the sheet's "offset", which is the amount required to ensure everything indexes at 1
/// Optionally, you can pass similar values for multiz stuff
/proc/read_sheet(list/sheet, x, y, offset, z, z_offset)
	var/list/working = sheet
	var/offset_x = x + offset
	var/offset_y = y + offset
	var/offset_z = z + z_offset
	if(z)
		working = sheet[offset_z]
	var/list/line = working[offset_x]
	var/word = line[offset_y]
	return word

/// This is the define used to calculate falloff.
/datum/light_source/proc/remove_lum()
	SETUP_CORNERS_REMOVAL_CACHE(src)
	applied = FALSE
	for (var/datum/lighting_corner/corner as anything in effect_str)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)

	effect_str = null

/datum/light_source/proc/recalc_corner(datum/lighting_corner/corner)
	SETUP_CORNERS_CACHE(src)
	LAZYINITLIST(effect_str)
	if (effect_str[corner]) // Already have one.
		REMOVE_CORNER(corner)
		effect_str[corner] = 0

	APPLY_CORNER(corner)
	effect_str[corner] = .


// Keep in mind. Lighting corners accept the bottom left (northwest) set of cords to them as input
#define GENERATE_MISSING_CORNERS(gen_for)                                                                 \
	if (!gen_for.lighting_corner_NE) {                                                                    \
		gen_for.lighting_corner_NE = new /datum/lighting_corner(gen_for.x, gen_for.y, gen_for.z);         \
	}                                                                                                     \
	if (!gen_for.lighting_corner_SE) {                                                                    \
		gen_for.lighting_corner_SE = new /datum/lighting_corner(gen_for.x, gen_for.y - 1, gen_for.z);     \
	}                                                                                                     \
	if (!gen_for.lighting_corner_SW) {                                                                    \
		gen_for.lighting_corner_SW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y - 1, gen_for.z); \
	}                                                                                                     \
	if (!gen_for.lighting_corner_NW) {                                                                    \
		gen_for.lighting_corner_NW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y, gen_for.z);     \
	}                                                                                                     \
	gen_for.lighting_corners_initialised = TRUE;

#define INSERT_CORNERS(insert_into, draw_from)             \
	if (!draw_from.lighting_corners_initialised) {         \
		GENERATE_MISSING_CORNERS(draw_from);               \
	}                                                      \
	insert_into[draw_from.lighting_corner_NE] = 0;         \
	insert_into[draw_from.lighting_corner_SE] = 0;         \
	insert_into[draw_from.lighting_corner_SW] = 0;         \
	insert_into[draw_from.lighting_corner_NW] = 0;

/// Refreshes our lighting source to match its parent atom
/// Returns TRUE if an update is needed, FALSE otherwise
/datum/light_source/proc/refresh_values()
	var/update = FALSE
	var/atom/source_atom = src.source_atom
	var/turf/old_source_turf = source_turf

	if (QDELETED(source_atom))
		qdel(src)
		return FALSE

	if (source_atom.light_power != light_power)
		light_power = source_atom.light_power
		update = TRUE

	if (source_atom.light_range != light_range)
		light_range = source_atom.light_range
		update = TRUE

	if (!top_atom)
		top_atom = source_atom
		update = TRUE

	if (!light_range || !light_power)
		qdel(src)
		return FALSE

	var/atom/visual_source = source_atom
	if(isturf(top_atom))
		visual_source = source_atom
		if(source_turf != top_atom)
			source_turf = top_atom
			update = TRUE
	else
		visual_source = top_atom
		if(top_atom.loc != source_turf)
			source_turf = top_atom.loc
			update = TRUE

	if (!isturf(source_turf))
		if (applied)
			remove_lum()
		return FALSE

	if (light_range && light_power && !applied)
		update = TRUE

	if (source_atom.light_color != light_color)
		light_color = source_atom.light_color
		PARSE_LIGHT_COLOR(src)
		update = TRUE

	else if (applied_lum_r != lum_r || applied_lum_g != lum_g || applied_lum_b != lum_b)
		update = TRUE

	if(source_atom.light_dir != light_dir)
		light_dir = source_atom.light_dir
		update = TRUE

	if (source_atom.light_angle != light_angle)
		light_angle = source_atom.light_angle
		update = TRUE

	if(source_atom.light_height != light_height)
		light_height = source_atom.light_height
		update = TRUE

	var/list/visual_offsets = calculate_light_offset(visual_source)
	if(visual_offsets[1] != offset_x || visual_offsets[2] != offset_y || source_turf != old_source_turf)
		offset_x = visual_offsets[1]
		offset_y = visual_offsets[2]
		visual_offset = max(CEILING(abs(offset_x), 1), CEILING(abs(offset_y), 1))
		update = TRUE

	// If we need to update, well, update
	if (update)
		needs_update = LIGHTING_CHECK_UPDATE
		applied = TRUE
		return TRUE

	// Otherwise, go off the needs_update var. If it requires an update provide one, otherwise we're kosher
	if (needs_update == LIGHTING_CHECK_UPDATE)
		return FALSE //nothing's changed
	return TRUE

/// Returns a list of lighting corners this source impacts
/datum/light_source/proc/impacted_corners()
	var/list/datum/lighting_corner/corners = list()
	if (!source_turf)
		return list()

	var/oldlum = source_turf.luminosity
	var/working_range = CEILING(light_range + visual_offset, 1)
	source_turf.luminosity = working_range

	var/uses_multiz = !!GET_LOWEST_STACK_OFFSET(source_turf.z)

	if(!uses_multiz) // Yes I know this could be acomplished with an if in the for loop, but it's fukin lighting code man
		for(var/turf/T in view(working_range, source_turf))
			if(IS_OPAQUE_TURF(T))
				continue
			INSERT_CORNERS(corners, T)
		source_turf.luminosity = oldlum
		return corners

	for(var/turf/T in view(working_range, source_turf))
		if(IS_OPAQUE_TURF(T))
			continue
		INSERT_CORNERS(corners, T)

		var/turf/below = GET_TURF_BELOW(T)
		var/turf/previous = T
		while(below)
			// If we find a non transparent previous, end
			if(!istransparentturf(previous))
				break
			if(IS_OPAQUE_TURF(below))
				// If we're opaque but the tile above us is transparent, then we should be counted as part of the potential "space"
				// Of this corner
				break
			// Now we do lighting things to it
			INSERT_CORNERS(corners, below)
			// ANNND then we add the one below it
			previous = below
			below = GET_TURF_BELOW(below)

		var/turf/above = GET_TURF_ABOVE(T)
		while(above)
			// If we find a non transparent turf, end
			if(!istransparentturf(above) || IS_OPAQUE_TURF(above))
				break
			INSERT_CORNERS(corners, above)
			above = GET_TURF_ABOVE(above)

	source_turf.luminosity = oldlum
	return corners

/datum/light_source/proc/update_corners()
	if(!refresh_values())
		return

	var/list/datum/lighting_corner/corners = impacted_corners()
	SETUP_CORNERS_CACHE(src)

	var/list/datum/lighting_corner/new_corners = (corners - src.effect_str)
	LAZYINITLIST(src.effect_str)
	for (var/datum/lighting_corner/corner as anything in new_corners)
		APPLY_CORNER(corner)
		if (. != 0)
			LAZYADD(corner.affecting, src)
			effect_str[corner] = .
	// New corners are a subset of corners. so if they're both the same length, there are NO old corners!
	if(needs_update != LIGHTING_VIS_UPDATE && length(corners) != length(new_corners))
		for (var/datum/lighting_corner/corner as anything in corners - new_corners) // Existing corners
			APPLY_CORNER(corner)
			if (. != 0)
				effect_str[corner] = .
			else
				LAZYREMOVE(corner.affecting, src)
				effect_str -= corner

	var/list/datum/lighting_corner/gone_corners = effect_str - corners
	for (var/datum/lighting_corner/corner as anything in gone_corners)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)
	effect_str -= gone_corners

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(src.effect_str)

#undef APPLY_CORNER
#undef EFFECT_UPDATE
#undef GENERATE_MISSING_CORNERS
#undef INSERT_CORNERS
#undef LUM_FALLOFF
#undef LUM_FALLOFF_MULTIZ
#undef REMOVE_CORNER
#undef SETUP_CORNERS_CACHE
#undef SETUP_CORNERS_REMOVAL_CACHE
