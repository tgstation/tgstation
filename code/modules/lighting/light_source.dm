// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/top_atom		// The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/source_atom	// The atom that we belong to.

	var/turf/source_turf	// The turf under the above.
	var/light_power			// Intensity of the emitter light.
	var/light_range			// The range of the emitted light.
	var/light_color			// The colour of the light, string, decomposed by parse_light_color()

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	// These two lists might just be an assoc list.
	var/list/effect_str		// List used to store how much we're affecting turfs.

	var/applied				// Whether we have applied our light yet or not.

	var/vis_update			// Whether we should smartly recalculate visibility. and then only update tiles that became (in)visible to us.
	var/needs_update		// Whether we are queued for an update.
	var/destroyed			// Whether we are destroyed and need to stop emitting light.
	var/force_update		// Forced updates, currently unused.

/datum/light_source/New(var/atom/owner, var/atom/top)
	source_atom = owner // Set our new owner.
	if(!source_atom.light_sources)
		source_atom.light_sources = list()

	source_atom.light_sources += src // Add us to the lights of our owner.
	top_atom = top
	if(top_atom != source_atom)
		if(!top.light_sources)
			top.light_sources = list()

		top_atom.light_sources += src

	source_turf = top_atom
	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	parse_light_color()

	effect_str = list()

	update()

	return ..()

// Kill ourselves.
/datum/light_source/proc/destroy()
	destroyed = 1
	force_update()
	if(source_atom)
		source_atom.light_sources -= src

	if(top_atom)
		top_atom.light_sources -= src

// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/light_source/proc/update(atom/new_top_atom)
	// This top atom is different.
	if(new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom) // Remove ourselves from the light sources of that top atom.
			top_atom.light_sources -= src

		top_atom = new_top_atom

		if(top_atom != source_atom)
			if(!top_atom.light_sources)
				top_atom.light_sources = list()

			top_atom.light_sources += src // Add ourselves to the light sources of our new top atom.

	if(!needs_update) // Add us to the queue if we aren't updating already.
		lighting_update_lights += src
		needs_update = 1

// Will force an update without checking if it's actually needed.
/datum/light_source/proc/force_update()
	force_update = 1
	if(!needs_update) // Add us to the queue if we aren't updating already.
		needs_update = 1
		lighting_update_lights += src

// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/light_source/proc/vis_update()
	if(!needs_update) // Add us to the queue if we aren't updating already.
		needs_update = 1
		lighting_update_lights += src

	vis_update = 1

// Will check if we actually need to update, and update any variables that may need to be updated.
/datum/light_source/proc/check()
	if(!source_atom || !light_range || !light_power)
		destroy()
		return 1

	if(!top_atom)
		top_atom = source_atom
		. = 1

	if(istype(top_atom, /turf))
		if(source_turf != top_atom)
			source_turf = top_atom
			. = 1
	else if(top_atom.loc != source_turf)
		source_turf = top_atom.loc
		. = 1

	if(source_atom.light_power != light_power)
		light_power = source_atom.light_power
		. = 1

	if(source_atom.light_range != light_range)
		light_range = source_atom.light_range
		. = 1

	if(light_range && light_power && !applied)
		. = 1

	if(source_atom.light_color != light_color)
		light_color = source_atom.light_color
		parse_light_color()
		. = 1

// Decompile the hexadecimal colour into lumcounts of each perspective.
/datum/light_source/proc/parse_light_color()
	if(light_color)
		lum_r = GetRedPart(light_color) / 255
		lum_g = GetGreenPart(light_color) / 255
		lum_b = GetBluePart(light_color) / 255
	else
		lum_r = 1
		lum_g = 1
		lum_b = 1

// This is the define used to calculate falloff.
#if LIGHTING_FALLOFF == 1 //circular
  #define LUM_DISTANCE(swapvar, O, T) swapvar = (O.x - T.x)**2 + (O.y - T.y)**2 + LIGHTING_HEIGHT
  #if LIGHTING_LAMBERTIAN == 1
    #define LUM_ATTENUATION(swapvar) swapvar = CLAMP01((1 - CLAMP01(sqrt(swapvar) / max(1,light_range))) * (1 / sqrt(swapvar + 1)))
  #else
    #define LUM_ATTENUATION(swapvar) swapvar = 1 - CLAMP01(sqrt(swapvar) / max(1,light_range))
  #endif
#elif LIGHTING_FALLOFF == 2 //square
  #define LUM_DISTANCE(swapvar, O, T) swapvar = abs(O.x - T.x) + abs(O.y - T.y) + LIGHTING_HEIGHT
  #if LIGHTING_LAMBERTIAN == 1
    #define LUM_ATTENUATION(swapvar) swapvar = CLAMP01((1 - CLAMP01(swapvar / max(1,light_range))) * (1 / sqrt(swapvar**2 + 1)))
  #else
    #define LUM_ATTENUATION(swapvar) swapvar = CLAMP01(swapvar / max(1,light_range))
  #endif
#endif

#define LUM_FALLOFF(swapvar, O, T) \
  LUM_DISTANCE(swapvar, O, T); \
  LUM_ATTENUATION(swapvar);

// Macro that applies light to a new turf.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.

#define APPLY_TURF(T)						\
	if(T.lighting_overlay)					\
	{										\
		LUM_FALLOFF(., T, source_turf);		\
											\
		if(!.)								\
		{									\
			continue;						\
		}									\
		. *= light_power;					\
		. = round(., LIGHTING_ROUND_VALUE);	\
											\
		effect_str[T] = .;					\
											\
		T.lighting_overlay.update_lumcount	\
		(									\
			applied_lum_r * .,				\
			applied_lum_g * .,				\
			applied_lum_b * .,				\
		);									\
	}										\
	else									\
	{										\
		effect_str[T] = 0;					\
	}										\
											\
	if(!T.affecting_lights)					\
	{										\
		T.affecting_lights = list();		\
	}										\
											\
	T.affecting_lights	+= src;				\

// Removes a turf from effect.
// Opposite of the above.

#define REMOVE_TURF(T)						\
	if(T.affecting_lights)					\
	{										\
		T.affecting_lights -= src;			\
	}										\
											\
	if(T.lighting_overlay)					\
	{										\
		var/str = effect_str[T];			\
		T.lighting_overlay.update_lumcount	\
		(									\
			-str * applied_lum_r,			\
			-str * applied_lum_g,			\
			-str * applied_lum_b			\
		);									\
	}										\

// Base proc to aply lighting.
/datum/light_source/proc/apply_lum()
	applied = 1

	// Keep track of the last applied lum values so that the lighting can be reversed
	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	if(istype(source_turf))
		// We need a special function "dview" here to calculate view, as certain tiles might be unilluminated, which will cause them to not be seen by reguler view().
		// There is a special macro "FOR_DVIEW" here, as doing for(type in view) only views that specific type.
		FOR_DVIEW(var/turf/T, light_range, source_turf, INVISIBILITY_LIGHTING)
			APPLY_TURF(T)

// Opposite of the above.
/datum/light_source/proc/remove_lum()
	applied = 0

	for(var/turf/T in effect_str)
		REMOVE_TURF(T)

	effect_str.Cut()

// Smartly updates the lighting, only removes lum from and adds lum to turfs that actually got changed.
// This is for lights that need to reconsider due to nearby opacity changes.
/datum/light_source/proc/smart_vis_update()
	var/list/view[0]
	FOR_DVIEW(var/turf/T, light_range, source_turf, 0)	// We're only looking for turfs.
		view += T	//Filter out turfs.

	// This is the part where we calculate new turfs (if any)
	var/list/new_turfs = view - effect_str // This will result with all the tiles that are added.
	for(var/turf/T in new_turfs)
		APPLY_TURF(T)

	var/list/old_turfs = effect_str - view
	for(var/turf/T in old_turfs)
		REMOVE_TURF(T)

		effect_str -= T

// Calculates lighting for an individual turf, used when a turf's lighting goes dynamic (construction of floors, for example.)
// Assumes the turf is visible and such.
// For the love of god don't call this proc when it's not needed! Lighting artifacts WILL happen!
/datum/light_source/proc/calc_turf(var/turf/T)
	if(T.lighting_overlay)
		LUM_FALLOFF(., T, source_turf)
		. *= light_power

		. = round(., LIGHTING_ROUND_VALUE)

		effect_str[T] = .
		// Since the applied_lum values are what are (later) removed by remove_lum.
		// Anything we apply to the lighting overlays HAS to match what remove_lum uses.
		T.lighting_overlay.update_lumcount(
			applied_lum_r * .,
			applied_lum_g * .,
			applied_lum_b * .
		)
