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

	var/tmp/old_lum_r
	var/tmp/old_lum_g
	var/tmp/old_lum_b

	var/list/effect_str
	var/list/effect_turf

	var/applied

	var/vis_update		//Whetever we should smartly recalculate visibility. and then only update tiles that became (in) visible to us
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

	effect_str = list()
	effect_turf = list()

	update()

	return ..()

/datum/light_source/proc/destroy()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/destroy() called tick#: [world.time]")
	destroyed = 1
	force_update()
	if(source_atom) source_atom.light_sources -= src
	if(top_atom) top_atom.light_sources -= src

/datum/light_source/proc/update(atom/new_top_atom)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/update() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/force_update() called tick#: [world.time]")
	force_update = 1
	if(!needs_update)
		needs_update = 1
		lighting_update_lights += src

/datum/light_source/proc/vis_update()
	if(!needs_update)
		needs_update = 1
		lighting_update_lights += src

	vis_update = 1

/datum/light_source/proc/check()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/check() called tick#: [world.time]")
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

	if(. || source_atom.light_color != light_color)//Save the old lumcounts if we need to update, if the colour changed DO IT BEFORE we parse the colour and LOSE the old lumcounts!
		old_lum_r = lum_r
		old_lum_g = lum_g
		old_lum_b = lum_b

	if(source_atom.light_color != light_color)
		light_color = source_atom.light_color
		parse_light_color()
		. = 1

/datum/light_source/proc/parse_light_color()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/parse_light_color() called tick#: [world.time]")
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
  writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/falloff() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/apply_lum() called tick#: [world.time]")
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

				. = round(., LIGHTING_ROUND_VALUE)	//Screw sinking points.

				effect_str += .

				T.lighting_overlay.update_lumcount(
					lum_r * .,
					lum_g * .,
					lum_b * .
				)

			else
				effect_str += 0

			if(!T.affecting_lights)
				T.affecting_lights = list()

			T.affecting_lights += src
			effect_turf += T

/datum/light_source/proc/remove_lum()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/remove_lum() called tick#: [world.time]")
	applied = 0

	var/i = 1
	for(var/turf/T in effect_turf)
		if(T.affecting_lights)
			T.affecting_lights -= src

		if(T.lighting_overlay)
			var/str = effect_str[i]
			T.lighting_overlay.update_lumcount(-str * old_lum_r, -str * old_lum_g, -str * old_lum_b)

		i++

	effect_str.Cut()
	effect_turf.Cut()

//Smartly updates the lighting, only removes lum from and adds lum to turfs that actually got changed.
//This is for lights that need to reconsider due to nearby opacity changes.
//Stupid dumb copy pasta because BYOND and speed.
/datum/light_source/proc/smart_vis_update()
	var/list/view[0]
	for(var/turf/T in dview(light_range, source_turf, INVISIBILITY_LIGHTING))
		view += T	//Filter out turfs.

	//This is the part where we calculate new turfs (if any)
	var/list/new_turfs = view - effect_turf //This will result with all the tiles that are added.
	for(var/turf/T in new_turfs)
		//Big huge copy paste from apply_lum() incoming because screw unreadable defines and screw proc call overhead.
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

			. = round(., LIGHTING_ROUND_VALUE)

			effect_str += .

			T.lighting_overlay.update_lumcount(
				lum_r * .,
				lum_g * .,
				lum_b * .
			)

		else
			effect_str += 0

		if(!T.affecting_lights)
			T.affecting_lights = list()

		T.affecting_lights += src
		effect_turf += T

	var/list/old_turfs = effect_turf - view
	for(var/turf/T in old_turfs)
		//Insert not-so-huge copy paste from remove_lum().
		var/idx = effect_turf.Find(T) //Get the index, luckily Find() is cheap in small lists like this. (with small I mean under a couple thousand len)
		if(T.affecting_lights)
			T.affecting_lights -= src

		if(T.lighting_overlay)
			var/str = effect_str[idx]
			T.lighting_overlay.update_lumcount(-str * lum_r, -str * lum_g, -str * lum_b)

		effect_turf.Cut(idx, idx + 1)
		effect_str.Cut(idx, idx + 1)
