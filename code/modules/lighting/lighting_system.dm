/*
	This is /tg/'s 'newer' lighting system. It's basically a combination of Forum_Account's and ShadowDarke's
	respective lighting libraries heavily modified by Carnwennan for /tg/station with further edits by
	MrPerson. Credits, where due, to them.

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
		Allow lights to be weaker than 'cap' radius
		Colored lights
*/

#define LIGHTING_CIRCULAR 1									//comment this out to use old square lighting effects.
#define LIGHTING_LAYER 15									//Drawing layer for lighting
#define LIGHTING_CAP 10										//The lumcount level at which alpha is 0 and we're fully lit.
#define LIGHTING_CAP_FRAC (255/LIGHTING_CAP)				//A precal'd variable we'll use in turf/redraw_lighting()
#define LIGHTING_ICON 'icons/effects/alphacolors.dmi'
#define LIGHTING_ICON_STATE "white"
#define LIGHTING_TIME 1.2									//Time to do any lighting change. Actual number pulled out of my ass
#define LIGHTING_DARKEST_VISIBLE_ALPHA 230					//Anything darker than this is so dark, we'll just consider the whole tile unlit

/datum/light_source
	var/atom/owner
	var/radius = 0
	var/changed = 1
	var/list/effect = list()
	var/__x = 0		//x coordinate at last update
	var/__y = 0		//y coordinate at last update

/datum/light_source/New(atom/A)
	if(!istype(A))
		CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[A]' instead.")
	..()
	owner = A
	radius = A.luminosity
	__x = owner.x
	__y = owner.y
	SSlighting.changed_lights |= src

/datum/light_source/Destroy()
	if(owner && owner.light == src)
		remove_effect()
		owner.light = null
		owner = null
	return ..()

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
	if(owner)
		__x = owner.x
		__y = owner.y
	if(!changed)
		changed = 1
		SSlighting.changed_lights |= src

//Remove current effect
/datum/light_source/proc/remove_effect().
	for(var/turf/T in effect)
		T.update_lumcount(-effect[T])

		if(T.affecting_lights && T.affecting_lights.len)
			T.affecting_lights -= src

	effect.Cut()

//Apply a new effect
/datum/light_source/proc/add_effect()
	// only do this if the light is turned on and is on the map
	if(owner && owner.loc && radius > 0)
		effect = list()
		var/turf/To = get_turf(owner)
		var/range = owner.get_light_range(radius)
		for(var/atom/movable/AM in To)
			if(AM == owner)
				continue
			if(AM.opacity)
				range = 0
				break

		for(var/turf/T in view(range, To))
			var/delta_lumcount = T.lumen(src)
			if(delta_lumcount > 0)
				effect[T] = delta_lumcount
				T.update_lumcount(delta_lumcount)

				if(!T.affecting_lights)
					T.affecting_lights = list()
				T.affecting_lights |= src

		return 1
	else
		return 0

//How much light light_source L should apply to src
/turf/proc/lumen(datum/light_source/L)
	var/distance = 0
#ifdef LIGHTING_CIRCULAR
	distance = cheap_hypotenuse(x, y, L.__x, L.__y)
#else
	distance = max(abs(x - L.__x), abs(y - L.__y))
#endif
	return LIGHTING_CAP * (L.radius - distance) / L.radius
//LIGHTING_CAP == strength for now


/atom
	var/datum/light_source/light


//Turfs with opacity when they are constructed will trigger nearby lights to update
//Turfs and atoms with luminosity when they are constructed will create a light_source automatically
/turf/New()
	..()
	if(luminosity)
		light = new(src)
//		luminosity = 0

//Movable atoms with opacity when they are constructed will trigger nearby lights to update
//Movable atoms with luminosity when they are constructed will create a light_source automatically
/atom/movable/New()
	..()
	if(opacity)
		UpdateAffectingLights()
	if(luminosity)
		light = new(src)
//		luminosity = 0

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
/atom/proc/SetLuminosity(new_luminosity)
	if(new_luminosity < 0)
		new_luminosity = 0

	if(!light)
		if(!new_luminosity)
			return
		light = new(src)
	else
		if(light.radius == new_luminosity)
			return
	light.radius = new_luminosity
	luminosity = new_luminosity
	light.changed()

/atom/proc/AddLuminosity(delta_luminosity)
	if(light)
		SetLuminosity(light.radius + delta_luminosity)
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
	color = "#000"
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

/turf/ChangeTurf(var/path)
	if(!path || path == type) //Sucks this is here but it would cause problems otherwise.
		return ..()

	for(var/obj/effect/decal/cleanable/decal in src.contents)
		qdel(decal)

	if(light)
		qdel(light)

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	var/oldbaseturf = baseturf

	var/list/our_lights //reset affecting_lights if needed
	if(opacity != initial(path:opacity) && old_lumcount)
		UpdateAffectingLights()

	if(affecting_lights)
		our_lights = affecting_lights.Copy()

	. = ..() //At this point the turf has changed

	affecting_lights = our_lights

	lighting_changed = 1 //Don't add ourself to SSlighting.changed_turfs
	update_lumcount(old_lumcount)
	baseturf = oldbaseturf
	lighting_object = locate() in src
	init_lighting()

	for(var/turf/space/S in orange(src,1))
		S.update_starlight()


/turf/proc/update_lumcount(amount)
	lighting_lumcount += amount
	if(!lighting_changed)
		SSlighting.changed_turfs += src
		lighting_changed = 1

/turf/space/update_lumcount(amount) //Keep track in case the turf becomes a floor at some point, but don't process.
	lighting_lumcount += amount

/turf/proc/init_lighting()
	var/area/A = loc
	if(!A.lighting_use_dynamic || istype(src, /turf/space))
		lighting_changed = 0
		if(lighting_object)
			lighting_object.alpha = 0
			lighting_object = null
	else
		if(!lighting_object)
			lighting_object = new (src)
		redraw_lighting(1)

/turf/space/init_lighting()
	. = ..()
	if(config.starlight)
		update_starlight()

/turf/proc/redraw_lighting(var/instantly = 0)
	if(lighting_object)
		var/newalpha
		if(lighting_lumcount <= 0)
			newalpha = 255
		else
			lighting_object.luminosity = 1
			if(lighting_lumcount < LIGHTING_CAP)
				var/num = Clamp(lighting_lumcount * LIGHTING_CAP_FRAC, 0, 255)
				newalpha = 255-num
			else //if(lighting_lumcount >= LIGHTING_CAP)
				newalpha = 0

		if(lighting_object.alpha != newalpha)
			var/change_time = LIGHTING_TIME
			if(instantly)
				change_time = 0
			animate(lighting_object, alpha = newalpha, time = change_time)
			if(newalpha >= LIGHTING_DARKEST_VISIBLE_ALPHA) //Doesn't actually make it darker or anything, just tells byond you can't see the tile
				animate(luminosity = 0, time = 0)

	lighting_changed = 0

/area
	var/lighting_use_dynamic = 1	//Turn this flag off to make the area fullbright

/area/New()
	. = ..()
	if(!lighting_use_dynamic)
		luminosity = 1

/area/proc/SetDynamicLighting()
	lighting_use_dynamic = 1
	luminosity = 0
	for(var/turf/T in src.contents)
		T.init_lighting()
		T.update_lumcount(0)

#undef LIGHTING_LAYER
#undef LIGHTING_CIRCULAR
#undef LIGHTING_ICON
#undef LIGHTING_ICON_STATE
#undef LIGHTING_TIME
#undef LIGHTING_CAP
#undef LIGHTING_CAP_FRAC
#undef LIGHTING_DARKEST_VISIBLE_ALPHA


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
#define LIGHTING_MAX_LUMINOSITY_MOBILE	5	//Moving objects have a lower max luminosity since these update more often. (lag reduction)
#define LIGHTING_MAX_LUMINOSITY_MOB		5
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
