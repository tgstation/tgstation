/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effect/particle_effect
	name = "particle effect"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE | PASSGRILLE
	anchored = TRUE

/obj/effect/particle_effect/Initialize(mapload)
	. = ..()
	GLOB.cameranet.updateVisibility(src)

/obj/effect/particle_effect/Destroy()
	GLOB.cameranet.updateVisibility(src)
	return ..()

// Prevents effects from getting registered for SSspacedrift
/obj/effect/particle_effect/newtonian_move(direction, instant = FALSE, start_delay = 0)
	return TRUE

/datum/effect_system
	var/number = 3
	var/cardinals_only = FALSE
	var/turf/location
	var/atom/holder
	var/effect_type
	var/total_effects = 0
	var/autocleanup = FALSE //will delete itself after use

/datum/effect_system/Destroy()
	holder = null
	location = null
	return ..()

/datum/effect_system/proc/set_up(number = 3, cardinals_only = FALSE, location)
	src.number = min(number, 10)
	src.cardinals_only = cardinals_only
	src.location = get_turf(location)

/datum/effect_system/proc/attach(atom/atom)
	holder = atom

/datum/effect_system/proc/start()
	if(QDELETED(src))
		return
	for(var/i in 1 to number)
		if(total_effects > 20)
			return
		generate_effect()

/datum/effect_system/proc/generate_effect()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/effect = new effect_type(location)
	total_effects++
	var/direction
	if(cardinals_only)
		direction = pick(GLOB.cardinals)
	else
		direction = pick(GLOB.alldirs)
	var/step_amt = pick(1,2,3)
	var/step_delay = 5

	var/datum/move_loop/loop = SSmove_manager.move(effect, direction, step_delay, timeout = step_delay * step_amt, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, PROC_REF(decrement_total_effect))

/datum/effect_system/proc/decrement_total_effect(datum/source)
	SIGNAL_HANDLER
	total_effects--
	if(!autocleanup || total_effects > 0)
		return
	QDEL_IN(src, 2 SECONDS)
