/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effect/effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = 0
	unacidable = 1//So effect are not targeted by alien acid.
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/effect/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL
/*
/datum/effect/effect/proc/fadeOut(var/atom/A, var/frames = 16)
	if(A.alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = A.alpha / frames
	for(var/i = 0, i < frames, i++)
		A.alpha -= step
		sleep(world.tick_lag)
	return
*/
/datum/effect/effect/system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/setup = 0

/datum/effect/effect/system/Destroy()
	holder = null
	location = null
	..()

/datum/effect/effect/system/proc/set_up(n = 3, c = 0, turf/loc)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	location = loc
	setup = 1

/datum/effect/effect/system/proc/attach(atom/atom)
	holder = atom

/datum/effect/effect/system/proc/start()