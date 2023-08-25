/**
 * Plays a cinematic, duh. Can be to a select few people, or everyone.
 *
 * cinematic_type - datum typepath to what cinematic you wish to play.
 * watchers - a list of all mobs you are playing the cinematic to. If world, the cinematical will play globally to all players.
 * special_callback - optional callback to be invoked mid-cinematic.
 */
/proc/play_cinematic(datum/cinematic/cinematic_type, watchers, datum/callback/special_callback)
	if(!ispath(cinematic_type, /datum/cinematic))
		CRASH("play_cinematic called with a non-cinematic type. (Got: [cinematic_type])")
	var/datum/cinematic/playing = new cinematic_type(watchers, special_callback)

	if(watchers == world)
		watchers = GLOB.mob_list

	playing.start_cinematic(watchers)

	return playing

/// The cinematic screen showed to everyone
/atom/movable/screen/cinematic
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "station_intact"
	plane = SPLASHSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "BOTTOM,LEFT+50%"
	appearance_flags = APPEARANCE_UI | TILE_BOUND

/// Cinematic datum. Used to show an animation to everyone.
/datum/cinematic
	/// A list of all clients watching the cinematic
	var/list/client/watching = list()
	/// A list of all mobs who have notransform set while watching the cinematic
	var/list/datum/weakref/locked = list()
	/// Whether the cinematic is a global cinematic or not
	var/is_global = FALSE
	/// Refernce to the cinematic screen shown to everyohne
	var/atom/movable/screen/cinematic/screen
	/// Callbacks passed that occur during the animation
	var/datum/callback/special_callback
	/// How long for the final screen remains shown
	var/cleanup_time = 30 SECONDS
	/// Whether the cinematic turns off ooc when played globally.
	var/stop_ooc = TRUE

/datum/cinematic/New(watcher, datum/callback/special_callback)
	screen = new(src)
	if(watcher == world)
		is_global = TRUE

	src.special_callback = special_callback

/datum/cinematic/Destroy()
	QDEL_NULL(screen)
	special_callback = null
	watching.Cut()
	locked.Cut()
	return ..()

/// Actually goes through the process of showing the cinematic to the list of watchers.
/datum/cinematic/proc/start_cinematic(list/watchers)
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PLAY_CINEMATIC, src) & COMPONENT_GLOB_BLOCK_CINEMATIC)
		return

	// Register a signal to handle what happens when a different cinematic tries to play over us.
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAY_CINEMATIC, PROC_REF(handle_replacement_cinematics))

	// Pause OOC
	var/ooc_toggled = FALSE
	if(is_global && stop_ooc && GLOB.ooc_allowed)
		ooc_toggled = TRUE
		toggle_ooc(FALSE)

	// Place the /atom/movable/screen/cinematic into everyone's screens, and prevent movement.
	for(var/mob/watching_mob in watchers)
		show_to(watching_mob, GET_CLIENT(watching_mob))
		RegisterSignal(watching_mob, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(show_to))
		// Close watcher ui's, too, so they can watch it.
		SStgui.close_user_uis(watching_mob)

	// Actually plays the animation. This will sleep, likely.
	play_cinematic()

	// Cleans up after it's done playing.
	addtimer(CALLBACK(src, PROC_REF(clean_up_cinematic), ooc_toggled), cleanup_time)

/// Cleans up the cinematic after a set timer of it sticking on the end screen.
/datum/cinematic/proc/clean_up_cinematic(was_ooc_toggled = FALSE)
	if(was_ooc_toggled)
		toggle_ooc(TRUE)

	stop_cinematic()

/// Whenever another cinematic starts to play over us, we have the chacne to block it.
/datum/cinematic/proc/handle_replacement_cinematics(datum/source, datum/cinematic/other)
	SIGNAL_HANDLER

	// Stop our's and allow others to play if we're local and it's global
	if(!is_global && other.is_global)
		stop_cinematic()
		return NONE

	return COMPONENT_GLOB_BLOCK_CINEMATIC

/// Whenever a mob watching the cinematic logs in, show them the ongoing cinematic
/datum/cinematic/proc/show_to(mob/watching_mob, client/watching_client)
	SIGNAL_HANDLER

	// We could technically rip people out of notransform who shouldn't be,
	// so we'll only lock down all viewing mobs who don't have it already set.
	// This does potentially mean some mobs could lose their notrasnform and
	// not be locked down by cinematics, but that should be very unlikely.
	if(!watching_mob.notransform)
		lock_mob(watching_mob)

	// Only show the actual cinematic to cliented mobs.
	if(!watching_client || (watching_client in watching))
		return

	watching += watching_client
	watching_mob.overlay_fullscreen("cinematic", /atom/movable/screen/fullscreen/cinematic_backdrop)
	watching_client.screen += screen
	RegisterSignal(watching_client, COMSIG_QDELETING, PROC_REF(remove_watcher))

/// Simple helper for playing sounds from the cinematic.
/datum/cinematic/proc/play_cinematic_sound(sound_to_play)
	if(is_global)
		SEND_SOUND(world, sound_to_play)
	else
		for(var/client/watching_client as anything in watching)
			SEND_SOUND(watching_client, sound_to_play)

/// Invoke any special callbacks for actual effects synchronized with animation.
/// (Such as a real nuke explosion happening midway)
/datum/cinematic/proc/invoke_special_callback()
	special_callback?.Invoke()

/// The actual cinematic occurs here.
/datum/cinematic/proc/play_cinematic()
	return

/// Stops the cinematic and removes it from all the viewers.
/datum/cinematic/proc/stop_cinematic()
	for(var/client/viewing_client as anything in watching)
		remove_watcher(viewing_client)

	for(var/datum/weakref/locked_ref as anything in locked)
		unlock_mob(locked_ref)

	qdel(src)

/// Locks a mob, preventing them from moving, being hurt, or acting
/datum/cinematic/proc/lock_mob(mob/to_lock)
	locked += WEAKREF(to_lock)
	to_lock.notransform = TRUE

/// Unlocks a previously locked weakref
/datum/cinematic/proc/unlock_mob(datum/weakref/mob_ref)
	var/mob/locked_mob = mob_ref.resolve()
	if(isnull(locked_mob))
		return
	locked_mob.notransform = FALSE
	UnregisterSignal(locked_mob, COMSIG_MOB_CLIENT_LOGIN)

/// Removes the passed client from our watching list.
/datum/cinematic/proc/remove_watcher(client/no_longer_watching)
	SIGNAL_HANDLER

	if(!(no_longer_watching in watching))
		CRASH("cinematic remove_watcher was passed a client which wasn't watching.")

	UnregisterSignal(no_longer_watching, COMSIG_QDELETING)
	// We'll clear the cinematic if they have a mob which has one,
	// but we won't remove notransform. Wait for the cinematic end to do that.
	no_longer_watching.mob?.clear_fullscreen("cinematic")
	no_longer_watching.screen -= screen

	watching -= no_longer_watching
