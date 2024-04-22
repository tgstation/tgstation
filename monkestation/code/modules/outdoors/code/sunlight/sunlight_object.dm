//todo: handle moving sunlight turfs - see various uses of get_turf in lighting_object


/*
Sunlight System
	Objects + Details
		Sunlight Objects (this file)
			- Grayscale version of lighting_object
			- Has 3 states
				- SKY_BLOCKED  (0)
					- Turfs that have an opaque turf above them. Has no light themselves but is affected by SKY_VISIBLE_BORDER
				- SKY_VISIBLE (1)
					- Turfs that with no opaque turfs above it (no roof, glass roof, etc), with no neighbouring SKY_BLOCKED tiles
					  Emits no light, but is fully white to display the overlay color
				- SKY_VISIBLE_BORDER  (2)
					- Turfs that with no opaque turfs above it (no roof, glass roof, etc), which neighbour at least one SKY_BLOCKED tile.
				     Emits light to SKY_BLOCKED tiles, and fully white to display the overlay color
*/

// Keep in mind. Lighting corners accept the bottom left (northwest) set of cords to them as input
#define GENERATE_MISSING_CORNERS(gen_for) \
	if (!gen_for.lighting_corner_NE) { \
		gen_for.lighting_corner_NE = new /datum/lighting_corner(gen_for.x, gen_for.y, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_SE) { \
		gen_for.lighting_corner_SE = new /datum/lighting_corner(gen_for.x, gen_for.y - 1, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_SW) { \
		gen_for.lighting_corner_SW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y - 1, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_NW) { \
		gen_for.lighting_corner_NW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y, gen_for.z); \
	} \
	gen_for.lighting_corners_initialised = TRUE;

/atom/movable/outdoor_effect
	name = ""
	mouse_opacity = 0
	anchored = 1

	/* misc vars */
	var/mutable_appearance/sunlight_overlay
	var/state 					 = SKY_VISIBLE	// If we can see the see the sky, are blocked, or we have a blocked neighbour (SKY_BLOCKED/VISIBLE/VISIBLE_BORDER)
	var/weatherproof			 = FALSE        // If we have a weather overlay
	var/turf/source_turf
	var/list/datum/lighting_corner/affecting_corners

/atom/movable/outdoor_effect/Destroy(force)
	if (!force)
		return QDEL_HINT_LETMELIVE

	//If we are a source of light - disable it, to fix out corner refs
	disable_sunlight()

	//Remove ourselves from our turf
	if(source_turf && source_turf.outdoor_effect == src)
		source_turf.outdoor_effect = null


	return ..()



/atom/movable/outdoor_effect/Initialize(mapload)
	. = ..()
	source_turf = loc
	if (source_turf.outdoor_effect)
		qdel(source_turf.outdoor_effect, force = TRUE)
		source_turf.outdoor_effect = null //No qdel_null force
	source_turf.outdoor_effect = src

/atom/movable/outdoor_effect/proc/disable_sunlight()
	var/turf/T = list()
	for(var/datum/lighting_corner/C in affecting_corners)
		LAZYREMOVE(C.globAffect, src)
		C.get_sunlight_falloff()
		if( C.master_NE)
			T |= C.master_NE
		if (C.master_SE)
			T |= C.master_SE
		if (C.master_SW)
			T |= C.master_SW
		if (C.master_NW)
			T |= C.master_NW
	T |= source_turf /* get our calculated indoor lighting */
	GLOB.SUNLIGHT_QUEUE_CORNER += T

	//Empty our affecting_corners list
	affecting_corners = null

/atom/movable/outdoor_effect/proc/process_state()
	if(source_turf != loc)
		var/turf/turf = get_turf(src)
		if(turf.turf_flags & TURF_WEATHER)
			turf.turf_flags &= ~TURF_WEATHER
		Move(source_turf)
	switch(state)
		if(SKY_BLOCKED)
			disable_sunlight() /* Do our indoor processing */
		if(SKY_VISIBLE_BORDER)
			calc_sunlight_spread()

#define hardSun 0.5 /* our hyperboloidy modifyer funky times - I wrote this in like, 2020 and can't remember how it works - I think it makes a 3D cone shape with a flat top */
/* calculate the indoor corners we are affecting */
#define SUN_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 - hardSun) / max(1, GLOB.GLOBAL_LIGHT_RANGE)))


/atom/movable/outdoor_effect/proc/calc_sunlight_spread()

	var/list/turf/turfs                    = list()
	var/datum/lighting_corner/C
	var/turf/T
	var/list/tempMasterList = list() /* to mimimize double ups */
	var/list/corners  = list() /* corners we are currently affecting */

	//Set lum so we can see things
	var/oldLum = luminosity
	luminosity = GLOB.GLOBAL_LIGHT_RANGE

	for(T in view(CEILING(GLOB.GLOBAL_LIGHT_RANGE, 1), source_turf))
		if(IS_OPAQUE_TURF(T)) /* get_corners used to do opacity checks for arse */
			continue
		if (!T.lighting_corners_initialised)
			GENERATE_MISSING_CORNERS(T)
		corners |= T.lighting_corner_NE
		corners |= T.lighting_corner_SE
		corners |= T.lighting_corner_SW
		corners |= T.lighting_corner_NW
		turfs += T

	//restore lum
	luminosity = oldLum

	/* fix up the lists */
	/* add ourselves and our distance to the corner */
	LAZYINITLIST(affecting_corners)
	var/list/L = corners - affecting_corners
	affecting_corners += L
	for (C in L)
		LAZYSET(C.globAffect, src, SUN_FALLOFF(C,source_turf))
		if(C.globAffect[src] > C.sun_falloff) /* if are closer than current dist, update the corner */
			C.sun_falloff = C.globAffect[src]
			if (C.master_NE)
				tempMasterList |= C.master_NE
			if (C.master_SE)
				tempMasterList |= C.master_SE
			if (C.master_SW)
				tempMasterList |= C.master_SW
			if (C.master_NW)
				tempMasterList |= C.master_NW

	L = affecting_corners - corners // Now-gone corners, remove us from the affecting.
	affecting_corners -= L
	for (C in L)
		LAZYREMOVE(C.globAffect, src)
		C.get_sunlight_falloff()
		if (C.master_NE)
			tempMasterList |= C.master_NE
		if (C.master_SE)
			tempMasterList |= C.master_SE
		if (C.master_SW)
			tempMasterList |= C.master_SW
		if (C.master_NW)
			tempMasterList |= C.master_NW

	GLOB.SUNLIGHT_QUEUE_CORNER += tempMasterList /* update the boys */

/* Related object changes */
/* I moved this here to consolidate sunlight changes as much as possible, so its easily disabled */

/* area fuckery */
/area/var/turf/pseudo_roof

/* turf fuckery */
/turf/var/tmp/atom/movable/outdoor_effect/outdoor_effect /* a turf's sunlight overlay */
/turf/var/turf/pseudo_roof /* our roof turf - may be a path for top z level, or a ref to the turf above*/

//non-weatherproof turfs
/turf/var/weatherproof = TRUE
/turf/open/space/weatherproof = FALSE
/turf/open/floor/plating/ocean/weatherproof = FALSE
/turf/open/openspace/weatherproof = FALSE

/* check ourselves and neighbours to see what outdoor effects we need */
/* turf won't initialize an outdoor_effect if sky_blocked*/
/turf/proc/get_sky_and_weather_states()
	var/TempState

	var/roofStat = get_ceiling_status()
	var/tempRoofStat
	if(roofStat["SKYVISIBLE"])
		TempState = SKY_VISIBLE
		for(var/turf/CT in RANGE_TURFS(1, src))
			tempRoofStat = CT.get_ceiling_status()
			if(!tempRoofStat["SKYVISIBLE"]) /* if we have a single roofed/indoor neighbour, we are a border */
				TempState = SKY_VISIBLE_BORDER
				break
	else /* roofed, so turn off the lights */
		TempState = SKY_BLOCKED

	/* if border or indoor, initialize. Set sunlight state if valid */
	if(!outdoor_effect && (TempState <> SKY_BLOCKED || !roofStat["WEATHERPROOF"]))
		outdoor_effect = new /atom/movable/outdoor_effect(src)
	if(outdoor_effect)
		outdoor_effect.state = TempState
		outdoor_effect.weatherproof = roofStat["WEATHERPROOF"]
		UnregisterSignal(SSdcs, COMSIG_GLOB_WEATHER_EFFECT)
		if(!outdoor_effect.weatherproof)
			turf_flags |= TURF_WEATHER
			//RegisterSignal(SSdcs, COMSIG_GLOB_WEATHER_EFFECT, PROC_REF(apply_weather_effect))

/* runs up the Z stack for this turf, returns a assoc (SKYVISIBLE, WEATHERPROOF)*/
/* pass recursion_started=TRUE when we are checking our ceiling's stats */
/turf/proc/get_ceiling_status(recursion_started = FALSE)
	. = list()
	//Check yourself (before you wreck yourself)
	if(isclosedturf(src)) //Closed, but we might be transparent
		.["SKYVISIBLE"]   =  istransparentturf(src) // a column of glass should still let the sun in
		.["WEATHERPROOF"] =  TRUE
	else
		if(recursion_started)
			// This src is acting as a ceiling - so if we are a floor we weatherproof + block the sunlight of our down-Z turf
			.["SKYVISIBLE"]   = istransparentturf(src) //If we are glass floor, we don't block
			.["WEATHERPROOF"] = weatherproof //If we are air or space, we aren't weatherproof
		else //We are open, so assume open to the elements
			.["SKYVISIBLE"]   = TRUE
			.["WEATHERPROOF"] = FALSE

	// Early leave if we can't see the sky - if we are an opaque turf, we already know the results
	// I can't think of a case where we would have a turf that would block light but let weather effects through - Maybe a vent?
	// fix this if that is the case
	if(!.["SKYVISIBLE"])
		return .

	//Ceiling Check
	// Psuedo-roof, for the top of the map (no actual turf exists up here) -- We assume these are solid, if you add glass pseudo_roofs then fix this
	if (pseudo_roof)
		.["SKYVISIBLE"]   =  FALSE
		.["WEATHERPROOF"] =  TRUE
	else
		// EVERY turf must be transparent for sunlight - so &=
		// ANY turf must be closed for weatherproof - so |=
		var/turf/ceiling = get_step_multiz(src, UP)
		if(ceiling)
			var/list/ceilingStat = ceiling.get_ceiling_status(TRUE) //Pass TRUE because we are now acting as a ceiling
			.["SKYVISIBLE"]   &= ceilingStat["SKYVISIBLE"]
			.["WEATHERPROOF"] |= ceilingStat["WEATHERPROOF"]

	var/area/turf_area = get_area(src)
	var/turf/above_turf = GET_TURF_ABOVE(src)
	if((!isspaceturf(src) && !istype(src, /turf/open/floor/plating/ocean) && !above_turf && !SSmapping.level_trait(src.z, ZTRAIT_UP) && !turf_area.outdoors && !turf_area.false_outdoors) || (!SSmapping.level_trait(src.z, ZTRAIT_DAYCYCLE) && !SSmapping.level_trait(src.z, ZTRAIT_STARLIGHT)))
		.["SKYVISIBLE"]   =  FALSE
		.["WEATHERPROOF"] =  TRUE

/turf/proc/apply_weather_effect(datum/source, datum/weather_effect/effect)
	SIGNAL_HANDLER
	if(!weather_affectable || !prob(effect.probability))
		return

	effect.effect_affect(src)

/* moved this out of reconsider lights so we can call it in multiz refresh  */
/turf/proc/reconsider_sunlight()
	if(!SSlighting.initialized)
		return

	/* remove roof refs (not path for psuedo roof) so we can recalculate it */
	if(pseudo_roof && !ispath(pseudo_roof))
		pseudo_roof = null

	var/atom/movable/outdoor_effect/S
	var/list/SunlightUpdates = list()

	//Add ourselves (we might not have corners initialized, and this handles it)
	SunlightUpdates += src

	//AHHHHGGGGGHHHHHHHHHHHHHHH
	if(lighting_corner_NE)
		if (lighting_corner_NE.master_NE)
			SunlightUpdates |= lighting_corner_NE.master_NE
		for(S in lighting_corner_NE.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_NE.master_SE)
			SunlightUpdates |= lighting_corner_NE.master_SE
		for(S in lighting_corner_NE.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_NE.master_SW)
			SunlightUpdates |= lighting_corner_NE.master_SW
		for(S in lighting_corner_NE.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_NE.master_NW)
			SunlightUpdates |= lighting_corner_NE.master_NW
		for(S in lighting_corner_NE.globAffect)
			SunlightUpdates |= S.source_turf

	if(lighting_corner_SE)
		if (lighting_corner_SE.master_NE)
			SunlightUpdates |= lighting_corner_SE.master_NE
		for(S in lighting_corner_SE.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_SE.master_SE)
			SunlightUpdates |= lighting_corner_SE.master_SE
		for(S in lighting_corner_SE.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_SE.master_SW)
			SunlightUpdates |= lighting_corner_SE.master_SW
		for(S in lighting_corner_SE.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_SE.master_NW)
			SunlightUpdates |= lighting_corner_SE.master_NW
		for(S in lighting_corner_SE.globAffect)
			SunlightUpdates |= S.source_turf

	if(lighting_corner_SW)
		if (lighting_corner_SW.master_NE)
			SunlightUpdates |= lighting_corner_SW.master_NE
		for(S in lighting_corner_SW.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_SW.master_SE)
			SunlightUpdates |= lighting_corner_SW.master_SE
		for(S in lighting_corner_SW.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_SW.master_SW)
			SunlightUpdates |= lighting_corner_SW.master_SW
		for(S in lighting_corner_SW.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_SW.master_NW)
			SunlightUpdates |= lighting_corner_SW.master_NW
		for(S in lighting_corner_SW.globAffect)
			SunlightUpdates |= S.source_turf

	if(lighting_corner_NW)
		if (lighting_corner_NW.master_NE)
			SunlightUpdates |= lighting_corner_NW.master_NE
		for(S in lighting_corner_NW.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_NW.master_SE)
			SunlightUpdates |= lighting_corner_NW.master_SE
		for(S in lighting_corner_NW.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_NW.master_SW)
			SunlightUpdates |= lighting_corner_NW.master_SW
		for(S in lighting_corner_NW.globAffect)
			SunlightUpdates |= S.source_turf

		if (lighting_corner_NW.master_NW)
			SunlightUpdates |= lighting_corner_NW.master_NW
		for(S in lighting_corner_NW.globAffect)
			SunlightUpdates |= S.source_turf

	GLOB.SUNLIGHT_QUEUE_WORK += SunlightUpdates

	var/turf/T = GET_TURF_BELOW(src)
	if(T)
		T.reconsider_sunlight()

/* corner fuckery */
/datum/lighting_corner/var/list/globAffect = list() /* list of sunlight objects affecting this corner */
/datum/lighting_corner/var/sun_falloff = 0 /* smallest distance to sunlight turf, for sunlight falloff */

/* loop through and find our strongest sunlight value */
/datum/lighting_corner/proc/get_sunlight_falloff()
	sun_falloff = 0

	var/atom/movable/outdoor_effect/S
	for(S in globAffect)
		sun_falloff = sun_falloff < globAffect[S] ? globAffect[S] : sun_falloff




/* Effect Fuckery */
/* these bits are to set the roof on a top-z level, as there is no turf above to act as a roof */
/obj/effect/mapping_helpers/sunlight/pseudo_roof_setter
	var/turf/pseudo_roof

/obj/effect/mapping_helpers/sunlight/pseudo_roof_setter/Initialize(mapload)
	. = ..()
	// Disabled mapload catch - somebody might want to wangle this l8r
	// if(!mapload)
	// 	log_mapping("[src] spawned outside of mapload!")
	// 	return
	if(isturf(loc) && !get_step_multiz(loc, UP))
		var/turf/T = loc
		T.pseudo_roof = pseudo_roof



#undef SUN_FALLOFF
#undef hardSun
#undef GENERATE_MISSING_CORNERS
