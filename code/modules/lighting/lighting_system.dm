/*
	This is /tg/'s 'newer' lighting system. It's basically a combination of Forum_Account's and ShadowDarke's
	respective lighting libraries heavily modified by Carnwennan for /tg/station with further edits by
	MrPerson and MrStonedOne. Credits, where due, to them. Also big shoutout to Tobba for implementing Goonstation's
	lighting system which we now copy. Dunno how someone comes up with that kind of stuff without an example.
	I know I couldn't.

	Originally, like all other lighting libraries on BYOND, we used areas to render different hard-coded light levels.
	The idea was that this was cheaper than using objects. Well as it turns out, the cost of the system is primarily from the
	massive loops the system has to run, not from the areas or objects actually doing any work. Thus the newer system uses objects
	so we can have more lighting states and smooth transitions between them.

	This is a queueing system. Everytime we call a change to opacity or luminosity throwgh SetOpacity() or SetLuminosity(),
	we are simply updating variables and scheduling certain lights/turfs for an update. Actual updates are handled
	periodically by the SSlighting subsystem. Specifically, it runs check() on every light datum that ran changed().
	Then it runs redraw_lighting() on every turf that ran update_lumcount().

	Unlike our older system, there are hardcoded maximum luminosities (different for certain atoms).
	This is to cap the cost of creating lighting effects.
	(without this, an atom with luminosity of 20 would have to update 41^2 turfs!) :s

	Each light remembers the effect it casts on each turf. It reduces cost of removing lighting effects by a lot!

	Known Issues/TODO:
		Shuttles still do not have support for dynamic lighting (I hope to fix this at some point) -probably trivial now
		No directional lighting support. (prototype looked ugly)
		Colored lights
		Normalize lumcounts to be from 0 to 1 instead of 0 to 10 so LIGHTING_CALC is unnecessary
*/

#define LIGHTING_CIRCULAR 1									//Comment this out to use old square lighting effects.
#define LIGHTING_LAYER 15									//Drawing layer for lighting
#define LIGHTING_CAP 10										//The lumcount level at which we're fully lit.
#define LIGHTING_CALC(value) (value/LIGHTING_CAP)
#define LIGHTING_ICON 'icons/effects/alphacolors.dmi'
#define LIGHTING_ICON_STATE "lighting_corners"
#define LIGHTING_LUM_FOR_FULL_BRIGHT 6						//Anything who's lum is lower then this starts off less bright.
#define LIGHTING_MIN_RADIUS 4								//Lowest radius a light source can effect.

/datum/light_source
	var/atom/owner
	var/radius = 0
	var/luminosity = 0
	var/cap = 0
	var/changed = 0
	var/list/turfs_effect = list()
	var/list/turfs_direction = list()
	var/__x = 0		//x coordinate at last update
	var/__y = 0		//y coordinate at last update

/datum/light_source/New(atom/A)
	if(!istype(A))
		CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[A]' instead.")
	..()
	owner = A
	UpdateLuminosity(A.luminosity)

/datum/light_source/Destroy()
	if(owner && owner.light == src)
		remove_effect()
		owner.light = null
		owner.luminosity = 0
		owner = null
	if(changed)
		SSlighting.changed_lights -= src
	return ..()

/datum/light_source/proc/UpdateLuminosity(new_luminosity, new_cap)
	if(new_luminosity < 0)
		new_luminosity = 0

	if(luminosity == new_luminosity && (new_cap == null || cap == new_cap))
		return

	radius = max(LIGHTING_MIN_RADIUS, new_luminosity)
	radius = owner.get_light_range(radius)
	luminosity = new_luminosity
	owner.luminosity = radius
	if (new_cap != null)
		cap = new_cap

	changed()


//Check a light to see if its effect needs reprocessing. If it does, remove any old effect and create a new one
/datum/light_source/proc/check()
	if(!owner)
		remove_effect()
		return 0

	if(changed)
		changed = 0
		remove_effect()
		return add_effect()

	return 1

//Tell the lighting subsystem to check() next fire
/datum/light_source/proc/changed()
	if(!changed)
		changed = 1
		SSlighting.changed_lights |= src

//Remove current effect
/datum/light_source/proc/remove_effect().
	for(var/turf/T in turfs_effect)
		T.update_lumcount(-turfs_effect[T], turfs_direction[T])
		T.affecting_lights -= src

		for(var/thing in RANGE_TURFS(1, T))
			var/turf/neighbor = thing
			if(neighbor == T)
				continue
			if(!neighbor.lighting_changed)
				neighbor.update_lumcount(0, 0)

	turfs_effect.Cut()
	turfs_direction.Cut()

//Apply a new effect.
/datum/light_source/proc/add_effect()
	__x = owner.x
	__y = owner.y
	// only do this if the light is turned on and is on the map
	if(!owner || !owner.loc)
		return 0
	if(radius <= 0 || luminosity <= 0)
		return 0

	var/turf/To = get_turf(owner)

	for(var/atom/movable/AM in To)
		if(AM == owner)
			continue
		if(AM.opacity)
			return 0

	var/center_strength = 0
	if (cap <= 0)
		center_strength = LIGHTING_CAP/LIGHTING_LUM_FOR_FULL_BRIGHT*(luminosity)
	else
		center_strength = cap

	for(var/turf/T in view(radius+1, To))
		//This will fuck up for turfs on the edge of the map. Would rather no op than throw exceptions
		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			continue
#ifdef LIGHTING_CIRCULAR
		var/distance = cheap_hypotenuse(T.x, T.y, __x, __y)
#else
		var/distance = max(abs(T,x - __x), abs(T.y - __y))
#endif
		var/delta_lumcount = Clamp(center_strength * (radius - distance) / radius, 0, LIGHTING_CAP)

		if(delta_lumcount <= 0)
			continue

		var/list/neighbors = RANGE_TURFS(1, T)
		var/directions = N_NORTHWEST|N_NORTHEAST|N_SOUTHEAST|N_SOUTHWEST

		for(var/thing in neighbors)
			var/turf/neighbor = thing
			if(neighbor == T)
				continue
			if(!neighbor.lighting_changed)
				neighbor.update_lumcount(0, 0)

		if(T.opacity) //sorry for this but I'm looking for cheap, not good
			var/turf/neighbor
			switch(get_dir(T, To))
				if(NORTH)
					directions = N_NORTHWEST|N_NORTHEAST
				if(EAST)
					directions = N_NORTHEAST|N_SOUTHEAST
				if(SOUTH)
					directions = N_SOUTHEAST|N_SOUTHWEST
				if(WEST)
					directions = N_SOUTHWEST|N_NORTHWEST
				if(NORTHWEST)
					directions = N_NORTHWEST
					neighbor = neighbors[8] //magic numbers, make them defines later
					if(!neighbor.opacity)
						directions |= N_NORTHEAST
					neighbor = neighbors[4]
					if(!neighbor.opacity)
						directions |= N_SOUTHWEST
				if(NORTHEAST)
					directions = N_NORTHEAST
					neighbor = neighbors[8]
					if(!neighbor.opacity)
						directions |= N_NORTHWEST
					neighbor = neighbors[6]
					if(!neighbor.opacity)
						directions |= N_SOUTHEAST
				if(SOUTHEAST)
					directions = N_SOUTHEAST
					neighbor = neighbors[2]
					if(!neighbor.opacity)
						directions |= N_SOUTHWEST
					neighbor = neighbors[6]
					if(!neighbor.opacity)
						directions |= N_NORTHEAST
				if(SOUTHWEST)
					directions = N_SOUTHWEST
					neighbor = neighbors[2]
					if(!neighbor.opacity)
						directions |= N_SOUTHEAST
					neighbor = neighbors[4]
					if(!neighbor.opacity)
						directions |= N_NORTHWEST

		turfs_effect[T] = delta_lumcount
		turfs_direction[T] = directions
		T.update_lumcount(delta_lumcount, directions)

		if(!T.affecting_lights)
			T.affecting_lights = list()
		T.affecting_lights |= src

	return 1

/atom
	var/datum/light_source/light


//Turfs with opacity when they are constructed will trigger nearby lights to update
//Turfs and atoms with luminosity when they are constructed will create a light_source automatically
/turf/New()
	..()
	if(luminosity)
		light = new(src)

//Movable atoms with opacity when they are constructed will trigger nearby lights to update
//Movable atoms with luminosity when they are constructed will create a light_source automatically
/atom/movable/New()
	..()
	if(opacity)
		UpdateAffectingLights()
	if(luminosity)
		light = new(src)

//Objects with opacity will trigger nearby lights to update at next SSlighting fire
/atom/movable/Destroy()
	qdel(light)
	if(opacity)
		UpdateAffectingLights()
	return ..()

//Objects with opacity will trigger nearby lights of the old location to update at next SSlighting fire
/atom/movable/Moved(atom/OldLoc, Dir)
	if(isturf(loc))
		if(opacity)
			OldLoc.UpdateAffectingLights()
		else
			if(light)
				light.changed()
	return ..()

//Sets our luminosity.
//If we have no light it will create one.
//If we are setting luminosity to 0 the light will be cleaned up by the controller and garbage collected once all its
//queues are complete.
//if we have a light already it is merely updated, rather than making a new one.
//The second arg allows you to scale the light cap for calculating falloff.

/atom/proc/SetLuminosity(new_luminosity, new_cap)
	if (!light)
		if (new_luminosity <= 0)
			return
		light = new(src)

	light.UpdateLuminosity(new_luminosity, new_cap)

/atom/proc/AddLuminosity(delta_luminosity)
	if(light)
		SetLuminosity(light.luminosity + delta_luminosity)
	else
		SetLuminosity(delta_luminosity)

/area/SetLuminosity(new_luminosity)			//we don't want dynamic lighting for areas
	luminosity = !!new_luminosity


//change our opacity (defaults to toggle), and then update all lights that affect us.
/atom/proc/SetOpacity(new_opacity)
	if(new_opacity == null)
		new_opacity = !opacity			//default = toggle opacity
	else if(opacity == new_opacity)
		return 0						//opacity hasn't changed! don't bother doing anything
	opacity = new_opacity				//update opacity, the below procs now call light updates.
	UpdateAffectingLights()
	return 1

/atom/movable/light
	icon = LIGHTING_ICON
	icon_state = LIGHTING_ICON_STATE
	layer = LIGHTING_LAYER
	mouse_opacity = 0
	blend_mode = BLEND_OVERLAY
	invisibility = INVISIBILITY_LIGHTING
	luminosity = 0
	infra_luminosity = 1
	anchored = 1

/atom/movable/light/Destroy()
	return QDEL_HINT_LETMELIVE

/atom/movable/light/Move()
	return 0

/turf
	var/lighting_lumcount = 0
	var/lighting_changed = 0
	var/atom/movable/light/lighting_object //Will be null for space turfs and anything in a static lighting area
	var/list/affecting_lights			//not initialised until used (even empty lists reserve a fair bit of memory)
	var/list/lit_corners = list("NORTHWEST"=0,"NORTHEAST"=0,"SOUTHEAST"=0,"SOUTHWEST"=0)

/turf/ChangeTurf(path)
	if(!path || path == type) //Sucks this is here but it would cause problems otherwise.
		return ..()

	for(var/obj/effect/decal/cleanable/decal in src.contents)
		qdel(decal)

	if(light)
		qdel(light)

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/oldbaseturf = baseturf

	var/list/our_lights //reset affecting_lights if needed
	var/list/our_lit_corners = lit_corners.Copy()
	if(opacity != initial(path:opacity) && old_lumcount)
		UpdateAffectingLights()

	if(affecting_lights)
		our_lights = affecting_lights.Copy()

	. = ..() //At this point the turf has changed

	affecting_lights = our_lights
	lit_corners = our_lit_corners

	lighting_lumcount += old_lumcount
	baseturf = oldbaseturf
	lighting_object = locate() in src
	init_lighting()

	for(var/turf/space/S in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		S.update_starlight()

/turf/proc/update_lumcount(amount, dirs)
	if(dirs)
		if(dirs & N_NORTHWEST)
			lit_corners["NORTHWEST"] += amount
		if(dirs & N_NORTHEAST)
			lit_corners["NORTHEAST"] += amount
		if(dirs & N_SOUTHEAST)
			lit_corners["SOUTHEAST"] += amount
		if(dirs & N_SOUTHWEST)
			lit_corners["SOUTHWEST"] += amount
	lighting_lumcount += amount
	if(!lighting_changed)
		SSlighting.changed_turfs += src
		lighting_changed = 1

/turf/proc/init_lighting()
	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(A) || istype(src, /turf/space))
		lighting_changed = 0
		if(lighting_object)
			lighting_object.alpha = 0
			lighting_object = null
	else
		if(!lighting_object)
			lighting_object = new (src)
		lighting_object.alpha = 255
		redraw_lighting(1)

/turf/space/init_lighting()
	. = ..()
	if(config.starlight)
		update_starlight()

#define MEAN4(val1, val2, val3, val4) ((val1+val2+val3+val4)/4)

/turf/proc/redraw_lighting(instantly = 0)
	if(lighting_object)
		var/list/neighbors = RANGE_TURFS(1, src)
		var/turf/N = neighbors[8]
		var/turf/E = neighbors[6]
		var/turf/S = neighbors[2]
		var/turf/W = neighbors[4]
		var/turf/NW = neighbors[7]
		var/turf/NE = neighbors[9]
		var/turf/SE = neighbors[3]
		var/turf/SW = neighbors[1]

		var/list/Nlights = N.lit_corners; var/list/Elights = E.lit_corners
		var/list/Slights = S.lit_corners; var/list/Wlights = W.lit_corners
		var/list/mylights = lit_corners

		var/list/color_matrix = list(
0,0,0,-LIGHTING_CALC(MEAN4(mylights["NORTHWEST"],Nlights["SOUTHWEST"],Wlights["NORTHEAST"],NW.lit_corners["SOUTHEAST"])),
0,0,0,-LIGHTING_CALC(MEAN4(mylights["NORTHEAST"],Nlights["SOUTHEAST"],Elights["NORTHWEST"],NE.lit_corners["SOUTHWEST"])),
0,0,0,-LIGHTING_CALC(MEAN4(mylights["SOUTHEAST"],Slights["NORTHEAST"],Elights["SOUTHWEST"],SE.lit_corners["NORTHWEST"])),
0,0,0,-LIGHTING_CALC(MEAN4(mylights["SOUTHWEST"],Slights["NORTHWEST"],Wlights["SOUTHEAST"],SW.lit_corners["NORTHEAST"])),
0,0,0,1
		)

		if(instantly)
			lighting_object.color = color_matrix
		else
			animate(lighting_object, color = color_matrix, time = SSlighting.wait)

	lighting_changed = 0

#undef MEAN4

/turf/proc/get_lumcount()
	. = LIGHTING_CAP
	var/area/A = src.loc
	if(IS_DYNAMIC_LIGHTING(A))
		. = src.lighting_lumcount

/area
	var/lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED	//Turn this flag off to make the area fullbright

/area/New()
	. = ..()
	if(lighting_use_dynamic != DYNAMIC_LIGHTING_ENABLED)
		luminosity = 1

/area/proc/SetDynamicLighting()
	if (lighting_use_dynamic == DYNAMIC_LIGHTING_DISABLED)
		lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED
	luminosity = 0
	for(var/turf/T in src.contents)
		T.init_lighting()
		T.update_lumcount(0, 0)

#undef LIGHTING_CIRCULAR
#undef LIGHTING_LAYER
#undef LIGHTING_CAP
#undef LIGHTING_CALC
#undef LIGHTING_ICON
#undef LIGHTING_ICON_STATE
#undef LIGHTING_LUM_FOR_FULL_BRIGHT
#undef LIGHTING_MIN_RADIUS


//set the changed status of all lights which could have possibly lit this atom.
//We don't need to worry about lights which lit us but moved away, since they will have change status set already
//This proc can cause lots of lights to be updated. :(
/atom/proc/UpdateAffectingLights()

/atom/movable/UpdateAffectingLights()
	if(isturf(loc))
		loc.UpdateAffectingLights()

/turf/UpdateAffectingLights()
	if(affecting_lights)
		for(var/datum/light_source/thing in affecting_lights)
			thing.changed()			//force it to update at next process()


#define LIGHTING_MAX_LUMINOSITY_STATIC	8	//Maximum luminosity to reduce lag.
#define LIGHTING_MAX_LUMINOSITY_MOBILE	7	//Moving objects have a lower max luminosity since these update more often. (lag reduction)
#define LIGHTING_MAX_LUMINOSITY_MOB		6
#define LIGHTING_MAX_LUMINOSITY_TURF	8	//turfs are static too, why was this 1?!

//caps luminosity effects max-range based on what type the light's owner is.
/atom/proc/get_light_range(radius)
	return min(radius, LIGHTING_MAX_LUMINOSITY_STATIC)

/atom/movable/get_light_range(radius)
	return min(radius, LIGHTING_MAX_LUMINOSITY_MOBILE)

/mob/get_light_range(radius)
	return min(radius, LIGHTING_MAX_LUMINOSITY_MOB)

/obj/machinery/light/get_light_range(radius)
	return min(radius, LIGHTING_MAX_LUMINOSITY_STATIC)

/turf/get_light_range(radius)
	return min(radius, LIGHTING_MAX_LUMINOSITY_TURF)

#undef LIGHTING_MAX_LUMINOSITY_STATIC
#undef LIGHTING_MAX_LUMINOSITY_MOBILE
#undef LIGHTING_MAX_LUMINOSITY_MOB
#undef LIGHTING_MAX_LUMINOSITY_TURF
