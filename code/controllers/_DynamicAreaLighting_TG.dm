/*
	Modified DynamicAreaLighting for TGstation - Coded by Carnwennan

	This is TG's 'new' lighting system. It's basically a heavily modified combination of Forum_Account's and
	ShadowDarke's respective lighting libraries. Credits, where due, to them.

	Like sd_DAL (what we used to use), it changes the shading overlays of areas by splitting each type of area into sub-areas
	by using the var/tag variable and moving turfs into the contents list of the correct sub-area. This method is
	much less costly than using overlays or objects.

	Unlike sd_DAL however it uses a queueing system. Everytime we call a change to opacity or luminosity
	(through SetOpacity() or SetLuminosity()) we are  simply updating variables and scheduling certain lights/turfs for an
	update. Actual updates are handled periodically by the SSlighting subsystem. This carries additional overheads, however it
	means that each thing is changed only once per SSlighting.wait deciseconds. Allowing for greater control
	over how much priority we'd like lighting updates to have.

	UPDATE: we no longer postpone lighting updates by editting variables, there is now a subsystem/proc/postpone() procedure.
			So you would do SSlighting.postpone()

	Unlike our old system there are hardcoded maximum luminositys (different for certain atoms).
	This is to cap the cost of creating lighting effects.
	(without this, an atom with luminosity of 20 would have to update 41^2 turfs!) :s

	Also, in order for the queueing system to work, each light remembers the effect it casts on each turf. This is going to
	have larger memory requirements than our previous system but it's easily worth the hassle for the greater control we
	gain. It also reduces cost of removing lighting effects by a lot!

	Known Issues/TODO:
		Shuttles still do not have support for dynamic lighting (I hope to fix this at some point)
		No directional lighting support. (prototype looked ugly)
*/

#define USE_CIRCULAR_LIGHTING		//comment this out to use old square lighting effects.

/datum/light_source
	var/atom/owner
	var/changed = 1
	var/list/effect = list()
	var/__x = 0		//x coordinate at last update
	var/__y = 0		//y coordinate at last update


/datum/light_source/New(atom/A)
	if(!istype(A))
		CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[A]' instead.")
	..()
	owner = A
	__x = owner.x
	__y = owner.y
	// the lighting object maintains a list of all light sources
	SSlighting.lights += src


//Check a light to see if its effect needs reprocessing. If it does, remove any old effect and create a new one
/datum/light_source/proc/check()
	if(!owner)
		remove_effect()
		return 1	//causes it to be removed from our list of lights. The garbage collector will then destroy it.

	// check to see if we've moved since last update
	if(owner.x != __x || owner.y != __y)
		__x = owner.x
		__y = owner.y
		changed = 1

	if(changed)
		changed = 0
		remove_effect()
		return add_effect()
	return 0


/datum/light_source/proc/remove_effect()
	// before we apply the effect we remove the light's current effect.
	for(var/turf/T in effect)	// negate the effect of this light source
		T.update_lumcount(-effect[T])

		if(T.affecting_lights && T.affecting_lights.len)
			T.affecting_lights -= src
		else
			T.affecting_lights = null

	effect.Cut()					// clear the effect list

/datum/light_source/proc/add_effect()
	// only do this if the light is turned on and is on the map
	if(owner.loc && owner.luminosity > 0)
		effect = list()
		var/turf/To = get_turf(owner)
		var/range = owner.get_light_range()

		for(var/turf/T in view(range, To))
			var/delta_lumcount = T.lumen(src)
			if(delta_lumcount > 0)
				effect[T] = delta_lumcount
				T.update_lumcount(delta_lumcount)

				if(!T.affecting_lights)
					T.affecting_lights = list()
				T.affecting_lights += src

		return 0
	else
		owner.light = null
		return 1	//cause the light to be removed from the lights list and garbage collected once it's no
					//longer referenced by the queue

/turf/proc/lumen(datum/light_source/L)
	. = L.owner.luminosity
#ifdef USE_CIRCULAR_LIGHTING
	. -= cheap_hypotenuse(x, y, L.__x, L.__y)
#else
	. -= max(abs(x - L.__x), abs(y - L.__y))
#endif
	return .

/turf/space/lumen()
	return 0


/atom
	var/datum/light_source/light


//Turfs with opacity when they are constructed will trigger nearby lights to update
//Turfs and atoms with luminosity when they are constructed will create a light_source automatically
/turf/New()
	..()
	if(luminosity)
		if(light)	WARNING("[type] - Don't set lights up manually during New(), We do it automatically.")
		light = new(src)

//Movable atoms with opacity when they are constructed will trigger nearby lights to update
//Movable atoms with luminosity when they are constructed will create a light_source automatically
/atom/movable/New()
	..()
	if(opacity)
		UpdateAffectingLights()
	if(luminosity)
		if(light)	WARNING("[type] - Don't set lights up manually during New(), We do it automatically.")
		light = new(src)

//Objects with opacity will trigger nearby lights to update at next lighting process.
/atom/movable/Destroy()
	if(opacity)
		UpdateAffectingLights()
	return ..()

//Sets our luminosity.
//If we have no light it will create one.
//If we are setting luminosity to 0 the light will be cleaned up by the controller and garbage collected once all its
//queues are complete.
//if we have a light already it is merely updated, rather than making a new one.
/atom/proc/SetLuminosity(new_luminosity)
	if(new_luminosity < 0)
		new_luminosity = 0
	if(light)
		if(luminosity != new_luminosity)	//non-luminous lights are removed from the lights list in add_effect()
			light.changed = 1
	else
		if(new_luminosity)
			light = new(src)
	luminosity = new_luminosity

/atom/proc/AddLuminosity(delta_luminosity)
	SetLuminosity(luminosity + delta_luminosity)

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


/turf
	var/lighting_lumcount = 0
	var/lighting_changed = 0
	var/list/affecting_lights			//not initialised until used (even empty lists reserve a fair bit of memory)

/turf/space
	lighting_lumcount = 4		//starlight

/turf/proc/update_lumcount(amount)
	lighting_lumcount += amount
	if(!lighting_changed)
		SSlighting.changed_turfs += src
		lighting_changed = 1

/area/proc/lighting_tag(level)
	return tagbase + "sd_L[level]"

/area/proc/build_lighting_area(tag, level)
	var/area/A = locate(tag)	// find an appropriate area
	if(A)
		return A
	A = new type()    // create area if it wasn't found
	// replicate vars
	for(var/V in vars)
		switch(V)
			if("contents","last_light","overlays")	continue
			else
				if(issaved(vars[V])) A.vars[V] = vars[V]

	A.tag = tag
	A.lighting_subarea = 1
	A.lighting_space = 0 // in case it was copied from a space subarea
	A.SetLightLevel(level)

	related += A
	return A

/turf/proc/shift_to_subarea()
	lighting_changed = 0
	var/area/Area = loc

	if(!istype(Area) || !Area.lighting_use_dynamic) return

	var/level = min(max(round(lighting_lumcount,1),0),SSlighting.lighting_images.len)
	var/new_tag = Area.lighting_tag(level)
	if(Area.tag!=new_tag)	//skip if already in this area
		var/area/A = Area.build_lighting_area(new_tag,level)
		A.contents += src	// move the turf into the area

/area
	var/lighting_use_dynamic = 1	//Turn this flag off to prevent sd_DynamicAreaLighting from affecting this area
	var/last_light					//tracks the last light level set for this area (used for removing previously applied lighting overlays)
	var/lighting_subarea = 0		//tracks whether we're a lighting sub-area
	var/lighting_space = 0			// true for space-only lighting subareas
	var/tagbase

/area/proc/SetLightLevel(light)
	if(!src) return
	if(light <= 1)
		light = 1
		luminosity = 0
	else
		if(light > SSlighting.lighting_images.len)
			light = SSlighting.lighting_images.len
		luminosity = 1

	if(last_light != light)
		if(last_light)
			overlays -= SSlighting.lighting_images[last_light]
		overlays += SSlighting.lighting_images[light]
		last_light = light

/area/proc/SetDynamicLighting()
	lighting_use_dynamic = 1
	for(var/turf/T in contents)
		T.update_lumcount(0)

/area/proc/InitializeLighting()	//TODO: could probably improve this bit ~Carn
	tagbase = "[type]"
	if(!tag) tag = tagbase
	if(!lighting_use_dynamic)
		if(!lighting_subarea)	// see if this is a lighting subarea already
		//show the dark overlay so areas, not yet in a lighting subarea, won't be bright as day and look silly.
			SetLightLevel(4)

#undef USE_CIRCULAR_LIGHTING

//set the changed status of all lights which could have possibly lit this atom.
//We don't need to worry about lights which lit us but moved away, since they will have change status set already
//This proc can cause lots of lights to be updated. :(
/atom/proc/UpdateAffectingLights()

/atom/movable/UpdateAffectingLights()
	if(isturf(loc))
		loc.UpdateAffectingLights()

/turf/UpdateAffectingLights()
	if(affecting_lights)
		for(var/thing in affecting_lights)
			thing:changed = 1			//force it to update at next process()


#define LIGHTING_MAX_LUMINOSITY_STATIC	8	//Maximum luminosity to reduce lag.
#define LIGHTING_MAX_LUMINOSITY_MOBILE	5	//Moving objects have a lower max luminosity since these update more often. (lag reduction)
#define LIGHTING_MAX_LUMINOSITY_MOB		5
#define LIGHTING_MAX_LUMINOSITY_TURF	1	//turfs have a severely shortened range to protect from inevitable floor-lighttile spam.

//caps luminosity effects max-range based on what type the light's owner is.
/atom/proc/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_STATIC)

/atom/movable/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_MOBILE)

/mob/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_MOB)

/obj/machinery/light/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_STATIC)

/turf/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_TURF)

#undef LIGHTING_MAX_LUMINOSITY_STATIC
#undef LIGHTING_MAX_LUMINOSITY_MOBILE
#undef LIGHTING_MAX_LUMINOSITY_MOB
#undef LIGHTING_MAX_LUMINOSITY_TURF
