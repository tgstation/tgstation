GLOBAL_LIST_EMPTY(cinematics)

// Use to play cinematics.
// Watcher can be world,mob, or a list of mobs
// Blocks until sequence is done.
/proc/Cinematic(cinematic,watcher)
	var/cinematic/playing
	for(var/datum/cinematic/C in subtypesof(/datum/cinematic))
		if(inital(C.name) == cinematic)
			playing = new C()
			break
	if(watcher == world)
		playing.global = TRUE
		watcher = GLOB.mob_list
	playing.play(watcher)

/obj/screen/cinematic
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "station_intact"
	layer = 21
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "1,0"

/datum/cinematic
	name = CINEMATIC_DEFAULT
	var/list/watching //List of clients watching this
	var/list/locked //Who had notransform set during the cinematic
	var/global = FALSE //Global cinematics will override mob-specific ones
	var/obj/screen/cinematic_screen/screen

/datum/cinematic/New()
	cinematics += src
	screen = new(src)

/datum/cinematic/Destroy()
	cinematics -= src
	qdel(screen)
	for(var/mob/M in locked)
		M.notransform = FALSE
	return ..()

/datum/cinematic/proc/play(watchers)
	//Check if you can actually play it (stop mob cinematics for global ones) and create screen objects
	for(var/A in cinematics)
		var/datum/cinematic/C = A
		if(C.global || !global)
			return //Can't play two global or local cinematics at the same time

	for(var/mob/M in GLOB.mob_list)
		if(M in watchers)
			M.notransform = TRUE //Should this be done for non-global cinematics or even at all ?
			locked += M
			if(M.client)
				watching += M.client
				M.client.screen += screen
		else
			if(global)
				M.notransform = TRUE
				locked += M
	
	//Actually play it
	content()
	//Cleanup
	qdel(src)

//Sound helper
/datum/cinematic/proc/cinematic_sound(s)
	if(global)
		SEND_SOUND(world,s)
	else
		for(var/C in watching)
			SEND_SOUND(C,s)

//Fire up special callback for actual effects synchronized with animation (eg real nuke explosion happens midway)
/datum/cinematic/proc/special()
	return

//Actual cinematic goes in here
/datum/cinematic/proc/content()
	sleep(50)

/datum/cinematic/nuke_station
	name = CINEMATIC_NUKE_STATION

/datum/cinematic/nuke_station/content()
	flick("intro_nuke",screen)
	sleep(35)
	flick("station_explode_fade_red",screen)
	cinematic_sound('sound/effects/explosion_distant.ogg'))
	special()
	//station_explosion_detonation(bomb)

/datum/cinematic/nuke_station/ops/content()
	..()
	cinematic.icon_state = "summary_nukewin"

/datum/cinematic/nuke_near_miss
/datum/cinematic/nuke_full_miss
/datum/cinematic/malf
/datum/cinematic/fake

/* Intended usage.
Nuke.Explosion()
	-> Cinematic(NUKE_BOOM,world)
	-> ActualExplosion()
	-> Mode.OnExplosion()


Narsie()
	-> Cinematic(CULT,world)
*/