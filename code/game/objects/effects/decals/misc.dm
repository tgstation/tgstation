//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/medical/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	///The mob who sourced this puff, if one exists
	var/mob/user
	///The sprayer who fired this puff
	var/obj/item/reagent_containers/spray/sprayer
	///How many interactions we have left before we disappear early
	var/lifetime = INFINITY
	///Are we a part of a stream?
	var/stream
	/// String used in combat logs containing reagents present for when the puff hits something
	var/logging_string

/obj/effect/decal/chempuff/Destroy(force)
	user = null
	sprayer = null
	return ..()

/obj/effect/decal/chempuff/blob_act(obj/structure/blob/B)
	return

/obj/effect/decal/chempuff/proc/end_life(delay = 0.5 SECONDS)
	QDEL_IN(src, delay) //Gotta let it stop drifting
	animate(src, alpha = 0, time = delay)

/obj/effect/decal/chempuff/proc/loop_ended(datum/move_loop/source)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return
	end_life(source.delay)

/obj/effect/decal/chempuff/proc/check_move(datum/move_loop/source, result)
	SIGNAL_HANDLER

	if(QDELETED(src)) //Reasons PLEASE WORK I SWEAR TO GOD
		return
	if(result == MOVELOOP_FAILURE) //If we hit something
		end_life(source.delay)
		return

	spray_down_turf(get_turf(src), travelled_max_distance = (source.lifetime - source.delay <= 0))

	if(lifetime < 0) // Did we use up all the puff early?
		end_life(source.delay)

/**
 * Handles going through every movable on the passed turf and calling [spray_down_atom] on them.
 *
 * [travelled_max_distance] is used to determine if we're at the end of the life, as in some
 * contexts an atom may or may not end up being exposed depending on how far we've travelled.
 */
/obj/effect/decal/chempuff/proc/spray_down_turf(turf/spraying, travelled_max_distance = FALSE)
	for(var/atom/movable/turf_atom in spraying)
		if(turf_atom == src || turf_atom.invisibility) //we ignore the puff itself and stuff below the floor
			continue

		if(lifetime < 0)
			break

		if(!stream)
			spray_down_atom(turf_atom)
			if(ismob(turf_atom))
				lifetime -= 1
			continue

		if(isliving(turf_atom))
			var/mob/living/turf_mob = turf_atom

			if(!turf_mob.can_inject())
				continue
			if(turf_mob.body_position != STANDING_UP && !travelled_max_distance)
				continue

			spray_down_atom(turf_atom)
			lifetime -= 1

		else if(travelled_max_distance)
			spray_down_atom(turf_atom)
			lifetime -= 1

	if(lifetime >= 0 && (!stream || travelled_max_distance))
		spray_down_atom(spraying)
		lifetime -= 1

/// Actually handles exposing the passed atom to the reagents and logging
/obj/effect/decal/chempuff/proc/spray_down_atom(atom/spraying)
	if(isnull(logging_string))
		logging_string = reagents.get_reagent_log_string()

	reagents.expose(spraying, VAPOR)
	log_combat(user, spraying, "sprayed", sprayer, addition = "which had [logging_string]")

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	density = TRUE
