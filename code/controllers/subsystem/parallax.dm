/// Define for the pickweight value where you get no parallax
#define PARALLAX_NONE "parallax_none"

SUBSYSTEM_DEF(parallax)
	name = "Parallax"
	wait = 2
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_PARALLAX
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/list/currentrun
	var/planet_x_offset = 128
	var/planet_y_offset = 128
	/// A random parallax layer that we sent to every player
	var/atom/movable/screen/parallax_layer/random/random_layer
	/// Weighted list with the parallax layers we could spawn
	var/random_parallax_weights = list( \
		/atom/movable/screen/parallax_layer/random/space_gas = 35, \
		/atom/movable/screen/parallax_layer/random/asteroids = 35, \
		PARALLAX_NONE = 30, \
	)


//These are cached per client so needs to be done asap so people joining at roundstart do not miss these.
/datum/controller/subsystem/parallax/PreInit()
	. = ..()

	generate_random_parallax_layer()

	planet_y_offset = rand(100, 160)
	planet_x_offset = rand(100, 160)

/datum/controller/subsystem/parallax/fire(resumed = FALSE)
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/client/processing_client = currentrun[currentrun.len]
		currentrun.len--
		if (QDELETED(processing_client) || !processing_client.eye)
			if (MC_TICK_CHECK)
				return
			continue

		var/atom/movable/movable_eye = processing_client.eye
		if(!istype(movable_eye))
			continue

		while(isloc(movable_eye.loc) && !isturf(movable_eye.loc))
			movable_eye = movable_eye.loc
		//get the last movable holding the mobs eye

		if(movable_eye == processing_client.movingmob)
			if (MC_TICK_CHECK)
				return
			continue

		//eye and the last recorded eye are different, and the last recorded eye isnt just the clients mob
		if(!isnull(processing_client.movingmob))
			LAZYREMOVE(processing_client.movingmob.client_mobs_in_contents, processing_client.mob)
		LAZYADD(movable_eye.client_mobs_in_contents, processing_client.mob)

		processing_client.movingmob = movable_eye
		if (MC_TICK_CHECK)
			return
	currentrun = null

/// Generate a random layer for parallax
/datum/controller/subsystem/parallax/proc/generate_random_parallax_layer()
	var/picked_parallax = pick_weight(random_parallax_weights)

	if(picked_parallax == PARALLAX_NONE)
		return

	random_layer = new picked_parallax()
	random_layer.get_random_look()

	random_layer.apply_global_effects()
