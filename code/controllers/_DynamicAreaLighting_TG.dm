/*
	Modified DynamicAreaLighting for TGstation - Coded by Carnwennan

	This is TG's 'new' lighting system. It's basically a heavily modified combination of Forum_Account's and
	ShadowDarke's respective lighting libraries. Credits, where due, to them.

	Like sd_DAL (what we used to use), it changes the shading overlays of areas by splitting each type of area into sub-areas
	by using the var/tag variable and moving turfs into the contents list of the correct sub-area. This method is
	much less costly than using overlays or objects.

	Unlike sd_DAL however it uses a queueing system. Everytime we call a change to opacity or luminosity
	(through SetOpacity() or SetLuminosity()) we are  simply updating variables and scheduling certain lights/turfs for an
	update. Actual updates are handled periodically by the lighting_controller. This carries additional overheads, however it
	means that each thing is changed only once per lighting_controller.processing_interval ticks. Allowing for greater control
	over how much priority we'd like lighting updates to have. It also makes it possible for us to simply delay updates by
	setting lighting_controller.processing = 0 at say, the start of a large explosion, waiting for it to finish, and then
	turning it back on with lighting_controller.processing = 1.

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

#define LIGHTING_CIRCULAR 1									//comment this out to use old square lighting effects.
#define LIGHTING_LAYER 10									//Drawing layer for lighting overlays
#define LIGHTING_ICON 'icons/effects/ss13_dark_alpha6.dmi'	//Icon used for lighting shading effects

datum/light_source
	var/atom/owner
	var/changed = 1
	var/list/effect = list()
	var/__x = 0		// x coordinate at last update
	var/__y = 0		// y coordinate at last update
	var/__z = 0		// z coordinate at last update

	var/_l_color // do not use directly, only used as reference for updating
	var/col_r
	var/col_g
	var/col_b

	New(atom/A)
		if(!istype(A))
			CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[A]' instead.")
		..()
		owner = A
		readrgb(owner.l_color)
		__x = owner.x
		__y = owner.y
		__z = owner.z
		// the lighting object maintains a list of all light sources
		lighting_controller.lights += src


	//Check a light to see if its effect needs reprocessing. If it does, remove any old effect and create a new one
	proc/check()
		if(!owner)
			remove_effect()
			return 1	//causes it to be removed from our list of lights. The garbage collector will then destroy it.

		// check to see if we've moved since last update
		if(owner.x != __x || owner.y != __y || owner.z != __z)
			__x = owner.x
			__y = owner.y
			__z = owner.z
			changed = 1

		if (owner.l_color != _l_color)
			changed = 1

		if(changed)
			changed = 0
			remove_effect()
			return add_effect()
		return 0

	proc/remove_effect()
		// before we apply the effect we remove the light's current effect.
		for(var/turf/T in effect)	// negate the effect of this light source
			T.update_lumcount(-effect[T], col_r, col_g, col_b, 1)
		effect.Cut()					// clear the effect list

	proc/add_effect()
		// only do this if the light is turned on and is on the map
		if(owner.loc && owner.luminosity > 0)
			readrgb(owner.l_color)
			effect = list()
			for(var/turf/T in view(owner.get_light_range(),owner))
				var/delta_lumen = lum(T)
				if(delta_lumen > 0)
					effect[T] = delta_lumen
					T.update_lumcount(delta_lumen, col_r, col_g, col_b, 0)

			return 0
		else
			owner.light = null
			return 1	//cause the light to be removed from the lights list and garbage collected once it's no
						//longer referenced by the queue

	proc/lum(turf/A)
		if (owner.trueLuminosity < 1)
			return 0
		var/dist
		if(!A)
			dist = 0
		else
#ifdef LIGHTING_CIRCULAR
			dist = cheap_hypotenuse(A.x, A.y, __x, __y)
#else
			dist = max(abs(A.x - __x), abs(A.y - __y))
#endif
		if (owner.trueLuminosity > 100) // This will never happen... right?
			return sqrt(owner.trueLuminosity) - dist
		else
			return sqrtTable[owner.trueLuminosity] - dist

	proc/readrgb(const/col)
		_l_color = col

		if(col)
			col_r = GetRedPart(col)
			col_g = GetGreenPart(col)
			col_b = GetBluePart(col)
		else
			col_r = null

atom
	var/datum/light_source/light
	var/trueLuminosity = 0  // Typically 'luminosity' squared.  The builtin luminosity must remain linear.
	                        // We may read it, but NEVER set it directly.
	var/l_color

//Turfs with opacity when they are constructed will trigger nearby lights to update
//Turfs and atoms with luminosity when they are constructed will create a light_source automatically
turf/New()
	..()
	if(luminosity)
		if(light)	WARNING("[type] - Don't set lights up manually during New(), We do it automatically.")
		trueLuminosity = luminosity * luminosity
		light = new(src)

//Movable atoms with opacity when they are constructed will trigger nearby lights to update
//Movable atoms with luminosity when they are constructed will create a light_source automatically
atom/movable/New()
	..()
	if(opacity)
		if(isturf(loc))
			if(loc:lighting_lumcount > 1)
				UpdateAffectingLights()
	if(luminosity)
		if(light)	WARNING("[type] - Don't set lights up manually during New(), We do it automatically.")
		trueLuminosity = luminosity * luminosity
		light = new(src)

//Objects with opacity will trigger nearby lights to update at next lighting process.
atom/movable/Destroy()
	if(opacity)
		if(isturf(loc))
			if(loc:lighting_lumcount > 1)
				UpdateAffectingLights()

	..()

//Sets our luminosity.
//If we have no light it will create one.
//If we are setting luminosity to 0 the light will be cleaned up by the controller and garbage collected once all its
//queues are complete.
//if we have a light already it is merely updated, rather than making a new one.
atom/proc/SetLuminosity(new_luminosity, trueLum = FALSE)
	if(new_luminosity < 0)
		new_luminosity = 0
	if(!trueLum)
		new_luminosity *= new_luminosity
	if(light)
		if(trueLuminosity != new_luminosity)	//non-luminous lights are removed from the lights list in add_effect()
			light.changed = 1
	else
		if(new_luminosity)
			light = new(src)
	trueLuminosity = new_luminosity
	if (trueLuminosity < 1)
		luminosity = 0
	else if (trueLuminosity <= 100)
		luminosity = sqrtTable[trueLuminosity]
	else
		luminosity = sqrt(trueLuminosity)

atom/proc/AddLuminosity(delta_luminosity)
	if(delta_luminosity > 0)
		SetLuminosity(trueLuminosity + delta_luminosity*delta_luminosity, TRUE)
	else if(delta_luminosity < 0)
		SetLuminosity(trueLuminosity - delta_luminosity*delta_luminosity, TRUE)

area/SetLuminosity(new_luminosity)			//we don't want dynamic lighting for areas
	luminosity = !!new_luminosity
	trueLuminosity = luminosity


//change our opacity (defaults to toggle), and then update all lights that affect us.
atom/proc/SetOpacity(new_opacity)
	if(new_opacity == null)
		new_opacity = !opacity			//default = toggle opacity
	else if(opacity == new_opacity)
		return 0						//opacity hasn't changed! don't bother doing anything
	opacity = new_opacity				//update opacity, the below procs now call light updates.
	return 1

turf/SetOpacity(new_opacity)
	if(..()==1)							//only bother if opacity changed
		if(lighting_lumcount)			//only bother with an update if our turf is currently affected by a light
			UpdateAffectingLights()

/atom/movable/SetOpacity(new_opacity)
	if(..()==1)							//only bother if opacity changed
		if(isturf(loc))					//only bother with an update if we're on a turf
			var/turf/T = loc
			if(T.lighting_lumcount)		//only bother with an update if our turf is currently affected by a light
				UpdateAffectingLights()


turf
	var/lighting_lumcount = 0
	var/lighting_changed = 0
	var/color_lighting_lumcount = 0

	var/lumcount_r = 0
	var/lumcount_g = 0
	var/lumcount_b = 0
	var/light_col_sources = 0

turf/space
	lighting_lumcount = 4		//starlight

turf/proc/update_lumcount(amount, col_r, col_g, col_b, removing = 0)
	lighting_lumcount += amount

	if(!isnull(col_r)) //col_r is the "key" var, if it's null so will the rest
		if(removing)
			light_col_sources--
			lumcount_r -= col_r
			lumcount_g -= col_g
			lumcount_b -= col_b
		else
			light_col_sources++
			lumcount_r += col_r
			lumcount_g += col_g
			lumcount_b += col_b

		if(light_col_sources)
			var/r_avg = max(0, min(255, round(lumcount_r / light_col_sources, 16) + 15))
			var/g_avg = max(0, min(255, round(lumcount_g / light_col_sources, 16) + 15))
			var/b_avg = max(0, min(255, round(lumcount_b / light_col_sources, 16) + 15))
			l_color = rgb(r_avg, g_avg, b_avg)
		else
			l_color = null

		color_lighting_lumcount = max(color_lighting_lumcount + amount, 0) // Minimum of 0.

	if(!lighting_changed)
		lighting_controller.changed_turfs += src
		lighting_changed = 1

turf/proc/lighting_tag(const/level)
	var/area/A = loc
	return A.tagbase + "sd_L[level]"

turf/proc/build_lighting_area(const/tag, const/level, const/color_light)
	var/area/Area = loc
	var/area/A = new Area.type()    // create area if it wasn't found
	// replicate vars
	for(var/V in Area.vars)
		switch(V)
			if ("contents","lighting_overlay", "color_overlay", "overlays")
				continue
			else
				if(issaved(Area.vars[V])) A.vars[V] = Area.vars[V]

	A.tag = tag
	A.lighting_subarea = 1
	A.lighting_space = 0 // in case it was copied from a space subarea

	if (l_color != A.l_color)
		A.l_color = l_color
		//color_light = min(max(round(color_lighting_lumcount, 1), 0), lighting_controller.lighting_states)
		//world << "[color_light] [color_lighting_lumcount]"

	A.SetLightLevel(level, color_light)
	Area.related += A
	return A

turf/proc/shift_to_subarea()
	lighting_changed = 0
	var/area/Area = loc

	if(!istype(Area) || !Area.lighting_use_dynamic) return

	var/level = Clamp(round(lighting_lumcount, 1), 0, lighting_controller.lighting_states)
	var/new_tag = lighting_tag(level)

	// pomf - If we have a lighting color that is not null, apply the new tag to seperate the areas.
	if (l_color)
		// pomf - We append the (rounded!) color lighting lumcount so we can have colored lights.
		new_tag += "[l_color][Clamp(round(color_lighting_lumcount, 1), 0, lighting_controller.lighting_states)]"

	if(Area.tag != new_tag)	//skip if already in this area
		var/area/A = locate(new_tag)	// find an appropriate area
		var/color_light = Clamp(round(color_lighting_lumcount, 1), 0, lighting_controller.lighting_states)

		if(!A)
			A = build_lighting_area(new_tag, level, color_light)
		else if(l_color != A.l_color)
			A.l_color = l_color
			A.SetLightLevel(level, color_light)

		A.contents += src	// move the turf into the area
	universe.OnTurfTick(src)

// Dedicated lighting sublevel for space turfs
// helps us depower things in space, remove space fire alarms,
// and evens out space lighting
turf/space/lighting_tag(var/level)
	var/area/A = loc
	return A.tagbase + "sd_L_space"
turf/space/build_lighting_area(var/tag,var/level)
	var/area/A = ..(tag,4)
	A.lighting_space = 1
	A.SetLightLevel(4)
	A.icon_state = null
	return A

area
	var/lighting_use_dynamic = 1	//Turn this flag off to prevent sd_DynamicAreaLighting from affecting this area
	var/image/lighting_overlay		//tracks the darkness image of the area for easy removal
	var/lighting_subarea = 0		//tracks whether we're a lighting sub-area
	var/lighting_space = 0			// true for space-only lighting subareas
	var/tagbase
	var/image/color_overlay //Tracks the color image.

	proc/SetLightLevel(light, color_light = 0)
		if(!src) return
		if(light <= 0)
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

		if (color_overlay)
			overlays.Remove(color_overlay)
			color_overlay.icon_state = "white"
		else
			if (l_color)
				color_overlay = image('icons/obj/weapons.dmi', ,"white", 10.1)

		if (istype(color_overlay))
			color_overlay.color = l_color

			/*
			if (light < 6)
				switch (level)
					if (6)
						color_overlay.alpha = 140
					if (5)
						color_overlay.alpha = 120
					if (4)
						color_overlay.alpha = 100
					if (3)
						color_overlay.alpha = 80
					if (2)
						color_overlay.alpha = 60
					if (1)
						color_overlay.alpha = 40
					if (-INFINITY to 0)
					//world << "Zero or below, [color_light]."
					color_overlay.alpha = 0
					else
						//world << "Setting the alpha to max... color_light [color_light]."
						color_overlay.alpha = 140

				color_overlay.blend_mode = BLEND_MULTIPLY
			*/

			if (1)
				switch (color_light)
					if (6)
						color_overlay.alpha = 180
					if (5)
						color_overlay.alpha = 140
					if (4)
						color_overlay.alpha = 120
					if (3)
						color_overlay.alpha = 80
					if (2)
						color_overlay.alpha = 60
					if (1)
						color_overlay.alpha = 20
					if (-INFINITY to 0)
						//world << "Zero or below, [color_light]."
						color_overlay.alpha = 0
					else
						//world << "Setting the alpha to max... color_light [color_light]."
						color_overlay.alpha = 180

			color_overlay.blend_mode = BLEND_ADD

			if (color_overlay.color)
				overlays.Add(color_overlay)

		if (isnull(color_overlay))
			overlays.Add(lighting_overlay)
		else if (light < 6)
			overlays.Add(lighting_overlay)

	proc/SetDynamicLighting()

		src.lighting_use_dynamic = 1
		for(var/turf/T in src.contents)
			T.update_lumcount(0)

	proc/InitializeLighting()	//TODO: could probably improve this bit ~Carn
		tagbase = "[type]"
		if(!tag) tag = tagbase
		if(!lighting_use_dynamic)
			if(!lighting_subarea)	// see if this is a lighting subarea already
			//show the dark overlay so areas, not yet in a lighting subarea, won't be bright as day and look silly.
				SetLightLevel(4)

//#undef LIGHTING_LAYER
#undef LIGHTING_CIRCULAR
//#undef LIGHTING_ICON

#define LIGHTING_MAX_LUMINOSITY_STATIC	8	//Maximum luminosity to reduce lag.
#define LIGHTING_MAX_LUMINOSITY_MOBILE	5	//Moving objects have a lower max luminosity since these update more often. (lag reduction)
#define LIGHTING_MAX_LUMINOSITY_TURF	1	//turfs have a severely shortened range to protect from inevitable floor-lighttile spam.

//set the changed status of all lights which could have possibly lit this atom.
//We don't need to worry about lights which lit us but moved away, since they will have change status set already
//This proc can cause lots of lights to be updated. :(
atom/proc/UpdateAffectingLights()
	for(var/atom/A in oview(LIGHTING_MAX_LUMINOSITY_STATIC-1,src))
		if(A.light)
			A.light.changed = 1			//force it to update at next process()

//caps luminosity effects max-range based on what type the light's owner is.
atom/proc/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_STATIC)

atom/movable/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_MOBILE)

obj/machinery/light/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_STATIC)

turf/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_TURF)

#undef LIGHTING_MAX_LUMINOSITY_STATIC
#undef LIGHTING_MAX_LUMINOSITY_MOBILE
#undef LIGHTING_MAX_LUMINOSITY_TURF