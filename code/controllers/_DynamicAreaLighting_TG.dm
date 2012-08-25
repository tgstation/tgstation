/*
	Modified DynamicAreaLighting for TGstation - Coded by Carnwennan

	This is TG's 'new' lighting system. It's basically a heavily modified mix of combination of Forum_Account's and
	ShadowDarke's respective lighting libraries. Credits, where due, to them.

	Like sd_DAL (what we used to use), it changes the shading overlays of areas by splitting each type of area into sub-areas
	by using the var/tag variable and moving turfs into the contents list of the correct sub-area.

	Unlike sd_DAL however it uses a queueing system. Everytime we  call a change to opacity or luminosity
	(through SetOpacity() or SetLuminosity()) we are  simply updating variables and scheduling certain lights/turfs for an
	update. Actual updates are handled periodically by the lighting_controller. This carries additional overheads, however it
	means that each thing is changed only once per lighting_controller.processing_interval ticks. Allowing for greater control
	over how much priority we'd like lighting updates to have. It also makes it possible for us to simply delay updates by
	setting lighting_controller.processing = 0 at say, the start of a large explosion, waiting for it to finish, and then
	turning it back on with lighting_controller.processing = 1.

	Unlike our old system there is a hardcoded maximum luminosity. This is to discourage coders using large luminosity values
	for dynamic lighting, as the cost of lighting grows rapidly at large luminosity levels (especially when changing opacity
	at runtime)

	Also, in order for the queueing system to work, each light remembers the effect it casts on each turf. This is going to
	have larger memory requirements than our previous system but hopefully it's worth the hassle for the greater control we
	gain. Besides, there are far far worse uses of needless lists in the game, it'd be worth pruning some of them to offset
	costs.

	Known Issues/TODO:
		admin-spawned turfs will have broken lumcounts. Not willing to fix it at this moment
		mob luminosity will be lower than expected when one of multiple light sources is dropped after exceeding the maximum luminosity
		Shuttles still do not have support for dynamic lighting (I hope to fix this at some point)
		No directional lighting support. Fairly easy to add this and the code is ready.
		When opening airlocks etc, lighting does not always update to account for the change in opacity.
*/

#define LIGHTING_MAX_LUMINOSITY 12	//Hard maximum luminosity to prevet lag which could be caused by coders making mini-suns
#define LIGHTING_MAX_LUMINOSITY_MOB 7	//Mobs get their own max because 60-odd human suns running around would be pretty silly
#define LIGHTING_LAYER 10			//Drawing layer for lighting overlays
#define LIGHTING_ICON 'icons/effects/ss13_dark_alpha7.dmi'	//Icon used for lighting shading effects

datum/controller/lighting/New()			//moved here so its in the define. eek :S
	lighting_states = max( 0, length(icon_states(LIGHTING_ICON))-1 )

datum/light_source
	var/atom/owner
	var/changed = 1
	var/mobile = 1
	var/list/effect = list()

	var/__x = 0		//x coordinate at last update
	var/__y = 0		//y coordinate at last update


	New(atom/A)
		if(!istype(A))
			CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[A]' instead.")

		..()
		owner = A

		if(istype(owner, /atom/movable))	mobile = 1		//apparantly this is faster than type-checking
		else								mobile = 0		//Perhaps removing support for luminous turfs would be a good idea.

		__x = owner.x
		__y = owner.y

		// the lighting object maintains a list of all light sources
		lighting_controller.lights += src


	//Check a light to see if its effect needs reprocessing. If it does, remove any old effect and create a new one
	proc/check()
		if(!owner)
			remove_effect()
			return 1	//causes it to be removed from our list of lights. The garbage collector will then destroy it.

		if(mobile)
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


	proc/remove_effect()
		// before we apply the effect we remove the light's current effect.
		if(effect.len)
			for(var/turf in effect)	// negate the effect of this light source
				var/turf/T = turf
				T.update_lumcount(-effect[T])
			effect.Cut()					// clear the effect list

	proc/add_effect()
		// only do this if the light is turned on and is on the map
		if(owner.loc && owner.luminosity > 0)
			effect = new_effect()						// identify the effects of this light source
			for(var/turf in effect)
				var/turf/T = turf
				T.update_lumcount(effect[T])			// apply the effect
			return 0
		else
			owner.light = null
			return 1	//cause the light to be removed from the lights list and garbage collected once it's no
						//longer referenced by the queue

	proc/new_effect()
		. = list()

		for(var/turf/T in view(owner.luminosity, owner))
//			var/area/A = T.loc
//			if(!A) continue
			var/change_in_lumcount = lum(T)
			if(change_in_lumcount > 0)
				.[T] = change_in_lumcount

		return .


	proc/lum(turf/A)
		return owner.luminosity - max(abs(A.x-__x),abs(A.y-__y))
//		var/dist = cheap_hypotenuse(A.x,A.y,__x,__y) //fetches the pythagorean distance between A and the light
//		if(owner.luminosity < dist)	//if the turf is outside the radius the light doesn't illuminate it
//			return 0
//		return round(owner.luminosity - (dist/2),0.1)

atom
	var/datum/light_source/light

//Turfs with opacity when they are constructed will trigger nearby lights to update
//Turfs atoms with luminosity when they are constructed will create a light_source automatically
//TODO: lag reduction
turf/New()
	..()
	if(opacity)
		UpdateAffectingLights()
	if(luminosity)
		world.log << "[type] has luminosity at New()"
		if(light)	world.log << "## WARNING: [type] - Don't set lights up manually during New(), We do it automatically."
		light = new(src)

//Movable atoms with opacity when they are constructed will trigger nearby lights to update
//Movable atoms with luminosity when they are constructed will create a light_source automatically
//TODO: lag reduction
atom/movable/New()
	..()
	if(opacity)
		UpdateAffectingLights()
	if(luminosity)
		if(light)	world.log << "## WARNING: [type] - Don't set lights up manually during New(), We do it automatically."
		light = new(src)

//Turfs with opacity will trigger nearby lights to update at next lighting process.
//TODO: is this really necessary? Removing it could help reduce lag during singulo-mayhem somewhat
turf/Del()
	if(opacity)
		UpdateAffectingLights()
	..()

//Objects with opacity will trigger nearby lights to update at next lighting process.
atom/movable/Del()
	if(opacity)
		UpdateAffectingLights()
	..()

//Sets our luminosity. Enforces a hardcoded maximum luminosity by default. This maximum can be overridden but it is extremely
//unwise to do so.
//If we have no light it will create one.
//If we are setting luminosity to 0 the light will be cleaned up and delted once all its queues are complete
//if we have a light already it is merely updated
atom/proc/SetLuminosity(new_luminosity, max_luminosity = LIGHTING_MAX_LUMINOSITY)
	if(new_luminosity < 0)
		new_luminosity = 0
//		world.log << "## WARNING: [type] - luminosity cannot be negative"
	else if(max_luminosity < new_luminosity)
		new_luminosity = max_luminosity
//		if(luminosity != new_luminosity)
//			world.log << "## WARNING: [type] - LIGHT_MAX_LUMINOSITY exceeded"

	if(isturf(loc))
		if(light)
			if(luminosity != new_luminosity)	//TODO: remove lights from the light list when they're not luminous? DONE in add_effect
				light.changed = 1
		else
			if(new_luminosity)
				light = new(src)

	luminosity = new_luminosity

//Snowflake code to prevent mobs becoming suns (lag-prevention)
mob/SetLuminosity(new_luminosity)
	..(new_luminosity,LIGHTING_MAX_LUMINOSITY_MOB)

//change our opacity (defaults to toggle), and then update all lights that affect us.
atom/proc/SetOpacity(var/new_opacity)
	if(new_opacity == null)			new_opacity = !opacity
	else if(opacity == new_opacity)	return
	opacity = new_opacity

	UpdateAffectingLights()

//set the changed status of all lights which could have possibly lit this atom.
//We don't need to worry about lights which lit us but moved away, since they will have change status set already
atom/proc/UpdateAffectingLights()
	var/turf/T = src
	if(!isturf(T))
		T = loc
		if(!isturf(T))	return
	for(var/atom in range(LIGHTING_MAX_LUMINOSITY,T))	//TODO: this will probably not work very well :(
		var/atom/A = atom
		if(A.light && A.luminosity)
			A.light.changed = 1			//force it to update at next process()

//	for(var/light in lighting_controller.lights)		//TODO: this will probably laaaaaag
//		var/datum/light_source/L = light
//		if(L.changed)	continue
//		if(!L.owner)	continue
//		if(!L.owner.luminosity)	continue
//		if(src in L.effect)
//			L.changed = 1

turf
	var/lighting_lumcount = 0
	var/lighting_changed = 0

turf/space
	lighting_lumcount = 4		//starlight

turf/proc/update_lumcount(amount)
	lighting_lumcount += amount
//	if(lighting_lumcount < 0 || lighting_lumcount > 100)
//		world.log << "## WARNING: [type] ([src]) lighting_lumcount = [lighting_lumcount]"
	if(!lighting_changed)
		lighting_controller.changed_turfs += src
		lighting_changed = 1

turf/proc/shift_to_subarea()
	lighting_changed = 0

	var/area/Area = loc
	if(!istype(Area) || !Area.lighting_use_dynamic) return

	// change the turf's area depending on its brightness
	// restrict light to valid levels
	var/light = min(max(round(lighting_lumcount,1),0),lighting_controller.lighting_states)
	var/new_tag = "[Area.type]sd_L[light]"

	if(Area.tag!=new_tag)	//skip if already in this area
		var/area/A = locate(new_tag)	// find an appropriate area
		if(!A)
			A = new Area.type()    // create area if it wasn't found
			// replicate vars
			for(var/V in Area.vars)
				switch(V)
					if("contents","lighting_overlay","overlays")	continue
					else
						if(issaved(Area.vars[V])) A.vars[V] = Area.vars[V]

			A.tag = new_tag
			A.lighting_subarea = 1
			A.SetLightLevel(light)

			Area.related += A

		A.contents += src	// move the turf into the area

area
	var/lighting_use_dynamic = 1	//Turn this flag off to prevent sd_DynamicAreaLighting from affecting this area
	var/image/lighting_overlay		//tracks the darkness image of the area for easy removal
	var/lighting_subarea = 0		//tracks whether we're a lighting sub-area

	proc/SetLightLevel(light)
		if(!src) return
		if(light < 0)
			light = 0
			luminosity = 0
		else
			if(light > lighting_controller.lighting_states)
				light = lighting_controller.lighting_states
			luminosity = 1

		if(lighting_overlay)
			overlays -= lighting_overlay
			lighting_overlay.icon_state = "[light]"
		else
			lighting_overlay = image(LIGHTING_ICON,,num2text(light),LIGHTING_LAYER)

		overlays += lighting_overlay

	proc/InitializeLighting()	//TODO: could probably improve this bit ~Carn
		if(!tag) tag = "[type]"
		if(!lighting_use_dynamic)
			if(!lighting_subarea)	// see if this is a lighting subarea already
			//show the dark overlay so areas, not yet in a lighting subarea, won't be bright as day and look silly.
				SetLightLevel(4)


#undef LIGHTING_MAX_LUMINOSITY
#undef LIGHTING_MAX_LUMINOSITY_MOB
#undef LIGHTING_LAYER
#undef LIGHTING_ICON