/datum/light_source
	var/atom/top_atom
	var/atom/source_atom

	var/turf/source_turf
	var/light_power
	var/light_range
	var/light_color // string, decomposed by parse_light_color()

	var/lum_r
	var/lum_g
	var/lum_b

	var/list/effect_r
	var/list/effect_g
	var/list/effect_b
	var/list/effect_turf

	var/applied

	var/needs_update
	var/destroyed
	var/force_update

/datum/light_source/New(atom/owner, atom/top)
	source_atom = owner
	if(!source_atom.light_sources) source_atom.light_sources = list()
	source_atom.light_sources += src
	top_atom = top
	if(top_atom != source_atom)
		if(!top.light_sources) top.light_sources = list()
		top_atom.light_sources += src

	source_turf = top_atom
	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	parse_light_color()

	effect_r = list()
	effect_g = list()
	effect_b = list()
	effect_turf = list()

	update()

	return ..()

/datum/light_source/proc/destroy()
	destroyed = 1
	force_update()
	if(source_atom) source_atom.light_sources -= src
	if(top_atom) top_atom.light_sources -= src

/datum/light_source/proc/update(atom/new_top_atom)
	if(new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom) top_atom.light_sources -= src
		top_atom = new_top_atom
		if(top_atom != source_atom)
			if(!top_atom.light_sources) top_atom.light_sources = list()
			top_atom.light_sources += src
	if(!needs_update)
		lighting_update_lights += src
		needs_update = 1

/datum/light_source/proc/force_update()
	force_update = 1
	if(!needs_update)
		needs_update = 1
		lighting_update_lights += src

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

	if(source_atom.light_color != light_color)
		light_color = source_atom.light_color
		parse_light_color()
		. = 1

	if(light_range && light_power && !applied)
		. = 1

/datum/light_source/proc/parse_light_color()
	if(light_color)
		lum_r = GetRedPart(light_color) / 255
		lum_g = GetGreenPart(light_color) / 255
		lum_b = GetBluePart(light_color) / 255
	else
		lum_r = 1
		lum_g = 1
		lum_b = 1

/*
/datum/light_source/proc/falloff(atom/movable/lighting_overlay/O)
  #if LIGHTING_FALLOFF == 1 // circular
	. = (O.x - source_turf.x)**2 + (O.y - source_turf.y)**2 + LIGHTING_HEIGHT
   #if LIGHTING_LAMBERTIAN == 1
	. = CLAMP01((1 - CLAMP01(sqrt(.) / light_range)) * (1 / (sqrt(. + 1))))
   #else
	. = 1 - CLAMP01(sqrt(.) / light_range)
   #endif

  #elif LIGHTING_FALLOFF == 2 // square
	. = abs(O.x - source_turf.x) + abs(O.y - source_turf.y) + LIGHTING_HEIGHT
   #if LIGHTING_LAMBERTIAN == 1
	. = CLAMP01((1 - CLAMP01(. / light_range)) * (1 / (sqrt(.)**2 + )))
   #else
	. = 1 - CLAMP01(. / light_range)
   #endif
  #endif
*/

/datum/light_source/proc/apply_lum()
	applied = 1
	if(istype(source_turf))
		for(var/turf/T in dview(light_range, source_turf, INVISIBILITY_LIGHTING))
			if(T.lighting_overlay)

			  #if LIGHTING_FALLOFF == 1 // circular
				. = (T.lighting_overlay.x - source_turf.x)**2 + (T.lighting_overlay.y - source_turf.y)**2 + LIGHTING_HEIGHT
			   #if LIGHTING_LAMBERTIAN == 1
				. = CLAMP01((1 - CLAMP01(sqrt(.) / light_range)) * (1 / (sqrt(. + 1))))
			   #else
				. = 1 - CLAMP01(sqrt(.) / light_range)
			   #endif

			  #elif LIGHTING_FALLOFF == 2 // square
				. = abs(T.lighting_overlay.x - source_turf.x) + abs(T.lighting_overlay.y - source_turf.y) + LIGHTING_HEIGHT
			   #if LIGHTING_LAMBERTIAN == 1
				. = CLAMP01((1 - CLAMP01(. / light_range)) * (1 / (sqrt(.)**2 + )))
			   #else
				. = 1 - CLAMP01(. / light_range)
			   #endif
			  #endif
				. *= light_power
				if(!.) //Don't add turfs that aren't affected to the affected turfs.
					continue

				effect_r[T.lighting_overlay] = round(lum_r * ., LIGHTING_ROUND_VALUE)
				effect_g[T.lighting_overlay] = round(lum_g * ., LIGHTING_ROUND_VALUE)
				effect_b[T.lighting_overlay] = round(lum_b * ., LIGHTING_ROUND_VALUE)

				T.lighting_overlay.update_lumcount(
					round(lum_r * ., LIGHTING_ROUND_VALUE),
					round(lum_g * ., LIGHTING_ROUND_VALUE),
					round(lum_b * ., LIGHTING_ROUND_VALUE)
				)

			if(!T.affecting_lights)
				T.affecting_lights = list()

			T.affecting_lights += src
			effect_turf += T

/datum/light_source/proc/remove_lum()
	applied = 0

	for(var/turf/T in effect_turf)
		if(T.affecting_lights)
			T.affecting_lights -= src

		if(T.lighting_overlay)
			T.lighting_overlay.update_lumcount(-effect_r[T.lighting_overlay], -effect_g[T.lighting_overlay], -effect_b[T.lighting_overlay])

	effect_r.Cut()
	effect_g.Cut()
	effect_b.Cut()
	effect_turf.Cut()
