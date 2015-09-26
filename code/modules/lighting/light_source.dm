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

	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

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
		effect_str += .;					\
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
		effect_str += 0;					\
	}										\
											\
	if(!T.affecting_lights)					\
	{										\
		T.affecting_lights = list();		\
	}										\
											\
	T.affecting_lights	+= src;				\
	effect_turf			+= T;				\

#define REMOVE_TURF(T, i)					\
	if(T.affecting_lights)					\
	{										\
		T.affecting_lights -= src;			\
	}										\
											\
	if(T.lighting_overlay)					\
	{										\
		var/str = effect_str[i];			\
		T.lighting_overlay.update_lumcount	\
		(									\
			-str * applied_lum_r,			\
			-str * applied_lum_g,			\
			-str * applied_lum_b			\
		);									\
	}										\
	
/datum/light_source/proc/apply_lum()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/apply_lum() called tick#: [world.time]")
	applied = 1

	//Keep track of the last applied lum values so that the lighting can be reversed
	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	if(istype(source_turf))
		FOR_DVIEW(var/turf/T, light_range, source_turf, INVISIBILITY_LIGHTING)
			APPLY_TURF(T)

/datum/light_source/proc/remove_lum()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/light_source/proc/remove_lum() called tick#: [world.time]")
	applied = 0

	var/i = 1
	for(var/turf/T in effect_turf)
		REMOVE_TURF(T, i)

		i++

	effect_str.Cut()
	effect_turf.Cut()

//Smartly updates the lighting, only removes lum from and adds lum to turfs that actually got changed.
//This is for lights that need to reconsider due to nearby opacity changes.
//Stupid dumb copy pasta because BYOND and speed.
/datum/light_source/proc/smart_vis_update()
	var/list/view[0]
	FOR_DVIEW(var/turf/T, light_range, source_turf, 0)	//We're only looking for turfs.
		view += T	//Filter out turfs.

	//This is the part where we calculate new turfs (if any)
	var/list/new_turfs = view - effect_turf //This will result with all the tiles that are added.
	for(var/turf/T in new_turfs)
		APPLY_TURF(T)

	var/list/old_turfs = effect_turf - view
	for(var/turf/T in old_turfs)
		//Insert not-so-huge copy paste from remove_lum().
		var/idx = effect_turf.Find(T) //Get the index, luckily Find() is cheap in small lists like this. (with small I mean under a couple thousand len)
		REMOVE_TURF(T, idx)

		effect_turf.Cut(idx, idx + 1)
		effect_str.Cut(idx, idx + 1)

//Whoop yet not another copy pasta because speed ~~~~BYOND.
//Calculates lighting for an individual turf, used when a turf's lighting goes dynamic (construction of floors, for example.)
//Assumes the turf is visible and such.
//For the love of god don't call this proc when it's not needed! Lighting artifacts WILL happen!
/datum/light_source/proc/calc_turf(var/turf/T)
	var/idx = effect_turf.Find(T)
	if(!idx)
		return	//WHY.

	if(T.lighting_overlay)
		LUM_FALLOFF(., T, source_turf)
		. *= light_power

		. = round(., LIGHTING_ROUND_VALUE)

		effect_str[idx] = .
		//Since the applied_lum values are what are (later) removed by remove_lum.
		//Anything we apply to the lighting overlays HAS to match what remove_lum uses.
		T.lighting_overlay.update_lumcount(
			applied_lum_r * .,
			applied_lum_g * .,
			applied_lum_b * .
		)
