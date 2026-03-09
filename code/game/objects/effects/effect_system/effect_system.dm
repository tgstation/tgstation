/*
 * This is an attempt to make some easily reusable "particle" type effect, to stop the code
 * constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
 * defined, then set up when it is created with New(). Then this same system can just be reused each time
 * it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
 * would spawn and follow the beaker, even if it is carried or thrown.
*/

#define PER_SYSTEM_PARTICLE_CAP 20

/obj/effect/particle_effect
	name = "particle effect"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE | PASSGRILLE
	anchored = TRUE

// Prevents effects from getting registered for SSnewtonian_movement
/obj/effect/particle_effect/newtonian_move(inertia_angle, instant = FALSE, start_delay = 0, drift_force = 0, controlled_cap = null)
	return TRUE

/datum/effect_system
	// Does not contain any behaviors and should not be used by itself
	abstract_type = /datum/effect_system
	/// Turf on which to spawn the effects
	var/turf/location = null
	/// Atom that is spawning the particles whose location we're following
	var/atom/holder = null

/datum/effect_system/New(turf/location)
	. = ..()
	src.location = get_turf(location)

/datum/effect_system/Destroy()
	holder = null
	location = null
	return ..()

/// Instruct the effect system to start following an atom. Can be chained into .start()
/datum/effect_system/proc/attach(atom/new_holder)
	RETURN_TYPE(/datum/effect_system)
	holder = new_holder
	return src

/// Start the effect system
/datum/effect_system/proc/start()
	return

/// Basic effect system which spawns a certain number of moving effects
/datum/effect_system/basic
	/// Total number of particles to spawn
	var/amount = 3
	/// Should we pick among cardinals or all directions when deciding where the particle should move
	var/cardinals_only = FALSE
	/// Typepath of the effect to spawn
	var/effect_type = null
	/// Total amount of effects we currently have active
	var/total_effects = 0
	/// Should the system delete itself after finishing?
	var/autocleanup = FALSE
	/// Should the system delete effects that stop moving?
	var/delete_on_stop = FALSE
	/// How frequently (in deciseconds) should we move our particles?
	var/step_delay = 0.5 SECONDS

	// Internal use
	/// The length of the previous assigned moveloop in deciseconds
	var/last_loop_length = 0

/datum/effect_system/basic/New(turf/location, amount = null, cardinals_only = null)
	. = ..()
	if (!isnull(amount))
		src.amount = amount
	if (!isnull(cardinals_only))
		src.cardinals_only = cardinals_only

/datum/effect_system/basic/start()
	if(QDELETED(src))
		return
	for(var/i in 1 to amount)
		if(total_effects > PER_SYSTEM_PARTICLE_CAP)
			return
		generate_effect()

/// Returns how many steps to attempt to move a generated effect
/datum/effect_system/basic/proc/get_step_count()
	return rand(1, 3)

/// Generates a effect for our system to control, returns the generated effect
/datum/effect_system/basic/proc/generate_effect()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/effect = new effect_type(location)
	total_effects++
	var/direction
	if(cardinals_only)
		direction = pick(GLOB.cardinals)
	else
		direction = pick(GLOB.alldirs)

	var/step_count = get_step_count()
	var/datum/move_loop/loop = GLOB.move_manager.move(effect, direction, step_delay, timeout = step_delay * step_count, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_end))
	last_loop_length = loop.lifetime
	return effect

/datum/effect_system/basic/proc/post_move(datum/move_loop/source, result, visual_delay)
	SIGNAL_HANDLER
	if(result == MOVELOOP_FAILURE)
		move_failed(source, source.moving)

/// Allows us to hook into being unable to automatically move
/datum/effect_system/basic/proc/move_failed(datum/move_loop/loop, obj/effect/failed)
	if(QDELETED(failed) || !delete_on_stop)
		return
	qdel(failed)

/datum/effect_system/basic/proc/loop_end(datum/move_loop/source)
	SIGNAL_HANDLER
	total_effects--
	if(delete_on_stop && !QDELETED(source.moving))
		qdel(source.moving)
	if(autocleanup && total_effects == 0)
		QDEL_IN(src, 2 SECONDS)

#undef PER_SYSTEM_PARTICLE_CAP
