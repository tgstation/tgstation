/var/list/all_lighting_objects = list() // Global list of lighting objects.

/atom/movable/lighting_object
	name          = ""

	anchored      = TRUE

	icon             = LIGHTING_ICON
	color            = LIGHTING_BASE_MATRIX
	plane            = LIGHTING_PLANE
	mouse_opacity    = 0
	layer            = LIGHTING_LAYER
	invisibility     = INVISIBILITY_LIGHTING

	blend_mode       = BLEND_ADD

	var/needs_update = FALSE

/atom/movable/lighting_object/Initialize(mapload, var/no_update = FALSE)
	. = ..()
	verbs.Cut()
	global.all_lighting_objects += src

	var/turf/T         = loc // If this runtimes atleast we'll know what's creating overlays in things that aren't turfs.
	T.lighting_object = src
	T.luminosity       = 0

	for(var/turf/open/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		S.update_starlight()

	if (no_update)
		return

	update()

/atom/movable/lighting_object/Destroy(var/force)
	if (force)
		global.all_lighting_objects        -= src
		global.lighting_update_objects     -= src

		var/turf/T   = loc
		if (istype(T))
			T.lighting_object = null
			T.luminosity = 1

		return ..()
	else
		return QDEL_HINT_LETMELIVE

/atom/movable/lighting_object/proc/update()
	var/turf/T = loc
	if (!istype(T)) // Erm...
		if (loc)
			warning("A lighting object realised its loc was NOT a turf (actual loc: [loc], [loc.type]) in update()!")

		else
			warning("A lighting object realised it was in nullspace in update()!")

		qdel(src, TRUE)
		return

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	var/datum/lighting_corner/cr  = T.corners[3] || dummy_lighting_corner
	var/datum/lighting_corner/cg  = T.corners[2] || dummy_lighting_corner
	var/datum/lighting_corner/cb  = T.corners[4] || dummy_lighting_corner
	var/datum/lighting_corner/ca  = T.corners[1] || dummy_lighting_corner

	var/max = max(cr.cache_mx, cg.cache_mx, cb.cache_mx, ca.cache_mx)

	color  = list(
		cr.cache_r, cr.cache_g, cr.cache_b, 0,
		cg.cache_r, cg.cache_g, cg.cache_b, 0,
		cb.cache_r, cb.cache_g, cb.cache_b, 0,
		ca.cache_r, ca.cache_g, ca.cache_b, 0,
		0, 0, 0, 1
	)
	#if LIGHTING_SOFT_THRESHOLD != 0
	luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™️, it won't even be a flat 0.
	// This number is mostly arbitrary.
	luminosity = max > 1e-6
	#endif

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/ex_act(severity)
	return 0

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull()
	return

/atom/movable/lighting_object/blob_act()
	return

// Nope nope nope!
/atom/movable/lighting_object/onShuttleMove(turf/T1, rotation)
	return FALSE

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/forceMove(atom/destination, var/no_tp=FALSE, var/harderforce = FALSE)
	if(harderforce)
		. = ..()
