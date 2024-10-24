/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = 0
	var/stopper = 1 // stops throwers
	var/mobs_only = FALSE
	invisibility = INVISIBILITY_ABSTRACT // nope cant see this shit
	anchored = TRUE

/obj/effect/step_trigger/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/step_trigger/proc/Trigger(atom/movable/A)
	return 0

/obj/effect/step_trigger/proc/on_entered(datum/source, H as mob|obj)
	SIGNAL_HANDLER
	if(!H || H == src)
		return
	if(isobserver(H) && !affect_ghosts)
		return
	if(!ismob(H) && mobs_only)
		return
	INVOKE_ASYNC(src, PROC_REF(Trigger), H)


/obj/effect/step_trigger/singularity_act()
	return

/obj/effect/step_trigger/singularity_pull()
	return

/* Sends a message to mob when triggered*/

/obj/effect/step_trigger/message
	var/message //the message to give to the mob
	var/once = 1
	mobs_only = TRUE

/obj/effect/step_trigger/message/Trigger(mob/M)
	if(M.client)
		to_chat(M, span_info("[message]"))
		if(once)
			qdel(src)

/* Tosses things in a certain direction */
/obj/effect/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3 // if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1 // delay of movement
	var/facedir = 0 // if 1: atom faces the direction of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	///List of moving atoms mapped to their inital direction
	var/list/affecting = list()

/obj/effect/step_trigger/thrower/Trigger(atom/A)
	if(!A || !ismovable(A))
		return
	var/atom/movable/AM = A
	for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
		if(AM in T.affecting)
			return

	if(immobilize)
		ADD_TRAIT(AM, TRAIT_IMMOBILIZED, REF(src))

	affecting[AM] = AM.dir
	var/datum/move_loop/loop = GLOB.move_manager.move(AM, direction, speed, tiles ? tiles * speed : INFINITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(set_to_normal))

/obj/effect/step_trigger/thrower/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/being_moved = source.moving
	affecting[being_moved] = being_moved.dir

/obj/effect/step_trigger/thrower/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/being_moved = source.moving
	if(!facedir)
		being_moved.setDir(affecting[being_moved])
	if(being_moved.z != z)
		qdel(source)
		return
	if(!nostop)
		for(var/obj/effect/step_trigger/T in get_turf(being_moved))
			if(T.stopper && T != src)
				qdel(source)
				return
	else
		for(var/obj/effect/step_trigger/teleporter/T in get_turf(being_moved))
			if(T.stopper)
				qdel(source)
				return

/obj/effect/step_trigger/thrower/proc/set_to_normal(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/being_moved = source.moving
	affecting -= being_moved
	REMOVE_TRAIT(being_moved, TRAIT_IMMOBILIZED, REF(src))


/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = 0 // teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0

/obj/effect/step_trigger/teleporter/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)

		var/turf/T = locate(teleport_x, teleport_y, teleport_z)
		A.forceMove(T)

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

/obj/effect/step_trigger/teleporter/random/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)
		if(teleport_x_offset && teleport_y_offset && teleport_z_offset)

			var/turf/T = locate(rand(teleport_x, teleport_x_offset), rand(teleport_y, teleport_y_offset), rand(teleport_z, teleport_z_offset))
			if (T)
				A.forceMove(T)

/* Teleports atoms directly to an offset, no randomness, looping hallways! */

/obj/effect/step_trigger/teleporter/offset
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0

/obj/effect/step_trigger/teleporter/offset/on_entered(datum/source, H as mob|obj, atom/old_loc)
	if(!old_loc?.Adjacent(loc)) // prevents looping, if we were teleported into this then the old loc is usually not adjacent
		return
	return ..()

/obj/effect/step_trigger/teleporter/offset/Trigger(atom/movable/poor_soul)
	var/turf/destination = locate(x + teleport_x_offset, y + teleport_y_offset, z)
	if(!destination)
		return
	poor_soul.forceMove(destination)
	var/mob/living/living_soul = poor_soul
	if(istype(living_soul) && living_soul.client)
		living_soul.client.move_delay = 0

/* Fancy teleporter, creates sparks and smokes when used */

/obj/effect/step_trigger/teleport_fancy
	var/locationx
	var/locationy
	var/uses = 1 //0 for infinite uses
	var/entersparks = 0
	var/exitsparks = 0
	var/entersmoke = 0
	var/exitsmoke = 0

/obj/effect/step_trigger/teleport_fancy/Trigger(mob/M)
	var/dest = locate(locationx, locationy, z)
	M.Move(dest)

	if(entersparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, src)
		s.start()
	if(exitsparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, dest)
		s.start()

	if(entersmoke)
		var/datum/effect_system/fluid_spread/smoke/s = new
		s.set_up(4, holder = src, location = src)
		s.start()
	if(exitsmoke)
		var/datum/effect_system/fluid_spread/smoke/s = new
		s.set_up(4, holder = src, location = dest)
		s.start()

	uses--
	if(uses == 0)
		qdel(src)

/* Simple sound player, Mapper friendly! */

/obj/effect/step_trigger/sound_effect
	var/sound //eg. path to the sound, inside '' eg: 'growl.ogg'
	var/volume = 100
	var/freq_vary = 1 //Should the frequency of the sound vary?
	var/extra_range = 0 // eg World.view = 7, extra_range = 1, 7+1 = 8, 8 turfs radius
	var/happens_once = 0
	var/triggerer_only = 0 //Whether the triggerer is the only person who hears this


/obj/effect/step_trigger/sound_effect/Trigger(atom/movable/A)
	var/turf/T = get_turf(A)

	if(!T)
		return

	if(triggerer_only && ismob(A))
		var/mob/B = A
		B.playsound_local(T, sound, volume, freq_vary)
	else
		playsound(T, sound, volume, freq_vary, extra_range)

	if(happens_once)
		qdel(src)

/obj/effect/step_trigger/sound_effect/lavaland_cult_altar
	happens_once = 1
	name = "a grave mistake";
	sound = 'sound/effects/hallucinations/i_see_you1.ogg'
	triggerer_only = 1
