/// All flock conversion stuff (animation, handling actual conversion) should go here.
#define FLOCK_CONVERT_COLOR_MATRIX list(1,0,0,0,1,0,0,0,1,0.18,0.98,0.71)
#define FLOCK_END_ANIMATION_LENGTH 2 SECONDS

// TODO: ditch me the second anything real can do this
ADMIN_VERB(do_flock_act, R_DEBUG, "Do flock_act", "flock_act your current turf", ADMIN_CATEGORY_DEBUG)
	var/turf/user_turf = get_turf(user.mob)
	if(!isturf(user_turf))
		return
	user_turf.flock_act()

/// Call final animation on things that have been flock-converted.
/proc/animate_flock_converted(atom/converted)
	animate(converted, color=FLOCK_CONVERT_COLOR_MATRIX, time = 0)
	animate(color = null, time = FLOCK_END_ANIMATION_LENGTH, easing = CIRCULAR_EASING|EASE_OUT)
	converted.add_shared_particles(/particles/flock_convert_complete)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(finish_flock_convert_animation), converted, FLOCK_END_ANIMATION_LENGTH))

/proc/finish_flock_convert_animation(atom/converted)
	converted.remove_shared_particles(/particles/flock_convert_complete)

/atom/proc/flock_act()
	return

// TURF

/turf/flock_act()
	for(var/atom/atom in src)
		atom.flock_act()

// TODO: special casing to handle things like floor lights
/turf/open/floor/flock_act()
	..()
	var/turf/open/floor/flock/new_turf = ChangeTurf(/turf/open/floor/flock, flags = CHANGETURF_INHERIT_AIR)
	playsound(new_turf, 'troutstation/sound/effects/flock/flock_convert.ogg', 50, vary = TRUE)
	animate_flock_converted(new_turf)



/turf/closed/wall/flock_act()
	..()
	var/turf/closed/wall/flock/new_turf = ChangeTurf(/turf/closed/wall/flock, flags = CHANGETURF_INHERIT_AIR)
	playsound(new_turf, 'troutstation/sound/effects/flock/flock_convert.ogg', 50, vary = TRUE)
	animate_flock_converted(new_turf)

// OBJ

/obj/flock_act()
	// temporary i hope hope hope
	animate_flock_converted(src)

#undef FLOCK_CONVERT_COLOR_MATRIX
#undef FLOCK_END_ANIMATION_LENGTH
