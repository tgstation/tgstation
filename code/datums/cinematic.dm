GLOBAL_LIST_EMPTY(cinematics)

// Use to play cinematics.
// Watcher can be world,mob, or a list of mobs
// Blocks until sequence is done.
/proc/Cinematic(id,watcher,datum/callback/special_callback)
	var/datum/cinematic/playing
	for(var/V in subtypesof(/datum/cinematic))
		var/datum/cinematic/C = V
		if(initial(C.id) == id)
			playing = new V()
			break
	if(!playing)
		CRASH("Cinematic type not found")
	if(special_callback)
		playing.special_callback = special_callback
	if(watcher == world)
		playing.is_global = TRUE
		watcher = GLOB.mob_list
	playing.play(watcher)

/obj/screen/cinematic
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "station_intact"
	layer = 21
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "1,1"

/datum/cinematic
	var/id = CINEMATIC_DEFAULT
	var/list/watching = list() //List of clients watching this
	var/list/locked = list() //Who had notransform set during the cinematic
	var/is_global = FALSE //Global cinematics will override mob-specific ones
	var/obj/screen/cinematic/screen
	var/datum/callback/special_callback //For special effects synced with animation (explosions after the countdown etc)
	var/cleanup_time = 300 //How long for the final screen to remain
	var/stop_ooc = TRUE //Turns off ooc when played globally.

/datum/cinematic/New()
	GLOB.cinematics += src
	screen = new(src)

/datum/cinematic/Destroy()
	GLOB.cinematics -= src
	QDEL_NULL(screen)
	for(var/mob/M in locked)
		M.notransform = FALSE
	return ..()

/datum/cinematic/proc/play(watchers)
	//Check if you can actually play it (stop mob cinematics for global ones) and create screen objects
	for(var/A in GLOB.cinematics)
		var/datum/cinematic/C = A
		if(C == src)
			continue
		if(C.is_global || !is_global)
			return //Can't play two global or local cinematics at the same time

	//Close all open windows if global
	if(is_global)
		SStgui.close_all_uis()

	//Pause OOC
	var/ooc_toggled = FALSE
	if(is_global && stop_ooc && GLOB.ooc_allowed)
		ooc_toggled = TRUE
		toggle_ooc(FALSE)


	for(var/mob/M in GLOB.mob_list)
		if(M in watchers)
			M.notransform = TRUE //Should this be done for non-global cinematics or even at all ?
			locked += M
			//Close watcher ui's
			SStgui.close_user_uis(M)
			if(M.client)
				watching += M.client
				M.client.screen += screen
		else
			if(is_global)
				M.notransform = TRUE
				locked += M

	//Actually play it
	content()
	
	//Restore OOC
	if(ooc_toggled)
		toggle_ooc(TRUE)
	
	//Cleanup
	sleep(cleanup_time)
	qdel(src)

//Sound helper
/datum/cinematic/proc/cinematic_sound(s)
	if(is_global)
		SEND_SOUND(world,s)
	else
		for(var/C in watching)
			SEND_SOUND(C,s)

//Fire up special callback for actual effects synchronized with animation (eg real nuke explosion happens midway)
/datum/cinematic/proc/special()
	if(special_callback)
		special_callback.Invoke()

//Actual cinematic goes in here
/datum/cinematic/proc/content()
	sleep(50)

/datum/cinematic/nuke_win
	id = CINEMATIC_NUKE_WIN

/datum/cinematic/nuke_win/content()
	flick("intro_nuke",screen)
	sleep(35)
	flick("station_explode_fade_red",screen)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	screen.icon_state = "summary_nukewin"

/datum/cinematic/nuke_miss
	id = CINEMATIC_NUKE_MISS

/datum/cinematic/nuke_miss/content()
	flick("intro_nuke",screen)
	sleep(35)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	flick("station_intact_fade_red",screen)
	screen.icon_state = "summary_nukefail"

//Also used for blob
/datum/cinematic/nuke_selfdestruct
	id = CINEMATIC_SELFDESTRUCT

/datum/cinematic/nuke_selfdestruct/content()
	flick("intro_nuke",screen)
	sleep(35)
	flick("station_explode_fade_red", screen)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	screen.icon_state = "summary_selfdes"

/datum/cinematic/nuke_selfdestruct_miss
	id = CINEMATIC_SELFDESTRUCT_MISS

/datum/cinematic/nuke_selfdestruct_miss/content()
	flick("intro_nuke",screen)
	sleep(35)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	screen.icon_state = "station_intact"

/datum/cinematic/malf
	id = CINEMATIC_MALF

/datum/cinematic/malf/content()
	flick("intro_malf",screen)
	sleep(76)
	flick("station_explode_fade_red",screen)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	screen.icon_state = "summary_malf"

/datum/cinematic/cult
	id = CINEMATIC_CULT

/datum/cinematic/cult/content()
	screen.icon_state = null
	flick("intro_cult",screen)
	sleep(25)
	cinematic_sound(sound('sound/magic/enter_blood.ogg'))
	sleep(28)
	cinematic_sound(sound('sound/machines/terminal_off.ogg'))
	sleep(20)
	flick("station_corrupted",screen)
	cinematic_sound(sound('sound/effects/ghost.ogg'))
	sleep(70)
	special()

/datum/cinematic/cult_nuke
	id = CINEMATIC_CULT_NUKE

/datum/cinematic/cult_nuke/content()
	flick("intro_nuke",screen)
	sleep(35)
	flick("station_explode_fade_red",screen)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	screen.icon_state = "summary_cult"

/datum/cinematic/nuke_annihilation
	id = CINEMATIC_ANNIHILATION

/datum/cinematic/nuke_annihilation/content()
	flick("intro_nuke",screen)
	sleep(35)
	flick("station_explode_fade_red",screen)
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()
	screen.icon_state = "summary_totala"

/datum/cinematic/fake
	id = CINEMATIC_NUKE_FAKE
	cleanup_time = 100

/datum/cinematic/fake/content()
	flick("intro_nuke",screen)
	sleep(35)
	cinematic_sound(sound('sound/items/bikehorn.ogg'))
	flick("summary_selfdes",screen) //???
	special()

/datum/cinematic/no_core
	id = CINEMATIC_NUKE_NO_CORE
	cleanup_time = 100

/datum/cinematic/no_core/content()
	flick("intro_nuke",screen)
	sleep(35)
	flick("station_intact",screen)
	cinematic_sound(sound('sound/ambience/signal.ogg'))
	sleep(100)

/datum/cinematic/nuke_far
	id = CINEMATIC_NUKE_FAR
	cleanup_time = 0

/datum/cinematic/nuke_far/content()
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()

/datum/cinematic/clownop
	id = CINEMATIC_NUKE_CLOWNOP
	cleanup_time = 100

/datum/cinematic/clownop/content()
	flick("intro_nuke",screen)
	sleep(35)
	cinematic_sound(sound('sound/items/airhorn.ogg'))
	flick("summary_selfdes",screen) //???
	special()

/* Intended usage.
Nuke.Explosion()
	-> Cinematic(NUKE_BOOM,world)
	-> ActualExplosion()
	-> Mode.OnExplosion()


Narsie()
	-> Cinematic(CULT,world)
*/