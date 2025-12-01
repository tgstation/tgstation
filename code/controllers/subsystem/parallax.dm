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
	var/random_parallax_weights = list(
		/atom/movable/screen/parallax_layer/random/space_gas = 35,
		/atom/movable/screen/parallax_layer/random/asteroids = 35,
		PARALLAX_NONE = 30,
	)

//These are cached per client so needs to be done asap so people joining at roundstart do not miss these.
/datum/controller/subsystem/parallax/PreInit()
	. = ..()

	set_random_parallax_layer(pick_weight(random_parallax_weights))

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
/datum/controller/subsystem/parallax/proc/set_random_parallax_layer(picked_parallax)
	if(picked_parallax == PARALLAX_NONE)
		return

	random_layer = new picked_parallax(null,  /* hud_owner = */ null, /* template = */ TRUE)
	RegisterSignal(random_layer, COMSIG_QDELETING, PROC_REF(clear_references))
	random_layer.get_random_look()

/// Change the random parallax layer after it's already been set. update_player_huds = TRUE will also replace them in the players client images, if it was set
/datum/controller/subsystem/parallax/proc/swap_out_random_parallax_layer(atom/movable/screen/parallax_layer/new_type, update_player_huds = TRUE)
	set_random_parallax_layer(new_type)

	if(!update_player_huds)
		return

	//Parallax is one of the first things to be set (during client join), so rarely is anything fast enough to swap it out
	//That's why we need to swap the layers out for fast joining clients :/
	for(var/client/client as anything in GLOB.clients)
		client.parallax_layers_cached?.Cut()
		client.mob?.hud_used?.update_parallax_pref(client.mob)

/datum/controller/subsystem/parallax/proc/clear_references()
	SIGNAL_HANDLER

	random_layer = null

/// Called at the end of SSstation setup, in-case we want to run some code that would otherwise be too early to run (like GLOB. stuff)
/datum/controller/subsystem/parallax/proc/post_station_setup()
	random_layer?.apply_global_effects()

/// Return the most dominant color, if we have a colored background (mostly nebula gas)
/datum/controller/subsystem/parallax/proc/get_parallax_color()
	var/atom/movable/screen/parallax_layer/random/space_gas/gas = random_layer
	if(!istype(gas))
		return

	return gas.parallax_color

#undef PARALLAX_NONE
