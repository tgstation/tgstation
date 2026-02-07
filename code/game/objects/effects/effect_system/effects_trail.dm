
/////////////////////////////////////////////
//////// Attach a trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/datum/effect_system/trail_follow
	/// Previous position of the atom we're tracking
	var/turf/oldposition
	/// Are we currently spawning particles?
	var/active = FALSE
	/// Can the particles be spawned ontop of eachother?
	var/allow_overlap = FALSE
	/// Should we automatically start processing ourselves?
	var/auto_process = TRUE
	/// Delay before we delete the particles
	var/qdel_in_time = 1 SECONDS
	/// Typepath we should spawn
	var/effect_type = null
	/// Should we flick an icon state and blank out the particles afterwards?
	var/fade = TRUE
	/// icon_state to flick on our particles
	var/fadetype = "ion_fade"
	/// Are we restricted to zero-g only?
	var/nograv_required = FALSE

/datum/effect_system/trail_follow/New(turf/location)
	. = ..()
	attach(location)
	oldposition = location

/datum/effect_system/trail_follow/Destroy()
	oldposition = null
	stop()
	return ..()

/datum/effect_system/trail_follow/proc/stop()
	oldposition = null
	STOP_PROCESSING(SSfastprocess, src)
	active = FALSE
	return TRUE

/datum/effect_system/trail_follow/start()
	oldposition = get_turf(holder)
	if(!check_conditions())
		return FALSE
	if(auto_process)
		START_PROCESSING(SSfastprocess, src)
	active = TRUE
	return TRUE

/datum/effect_system/trail_follow/process()
	generate_effect()

/datum/effect_system/trail_follow/proc/generate_effect()
	if(!check_conditions())
		return stop()

	if(!oldposition || oldposition == get_turf(holder))
		oldposition = get_turf(holder)
		return

	if(nograv_required && oldposition.has_gravity())
		oldposition = get_turf(holder)
		return

	var/obj/effect/particle = new effect_type(oldposition)
	set_dir(particle)
	if(fade)
		flick(fadetype, particle)
		particle.icon_state = ""

	if(qdel_in_time)
		QDEL_IN(particle, qdel_in_time)

/datum/effect_system/trail_follow/proc/check_conditions()
	if(!get_turf(holder))
		return FALSE
	return TRUE

/datum/effect_system/trail_follow/proc/set_dir(obj/effect/effect)
	effect.setDir(holder.dir)

/datum/effect_system/trail_follow/steam
	effect_type = /obj/effect/particle_effect/steam

/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = TRUE

/obj/effect/particle_effect/ion_trails/flight
	icon_state = "ion_trails_flight"

/datum/effect_system/trail_follow/ion
	effect_type = /obj/effect/particle_effect/ion_trails
	nograv_required = TRUE
	qdel_in_time = 2 SECONDS

/datum/effect_system/trail_follow/ion/grav_allowed
	nograv_required = FALSE
